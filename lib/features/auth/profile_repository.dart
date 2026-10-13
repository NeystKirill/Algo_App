import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    return await _client.from('profiles').select().eq('id', userId).maybeSingle();
  }

  Future<void> upsertProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    await _client.from('profiles').upsert({
      'id': userId,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    });
  }
}
