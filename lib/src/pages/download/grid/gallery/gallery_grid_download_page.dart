import 'dart:math';

import 'package:blur/blur.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/database/database.dart';
import 'package:skana_ehentai/src/mixin/scroll_to_top_page_mixin.dart';
import 'package:skana_ehentai/src/pages/download/grid/gallery/gallery_grid_download_page_state.dart';
import 'package:skana_ehentai/src/pages/download/mixin/basic/multi_select/multi_select_download_page_logic_mixin.dart';
import 'package:skana_ehentai/src/pages/download/mixin/basic/multi_select/multi_select_download_page_mixin.dart';
import 'package:skana_ehentai/src/pages/download/mixin/basic/multi_select/multi_select_download_page_state_mixin.dart';
import 'package:skana_ehentai/src/pages/download/mixin/gallery/gallery_download_page_logic_mixin.dart';
import 'package:skana_ehentai/src/pages/download/mixin/gallery/gallery_download_page_mixin.dart';
import 'package:skana_ehentai/src/pages/download/mixin/gallery/gallery_download_page_state_mixin.dart';
import 'package:skana_ehentai/src/routes/routes.dart';
import 'package:skana_ehentai/src/service/super_resolution_service.dart';
import 'package:skana_ehentai/src/utils/route_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../../../../config/ui_config.dart';
import '../../../../model/gallery_image.dart';
import '../../../../service/gallery_download_service.dart';
import '../../download_base_page.dart';
import '../mixin/grid_download_page_mixin.dart';
import 'gallery_grid_download_page_logic.dart';

