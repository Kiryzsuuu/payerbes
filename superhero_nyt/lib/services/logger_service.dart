import 'package:flutter/foundation.dart';

class AppLogger {
  static void _print(String type, String emoji, String message) {
    final time = DateTime.now();
    final ts =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
    debugPrint('');
    debugPrint('┌─────────────────────────────────────────────');
    debugPrint('│ $emoji  [$ts] $type');
    debugPrint('│ $message');
    debugPrint('└─────────────────────────────────────────────');
  }

  // ── AUTH ─────────────────────────────────────────────────
  static void login(String email, String method) =>
      _print('AUTH - LOGIN', '🔐', 'User: $email | Metode: $method');

  static void logout(String email) =>
      _print('AUTH - LOGOUT', '🚪', 'User: $email keluar');

  static void register(String email) =>
      _print('AUTH - REGISTER', '📝', 'Akun baru: $email');

  static void resetPassword(String email) =>
      _print('AUTH - RESET PASSWORD', '🔑', 'Reset dikirim ke: $email');

  // ── CRUD HERO ─────────────────────────────────────────────
  static void heroAdded(String name, String by) =>
      _print('CRUD - CREATE', '➕', 'Hero ditambah: "$name" | Oleh: $by');

  static void heroUpdated(String name, String by) =>
      _print('CRUD - UPDATE', '✏️ ', 'Hero diupdate: "$name" | Oleh: $by');

  static void heroDeleted(String name, String by) =>
      _print('CRUD - DELETE', '🗑️ ', 'Hero dihapus: "$name" | Oleh: $by');

  // ── FAVORIT ───────────────────────────────────────────────
  static void favoriteAdded(String heroName, String uid) =>
      _print('FAVORIT - SAVED', '🔖', 'Disimpan: "$heroName" | UID: $uid');

  static void favoriteRemoved(String heroName, String uid) =>
      _print('FAVORIT - REMOVED', '🗂️ ', 'Dihapus dari saved: "$heroName" | UID: $uid');

  // ── SEARCH ────────────────────────────────────────────────
  static void search(String query, int results) =>
      _print('SEARCH', '🔍', 'Query: "$query" | Hasil: $results hero');

  // ── NAVIGATION ────────────────────────────────────────────
  static void pageView(String page) =>
      _print('NAVIGATION', '📄', 'Halaman dibuka: $page');

  // ── FIRESTORE ─────────────────────────────────────────────
  static void firestoreRead(String collection, int count) =>
      _print('FIRESTORE - READ', '📖',
          'Collection: $collection | $count dokumen dibaca');

  static void firestoreWrite(String collection, String docId) =>
      _print('FIRESTORE - WRITE', '💾',
          'Collection: $collection | Doc: $docId');

  static void firestoreDelete(String collection, String docId) =>
      _print('FIRESTORE - DELETE', '🗑️ ',
          'Collection: $collection | Doc: $docId');

  // ── API ───────────────────────────────────────────────────
  static void apiCall(String endpoint, int status) =>
      _print('API - CALL', '🌐', 'Endpoint: $endpoint | Status: $status');

  static void apiError(String endpoint, String error) =>
      _print('API - ERROR', '❌', 'Endpoint: $endpoint | Error: $error');

  // ── INFO UMUM ─────────────────────────────────────────────
  static void info(String message) =>
      _print('INFO', 'ℹ️ ', message);
}
