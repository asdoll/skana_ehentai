import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/database/database.dart';
import 'package:skana_ehentai/src/mixin/scroll_to_top_page_mixin.dart';
import 'package:skana_ehentai/src/model/gallery_url.dart';
import 'package:skana_ehentai/src/pages/download/mixin/archive/archive_download_page_logic_mixin.dart';
import 'package:skana_ehentai/src/pages/download/mixin/archive/archive_download_page_state_mixin.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/grouped_list.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../../../../model/gallery_image.dart';
import '../../../../routes/routes.dart';
import '../../../../service/archive_download_service.dart';
import '../../../../service/super_resolution_service.dart' as srs;
import '../../../../service/super_resolution_service.dart';
import '../../../../setting/performance_setting.dart';
import '../../../../setting/preference_setting.dart';
import '../../../../setting/style_setting.dart';
import '../../../../utils/byte_util.dart';
import '../../../../utils/date_util.dart';
import '../../../../utils/route_util.dart';
import '../../../../widget/eh_gallery_category_tag.dart';
import '../../../../widget/eh_image.dart';
import '../../../details/details_page_logic.dart';
import '../../../layout/mobile_v2/notification/tap_menu_button_notification.dart';
import '../../download_base_page.dart';
import '../../mixin/archive/archive_download_page_mixin.dart';
import '../../mixin/basic/multi_select/multi_select_download_page_mixin.dart';
import 'archive_list_download_page_logic.dart';
import 'archive_list_download_page_state.dart';

