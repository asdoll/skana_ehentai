import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/model/tab_bar_icon.dart';
import 'package:skana_ehentai/src/service/tag_search_order_service.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../consts/locale_consts.dart';
import '../../../l18n/locale_text.dart';
import '../../../model/jh_layout.dart';
import '../../../routes/routes.dart';
import '../../../service/tag_translation_service.dart';
import '../../../setting/preference_setting.dart';
import '../../../setting/style_setting.dart';
import '../../../utils/locale_util.dart';
import '../../../utils/route_util.dart';
import '../../../widget/loading_state_indicator.dart';

class SettingPreferencePage extends StatelessWidget {
  const SettingPreferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'preferenceSetting'.tr),
      body: Obx(
        () => SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(top: 16),
            children: [
              _buildLanguage(),
              _buildTagTranslate(),
              _buildTagOrderOptimization(),
              _buildDefaultTab(),
              if (styleSetting.isInV2Layout) _buildSimpleDashboardMode(),
              if (styleSetting.isInV2Layout) _buildShowBottomNavigation(),
              if (styleSetting.isInV2Layout ||
                  styleSetting.actualLayout == LayoutMode.desktop)
                _buildHideScroll2TopButton(),
              _buildPreloadGalleryCover(),
              _buildEnableSwipeBackGesture(),
              if (styleSetting.isInV2Layout)
                _buildEnableLeftMenuDrawerGesture(),
              if (styleSetting.isInV2Layout) _buildQuickSearch(),
              if (styleSetting.isInV2Layout)
                _buildDrawerGestureEdgeWidth(context),
              _buildShowAllGalleryTitles(),
              _buildShowGalleryTagVoteStatus(),
              _buildShowComments(),
              if (preferenceSetting.showComments.isTrue)
                _buildShowAllComments().fadeIn(const Key('showAllComments')),
              _buildEnableDefaultFavorite(),
              _buildEnableDefaultTagSet(),
              if (GetPlatform.isDesktop && styleSetting.isInDesktopLayout)
                _buildLaunchInFullScreen(),
              _buildTagSearchConfig(),
              if (preferenceSetting.enableTagZHTranslation.isTrue)
                _buildShowR18GImageDirectly()
                    .fadeIn(const Key('showR18GImageDirectly')),
              _buildShowUtcTime(),
              _buildShowDawnInfo(),
              _buildShowEncounterMonster(),
              _buildUseBuiltInBlockedUsers(),
              _buildBlockRules(),
            ],
          ).withListTileTheme(context),
        ),
      ),
    );
  }

  Widget _buildLanguage() {
    return moonListTile(
      title: 'language'.tr,
      trailing: popupMenuButton<Locale>(
        child: IgnorePointer(
          child: filledButton(
            onPressed: () {},
            label: LocaleConsts.localeCode2Description[
                preferenceSetting.locale.value.toString()]!,
          ),
        ),
        initialValue: preferenceSetting.locale.value,
        onSelected: (Locale? newValue) =>
            preferenceSetting.saveLanguage(newValue!),
        itemBuilder: (context) => LocaleText()
            .keys
            .keys
            .map((localeCode) => PopupMenuItem(
                  value: localeCode2Locale(localeCode),
                  child: Text(LocaleConsts.localeCode2Description[localeCode]!).small(),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTagTranslate() {
    return moonListTile(
      title: 'enableTagZHTranslation'.tr,
      subtitle: tagTranslationService.loadingState.value == LoadingState.success
          ? '${'version'.tr}: ${tagTranslationService.timeStamp.value!}'
          : tagTranslationService.loadingState.value == LoadingState.loading
              ? '${'downloadTagTranslationHint'.tr}${tagTranslationService.downloadProgress.value}'
              : tagTranslationService.loadingState.value == LoadingState.error
                  ? 'downloadFailed'.tr
                  : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingStateIndicator(
            loadingState: tagTranslationService.loadingState.value,
            indicatorRadius: 10,
            width: 40,
            idleWidgetBuilder: () => MoonEhButton(
                onTap: tagTranslationService.fetchDataFromGithub,
                icon: BootstrapIcons.arrow_counterclockwise),
            errorWidgetSameWithIdle: true,
            successWidgetSameWithIdle: true,
          ),
          MoonSwitch(
            value: preferenceSetting.enableTagZHTranslation.value,
            onChanged: (value) {
              preferenceSetting.saveEnableTagZHTranslation(value);
              if (value == true &&
                  tagTranslationService.loadingState.value !=
                      LoadingState.success) {
                tagTranslationService.fetchDataFromGithub();
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildTagOrderOptimization() {
    return moonListTile(
      title: 'zhTagSearchOrderOptimization'.tr,
      subtitle: tagSearchOrderOptimizationService.loadingState.value ==
              LoadingState.success
          ? '${'version'.tr}: ${tagSearchOrderOptimizationService.version.value!}'
          : tagSearchOrderOptimizationService.loadingState.value ==
                  LoadingState.loading
              ? '${'downloadTagTranslationHint'.tr}${tagSearchOrderOptimizationService.downloadProgress.value}'
              : tagSearchOrderOptimizationService.loadingState.value ==
                      LoadingState.error
                  ? 'downloadFailed'.tr
                  : 'zhTagSearchOrderOptimizationHint'.tr,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingStateIndicator(
            loadingState: tagSearchOrderOptimizationService.loadingState.value,
            indicatorRadius: 10,
            width: 40,
            idleWidgetBuilder: () => MoonEhButton(
                onTap: tagSearchOrderOptimizationService.fetchDataFromGithub,
                icon: BootstrapIcons.arrow_counterclockwise),
            errorWidgetSameWithIdle: true,
            successWidgetSameWithIdle: true,
          ),
          MoonSwitch(
            value: preferenceSetting.enableTagZHSearchOrderOptimization.value,
            onChanged: (value) {
              preferenceSetting.saveEnableTagZHSearchOrderOptimization(value);
              if (value == true &&
                  tagSearchOrderOptimizationService.loadingState.value !=
                      LoadingState.success) {
                tagSearchOrderOptimizationService.fetchDataFromGithub();
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildDefaultTab() {
    return moonListTile(
      title: 'defaultTab'.tr,
      trailing: popupMenuButton<TabBarIconNameEnum>(
        child: IgnorePointer(
          child: filledButton(
            onPressed: () {},
            label: TabBarIconNameEnum.values
                .firstWhere(
                    (element) => element == preferenceSetting.defaultTab.value)
                .name
                .tr,
          ),
        ),
        initialValue: preferenceSetting.defaultTab.value,
        onSelected: (TabBarIconNameEnum? newValue) =>
            preferenceSetting.saveDefaultTab(newValue!),
        itemBuilder: (context) => TabBarIconNameEnum.values
            .map((tabBarIconNameEnum) => PopupMenuItem(
                  value: tabBarIconNameEnum,
                  child: Text(tabBarIconNameEnum.name.tr).small(),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSimpleDashboardMode() {
    return moonListTile(
      title: 'simpleDashboardMode'.tr,
      subtitle: 'simpleDashboardModeHint'.tr,
      trailing: MoonSwitch(
        value: preferenceSetting.simpleDashboardMode.value,
        onChanged: preferenceSetting.saveSimpleDashboardMode,
      ),
    );
  }

  Widget _buildShowBottomNavigation() {
    return moonListTile(
      title: 'hideBottomBar'.tr,
      trailing: MoonSwitch(
        value: preferenceSetting.hideBottomBar.value,
        onChanged: preferenceSetting.saveHideBottomBar,
      ),
    );
  }

  Widget _buildHideScroll2TopButton() {
    return moonListTile(
      title: 'hideScroll2TopButton'.tr,
      trailing: popupMenuButton<Scroll2TopButtonModeEnum>(
        child: IgnorePointer(
          child: filledButton(
            onPressed: () {},
            label: preferenceSetting.hideScroll2TopButton.value ==
                    Scroll2TopButtonModeEnum.scrollUp
                ? 'whenScrollUp'.tr
                : preferenceSetting.hideScroll2TopButton.value ==
                        Scroll2TopButtonModeEnum.scrollDown
                    ? 'whenScrollDown'.tr
                    : preferenceSetting.hideScroll2TopButton.value.name.tr,
          ),
        ),
        initialValue: preferenceSetting.hideScroll2TopButton.value,
        onSelected: (Scroll2TopButtonModeEnum? newValue) =>
            preferenceSetting.saveHideScroll2TopButton(newValue!),
        itemBuilder: (context) => Scroll2TopButtonModeEnum.values
            .map((scroll2TopButtonModeEnum) => PopupMenuItem(
                  value: scroll2TopButtonModeEnum,
                  child: Text(scroll2TopButtonModeEnum ==
                          Scroll2TopButtonModeEnum.scrollUp
                      ? 'whenScrollUp'.tr
                      : scroll2TopButtonModeEnum ==
                              Scroll2TopButtonModeEnum.scrollDown
                          ? 'whenScrollDown'.tr
                          : scroll2TopButtonModeEnum.name.tr).small(),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildPreloadGalleryCover() {
    return moonListTile(
      title: 'preloadGalleryCover'.tr,
      subtitle: 'preloadGalleryCoverHint'.tr,
      trailing: MoonSwitch(
        value: preferenceSetting.preloadGalleryCover.value,
        onChanged: preferenceSetting.savePreloadGalleryCover,
      ),
    );
  }

  Widget _buildEnableSwipeBackGesture() {
    return moonListTile(
      title: 'enableSwipeBackGesture'.tr,
      subtitle: 'needRestart'.tr,
      trailing: MoonSwitch(
        value: preferenceSetting.enableSwipeBackGesture.value,
        onChanged: preferenceSetting.saveEnableSwipeBackGesture,
      ),
    );
  }

  Widget _buildEnableLeftMenuDrawerGesture() {
    return moonListTile(
      title: 'enableLeftMenuDrawerGesture'.tr,
      trailing: MoonSwitch(
        value: preferenceSetting.enableLeftMenuDrawerGesture.value,
        onChanged: preferenceSetting.saveEnableLeftMenuDrawerGesture,
      ),
    );
  }

  Widget _buildQuickSearch() {
    return moonListTile(
      title: 'enableQuickSearchDrawerGesture'.tr,
      trailing: MoonSwitch(
        value: preferenceSetting.enableQuickSearchDrawerGesture.value,
        onChanged: preferenceSetting.saveEnableQuickSearchDrawerGesture,
      ),
    );
  }

  Widget _buildDrawerGestureEdgeWidth(BuildContext context) {
    return moonListTile(
      title: 'drawerGestureEdgeWidth'.tr,
      trailing: Obx(() {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SliderTheme(
              data: SliderTheme.of(context)
                  .copyWith(showValueIndicator: ShowValueIndicator.always),
              child: Slider(
                min: 20,
                max: 300,
                activeColor: UIConfig.primaryColor(context),
                label:
                    preferenceSetting.drawerGestureEdgeWidth.value.toString(),
                value:
                    preferenceSetting.drawerGestureEdgeWidth.value.toDouble(),
                onChanged: (value) {
                  preferenceSetting.drawerGestureEdgeWidth.value =
                      value.toInt();
                },
                onChangeEnd: (value) {
                  preferenceSetting.saveDrawerGestureEdgeWidth(value.toInt());
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildShowAllGalleryTitles() {
    return moonListTile(
      title: 'showAllGalleryTitles'.tr,
      subtitle: 'showAllGalleryTitlesHint'.tr,
      trailing: MoonSwitch(
        value: preferenceSetting.showAllGalleryTitles.value,
        onChanged: preferenceSetting.saveShowAllGalleryTitles,
      ),
    );
  }

  Widget _buildShowGalleryTagVoteStatus() {
    return moonListTile(
      title: 'showGalleryTagVoteStatus'.tr,
      subtitle: 'showGalleryTagVoteStatusHint'.tr,
      trailing: MoonSwitch(
        value: preferenceSetting.showGalleryTagVoteStatus.value,
        onChanged: preferenceSetting.saveShowGalleryTagVoteStatus,
      ),
    );
  }

  Widget _buildShowComments() {
    return moonListTile(
      title: 'showComments'.tr,
      trailing: MoonSwitch(
        value: preferenceSetting.showComments.value,
        onChanged: preferenceSetting.saveShowComments,
      ),
    );
  }

  Widget _buildShowAllComments() {
    return moonListTile(
      title: 'showAllComments'.tr,
      subtitle: 'showAllCommentsHint'.tr,
      trailing: MoonSwitch(
        value: preferenceSetting.showAllComments.value,
        onChanged: preferenceSetting.saveShowAllComments,
      ),
    );
  }

  Widget _buildShowR18GImageDirectly() {
    return moonListTile(
      title: 'showR18GImageDirectly'.tr,
      trailing: MoonSwitch(
        value: preferenceSetting.showR18GImageDirectly.value,
        onChanged: preferenceSetting.saveShowR18GImageDirectly,
      ),
    );
  }

  Widget _buildEnableDefaultFavorite() {
    return moonListTile(
      title: 'enableDefaultFavorite'.tr,
      subtitle: preferenceSetting.enableDefaultFavorite.isTrue
          ? 'enableDefaultFavoriteHint'.tr
          : 'disableDefaultFavoriteHint'.tr,
      trailing: MoonSwitch(
        value: preferenceSetting.enableDefaultFavorite.value,
        onChanged: preferenceSetting.saveEnableDefaultFavorite,
      ),
    );
  }

  Widget _buildEnableDefaultTagSet() {
    return moonListTile(
      title: 'enableDefaultTagSet'.tr,
      subtitle: preferenceSetting.enableDefaultTagSet.isTrue
          ? 'enableDefaultTagSetHint'.tr
          : 'disableDefaultTagSetHint'.tr,
      trailing: MoonSwitch(
        value: preferenceSetting.enableDefaultTagSet.value,
        onChanged: preferenceSetting.saveEnableDefaultTagSet,
      ),
    );
  }

  Widget _buildLaunchInFullScreen() {
    return moonListTile(
      title: 'launchInFullScreen'.tr,
      subtitle: 'launchInFullScreenHint'.tr,
      trailing: MoonSwitch(
        value: preferenceSetting.launchInFullScreen.value,
        onChanged: preferenceSetting.saveLaunchInFullScreen,
      ),
    );
  }

  Widget _buildTagSearchConfig() {
    return moonListTile(
      title: 'searchBehaviour'.tr,
      subtitle:
          preferenceSetting.searchBehaviour.value == SearchBehaviour.inheritAll
              ? 'inheritAllHint'.tr
              : preferenceSetting.searchBehaviour.value ==
                      SearchBehaviour.inheritPartially
                  ? 'inheritPartiallyHint'.tr
                  : 'noneHint'.tr,
      trailing: popupMenuButton<SearchBehaviour>(
        child: IgnorePointer(
          child: filledButton(
            onPressed: () {},
            label: preferenceSetting.searchBehaviour.value.name.tr,
          ),
        ),
        initialValue: preferenceSetting.searchBehaviour.value,
        onSelected: (SearchBehaviour? newValue) =>
            preferenceSetting.saveTagSearchConfig(newValue!),
        itemBuilder: (context) => SearchBehaviour.values
            .map((searchBehaviour) => PopupMenuItem(
                  value: searchBehaviour,
                  child: Text(searchBehaviour.name.tr).small(),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildShowUtcTime() {
    return moonListTile(
      title: 'showUtcTime'.tr,
      trailing: MoonSwitch(
        value: preferenceSetting.showUtcTime.value,
        onChanged: preferenceSetting.saveShowUtcTime,
      ),
    );
  }

  Widget _buildBlockRules() {
    return moonListTile(
      title: 'blockingRules'.tr,
      subtitle: 'blockingRulesHint'.tr,
      trailing: MoonEhButton.md(
          onTap: () => toRoute(Routes.blockingRules),
          icon: BootstrapIcons.chevron_right),
      onTap: () => toRoute(Routes.blockingRules),
    );
  }

  Widget _buildShowDawnInfo() {
    return moonListTile(
      title: 'showDawnInfo'.tr,
      trailing: MoonSwitch(
        value: preferenceSetting.showDawnInfo.value,
        onChanged: preferenceSetting.saveShowDawnInfo,
      ),
    );
  }

  Widget _buildShowEncounterMonster() {
    return moonListTile(
      title: 'showEncounterMonster'.tr,
      trailing: MoonSwitch(
        value: preferenceSetting.showHVInfo.value,
        onChanged: preferenceSetting.saveShowHVInfo,
      ),
    );
  }

  Widget _buildUseBuiltInBlockedUsers() {
    return moonListTile(
      title: 'useBuiltInBlockedUsers'.tr,
      subtitle: 'useBuiltInBlockedUsersHint'.tr,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MoonEhButton(
            icon: BootstrapIcons.question_circle,
            onTap: () => launchUrlString(
              'https://raw.githubusercontent.com/jiangtian616/JHenTai/refs/heads/master/built_in_blocked_user.json',
              mode: LaunchMode.externalApplication,
            ),
          ),
          MoonSwitch(
            value: preferenceSetting.useBuiltInBlockedUsers.value,
            onChanged: preferenceSetting.saveUseBuiltInBlockedUsers,
          )
        ],
      ),
    );
  }
}
