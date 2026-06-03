import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/custom_hero.dart';
import '../services/logger_service.dart';

const _adminEmail = 'maskiryz23@gmail.com';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _currentUserModel;
  List<CustomHero> _customHeroes = [];
  bool _loading = false;
  String? _error;

  UserModel? get currentUserModel => _currentUserModel;
  List<CustomHero> get customHeroes => _customHeroes;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAdmin => _currentUserModel?.isAdmin ?? false;

  AdminProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _initUser(user);
        _listenHeroes();
      } else {
        _currentUserModel = null;
        _customHeroes = [];
        notifyListeners();
      }
    });
  }

  Future<void> _initUser(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final doc = await ref.get();
    final role = user.email == _adminEmail ? 'admin' : 'user';

    if (!doc.exists) {
      await ref.set({
        'email': user.email ?? '',
        'role': role,
        'displayName': user.displayName ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      AppLogger.firestoreWrite('users', user.uid);
      AppLogger.info('User baru didaftarkan: ${user.email} | Role: $role');
    } else {
      if (user.email == _adminEmail && doc['role'] != 'admin') {
        await ref.update({'role': 'admin'});
      }
    }

    final updated = await ref.get();
    _currentUserModel = UserModel.fromDoc(updated);
    AppLogger.firestoreRead('users', 1);
    AppLogger.info(
        'Session aktif: ${user.email} | Role: ${_currentUserModel?.role.name}');
    notifyListeners();
  }

  void _listenHeroes() {
    _db
        .collection('custom_heroes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      _customHeroes = snap.docs.map(CustomHero.fromDoc).toList();
      AppLogger.firestoreRead('custom_heroes', snap.docs.length);
      notifyListeners();
    });
  }

  // ── CREATE ───────────────────────────────────────────────
  Future<bool> addHero(CustomHero hero) async {
    if (!isAdmin) return false;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = hero.toMap();
      final by = _auth.currentUser?.email ?? '';
      data['createdBy'] = by;
      final docRef = await _db.collection('custom_heroes').add(data);
      AppLogger.heroAdded(hero.name, by);
      AppLogger.firestoreWrite('custom_heroes', docRef.id);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menambah hero: $e';
      AppLogger.apiError('custom_heroes/add', e.toString());
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // ── UPDATE ───────────────────────────────────────────────
  Future<bool> updateHero(String id, CustomHero hero) async {
    if (!isAdmin) return false;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = hero.toMap();
      data.remove('createdAt');
      await _db.collection('custom_heroes').doc(id).update(data);
      AppLogger.heroUpdated(hero.name, _auth.currentUser?.email ?? '');
      AppLogger.firestoreWrite('custom_heroes', id);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal update hero: $e';
      AppLogger.apiError('custom_heroes/update', e.toString());
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // ── DELETE ───────────────────────────────────────────────
  Future<bool> deleteHero(String id) async {
    if (!isAdmin) return false;
    try {
      // Cari nama hero sebelum dihapus
      final name = _customHeroes
          .where((h) => h.id == id)
          .map((h) => h.name)
          .firstOrNull ?? id;
      await _db.collection('custom_heroes').doc(id).delete();
      AppLogger.heroDeleted(name, _auth.currentUser?.email ?? '');
      AppLogger.firestoreDelete('custom_heroes', id);
      return true;
    } catch (e) {
      _error = 'Gagal hapus hero: $e';
      AppLogger.apiError('custom_heroes/delete', e.toString());
      notifyListeners();
      return false;
    }
  }
}
