import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/utils/toast_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../../../../setting/network_setting.dart';

class SettingProxyPage extends StatefulWidget {
  const SettingProxyPage({super.key});

  @override
  State<SettingProxyPage> createState() => _SettingProxyPageState();
}

class _SettingProxyPageState extends State<SettingProxyPage> {
  JProxyType proxyType = networkSetting.proxyType.value;
  String proxyAddress = networkSetting.proxyAddress.value;
  String? proxyUsername = networkSetting.proxyUsername.value;
  String? proxyPassword = networkSetting.proxyPassword.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        title: 'proxySetting'.tr,
        actions: [
          MoonEhButton.md(
            icon: BootstrapIcons.save,
            onTap: () {
              networkSetting.saveProxy(
                  proxyType, proxyAddress, proxyUsername, proxyPassword);
              toast('success'.tr);
            },
          ),
        ],
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.only(top: 16),
          children: [
            _buildProxyType(),
            _buildProxyAddress(),
            _buildProxyUsername(),
            _buildProxyPassword(),
          ],
        ),
      ).withListTileTheme(context),
    );
  }

  Widget _buildProxyType() {
    return moonListTile(
      title: 'proxyType'.tr,
      trailing: popupMenuButton<JProxyType>(
        itemBuilder: (context) => [
          PopupMenuItem(
              value: JProxyType.system, child: Text('systemProxy'.tr).small()),
          PopupMenuItem(value: JProxyType.http, child: Text('httpProxy'.tr).small()),
          PopupMenuItem(
              value: JProxyType.socks5, child: Text('socks5Proxy'.tr).small()),
          PopupMenuItem(
              value: JProxyType.socks4, child: Text('socks4Proxy'.tr).small()),
          PopupMenuItem(
              value: JProxyType.direct, child: Text('directProxy'.tr).small()),
        ],
        onSelected: (JProxyType value) {
          proxyType = value;
          networkSetting.saveProxy(
              proxyType, proxyAddress, proxyUsername, proxyPassword);
        },
        initialValue: proxyType,
        child: IgnorePointer(
          child: filledButton(
            onPressed: () {},
            label: proxyType == JProxyType.system
                ? 'systemProxy'.tr
                : proxyType == JProxyType.direct
                    ? 'directProxy'.tr
                    : proxyType == JProxyType.http
                        ? 'httpProxy'.tr
                        : proxyType == JProxyType.socks5
                            ? 'socks5Proxy'.tr
                            : proxyType == JProxyType.socks4
                                ? 'socks4Proxy'.tr
                                : 'unknown'.tr,
          ),
        ),
      ),
    );
  }

  Widget _buildProxyAddress() {
    return moonListTile(
      title: 'address'.tr,
      trailing: SizedBox(
        width: 150,
        child: MoonTextInput(
          controller:
              TextEditingController(text: networkSetting.proxyAddress.value),
          textAlign: TextAlign.center,
          textInputSize: MoonTextInputSize.sm,
          onChanged: (String value) => proxyAddress = value,
          enabled: networkSetting.proxyType.value != JProxyType.system &&
              networkSetting.proxyType.value != JProxyType.direct,
        ),
      ),
      enabled: networkSetting.proxyType.value != JProxyType.system &&
          networkSetting.proxyType.value != JProxyType.direct,
    );
  }

  Widget _buildProxyUsername() {
    return moonListTile(
      title: 'userName'.tr,
      trailing: SizedBox(
        width: 150,
        child: MoonTextInput(
          controller:
              TextEditingController(text: networkSetting.proxyUsername.value),
          textAlign: TextAlign.center,
          textInputSize: MoonTextInputSize.sm,
          onChanged: (String value) => proxyUsername = value,
          enabled: networkSetting.proxyType.value != JProxyType.system &&
              networkSetting.proxyType.value != JProxyType.direct,
        ),
      ),
      enabled: networkSetting.proxyType.value != JProxyType.system &&
          networkSetting.proxyType.value != JProxyType.direct,
    );
  }

  Widget _buildProxyPassword() {
    return moonListTile(
      title: 'password'.tr,
      trailing: SizedBox(
        width: 150,
        child: MoonTextInput(
          controller:
              TextEditingController(text: networkSetting.proxyPassword.value),
          textAlign: TextAlign.center,
          textInputSize: MoonTextInputSize.sm,
          onChanged: (String value) => proxyPassword = value,
          obscureText: true,
          enabled: networkSetting.proxyType.value != JProxyType.system &&
              networkSetting.proxyType.value != JProxyType.direct,
        ),
      ),
      enabled: networkSetting.proxyType.value != JProxyType.system &&
          networkSetting.proxyType.value != JProxyType.direct,
    );
  }
}
