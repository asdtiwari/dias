class EncryptionService {
  // For demonstration: a simple XOR cipher with a fixed key.
  final int _key = 59;

  String encrypt(String plainText) {
    return String.fromCharCodes(plainText.codeUnits.map((c) => c ^ _key));
  }

  String decrypt(String cipherText) {
    return String.fromCharCodes(cipherText.codeUnits.map((c) => c ^ _key));
  }
}
