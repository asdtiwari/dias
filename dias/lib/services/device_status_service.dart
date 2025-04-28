import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_udid/flutter_udid.dart';

class DeviceStatusService {
  /// Checks if the device has an active internet connection.
  Future<bool> isInternetAvailable() async {
    // Retrieve connectivity result. Sometimes it might return a List<ConnectivityResult>.
    final dynamic result = await Connectivity().checkConnectivity();
    ConnectivityResult connectivityResult;
    if (result is ConnectivityResult) {
      connectivityResult = result;
    } else if (result is List<ConnectivityResult> && result.isNotEmpty) {
      connectivityResult = result.first;
    } else {
      connectivityResult = ConnectivityResult.none;
    }
    return connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile;
  }

  // check Bluetooth Status
  Future<bool> isBluetoothOn() async {
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  // get unique id of application for a device
  Future<String?> getDeviceId() async {
    String udid = await FlutterUdid.udid;
    return udid;
  }
}
