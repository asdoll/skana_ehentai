import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

import '../service/log.dart';
import 'platform_util.dart';

Future<void> requestStoragePermission() async {
  // permission_handler has no OHOS implementation, and none of these permissions
  // exist there: the app writes inside its own sandbox and hands anything going
  // to the gallery over to photoAccessHelper's own confirmation sheet.
  if (!GetPlatform.isMacOS && !GetPlatform.isLinux && !isOhos) {
    try {
      await Permission.manageExternalStorage.request().isGranted;
      log.info(await Permission.manageExternalStorage.status);
    } on Exception catch (e) {
      log.error('Request manageExternalStorage permission failed!', e);
    }

    try {
      await Permission.storage.request().isGranted;
      log.info(await Permission.storage.status);
    } on Exception catch (e) {
      log.error('Request storage permission failed!', e);
    }
  }
}

Future<void> requestAlbumPermission() async {
  if (isOhos) {
    return;
  }

  bool statuses;
  if (Platform.isAndroid) {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.androidInfo;
    final sdkInt = deviceInfo.version.sdkInt;
    statuses =
        sdkInt < 29 ? await Permission.storage.request().isGranted : true;
  } else {
    statuses = await Permission.photosAddOnly.request().isGranted;
  }

  log.info('requestPermission result: $statuses');
}

bool checkPermissionForPath(String path) {
  try {
    File file = File(join(path, 'JHenTaiTest'));
    file.createSync(recursive: true);
    file.deleteSync();
  } on FileSystemException catch (e) {
    log.error('${'invalidPath'.tr}:$path', e);
    log.uploadError(e, extraInfos: {'path': path});
    return false;
  }

  return true;
}