class ArchiveListDownloadPage extends StatelessWidget
    with
        Scroll2TopPageMixin,
        MultiSelectDownloadPageMixin,
        ArchiveDownloadPageMixin {
  ArchiveListDownloadPage({super.key});

  final ArchiveListDownloadPageLogic logic =
      Get.put<ArchiveListDownloadPageLogic>(ArchiveListDownloadPageLogic(),
          permanent: true);
  final ArchiveListDownloadPageState state =
      Get.find<ArchiveListDownloadPageLogic>().state;

  @override
  ArchiveDownloadPageLogicMixin get archiveDownloadPageLogic => logic;

  @override
  ArchiveDownloadPageStateMixin get archiveDownloadPageState => state;

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
          galleryType: DownloadPageGalleryType.archive),
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
              archiveDownloadService.resumeAllDownloadArchive();
            }
            if (value == 3) {
              archiveDownloadService.pauseAllDownloadArchive();
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
    return GetBuilder<ArchiveDownloadService>(
      id: archiveDownloadService.galleryCountChangedId,
      builder: (_) => GetBuilder<ArchiveListDownloadPageLogic>(
        id: logic.bodyId,
        builder: (_) => NotificationListener<UserScrollNotification>(
          onNotification: logic.onUserScroll,
          child: FutureBuilder(
            future: state.displayGroupsCompleter.future,
            builder: (_, __) => !state.displayGroupsCompleter.isCompleted
                ? const Center()
                : GroupedList<String, ArchiveDownloadedData>(
                    maxGalleryNum4Animation:
                        performanceSetting.maxGalleryNum4Animation.value,
                    scrollController: state.scrollController,
                    controller: state.groupedListController,
                    groups: Map.fromEntries(archiveDownloadService.allGroups
                        .map((e) =>
                            MapEntry(e, state.displayGroups.contains(e)))),
                    elements: archiveDownloadService.archives,
                    elementGroup: (ArchiveDownloadedData archive) =>
                        archiveDownloadService
                            .archiveDownloadInfos[archive.gid]!.group,
                    groupBuilder: (context, groupName, isOpen) =>
                        _groupBuilder(context, groupName, isOpen).marginAll(5),
                    elementBuilder: (BuildContext context, String group,
                            ArchiveDownloadedData archive, isOpen) =>
                        _itemBuilder(context, archive),
                    groupUniqueKey: (String group) => group,
                    elementUniqueKey: (ArchiveDownloadedData archive) =>
                        archive.gid.toString(),
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
              '$groupName${'(${archiveDownloadService.archivesWithGroup(groupName).length})'}',
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

  Widget _itemBuilder(BuildContext context, ArchiveDownloadedData archive) {
    return GestureDetector(
      onSecondaryTap: () =>
          logic.handleLongPressOrSecondaryTapItem(archive, context),
      onLongPress: () =>
          logic.handleLongPressOrSecondaryTapItem(archive, context),
      child: _buildCard(context, archive)
          .marginSymmetric(horizontal: 5, vertical: 2),
    );
  }

  Widget _buildCard(BuildContext context, ArchiveDownloadedData archive) {
    return GetBuilder<ArchiveListDownloadPageLogic>(
      id: '${logic.itemCardId}::${archive.gid}',
      builder: (_) => Container(
        decoration: state.selectedGids.contains(archive.gid)
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
        height: UIConfig.downloadPageCardHeight,
        child: Row(
          children: [
            _buildCover(archive),
            _buildInfo(context, archive),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(ArchiveDownloadedData archive) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => toRoute(
        Routes.details,
        arguments: DetailsPageArgument(
            galleryUrl: GalleryUrl.parse(archive.galleryUrl)),
      ),
      child: EHImage(
        galleryImage: GalleryImage(url: archive.coverUrl),
        containerWidth: UIConfig.downloadPageCoverWidth,
        containerHeight: UIConfig.downloadPageCoverHeight,
        borderRadius:
            BorderRadius.circular(UIConfig.downloadPageCardBorderRadius),
        fit: BoxFit.fitWidth,
        maxBytes: 2 * 1024 * 1024,
      ),
    );
  }

  Widget _buildInfo(BuildContext context, ArchiveDownloadedData archive) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => logic.handleTapItem(archive),
        child: Container(
          padding: const EdgeInsets.only(left: 6, right: 10, bottom: 6, top: 6),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoHeader(context, archive),
                  const Expanded(child: SizedBox()),
                  _buildInfoCenter(context, archive),
                  const Expanded(child: SizedBox()),
                  _buildInfoFooter(context, archive),
                ],
              ),
              if (state.selectedGids.contains(archive.gid))
                const Positioned(
                    child: Center(child: Icon(Icons.check_circle))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoHeader(BuildContext context, ArchiveDownloadedData archive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          archive.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ).subHeader(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (archive.uploader != null)
              Text(
                archive.uploader!,
                style: TextStyle(
                    color: UIConfig.downloadPageCardTextColor(context)),
              ).small(),
            Text(
              preferenceSetting.showUtcTime.isTrue
                  ? archive.publishTime
                  : DateUtil.transformUtc2LocalTimeString(archive.publishTime),
              style:
                  TextStyle(color: UIConfig.downloadPageCardTextColor(context)),
            ).small(),
          ],
        ).marginOnly(top: 5),
      ],
    );
  }

  Widget _buildInfoCenter(BuildContext context, ArchiveDownloadedData archive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        EHGalleryCategoryTag(category: archive.category),
        const Expanded(child: SizedBox()),
        _buildReUnlockButton(context, archive),
        _buildParseFromBot(context, archive),
        _buildIsOriginal(context, archive),
        _buildSuperResolutionLabel(context, archive),
        _buildButton(context, archive),
      ],
    );
  }

  Widget _buildReUnlockButton(
      BuildContext context, ArchiveDownloadedData archive) {
    ArchiveDownloadInfo archiveDownloadInfo =
        archiveDownloadService.archiveDownloadInfos[archive.gid]!;

    return GetBuilder<ArchiveDownloadService>(
      id: '${ArchiveDownloadService.archiveStatusId}::${archive.gid}',
      builder: (_) {
        if (archiveDownloadInfo.archiveStatus != ArchiveStatus.needReUnlock) {
          return const SizedBox();
        }

        return GestureDetector(
          onTap: () => logic.handleReUnlockArchive(archive),
          child: Icon(BootstrapIcons.unlock,
              size: UIConfig.downloadPageBotIconSize + 1,
              color: UIConfig.alertColor(context)),
        ).marginOnly(right: 8);
      },
    );
  }

  Widget _buildParseFromBot(
      BuildContext context, ArchiveDownloadedData archive) {
    ArchiveDownloadInfo archiveDownloadInfo =
        archiveDownloadService.archiveDownloadInfos[archive.gid]!;
    return GetBuilder<ArchiveListDownloadPageLogic>(
      global: false,
      init: logic,
      id: '${logic.galleryId}::${archive.gid}',
      builder: (_) {
        if (archiveDownloadInfo.parseSource != ArchiveParseSource.bot.code) {
          return const SizedBox();
        }

        return Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: UIConfig.resumePauseButtonColor(context)),
          ),
          child: Icon(
            BootstrapIcons.robot,
            size: UIConfig.downloadPageBotIconSize,
            color: UIConfig.resumePauseButtonColor(context),
          ),
        );
      },
    );
  }

  Widget _buildIsOriginal(BuildContext context, ArchiveDownloadedData archive) {
    bool isOriginal = archive.isOriginal;
    if (!isOriginal) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
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
      BuildContext context, ArchiveDownloadedData archive) {
    return GetBuilder<srs.SuperResolutionService>(
      id: '${srs.SuperResolutionService.superResolutionId}::${archive.gid}',
      builder: (_) {
        srs.SuperResolutionInfo? superResolutionInfo = superResolutionService
            .get(archive.gid, srs.SuperResolutionType.archive);

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

  Widget _buildButton(BuildContext context, ArchiveDownloadedData archive) {
    ArchiveDownloadInfo archiveDownloadInfo =
        archiveDownloadService.archiveDownloadInfos[archive.gid]!;

    return GetBuilder<ArchiveDownloadService>(
      id: '${ArchiveDownloadService.archiveStatusId}::${archive.gid}',
      builder: (_) {
        return GestureDetector(
          onTap: () => archiveDownloadInfo.archiveStatus == ArchiveStatus.paused
              ? archiveDownloadService.resumeDownloadArchive(archive.gid)
              : archiveDownloadService.pauseDownloadArchive(archive.gid),
          child: Icon(
            archiveDownloadInfo.archiveStatus.code <= ArchiveStatus.paused.code
                ? BootstrapIcons.play
                : archiveDownloadInfo.archiveStatus == ArchiveStatus.completed
                    ? BootstrapIcons.check2
                    : BootstrapIcons.pause,
            size: 26,
            color: UIConfig.resumePauseButtonColor(context),
          ),
        );
      },
    );
  }

  Widget _buildInfoFooter(BuildContext context, ArchiveDownloadedData archive) {
    ArchiveDownloadInfo archiveDownloadInfo =
        archiveDownloadService.archiveDownloadInfos[archive.gid]!;

    return GetBuilder<ArchiveDownloadService>(
      id: '${ArchiveDownloadService.archiveStatusId}::${archive.gid}',
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (archiveDownloadInfo.archiveStatus ==
                    ArchiveStatus.downloading)
                  GetBuilder<ArchiveDownloadService>(
                    id: '${ArchiveDownloadService.archiveSpeedComputerId}::${archive.gid}::${archive.isOriginal}',
                    builder: (_) => Text(
                      archiveDownloadInfo.speedComputer.speed,
                      style: TextStyle(
                          fontSize: UIConfig.downloadPageCardTextSize,
                          color: UIConfig.downloadPageCardTextColor(context)),
                    ).small(),
                  ),
                const Expanded(child: SizedBox()),
                if (archiveDownloadInfo.archiveStatus.code <=
                    ArchiveStatus.downloading.code)
                  GetBuilder<ArchiveDownloadService>(
                    id: '${ArchiveDownloadService.archiveSpeedComputerId}::${archive.gid}::${archive.isOriginal}',
                    builder: (_) => Text(
                      '${byte2String(archiveDownloadInfo.speedComputer.downloadedBytes.toDouble())}/${byte2String(archiveDownloadInfo.size.toDouble())}',
                      style: TextStyle(
                          fontSize: UIConfig.downloadPageCardTextSize,
                          color: UIConfig.downloadPageCardTextColor(context)),
                    ).small(),
                  ),
                if (archiveDownloadInfo.archiveStatus !=
                    ArchiveStatus.downloading)
                  Text(
                    archiveDownloadInfo.archiveStatus.name.tr,
                    style: TextStyle(
                        fontSize: UIConfig.downloadPageCardTextSize,
                        color: UIConfig.downloadPageCardTextColor(context),
                        height: 1),
                  ).small().marginOnly(left: 8),
              ],
            ),
            if (archiveDownloadInfo.archiveStatus.code <=
                ArchiveStatus.downloading.code)
              SizedBox(
                height: UIConfig.downloadPageProgressIndicatorHeight,
                child: GetBuilder<ArchiveDownloadService>(
                  id: '${ArchiveDownloadService.archiveSpeedComputerId}::${archive.gid}::${archive.isOriginal}',
                  builder: (_) => MoonLinearProgress(
                    value: archiveDownloadInfo.speedComputer.downloadedBytes /
                        archiveDownloadInfo.size,
                    color: archiveDownloadInfo.archiveStatus.code <=
                            ArchiveStatus.paused.code
                        ? UIConfig.downloadPageProgressPausedIndicatorColor(
                            context)
                        : null,
                  ),
                ),
              ).marginOnly(top: 6),
          ],
        );
      },
    );
  }
}
