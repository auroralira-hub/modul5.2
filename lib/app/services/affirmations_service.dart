import 'dart:convert';

import 'package:dio/dio.dart';

import 'network_service.dart';

typedef AffirmationCallback = void Function(String message);

class AffirmationsService {
  static const String _apiUrl = 'https://www.affirmations.dev/';
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _apiUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  static Future<String> fetchAffirmation() async {
    final hasNetwork = await NetworkService.hasConnection();
    if (!hasNetwork) {
      return 'Affirmation tidak tersedia saat offline.';
    }
    try {
      print('🔄 Trying to fetch affirmation from API...');
      final response = await _dio.get('/');
      print('📡 Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final affirmation = _extractAffirmation(response.data);
        if (affirmation != null && affirmation.isNotEmpty) {
          print('✅ Affirmation received from API: $affirmation');
          return affirmation;
        }
      }
    } on DioException catch (e) {
      print('⚠️ API failed via Dio, using offline affirmations: ${e.message}');
    } catch (e) {
      print('⚠️ API failed, using offline affirmations: $e');
    }

    return 'Affirmation tidak tersedia (gagal memuat dari API).';
  }

  static Future<void> fetchAffirmationWithCallback({
    required AffirmationCallback onSuccess,
    AffirmationCallback? onError,
  }) async {
    final hasNetwork = await NetworkService.hasConnection();
    if (!hasNetwork) {
      onError?.call('Affirmation tidak tersedia saat offline.');
      return;
    }
    try {
      final response = await _dio.get('/');
      if (response.statusCode == 200) {
        final affirmation = _extractAffirmation(response.data);
        if (affirmation != null && affirmation.isNotEmpty) {
          onSuccess(affirmation);
          return;
        }
      }
      onError?.call('Affirmation tidak tersedia (gagal memuat dari API).');
    } on DioException catch (e) {
      onError?.call('Gagal memuat affirmation: ${e.message}');
    } catch (e) {
      onError?.call('Terjadi kesalahan: $e');
    }
  }

  static String? _extractAffirmation(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['affirmation'] as String?;
    }
    if (data is String) {
      final map = jsonDecode(data) as Map<String, dynamic>;
      return map['affirmation'] as String?;
    }
    return null;
  }
}
