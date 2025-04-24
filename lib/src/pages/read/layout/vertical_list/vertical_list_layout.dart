import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/model/read_page_info.dart';
import 'package:skana_ehentai/src/pages/read/layout/vertical_list/vertical_list_layout_state.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../setting/read_setting.dart';
import '../../../../utils/screen_size_util.dart';
import '../../../../widget/eh_wheel_speed_controller_for_read_page.dart';
import '../base/base_layout.dart';
import 'vertical_list_layout_logic.dart';

class VerticalListLayout extends BaseLayout {
  VerticalListLayout({Key? key}) : super(key: key);

  @override
  final VerticalListLayoutLogic logic = Get.put<VerticalListLayoutLogic>(VerticalListLayoutLogic(), permanent: true);
  final VerticalListLayoutState state = Get.find<VerticalListLayoutLogic>().state;

  @override
  Widget buildBody(BuildContext context) {
    return GetBuilder<VerticalListLayoutLogic>(
      id: logic.verticalLayoutId,
      builder: (_) => PhotoViewGallery.builder(
        scrollDirection: Axis.vertical,
        itemCount: 1,
        builder: (_, __) => PhotoViewGalleryPageOptions.customChild(
          controller: state.photoViewController,
          initialScale: 1.0,
          minScale: 1.0,
          maxScale: 2.5,
          scaleStateCycle: readSetting.enableDoubleTapToScaleUp.isTrue ? logic.scaleStateCycle : null,
          enableTapDragZoom: readSetting.enableTapDragToScaleUp.isTrue,
          child: EHWheelSpeedControllerForReadPage(
            scrollOffsetController: state.scrollOffsetController,
            child: ScrollablePositionedList.separated(
              physics: const ClampingScrollPhysics(),
              minCacheExtent: readPageState.readPageInfo.mode == ReadMode.online
                  ? readSetting.preloadDistance * screenHeight * 1
                  : readSetting.preloadDistanceLocal * screenHeight * 1,
              initialScrollIndex: readPageState.readPageInfo.initialIndex,
              itemCount: readPageState.readPageInfo.pageCount,
              itemScrollController: state.itemScrollController,
              itemPositionsListener: state.itemPositionsListener,
              scrollOffsetController: state.scrollOffsetController,
              itemBuilder: _imageBuilder,
              separatorBuilder: (_, __) => Obx(() => SizedBox(height: readSetting.imageSpace.value.toDouble())),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageBuilder(context, index) {
    Widget child = Row(
      children: [
        Expanded(
          flex: 100 - readSetting.imageRegionWidthRatio.value,
          child: const SizedBox(),
        ),
        Expanded(
          flex: readSetting.imageRegionWidthRatio.value * 2,
          child: readPageState.readPageInfo.mode == ReadMode.online ? buildItemInOnlineMode(context, index) : buildItemInLocalMode(context, index),
        ),
        Expanded(
          flex: 100 - readSetting.imageRegionWidthRatio.value,
          child: const SizedBox(),
        ),
      ],
    );

    if (GetPlatform.isMobile && index == 0) {
      return Obx(() => child.marginOnly(top: readSetting.notchOptimization.isTrue ? MediaQuery.of(context).padding.top : 0));
    }

    return child;
  }
}