class GalleryGridDownloadPage extends StatelessWidget
    with
        Scroll2TopPageMixin,
        MultiSelectDownloadPageMixin,
        GalleryDownloadPageMixin,
        GridBasePage {
  GalleryGridDownloadPage({Key? key}) : super(key: key);

  @override
  final DownloadPageGalleryType galleryType = DownloadPageGalleryType.download;
  @override
  final GalleryGridDownloadPageLogic logic =
      Get.put<GalleryGridDownloadPageLogic>(GalleryGridDownloadPageLogic(),
          permanent: true);
  @override
  final GalleryGridDownloadPageState state =
      Get.find<GalleryGridDownloadPageLogic>().state;

  @override
  GalleryDownloadPageLogicMixin get galleryDownloadPageLogic => logic;

  @override
  GalleryDownloadPageStateMixin get galleryDownloadPageState => state;

  @override
  MultiSelectDownloadPageLogicMixin get multiSelectDownloadPageLogic => logic;

  @override
  MultiSelectDownloadPageStateMixin get multiSelectDownloadPageState => state;

  @override
  List<Widget> buildAppBarActions(BuildContext context) {
    return [
      GetBuilder<GalleryGridDownloadPageLogic>(
        global: false,
        init: logic,
        id: logic.editButtonId,
        builder: (_) => MoonEhButton.md(
          icon: state.inEditMode ? BootstrapIcons.floppy : BootstrapIcons.filter_left,
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
    List<GalleryDownloadedData> gallerys =
        state.galleryObjectsWithGroup(groupName);
    return GridGroup(
      groupName: groupName,
      contentSize: gallerys.length,
      widgets: gallerys
          .sublist(0, min(GridGroup.maxWidgetCount, gallerys.length))
          .map(
            (gallery) => GetBuilder<GalleryDownloadService>(
              id: '${logic.downloadService.galleryDownloadSuccessId}::${gallery.gid}',
              builder: (_) => GetBuilder<GalleryDownloadService>(
                id: '${logic.downloadService.downloadImageUrlId}::${gallery.gid}::0',
                builder: (_) {
                  GalleryImage? image = logic.downloadService
                      .galleryDownloadInfos[gallery.gid]?.images[0];

                  if (image == null) {
                    return Center(
                      child: UIConfig.loadingAnimation(context, size: 16),
                    );
                  }

                  Widget cover = buildGroupInnerImage(image);

                  if (logic.downloadService.galleryDownloadInfos[gallery.gid]
                          ?.downloadProgress.downloadStatus ==
                      DownloadStatus.downloaded) {
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
      BuildContext context, GalleryDownloadedData gallery, bool inEditMode) {
    return GridGallery(
      title: gallery.title,
      widget: GetBuilder<GalleryGridDownloadPageLogic>(
        id: '${logic.itemCardId}::${gallery.gid}',
        builder: (_) => GetBuilder<GalleryDownloadService>(
          id: '${logic.downloadService.galleryDownloadSuccessId}::${gallery.gid}',
          builder: (_) {
            if (logic.downloadService.galleryDownloadInfos[gallery.gid]
                    ?.downloadProgress.downloadStatus ==
                DownloadStatus.downloaded) {
              if (state.selectedGids.contains(gallery.gid)) {
                return Stack(
                  children: [_buildCover(gallery), _buildSelectedIcon()],
                );
              } else {
                return _buildCover(gallery);
              }
            }

            GalleryDownloadProgress downloadProgress = logic.downloadService
                .galleryDownloadInfos[gallery.gid]!.downloadProgress;
            GalleryDownloadSpeedComputer speedComputer = logic.downloadService
                .galleryDownloadInfos[gallery.gid]!.speedComputer;

            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Blur(
                    blur: 1,
                    blurColor: UIConfig.downloadPageGridCoverBlurColor,
                    colorOpacity: 0.6,
                    child: _buildCover(gallery),
                  ),
                ),
                _buildCircularProgressIndicator(gallery, downloadProgress),
                _buildDownloadProgress(gallery, downloadProgress),
                _buildActionButton(gallery, downloadProgress, speedComputer),
                if (state.selectedGids.contains(gallery.gid))
                  _buildSelectedIcon(),
              ],
            );
          },
        ),
      ),
      parseFromBot: false,
      isOriginal: gallery.downloadOriginalImage,
      gid: gallery.gid,
      superResolutionType: SuperResolutionType.gallery,
      onTapWidget: inEditMode ? null : () => logic.handleTapItem(gallery),
      onTapTitle: inEditMode ? null : () => logic.handleTapTitle(gallery),
      onLongPress: inEditMode
          ? null
          : () => logic.handleLongPressOrSecondaryTapItem(gallery, context),
      onSecondTap: inEditMode
          ? null
          : () => logic.handleLongPressOrSecondaryTapItem(gallery, context),
      onTertiaryTap: inEditMode ? null : () => logic.handleTapTitle(gallery),
    );
  }

  GetBuilder<GalleryDownloadService> _buildCover(
      GalleryDownloadedData gallery) {
    return GetBuilder<GalleryDownloadService>(
      id: '${logic.downloadService.downloadImageUrlId}::${gallery.gid}::0',
      builder: (_) {
        GalleryImage? image =
            logic.downloadService.galleryDownloadInfos[gallery.gid]?.images[0];

        if (image?.downloadStatus == DownloadStatus.downloaded) {
          return buildGalleryImage(image!);
        }

        return const Center();
      },
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
        child: const Icon(BootstrapIcons.check2,
            color: UIConfig.downloadPageGridViewSelectIconColor),
      ),
    );
  }

  Center _buildCircularProgressIndicator(
      GalleryDownloadedData gallery, GalleryDownloadProgress downloadProgress) {
    return Center(
      child: GetBuilder<GalleryDownloadService>(
        id: '${logic.downloadService.galleryDownloadProgressId}::${gallery.gid}',
        builder: (_) => ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: UIConfig.downloadPageGridViewCircularProgressSize,
            minHeight: UIConfig.downloadPageGridViewCircularProgressSize,
          ),
          child: CircularProgressIndicator(
            value: downloadProgress.curCount / downloadProgress.totalCount,
            color: UIConfig.downloadPageGridProgressColor,
            backgroundColor: UIConfig.downloadPageGridProgressBackGroundColor,
          ),
        ),
      ),
    );
  }

  Center _buildDownloadProgress(
      GalleryDownloadedData gallery, GalleryDownloadProgress downloadProgress) {
    return Center(
      child: GetBuilder<GalleryDownloadService>(
        id: '${logic.downloadService.galleryDownloadProgressId}::${gallery.gid}',
        builder: (_) => Text(
          '${downloadProgress.curCount} / ${downloadProgress.totalCount}',
          style: const TextStyle(
              fontSize: UIConfig.downloadPageGridViewInfoTextSize,
              color: UIConfig.downloadPageGridTextColor),
        ).xSmall(),
      ).marginOnly(top: 60),
    );
  }

  GestureDetector _buildActionButton(
      GalleryDownloadedData gallery,
      GalleryDownloadProgress downloadProgress,
      GalleryDownloadSpeedComputer speedComputer) {
    return GestureDetector(
      onTap: () {
        downloadProgress.downloadStatus == DownloadStatus.paused
            ? logic.downloadService.resumeDownloadGallery(gallery)
            : logic.downloadService.pauseDownloadGallery(gallery);
      },
      child: Center(
        child: GetBuilder<GalleryDownloadService>(
          id: '${logic.downloadService.galleryDownloadProgressId}::${gallery.gid}',
          builder: (_) =>
              downloadProgress.downloadStatus == DownloadStatus.downloading
                  ? GetBuilder<GalleryDownloadService>(
                      id: '${logic.downloadService.galleryDownloadSpeedComputerId}::${gallery.gid}',
                      builder: (_) => Text(
                        speedComputer.speed,
                        style: const TextStyle(
                          fontSize: UIConfig.downloadPageGridViewSpeedTextSize,
                          color: UIConfig.downloadPageGridTextColor,
                        ),
                      ).xSmall(),
                    )
                  : Icon(
                      downloadProgress.downloadStatus == DownloadStatus.paused
                          ? BootstrapIcons.play
                          : BootstrapIcons.check2,
                      color: UIConfig.downloadPageGridTextColor,
                    ),
        ),
      ),
    );
  }
}
