import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/theme_config.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/get_logic_extension.dart';
import 'package:skana_ehentai/src/pages/setting/style/theme_color/preview_page/detail_preview_page.dart';
import 'package:skana_ehentai/src/setting/style_setting.dart';
import 'package:skana_ehentai/src/utils/route_util.dart';
import 'package:skana_ehentai/src/utils/toast_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

class SettingThemeColorPage extends StatefulWidget {
  const SettingThemeColorPage({super.key});

  @override
  State<SettingThemeColorPage> createState() => _SettingThemeColorPageState();
}

class _SettingThemeColorPageState extends State<SettingThemeColorPage> {
  Brightness selectedBrightness = styleSetting.currentBrightness();

  @override
  Widget build(BuildContext context) {
    ThemeData previewThemeData = selectedBrightness == Brightness.light
        ? ThemeConfig.theme(Brightness.light)
        : ThemeConfig.theme(Brightness.dark);

    return Theme(
      data: previewThemeData,
      child: Scaffold(
        appBar: AppBar(centerTitle: true, title: Text('preview'.tr)),
        body: DetailPreviewPage(),
        bottomNavigationBar: _buildBottomAppBar(),
      ),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      color: UIConfig.toastTextColor(context),
      height: 150,
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MoonEhButton.md(
                  icon: selectedBrightness == Brightness.light
                      ? BootstrapIcons.sun_fill
                      : BootstrapIcons.moon_fill,
                  size: 30,
                  onTap: () {
                    setState(() => selectedBrightness =
                        selectedBrightness == Brightness.light
                            ? Brightness.dark
                            : Brightness.light);
                  },
                ),
                MoonEhButton.md(
                  icon: BootstrapIcons.circle_fill,
                  color: selectedBrightness == Brightness.light
                      ? styleSetting.lightThemeColor.value
                      : styleSetting.darkThemeColor.value,
                  size: 30,
                  onTap: () async {
                    Color? newColor = await Get.dialog(
                      _ColorSettingDialog(
                        initialColor: selectedBrightness == Brightness.light
                            ? styleSetting.lightThemeColor.value
                            : styleSetting.darkThemeColor.value,
                        resetColor: selectedBrightness == Brightness.light
                            ? UIConfig.defaultLightThemeColor
                            : UIConfig.defaultDarkThemeColor,
                      ),
                    );

                    if (newColor == null) {
                      return;
                    }

                    if (selectedBrightness == Brightness.light) {
                      styleSetting.saveLightThemeColor(newColor);
                      Get.rootController.theme =
                          ThemeConfig.theme(Brightness.light);
                    } else {
                      styleSetting.saveDarkThemeColor(newColor);
                      Get.rootController.darkTheme =
                          ThemeConfig.theme(Brightness.dark);
                    }

                    if (selectedBrightness ==
                        styleSetting.currentBrightness()) {
                      Get.rootController.updateSafely();
                    }

                    setState(() {});
                    toast('success'.tr);
                  },
                ),
              ],
            ),
          ),
          Text('themeColorSettingHint'.tr).subHeader(),
        ],
      ),
    );
  }
}

class _ColorSettingDialog extends StatefulWidget {
  final Color initialColor;
  final Color resetColor;

  const _ColorSettingDialog(
      {required this.initialColor, required this.resetColor});

  @override
  State<_ColorSettingDialog> createState() => _ColorSettingDialogState();
}

class _ColorSettingDialogState extends State<_ColorSettingDialog> {
  late Color selectedColor;

  @override
  void initState() {
    selectedColor = widget.initialColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context: context,
      title: "",
      contentWidget: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ColorPicker(
          color: selectedColor,
          pickersEnabled: const <ColorPickerType, bool>{
            ColorPickerType.both: true,
            ColorPickerType.primary: false,
            ColorPickerType.accent: false,
            ColorPickerType.bw: false,
            ColorPickerType.custom: false,
            ColorPickerType.wheel: true,
          },
          pickerTypeLabels: <ColorPickerType, String>{
            ColorPickerType.both: 'preset'.tr,
            ColorPickerType.wheel: 'custom'.tr,
          },
          enableTonalPalette: true,
          showColorCode: true,
          colorCodeHasColor: true,
          enableOpacity: true,
          materialNameTextStyle:
              Get.context?.moonTheme?.tokens.typography.heading.text12,
          colorNameTextStyle:
              Get.context?.moonTheme?.tokens.typography.heading.text12,
          pickerTypeTextStyle:
              Get.context?.moonTheme?.tokens.typography.heading.text12,
          colorCodeTextStyle:
              Get.context?.moonTheme?.tokens.typography.heading.text16,
          width: 30,
          height: 30,
          columnSpacing: 12,
          onColorChanged: (Color color) {
            selectedColor = color;
          },
        ),
      ),
      actions: [
        outlinedButton(label: 'cancel'.tr, onPressed: backRoute),
        filledButton(
          label: 'reset'.tr,
          onPressed: () {
            setState(() => selectedColor = widget.resetColor);
          },
        ),
        filledButton(
          label: 'OK'.tr,
          onPressed: () {
            backRoute(result: selectedColor);
          },
        )
      ],
    );
  }
}
