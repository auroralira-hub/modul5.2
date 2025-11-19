import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../data/models.dart';

class SupabaseProfileService {
  const SupabaseProfileService();

  supa.SupabaseClient get _client => supa.Supabase.instance.client;

  Future<String> registerUser(User user) async {
    try {
      final authResponse = await _client.auth.signUp(
        email: user.email,
        password: user.password,
        data: {'username': user.username, 'name': user.name},
      );

      final authUser = authResponse.user;
      if (authUser == null) {
        throw SupabaseProfileServiceException(
          'Gagal membuat akun, user tidak tersedia.',
        );
      }

      await _client.from('profiles').insert({
        'user_id': authUser.id,
        'username': user.username,
        'name': user.name,
        'age': user.age,
        'major': user.major,
        'email': user.email,
        'avatar': '',
        'timestampz': DateTime.now().toIso8601String(),
      });
      return authUser.id;
    } on supa.AuthException catch (e) {
      throw SupabaseProfileServiceException(e.message);
    } on supa.PostgrestException catch (e) {
      if (_isDuplicateError(e)) {
        throw UsernameAlreadyExistsException();
      }
      throw SupabaseProfileServiceException(e.message);
    } catch (e) {
      throw SupabaseProfileServiceException(e.toString());
    }
  }

  Future<User> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      final dynamic profileData = await _client
          .from('profiles')
          .select('user_id, username, name, age, major, email')
          .eq('username', username)
          .maybeSingle();

      final Map<String, dynamic>? profile = profileData == null
          ? null
          : Map<String, dynamic>.from(profileData as Map);

      if (profile == null) {
        throw SupabaseProfileServiceException(
          'Username tidak ditemukan di Supabase.',
        );
      }

      final email = (profile['email'] as String?)?.trim();
      if (email == null || email.isEmpty) {
        throw SupabaseProfileServiceException(
          'Akun ini tidak memiliki email terdaftar.',
        );
      }

      final authResponse = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final authUser = authResponse.user;
      if (authUser == null) {
        throw SupabaseProfileServiceException(
          'Login Supabase gagal, user tidak ditemukan.',
        );
      }

      return User(
        supabaseUserId: authUser.id,
        username: (profile['username'] as String?) ?? username,
        name: (profile['name'] as String?) ?? '',
        age: _toInt(profile['age']),
        major: (profile['major'] as String?) ?? '',
        email: email,
        password: password,
      );
    } on supa.AuthException catch (e) {
      throw SupabaseProfileServiceException(e.message);
    } on supa.PostgrestException catch (e) {
      throw SupabaseProfileServiceException(e.message);
    } catch (e) {
      throw SupabaseProfileServiceException(e.toString());
    }
  }

  Future<String?> fetchAvatarUrl(String userId) async {
    try {
      final dynamic response = await _client
          .from('profiles')
          .select('avatar')
          .eq('user_id', userId)
          .maybeSingle();
      final map = response == null
          ? null
          : Map<String, dynamic>.from(response as Map);
      final avatar = map?['avatar'] as String?;
      if (avatar == null || avatar.isEmpty) return null;
      return avatar;
    } on supa.PostgrestException catch (e) {
      throw SupabaseProfileServiceException(e.message);
    } catch (e) {
      throw SupabaseProfileServiceException(e.toString());
    }
  }

  Future<String> uploadProfilePhoto({
    required String userId,
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    final path = 'users/$userId/$fileName';
    try {
      await _client.storage
          .from('foto_profil')
          .uploadBinary(
            path,
            bytes,
            fileOptions: supa.FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );
      final publicUrl = _client.storage.from('foto_profil').getPublicUrl(path);
      await _client
          .from('profiles')
          .update({'avatar': publicUrl})
          .eq('user_id', userId);
      return publicUrl;
    } on supa.StorageException catch (e) {
      throw SupabaseProfileServiceException(e.message);
    } on supa.PostgrestException catch (e) {
      throw SupabaseProfileServiceException(e.message);
    } catch (e) {
      throw SupabaseProfileServiceException(e.toString());
    }
  }

  bool _isDuplicateError(supa.PostgrestException exception) {
    final message = exception.message.toLowerCase();
    return exception.code == '23505' || message.contains('duplicate key');
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class SupabaseEntriesService {
  const SupabaseEntriesService();

  supa.SupabaseClient get _client => supa.Supabase.instance.client;

  Future<void> saveEntry({
    required String userId,
    required JournalEntry entry,
  }) async {
    try {
      await _client.from('entries').insert({
        'user_id': userId,
        'username': entry.username,
        'mood': entry.mood,
        'stress_level': entry.stressLevel,
        'note': entry.note,
        'timestamp': entry.timestamp.toIso8601String(),
      });
    } on supa.PostgrestException catch (e) {
      throw SupabaseEntriesServiceException(e.message);
    } catch (e) {
      throw SupabaseEntriesServiceException(e.toString());
    }
  }

  Future<List<JournalEntry>> fetchEntries(String username) async {
    try {
      final data = await _client
          .from('entries')
          .select('username, mood, stress_level, note, timestamp')
          .eq('username', username)
          .order('timestamp');
      final list = (data as List<dynamic>)
          .map(
            (row) => JournalEntry.fromJson({
              'username': row['username'],
              'mood': row['mood'],
              'stressLevel': row['stress_level'],
              'note': row['note'],
              'timestamp': row['timestamp'],
            }),
          )
          .toList();
      return list;
    } on supa.PostgrestException catch (e) {
      throw SupabaseEntriesServiceException(e.message);
    } catch (e) {
      throw SupabaseEntriesServiceException(e.toString());
    }
  }
}

class SupabaseProfileServiceException implements Exception {
  final String message;
  SupabaseProfileServiceException(this.message);

  @override
  String toString() => message;
}

class SupabaseEntriesServiceException implements Exception {
  final String message;
  SupabaseEntriesServiceException(this.message);

  @override
  String toString() => message;
}

class UsernameAlreadyExistsException implements Exception {
  final String message;
  UsernameAlreadyExistsException([this.message = 'Username sudah terdaftar']);

  @override
  String toString() => message;
}
