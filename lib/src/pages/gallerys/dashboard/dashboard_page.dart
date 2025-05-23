import 'package:bootstrap_icons/bootstrap_icons.dart' show BootstrapIcons;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/pages/base/base_page.dart';
import 'package:skana_ehentai/src/pages/gallerys/dashboard/dashboard_page_state.dart';
import 'package:skana_ehentai/src/routes/routes.dart';
import 'package:skana_ehentai/src/utils/route_util.dart';
import 'package:skana_ehentai/src/widget/eh_wheel_speed_controller.dart';
import 'package:skana_ehentai/src/widget/eh_dashboard_card.dart';
import 'package:skana_ehentai/src/widget/icons.dart';
import 'package:skana_ehentai/src/widget/loading_state_indicator.dart';

import '../../../config/ui_config.dart';
import '../../../utils/widgetplugin.dart';
import '../../layout/mobile_v2/mobile_layout_page_v2_state.dart';
import '../../layout/mobile_v2/notification/tap_tab_bat_button_notification.dart';
import 'dashboard_page_logic.dart';

/// For mobile v2 layout
class DashboardPage extends BasePage {
  const DashboardPage({super.key})
      : super(
          showMenuButton: true,
          showTitle: true,
          showScroll2TopButton: true,
        );

  @override
  String get name => 'home'.tr;

  @override
  DashboardPageLogic get logic => Get.put<DashboardPageLogic>(DashboardPageLogic(), permanent: true);

  @override
  DashboardPageState get state => Get.find<DashboardPageLogic>().state;

  @override
  List<Widget> buildAppBarActions() {
    return [
      MoonEhButton.md(
        icon: BootstrapIcons.search,
        onTap: () => toRoute(Routes.mobileV2Search),
      ),
      MoonEhButton.md(
        icon: BootstrapIcons.three_dots,
        onTap: () => MobileLayoutPageV2State.scaffoldKey.currentState?.openEndDrawer(),
      ),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    return GetBuilder<DashboardPageLogic>(
      id: logic.bodyId,
      builder: (_) => NotificationListener<UserScrollNotification>(
        onNotification: logic.onUserScroll,
        child: EHWheelSpeedController(
          controller: state.scrollController,
          child: CustomScrollView(
            key: state.pageStorageKey,
            controller: state.scrollController,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            scrollBehavior: UIConfig.scrollBehaviourWithScrollBarWithMouse,
            slivers: [
              buildPullDownIndicator(),
              _buildRanklistDesc(),
              _buildRanklist(),
              _buildPopularListDesc(),
              _buildPopular(),
              _buildGalleryDesc(context),
              _buildGalleryBody(context),
              super.buildLoadMoreIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildPullDownIndicator() {
    return CupertinoSliverRefreshControl(
      refreshTriggerPullDistance: UIConfig.refreshTriggerPullDistance,
      onRefresh: logic.handleRefreshTotalPage,
      builder: buildRefreshIndicator,
    );
  }

  Widget _buildRanklistDesc() {
    return const SliverPadding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 4),
      sliver: SliverToBoxAdapter(
        child: _RankListDesc(),
      ),
    );
  }

  Widget _buildRanklist() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: UIConfig.dashboardCardSize,
        child: GetBuilder<DashboardPageLogic>(
          id: logic.ranklistId,
          builder: (_) => LoadingStateIndicator(
            loadingState: state.ranklistLoadingState,
            errorTapCallback: logic.loadRanklist,
            successWidgetBuilder: () => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: state.ranklistGallerys.length,
              itemBuilder: (_, index) => EHDashboardCard(gallery: state.ranklistGallerys[index], badge: _getRanklistBadge(index)),
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              cacheExtent: 2000,
            ).enableMouseDrag(withScrollBar: false).fadeIn(),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularListDesc() {
    return const SliverPadding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 8),
      sliver: SliverToBoxAdapter(
        child: _PopularListDesc(),
      ),
    );
  }

  Widget _buildPopular() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: UIConfig.dashboardCardSize,
        child: GetBuilder<DashboardPageLogic>(
          id: logic.popularListId,
          builder: (_) => LoadingStateIndicator(
            loadingState: state.popularLoadingState,
            errorTapCallback: logic.loadPopular,
            successWidgetBuilder: () => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: state.popularGallerys.length,
              itemBuilder: (_, index) => EHDashboardCard(gallery: state.popularGallerys[index]),
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              cacheExtent: 2000,
            ).enableMouseDrag(withScrollBar: false).fadeIn(),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryDesc(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      sliver: SliverToBoxAdapter(
        child: _GalleryListDesc(
          actions: [
            MoonButton.icon(
              icon: Icon(BootstrapIcons.gear, size: 20),
              onTap: logic.handleTapFilterButton,
            ),
            MoonButton.icon(
              icon: Icon(BootstrapIcons.arrow_clockwise, size: 22),
              onTap: logic.handleClearAndRefresh,
            ).paddingTop(1),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryBody(BuildContext context) {
    return GetBuilder<DashboardPageLogic>(
      id: logic.galleryListId,
      builder: (_) => buildGalleryCollection(context),
    );
  }

  String? _getRanklistBadge(int index) {
    switch (index) {
      case 0:
        return '🥇';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return null;
    }
  }
}

class _RankListDesc extends StatelessWidget {
  const _RankListDesc();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆 ', style: TextStyle(fontSize: 16)),
            Text('ranklistBoard'.tr).header().paddingTop(3),
          ],
        ),
        const Expanded(child: SizedBox()),
        TextButton(
          style: TextButton.styleFrom(padding: const EdgeInsets.only(left: 12), visualDensity: const VisualDensity(vertical: -4)),
          onPressed: () => const TapTabBarButtonNotification(Routes.ranklist).dispatch(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'seeAll'.tr,
                style: TextStyle(color: UIConfig.dashboardPageSeeAllTextColor(context), fontSize: 12, fontWeight: FontWeight.w400, height: 1),
              ).subHeader(),
              Icon(Icons.arrow_forward_ios, color: UIConfig.dashboardPageArrowButtonColor(context), size: 16),
            ],
          ),
        )
      ],
    );
  }
}

class _PopularListDesc extends StatelessWidget {
  const _PopularListDesc();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🥵 ', style: TextStyle(fontSize: 16)),
            Text('popular'.tr).header().paddingTop(3),
          ],
        ),
        const Expanded(child: SizedBox()),
        TextButton(
          style: TextButton.styleFrom(padding: const EdgeInsets.only(left: 12), visualDensity: const VisualDensity(vertical: -4)),
          onPressed: () => const TapTabBarButtonNotification(Routes.popular).dispatch(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'seeAll'.tr,
                style: TextStyle(color: UIConfig.dashboardPageSeeAllTextColor(context), fontSize: 12, fontWeight: FontWeight.w400, height: 1),
              ).subHeader(),
              Icon(Icons.arrow_forward_ios, color: UIConfig.dashboardPageArrowButtonColor(context), size: 16),
            ],
          ),
        )
      ],
    );
  }
}

class _GalleryListDesc extends StatelessWidget {
  final List<Widget> actions;

  const _GalleryListDesc({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎁 ', style: TextStyle(fontSize: 16)),
            Text('newest'.tr).header().paddingTop(3),
          ],
        ),
        const Expanded(child: SizedBox()),
        Row(mainAxisSize: MainAxisSize.min, children: actions)
      ],
    );
  }
}
