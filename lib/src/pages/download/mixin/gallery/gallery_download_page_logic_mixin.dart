import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/get_logic_extension.dart';
import 'package:skana_ehentai/src/mixin/scroll_to_top_logic_mixin.dart';
import 'package:skana_ehentai/src/mixin/update_global_gallery_status_logic_mixin.dart';
import 'package:skana_ehentai/src/service/super_resolution_service.dart';
import 'package:skana_ehentai/src/setting/super_resolution_setting.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

import '../../../../database/database.dart';
import '../../../../enum/config_enum.dart';
import '../../../../model/read_page_info.dart';
import '../../../../routes/routes.dart';
import '../../../../service/gallery_download_service.dart';
import '../../../../service/local_config_service.dart';
import '../../../../setting/read_setting.dart';
import '../../../../utils/process_util.dart';
import '../../../../utils/route_util.dart';
import '../../../../utils/toast_util.dart';
import '../../../../widget/eh_alert_dialog.dart';
import '../../../../widget/eh_download_dialog.dart';
import '../basic/multi_select/multi_select_download_page_logic_mixin.dart';

mixin GalleryDownloadPageLogicMixin on GetxController
    implements
        Scroll2TopLogicMixin,
        MultiSelectDownloadPageLogicMixin<GalleryDownloadedData>,
        UpdateGlobalGalleryStatusLogicMixin {
  final String bodyId = 'bodyId';

  final GalleryDownloadService downloadService = galleryDownloadService;

  Future<void> handleChangeGroup(GalleryDownloadedData gallery) async {
    String oldGroup = downloadService.galleryDownloadInfos[gallery.gid]!.group;

    ({String group, bool downloadOriginalImage})? result = await Get.dialog(
      EHDownloadDialog(
        title: 'changeGroup'.tr,
        currentGroup: oldGroup,
        candidates: downloadService.allGroups,
      ),
    );

    if (result == null) {
      return;
    }

    String newGroup = result.group;
    if (newGroup == oldGroup) {
      return;
    }

    await downloadService.updateGroup(gallery, newGroup);

    update([bodyId]);
  }

  Future<void> handleLongPressGroup(String oldGroup) async {
    if (downloadService.galleryDownloadInfos.values
        .every((g) => g.group != oldGroup)) {
      return handleDeleteGroup(oldGroup);
    }
    return handleRenameGroup(oldGroup);
  }

  Future<void> handleRenameGroup(String oldGroup) async {
    ({String group, bool downloadOriginalImage})? result = await Get.dialog(
      EHDownloadDialog(
        title: 'renameGroup'.tr,
        currentGroup: oldGroup,
        candidates: downloadService.allGroups,
      ),
    );

    if (result == null) {
      return;
    }

    String newGroup = result.group;
    if (newGroup == oldGroup) {
      return;
    }

    return doRenameGroup(oldGroup, newGroup);
  }

  Future<void> doRenameGroup(String oldGroup, String newGroup) async {
    await downloadService.renameGroup(oldGroup, newGroup);
    update([bodyId]);
  }

  Future<void> handleDeleteGroup(String oldGroup) async {
    bool? success = await Get.dialog(EHDialog(title: '${'deleteGroup'.tr}?'));
    if (success == null || !success) {
      return;
    }

    await downloadService.deleteGroup(oldGroup);

    update([bodyId]);
  }

  @override
  void handleTapItem(GalleryDownloadedData item) {
    if (multiSelectDownloadPageState.inMultiSelectMode) {
      toggleSelectItem(item.gid);
    } else {
      goToReadPage(item);
    }
  }

  @override
  void handleLongPressOrSecondaryTapItem(
      GalleryDownloadedData item, BuildContext context) {
    if (multiSelectDownloadPageState.inMultiSelectMode) {
      toggleSelectItem(item.gid);
    } else {
      showTrigger(item, context);
    }
  }

  void handleResumeAllTasks() {
    downloadService.resumeAllDownloadGallery();
  }

  void handlePauseAllTasks() {
    downloadService.pauseAllDownloadGallery();
  }

  void handleRemoveItem(GalleryDownloadedData gallery, bool deleteImages,
      BuildContext context) async {
    downloadService.update([downloadService.galleryCountChangedId]);
  }

  void handleAssignPriority(GalleryDownloadedData gallery, int priority) {
    downloadService.assignPriority(gallery, priority);
    updateSafely([bodyId]);
  }

  void handleReDownloadItem(GalleryDownloadedData gallery) {
    downloadService.reDownloadGallery(gallery);
  }

  Future<void> goToReadPage(GalleryDownloadedData gallery) async {
    if (readSetting.useThirdPartyViewer.isTrue &&
        readSetting.thirdPartyViewerPath.value != null) {
      openThirdPartyViewer(downloadService.computeGalleryDownloadAbsolutePath(
          gallery.title, gallery.gid));
    } else {
      String? string = await localConfigService.read(
          configKey: ConfigEnum.readIndexRecord,
          subConfigKey: gallery.gid.toString());
      int readIndexRecord = (string == null ? 0 : (int.tryParse(string) ?? 0));

      toRoute(
        Routes.read,
        arguments: ReadPageInfo(
          mode: ReadMode.downloaded,
          gid: gallery.gid,
          token: gallery.token,
          galleryTitle: gallery.title,
          galleryUrl: gallery.galleryUrl,
          initialIndex: readIndexRecord,
          readProgressRecordStorageKey: gallery.gid.toString(),
          pageCount: gallery.pageCount,
          useSuperResolution: superResolutionService.get(
                  gallery.gid, SuperResolutionType.gallery) !=
              null,
        ),
      );
    }
  }

  void showTrigger(GalleryDownloadedData gallery, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => moonAlertDialog(
        context: context,
        title: gallery.title,
        columnActions: true,
        actions: [
          outlinedButton(
            isFullWidth: true,
            onPressed: backRoute,
            label: 'cancel'.tr,
          ),
          if (superResolutionSetting.modelDirectoryPath.value != null &&
              downloadService.galleryDownloadInfos[gallery.gid]
                      ?.downloadProgress.downloadStatus ==
                  DownloadStatus.downloaded &&
              (superResolutionService.get(
                          gallery.gid, SuperResolutionType.gallery) ==
                      null ||
                  superResolutionService
                          .get(gallery.gid, SuperResolutionType.gallery)
                          ?.status ==
                      SuperResolutionStatus.paused))
            filledButton(
              label: 'superResolution'.tr,
              onPressed: () async {
                backRoute();

                if (superResolutionService.get(
                            gallery.gid, SuperResolutionType.gallery) ==
                        null &&
                    gallery.downloadOriginalImage) {
                  bool? result = await Get.dialog(EHDialog(
                      title: '${'attention'.tr}!',
                      content: 'superResolveOriginalImageHint'.tr));
                  if (result == false) {
                    return;
                  }
                }

                superResolutionService.superResolve(
                    gallery.gid, SuperResolutionType.gallery);
              },
            ),
          if (superResolutionService
                  .get(gallery.gid, SuperResolutionType.gallery)
                  ?.status ==
              SuperResolutionStatus.running)
            filledButton(
              label: 'stopSuperResolution'.tr,
              onPressed: () async {
                backRoute();
                superResolutionService
                    .pauseSuperResolve(gallery.gid, SuperResolutionType.gallery)
                    .then((_) => toast("success".tr));
              },
            ),
          if (superResolutionService
                      .get(gallery.gid, SuperResolutionType.gallery)
                      ?.status ==
                  SuperResolutionStatus.paused ||
              superResolutionService
                      .get(gallery.gid, SuperResolutionType.gallery)
                      ?.status ==
                  SuperResolutionStatus.success)
            filledButton(
              label: 'deleteSuperResolvedImage'.tr,
              onPressed: () async {
                backRoute();
                superResolutionService
                    .deleteSuperResolve(
                        gallery.gid, SuperResolutionType.gallery)
                    .then((_) => toast("success".tr));
              },
            ),
          filledButton(
            label: 'changeGroup'.tr,
            onPressed: () {
              backRoute();
              handleChangeGroup(gallery);
            },
          ),
          filledButton(
            label: 'changePriority'.tr,
            onPressed: () {
              backRoute();
              showPrioritySheet(gallery, context);
            },
          ),
          filledButton(
            label: 'reDownload'.tr,
            onPressed: () {
              backRoute();
              handleReDownloadItem(gallery);
            },
          ),
          filledButton(
            label: 'deleteTask'.tr,
            color: UIConfig.alertColor(context),
            onPressed: () {
              backRoute();
              handleRemoveItem(gallery, false, context);
            },
          ),
          filledButton(
            label: 'deleteTaskAndImages'.tr,
            color: UIConfig.alertColor(context),
            onPressed: () {
              backRoute();
              handleRemoveItem(gallery, true, context);
            },
          ),
        ],
      ),
    );
  }

  void showPrioritySheet(GalleryDownloadedData gallery, BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text('${'priority'.tr} : 1 (${'highest'.tr})'),
            isDefaultAction:
                downloadService.galleryDownloadInfos[gallery.gid]?.priority ==
                    1,
            onPressed: () {
              handleAssignPriority(gallery, 1);
              backRoute();
            },
          ),
          ...[2, 3]
              .map((i) => CupertinoActionSheetAction(
                    child: Text('${'priority'.tr} : $i'),
                    isDefaultAction: downloadService
                            .galleryDownloadInfos[gallery.gid]?.priority ==
                        i,
                    onPressed: () {
                      handleAssignPriority(gallery, i);
                      backRoute();
                    },
                  ))
              .toList(),
          CupertinoActionSheetAction(
            child: Text('${'priority'.tr} : 4 (${'default'.tr})'),
            isDefaultAction:
                downloadService.galleryDownloadInfos[gallery.gid]?.priority ==
                    4,
            onPressed: () {
              handleAssignPriority(gallery, 4);
              backRoute();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('${'priority'.tr} : 5'),
            isDefaultAction:
                downloadService.galleryDownloadInfos[gallery.gid]?.priority ==
                    5,
            onPressed: () {
              handleAssignPriority(gallery, 5);
              backRoute();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('cancel'.tr),
          onPressed: backRoute,
        ),
      ),
    );
  }

  Future<void> handleMultiResumeTasks() async {
    for (int gid in multiSelectDownloadPageState.selectedGids) {
      downloadService.resumeDownloadGalleryByGid(gid);
    }

    exitSelectMode();
  }

  Future<void> handleMultiPauseTasks() async {
    for (int gid in multiSelectDownloadPageState.selectedGids) {
      downloadService.pauseDownloadGalleryByGid(gid);
    }

    exitSelectMode();
  }

  Future<void> handleMultiReDownloadItems() async {
    bool? result = await Get.dialog(
      EHDialog(title: 'reDownload'.tr, content: 'multiReDownloadHint'.tr),
    );

    if (result == true) {
      for (int gid in multiSelectDownloadPageState.selectedGids) {
        downloadService.reDownloadGalleryByGid(gid);
      }

      exitSelectMode();
    }
  }

  Future<void> handleMultiChangeGroup() async {
    ({String group, bool downloadOriginalImage})? result = await Get.dialog(
      EHDownloadDialog(
        title: 'changeGroup'.tr,
        candidates: downloadService.allGroups,
      ),
    );

    if (result == null) {
      return;
    }

    String newGroup = result.group;

    for (int gid in multiSelectDownloadPageState.selectedGids) {
      await downloadService.updateGroupByGid(gid, newGroup);
    }

    multiSelectDownloadPageState.inMultiSelectMode = false;
    multiSelectDownloadPageState.selectedGids.clear();
    updateSafely([bottomAppbarId, bodyId]);
  }

  Future<void> handleMultiDelete() async {
    bool isUpdatingDependent = multiSelectDownloadPageState.selectedGids
        .any(downloadService.isUpdatingDependent);

    bool? result = await Get.dialog(
      EHDialog(
        title: 'delete'.tr,
        content: 'multiDeleteHint'.tr +
            (isUpdatingDependent
                ? '\n\n${'deleteUpdatingDependentHint'.tr}'
                : ''),
      ),
    );

    if (result == true) {
      List<Future> futures = [];

      for (int gid in multiSelectDownloadPageState.selectedGids) {
        futures.add(downloadService.deleteGalleryByGid(gid));
      }

      exitSelectMode();
      await Future.wait(futures);
      updateGlobalGalleryStatus();
    }
  }
}
