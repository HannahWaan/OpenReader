import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';

class SyncService {
  static SupabaseClient? _client;

  static SupabaseClient? get client {
    if (!SupabaseConfig.isConfigured) return null;
    _client ??= Supabase.instance.client;
    return _client;
  }

  static bool get isAvailable => SupabaseConfig.isConfigured;

  static Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  static User? get currentUser => client?.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  static Future<AuthResponse> signUp(String email, String password) async {
    return await client!.auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await client!.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await client?.auth.signOut();
  }

  static Future<void> syncHighlights(List<Map<String, dynamic>> localHighlights) async {
    if (!isLoggedIn || !await isOnline()) return;
    final userId = currentUser!.id;
    for (final h in localHighlights) {
      await client!.from('highlights').upsert({
        ...h,
        'user_id': userId,
      }, onConflict: 'id');
    }
  }

  static Future<void> syncVocabulary(List<Map<String, dynamic>> localWords) async {
    if (!isLoggedIn || !await isOnline()) return;
    final userId = currentUser!.id;
    for (final w in localWords) {
      await client!.from('vocabulary').upsert({
        ...w,
        'user_id': userId,
      }, onConflict: 'id');
    }
  }

  static Future<void> syncBookProgress(Map<String, dynamic> bookData) async {
    if (!isLoggedIn || !await isOnline()) return;
    final userId = currentUser!.id;
    await client!.from('book_progress').upsert({
      ...bookData,
      'user_id': userId,
    }, onConflict: 'book_id,user_id');
  }

  static Future<List<Map<String, dynamic>>> pullHighlights() async {
    if (!isLoggedIn || !await isOnline()) return [];
    final userId = currentUser!.id;
    final res = await client!.from('highlights').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<List<Map<String, dynamic>>> pullVocabulary() async {
    if (!isLoggedIn || !await isOnline()) return [];
    final userId = currentUser!.id;
    final res = await client!.from('vocabulary').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(res);
  }
}
