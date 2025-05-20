import 'package:bootstrap_icons/bootstrap_icons.dart' show BootstrapIcons;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/pages/layout/mobile_v2/notification/tap_menu_button_notification.dart';
import 'package:skana_ehentai/src/routes/routes.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';
import '../../setting/user_setting.dart';
import '../../utils/route_util.dart';

class SettingPage extends StatelessWidget {
  final bool showMenuButton;

  const SettingPage({super.key, this.showMenuButton = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        title: 'setting'.tr,
        leading: showMenuButton
            ? NormalDrawerButton(
                onTap: () => TapMenuButtonNotification().dispatch(context),
              )
            : null,
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.only(top: 12),
          children: [
            moonListTile(
              leading: moonIcon(icon:BootstrapIcons.person),
              title: 'account'.tr,
              trailing: SizedBox(width: 25,height: 25),
              onTap: () => toRoute('${Routes.settingPrefix}account'),
            ),
            if (userSetting.hasLoggedIn())
              moonListTile(
              leading: moonIcon(icon:BootstrapIcons.emoji_laughing),
                title: 'EH'.tr,
                trailing: SizedBox(width: 25,height: 25),
                onTap: () => toRoute('${Routes.settingPrefix}EH'),
              ),
            moonListTile(
              leading: moonIcon(icon:BootstrapIcons.phone),
              title: 'style'.tr,
              trailing: SizedBox(width: 25,height: 25),
              onTap: () => toRoute('${Routes.settingPrefix}style'),
            ),
            moonListTile(
              leading: moonIcon(icon:BootstrapIcons.book),
              title: 'read'.tr,
              trailing: SizedBox(width: 25,height: 25),
              onTap: () => toRoute('${Routes.settingPrefix}read'),
            ),
            moonListTile(
              leading: moonIcon(icon:BootstrapIcons.star),
              title: 'preference'.tr,
              trailing: SizedBox(width: 25,height: 25),
              onTap: () => toRoute('${Routes.settingPrefix}preference'),
            ),
            moonListTile(
              leading: moonIcon(icon:BootstrapIcons.wifi),
              title: 'network'.tr,
              trailing: SizedBox(width: 25,height: 25),
              onTap: () => toRoute('${Routes.settingPrefix}network'),
            ),
            moonListTile(
              leading: moonIcon(icon:BootstrapIcons.download),
              title: 'download'.tr,
              trailing: SizedBox(width: 25,height: 25),
              onTap: () => toRoute('${Routes.settingPrefix}download'),
            ),
            moonListTile(
              leading: moonIcon(icon:BootstrapIcons.lightning_charge),
              title: 'performance'.tr,
              trailing: SizedBox(width: 25,height: 25),
              onTap: () => toRoute('${Routes.settingPrefix}performance'),
            ),
            moonListTile(
              leading: moonIcon(icon:BootstrapIcons.mouse),
              title: 'mouseWheel'.tr,
              trailing: SizedBox(width: 25,height: 25),
              onTap: () => toRoute('${Routes.settingPrefix}mouse_wheel'),
            ),
            moonListTile(
              leading: moonIcon(icon:BootstrapIcons.gear_wide),
              title: 'advanced'.tr,
              trailing: SizedBox(width: 25,height: 25),
              onTap: () => toRoute('${Routes.settingPrefix}advanced'),
            ),
            // ListTile(
            //   leading: const Icon(Icons.cloud),
            //   title: Text('cloud'.tr),
            //   onTap: () => toRoute(Routes.settingPrefix + 'cloud'),
            // ),
            moonListTile(
              leading: moonIcon(icon:BootstrapIcons.fingerprint),
              title: 'security'.tr,
              trailing: SizedBox(width: 25,height: 25),
              onTap: () => toRoute('${Routes.settingPrefix}security'),
            ),
            moonListTile(
              leading: moonIcon(icon:BootstrapIcons.info),
              title: 'about'.tr,
              trailing: SizedBox(width: 25,height: 25),
              onTap: () => toRoute('${Routes.settingPrefix}about'),
            ),
          ],
        ),
      ),
    );
  }
}
