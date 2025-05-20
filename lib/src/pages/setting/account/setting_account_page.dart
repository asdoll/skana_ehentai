import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/setting/user_setting.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';
import '../../../routes/routes.dart';
import '../../../utils/route_util.dart';
import '../../../widget/eh_log_out_dialog.dart';

class SettingAccountPage extends StatelessWidget {
  const SettingAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'accountSetting'.tr),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.only(top: 12),
          children: [
            if (!userSetting.hasLoggedIn()) _buildLogin(),
            if (userSetting.hasLoggedIn()) ...[
              _buildLogout(context),
              _buildCookiePage(),
            ],
          ],
        ).withListTileTheme(context),
      ),
    );
  }

  Widget _buildLogin() {
    return moonListTile(
      title: 'login'.tr,
      trailing: MoonEhButton.md(onTap: () => toRoute(Routes.login), icon: BootstrapIcons.chevron_right),
      onTap: () => toRoute(Routes.login),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return moonListTile(
      title: '${'youHaveLoggedInAs'.tr}${userSetting.nickName.value ?? userSetting.userName.value!}',
      onTap: () => Get.dialog(const LogoutDialog()),
      trailing: MoonEhButton.md(
        icon: BootstrapIcons.box_arrow_right,
        color: UIConfig.alertColor(context),
        onTap: () => Get.dialog(const LogoutDialog()),
      ),
    );
  }

  Widget _buildCookiePage() {
    return moonListTile(
      title: 'showCookie'.tr,
      trailing: MoonEhButton.md(onTap: () => toRoute(Routes.cookie), icon: BootstrapIcons.chevron_right),
      onTap: () => toRoute(Routes.cookie),
    );
  }
}
