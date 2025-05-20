import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/pages/layout/mobile_v2/notification/tap_menu_button_notification.dart';
import 'package:skana_ehentai/src/service/local_gallery_service.dart';
import 'package:skana_ehentai/src/setting/style_setting.dart' show styleSetting;
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/fade_slide_widget.dart';
import 'package:skana_ehentai/src/widget/icons.dart';
import 'package:skana_ehentai/src/widget/loading_state_indicator.dart';
import 'package:path/path.dart' as p;

import '../../../../config/ui_config.dart';
import '../../../../mixin/scroll_to_top_logic_mixin.dart';
import '../../../../mixin/scroll_to_top_page_mixin.dart';
import '../../../../mixin/scroll_to_top_state_mixin.dart';
import '../../../../utils/toast_util.dart';
import '../../../../widget/eh_image.dart';
import '../../../../widget/eh_wheel_speed_controller.dart';
import '../../download_base_page.dart';
import 'local_gallery_list_page_logic.dart';
import 'local_gallery_list_page_state.dart';

class LocalGalleryListPage extends StatelessWidget with Scroll2TopPageMixin {
  LocalGalleryListPage({super.key});

  final LocalGalleryListPageLogic logic =
      Get.put(LocalGalleryListPageLogic(), permanent: true);
  final LocalGalleryListPageState state =
      Get.find<LocalGalleryListPageLogic>().state;

  @override
  Scroll2TopLogicMixin get scroll2TopLogic => logic;

  @override
  Scroll2TopStateMixin get scroll2TopState => state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(),
      floatingActionButton: buildFloatingActionButton(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return appBar(
      centerTitle: true,
      titleWidget: const DownloadPageSegmentControl(
          galleryType: DownloadPageGalleryType.local),
      leading: styleSetting.isInV2Layout
          ? NormalDrawerButton(
              onTap: () => TapMenuButtonNotification().dispatch(context),
            )
          : null,
      actions: [
        MoonEhButton.md(
          icon: BootstrapIcons.question_circle,
          onTap: () => toast(
              (GetPlatform.isIOS || GetPlatform.isMacOS)
                  ? 'localGalleryHelpInfo4iOSAndMacOS'.tr
                  : 'localGalleryHelpInfo'.tr,
              isShort: false),
        ),
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
                    moonIcon(icon: BootstrapIcons.arrow_clockwise),
                    const SizedBox(width: 12),
                    Text('refresh'.tr).small()
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
              logic.handleRefreshLocalGallery();
            }
          },
        ),
      ],
    );
  }

  Widget buildBody() {
    return GetBuilder<LocalGalleryService>(
      id: localGalleryService.galleryCountChangedId,
      builder: (_) => GetBuilder<LocalGalleryListPageLogic>(
        id: logic.bodyId,
        builder: (_) => LoadingStateIndicator(
          loadingState: localGalleryService.loadingState,
          successWidgetBuilder: () =>
              NotificationListener<UserScrollNotification>(
            onNotification: logic.onUserScroll,
            child: EHWheelSpeedController(
              controller: state.scrollController,
              child: ListView.builder(
                controller: state.scrollController,
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: logic.computeItemCount(),
                itemBuilder: (context, index) {
                  if (logic.isAtRootPath) {
                    return rootDirectoryItemBuilder(context, index);
                  }

                  if (index == 0) {
                    return parentDirectoryItemBuilder(context);
                  }

                  index--;

                  if (index < logic.computeCurrentDirectoryCount()) {
                    return childDirectoryItemBuilder(context, index);
                  }

                  return galleryItemBuilder(
                      context, index - logic.computeCurrentDirectoryCount());
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget rootDirectoryItemBuilder(BuildContext context, int index) {
    String childPath = logic.computeChildPath(index);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => logic.pushRoute(childPath),
      child: _buildDirectory(
        context,
        logic.isAtRootPath
            ? childPath
            : p.relative(childPath, from: state.currentPath),
        BootstrapIcons.archive,
      ).marginAll(5),
    );
  }

  Widget parentDirectoryItemBuilder(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: logic.backRoute,
      child:
          _buildDirectory(context, '/..', BootstrapIcons.arrow_return_left).marginAll(5),
    );
  }

  Widget childDirectoryItemBuilder(BuildContext context, int index) {
    String childPath = logic.computeChildPath(index);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => logic.pushRoute(childPath),
      child: _buildDirectory(
        context,
        logic.isAtRootPath
            ? childPath
            : p.relative(childPath, from: state.currentPath),
        BootstrapIcons.folder,
      ).marginAll(5),
    );
  }

  Widget _buildDirectory(
      BuildContext context, String displayPath, IconData iconData) {
    return Container(
      height: UIConfig.groupListHeight,
      decoration: BoxDecoration(
        color: UIConfig.groupListColor(context),
        boxShadow: [if (!Get.isDarkMode) UIConfig.groupListShadow(context)],
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.only(right: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Row(
          children: [
            SizedBox(
                width: UIConfig.downloadPageGroupHeaderWidth,
                child: Center(child: moonIcon(icon: iconData))),
            Expanded(
                child: Text(logic.transformDisplayPath(displayPath),
                    maxLines: 1, overflow: TextOverflow.ellipsis).subHeader())
          ],
        ),
      ),
    );
  }

  Widget galleryItemBuilder(BuildContext context, int index) {
    LocalGallery gallery =
        localGalleryService.path2GalleryDir[state.currentPath]![index];

    return GestureDetector(
      onSecondaryTap: () => logic.showBottomSheet(gallery, context),
      onLongPress: () => logic.showBottomSheet(gallery, context),
      child: FadeSlideWidget(
        show: !state.removedGalleryTitles.contains(gallery.title),
        child: _buildGallery(gallery, context).marginSymmetric(horizontal: 5,vertical: 2),
        afterAnimation: (bool show, bool isInit) {
          if (!show && !isInit) {
            Get.engine.addPostFrameCallback(
              (_) =>
                  localGalleryService.deleteGallery(gallery, state.currentPath),
            );
            state.removedGalleryTitles.remove(gallery.title);
          }
        },
      ),
    );
  }

  Widget _buildGallery(LocalGallery gallery, BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => logic.goToReadPage(gallery),
      child: Container(
        decoration: BoxDecoration(
          color: UIConfig.downloadPageCardColor(context),
          borderRadius:
              BorderRadius.circular(UIConfig.downloadPageCardBorderRadius),
        ),
        height: UIConfig.downloadPageCardHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Row(
            children: [
              _buildCover(gallery, context),
              Expanded(child: _buildInfo(context, gallery)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover(LocalGallery gallery, BuildContext context) {
    return EHImage(
      galleryImage: gallery.cover,
      borderRadius:
                BorderRadius.circular(UIConfig.downloadPageCardBorderRadius),
      containerWidth: UIConfig.downloadPageCoverWidth,
      containerHeight: UIConfig.downloadPageCoverHeight,
      fit: BoxFit.fitWidth,
      maxBytes: 2 * 1024 * 1024,
    );
  }

  Widget _buildInfo(BuildContext context, LocalGallery gallery) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(gallery.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: UIConfig.downloadPageCardTitleSize, height: 1.2)).subHeader(),
      ],
    ).paddingOnly(left: 6, right: 10, top: 8, bottom: 5);
  }
}
