import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/site_settings.dart';
import '../services/logger_service.dart';

class SiteSettingsProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  SiteSettings _settings = const SiteSettings();
  bool _saving = false;

  SiteSettings get settings => _settings;
  bool get saving => _saving;

  SiteSettingsProvider() {
    _listen();
  }

  void _listen() {
    _db.collection('config').doc('site').snapshots().listen((snap) {
      if (snap.exists) {
        _settings = SiteSettings.fromDoc(snap);
        AppLogger.firestoreRead('config/site', 1);
      }
      notifyListeners();
    });
  }

  Future<bool> save(SiteSettings updated) async {
    _saving = true;
    notifyListeners();
    try {
      await _db.collection('config').doc('site').set(updated.toMap());
      AppLogger.firestoreWrite('config/site', 'site');
      _saving = false;
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.apiError('site_settings/save', e.toString());
      _saving = false;
      notifyListeners();
      return false;
    }
  }
}
