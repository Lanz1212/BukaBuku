import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  // ─── User & Session Getters ────────────────────────────────────────────────
  static bool get isLoggedIn => _client.auth.currentUser != null;

  static User? get currentUser => _client.auth.currentUser;

  // ─── Daftar Akun Baru ──────────────────────────────────────────────────────
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String addresses,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'password': password,
        'full_name': fullName.trim(),
        'phone': phone.trim(),
        'addresses': addresses.trim(),
      },
    );

    // Safety fallback: if user session exists immediately, ensure profile row exists
    final user = response.user;
    if (user != null && response.session != null) {
      try {
        await _client.from('profiles').upsert({
          'id': user.id,
          'email': user.email ?? email.trim(),
          'password': password,
          'full_name': fullName.trim(),
          'phone': phone.trim(),
          'addresses': addresses.trim(),
          'role': 'user',
          'is_active': true,
        });
      } catch (_) {
        // Trigger on auth.users already handles insertion
      }
    }

    return response;
  }

  // ─── Masuk Akun ────────────────────────────────────────────────────────────
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    // Update password in profiles table on successful login as well
    final user = response.user;
    if (user != null) {
      try {
        await _client.from('profiles').update({
          'password': password,
        }).eq('id', user.id);
      } catch (_) {}
    }

    return response;
  }

  // ─── Keluar Akun ───────────────────────────────────────────────────────────
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ─── Ambil Role User Saat Ini ──────────────────────────────────────────────
  // Mengembalikan 'user', 'admin', atau default 'user'
  static Future<String> getCurrentUserRole() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 'user';

    try {
      final response = await _client
          .from('profiles')
          .select('role, is_active')
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        final isActive = response['is_active'] as bool? ?? true;
        if (!isActive) {
          await signOut();
          throw const AuthException('Akun Anda telah dinonaktifkan. Silakan hubungi admin.');
        }
        return (response['role'] as String?)?.toLowerCase() ?? 'user';
      }

      // Profile record doesn't exist yet, create default
      final user = _client.auth.currentUser;
      final meta = user?.userMetadata ?? {};
      await _client.from('profiles').upsert({
        'id': userId,
        'email': user?.email,
        'full_name': meta['full_name'] ?? '',
        'phone': meta['phone'] ?? '',
        'addresses': meta['addresses'] ?? '',
        'password': meta['password'] ?? '',
        'role': 'user',
        'is_active': true,
      });
      return 'user';
    } catch (e) {
      if (e is AuthException) rethrow;
      return 'user';
    }
  }

  // ─── Ambil Profil Lengkap ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      return await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
    } catch (_) {
      return null;
    }
  }
}

