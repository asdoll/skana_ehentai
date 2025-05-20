import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/setting/mouse_setting.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../../../utils/text_input_formatter.dart';
import '../../../utils/toast_util.dart';

class SettingMouseWheelPage extends StatelessWidget {
  const SettingMouseWheelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'mouseWheelSetting'.tr),
      body: Obx(() {
        TextEditingController wheelScrollSpeedController = TextEditingController(text: mouseSetting.wheelScrollSpeed.value.toString());

        return ListView(
          padding: const EdgeInsets.only(top: 16),
          children: [
            moonListTile(
              title: 'wheelScrollSpeed'.tr,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 50,
                    child: MoonTextInput(
                      controller: wheelScrollSpeedController,
                      textAlign: TextAlign.center,
                      textInputSize: MoonTextInputSize.sm,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'\d|\.')), DoubleRangeTextInputFormatter(minValue: 0)],
                      onSubmitted: (_) {
                        double? value = double.tryParse(wheelScrollSpeedController.value.text);
                        if (value == null) {
                          return;
                        }
                        mouseSetting.saveWheelScrollSpeed(value);
                        toast('saveSuccess'.tr);
                      },
                    ),
                  ),
                  MoonEhButton.md(
                    icon: BootstrapIcons.check2,
                    onTap: () {
                      double? value = double.tryParse(wheelScrollSpeedController.value.text);
                      if (value == null) {
                        return;
                      }
                      mouseSetting.saveWheelScrollSpeed(value);
                      toast('saveSuccess'.tr);
                    },
                    color: UIConfig.resumePauseButtonColor(context),
                  ),
                ],
              ),
            ),
          ],
        ).withListTileTheme(context);
      }),
    );
  }
}
