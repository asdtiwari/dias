import 'dart:io';
import 'package:dias/services/device_status_service.dart';
import 'package:dias/services/encryption_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class SecurityService {
  Future<bool> hasExternalFlagFile() async {
    // Step 1: Handle Permissions
    if (Platform.isAndroid) {
      final storageStatus = await Permission.manageExternalStorage.request();
      if (!storageStatus.isGranted) return false;
    } else if (Platform.isIOS) {
      final photosStatus = await Permission.photos.request();
      final mediaStatus = await Permission.mediaLibrary.request();
      if (!photosStatus.isGranted || !mediaStatus.isGranted) return false;
    }

    // Step 2: Set up paths based on platform
    Directory sysdDir;
    if (Platform.isAndroid) {
      sysdDir = Directory('/storage/emulated/0/Android/media/.sysd');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      sysdDir = Directory('${dir.path}/.sysd');
    }

    final recDir = Directory('${sysdDir.path}/.rec');
    final regDir = Directory('${recDir.path}/.reg');
    final flagFile = File('${regDir.path}/.reg');

    // Step 3: Ensure directory structure exists
    try {
      if (!await regDir.exists()) {
        await regDir.create(recursive: true);
      }
    } catch (e) {
      return false;
    }

    // Step 4: Get device ID
    final deviceId = (await DeviceStatusService().getDeviceId()) ?? "";
    // Step 5: If file exists, verify deviceId and timestamps
    if (await flagFile.exists()) {
      try {
        final content = await flagFile.readAsString();
        final decrypted = EncryptionService().decrypt(content);
        final parts = decrypted.split('|');

        if (parts.length == 2) {
          final fileDeviceId = parts[0];
          final timestampStr = parts[1];
          final parsedTime = DateTime.tryParse(timestampStr);

          if (fileDeviceId != deviceId || parsedTime == null) {
            return false; // Device ID mismatch or timestamp is invalid
          }

          // Get last modified times
          final sysdTime = await sysdDir.stat().then((s) => s.modified);
          final recTime = await recDir.stat().then((s) => s.modified);
          final regTime = await regDir.stat().then((s) => s.modified);
          final fileTime = await flagFile.stat().then((s) => s.modified);

          // Helper to truncate DateTime to only hour and minute
          DateTime truncateToHourMinute(DateTime dt) {
            return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute);
          }

          // Truncate all times
          final sysdTrunc = truncateToHourMinute(sysdTime);
          final recTrunc = truncateToHourMinute(recTime);
          final regTrunc = truncateToHourMinute(regTime);
          final fileTrunc = truncateToHourMinute(fileTime);
          final parsedTrunc = truncateToHourMinute(parsedTime);

          // Compare only truncated times
          final sameTime =
              sysdTrunc == recTrunc &&
              recTrunc == regTrunc &&
              regTrunc == fileTrunc &&
              fileTrunc == parsedTrunc;

          return sameTime;
        }

        return false;
      } catch (e) {
        return false;
      }
    }

    // Step 6: If file doesn't exist, create with current time
    try {
      final now = DateTime.now();
      final nowIso = now.toIso8601String();
      final dataToEncrypt = '$deviceId|$nowIso';
      final encrypted = EncryptionService().encrypt(dataToEncrypt);
      await flagFile.writeAsString(encrypted);

      return true;
    } catch (e) {
      return false;
    }
  }

  // 2) check clone or legit
  Future<bool> isOfficialApp() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final bool isReal =
        packageInfo.appName == AppConfig.expectedAppName &&
        packageInfo.version == AppConfig.expectedVersion &&
        packageInfo.buildNumber == AppConfig.expectedBuildNumber &&
        packageInfo.packageName ==
            (Platform.isAndroid
                ? AppConfig.expectedAndroidPackage
                : AppConfig.expectedIOSBundleId);

    return isReal;
  }

  /// Runs _all_ checks; returns true only if every layer passes.
  Future<bool> isEnvironmentTrusted() async {
    if (!await hasExternalFlagFile()) return false;
    if (!await isOfficialApp()) return false;
    return true;
  }
}

// Easiest Way: Use rename Package
// download package: dart pub add rename
// package: dart run rename setBundleId --value com.new.package.name
// app name: dart run rename setAppName --value "DIAS"
// version and build number can change from pubspec.yaml where 1.0.0 represent version and +1 build number
// supportive class for isOfficialApp()
class AppConfig {
  static const String expectedAppName = 'DIAS';
  static const String expectedVersion = '1.0.0';
  static const String expectedBuildNumber = '1';
  static const String expectedAndroidPackage = 'com.application.dias';
  static const String expectedIOSBundleId = 'com.application.dias';
}
