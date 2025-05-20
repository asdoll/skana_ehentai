import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/model/gallery_url.dart';
import 'package:skana_ehentai/src/pages/download/mixin/gallery/gallery_download_page_mixin.dart';
import 'package:skana_ehentai/src/service/super_resolution_service.dart' as srs;
import 'package:skana_ehentai/src/setting/preference_setting.dart';
import 'package:skana_ehentai/src/setting/style_setting.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/grouped_list.dart';
import 'package:skana_ehentai/src/widget/icons.dart';
import '../../../../database/database.dart';
import '../../../../mixin/scroll_to_top_page_mixin.dart';
import '../../../../model/gallery_image.dart';
import '../../../../routes/routes.dart';
import '../../../../service/gallery_download_service.dart';
import '../../../../service/super_resolution_service.dart';
import '../../../../setting/performance_setting.dart';
import '../../../../utils/date_util.dart';
import '../../../../utils/route_util.dart';
import '../../../../widget/eh_gallery_category_tag.dart';
import '../../../../widget/eh_image.dart';
import '../../../details/details_page_logic.dart';
import '../../../layout/mobile_v2/notification/tap_menu_button_notification.dart';
import '../../download_base_page.dart';
import '../../mixin/basic/multi_select/multi_select_download_page_logic_mixin.dart';
import '../../mixin/basic/multi_select/multi_select_download_page_mixin.dart';
import '../../mixin/basic/multi_select/multi_select_download_page_state_mixin.dart';
import '../../mixin/gallery/gallery_download_page_logic_mixin.dart';
import '../../mixin/gallery/gallery_download_page_state_mixin.dart';
import 'gallery_list_download_page_logic.dart';
import 'gallery_list_download_page_state.dart';

