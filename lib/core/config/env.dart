abstract final class Env {
  static const supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  static const supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY', defaultValue: '');

  static bool get supabaseEnabled =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
