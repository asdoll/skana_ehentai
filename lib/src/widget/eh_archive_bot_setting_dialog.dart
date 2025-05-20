import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';
import 'package:telegram/telegram.dart';

import '../setting/archive_bot_setting.dart';
import '../utils/route_util.dart';

class EHArchiveBotSettingDialog extends StatefulWidget {
  final String? apiAddress;
  final String? apiKey;
  final bool useProxy;

  const EHArchiveBotSettingDialog({super.key, required this.apiAddress, required this.apiKey, required this.useProxy});

  @override
  State<EHArchiveBotSettingDialog> createState() => _EHArchiveBotSettingDialogState();
}

class _EHArchiveBotSettingDialogState extends State<EHArchiveBotSettingDialog> {
  final TextEditingController _apiAddressController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  late bool _useProxy;

  @override
  void initState() {
    if(widget.apiAddress != null) {
      _apiAddressController.text = widget.apiAddress!;
    }
    if(widget.apiKey != null) {
      _apiKeyController.text = widget.apiKey!;
    }
    _useProxy = widget.useProxy;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context: context,
      title: 'apiSetting'.tr,
      actions: [
        MoonEhButton.md(
          icon: BootstrapIcons.telegram,
          size: 30,
          onTap: () {
            Telegram.joinChannel(inviteLink: 'https://t.me/EH_ArBot');
          },
        ),
        outlinedButton(onPressed: backRoute, label: 'cancel'.tr),
        filledButton(
          onPressed: () {
            setStateSafely(() {
              archiveBotSetting.saveAllConfig(
                _apiAddressController.text.isBlank! ? null : _apiAddressController.text,
                _apiKeyController.text.isBlank! ? null : _apiKeyController.text,
                _useProxy,
              );
              backRoute(result: true);
            });
          },
          label: 'OK'.tr,
        ),
      ],
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            minLeadingWidth: 40,
            leading: Text('apiAddress'.tr).small(),
            title: MoonTextInput(
              enabled: !_useProxy,
              controller: _apiAddressController,
              trailing: _apiAddressController.text.isEmpty
                    ? null
                    : MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          child: moonIcon(icon: BootstrapIcons.x),
                          onTap: () {
                            setStateSafely(_apiAddressController.clear);
                          },
                        ),
                      ),
              onChanged: (String value) {
                setStateSafely(() {});
              },
            ),
          ),
          ListTile(
            minLeadingWidth: 40,
            leading: Text('apiKey'.tr).small(),
            title: MoonTextInput(
              controller: _apiKeyController,
              trailing: _apiKeyController.text.isEmpty
                    ? null
                    : MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          child: moonIcon(icon: BootstrapIcons.x),
                          onTap: () {
                            setStateSafely(_apiKeyController.clear);
                          },
                        ),
                      ),
              onChanged: (String value) {
                setStateSafely(() {});
              },
            ),
          ),
          ListTile(
            minLeadingWidth: 40,
            leading: Text('useProxyServer'.tr).small(),
            title: MoonSwitch(
              value: _useProxy,
              onChanged: (bool value) async {
                setStateSafely(() {
                  _useProxy = value;
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
