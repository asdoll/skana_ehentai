import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/extension/list_extension.dart';
import 'package:skana_ehentai/src/pages/gallerys/dashboard/dashboard_page_logic.dart';
import 'package:skana_ehentai/src/pages/gallerys/dashboard/simple/simple_dashboard_page_logic.dart';
import 'package:skana_ehentai/src/pages/search/mobile_v2/search_page_mobile_v2.dart';

import '../../../mixin/double_tap_to_refresh_state_mixin.dart';
import '../../../model/tab_bar_icon.dart';
import '../../../routes/routes.dart';
import '../../../setting/preference_setting.dart';
import '../../download/download_base_page.dart';
import '../../favorite/favorite_page.dart';
import '../../favorite/favorite_page_logic.dart';
import '../../gallerys/dashboard/dashboard_page.dart';
import '../../gallerys/dashboard/simple/simple_dashboard_page.dart';
import '../../history/history_page.dart';
import '../../history/history_page_logic.dart';
import '../../popular/popular_page.dart';
import '../../popular/popular_page_logic.dart';
import '../../ranklist/ranklist_page.dart';
import '../../ranklist/ranklist_page_logic.dart';
import '../../setting/setting_page.dart';
import '../../watched/watched_page.dart';
import '../../watched/watched_page_logic.dart';

class MobileLayoutPageV2State with DoubleTapToRefreshStateMixin {
  late final List<TabBarIcon> icons;

  int selectedDrawerTabIndex = 0;
  int selectedNavigationIndex = 0;

  ScrollController scrollController = ScrollController();

  /// selectedNavigationIndex's order in [shouldRender] tabs
  int get selectedDrawerTabOrder => icons.where((icon) => icon.shouldRender).toList().indexWhere((icon) => icon.name == icons[selectedDrawerTabIndex].name);

  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  MobileLayoutPageV2State() {
    icons = [
      TabBarIcon(
        name: TabBarIconNameEnum.home,
        routeName: Routes.dashboard,
        selectedIcon: const Icon(BootstrapIcons.house_fill),
        unselectedIcon: const Icon(BootstrapIcons.house),
        page: () => preferenceSetting.simpleDashboardMode.isTrue ? const SimpleDashboardPage() : const DashboardPage(),
        scrollController: () => preferenceSetting.simpleDashboardMode.isTrue
            ? Get.find<SimpleDashboardPageLogic>().scroll2TopState.scrollController
            : Get.find<DashboardPageLogic>().scroll2TopState.scrollController,
        shouldRender: false,
      ),
      TabBarIcon(
        name: TabBarIconNameEnum.search,
        routeName: Routes.mobileV2Search,
        selectedIcon: const Icon(BootstrapIcons.search, shadows: [Shadow(blurRadius: 2)]),
        unselectedIcon: const Icon(BootstrapIcons.search),
        page: () => SearchPageMobileV2(),
        shouldRender: false,
        enterNewRoute: true,
      ),
      TabBarIcon(
        name: TabBarIconNameEnum.popular,
        routeName: Routes.popular,
        selectedIcon: const Icon(BootstrapIcons.fire),
        unselectedIcon: const Icon(BootstrapIcons.fire),
        page: () => PopularPage(showMenuButton: true, showTitle: true, name: 'popular'.tr),
        scrollController: () => Get.find<PopularPageLogic>().scroll2TopState.scrollController,
        shouldRender: false,
      ),
      TabBarIcon(
        name: TabBarIconNameEnum.ranklist,
        routeName: Routes.ranklist,
        selectedIcon: const Icon(BootstrapIcons.bar_chart, shadows: [Shadow(blurRadius: 2)]),
        unselectedIcon: const Icon(BootstrapIcons.bar_chart),
        page: () => const RanklistPage(showMenuButton: true, showTitle: true),
        scrollController: () => Get.find<RanklistPageLogic>().scroll2TopState.scrollController,
        shouldRender: false,
      ),
      TabBarIcon(
        name: TabBarIconNameEnum.favorite,
        routeName: Routes.favorite,
        selectedIcon: const Icon(BootstrapIcons.heart_fill),
        unselectedIcon: const Icon(BootstrapIcons.heart),
        page: () => FavoritePage(showMenuButton: true, showTitle: true, name: 'favorite'.tr),
        scrollController: () => Get.find<FavoritePageLogic>().scroll2TopState.scrollController,
        shouldRender: false,
      ),
      TabBarIcon(
        name: TabBarIconNameEnum.watched,
        routeName: Routes.watched,
        selectedIcon: const Icon(BootstrapIcons.eye_fill),
        unselectedIcon: const Icon(BootstrapIcons.eye),
        page: () => WatchedPage(showMenuButton: true, showTitle: true, name: 'watched'.tr),
        scrollController: () => Get.find<WatchedPageLogic>().scroll2TopState.scrollController,
        shouldRender: false,
      ),
      TabBarIcon(
        name: TabBarIconNameEnum.history,
        routeName: Routes.history,
        selectedIcon: const Icon(BootstrapIcons.clock_history, shadows: [Shadow(blurRadius: 2)]),
        unselectedIcon: const Icon(BootstrapIcons.clock_history),
        page: () => HistoryPage(showMenuButton: true, showTitle: true, name: 'history'.tr),
        scrollController: () => Get.find<HistoryPageLogic>().scroll2TopState.scrollController,
        shouldRender: false,
      ),
      TabBarIcon(
        name: TabBarIconNameEnum.download,
        routeName: Routes.download,
        selectedIcon: const Icon(BootstrapIcons.cloud_download_fill),
        unselectedIcon: const Icon(BootstrapIcons.cloud_download),
        page: () => const DownloadPage(),
        shouldRender: false,
      ),
      TabBarIcon(
        name: TabBarIconNameEnum.setting,
        routeName: Routes.setting,
        selectedIcon: const Icon(BootstrapIcons.gear_fill),
        unselectedIcon: const Icon(BootstrapIcons.gear),
        page: () => const SettingPage(showMenuButton: true),
        shouldRender: false,
      ),
    ];

    selectedDrawerTabIndex = icons.firstIndexWhereOrNull((icon) => icon.name == preferenceSetting.defaultTab.value) ?? 0;
    icons[selectedDrawerTabIndex].shouldRender = true;
  }
}
