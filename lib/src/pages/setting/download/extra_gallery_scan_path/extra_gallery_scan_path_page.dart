import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/setting/download_setting.dart';
import 'package:skana_ehentai/src/utils/string_uril.dart';
import 'package:skana_ehentai/src/widget/eh_alert_dialog.dart';

import '../../../../service/log.dart';
import '../../../../utils/permission_util.dart';
import '../../../../utils/toast_util.dart';

class ExtraGalleryScanPathPage extends StatelessWidget {
  const ExtraGalleryScanPathPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('extraGalleryScanPath'.tr),
        actions: [
          IconButton(onPressed: _handleAddPath, icon: const Icon(Icons.add)),
        ],
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.only(top: 16),
          children: downloadSetting.extraGalleryScanPath
              .map(
                (path) => ListTile(
                    title: Text(path), onTap: () => _handleDelete(path)),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _handleAddPath() async {
    await requestStoragePermission();

    String? newPath;
    try {
      newPath = await FilePicker.platform.getDirectoryPath();
    } on Exception catch (e) {
      log.error('Pick extra path failed', e);
    }
    if (isEmptyOrNull(newPath)) {
      return;
    }

    /// check permission
    if (!checkPermissionForPath(newPath!)) {
      toast('invalidPath'.tr, isShort: false);
      return;
    }

    downloadSetting.addExtraGalleryScanPath(newPath);
  }

  Future<void> _handleDelete(String path) async {
    bool? result = await Get.dialog(EHDialog(title: 'delete'.tr + '?'));

    if (result == true) {
      downloadSetting.removeExtraGalleryScanPath(path);
    }
  }
}
