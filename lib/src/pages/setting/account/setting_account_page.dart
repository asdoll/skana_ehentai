import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/setting/user_setting.dart';
import '../../../routes/routes.dart';
import '../../../utils/route_util.dart';
import '../../../widget/eh_log_out_dialog.dart';

class SettingAccountPage extends StatelessWidget {
  const SettingAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('accountSetting'.tr)),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.only(top: 12),
          children: [
            if (!userSetting.hasLoggedIn()) _buildLogin(),
            if (userSetting.hasLoggedIn()) ...[
              _buildLogout(context).marginOnly(bottom: 12),
              _buildCookiePage(),
            ],
          ],
        ).withListTileTheme(context),
      ),
    );
  }

  Widget _buildLogin() {
    return ListTile(
      title: Text('login'.tr),
      trailing: IconButton(onPressed: () => toRoute(Routes.login), icon: const Icon(Icons.keyboard_arrow_right)),
      onTap: () => toRoute(Routes.login),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return ListTile(
      title: Text('${'youHaveLoggedInAs'.tr}${userSetting.nickName.value ?? userSetting.userName.value!}'),
      onTap: () => Get.dialog(const LogoutDialog()),
      trailing: IconButton(
        icon: const Icon(Icons.logout),
        color: UIConfig.alertColor(context),
        onPressed: () => Get.dialog(const LogoutDialog()),
      ),
    );
  }

  Widget _buildCookiePage() {
    return ListTile(
      title: Text('showCookie'.tr),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () => toRoute(Routes.cookie),
    );
  }
}
