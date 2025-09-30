import 'dart:convert';

class JwtUtils {
  /// Returns true if token is expired or invalid
  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = _decodeBase64(parts[1]);
      final Map<String, dynamic> map = json.decode(payload);
      final exp = map['exp'];
      if (exp == null) return true;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return expiry.isBefore(DateTime.now());
    } catch (_) {
      return true;
    }
  }

  /// Decode payload to Map (not verifying signature)
  static Map<String, dynamic> decodePayload(String token) {
    final parts = token.split('.');
    final payload = _decodeBase64(parts[1]);
    return json.decode(payload) as Map<String, dynamic>;
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Invalid base64url string!');
    }
    return utf8.decode(base64Url.decode(output));
  }
}
