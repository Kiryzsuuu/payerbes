import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/superhero.dart';
import '../models/custom_hero.dart';
import '../services/superhero_service.dart';
import '../services/logger_service.dart';

class SuperheroProvider extends ChangeNotifier {
  final SuperheroService _service = SuperheroService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Superhero> _apiFeatured = [];
  List<Superhero> _customHeroes = [];
  List<Superhero> _searchResults = [];
  Set<String> _favoriteIds = {};
  List<Superhero> _favoriteHeroes = [];

  bool _loadingFeatured = false;
  bool _loadingSearch = false;
  bool _loadingFavorites = false;
  String _searchQuery = '';
  String? _error;

  List<Superhero> get featured => [..._customHeroes, ..._apiFeatured];
  Set<String> get customHeroIds => _customHeroes.map((h) => h.id).toSet();
  List<Superhero> get searchResults => _searchResults;
  List<Superhero> get favoriteHeroes => _favoriteHeroes;
  Set<String> get favoriteIds => _favoriteIds;
  bool get loadingFeatured => _loadingFeatured;
  bool get loadingSearch => _loadingSearch;
  bool get loadingFavorites => _loadingFavorites;
  String get searchQuery => _searchQuery;
  String? get error => _error;

  SuperheroProvider() {
    loadFeatured();
    _listenCustomHeroes();
    _auth.authStateChanges().listen((_) => _loadFavorites());
  }

  void _listenCustomHeroes() {
    _db
        .collection('custom_heroes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      _customHeroes = snap.docs
          .map((doc) => CustomHero.fromDoc(doc).toSuperhero())
          .toList();
      AppLogger.firestoreRead('custom_heroes (featured)', snap.docs.length);
      notifyListeners();
    });
  }

  // ── Featured ────────────────────────────────────────────
  Future<void> loadFeatured() async {
    _loadingFeatured = true;
    _error = null;
    notifyListeners();
    AppLogger.info('Memuat featured heroes dari API...');
    try {
      _apiFeatured = await _service.getFeaturedHeroes();
      AppLogger.info('Featured heroes berhasil dimuat: ${_apiFeatured.length} hero');
    } catch (e) {
      _error = 'Gagal memuat hero. Periksa koneksi internet.';
      AppLogger.apiError('getFeaturedHeroes', e.toString());
    }
    _loadingFeatured = false;
    notifyListeners();
  }

  // ── Search ───────────────────────────────────────────────
  Future<void> search(String query) async {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _loadingSearch = true;
    notifyListeners();
    try {
      final apiResults = await _service.searchHeroes(query.trim());
      final localMatches = _customHeroes
          .where((h) => h.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      // custom heroes di depan supaya selalu muncul
      final seen = <String>{};
      _searchResults = [...localMatches, ...apiResults]
          .where((h) => seen.add(h.id))
          .toList();
      AppLogger.search(query, _searchResults.length);
    } catch (e) {
      _searchResults = [];
      AppLogger.apiError('searchHeroes', e.toString());
    }
    _loadingSearch = false;
    notifyListeners();
  }

  // ── Favorit (Firestore) ──────────────────────────────────
  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> toggleFavorite(Superhero hero) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(hero.id);

    if (_favoriteIds.contains(hero.id)) {
      _favoriteIds.remove(hero.id);
      _favoriteHeroes.removeWhere((h) => h.id == hero.id);
      await ref.delete();
      AppLogger.favoriteRemoved(hero.name, uid);
      AppLogger.firestoreDelete('users/$uid/favorites', hero.id);
    } else {
      _favoriteIds.add(hero.id);
      _favoriteHeroes.add(hero);
      await ref.set({
        'heroId': hero.id,
        'name': hero.name,
        'imageUrl': hero.imageUrl,
        'publisher': hero.biography.publisher,
        'alignment': hero.biography.alignment,
        'addedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.favoriteAdded(hero.name, uid);
      AppLogger.firestoreWrite('users/$uid/favorites', hero.id);
    }
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _favoriteIds = {};
      _favoriteHeroes = [];
      notifyListeners();
      return;
    }

    _loadingFavorites = true;
    notifyListeners();

    try {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .get();

      _favoriteIds = snap.docs.map((d) => d.id).toSet();
      AppLogger.firestoreRead('users/$uid/favorites', snap.docs.length);

      if (_favoriteIds.isNotEmpty) {
        final futures = _favoriteIds.map((id) => _service.getHeroById(id));
        final results = await Future.wait(futures);
        _favoriteHeroes = results.whereType<Superhero>().toList();
        AppLogger.info(
            'Favorit dimuat: ${_favoriteHeroes.length} hero untuk UID $uid');
      } else {
        _favoriteHeroes = [];
      }
    } catch (e) {
      AppLogger.apiError('loadFavorites', e.toString());
    }

    _loadingFavorites = false;
    notifyListeners();
  }
}
