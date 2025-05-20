import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/setting/style_setting.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../../../model/jh_layout.dart';
import '../../../routes/routes.dart';
import '../../../utils/route_util.dart';

class SettingStylePage extends StatelessWidget {
  const SettingStylePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'styleSetting'.tr),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.only(top: 16),
          children: [
            _buildBrightness(),
            //_buildThemeColor(),
            _buildListMode(),
            if (styleSetting.isInWaterFlowListMode)
              _buildCrossAxisCountInWaterFallFlow().fadeIn(),
            _buildPageListMode(),
            _buildCrossAxisCountInGridDownloadPageForGroup(),
            _buildCrossAxisCountInGridDownloadPageForGallery(),
            _buildCrossAxisCountInDetailPage(),
            if (!styleSetting.isInWaterFlowListMode)
              _buildMoveCover2RightSide().fadeIn(),
            _buildLayout(context),
          ],
        ).withListTileTheme(context),
      ),
    );
  }

  Widget _buildBrightness() {
    return moonListTile(
      title: 'themeMode'.tr,
      trailing: popupMenuButton<ThemeMode>(
        child: IgnorePointer(
          child: filledButton(
              onPressed: () {},
              label: styleSetting.themeMode.value == ThemeMode.light
                  ? 'light'.tr
                  : styleSetting.themeMode.value == ThemeMode.dark
                      ? 'dark'.tr
                      : 'followSystem'.tr),
        ),
        onSelected: (ThemeMode? newValue) =>
            styleSetting.saveThemeMode(newValue!),
        itemBuilder: (context) => [
          PopupMenuItem(value: ThemeMode.light, child: Text('light'.tr).small()),
          PopupMenuItem(value: ThemeMode.dark, child: Text('dark'.tr).small()),
          PopupMenuItem(
              value: ThemeMode.system, child: Text('followSystem'.tr).small()),
        ],
      ),
    );
  }

  // Widget _buildThemeColor() {
  //   return moonListTile(
  //     title: 'themeColor'.tr,
  //     trailing: MoonEhButton.md(icon: BootstrapIcons.chevron_right,onTap: () => toRoute(Routes.themeColor)),
  //     onTap: () => toRoute(Routes.themeColor),
  //   );
  // }

  Widget _buildListMode() {
    return moonListTile(
      title: 'listStyle'.tr,
      trailing: popupMenuButton<ListMode>(
        initialValue: styleSetting.listMode.value,
        onSelected: (ListMode? newValue) =>
            styleSetting.saveListMode(newValue!),
        itemBuilder: (context) => [
          PopupMenuItem(value: ListMode.flat, child: Text('flat'.tr).small()),
          PopupMenuItem(
              value: ListMode.flatWithoutTags,
              child: Text('flatWithoutTags'.tr).small()),
          PopupMenuItem(
              value: ListMode.listWithTags,
              child: Text('listWithTags'.tr).small()),
          PopupMenuItem(
              value: ListMode.listWithoutTags,
              child: Text('listWithoutTags'.tr).small()),
          PopupMenuItem(
              value: ListMode.waterfallFlowSmall,
              child: Text('waterfallFlowSmall'.tr).small()),
          PopupMenuItem(
              value: ListMode.waterfallFlowMedium,
              child: Text('waterfallFlowMedium'.tr).small()),
          PopupMenuItem(
              value: ListMode.waterfallFlowBig,
              child: Text('waterfallFlowBig'.tr).small()),
        ],
        child: IgnorePointer(
          child: filledButton(
            label: styleSetting.listMode.value == ListMode.flat
                ? 'flat'.tr
                : styleSetting.listMode.value == ListMode.flatWithoutTags
                    ? 'flatWithoutTags'.tr
                    : styleSetting.listMode.value == ListMode.listWithTags
                        ? 'listWithTags'.tr
                        : styleSetting.listMode.value ==
                                ListMode.listWithoutTags
                            ? 'listWithoutTags'.tr
                            : styleSetting.listMode.value ==
                                    ListMode.waterfallFlowSmall
                                ? 'waterfallFlowSmall'.tr
                                : styleSetting.listMode.value ==
                                        ListMode.waterfallFlowMedium
                                    ? 'waterfallFlowMedium'.tr
                                    : 'waterfallFlowBig'.tr,
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  Widget _buildCrossAxisCountInWaterFallFlow() {
    return moonListTile(
      title: 'crossAxisCountInWaterFallFlow'.tr,
      trailing: dropdownButton<int?>(
          maxWidth: 60,
          minWidth: 60,
          show: styleSetting.crossAxisCountInWaterFallFlowMenu.value,
          onTapOutside: () =>
              styleSetting.crossAxisCountInWaterFallFlowMenu.value = false,
          content: [
            MoonMenuItem(
                label: Text('auto'.tr).small(),
                onTap: () =>
                    styleSetting.saveCrossAxisCountInWaterFallFlow(null)),
            MoonMenuItem(
                label: Text('2'.tr).small(),
                onTap: () => styleSetting.saveCrossAxisCountInWaterFallFlow(2)),
            MoonMenuItem(
                label: Text('3'.tr).small(),
                onTap: () => styleSetting.saveCrossAxisCountInWaterFallFlow(3)),
            MoonMenuItem(
                label: Text('4'.tr).small(),
                onTap: () => styleSetting.saveCrossAxisCountInWaterFallFlow(4)),
            MoonMenuItem(
                label: Text('5'.tr).small(),
                onTap: () => styleSetting.saveCrossAxisCountInWaterFallFlow(5)),
            MoonMenuItem(
                label: Text('6'.tr).small(),
                onTap: () => styleSetting.saveCrossAxisCountInWaterFallFlow(6)),
          ],
          child: filledButton(
              onPressed: () =>
                  styleSetting.crossAxisCountInWaterFallFlowMenu.toggle(),
              label: styleSetting.crossAxisCountInWaterFallFlow.value == null
                  ? 'auto'.tr
                  : styleSetting.crossAxisCountInWaterFallFlow.value
                      .toString()
                      .tr)),
    );
  }

  Widget _buildCrossAxisCountInGridDownloadPageForGroup() {
    return moonListTile(
      title: 'crossAxisCountInGridDownloadPageForGroup'.tr,
      trailing: dropdownButton<int?>(
          maxWidth: 60,
          minWidth: 60,
          show: styleSetting.crossAxisCountInGridDownloadPageForGroupMenu.value,
          onTapOutside: () => styleSetting
              .crossAxisCountInGridDownloadPageForGroupMenu.value = false,
          content: [
            MoonMenuItem(
                label: Text('auto'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInGridDownloadPageForGroup(null)),
            MoonMenuItem(
                label: Text('2'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInGridDownloadPageForGroup(2)),
            MoonMenuItem(
                label: Text('3'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInGridDownloadPageForGroup(3)),
            MoonMenuItem(
                label: Text('4'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInGridDownloadPageForGroup(4)),
            MoonMenuItem(
                label: Text('5'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInGridDownloadPageForGroup(5)),
            MoonMenuItem(
                label: Text('6'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInGridDownloadPageForGroup(6)),
          ],
          child: filledButton(
              onPressed: () => styleSetting
                  .crossAxisCountInGridDownloadPageForGroupMenu
                  .toggle(),
              label: styleSetting
                          .crossAxisCountInGridDownloadPageForGroup.value ==
                      null
                  ? 'auto'.tr
                  : styleSetting.crossAxisCountInGridDownloadPageForGroup.value
                      .toString()
                      .tr)),
    );
  }

  Widget _buildCrossAxisCountInGridDownloadPageForGallery() {
    return moonListTile(
      title: 'crossAxisCountInGridDownloadPageForGallery'.tr,
      trailing: dropdownButton<int?>(
          maxWidth: 60,
          minWidth: 60,
          show: styleSetting.crossAxisCountInGridDownloadPageForGalleryMenu.value,
          onTapOutside: () => styleSetting
              .crossAxisCountInGridDownloadPageForGalleryMenu.value = false,
          content: [
            MoonMenuItem(
                label: Text('auto'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInGridDownloadPageForGallery(null)),
            MoonMenuItem(
                label: Text('2'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInGridDownloadPageForGallery(2)),
            MoonMenuItem(
                label: Text('3'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInGridDownloadPageForGallery(3)),
            MoonMenuItem(
                label: Text('4'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInGridDownloadPageForGallery(4)),
            MoonMenuItem(
                label: Text('5'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInGridDownloadPageForGallery(5)),
            MoonMenuItem(
                label: Text('6'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInGridDownloadPageForGallery(6)),
          ],
          child: filledButton(
              onPressed: () => styleSetting
                  .crossAxisCountInGridDownloadPageForGalleryMenu
                  .toggle(),
              label: styleSetting
                          .crossAxisCountInGridDownloadPageForGallery.value ==
                      null
                  ? 'auto'.tr
                  : styleSetting.crossAxisCountInGridDownloadPageForGallery.value
                      .toString()
                      .tr)),
    );
  }

  Widget _buildCrossAxisCountInDetailPage() {
    return moonListTile(
      title: 'crossAxisCountInDetailPage'.tr,
      trailing: dropdownButton<int?>(
          maxWidth: 60,
          minWidth: 60,
          show: styleSetting.crossAxisCountInDetailPageMenu.value,
          onTapOutside: () => styleSetting
              .crossAxisCountInDetailPageMenu.value = false,
          content: [
            MoonMenuItem(
                label: Text('auto'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInDetailPage(null)),
            MoonMenuItem(
                label: Text('2'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInDetailPage(2)),
            MoonMenuItem(
                label: Text('3'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInDetailPage(3)),
            MoonMenuItem(
                label: Text('4'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInDetailPage(4)),
            MoonMenuItem(
                label: Text('5'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInDetailPage(5)),
            MoonMenuItem(
                label: Text('6'.tr).small(),
                onTap: () => styleSetting
                    .saveCrossAxisCountInDetailPage(6)),
          ],
          child: filledButton(
              onPressed: () => styleSetting
                  .crossAxisCountInDetailPageMenu
                  .toggle(),
              label: styleSetting
                          .crossAxisCountInDetailPage.value ==
                      null
                  ? 'auto'.tr
                  : styleSetting.crossAxisCountInDetailPage.value
                      .toString()
                      .tr)),
    );
  }

  Widget _buildPageListMode() {
    return moonListTile(
      title: 'pageListStyle'.tr,
      trailing: MoonEhButton.md(
          onTap: () => toRoute(Routes.pageListStyle),
          icon: BootstrapIcons.chevron_right),
      onTap: () => toRoute(Routes.pageListStyle),
    );
  }

  Widget _buildMoveCover2RightSide() {
    return moonListTile(
      title: 'moveCover2RightSide'.tr,
      subtitle: 'needRestart'.tr,
      trailing: MoonSwitch(
        value: styleSetting.moveCover2RightSide.value,
        onChanged: styleSetting.saveMoveCover2RightSide,
      ),
    );
  }

  Widget _buildLayout(BuildContext context) {
    return moonListTile(
      title: 'layoutMode'.tr,
      subtitle: JHLayout.allLayouts
          .firstWhere((e) => e.mode == styleSetting.layout.value)
          .desc,
      trailing: popupMenuButton<LayoutMode>(
          onSelected: (LayoutMode? newValue) =>
              styleSetting.saveLayoutMode(newValue!),
          itemBuilder: (context) => JHLayout.allLayouts
              .map((e) => PopupMenuItem(
                    enabled: e.isSupported(),
                    value: e.mode,
                    child: Text(e.name,
                        style: e.isSupported()
                            ? null
                            : TextStyle(
                                color: UIConfig
                                    .settingPageLayoutSelectorUnSupportColor(
                                        context))),
                  ))
              .toList(),
          child: IgnorePointer(
            child: filledButton(
                label: JHLayout.layout(styleSetting.layout.value),
                onPressed: () {}),
          )),
    );
  }
}
