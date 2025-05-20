import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/setting/security_setting.dart';
import 'package:skana_ehentai/src/utils/toast_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/eh_app_password_setting_dialog.dart';

class SettingSecurityPage extends StatelessWidget {
  const SettingSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'securitySetting'.tr),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.only(top: 16),
          children: [
            if (GetPlatform.isMobile) _buildEnableBlurBackgroundApp(),
            _buildEnablePasswordAuth(),
            if (securitySetting.supportBiometricAuth) _buildEnableBiometricAuth(),
            if (GetPlatform.isMobile) _buildEnableAuthOnResume(),
            if (GetPlatform.isAndroid) _buildHideImagesInAlbum(),
          ],
        ).withListTileTheme(context),
      ),
    );
  }

  Widget _buildEnableBlurBackgroundApp() {
    return moonListTile(
      title: 'enableBlurBackgroundApp'.tr,
      trailing: MoonSwitch(
        value: securitySetting.enableBlur.value,
        onChanged: securitySetting.saveEnableBlur,
      ),
    );
  }

  Widget _buildEnablePasswordAuth() {
    return moonListTile(
      title: 'enablePasswordAuth'.tr,
      trailing: MoonSwitch(
        value: securitySetting.enablePasswordAuth.value,
        onChanged: (value) async {
          if (value) {
            String? password = await Get.dialog(const EHAppPasswordSettingDialog());

          if (password != null) {
            securitySetting.savePassword(password);
            toast('success'.tr);
          } else {
            return;
          }
        }

        securitySetting.saveEnablePasswordAuth(value);
      },
      ),
    );
  }

  Widget _buildEnableBiometricAuth() {
    return moonListTile(
      title: 'enableBiometricAuth'.tr,
      trailing: MoonSwitch(
        value: securitySetting.enableBiometricAuth.value,
        onChanged: securitySetting.saveEnableBiometricAuth,
      ),
    );
  }

  Widget _buildEnableAuthOnResume() {
    return moonListTile(
      title: 'enableAuthOnResume'.tr,
      subtitle: 'enableAuthOnResumeHints'.tr,
      trailing: MoonSwitch(
        value: securitySetting.enableAuthOnResume.value,
        onChanged: securitySetting.saveEnableAuthOnResume,
      ),
    );
  }

  Widget _buildHideImagesInAlbum() {
    return moonListTile(
      title: 'hideImagesInAlbum'.tr,
      trailing: MoonSwitch(
        value: securitySetting.hideImagesInAlbum.value,
        onChanged: securitySetting.saveHideImagesInAlbum,
      ),
    );
  }
}
