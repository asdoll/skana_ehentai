import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../service/log.dart';
import '../service/path_service.dart';
import 'platform_util.dart';
import 'toast_util.dart';

/// Asks the user for a directory, and only ever answers with a path that
/// `dart:io` can open.
///
/// HarmonyOS is why this exists. Its picker answers with a document URI
/// (`file://docs/storage/Users/currentUser/Download`), and the access it grants
/// is tied to that URI rather than to the path behind it - while every caller
/// here goes on to download into the directory, scan it, or write a config file
/// into it with `dart:io`. On top of that an OHOS app may only write inside its
/// own sandbox anyway. So on OHOS a document URI is discarded and the app's own
/// directory is offered instead, with a message saying why; a plain path (should
/// a device hand one back) is still accepted as it is.
Future<String?> pickUsableDirectoryPath() async {
  String? picked;
  try {
    picked = await FilePicker.platform.getDirectoryPath();
  } on Exception catch (e) {
    log.error('Pick directory failed', e);
  }

  if (picked == null || !picked.startsWith('file://')) {
    return picked;
  }

  if (!isOhos) {
    return picked;
  }

  String appDirectory = pathService.getVisibleDir().path;
  toast('${'ohosAppDirectoryOnly'.tr}\n$appDirectory', isShort: false);
  return appDirectory;
}
