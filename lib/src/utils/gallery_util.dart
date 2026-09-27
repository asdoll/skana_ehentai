import 'dart:async';
import 'dart:io';

import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:saver_gallery/saver_gallery.dart';

import '../service/log.dart';

/// Copies [filePath] into the system photo album, under the display name
/// [fileName].
///
/// `saver_gallery` has no HarmonyOS implementation at all, so on OHOS the save is
/// routed to `image_gallery_saver_plus`, which does have one. Every other
/// platform keeps going through `saver_gallery`.
Future<bool> saveFileToAlbum(String filePath, String fileName) async {
  if (Platform.isOhos) {
    return _saveFileToAlbumOnOhos(filePath, fileName);
  }

  SaveResult saveResult = await SaverGallery.saveFile(
    file: filePath,
    name: fileName,
    androidRelativePath: "Pictures/SkanaEH",
    androidExistNotSave: false,
  );

  log.info('Save file to album: $saveResult');

  return saveResult.isSuccess;
}

/// Characters `photoAccessHelper.showAssetsCreationDialog` rejects in a
/// `PhotoCreationConfig.title`.
const List<String> _invalidTitleChars = [
  '\\',
  '/',
  ':',
  '*',
  '?',
  '"',
  "'",
  '`',
  '<',
  '>',
  '|',
  '{',
  '}',
  '[',
  ']',
];

/// Strips everything the OHOS media library would choke on from [fileName].
///
/// The native side splits the title on '.' and appends the source file's own
/// extension, so only the stem is kept here. Getting this wrong does not raise:
/// `showAssetsCreationDialog` simply never opens, the save silently does nothing,
/// and the method channel still reports success.
String _albumTitle(String fileName) {
  String title = fileName.split('.').first;
  for (String char in _invalidTitleChars) {
    title = title.replaceAll(char, '_');
  }
  title = title.trim();

  return title.isEmpty
      ? DateTime.now().millisecondsSinceEpoch.toString()
      : title;
}

/// Tail of the save queue; see [_saveFileToAlbumOnOhos].
Future<void> _saveChain = Future.value();

/// Serialises album saves.
///
/// The OHOS implementation refuses a second overlapping save with a `Busy`
/// PlatformException instead of queueing it, and the reader can fire several
/// saves in a row, so calls are chained here.
Future<bool> _saveFileToAlbumOnOhos(String filePath, String fileName) async {
  Future<void> previous = _saveChain;
  Completer<void> gate = Completer<void>();
  _saveChain = gate.future;

  await previous;
  try {
    dynamic result = await ImageGallerySaverPlus.saveFile(
      filePath,
      name: _albumTitle(fileName),
    );

    // The channel signals failure through the returned map, not by throwing, so
    // the result has to be inspected rather than trusted.
    bool success = result is Map && result['isSuccess'] == true;
    if (success) {
      log.info('Save file to album: $result');
    } else {
      log.error('Save file to album failed: $result');
    }

    return success;
  } on Exception catch (e, stackTrace) {
    log.error('Save file to album failed', e, stackTrace);
    return false;
  } finally {
    gate.complete();
  }
}
