import 'dart:math';

import 'package:blur/blur.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/database/database.dart';
import 'package:skana_ehentai/src/mixin/scroll_to_top_page_mixin.dart';
import 'package:skana_ehentai/src/pages/download/download_base_page.dart';
import 'package:skana_ehentai/src/pages/download/mixin/archive/archive_download_page_logic_mixin.dart';
import 'package:skana_ehentai/src/pages/download/mixin/archive/archive_download_page_mixin.dart';
import 'package:skana_ehentai/src/pages/download/mixin/archive/archive_download_page_state_mixin.dart';
import 'package:skana_ehentai/src/service/super_resolution_service.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../../../../model/gallery_image.dart';
import '../../../../routes/routes.dart';
import '../../../../service/archive_download_service.dart';
import '../../../../utils/byte_util.dart';
import '../../../../utils/route_util.dart';
import '../../mixin/basic/multi_select/multi_select_download_page_mixin.dart';
import '../mixin/grid_download_page_mixin.dart';
import 'archive_grid_download_page_logic.dart';
import 'archive_grid_download_page_state.dart';

class ArchiveGridDownloadPage extends StatelessWidget
    with
        Scroll2TopPageMixin,
        MultiSelectDownloadPageMixin,
        ArchiveDownloadPageMixin,
        GridBasePage {
  ArchiveGridDownloadPage({super.key});

  @override
  final DownloadPageGalleryType galleryType = DownloadPageGalleryType.archive;
  @override
  final ArchiveGridDownloadPageLogic logic =
      Get.put<ArchiveGridDownloadPageLogic>(ArchiveGridDownloadPageLogic(),
          permanent: true);
  @override
  final ArchiveGridDownloadPageState state =
      Get.find<ArchiveGridDownloadPageLogic>().state;

  @override
  ArchiveDownloadPageLogicMixin get archiveDownloadPageLogic => logic;

  @override
  ArchiveDownloadPageStateMixin get archiveDownloadPageState => state;

  @override
  List<Widget> buildAppBarActions(BuildContext context) {
    return [
      GetBuilder<ArchiveGridDownloadPageLogic>(
        global: false,
        init: logic,
        id: logic.editButtonId,
        builder: (_) => MoonEhButton.md(
          icon: state.inEditMode
              ? BootstrapIcons.floppy
              : BootstrapIcons.filter_left,
          onTap: logic.toggleEditMode,
        ),
      ),
      popupMenuButton(
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              value: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  moonIcon(icon: BootstrapIcons.view_list),
                  const SizedBox(width: 12),
                  Text('switch2ListMode'.tr).small()
                ],
              ),
            ),
            PopupMenuItem(
              value: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  moonIcon(icon: BootstrapIcons.check2_all),
                  const SizedBox(width: 12),
                  Text('multiSelect'.tr).small()
                ],
              ),
            ),
            PopupMenuItem(
              value: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  moonIcon(icon: BootstrapIcons.play_circle),
                  const SizedBox(width: 12),
                  Text('resumeAllTasks'.tr).small()
                ],
              ),
            ),
            PopupMenuItem(
              value: 3,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  moonIcon(icon: BootstrapIcons.pause_circle),
                  const SizedBox(width: 12),
                  Text('pauseAllTasks'.tr).small()
                ],
              ),
            ),
            PopupMenuItem(
              value: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  moonIcon(icon: BootstrapIcons.search),
                  const SizedBox(width: 12),
                  Text('search'.tr).small()
                ],
              ),
            ),
          ];
        },
        onSelected: (value) {
          if (value == 0) {
            DownloadPageBodyTypeChangeNotification(
                    bodyType: DownloadPageBodyType.list)
                .dispatch(context);
          }
          if (value == 1) {
            if (state.inEditMode) {
              return;
            }
            logic.enterSelectMode();
          }
          if (value == 2) {
            logic.handleResumeAllTasks();
          }
          if (value == 3) {
            logic.handlePauseAllTasks();
          }
          if (value == 4) {
            toRoute(Routes.downloadSearch);
          }
        },
      ),
    ];
  }

  @override
  Widget? buildGridBottomAppBar(BuildContext context) {
    return buildBottomAppBar();
  }

  @override
  GridGroup groupBuilder(
      BuildContext context, String groupName, bool inEditMode) {
    List<ArchiveDownloadedData> archives =
        state.galleryObjectsWithGroup(groupName);

    return GridGroup(
      groupName: groupName,
      contentSize: archives.length,
      widgets: archives
          .sublist(0, min(GridGroup.maxWidgetCount, archives.length))
          .map(
            (archive) => GetBuilder<ArchiveDownloadService>(
              id: '${ArchiveDownloadService.archiveStatusId}::${archive.gid}',
              builder: (_) {
                Widget cover =
                    buildGroupInnerImage(GalleryImage(url: archive.coverUrl));

                if (archiveDownloadService
                        .archiveDownloadInfos[archive.gid]?.archiveStatus ==
                    ArchiveStatus.completed) {
                  return cover;
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Blur(
                    blur: 1,
                    blurColor: UIConfig.downloadPageGridCoverBlurColor,
                    colorOpacity: 0.6,
                    overlay: const Icon(BootstrapIcons.download,
                        color: UIConfig.downloadPageGridCoverOverlayColor),
                    child: cover,
                  ),
                );
              },
            ),
          )
          .toList(),
      onTap: inEditMode ? null : () => logic.enterGroup(groupName),
      onLongPress:
          inEditMode ? null : () => logic.handleLongPressGroup(groupName),
      onSecondTap:
          inEditMode ? null : () => logic.handleLongPressGroup(groupName),
    );
  }

  @override
  GridGallery galleryBuilder(
      BuildContext context, ArchiveDownloadedData archive, bool inEditMode) {
    return GridGallery(
      title: archive.title,
      widget: GetBuilder<ArchiveGridDownloadPageLogic>(
        id: '${logic.itemCardId}::${archive.gid}',
        builder: (_) {
          ArchiveDownloadInfo archiveDownloadInfo =
              archiveDownloadService.archiveDownloadInfos[archive.gid]!;

          return GetBuilder<ArchiveDownloadService>(
            id: '${ArchiveDownloadService.archiveStatusId}::${archive.gid}',
            builder: (_) {
              Widget cover =
                  buildGalleryImage(GalleryImage(url: archive.coverUrl));

              if (archiveDownloadService
                      .archiveDownloadInfos[archive.gid]?.archiveStatus ==
                  ArchiveStatus.completed) {
                if (state.selectedGids.contains(archive.gid)) {
                  return Stack(
                    children: [cover, _buildSelectedIcon()],
                  );
                } else {
                  return cover;
                }
              }

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Blur(
                      blur: 1,
                      blurColor: UIConfig.downloadPageGridCoverBlurColor,
                      colorOpacity: 0.6,
                      child: cover,
                    ),
                  ),
                  _buildCircularProgressIndicator(archive, archiveDownloadInfo),
                  _buildDownloadProgress(archive, archiveDownloadInfo),
                  _buildActionButton(archiveDownloadInfo, archive),
                  if (state.selectedGids.contains(archive.gid))
                    _buildSelectedIcon(),
                ],
              );
            },
          );
        },
      ),
      parseFromBot: archiveDownloadService
              .archiveDownloadInfos[archive.gid]?.parseSource ==
          ArchiveParseSource.bot.code,
      isOriginal: archive.isOriginal,
      gid: archive.gid,
      superResolutionType: SuperResolutionType.archive,
      onTapWidget: inEditMode ? null : () => logic.handleTapItem(archive),
      onTapTitle: inEditMode ? null : () => logic.handleTapTitle(archive),
      onLongPress: inEditMode
          ? null
          : () => logic.handleLongPressOrSecondaryTapItem(archive, context),
      onSecondTap: inEditMode
          ? null
          : () => logic.handleLongPressOrSecondaryTapItem(archive, context),
      onTertiaryTap: inEditMode ? null : () => logic.handleTapTitle(archive),
    );
  }

  Widget _buildSelectedIcon() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              Border.all(color: UIConfig.downloadPageGridViewSelectIconColor),
          color: UIConfig.downloadPageGridViewSelectIconBackGroundColor,
        ),
        child: Transform.translate(
            offset: Offset(0, 1),
            child: Icon(BootstrapIcons.check2,
                color: UIConfig.downloadPageGridViewSelectIconColor)),
      ),
    );
  }

  Center _buildCircularProgressIndicator(
      ArchiveDownloadedData archive, ArchiveDownloadInfo archiveDownloadInfo) {
    return Center(
      child: GetBuilder<ArchiveDownloadService>(
        id: '${ArchiveDownloadService.archiveSpeedComputerId}::${archive.gid}::${archive.isOriginal}',
        builder: (_) => ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: UIConfig.downloadPageGridViewCircularProgressSize,
            minHeight: UIConfig.downloadPageGridViewCircularProgressSize,
          ),
          child: CircularProgressIndicator(
            value: archiveDownloadInfo.speedComputer.downloadedBytes /
                archiveDownloadInfo.size,
            color: UIConfig.downloadPageGridProgressColor,
            backgroundColor: UIConfig.downloadPageGridProgressBackGroundColor,
          ),
        ),
      ),
    );
  }

  Center _buildDownloadProgress(
      ArchiveDownloadedData archive, ArchiveDownloadInfo archiveDownloadInfo) {
    return Center(
      child: GetBuilder<ArchiveDownloadService>(
        id: '${ArchiveDownloadService.archiveSpeedComputerId}::${archive.gid}::${archive.isOriginal}',
        builder: (_) => Text(
          '${byte2String(archiveDownloadInfo.speedComputer.downloadedBytes.toDouble())} / ${byte2String(archiveDownloadInfo.size.toDouble())}',
          style: const TextStyle(
              fontSize: UIConfig.downloadPageGridViewInfoTextSize,
              color: UIConfig.downloadPageGridTextColor),
        ).xSmall(),
      ).marginOnly(top: 60),
    );
  }

  GestureDetector  _buildActionButton(
      ArchiveDownloadInfo archiveDownloadInfo, ArchiveDownloadedData archive) {
    return GestureDetector(
      onTap: () =>
          archiveDownloadInfo.archiveStatus == ArchiveStatus.needReUnlock
              ? logic.handleReUnlockArchive(archive)
              : archiveDownloadInfo.archiveStatus == ArchiveStatus.paused
                  ? archiveDownloadService.resumeDownloadArchive(archive.gid)
                  : archiveDownloadService.pauseDownloadArchive(archive.gid),
      child: Center(
        child: GetBuilder<ArchiveDownloadService>(
          id: '${ArchiveDownloadService.archiveStatusId}::${archive.gid}',
          builder: (_) => archiveDownloadInfo.archiveStatus.code >=
                      ArchiveStatus.unlocking.code &&
                  archiveDownloadInfo.archiveStatus.code <=
                      ArchiveStatus.downloading.code
              ? GetBuilder<ArchiveDownloadService>(
                  id: '${ArchiveDownloadService.archiveSpeedComputerId}::${archive.gid}::${archive.isOriginal}',
                  builder: (_) => Text(
                    archiveDownloadInfo.speedComputer.speed,
                    style: const TextStyle(
                        fontSize: UIConfig.downloadPageGridViewSpeedTextSize,
                        color: UIConfig.downloadPageGridTextColor),
                  ),
                )
              : Icon(
                  archiveDownloadInfo.archiveStatus ==
                          ArchiveStatus.needReUnlock
                      ? BootstrapIcons.unlock
                      : archiveDownloadInfo.archiveStatus ==
                              ArchiveStatus.paused
                          ? BootstrapIcons.play
                          : archiveDownloadInfo.archiveStatus ==
                                  ArchiveStatus.completed
                              ? BootstrapIcons.check2
                              : BootstrapIcons.file_arrow_up,
                  color: UIConfig.downloadPageGridTextColor,
                ),
        ),
      ),
    );
  }
}