class GalleryListDownloadPage extends StatelessWidget
    with
        Scroll2TopPageMixin,
        MultiSelectDownloadPageMixin,
        GalleryDownloadPageMixin {
  GalleryListDownloadPage({super.key});

  final GalleryListDownloadPageLogic logic =
      Get.put<GalleryListDownloadPageLogic>(GalleryListDownloadPageLogic(),
          permanent: true);
  final GalleryListDownloadPageState state =
      Get.find<GalleryListDownloadPageLogic>().state;

  @override
  MultiSelectDownloadPageLogicMixin get multiSelectDownloadPageLogic => logic;

  @override
  MultiSelectDownloadPageStateMixin get multiSelectDownloadPageState => state;

  @override
  GalleryDownloadPageLogicMixin get galleryDownloadPageLogic => logic;

  @override
  GalleryDownloadPageStateMixin get galleryDownloadPageState => state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context),
      floatingActionButton: buildFloatingActionButton(),
      bottomNavigationBar: buildBottomAppBar(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return appBar(
      centerTitle: true,
      leading: styleSetting.isInV2Layout
          ? isRouteAtTop(Routes.download)
              ? MoonButton.icon(
                  onTap: () => backRoute(currentRoute: Routes.download),
                  icon: Icon(
                    BootstrapIcons.justify,
                    color: context.moonTheme?.tokens.colors.bulma,
                    size: 20,
                  ),
                )
              : NormalDrawerButton(
                  onTap: () => TapMenuButtonNotification().dispatch(context),
                )
          : null,
      titleWidget: const DownloadPageSegmentControl(
          galleryType: DownloadPageGalleryType.download),
      actions: [
        popupMenuButton(
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    moonIcon(icon: BootstrapIcons.grid),
                    const SizedBox(width: 12),
                    Text('switch2GridMode'.tr).small()
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
                      bodyType: DownloadPageBodyType.grid)
                  .dispatch(context);
            }
            if (value == 1) {
              logic.enterSelectMode();
            }
            if (value == 2) {
              logic.downloadService.resumeAllDownloadGallery();
            }
            if (value == 3) {
              logic.downloadService.pauseAllDownloadGallery();
            }
            if (value == 4) {
              toRoute(Routes.downloadSearch);
            }
          },
        ),
      ],
    );
  }

  Widget buildBody(BuildContext context) {
    return GetBuilder<GalleryDownloadService>(
      id: logic.downloadService.galleryCountChangedId,
      builder: (_) => GetBuilder<GalleryListDownloadPageLogic>(
        id: logic.bodyId,
        builder: (_) => NotificationListener<UserScrollNotification>(
          onNotification: logic.onUserScroll,
          child: FutureBuilder(
            future: state.displayGroupsCompleter.future,
            builder: (_, __) => !state.displayGroupsCompleter.isCompleted
                ? const Center()
                : GroupedList<String, GalleryDownloadedData>(
                    maxGalleryNum4Animation:
                        performanceSetting.maxGalleryNum4Animation.value,
                    scrollController: state.scrollController,
                    controller: state.groupedListController,
                    groups: Map.fromEntries(logic.downloadService.allGroups.map(
                        (e) => MapEntry(e, state.displayGroups.contains(e)))),
                    elements: logic.downloadService.gallerys,
                    elementGroup: (GalleryDownloadedData gallery) => logic
                        .downloadService
                        .galleryDownloadInfos[gallery.gid]!
                        .group,
                    groupBuilder: (context, groupName, isOpen) =>
                        _groupBuilder(context, groupName, isOpen).marginAll(5),
                    elementBuilder: (BuildContext context, String group,
                            GalleryDownloadedData gallery, isOpen) =>
                        _itemBuilder(context, gallery),
                    groupUniqueKey: (String group) => group,
                    elementUniqueKey: (GalleryDownloadedData gallery) =>
                        gallery.gid.toString(),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _groupBuilder(BuildContext context, String groupName, bool isOpen) {
    return GestureDetector(
      onTap: () => logic.toggleDisplayGroups(groupName),
      onLongPress: () => logic.handleLongPressGroup(groupName),
      onSecondaryTap: () => logic.handleLongPressGroup(groupName),
      child: Container(
        height: UIConfig.groupListHeight,
        decoration: BoxDecoration(
          color: UIConfig.groupListColor(context),
          boxShadow: [if (!Get.isDarkMode) UIConfig.groupListShadow(context)],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            SizedBox(
                width: UIConfig.downloadPageGroupHeaderWidth,
                child:
                    Center(child: moonIcon(icon: BootstrapIcons.folder2_open))),
            Text(
              '$groupName${'(${logic.downloadService.gallerysWithGroup(groupName).length})'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ).subHeader(),
            const Expanded(child: SizedBox()),
            GroupOpenIndicator(isOpen: isOpen).marginOnly(right: 12),
          ],
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, GalleryDownloadedData gallery) {
    return GestureDetector(
      onSecondaryTap: () =>
          logic.handleLongPressOrSecondaryTapItem(gallery, context),
      onLongPress: () =>
          logic.handleLongPressOrSecondaryTapItem(gallery, context),
      child: _buildCard(context, gallery)
          .marginSymmetric(horizontal: 5, vertical: 2),
    );
  }

  Widget _buildCard(BuildContext context, GalleryDownloadedData gallery) {
    return GetBuilder<GalleryListDownloadPageLogic>(
      id: '${logic.itemCardId}::${gallery.gid}',
      builder: (_) => Container(
        height: UIConfig.downloadPageCardHeight,
        decoration: state.selectedGids.contains(gallery.gid)
            ? BoxDecoration(
                color: UIConfig.downloadPageCardSelectedColor(context),
                borderRadius: BorderRadius.circular(
                    UIConfig.downloadPageCardBorderRadius),
              )
            : BoxDecoration(
                color: UIConfig.downloadPageCardColor(context),
                borderRadius: BorderRadius.circular(
                    UIConfig.downloadPageCardBorderRadius),
              ),
        child: Row(
          children: [
            _buildCover(context, gallery),
            _buildInfo(context, gallery),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context, GalleryDownloadedData gallery) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => toRoute(
        Routes.details,
        arguments: DetailsPageArgument(
            galleryUrl: GalleryUrl.parse(gallery.galleryUrl)),
      ),
      child: GetBuilder<GalleryDownloadService>(
        id: '${logic.downloadService.downloadImageUrlId}::${gallery.gid}::0',
        builder: (_) {
          GalleryImage? image = logic
              .downloadService.galleryDownloadInfos[gallery.gid]?.images[0];

          /// cover is the first image, if we haven't downloaded first image, then return a [UIConfig.loadingAnimation]
          if (image?.downloadStatus != DownloadStatus.downloaded) {
            return SizedBox(
              width: UIConfig.downloadPageCoverWidth,
              height: UIConfig.downloadPageCoverHeight,
              child: Center(child: UIConfig.loadingAnimation(context)),
            );
          }

          return EHImage(
            galleryImage: image!,
            containerWidth: UIConfig.downloadPageCoverWidth,
            containerHeight: UIConfig.downloadPageCoverHeight,
            borderRadius:
                BorderRadius.circular(UIConfig.downloadPageCardBorderRadius),
            fit: BoxFit.fitWidth,
            maxBytes: 2 * 1024 * 1024,
          );
        },
      ),
    );
  }

  Widget _buildInfo(BuildContext context, GalleryDownloadedData gallery) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => logic.handleTapItem(gallery),
        child: Stack(
          children: [
            Container(
              padding:
                  const EdgeInsets.only(left: 6, right: 10, bottom: 6, top: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoHeader(context, gallery),
                  const Expanded(child: SizedBox()),
                  _buildInfoCenter(context, gallery),
                  const Expanded(child: SizedBox()),
                  _buildInfoFooter(context, gallery),
                ],
              ),
            ),
            if (state.selectedGids.contains(gallery.gid))
              const Positioned(child: Center(child: Icon(Icons.check_circle))),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoHeader(BuildContext context, GalleryDownloadedData gallery) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          gallery.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ).subHeader(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (gallery.uploader != null)
              Text(
                gallery.uploader!,
                style: TextStyle(
                    color: UIConfig.downloadPageCardTextColor(context)),
              ).small(),
            Text(
              preferenceSetting.showUtcTime.isTrue
                  ? gallery.publishTime
                  : DateUtil.transformUtc2LocalTimeString(gallery.publishTime),
              style:
                  TextStyle(color: UIConfig.downloadPageCardTextColor(context)),
            ).small(),
          ],
        ).marginOnly(top: 5),
      ],
    );
  }

  Widget _buildInfoCenter(BuildContext context, GalleryDownloadedData gallery) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        EHGalleryCategoryTag(category: gallery.category),
        const Expanded(child: SizedBox()),
        _buildIsOriginal(context, gallery),
        _buildSuperResolutionLabel(context, gallery),
        _buildPriority(context, gallery),
        _buildButton(context, gallery),
      ],
    );
  }

  Widget _buildIsOriginal(BuildContext context, GalleryDownloadedData gallery) {
    bool isOriginal = gallery.downloadOriginalImage;
    if (!isOriginal) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: UIConfig.resumePauseButtonColor(context)),
      ),
      child: Transform.translate(
          offset: Offset(0, -1),
          child: Text(
            'original'.tr,
            style: TextStyle(
                color: UIConfig.resumePauseButtonColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 10),
          )).paddingBottom(1),
    );
  }

  Widget _buildSuperResolutionLabel(
      BuildContext context, GalleryDownloadedData gallery) {
    return GetBuilder<srs.SuperResolutionService>(
      id: '${srs.SuperResolutionService.superResolutionId}::${gallery.gid}',
      builder: (_) {
        srs.SuperResolutionInfo? superResolutionInfo = superResolutionService
            .get(gallery.gid, srs.SuperResolutionType.gallery);

        if (superResolutionInfo == null) {
          return const SizedBox();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius:
                superResolutionInfo.status == srs.SuperResolutionStatus.success
                    ? null
                    : BorderRadius.circular(4),
            border: Border.all(color: UIConfig.resumePauseButtonColor(context)),
            shape:
                superResolutionInfo.status == srs.SuperResolutionStatus.success
                    ? BoxShape.circle
                    : BoxShape.rectangle,
          ),
          child: Text(
            superResolutionInfo.status == srs.SuperResolutionStatus.paused
                ? 'AI'
                : superResolutionInfo.status ==
                        srs.SuperResolutionStatus.success
                    ? 'AI'
                    : 'AI(${superResolutionInfo.imageStatuses.fold<int>(0, (previousValue, element) => previousValue + (element == srs.SuperResolutionStatus.success ? 1 : 0))}/${superResolutionInfo.imageStatuses.length})',
            style: TextStyle(
              fontSize: 10,
              color: UIConfig.resumePauseButtonColor(context),
              decoration:
                  superResolutionInfo.status == srs.SuperResolutionStatus.paused
                      ? TextDecoration.lineThrough
                      : null,
            ),
          ).paddingBottom(1),
        );
      },
    );
  }

  Widget _buildPriority(BuildContext context, GalleryDownloadedData gallery) {
    int? priority =
        logic.downloadService.galleryDownloadInfos[gallery.gid]?.priority;
    if (priority == null) {
      return const SizedBox();
    }

    switch (priority) {
      case 1:
        return Icon(BootstrapIcons.$1_circle,
                color: UIConfig.resumePauseButtonColor(context),
                size: UIConfig.downloadPageBotIconSize + 1)
            .marginSymmetric(horizontal: 6);
      case 2:
        return Icon(BootstrapIcons.$2_circle,
                color: UIConfig.resumePauseButtonColor(context),
                size: UIConfig.downloadPageBotIconSize + 1)
            .marginSymmetric(horizontal: 6);
      case 3:
        return Icon(BootstrapIcons.$3_circle,
                color: UIConfig.resumePauseButtonColor(context),
                size: UIConfig.downloadPageBotIconSize + 1)
            .marginSymmetric(horizontal: 6);
      case GalleryDownloadService.defaultDownloadGalleryPriority:
        return const SizedBox();
      case 5:
        return Icon(BootstrapIcons.$5_circle,
                color: UIConfig.resumePauseButtonColor(context),
                size: UIConfig.downloadPageBotIconSize + 1)
            .marginSymmetric(horizontal: 6);
      default:
        return const SizedBox();
    }
  }

  Widget _buildButton(BuildContext context, GalleryDownloadedData gallery) {
    return GetBuilder<GalleryDownloadService>(
      id: '${logic.downloadService.galleryDownloadProgressId}::${gallery.gid}',
      builder: (_) {
        DownloadStatus downloadStatus = logic.downloadService
            .galleryDownloadInfos[gallery.gid]!.downloadProgress.downloadStatus;
        return GestureDetector(
          onTap: () {
            downloadStatus == DownloadStatus.paused
                ? logic.downloadService.resumeDownloadGallery(gallery)
                : logic.downloadService.pauseDownloadGallery(gallery);
          },
          child: Icon(
            downloadStatus == DownloadStatus.paused
                ? BootstrapIcons.play
                : downloadStatus == DownloadStatus.downloading
                    ? BootstrapIcons.pause
                    : BootstrapIcons.check2,
            size: 26,
            color: UIConfig.resumePauseButtonColor(context),
          ),
        );
      },
    );
  }

  Widget _buildInfoFooter(BuildContext context, GalleryDownloadedData gallery) {
    return GetBuilder<GalleryDownloadService>(
      id: '${logic.downloadService.galleryDownloadProgressId}::${gallery.gid}',
      builder: (_) {
        GalleryDownloadProgress downloadProgress = logic.downloadService
            .galleryDownloadInfos[gallery.gid]!.downloadProgress;
        GalleryDownloadSpeedComputer speedComputer = logic
            .downloadService.galleryDownloadInfos[gallery.gid]!.speedComputer;
        return Column(
          children: [
            Row(
              children: [
                if (downloadProgress.downloadStatus ==
                    DownloadStatus.downloading)
                  GetBuilder<GalleryDownloadService>(
                    id: '${logic.downloadService.galleryDownloadSpeedComputerId}::${gallery.gid}',
                    builder: (_) => Text(
                      speedComputer.speed,
                      style: TextStyle(
                          fontSize: UIConfig.downloadPageCardTextSize,
                          color: UIConfig.downloadPageCardTextColor(context)),
                    ).small(),
                  ),
                const Expanded(child: SizedBox()),
                Text(
                  '${downloadProgress.curCount}/${downloadProgress.totalCount}',
                  style: TextStyle(
                      fontSize: UIConfig.downloadPageCardTextSize,
                      color: UIConfig.downloadPageCardTextColor(context)),
                ).small(),
              ],
            ),
            if (downloadProgress.downloadStatus != DownloadStatus.downloaded)
              SizedBox(
                height: 3,
                child: MoonLinearProgress(
                  value:
                      downloadProgress.curCount / downloadProgress.totalCount,
                  color:
                      downloadProgress.downloadStatus == DownloadStatus.paused
                          ? UIConfig.downloadPageProgressPausedIndicatorColor(
                              context)
                          : null,
                ),
              ).marginOnly(top: 4),
          ],
        );
      },
    );
  }
}
