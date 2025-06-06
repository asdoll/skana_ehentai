import 'dart:math';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/mixin/window_widget_mixin.dart';
import 'package:skana_ehentai/src/mixin/scroll_status_listener.dart';
import 'package:skana_ehentai/src/mixin/scroll_status_listener_state.dart';
import 'package:skana_ehentai/src/model/read_page_info.dart';
import 'package:skana_ehentai/src/pages/read/layout/horizontal_list/horizontal_list_layout.dart';
import 'package:skana_ehentai/src/pages/read/layout/horizontal_page/horizontal_page_layout.dart';
import 'package:skana_ehentai/src/pages/read/read_page_logic.dart';
import 'package:skana_ehentai/src/pages/read/read_page_state.dart';
import 'package:skana_ehentai/src/service/super_resolution_service.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/eh_mouse_button_listener.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:skana_ehentai/src/widget/icons.dart';
import 'package:window_manager/window_manager.dart';

import '../../config/ui_config.dart';
import '../../routes/routes.dart';
import '../../service/gallery_download_service.dart';
import '../../setting/read_setting.dart';
import '../../utils/route_util.dart';
import '../../utils/screen_size_util.dart';
import '../../utils/toast_util.dart';
import '../../widget/eh_image.dart';
import '../../widget/eh_keyboard_listener.dart';
import '../../widget/eh_read_page_stack.dart';
import '../../widget/eh_thumbnail.dart';
import '../../widget/eh_wheel_speed_controller_for_read_page.dart';
import '../../widget/loading_state_indicator.dart';
import '../home_page.dart';
import 'layout/horizontal_double_column/horizontal_double_column_layout.dart';
import 'layout/vertical_list/vertical_list_layout.dart';

class ReadPage extends StatefulWidget {
  const ReadPage({super.key});

