class SupabaseConfig {
  // *** THAY BẰNG CREDENTIALS CỦA BẠN ***
  // Lấy từ: Supabase Dashboard → Settings → API
  static const String url = 'https://ngeokjanljxsdeesmsrw.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5nZW9ramFubGp4c2RlZXNtc3J3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzNDEzMTYsImV4cCI6MjA4NzkxNzMxNn0.Z5Nh4P3T7ZPeSbnhZ2KX9D_wmu_z0Iu3W6GkoRy1kzQ';

  // Để bảo mật hơn khi build, dùng --dart-define:
  // static String get url => const String.fromEnvironment('SUPABASE_URL');
  // static String get anonKey => const String.fromEnvironment('SUPABASE_ANON_KEY');
}
