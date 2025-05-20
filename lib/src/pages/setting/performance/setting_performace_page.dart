import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../../../config/ui_config.dart';
import '../../../setting/performance_setting.dart';
import '../../../utils/text_input_formatter.dart';
import '../../../utils/toast_util.dart';

class SettingPerformancePage extends StatelessWidget {
  SettingPerformancePage({super.key});

  final TextEditingController maxGalleryNum4AnimationController = TextEditingController(text: performanceSetting.maxGalleryNum4Animation.value.toString());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'performanceSetting'.tr),
      body: ListView(
        padding: const EdgeInsets.only(top: 16),
        children: [
          _buildMaxGalleryNum4Animation(context),
        ],
      ).withListTileTheme(context),
    );
  }

  Widget _buildMaxGalleryNum4Animation(BuildContext context) {
    return moonListTile(
      title: 'maxGalleryNum4Animation'.tr,
      subtitle: 'maxGalleryNum4AnimationHint'.tr,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            child: MoonTextInput(
              controller: maxGalleryNum4AnimationController,
              keyboardType: TextInputType.number,
              textInputSize: MoonTextInputSize.sm,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                IntRangeTextInputFormatter(minValue: 0),
              ],
            ),
          ),
          MoonEhButton.md(
            icon: BootstrapIcons.check2,
            onTap: () {
              int? value = int.tryParse(maxGalleryNum4AnimationController.value.text);
              if (value == null) {
                return;
              }
              performanceSetting.setMaxGalleryNum4Animation(value);
              toast('saveSuccess'.tr);
            },
            color: UIConfig.resumePauseButtonColor(context),
          ),
        ],
      ),
    );
  }
}
