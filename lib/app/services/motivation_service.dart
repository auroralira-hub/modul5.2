import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'network_service.dart';

class MotivationService {
  static const String _quotesEndpoint = 'https://type.fit/api/quotes';

  static Future<String> fetchRandomTip() async {
    final hasNetwork = await NetworkService.hasConnection();
    if (!hasNetwork) {
      return 'Tips motivasi tidak tersedia saat offline.';
    }

    final stopwatch = Stopwatch()..start();
    try {
      final response = await http
          .get(Uri.parse(_quotesEndpoint))
          .timeout(const Duration(seconds: 6));
      stopwatch.stop();
      developer.log(
        'MotivationService.fetchRandomTip selesai dalam ${stopwatch.elapsedMilliseconds}ms',
        name: 'MotivationService',
      );

      if (response.statusCode == 200) {
        final List<dynamic> parsed = jsonDecode(response.body) as List<dynamic>;
        if (parsed.isEmpty) return 'Tidak ada tips motivasi dari server.';
        final randomQuote = parsed[Random().nextInt(parsed.length)]
            as Map<String, dynamic>;
        final text = (randomQuote['text'] as String?)?.trim();
        final author = (randomQuote['author'] as String?)?.trim();
        if (text == null || text.isEmpty) {
          return 'Tidak ada tips motivasi dari server.';
        }
        return author != null && author.isNotEmpty
            ? '"$text"\n— $author'
            : '"$text"';
      }
      return 'Server mengembalikan status ${response.statusCode}.';
    } catch (e, stack) {
      stopwatch.stop();
      developer.log(
        'Gagal mengambil tips motivasi dalam ${stopwatch.elapsedMilliseconds}ms: $e',
        name: 'MotivationService',
        error: e,
        stackTrace: stack,
      );
      if (kDebugMode) {
        print('MotivationService error: $e');
      }
      return 'Tips motivasi gagal dimuat ($e).';
    }
  }
}
