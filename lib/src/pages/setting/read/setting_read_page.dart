import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/setting/read_setting.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../../../service/log.dart';
import '../../../utils/text_input_formatter.dart';
import '../../../utils/toast_util.dart';

class SettingReadPage extends StatelessWidget {
  final TextEditingController imageRegionWidthRatioController =
      TextEditingController(
          text: readSetting.imageRegionWidthRatio.value.toString());
  final TextEditingController gestureRegionWidthRatioController =
      TextEditingController(
          text: readSetting.gestureRegionWidthRatio.value.toString());
  final TextEditingController imageMaxKilobytesController =
      TextEditingController(
          text: readSetting.maxImageKilobyte.value.toString());

  SettingReadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('readSetting'.tr)),
      body: Obx(
        () => SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(top: 16),
            children: [
              if (GetPlatform.isMobile || GetPlatform.isWindows)
                _buildEnableImmersiveMode().center(),
              _buildKeepScreenAwake().center(),
              if (GetPlatform.isMobile)
                _buildEnableCustomReadBrightness().center(),
              if (GetPlatform.isMobile) _buildCustomReadBrightness().center(),
              _buildShowThumbnails().center(),
              _buildShowScrollBar().center(),
              _buildShowStatusInfo().center(),
              if (GetPlatform.isAndroid)
                _buildEnablePageTurnByVolumeKeys().center(),
              _buildEnablePageTurnAnime().center(),
              _buildEnableDoubleTapToScaleUp().center(),
              _buildEnableTapDragToScaleUp().center(),
              _buildEnableBottomMenu().center(),
              _buildReverseTurnPageDirection().center(),
              _buildDisableTurnPageOnTap().center(),
              _buildEnableImageMaxKilobytes().center(),
              if (readSetting.enableMaxImageKilobyte.isTrue)
                _buildImageMaxKilobytes(context)
                    .fadeIn(const Key('imageMaxKilobytes'))
                    .center(),
              _buildGestureRegionWidthRatio(context).center(),
              if (GetPlatform.isDesktop) _buildUseThirdPartyViewer().center(),
              if (GetPlatform.isDesktop) _buildThirdPartyViewerPath().center(),
              if (GetPlatform.isMobile) _buildDeviceDirection().center(),
              _buildReadDirection().center(),
              if (GetPlatform.isMobile &&
                  readSetting.readDirection.value ==
                      ReadDirection.top2bottomList)
                _buildNotchOptimization().center(),
              if (readSetting.readDirection.value ==
                  ReadDirection.top2bottomList)
                _buildImageRegionWidthRatio(context).center(),
              if (readSetting.isInListReadDirection)
                _buildPreloadDistanceInOnlineMode(context)
                    .fadeIn(const Key('preloadDistanceInOnlineMode'))
                    .center(),
              if (readSetting.isInListReadDirection)
                _buildPreloadDistanceInLocalMode(context)
                    .fadeIn(const Key('preloadDistanceInLocalMode'))
                    .center(),
              if (!readSetting.isInListReadDirection)
                _buildPreloadPageCount()
                    .fadeIn(const Key('preloadPageCount'))
                    .center(),
              if (!readSetting.isInListReadDirection)
                _buildPreloadPageCountInLocalMode()
                    .fadeIn(const Key('preloadPageCountInLocalMode'))
                    .center(),
              if (readSetting.isInDoubleColumnReadDirection)
                _buildDisplayFirstPageAlone()
                    .fadeIn(const Key('displayFirstPageAloneGlobally'))
                    .center(),
              if (readSetting.isInListReadDirection)
                _buildAutoModeStyle()
                    .fadeIn(const Key('autoModeStyle'))
                    .center(),
              if (readSetting.isInListReadDirection)
                _buildTurnPageMode().fadeIn(const Key('turnPageMode')).center(),
              _buildImageSpace().center(),
            ],
          ).withListTileTheme(context),
        ),
      ),
    );
  }

  Widget _buildEnableImmersiveMode() {
    return moonListTile(
      title: 'enableImmersiveMode'.tr,
      subtitle: GetPlatform.isMobile
          ? 'enableImmersiveHint'.tr
          : 'enableImmersiveHint4Windows'.tr,
      trailing: MoonSwitch(
        value: readSetting.enableImmersiveMode.value,
        onChanged: readSetting.saveEnableImmersiveMode,
      ),
    );
  }

  Widget _buildKeepScreenAwake() {
    return moonListTile(
      title: 'keepScreenAwakeWhenReading'.tr,
      trailing: MoonSwitch(
        value: readSetting.keepScreenAwakeWhenReading.value,
        onChanged: readSetting.saveKeepScreenAwakeWhenReading,
      ),
    );
  }

  Widget _buildEnableCustomReadBrightness() {
    return moonListTile(
      title: 'enableCustomReadBrightness'.tr,
      trailing: MoonSwitch(
        value: readSetting.enableCustomReadBrightness.value,
        onChanged: readSetting.saveEnableCustomReadBrightness,
      ),
    );
  }

  Widget _buildShowThumbnails() {
    return moonListTile(
      title: 'showThumbnails'.tr,
      trailing: MoonSwitch(
        value: readSetting.showThumbnails.value,
        onChanged: readSetting.saveShowThumbnails,
      ),
    );
  }

  Widget _buildShowScrollBar() {
    return moonListTile(
      title: 'showScrollBar'.tr,
      trailing: MoonSwitch(
        value: readSetting.showScrollBar.value,
        onChanged: readSetting.saveShowScrollBar,
      ),
    );
  }

  Widget _buildCustomReadBrightness() {
    return moonListTileWidgets(label:Row(
      children: [
        const SizedBox(width: 16),
        moonIcon(icon: BootstrapIcons.brightness_high),
        const SizedBox(width: 16),
        Text(readSetting.customBrightness.value.toString()).small(),
        Expanded(
          child: Slider(
            value: readSetting.customBrightness.value.toDouble(),
            activeColor: UIConfig.primaryColor(Get.context!),
            onChanged: (double value) =>
                readSetting.saveCustomBrightness(value.toInt()),
            min: 0,
            max: 100,
          ),
        ),
        const SizedBox(width: 16),
      ],
    ));
  }

  Widget _buildImageSpace() {
    return moonListTile(
      title: 'spaceBetweenImages'.tr,
      trailing: popupMenuButton<int>(
        child: IgnorePointer(
          child: filledButton(
            onPressed: () {},
            label: readSetting.imageSpace.value.toString(),
          ),
        ),
        initialValue: readSetting.imageSpace.value,
        onSelected: (int? newValue) => readSetting.saveImageSpace(newValue!),
        itemBuilder: (context) => [
          PopupMenuItem(value: 0, child: Text('0'.tr).small()),
          PopupMenuItem(value: 2, child: Text('2'.tr).small()),
          PopupMenuItem(value: 4, child: Text('4'.tr).small()),
          PopupMenuItem(value: 6, child: Text('6'.tr).small()),
          PopupMenuItem(value: 8, child: Text('8'.tr).small()),
          PopupMenuItem(value: 10, child: Text('10'.tr).small()),
        ],
      ).marginOnly(right: 12),
    );
  }

  Widget _buildShowStatusInfo() {
    return moonListTile(
      title: 'showStatusInfo'.tr,
      trailing: MoonSwitch(
        value: readSetting.showStatusInfo.value,
        onChanged: readSetting.saveShowStatusInfo,
      ),
    );
  }

  Widget _buildEnablePageTurnByVolumeKeys() {
    return moonListTile(
      title: 'enablePageTurnByVolumeKeys'.tr,
      trailing: MoonSwitch(
        value: readSetting.enablePageTurnByVolumeKeys.value,
        onChanged: readSetting.saveEnablePageTurnByVolumeKeys,
      ),
    );
  }

  Widget _buildEnablePageTurnAnime() {
    return moonListTile(
      title: 'enablePageTurnAnime'.tr,
      trailing: MoonSwitch(
        value: readSetting.enablePageTurnAnime.value,
        onChanged: readSetting.saveEnablePageTurnAnime,
      ),
    );
  }

  Widget _buildEnableDoubleTapToScaleUp() {
    return moonListTile(
      title: 'enableDoubleTapToScaleUp'.tr,
      trailing: MoonSwitch(
        value: readSetting.enableDoubleTapToScaleUp.value,
        onChanged: readSetting.saveEnableDoubleTapToScaleUp,
      ),
    );
  }

  Widget _buildEnableTapDragToScaleUp() {
    return moonListTile(
      title: 'enableTapDragToScaleUp'.tr,
      trailing: MoonSwitch(
        value: readSetting.enableTapDragToScaleUp.value,
        onChanged: readSetting.saveEnableTapDragToScaleUp,
      ),
    );
  }

  Widget _buildEnableBottomMenu() {
    return moonListTile(
      title: 'enableBottomMenu'.tr,
      trailing: MoonSwitch(
        value: readSetting.enableBottomMenu.value,
        onChanged: readSetting.saveEnableBottomMenu,
      ),
    );
  }

  Widget _buildReverseTurnPageDirection() {
    return moonListTile(
      title: 'reverseTurnPageDirection'.tr,
      trailing: MoonSwitch(
        value: readSetting.reverseTurnPageDirection.value,
        onChanged: readSetting.saveReverseTurnPageDirection,
      ),
    );
  }

  Widget _buildDisableTurnPageOnTap() {
    return moonListTile(
      title: 'disablePageTurningOnTap'.tr,
      trailing: MoonSwitch(
        value: readSetting.disablePageTurningOnTap.value,
        onChanged: readSetting.saveDisablePageTurningOnTap,
      ),
    );
  }

  Widget _buildEnableImageMaxKilobytes() {
    return moonListTile(
      title: 'enableImageMaxKilobytes'.tr,
      trailing: MoonSwitch(
        value: readSetting.enableMaxImageKilobyte.value,
        onChanged: readSetting.saveEnableMaxImageKilobyte,
      ),
    );
  }

  Widget _buildImageMaxKilobytes(BuildContext context) {
    return moonListTile(
      title: 'imageMaxKilobytes'.tr,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            child: MoonTextInput(
              controller: imageMaxKilobytesController,
              textAlign: TextAlign.center,
              textInputSize: MoonTextInputSize.sm,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                IntRangeTextInputFormatter(minValue: 1)
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('KB',
                  style: UIConfig.settingPageListTileTrailingTextStyle(context))
              .small(),
          MoonEhButton.md(
            icon: BootstrapIcons.check2,
            onTap: () {
              int? value = int.tryParse(imageMaxKilobytesController.value.text);
              if (value == null) {
                return;
              }
              readSetting.saveMaxImageKilobyte(value);
              toast('saveSuccess'.tr);
            },
            color: UIConfig.resumePauseButtonColor(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceDirection() {
    return moonListTile(
      title: 'deviceOrientation'.tr,
      trailing: popupMenuButton<DeviceDirection>(
        child: IgnorePointer(
          child: filledButton(
            onPressed: () {},
            label: readSetting.deviceDirection.value == DeviceDirection.followSystem
                ? 'followSystem'.tr
                : readSetting.deviceDirection.value == DeviceDirection.landscape
                    ? 'landscape'.tr
                    : 'portrait'.tr,
          ),
        ),
        initialValue: readSetting.deviceDirection.value,
        onSelected: (DeviceDirection? newValue) =>
            readSetting.saveDeviceDirection(newValue!),
        itemBuilder: (context) => [
          PopupMenuItem(
              value: DeviceDirection.followSystem,
              child: Text('followSystem'.tr).small()),
          PopupMenuItem(
              value: DeviceDirection.landscape,
              child: Text('landscape'.tr).small()),
          PopupMenuItem(
              value: DeviceDirection.portrait,
              child: Text('portrait'.tr).small()),
        ],
      ).marginOnly(right: 12),
    );
  }

  Widget _buildReadDirection() {
    return moonListTile(
      title: 'readDirection'.tr,
      trailing: popupMenuButton<ReadDirection>(
        child: IgnorePointer(
          child: filledButton(
            onPressed: () {},
            label: readSetting.readDirection.value.name.tr,
          ),
        ),
        initialValue: readSetting.readDirection.value,
        onSelected: (ReadDirection? newValue) =>
            readSetting.saveReadDirection(newValue!),
        itemBuilder: (context) => ReadDirection.values
            .map((e) => PopupMenuItem(value: e, child: Text(e.name.tr).small()))
            .toList(),
      ).marginOnly(right: 12),
    );
  }

  Widget _buildNotchOptimization() {
    return moonListTile(
      title: 'notchOptimization'.tr,
      subtitle: 'notchOptimizationHint'.tr,
      trailing: MoonSwitch(
        value: readSetting.notchOptimization.value,
        onChanged: readSetting.saveNotchOptimization,
      ),
    );
  }

  Widget _buildImageRegionWidthRatio(BuildContext context) {
    return moonListTile(
      title: 'imageRegionWidthRatio'.tr,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            child: MoonTextInput(
              controller: imageRegionWidthRatioController,
              keyboardType: TextInputType.number,
              textInputSize: MoonTextInputSize.sm,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                IntRangeTextInputFormatter(minValue: 1, maxValue: 100),
              ],
              onSubmitted: (_) {
                _saveImageRegionWidthRatio();
              },
            ),
          ),
          const SizedBox(width: 8),
          const Text('%').small(),
          MoonEhButton.md(
            icon: BootstrapIcons.check2,
            onTap: _saveImageRegionWidthRatio,
            color: UIConfig.resumePauseButtonColor(context),
          ),
        ],
      ),
    );
  }

  void _saveImageRegionWidthRatio() {
    int? value = int.tryParse(imageRegionWidthRatioController.value.text);
    if (value == null) {
      return;
    }
    readSetting.saveImageRegionWidthRatio(value);
    toast('saveSuccess'.tr);
  }

  Widget _buildGestureRegionWidthRatio(BuildContext context) {
    return moonListTile(
      title: 'gestureRegionWidthRatio'.tr,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            child: MoonTextInput(
              controller: gestureRegionWidthRatioController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              textInputSize: MoonTextInputSize.sm,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                IntRangeTextInputFormatter(minValue: 0, maxValue: 100),
              ],
              onSubmitted: (_) {
                _saveGestureRegionWidthRatio();
              },
            ),
          ),
          const SizedBox(width: 8),
          const Text('%').small(),
          MoonEhButton.md(
            icon: BootstrapIcons.check2,
            onTap: _saveGestureRegionWidthRatio,
            color: UIConfig.resumePauseButtonColor(context),
          ),
        ],
      ),
    );
  }

  void _saveGestureRegionWidthRatio() {
    int? value = int.tryParse(gestureRegionWidthRatioController.value.text);
    if (value == null) {
      return;
    }

    if (value <= 0) {
      value = 1;
    }
    if (value >= 100) {
      value = 99;
    }

    readSetting.saveGestureRegionWidthRatio(value);
    toast('saveSuccess'.tr);
  }

  Widget _buildUseThirdPartyViewer() {
    return moonListTile(
      title: 'useThirdPartyViewer'.tr,
      trailing: MoonSwitch(
        value: readSetting.useThirdPartyViewer.value,
        onChanged: readSetting.saveUseThirdPartyViewer,
      ),
    );
  }

  Widget _buildThirdPartyViewerPath() {
    return moonListTile(
      title: 'thirdPartyViewerPath'.tr,
      subtitle: readSetting.thirdPartyViewerPath.value,
      trailing: IgnorePointer(
          child: MoonEhButton.md(
        onTap: () {},
        icon: BootstrapIcons.chevron_right,
      )),
      onTap: () async {
        FilePickerResult? result;
        try {
          result = await FilePicker.platform.pickFiles();
        } on Exception catch (e) {
          log.error('Pick 3-rd party viewer failed', e);
          log.uploadError(e);
        }

        if (result == null || result.files.single.path == null) {
          return;
        }

        readSetting.saveThirdPartyViewerPath(result.files.single.path!);
      },
    );
  }

  Widget _buildPreloadDistanceInOnlineMode(BuildContext context) {
    return moonListTile(
      title: 'preloadDistanceInOnlineMode'.tr,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          popupMenuButton<int>(
            child: IgnorePointer(
              child: filledButton(
                onPressed: () {},
                label: readSetting.preloadDistance.value.toString(),
              ),
            ),
            initialValue: readSetting.preloadDistance.value,
            onSelected: (int? newValue) {
              readSetting.savePreloadDistance(newValue!);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 0, child: Text('0').small()),
              PopupMenuItem(value: 1, child: Text('1').small()),
              PopupMenuItem(value: 2, child: Text('2').small()),
              PopupMenuItem(value: 3, child: Text('3').small()),
              PopupMenuItem(value: 5, child: Text('5').small()),
              PopupMenuItem(value: 8, child: Text('8').small()),
              PopupMenuItem(value: 10, child: Text('10').small()),
            ],
          ),
        ],
      ).marginOnly(right: 12),
    );
  }

  Widget _buildPreloadDistanceInLocalMode(BuildContext context) {
    return moonListTile(
      title: 'preloadDistanceInLocalMode'.tr,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          popupMenuButton<int>(
            child: IgnorePointer(
              child: filledButton(
                onPressed: () {},
                label: readSetting.preloadDistanceLocal.value.toString(),
              ),
            ),
            initialValue: readSetting.preloadDistanceLocal.value,
            onSelected: (int? newValue) {
              readSetting.savePreloadDistanceLocal(newValue!);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 0, child: Text('0').small()),
              PopupMenuItem(value: 1, child: Text('1').small()),
              PopupMenuItem(value: 2, child: Text('2').small()),
              PopupMenuItem(value: 3, child: Text('3').small()),
              PopupMenuItem(value: 5, child: Text('5').small()),
              PopupMenuItem(value: 8, child: Text('8').small()),
              PopupMenuItem(value: 10, child: Text('10').small()),
            ],
          ),
        ],
      ).marginOnly(right: 12),
    );
  }

  Widget _buildPreloadPageCount() {
    return moonListTile(
      title: 'preloadPageCount'.tr,
      trailing: popupMenuButton<int>(
        child: IgnorePointer(
          child: filledButton(
            onPressed: () {},
            label: readSetting.preloadPageCount.value.toString(),
          ),
        ),
        initialValue: readSetting.preloadPageCount.value,
        onSelected: (int? newValue) {
          readSetting.savePreloadPageCount(newValue!);
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: 0, child: Text('0').small()),
          PopupMenuItem(value: 1, child: Text('1').small()),
          PopupMenuItem(value: 2, child: Text('2').small()),
          PopupMenuItem(value: 3, child: Text('3').small()),
          PopupMenuItem(value: 5, child: Text('5').small()),
          PopupMenuItem(value: 8, child: Text('8').small()),
          PopupMenuItem(value: 10, child: Text('10').small()),
        ],
      ).marginOnly(right: 12),
    );
  }

  Widget _buildPreloadPageCountInLocalMode() {
    return moonListTile(
      title: 'preloadPageCountInLocalMode'.tr,
      trailing: popupMenuButton<int>(
        child: IgnorePointer(
          child: filledButton(
            onPressed: () {},
            label: readSetting.preloadPageCountLocal.value.toString(),
          ),
        ),
        initialValue: readSetting.preloadPageCountLocal.value,
        onSelected: (int? newValue) {
          readSetting.savePreloadPageCountLocal(newValue!);
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: 0, child: Text('0').small()),
          PopupMenuItem(value: 1, child: Text('1').small()),
          PopupMenuItem(value: 2, child: Text('2').small()),
          PopupMenuItem(value: 3, child: Text('3').small()),
          PopupMenuItem(value: 5, child: Text('5').small()),
          PopupMenuItem(value: 8, child: Text('8').small()),
          PopupMenuItem(value: 10, child: Text('10').small()),
        ],
      ).marginOnly(right: 12),
    );
  }

  Widget _buildDisplayFirstPageAlone() {
    return moonListTile(
      title: 'displayFirstPageAloneGlobally'.tr,
      trailing: MoonSwitch(
        value: readSetting.displayFirstPageAlone.value,
        onChanged: readSetting.saveDisplayFirstPageAlone,
      ),
    );
  }

  Widget _buildAutoModeStyle() {
    return moonListTile(
      title: 'autoModeStyle'.tr,
      trailing: popupMenuButton<AutoModeStyle>(
        child: IgnorePointer(
          child: filledButton(
            onPressed: () {},
            label: readSetting.autoModeStyle.value.name.tr,
          ),
        ),
        initialValue: readSetting.autoModeStyle.value,
        onSelected: (AutoModeStyle? newValue) =>
            readSetting.saveAutoModeStyle(newValue!),
        itemBuilder: (context) => [
          PopupMenuItem(
              value: AutoModeStyle.scroll,
              child: Text('scroll'.tr).small()),
          PopupMenuItem(
              value: AutoModeStyle.turnPage,
              child: Text('turnPage'.tr).small()),
        ],
      ).marginOnly(right: 12),
    );
  }

  Widget _buildTurnPageMode() {
    return moonListTile(
      title: 'turnPageMode'.tr,
      subtitle: 'turnPageModeHint'.tr,
      trailing: popupMenuButton<TurnPageMode>(
        child: IgnorePointer(
          child: filledButton(
            onPressed: () {},
            label: readSetting.turnPageMode.value.name.tr,
          ),
        ),
        initialValue: readSetting.turnPageMode.value,
        onSelected: (TurnPageMode? newValue) =>
            readSetting.saveTurnPageMode(newValue!),
        itemBuilder: (context) => [
          PopupMenuItem(value: TurnPageMode.image, child: Text('image'.tr).small()),
          PopupMenuItem(
              value: TurnPageMode.screen,
              child: Text('screen'.tr).small()),
          PopupMenuItem(
              value: TurnPageMode.adaptive,
              child: Text('adaptive'.tr).small()),
        ],
      ).marginOnly(right: 12),
    );
  }
}
