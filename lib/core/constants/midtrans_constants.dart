/// Konfigurasi API Midtrans untuk Toko Buku Budi.
///
/// Anda bisa menaruh Server Key dan Client Key di sini untuk Sandbox / Production.
/// CATATAN KEAMANAN:
/// Untuk production, disarankan menyimpan Server Key di Supabase Edge Function Secrets
/// (Environment Variable: MIDTRANS_SERVER_KEY).
/// Namun untuk testing cepat (Sandbox), Anda bisa langsung isi [serverKey] & [clientKey] di bawah ini.
class MidtransConstants {
  /// Ubah ke `true` jika ingin menggunakan mode Production
  static const bool isProduction = false;

  /// Masukkan Client Key Midtrans Anda di sini:
  /// Contoh Sandbox: 'SB-Mid-client-xxxxxxxxxxxxxxxx'
  /// Contoh Production: 'Mid-client-xxxxxxxxxxxxxxxx'
  static const String clientKey = 'Mid-client-4ReguL5VrYnuOr7m';

  /// Masukkan Server Key Midtrans Anda di sini:
  /// Contoh Sandbox: 'SB-Mid-server-xxxxxxxxxxxxxxxx'
  /// Contoh Production: 'Mid-server-xxxxxxxxxxxxxxxx'
  /// (Jika Anda sudah set di Supabase Secret, biarkan kosong atau isi sama)
  static const String serverKey = 'SB-Mid-server-Aw4UujYEAWTnKj6nO8IVUA.V';

  /// Endpoint Edge Function Supabase untuk membuat token Snap
  static const String edgeFunctionUrl =
      'https://uemrnotnjwannfshzlph.supabase.co/functions/v1/create-midtrans-transaction';

  /// Base URL Snap Redirection
  static String get snapRedirectionBaseUrl => isProduction
      ? 'https://app.midtrans.com/snap/v4/redirection/'
      : 'https://app.sandbox.midtrans.com/snap/v4/redirection/';
}
