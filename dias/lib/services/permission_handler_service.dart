import 'dart:io';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerService {
  /// Checks if Bluetooth is supported on the device and enabled.
  Future<bool> checkBluetoothEnabled() async {
    // Check if Bluetooth is supported using isSupported (deprecated isAvailable is replaced by isSupported).
    if (!await FlutterBluePlus.isSupported) {
      log("Bluetooth is not supported on this device.");
      return false;
    }

    // Get the current Bluetooth adapter state.
    BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
    if (state == BluetoothAdapterState.on) {
      return true;
    } else {
      log("Bluetooth is currently off.");
      return false;
    }
  }

  /// Attempts to enable Bluetooth programmatically on Android devices.
  /// On iOS, prompts the user to enable Bluetooth via device settings.
  Future<void> enableBluetooth() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (e) {
        log("Error enabling Bluetooth: $e");
      }
    } else if (Platform.isIOS) {
      log("Please enable Bluetooth in the device settings.");
      // Optionally, you can guide the user to open settings.
    }
  }
  
  /// Opens the app settings so that the user can manually enable Bluetooth.
  Future<bool> openBluetoothSettings() async {
    return await openAppSettings();
  }
}
