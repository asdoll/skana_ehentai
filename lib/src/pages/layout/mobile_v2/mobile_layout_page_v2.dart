import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:collection/collection.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/pages/download/download_base_page.dart';
import 'package:skana_ehentai/src/pages/layout/mobile_v2/mobile_layout_page_v2_logic.dart';
import 'package:skana_ehentai/src/pages/layout/mobile_v2/mobile_layout_page_v2_state.dart';
import 'package:skana_ehentai/src/pages/layout/mobile_v2/notification/tap_menu_button_notification.dart';
import 'package:skana_ehentai/src/pages/search/quick_search/quick_search_page.dart';
import 'package:skana_ehentai/src/pages/setting/setting_page.dart';
import 'package:skana_ehentai/src/routes/routes.dart';
import 'package:skana_ehentai/src/setting/user_setting.dart';
import 'package:skana_ehentai/src/utils/route_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/will_pop_interceptor.dart';
import '../../../setting/preference_setting.dart';
import '../../../widget/eh_log_out_dialog.dart';
import 'notification/tap_tab_bat_button_notification.dart';

class MobileLayoutPageV2 extends StatelessWidget {
  final MobileLayoutPageV2Logic logic =
      Get.put(MobileLayoutPageV2Logic(), permanent: true);
  final MobileLayoutPageV2State state =
      Get.find<MobileLayoutPageV2Logic>().state;

  MobileLayoutPageV2({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => WillPopInterceptor(
        child: Scaffold(
          key: MobileLayoutPageV2State.scaffoldKey,
          drawerEdgeDragWidth:
              preferenceSetting.drawerGestureEdgeWidth.value.toDouble(),
          drawer: buildLeftDrawer(context),
          drawerEnableOpenDragGesture:
              preferenceSetting.enableLeftMenuDrawerGesture.isTrue,
          endDrawer: buildRightDrawer(),
          endDrawerEnableOpenDragGesture:
              preferenceSetting.enableQuickSearchDrawerGesture.isTrue,
          body: buildBody(),
          bottomNavigationBar: preferenceSetting.hideBottomBar.isTrue
              ? null
              : buildBottomNavigationBar(context),
        ),
      ),
    );
  }

  Widget buildLeftDrawer(BuildContext context) {
    return MoonDrawer(
      width: preferenceSetting.locale.value.languageCode == "zh" ||
              preferenceSetting.locale.value.languageCode == "ko"
          ? 140
          : preferenceSetting.locale.value.languageCode == "en"
              ? 160
              : 200,
      child: GetBuilder<MobileLayoutPageV2Logic>(
        id: logic.tabBarId,
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 120),
              Expanded(
                child: ScrollConfiguration(
                  behavior: UIConfig.leftDrawerPhysicsBehaviour,
                  child: ListView.builder(
                    key: const PageStorageKey('leftDrawer'),
                    controller: state.scrollController,
                    itemCount: state.icons.length,
                    cacheExtent: 1000,
                    itemBuilder: (context, index) => MoonMenuItem(
                      label: Text(state.icons[index].name.name.tr,
                              style: state.selectedDrawerTabIndex == index
                                  ? const TextStyle(color: Colors.white)
                                  : null)
                          .header(),
                      leading: Transform.translate(
                          offset: const Offset(0, -2),
                          child: Icon(state.icons[index].unselectedIcon.icon,
                              size: 22,
                              color: state.selectedDrawerTabIndex == index
                                  ? Colors.white
                                  : null)),
                      backgroundColor: state.selectedDrawerTabIndex == index
                          ? UIConfig.mobileDrawerSelectedTileColor(context)
                          : Colors.transparent,
                      onTap: () => logic.handleTapTabBarButton(index),
                    ).marginOnly(right: 8, top: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRightDrawer() {
    return Drawer(width: 278, child: QuickSearchPage());
  }

  Widget buildBottomNavigationBar(BuildContext context) {
    return GetBuilder<MobileLayoutPageV2Logic>(
      id: logic.bottomNavigationBarId,
      builder: (_) => Theme(
        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
        child: NavigationBar(
          backgroundColor: UIConfig.downloadPageCardColor(context),
          selectedIndex: state.selectedNavigationIndex,
          onDestinationSelected: logic.handleTapNavigationBarButton,
          height: 56,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          indicatorColor: UIConfig.primaryColor(context).withValues(alpha: 0.5),
          destinations: [
            NavigationDestination(
                selectedIcon: moonIcon(icon: BootstrapIcons.house_fill),
                icon: moonIcon(icon: BootstrapIcons.house),
                label: 'home'.tr),
            NavigationDestination(
                selectedIcon: moonIcon(icon: BootstrapIcons.download),
                icon: moonIcon(icon: BootstrapIcons.download),
                label: 'download'.tr),
            NavigationDestination(
                selectedIcon: moonIcon(icon: BootstrapIcons.gear_fill),
                icon: moonIcon(icon: BootstrapIcons.gear),
                label: 'setting'.tr),
          ],
        ),
      ),
    );
  }

  Widget buildBody() {
    return NotificationListener<TapTabBarButtonNotification>(
      child: NotificationListener<TapMenuButtonNotification>(
        child: GetBuilder<MobileLayoutPageV2Logic>(
          id: logic.bodyId,
          builder: (_) => Stack(
            children: [
              Offstage(
                  offstage: state.selectedNavigationIndex != 0,
                  child: buildHomeBody()),
              Offstage(
                  offstage: state.selectedNavigationIndex != 1,
                  child: const DownloadPage()),
              Offstage(
                  offstage: state.selectedNavigationIndex != 2,
                  child: const SettingPage()),
            ],
          ),
        ),
        onNotification: (_) {
          MobileLayoutPageV2State.scaffoldKey.currentState?.openDrawer();
          return true;
        },
      ),
      onNotification: (notification) {
        logic.handleTapTabBarButtonByRouteName(notification.routeName);
        return true;
      },
    );
  }

  /// use [shouldRender] to implement lazy load with [Offstage]
  Widget buildHomeBody() {
    return Stack(
      children: state.icons
          .where((icon) => icon.shouldRender)
          .mapIndexed(
            (index, icon) => Offstage(
              offstage: state.selectedDrawerTabOrder != index,
              child: icon.page.call(),
            ),
          )
          .toList(),
    );
  }
}

class EHUserAvatar extends StatelessWidget {
  const EHUserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      child: Obx(
        () => ListTile(
          leading: GestureDetector(
            child: CircleAvatar(
              radius: 32,
              backgroundColor: UIConfig.loginAvatarBackGroundColor(context),
              foregroundImage: userSetting.avatarImgUrl.value != null
                  ? ExtendedNetworkImageProvider(
                      userSetting.avatarImgUrl.value!,
                      cache: true)
                  : null,
              child: Icon(
                  userSetting.hasLoggedIn()
                      ? Icons.face_retouching_natural
                      : Icons.face,
                  color: UIConfig.loginAvatarForeGroundColor(context),
                  size: 32),
            ),
          ),
          title: Text(userSetting.nickName.value ??
              userSetting.userName.value ??
              'tap2Login'.tr),
          onTap: () {
            if (!userSetting.hasLoggedIn()) {
              toRoute(Routes.login);
              return;
            }
            Get.dialog(const LogoutDialog());
          },
        ),
      ),
    );
  }
}
