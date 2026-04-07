import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

String convertToSHA256(String input) {
  Uint8List bytes;
  Digest digest;

  bytes = utf8.encode(input);
  digest = sha256.convert(bytes);

  return digest.toString();
}