  @override
  State<ReadPage> createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage>
    with ScrollStatusListener, WindowListener, WindowWidgetMixin {
  final ReadPageLogic logic = Get.put<ReadPageLogic>(ReadPageLogic());
  final ReadPageState state = Get.find<ReadPageLogic>().state;

  @override
  ScrollStatusListerState get scrollStatusListerState => state;

  @override
  Brightness? get titleBarBrightness => Brightness.dark;

  @override
  Color? get titleBarColor => Colors.black;

  @override
  double get fullScreenTopPadding => 0;

  @override
  Widget build(BuildContext context) {
    Widget child = AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: EHMouseButtonListener(
        onFifthButtonTapDown: (_) => backRoute(),
        child: EHKeyboardListener(
          focusNode: state.focusNode,
          handleEsc: backRoute,
          handleSpace: logic.toggleMenu,
          handlePageDown: logic.toNext,
          handlePageUp: logic.toPrev,
          handleArrowDown: logic.toNext,
          handleArrowUp: logic.toPrev,
          handleArrowRight: logic.toRight,
          handleArrowLeft: logic.toLeft,
          handleA: logic.toLeft,
          handleD: logic.toRight,
          handleM: logic.handleM,
          handleEnd: backRoute,
          handleF11: toggleFullScreen,
          child: DefaultTextStyle(
            style: DefaultTextStyle.of(context).style.copyWith(
                  color: UIConfig.readPageForeGroundColor,
                  fontSize: 12,
                  decoration: TextDecoration.none,
                ),
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  EHReadPageStack(
                    children: [
                      buildGestureRegion(),
                      buildLayout(),
                    ],
                  ),
                  buildRightBottomInfo(context),
                  buildTopMenu(context),
                  buildBottomMenu(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return GetBuilder<ReadPageLogic>(
      id: logic.pageId,
      builder: (_) {
        if (readSetting.enableImmersiveMode.isFalse) {
          return buildWindow(child: child);
        }
        return child;
      },
    );
  }

  @override
  Widget buildWindow({required Widget child}) {
    return GetPlatform.isWindows
        ? buildWindowsTitle(child)
        : GetPlatform.isLinux
            ? buildLinuxTitle(child)
            : GetPlatform.isMacOS
                ? buildMaxOSTitle(child)
                : child;
  }

  /// Main region to display images
  Widget buildLayout() {
    Widget child = GetBuilder<ReadPageLogic>(
      id: logic.layoutId,
      builder: (_) {
        return LayoutBuilder(
          builder: (context, constraints) {
            logic.clearImageContainerSized();
            state.displayRegionSize =
                Size(constraints.maxWidth, constraints.maxHeight);

            if (readSetting.readDirection.value ==
                ReadDirection.top2bottomList) {
              return VerticalListLayout();
            }
            if (readSetting.isInListReadDirection) {
              return HorizontalListLayout();
            }
            if (readSetting.isInDoubleColumnReadDirection) {
              return HorizontalDoubleColumnLayout();
            }
            return HorizontalPageLayout();
          },
        );
      },
    );

    return wrapScrollListener(child);
  }

  /// right-bottom info
  Widget buildRightBottomInfo(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Obx(
        () {
          if (readSetting.showStatusInfo.isFalse) {
            return const SizedBox();
          }

          Widget child = DefaultTextStyle(
            style: DefaultTextStyle.of(context).style.copyWith(
                  color: UIConfig.readPageForeGroundColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
            child: Container(
              decoration: BoxDecoration(
                color: UIConfig.readPageRightBottomRegionColor,
                borderRadius:
                    const BorderRadius.only(topLeft: Radius.circular(8)),
              ),
              alignment: Alignment.center,
              padding:
                  const EdgeInsets.only(right: 32, bottom: 1, top: 3, left: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildPageNoInfo().marginOnly(right: 10),
                  _buildCurrentTime().marginOnly(right: 10),
                  if (!GetPlatform.isDesktop) _buildBatteryLevel(),
                ],
              ),
            ),
          );

          return GetBuilder<ReadPageLogic>(
            id: logic.rightBottomInfoId,
            builder: (_) => state.isMenuOpen ? child.fadeOut() : child.fadeIn(),
          );
        },
      ),
    );
  }

  Widget _buildPageNoInfo() {
    return GetBuilder<ReadPageLogic>(
      id: logic.pageNoId,
      builder: (_) => Text(
              '${state.readPageInfo.currentImageIndex + 1}/${state.readPageInfo.pageCount}')
          .small(),
    );
  }

  Widget _buildCurrentTime() {
    return GetBuilder<ReadPageLogic>(
      id: logic.currentTimeId,
      builder: (_) => Text(DateFormat('HH:mm').format(DateTime.now())).small(),
    );
  }

  Widget _buildBatteryLevel() {
    return GetBuilder<ReadPageLogic>(
      id: logic.batteryId,
      builder: (_) => Text('${state.batteryLevel}%').small(),
    );
  }

  /// gesture for turn page and pop menu
  Widget buildGestureRegion() {
    return Row(
      children: [
        /// left region
        Expanded(
          flex: (100 - readSetting.gestureRegionWidthRatio.value) ~/ 2,
          child: GestureDetector(
              onTap: logic.tapLeftRegion, behavior: HitTestBehavior.opaque),
        ),

        /// center region
        Expanded(
          flex: readSetting.gestureRegionWidthRatio.value,
          child: GestureDetector(
              onTap: logic.tapCenterRegion, behavior: HitTestBehavior.opaque),
        ),

        /// right region: toRight
        Expanded(
            flex: (100 - readSetting.gestureRegionWidthRatio.value) ~/ 2,
            child: GestureDetector(
                onTap: logic.tapRightRegion, behavior: HitTestBehavior.opaque)),
      ],
    );
  }

  /// top menu
  Widget buildTopMenu(BuildContext context) {
    return GetBuilder<ReadPageLogic>(
      id: logic.topMenuId,
      builder: (_) => AnimatedPositioned(
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
        height: state.isMenuOpen
            ? UIConfig.appBarHeight + context.mediaQuery.padding.top
            : 0,
        width: fullScreenWidth,
        child: appBar(
          leading: NormalBackButton(isDark: true),
          alwaysDark: true,
          actions: [
            if (GetPlatform.isDesktop)
              MoonEhButton(
                onTap: () => toast(
                  'PageDown、→、↓ 、D :  ${'toNext'.tr}'
                  '\n'
                  'PageUp、←、↑、A  :  ${'toPrev'.tr}'
                  '\n'
                  'Esc、End  :  ${'back'.tr}'
                  '\n'
                  'Space  :  ${'toggleMenu'.tr}'
                  '\n'
                  'M  :  ${'displayFirstPageAlone'.tr}'
                  '\n'
                  'F11  :  ${'toggleFullScreen'.tr}',
                  isShort: false,
                ),
                icon: BootstrapIcons.question_circle,
                color: UIConfig.readPageButtonColor,
              ),
            if (GetPlatform.isDesktop &&
                state.readPageInfo.gid != null &&
                (state.readPageInfo.mode == ReadMode.downloaded ||
                    state.readPageInfo.mode == ReadMode.archive) &&
                state.readPageInfo.useSuperResolution)
              textButton(
                onPressed: logic.handleTapSuperResolutionButton,
                labelWidget: GetBuilder<SuperResolutionService>(
                  id: '${SuperResolutionService.superResolutionId}::${state.readPageInfo.gid}',
                  builder: (_) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: UIConfig.onBackGroundColor(context)),
                    ),
                    child: Transform.translate(
                      offset: Offset(0, -1),
                      child: Text(
                        'AI${logic.getSuperResolutionProgress()}',
                        style: TextStyle(
                          fontSize: 15,
                          color: state.useSuperResolution
                              ? UIConfig.readPageActiveButtonColor(context)
                              : UIConfig.readPageButtonColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Obx(() {
              if (!readSetting.isInDoubleColumnReadDirection) {
                return const SizedBox();
              }
              return MoonEhButton(
                onTap: logic.toggleDisplayFirstPageAlone,
                icon: BootstrapIcons.$1_square,
                color: state.displayFirstPageAlone
                    ? UIConfig.readPageActiveButtonColor(context)
                    : UIConfig.readPageButtonColor,
              );
            }),
            GetBuilder<ReadPageLogic>(
              id: logic.autoModeId,
              builder: (_) => MoonEhButton(
                  onTap: logic.toggleAutoMode,
                  icon: BootstrapIcons.clock,
                  color: state.autoMode
                      ? UIConfig.readPageActiveButtonColor(context)
                      : UIConfig.readPageButtonColor),
            ),
            if (readSetting.enableBottomMenu.isFalse)
              MoonEhButton(
                onTap: () {
                  logic.restoreImmersiveMode();
                  toRoute(Routes.settingRead, id: fullScreen)?.then((_) {
                    logic.applyCurrentImmersiveMode();
                    state.focusNode.requestFocus();
                  });
                },
                icon: BootstrapIcons.gear,
                color: UIConfig.readPageButtonColor,
              ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  /// bottom menu
  Widget buildBottomMenu(BuildContext context) {
    return GetBuilder<ReadPageLogic>(
      id: logic.bottomMenuId,
      builder: (_) => Obx(
        () => AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
          bottom: state.isMenuOpen
              ? 0
              : (readSetting.showThumbnails.isTrue
                      ? -UIConfig.readPageBottomThumbnailsRegionHeight
                      : 0) -
                  UIConfig.readPageBottomSliderHeight -
                  (readSetting.enableBottomMenu.isTrue
                      ? UIConfig.readPageBottomActionHeight
                      : 0) -
                  max(MediaQuery.of(context).viewPadding.bottom,
                      UIConfig.readPageBottomSpacingHeight),
          child: ColoredBox(
            color: UIConfig.readPageMenuColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (readSetting.showThumbnails.isTrue)
                  _buildThumbnails(context),
                _buildSlider(),
                if (readSetting.enableBottomMenu.isTrue) _buildBottomAction(),
                SizedBox(
                    height: max(MediaQuery.of(context).viewPadding.bottom,
                        UIConfig.readPageBottomSpacingHeight)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnails(BuildContext context) {
    return SizedBox(
      width: fullScreenWidth,
      height: UIConfig.readPageBottomThumbnailsRegionHeight,
      child: Obx(
        () => EHWheelSpeedControllerForReadPage(
          scrollOffsetController: state.thumbnailsScrollOffsetController,
          child: ScrollablePositionedList.separated(
            scrollDirection: Axis.horizontal,
            reverse: readSetting.isInRight2LeftDirection,
            physics: const ClampingScrollPhysics(),
            minCacheExtent: 1 * fullScreenWidth,
            initialScrollIndex: state.readPageInfo.initialIndex,
            itemCount: state.readPageInfo.pageCount,
            itemScrollController: state.thumbnailsScrollController,
            itemPositionsListener: state.thumbnailPositionsListener,
            scrollOffsetController: state.thumbnailsScrollOffsetController,
            itemBuilder: (_, index) => GetBuilder<ReadPageLogic>(
              id: logic.thumbnailNoId,
              builder: (_) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 6),
                  SizedBox(
                    height: UIConfig.readPageThumbnailHeight,
                    width: UIConfig.readPageThumbnailWidth,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => logic.jump2ImageIndex(index),
                      child: state.readPageInfo.mode == ReadMode.online
                          ? _buildThumbnailInOnlineMode(context, index)
                          : _buildThumbnailInLocalMode(context, index),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GetBuilder<ReadPageLogic>(
                    builder: (_) => Center(
                      child: Container(
                        width: 24,
                        decoration: BoxDecoration(
                          color: state.readPageInfo.currentImageIndex == index
                              ? UIConfig
                                  .readPageBottomCurrentImageHighlightBackgroundColor(
                                      context)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          (index + 1).toString(),
                          style: TextStyle(
                            fontSize: 9,
                            color: state.readPageInfo.currentImageIndex == index
                                ? UIConfig
                                    .readPageBottomCurrentImageHighlightForegroundColor(
                                        context)
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
            separatorBuilder: (_, __) => const SizedBox(width: 6),
          ),
        ).enableMouseDrag(withScrollBar: false),
      ),
    );
  }

  Widget _buildThumbnailInOnlineMode(BuildContext context, int index) {
    return GetBuilder<ReadPageLogic>(
      id: '${logic.onlineImageId}::$index',
      builder: (_) {
        if (state.thumbnails[index] == null) {
          if (state.parseImageHrefsStates[index] == LoadingState.idle) {
            logic.beginToParseImageHref(index);
          }

          return Center(child: UIConfig.loadingAnimation(context));
        }

        return LayoutBuilder(
          builder: (_, constraints) => EHThumbnail(
            thumbnail: state.thumbnails[index]!,
            containerHeight: constraints.maxHeight,
            containerWidth: constraints.maxWidth,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }

  Widget _buildThumbnailInLocalMode(BuildContext context, int index) {
    return GetBuilder<GalleryDownloadService>(
      id: '${galleryDownloadService.downloadImageId}::${state.readPageInfo.gid}::$index',
      builder: (_) {
        if (state.images[index]?.downloadStatus != DownloadStatus.downloaded) {
          return Center(child: UIConfig.loadingAnimation(context));
        }
        return LayoutBuilder(
          builder: (_, constraints) => EHImage(
            galleryImage: state.images[index]!,
            containerHeight: constraints.maxHeight,
            containerWidth: constraints.maxWidth,
            borderRadius: BorderRadius.circular(8),
            maxBytes: 1024 * 50,
          ),
        );
      },
    );
  }

  Widget _buildSlider() {
    return GetBuilder<ReadPageLogic>(
      id: logic.sliderId,
      builder: (_) => SizedBox(
        height: UIConfig.readPageBottomSliderHeight,
        width: fullScreenWidth,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(readSetting.isInRight2LeftDirection
                    ? state.readPageInfo.pageCount.toString()
                    : (state.readPageInfo.currentImageIndex + 1).toString())
                .marginOnly(left: 36, right: 4),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ExcludeFocus(
                    child: Material(
                      color: Colors.transparent,
                      child: RotatedBox(
                        quarterTurns:
                            readSetting.isInRight2LeftDirection ? 2 : 0,
                        child: Slider(
                          min: 1,
                          max: state.readPageInfo.pageCount.toDouble(),
                          value: state.readPageInfo.currentImageIndex + 1.0,
                          thumbColor: UIConfig.readPageForeGroundColor,
                          activeColor: UIConfig.primaryColor(context),
                          onChanged: logic.handleSlide,
                          onChangeEnd: logic.handleSlideEnd,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(readSetting.isInRight2LeftDirection
                    ? (state.readPageInfo.currentImageIndex + 1).toString()
                    : state.readPageInfo.pageCount.toString())
                .marginOnly(right: 36, left: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return SizedBox(
      height: UIConfig.readPageBottomActionHeight,
      width: fullScreenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Material(
            color: Colors.transparent,
            child: popupMenuButton<ReadDirection>(
                initialValue: readSetting.readDirection.value,
                itemBuilder: (_) => ReadDirection.values
                    .map(
                      (e) => PopupMenuItem<ReadDirection>(
                          value: e, child: Text(e.name.tr)),
                    )
                    .toList(),
                onSelected: (ReadDirection value) =>
                    readSetting.saveReadDirection(value),
                child: IgnorePointer(
                  child: MoonEhButton(
                      buttonSize: MoonButtonSize.md,
                      onTap: () {},
                      color: Colors.white,
                      icon: BootstrapIcons.arrow_down_up),
                )),
          ),
          Material(
            color: Colors.transparent,
            child: popupMenuButton<DeviceDirection>(
              initialValue: readSetting.deviceDirection.value,
              itemBuilder: (_) => DeviceDirection.values
                  .map(
                    (e) => PopupMenuItem<DeviceDirection>(
                        value: e, child: Text(e.name.tr)),
                  )
                  .toList(),
              onSelected: (DeviceDirection value) =>
                  readSetting.saveDeviceDirection(value),
              child: IgnorePointer(
                  child: MoonEhButton(
                      buttonSize: MoonButtonSize.md,
                      onTap: () {},
                      color: Colors.white,
                      icon: Icons.screen_rotation)),
            ),
          ),
          MoonEhButton(
            buttonSize: MoonButtonSize.md,
            icon: BootstrapIcons.gear,
            color: Colors.white,
            onTap: () {
              logic.restoreImmersiveMode();
              toRoute(Routes.settingRead, id: fullScreen)?.then((_) {
                logic.applyCurrentImmersiveMode();
                state.focusNode.requestFocus();
              });
            },
          ),
        ],
      ),
    );
  }
}
