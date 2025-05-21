import 'dart:io' as io;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/string_extension.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/service/local_gallery_service.dart';
import 'package:skana_ehentai/src/setting/download_setting.dart';
import 'package:skana_ehentai/src/setting/user_setting.dart';
import 'package:skana_ehentai/src/utils/file_util.dart';
import 'package:skana_ehentai/src/utils/toast_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/eh_wheel_speed_controller.dart';
import 'package:skana_ehentai/src/widget/icons.dart';
import 'package:skana_ehentai/src/widget/loading_state_indicator.dart';
import 'package:path/path.dart';

import '../../../routes/routes.dart';
import '../../../service/archive_download_service.dart';
import '../../../service/gallery_download_service.dart';
import '../../../service/log.dart';
import '../../../utils/permission_util.dart';
import '../../../utils/route_util.dart';
import '../../../widget/eh_download_dialog.dart';

class SettingDownloadPage extends StatefulWidget {
  const SettingDownloadPage({super.key});

  @override
  State<SettingDownloadPage> createState() => _SettingDownloadPageState();
}

class _SettingDownloadPageState extends State<SettingDownloadPage> {
  LoadingState changeDownloadPathState = LoadingState.idle;

  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'downloadSetting'.tr),
      body: Obx(
        () => EHWheelSpeedController(
          controller: scrollController,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.only(top: 16),
            children: [
              _buildDownloadPath(),
              if (!GetPlatform.isIOS) _buildResetDownloadPath(),
              _buildExtraGalleryScanPath(),
              if (GetPlatform.isDesktop) _buildSingleImageSavePath(),
              _buildDownloadOriginalImage(),
              _buildDefaultGalleryGroup(context),
              _buildDefaultArchiveGroup(context),
              _buildArchiveBotSettings(),
              _buildDownloadConcurrency(),
              _buildSpeedLimit(context),
              _buildDownloadAllGallerysOfSamePriority(),
              //_buildUseJH2UpdateGallery(),
              _buildArchiveDownloadIsolateCount(),
              _buildManageArchiveDownloadConcurrency(),
              _buildDeleteArchiveFileAfterDownload(),
              _buildRestore(),
              _buildRestoreTasksAutomatically(),
            ],
          ).withListTileTheme(context),
        ),
      ),
    );
  }

  Widget _buildDownloadPath() {
    return moonListTile(
      title: 'downloadPath'.tr,
      subtitle: downloadSetting.downloadPath.value.breakWord,
      trailing: changeDownloadPathState == LoadingState.loading
          ? UIConfig.loadingAnimation(Get.context!)
          : const SizedBox(width: 24),
      onTap: () {
        if (!GetPlatform.isIOS) {
          toast('changeDownloadPathHint'.tr, isShort: false);
        }
      },
      onLongPress: () => _handleChangeDownloadPath(newDownloadPath: null),
    );
  }

  Widget _buildResetDownloadPath() {
    return moonListTile(
      title: 'resetDownloadPath'.tr,
      subtitle: 'longPress2Reset'.tr,
      onLongPress: _handleResetDownloadPath,
    );
  }

  Widget _buildExtraGalleryScanPath() {
    return moonListTile(
      title: 'extraGalleryScanPath'.tr,
      subtitle: 'extraGalleryScanPathHint'.tr,
      trailing: MoonEhButton.md(
          onTap: () => toRoute(Routes.extraGalleryScanPath),
          icon: BootstrapIcons.chevron_right),
      onTap: () => toRoute(Routes.extraGalleryScanPath),
    );
  }

  Widget _buildSingleImageSavePath() {
    return moonListTile(
      title: 'singleImageSavePath'.tr,
      subtitle: downloadSetting.singleImageSavePath.value.breakWord,
      trailing: GetPlatform.isMacOS
          ? null
          : MoonEhButton.md(
              onTap: _handleChangeSingleImageSavePath,
              icon: BootstrapIcons.chevron_right),
    );
  }

  Widget _buildDownloadOriginalImage() {
    return moonListTile(
      title: 'downloadOriginalImageByDefault'.tr,
      trailing: MoonSwitch(
          value: downloadSetting.downloadOriginalImageByDefault.value,
          onChanged: (value) {
            if (!userSetting.hasLoggedIn()) {
              toast('needLoginToOperate'.tr);
              return;
            }
            downloadSetting.saveDownloadOriginalImageByDefault(value);
          }),
    );
  }

  Widget _buildDefaultGalleryGroup(BuildContext context) {
    return moonListTile(
      title: 'defaultGalleryGroup'.tr,
      subtitle: 'longPress2Reset'.tr,
      trailing: Text(downloadSetting.defaultGalleryGroup.value ?? '',
          style: UIConfig.settingPageListTileTrailingTextStyle(context)),
      onTap: () async {
        ({String group, bool downloadOriginalImage})? result = await showDialog(
          context: context,
          builder: (_) => EHDownloadDialog(
            title: 'chooseGroup'.tr,
            currentGroup: downloadSetting.defaultGalleryGroup.value,
            candidates: galleryDownloadService.allGroups,
          ),
        );

        if (result != null) {
          downloadSetting.saveDefaultGalleryGroup(result.group);
        }
      },
      onLongPress: () {
        downloadSetting.saveDefaultGalleryGroup(null);
      },
    );
  }

  Widget _buildDefaultArchiveGroup(BuildContext context) {
    return moonListTile(
        title: 'defaultArchiveGroup'.tr,
        subtitle: 'longPress2Reset'.tr,
        trailing: Text(downloadSetting.defaultArchiveGroup.value ?? '',
            style: UIConfig.settingPageListTileTrailingTextStyle(context)),
        onTap: () async {
          ({String group, bool downloadOriginalImage})? result =
              await showDialog(
            context: context,
            builder: (_) => EHDownloadDialog(
              title: 'chooseGroup'.tr,
              currentGroup: downloadSetting.defaultArchiveGroup.value,
              candidates: archiveDownloadService.allGroups,
            ),
          );

          if (result != null) {
            downloadSetting.saveDefaultArchiveGroup(result.group);
          }
        },
        onLongPress: () {
          downloadSetting.saveDefaultArchiveGroup(null);
        });
  }

  Widget _buildDownloadConcurrency() {
    return moonListTile(
      title: 'downloadTaskConcurrency'.tr,
      trailing: popupMenuButton<int>(
        initialValue: downloadSetting.downloadTaskConcurrency.value,
        onSelected: (int? newValue) =>
            downloadSetting.saveDownloadTaskConcurrency(newValue!),
        itemBuilder: (context) => [
          PopupMenuItem(value: 2, child: Text('2').small()),
          PopupMenuItem(value: 4, child: Text('4').small()),
          PopupMenuItem(value: 6, child: Text('6').small()),
          PopupMenuItem(value: 8, child: Text('8').small()),
          PopupMenuItem(value: 10, child: Text('10').small()),
        ],
        child: IgnorePointer(
          child: filledButton(
            onPressed: () {},
            label: downloadSetting.downloadTaskConcurrency.value.toString(),
          ),
        ),
      ),
    );
  }

  Widget _buildArchiveBotSettings() {
    return moonListTile(
      title: 'archiveBotSettings'.tr,
      subtitle: 'archiveBotSettingsHint'.tr,
      trailing: MoonEhButton.md(
          onTap: () => toRoute(Routes.archiveBotSettings),
          icon: BootstrapIcons.chevron_right),
      onTap: () => toRoute(Routes.archiveBotSettings),
    );
  }

  Widget _buildSpeedLimit(BuildContext context) {
    return moonListTile(
      title: 'speedLimit'.tr,
      subtitle: 'speedLimitHint'.tr,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          popupMenuButton<int>(
            initialValue: downloadSetting.maximum.value,
            onSelected: (int? newValue) {
              downloadSetting.saveMaximum(newValue!);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 1, child: Text('1').small()),
              PopupMenuItem(value: 2, child: Text('2').small()),
              PopupMenuItem(value: 3, child: Text('3').small()),
              PopupMenuItem(value: 5, child: Text('5').small()),
              PopupMenuItem(value: 10, child: Text('10').small()),
              PopupMenuItem(value: 99, child: Text('99').small()),
            ],
            child: IgnorePointer(
              child: filledButton(
                onPressed: () {},
                label: downloadSetting.maximum.value.toString(),
              ),
            ),
          ),
          Text('${'images'.tr} ${'per'.tr}',
                  style: UIConfig.settingPageListTileTrailingTextStyle(context))
              .small()
              .marginSymmetric(horizontal: 8),
          popupMenuButton<Duration>(
            initialValue: downloadSetting.period.value,
            onSelected: (Duration? newValue) =>
                downloadSetting.savePeriod(newValue!),
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: Duration(seconds: 1), child: Text('1s').small()),
              PopupMenuItem(
                  value: Duration(seconds: 2), child: Text('2s').small()),
              PopupMenuItem(
                  value: Duration(seconds: 3), child: Text('3s').small()),
            ],
            child: IgnorePointer(
              child: filledButton(
                onPressed: () {},
                label: '${downloadSetting.period.value.inSeconds}s',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadAllGallerysOfSamePriority() {
    return moonListTile(
      title: 'downloadAllGallerysOfSamePriority'.tr,
      subtitle:
          '${'downloadAllGallerysOfSamePriorityHint'.tr} | ${'needRestart'.tr}',
      trailing: MoonSwitch(
          value: downloadSetting.downloadAllGallerysOfSamePriority.value,
          onChanged: (value) {
            downloadSetting.saveDownloadAllGallerysOfSamePriority(value);
          }),
    );
  }

  // Widget _buildUseJH2UpdateGallery() {
  //   return moonListTile(
  //     title: 'useJH2UpdateGallery'.tr,
  //     //subtitle: 'useJH2UpdateGalleryHint'.tr,
  //     trailing: MoonSwitch(
  //         value: downloadSetting.useJH2UpdateGallery.value,
  //         onChanged: downloadSetting.saveUseJH2UpdateGallery),
  //   );
  // }

  Widget _buildArchiveDownloadIsolateCount() {
    return moonListTile(
      title: 'archiveDownloadIsolateCount'.tr,
      subtitle: 'archiveDownloadIsolateCountHint'.tr,
      trailing: popupMenuButton<int>(
        initialValue: downloadSetting.archiveDownloadIsolateCount.value,
        onSelected: (int? newValue) =>
            downloadSetting.saveArchiveDownloadIsolateCount(newValue!),
        itemBuilder: (context) => [
          PopupMenuItem(value: 1, child: Text('1').small()),
          PopupMenuItem(value: 2, child: Text('2').small()),
          PopupMenuItem(value: 3, child: Text('3').small()),
          PopupMenuItem(value: 4, child: Text('4').small()),
          PopupMenuItem(value: 5, child: Text('5').small()),
          PopupMenuItem(value: 6, child: Text('6').small()),
          PopupMenuItem(value: 7, child: Text('7').small()),
          PopupMenuItem(value: 8, child: Text('8').small()),
          PopupMenuItem(value: 9, child: Text('9').small()),
          PopupMenuItem(value: 10, child: Text('10').small()),
        ],
        child: IgnorePointer(
          child: filledButton(
            onPressed: () {},
            label: downloadSetting.archiveDownloadIsolateCount.value.toString(),
          ),
        ),
      ),
    );
  }

  Widget _buildManageArchiveDownloadConcurrency() {
    return moonListTile(
      title: 'manageArchiveDownloadConcurrency'.tr,
      subtitle: 'manageArchiveDownloadConcurrencyHint'.tr,
      trailing: MoonSwitch(
          value: downloadSetting.manageArchiveDownloadConcurrency.value,
          onChanged: downloadSetting.saveManageArchiveDownloadConcurrency),
    );
  }

  Widget _buildDeleteArchiveFileAfterDownload() {
    return moonListTile(
      title: 'deleteArchiveFileAfterDownload'.tr,
      trailing: MoonSwitch(
          value: downloadSetting.deleteArchiveFileAfterDownload.value,
          onChanged: downloadSetting.saveDeleteArchiveFileAfterDownload),
    );
  }

  Widget _buildRestore() {
    return moonListTile(
      title: 'restoreDownloadTasks'.tr,
      subtitle: 'restoreDownloadTasksHint'.tr,
      onTap: _restore,
    );
  }

  Widget _buildRestoreTasksAutomatically() {
    return moonListTile(
      title: 'restoreTasksAutomatically'.tr,
      subtitle: 'restoreTasksAutomaticallyHint'.tr,
      trailing: MoonSwitch(
          value: downloadSetting.restoreTasksAutomatically.value,
          onChanged: downloadSetting.saveRestoreTasksAutomatically),
    );
  }

  Future<void> _handleChangeDownloadPath({String? newDownloadPath}) async {
    if (changeDownloadPathState == LoadingState.loading) {
      return;
    }

    if (GetPlatform.isIOS) {
      return;
    }

    await requestStoragePermission();

    String oldDownloadPath = downloadSetting.downloadPath.value;

    /// choose new download path
    try {
      newDownloadPath ??= await FilePicker.platform.getDirectoryPath();
    } on Exception catch (e) {
      log.error('Pick download path failed', e);
    }

    if (newDownloadPath == null || newDownloadPath == oldDownloadPath) {
      return;
    }

    /// check permission
    if (!checkPermissionForPath(newDownloadPath)) {
      toast('invalidPath'.tr, isShort: false);
      return;
    }

    setState(() => changeDownloadPathState = LoadingState.loading);

    try {
      await Future.wait([
        galleryDownloadService.pauseAllDownloadGallery(),
        archiveDownloadService.pauseAllDownloadArchive(),
      ]);

      try {
        await _copyOldFiles(oldDownloadPath, newDownloadPath);
      } on Exception catch (e) {
        log.error('Copy files failed!', e);
        log.uploadError(e, extraInfos: {
          'oldDownloadPath': oldDownloadPath,
          'newDownloadPath': newDownloadPath
        });
        toast('internalError'.tr);
      }

      downloadSetting.saveDownloadPath(newDownloadPath);

      /// to be compatible with the previous version, update the database.
      await galleryDownloadService.updateImagePathAfterDownloadPathChanged();

      await localGalleryService.refreshLocalGallerys();
    } on Exception catch (e) {
      log.error('_handleChangeDownloadPath failed!', e);
      log.uploadError(e);
      toast('internalError'.tr);
    } finally {
      setState(() => changeDownloadPathState = LoadingState.idle);
    }
  }

  Future<void> _handleResetDownloadPath() {
    return _handleChangeDownloadPath(
        newDownloadPath: downloadSetting.defaultDownloadPath);
  }

  Future<void> _copyOldFiles(
      String oldDownloadPath, String newDownloadPath) async {
    io.Directory oldDownloadDir = io.Directory(oldDownloadPath);
    List<io.FileSystemEntity> oldEntities =
        oldDownloadDir.listSync(recursive: true);
    List<io.Directory> oldDirs = oldEntities.whereType<io.Directory>().toList();
    List<io.File> oldFiles = oldEntities.whereType<io.File>().toList();

    List<Future> futures = [];

    /// copy directories first
    for (io.Directory oldDir in oldDirs) {
      if (FileUtil.isJHenTaiGalleryDirectory(oldDir)) {
        io.Directory newDir = io.Directory(join(
            newDownloadPath, relative(oldDir.path, from: oldDownloadPath)));
        futures.add(newDir.create(recursive: true));
      }
    }
    await Future.wait(futures);
    futures.clear();

    /// then copy files
    for (io.File oldFile in oldFiles) {
      if (FileUtil.isJHenTaiFile(oldFile)) {
        futures.add(oldFile.copy(join(
            newDownloadPath, relative(oldFile.path, from: oldDownloadPath))));
      }
    }
    await Future.wait(futures);
  }

  Future<void> _handleChangeSingleImageSavePath() async {
    String oldPath = downloadSetting.singleImageSavePath.value;
    String? newPath;

    /// choose new path
    try {
      newPath = await FilePicker.platform.getDirectoryPath();
    } on Exception catch (e) {
      log.error('Pick single image save path failed', e);
    }

    if (newPath == null || newPath == oldPath) {
      return;
    }

    /// check permission
    if (!checkPermissionForPath(newPath)) {
      toast('invalidPath'.tr, isShort: false);
      return;
    }

    downloadSetting.saveSingleImageSavePath(newPath);
  }

  Future<void> _restore() async {
    log.info('Restore download task.');

    int restoredGalleryCount = await galleryDownloadService.restoreTasks();
    int restoredArchiveCount = await archiveDownloadService.restoreTasks();

    toast(
      '${'restoredGalleryCount'.tr}: $restoredGalleryCount\n${'restoredArchiveCount'.tr}: $restoredArchiveCount',
      isShort: false,
    );
  }
}
