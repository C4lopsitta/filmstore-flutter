import 'package:flutter/services.dart';

class KeychainHelper {
  static const platform = MethodChannel('cc.atomtech.filmstore.filmstore/keychain');

  // Method to request certificate from Android Keychain
  static Future<String?> getCertificateFromKeychain() async {
    try {
      final String? certAlias = await platform.invokeMethod('getCertificate');
      return certAlias;
    } on PlatformException catch (e) {
      print("Failed to get certificate: '${e.message}'.");
      return null;
    }
  }
}
