import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class BLEScanner {
  StreamSubscription<List<ScanResult>>? _subscription;
  bool _isScanning = false;

  /// Starts scanning for BLE advertisements.
  /// [onAdFound] is called every time a new advertisement is found.
  void startScanning(void Function(String) onAdFound) async {
    if (_isScanning) return; // Avoid starting multiple times
    _isScanning = true;

    await FlutterBluePlus.startScan(
      withServices: [], // Empty to scan everything
      timeout: const Duration(seconds: 30), // Optional timeout
    );

    _subscription = FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        final manufacturerData = result.advertisementData.manufacturerData;
        if (manufacturerData.containsKey(0x1234)) {
          final dataBytes = manufacturerData[0x1234];
          if (dataBytes != null) {
            final advertisedString = String.fromCharCodes(dataBytes);
            onAdFound(advertisedString);
          }
        }
      }
    });
  }

  void stopScanning() async {
    if (!_isScanning) return;
    _isScanning = false;

    await FlutterBluePlus.stopScan();
    await _subscription?.cancel();
    _subscription = null;
  }
}
