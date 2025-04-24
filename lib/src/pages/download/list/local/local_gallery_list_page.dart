import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/service/local_gallery_service.dart';
import 'package:skana_ehentai/src/widget/fade_slide_widget.dart';
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
  LocalGalleryListPage({Key? key}) : super(key: key);

  final LocalGalleryListPageLogic logic = Get.put(LocalGalleryListPageLogic(), permanent: true);
  final LocalGalleryListPageState state = Get.find<LocalGalleryListPageLogic>().state;

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
    return AppBar(
      centerTitle: true,
      titleSpacing: 0,
      title: const DownloadPageSegmentControl(galleryType: DownloadPageGalleryType.local),
      leading: IconButton(
        icon: const Icon(Icons.help),
        onPressed: () => toast((GetPlatform.isIOS || GetPlatform.isMacOS) ? 'localGalleryHelpInfo4iOSAndMacOS'.tr : 'localGalleryHelpInfo'.tr, isShort: false),
      ),
      actions: [
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [const Icon(Icons.grid_view), const SizedBox(width: 12), Text('switch2GridMode'.tr)],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [const Icon(Icons.refresh), const SizedBox(width: 12), Text('refresh'.tr)],
                ),
              ),
            ];
          },
          onSelected: (value) {
            if (value == 0) {
              DownloadPageBodyTypeChangeNotification(bodyType: DownloadPageBodyType.grid).dispatch(context);
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
          successWidgetBuilder: () => NotificationListener<UserScrollNotification>(
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

                  return galleryItemBuilder(context, index - logic.computeCurrentDirectoryCount());
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
        logic.isAtRootPath ? childPath : p.relative(childPath, from: state.currentPath),
        Icons.folder_special,
      ).marginAll(5),
    );
  }

  Widget parentDirectoryItemBuilder(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: logic.backRoute,
      child: _buildDirectory(context, '/..', Icons.keyboard_return).marginAll(5),
    );
  }

  Widget childDirectoryItemBuilder(BuildContext context, int index) {
    String childPath = logic.computeChildPath(index);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => logic.pushRoute(childPath),
      child: _buildDirectory(
        context,
        logic.isAtRootPath ? childPath : p.relative(childPath, from: state.currentPath),
        Icons.folder_open,
      ).marginAll(5),
    );
  }

  Widget _buildDirectory(BuildContext context, String displayPath, IconData iconData) {
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
            SizedBox(width: UIConfig.downloadPageGroupHeaderWidth, child: Center(child: Icon(iconData))),
            Expanded(child: Text(logic.transformDisplayPath(displayPath), maxLines: 1, overflow: TextOverflow.ellipsis))
          ],
        ),
      ),
    );
  }

  Widget galleryItemBuilder(BuildContext context, int index) {
    LocalGallery gallery = localGalleryService.path2GalleryDir[state.currentPath]![index];

    return Slidable(
      key: Key(gallery.title),
      endActionPane: _buildEndActionPane(context, gallery),
      child: GestureDetector(
        onSecondaryTap: () => logic.showBottomSheet(gallery, context),
        onLongPress: () => logic.showBottomSheet(gallery, context),
        child: FadeSlideWidget(
          show: !state.removedGalleryTitles.contains(gallery.title),
          child: _buildGallery(gallery, context).marginAll(5),
          afterAnimation: (bool show, bool isInit) {
            if (!show && !isInit) {
              Get.engine.addPostFrameCallback(
                (_) => localGalleryService.deleteGallery(gallery, state.currentPath),
              );
              state.removedGalleryTitles.remove(gallery.title);
            }
          },
        ),
      ),
    );
  }

  ActionPane _buildEndActionPane(BuildContext context, LocalGallery gallery) {
    return ActionPane(
      motion: const DrawerMotion(),
      extentRatio: 0.15,
      children: [
        SlidableAction(
          icon: Icons.delete,
          foregroundColor: UIConfig.alertColor(context),
          backgroundColor: UIConfig.downloadPageActionBackGroundColor(context),
          onPressed: (BuildContext context) => logic.handleRemoveItem(gallery),
        )
      ],
    );
  }

  Widget _buildGallery(LocalGallery gallery, BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => logic.goToReadPage(gallery),
      child: SizedBox(
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
        Text(gallery.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: UIConfig.downloadPageCardTitleSize, height: 1.2)),
      ],
    ).paddingOnly(left: 6, right: 10, top: 8, bottom: 5);
  }
}
