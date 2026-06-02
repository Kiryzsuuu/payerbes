import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/superhero.dart';
import '../services/superhero_service.dart';

class SuperheroProvider extends ChangeNotifier {
  final SuperheroService _service = SuperheroService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Superhero> _featured = [];
  List<Superhero> _searchResults = [];
  Set<String> _favoriteIds = {};
  List<Superhero> _favoriteHeroes = [];

  bool _loadingFeatured = false;
  bool _loadingSearch = false;
  bool _loadingFavorites = false;
  String _searchQuery = '';
  String? _error;

  List<Superhero> get featured => _featured;
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
    // Sync favorit tiap kali auth berubah (login/logout)
    _auth.authStateChanges().listen((_) => _loadFavorites());
  }

  // ── Featured ────────────────────────────────────────────
  Future<void> loadFeatured() async {
    _loadingFeatured = true;
    _error = null;
    notifyListeners();
    try {
      _featured = await _service.getFeaturedHeroes();
    } catch (_) {
      _error = 'Gagal memuat hero. Periksa koneksi internet.';
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
      _searchResults = await _service.searchHeroes(query.trim());
    } catch (_) {
      _searchResults = [];
    }
    _loadingSearch = false;
    notifyListeners();
  }

  // ── Favorit (Firestore) ──────────────────────────────────
  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> toggleFavorite(Superhero hero) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final ref = _db.collection('users').doc(uid).collection('favorites').doc(hero.id);

    if (_favoriteIds.contains(hero.id)) {
      _favoriteIds.remove(hero.id);
      _favoriteHeroes.removeWhere((h) => h.id == hero.id);
      await ref.delete();
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

      if (_favoriteIds.isNotEmpty) {
        final futures = _favoriteIds.map((id) => _service.getHeroById(id));
        final results = await Future.wait(futures);
        _favoriteHeroes = results.whereType<Superhero>().toList();
      } else {
        _favoriteHeroes = [];
      }
    } catch (_) {}

    _loadingFavorites = false;
    notifyListeners();
  }
}
