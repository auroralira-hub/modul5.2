import 'dart:convert';
import 'dart:developer' as developer;

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
    final stopwatch = Stopwatch()..start();
    try {
      print('🔄 Trying to fetch affirmation from API...');
      final response = await _dio.get('/');
      print('📡 Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final affirmation = _extractAffirmation(response.data);
        if (affirmation != null && affirmation.isNotEmpty) {
          print('✅ Affirmation received from API: $affirmation');
          developer.log(
            'Affirmation berhasil dalam ${stopwatch.elapsedMilliseconds}ms',
            name: 'AffirmationsService',
          );
          return affirmation;
        }
      }
    } on DioException catch (e) {
      print('⚠️ API failed via Dio, using offline affirmations: ${e.message}');
    } catch (e) {
      print('⚠️ API failed, using offline affirmations: $e');
    } finally {
      if (stopwatch.isRunning) stopwatch.stop();
      developer.log(
        'fetchAffirmation selesai dalam ${stopwatch.elapsedMilliseconds}ms',
        name: 'AffirmationsService',
      );
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
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.get('/');
      if (response.statusCode == 200) {
        final affirmation = _extractAffirmation(response.data);
        if (affirmation != null && affirmation.isNotEmpty) {
          stopwatch.stop();
          developer.log(
            'fetchAffirmationWithCallback sukses dalam ${stopwatch.elapsedMilliseconds}ms',
            name: 'AffirmationsService',
          );
          onSuccess(affirmation);
          return;
        }
      }
      onError?.call('Affirmation tidak tersedia (gagal memuat dari API).');
    } on DioException catch (e) {
      onError?.call('Gagal memuat affirmation: ${e.message}');
    } catch (e) {
      onError?.call('Terjadi kesalahan: $e');
    } finally {
      if (stopwatch.isRunning) stopwatch.stop();
      developer.log(
        'fetchAffirmationWithCallback selesai dalam ${stopwatch.elapsedMilliseconds}ms',
        name: 'AffirmationsService',
      );
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
