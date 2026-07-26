import 'package:encrypt/encrypt.dart';

class AESService {
  static const String _secretKey = "12345678901234567890123456789012";

  static const String _ivString = "1234567890123456";

  late final Encrypter _encrypter;
  late final Key _key;
  late final IV _iv;

  AESService() {
    _key = Key.fromUtf8(_secretKey);

    _iv = IV.fromUtf8(_ivString);

    _encrypter = Encrypter(
      AES(
        _key,
        mode: AESMode.cbc,
      ),
    );
  }

  String encrypt(String value) {
    if (value.isEmpty) return "";

    return _encrypter
        .encrypt(
          value,
          iv: _iv,
        )
        .base64;
  }

  String decrypt(String value) {
    if (value.isEmpty) return "";

    try {
      return _encrypter.decrypt64(
        value,
        iv: _iv,
      );
    } catch (_) {
      // If value is already plain text (older messages),
      // return it instead of crashing.
      return value;
    }
  }
}
