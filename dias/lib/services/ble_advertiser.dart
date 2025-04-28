import 'dart:typed_data';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

class BLEAdvertiser {
  final FlutterBlePeripheral _blePeripheral = FlutterBlePeripheral();

  Future<void> startAdvertising(String data) async {
    final AdvertiseData advertiseData = AdvertiseData(
      includeDeviceName: true,
      manufacturerId: 0x1234,
      manufacturerData: Uint8List.fromList(data.codeUnits),
    );
    await _blePeripheral.start(advertiseData: advertiseData);
  }

  Future<void> stopAdvertising() async {
    await _blePeripheral.stop();
  }
}
