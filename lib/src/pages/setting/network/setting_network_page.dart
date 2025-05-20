import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/setting/network_setting.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../../../routes/routes.dart';
import '../../../utils/route_util.dart';
import '../../../utils/text_input_formatter.dart';
import '../../../utils/toast_util.dart';

class SettingNetworkPage extends StatelessWidget {
  final TextEditingController proxyAddressController = TextEditingController(text: networkSetting.proxyAddress.value);
  final TextEditingController connectTimeoutController = TextEditingController(text: networkSetting.connectTimeout.value.toString());
  final TextEditingController receiveTimeoutController = TextEditingController(text: networkSetting.receiveTimeout.value.toString());

  SettingNetworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'networkSetting'.tr),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.only(top: 16),
          children: [
            _buildEnableDomainFronting(),
            _buildProxyAddress(),
            _buildPageCacheMaxAge(),
            _buildCacheImageExpireDuration(),
            _buildConnectTimeout(context),
            _buildReceiveTimeout(context),
          ],
        ).withListTileTheme(context),
      ),
    );
  }

  Widget _buildEnableDomainFronting() {
    return moonListTile(
      title: 'enableDomainFronting'.tr,
      subtitle: 'bypassSNIBlocking'.tr,
      trailing: Switch(
        value: networkSetting.enableDomainFronting.value,
        onChanged: networkSetting.saveEnableDomainFronting,
      ),
    );
  }

  Widget _buildProxyAddress() {
    return moonListTile(
      title: 'proxyAddress'.tr,
      trailing: MoonEhButton.md(onTap: () => toRoute(Routes.proxy), icon: Icons.keyboard_arrow_right),
      onTap: () => toRoute(Routes.proxy),
    );
  }

  Widget _buildPageCacheMaxAge() {
    return moonListTile(
      title: 'pageCacheMaxAge'.tr,
      subtitle: 'pageCacheMaxAgeHint'.tr,
      trailing: popupMenuButton<Duration>(
        itemBuilder: (context) => [
          PopupMenuItem(value: Duration(minutes: 1), child: Text('1m'.tr).small()),
          PopupMenuItem(value: Duration(minutes: 10), child: Text('10m'.tr).small()),
          PopupMenuItem(value: Duration(hours: 1), child: Text('1h'.tr).small()),
          PopupMenuItem(value: Duration(days: 1), child: Text('1d'.tr).small()),
          PopupMenuItem(value: Duration(days: 3), child: Text('3d'.tr).small()),
        ],
        onSelected: (Duration value) => networkSetting.savePageCacheMaxAge(value),
        initialValue: networkSetting.pageCacheMaxAge.value,
        child: IgnorePointer(
          child: filledButton(
            onPressed: () {},
            label: networkSetting.pageCacheMaxAge.value == Duration(minutes: 1)
                ? '1m'.tr
                : networkSetting.pageCacheMaxAge.value == Duration(minutes: 10)
                    ? '10m'.tr
                    : networkSetting.pageCacheMaxAge.value == Duration(hours: 1)
                        ? '1h'.tr
                        : networkSetting.pageCacheMaxAge.value == Duration(days: 1)
                            ? '1d'.tr
                            : '3d'.tr,
          ),
        ),
      ),
    );
  }

  Widget _buildCacheImageExpireDuration() {
    return moonListTile(
      title: 'cacheImageExpireDuration'.tr,
      subtitle: 'cacheImageExpireDurationHint'.tr,
      trailing: popupMenuButton<Duration>(
        itemBuilder: (context) => [
          PopupMenuItem(value: Duration(days: 1), child: Text('1d'.tr).small()),
          PopupMenuItem(value: Duration(days: 2), child: Text('2d'.tr).small()),
          PopupMenuItem(value: Duration(days: 3), child: Text('3d'.tr).small()),
          PopupMenuItem(value: Duration(days: 5), child: Text('5d'.tr).small()),
          PopupMenuItem(value: Duration(days: 7), child: Text('7d'.tr).small()),
          PopupMenuItem(value: Duration(days: 14), child: Text('14d'.tr).small()),
          PopupMenuItem(value: Duration(days: 30), child: Text('30d'.tr).small()),
        ],
        onSelected: (Duration value) => networkSetting.saveCacheImageExpireDuration(value),
        initialValue: networkSetting.cacheImageExpireDuration.value,
        child: IgnorePointer(
          child: filledButton(
            onPressed: () {},
            label: networkSetting.cacheImageExpireDuration.value == Duration(days: 1)
                ? '1d'.tr
                : networkSetting.cacheImageExpireDuration.value == Duration(days: 2)
                    ? '2d'.tr
                  : networkSetting.cacheImageExpireDuration.value == Duration(days: 3)
                      ? '3d'.tr
                      : networkSetting.cacheImageExpireDuration.value == Duration(days: 5)
                          ? '5d'.tr
                          : networkSetting.cacheImageExpireDuration.value == Duration(days: 7)
                              ? '7d'.tr
                              : networkSetting.cacheImageExpireDuration.value == Duration(days: 14)
                                  ? '14d'.tr
                                  : '30d'.tr,
          ),
        ),
      ),
    );
  }

  Widget _buildConnectTimeout(BuildContext context) {
    return moonListTile(
      title: 'connectTimeout'.tr,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            child: MoonTextInput(
              controller: connectTimeoutController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              textInputSize: MoonTextInputSize.sm,
              
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                IntRangeTextInputFormatter(minValue: 0),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('ms', style: UIConfig.settingPageListTileTrailingTextStyle(context)).small(),
          MoonEhButton.md(
            color: UIConfig.resumePauseButtonColor(context),
            onTap: () {
              int? value = int.tryParse(connectTimeoutController.value.text);
              if (value == null) {
                return;
              }
              networkSetting.saveConnectTimeout(value);
              toast('saveSuccess'.tr);
            },
            icon: BootstrapIcons.check2,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiveTimeout(BuildContext context) {
    return moonListTile(
      title: 'receiveTimeout'.tr,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            child: MoonTextInput(
              controller: receiveTimeoutController,
              textAlign: TextAlign.center,
              textInputSize: MoonTextInputSize.sm,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                IntRangeTextInputFormatter(minValue: 0),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('ms', style: UIConfig.settingPageListTileTrailingTextStyle(context)).small(),
          MoonEhButton.md(
            color: UIConfig.resumePauseButtonColor(context),
            onTap: () {
              int? value = int.tryParse(receiveTimeoutController.value.text);
              if (value == null) {
                return;
              }
              networkSetting.saveReceiveTimeout(value);
              toast('saveSuccess'.tr);
            },
            icon: BootstrapIcons.check2,
          ),
        ],
      ),
    );
  }
}
