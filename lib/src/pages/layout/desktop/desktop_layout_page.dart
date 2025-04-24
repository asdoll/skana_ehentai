import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/pages/home_page.dart';
import 'package:skana_ehentai/src/pages/layout/desktop/desktop_home_page.dart';
import 'package:skana_ehentai/src/pages/layout/desktop/desktop_layout_page_state.dart';

import '../../../config/ui_config.dart';
import '../../../routes/routes.dart';
import '../../../service/windows_service.dart';
import '../../../setting/preference_setting.dart';
import '../../blank_page.dart';
import 'desktop_layout_page_logic.dart';

class DesktopLayoutPage extends StatelessWidget {
  final DesktopLayoutPageLogic logic = Get.put(DesktopLayoutPageLogic(), permanent: true);
  final DesktopLayoutPageState state = Get.find<DesktopLayoutPageLogic>().state;

  DesktopLayoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _leftTabBar(context),
        VerticalDivider(width: 1, color: UIConfig.layoutDividerColor(context)),
        Expanded(
          child: _buildDoubleColumn(context),
        ),
      ],
    );
  }

  Widget _leftTabBar(BuildContext context) {
    return Material(
      child: Container(
        width: UIConfig.desktopLeftTabBarWidth,
        color: UIConfig.backGroundColor(context),
        child: GetBuilder<DesktopLayoutPageLogic>(
          id: logic.tabBarId,
          builder: (_) => ScrollConfiguration(
            behavior: UIConfig.scrollBehaviourWithoutScrollBarWithMouse,
            child: ListView.builder(
              controller: state.leftTabBarScrollController,
              itemCount: state.icons.length,
              itemExtent: UIConfig.desktopLeftTabBarItemHeight,
              itemBuilder: _tabBarIcon,
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabBarIcon(BuildContext context, int index) {
    return MouseRegion(
      onEnter: (_) => logic.updateHoveringTabIndex(index),
      onExit: (_) => logic.updateHoveringTabIndex(null),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: state.selectedTabIndex == index ? Border(left: BorderSide(width: 3, color: UIConfig.desktopLeftTabIconColor(context))) : null,
                ),
                child: IconButton(
                  onPressed: () => logic.handleTapTabBarButton(index),
                  icon: state.selectedTabIndex == index ? state.icons[index].selectedIcon : state.icons[index].unselectedIcon,
                  color: UIConfig.desktopLeftTabIconColor(context),
                ),
              ),
            ),
          ),
          SizedBox(
            height: UIConfig.desktopLeftTabBarTextHeight,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                child: state.hoveringTabIndex != index
                    ? null
                    : Text(
                        state.icons[index].name.name.tr,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoubleColumn(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConfig.backGroundColor(context),
      body: ResizableContainer(
        direction: Axis.horizontal,
        controller: logic.resizableController,
        children: [
          ResizableChild(
            child: _leftColumn(),
            size: ResizableSize.ratio(windowService.leftColumnWidthRatio),
            minSize: 100,
          ),
          ResizableChild(
            child: _rightColumn(),
            size: ResizableSize.ratio(1 - windowService.leftColumnWidthRatio),
            minSize: 100,
          ),
        ],
        divider: ResizableDivider(
          thickness: 1.5,
          color: UIConfig.layoutDividerColor(context),
        ),
      ),
    );
  }

  Widget _leftColumn() {
    return Navigator(
      key: Get.nestedKey(left),
      observers: [GetObserver(null, leftRouting)],
      onGenerateInitialRoutes: (_, __) => [
        GetPageRoute(
          settings: const RouteSettings(name: Routes.desktopHome),
          page: () => DesktopHomePage(),
          popGesture: false,
          transition: Transition.fadeIn,
          showCupertinoParallax: false,
        ),
      ],
      onGenerateRoute: (settings) {
        Get.routing.args = settings.arguments;
        Get.parameters = Get.routeTree.matchRoute(settings.name!).parameters;
        return GetPageRoute(
          settings: settings,

          /// setting name may include path params
          page: Routes.pages.firstWhere((page) => settings.name!.split('?')[0] == page.name).page,

          popGesture: preferenceSetting.enableSwipeBackGesture.isTrue,
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 150),
        );
      },
    );
  }

  Widget _rightColumn() {
    return Navigator(
      key: Get.nestedKey(right),
      observers: [GetObserver(null, rightRouting)],
      onGenerateInitialRoutes: (_, __) => [
        GetPageRoute(
          settings: const RouteSettings(name: Routes.blank),
          page: () => const BlankPage(),
          popGesture: false,
          transition: Transition.fadeIn,
          showCupertinoParallax: false,
        ),
      ],
      onGenerateRoute: (settings) {
        Get.routing.args = settings.arguments;
        Get.parameters = Get.routeTree.matchRoute(settings.name!).parameters;
        return GetPageRoute(
          settings: settings,

          /// setting name may include path params
          page: Routes.pages.firstWhere((page) => settings.name!.split('?')[0] == page.name).page,

          /// do not use swipe back in tablet layout!
          popGesture: false,
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 150),
          showCupertinoParallax: false,
        );
      },
    );
  }
}
