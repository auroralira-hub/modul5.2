import 'dart:io';

class NetworkService {
  const NetworkService._();

  static const List<String> _hostsToPing = [
    'supabase.co',
    'google.com',
    '1.1.1.1',
  ];

  static Future<bool> hasConnection() async {
    for (final host in _hostsToPing) {
      try {
        final result = await InternetAddress.lookup(host);
        if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
          return true;
        }
      } on SocketException {
        // try next host
      }
    }
    return false;
  }
}
