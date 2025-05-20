import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/pages/gallerys/dashboard/simple/simple_dashboard_page_logic.dart';
import 'package:skana_ehentai/src/pages/gallerys/dashboard/simple/simple_dashboard_page_state.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../../../../routes/routes.dart';
import '../../../../utils/route_util.dart';
import '../../../base/base_page.dart';
import '../../../layout/mobile_v2/mobile_layout_page_v2_state.dart';

/// For mobile v2 layout
class SimpleDashboardPage extends BasePage {
  const SimpleDashboardPage({super.key})
      : super(
          showMenuButton: true,
          showTitle: true,
          showScroll2TopButton: true,
        );

  @override
  String get name => 'home'.tr;

  @override
  SimpleDashboardPageLogic get logic =>
      Get.put<SimpleDashboardPageLogic>(SimpleDashboardPageLogic(),
          permanent: true);

  @override
  SimpleDashboardPageState get state =>
      Get.find<SimpleDashboardPageLogic>().state;

  @override
  List<Widget> buildAppBarActions() {
    return [
      MoonEhButton.md(
          icon: BootstrapIcons.gear,
          onTap: logic.handleTapFilterButton),
      MoonEhButton.md(
          icon: BootstrapIcons.search,
          onTap: () => toRoute(Routes.mobileV2Search)),
      MoonEhButton.md(
          icon: BootstrapIcons.three_dots,
          onTap: () => MobileLayoutPageV2State.scaffoldKey.currentState
              ?.openEndDrawer()),
    ];
  }
}
