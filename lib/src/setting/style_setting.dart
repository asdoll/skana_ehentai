import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/enum/config_enum.dart';
import 'package:skana_ehentai/src/service/jh_service.dart';
import 'package:skana_ehentai/src/service/log.dart';

import '../model/jh_layout.dart';

StyleSetting styleSetting = StyleSetting();

class StyleSetting
    with JHLifeCircleBeanWithConfigStorage
    implements JHLifeCircleBean {
  Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  Rx<Color> lightThemeColor = UIConfig.defaultLightThemeColor.obs;
  Rx<Color> darkThemeColor = UIConfig.defaultDarkThemeColor.obs;
  Rx<ListMode> listMode = ListMode.listWithTags.obs;
  RxnInt crossAxisCountInWaterFallFlow = RxnInt(null);
  RxBool crossAxisCountInWaterFallFlowMenu = false.obs;
  RxnInt crossAxisCountInGridDownloadPageForGroup = RxnInt(null);
  RxBool crossAxisCountInGridDownloadPageForGroupMenu = false.obs;
  RxnInt crossAxisCountInGridDownloadPageForGallery = RxnInt(null);
  RxBool crossAxisCountInGridDownloadPageForGalleryMenu = false.obs;
  RxnInt crossAxisCountInDetailPage = RxnInt(null);
  RxBool crossAxisCountInDetailPageMenu = false.obs;
  RxMap<String, ListMode> pageListMode = <String, ListMode>{}.obs;
  RxBool moveCover2RightSide = false.obs;
  Rx<LayoutMode> layout =
      PlatformDispatcher.instance.views.first.physicalSize.width /
                  PlatformDispatcher.instance.views.first.devicePixelRatio <
              600
          ? LayoutMode.mobileV2.obs
          : GetPlatform.isDesktop
              ? LayoutMode.desktop.obs
              : LayoutMode.tabletV2.obs;

  bool get isInWaterFlowListMode =>
      listMode.value == ListMode.waterfallFlowBig ||
      listMode.value == ListMode.waterfallFlowSmall ||
      listMode.value == ListMode.waterfallFlowMedium;

  Brightness currentBrightness() => themeMode.value == ThemeMode.system
      ? PlatformDispatcher.instance.platformBrightness
      : themeMode.value == ThemeMode.light
          ? Brightness.light
          : Brightness.dark;

  /// If the current window width is too small, App will degrade to mobile mode. Use [actualLayout] to indicate actual layout.
  LayoutMode actualLayout =
      PlatformDispatcher.instance.views.first.physicalSize.width /
                  PlatformDispatcher.instance.views.first.devicePixelRatio <
              600
          ? LayoutMode.mobileV2
          : GetPlatform.isDesktop
              ? LayoutMode.desktop
              : LayoutMode.tabletV2;

  bool get isInMobileLayout =>
      actualLayout == LayoutMode.mobileV2 || actualLayout == LayoutMode.mobile;

  bool get isInTabletLayout =>
      actualLayout == LayoutMode.tabletV2 || actualLayout == LayoutMode.tablet;

  bool get isInV1Layout =>
      actualLayout == LayoutMode.mobile || actualLayout == LayoutMode.tablet;

  bool get isInV2Layout =>
      actualLayout == LayoutMode.mobileV2 ||
      actualLayout == LayoutMode.tabletV2;

  bool get isInDesktopLayout => actualLayout == LayoutMode.desktop;

  @override
  ConfigEnum get configEnum => ConfigEnum.styleSetting;

  @override
  void applyBeanConfig(String configString) {
    Map map = jsonDecode(configString);

    themeMode.value = ThemeMode.values[map['themeMode']];
    lightThemeColor.value =
        Color(map['lightThemeColor'] ?? lightThemeColor.value.value);
    darkThemeColor.value =
        Color(map['darkThemeColor'] ?? darkThemeColor.value.value);
    listMode.value = ListMode.values[map['listMode']];
    crossAxisCountInWaterFallFlow.value = map['crossAxisCountInWaterFallFlow'];
    crossAxisCountInGridDownloadPageForGroup.value =
        map['crossAxisCountInGridDownloadPageForGroup'];
    crossAxisCountInGridDownloadPageForGallery.value =
        map['crossAxisCountInGridDownloadPageForGallery'];
    crossAxisCountInDetailPage.value = map['crossAxisCountInDetailPage'];
    pageListMode.value = Map.from(map['pageListMode']?.map(
            (route, listModeIndex) =>
                MapEntry(route, ListMode.values[listModeIndex])) ??
        {});
    moveCover2RightSide.value =
        map['moveCover2RightSide'] ?? moveCover2RightSide.value;
    layout.value = LayoutMode.values[map['layout'] ?? layout.value.index];

    /// old layout has been removed in v5.0.0
    if (isInV1Layout) {
      layout = PlatformDispatcher.instance.views.first.physicalSize.width /
                  PlatformDispatcher.instance.views.first.devicePixelRatio <
              600
          ? LayoutMode.mobileV2.obs
          : GetPlatform.isDesktop
              ? LayoutMode.desktop.obs
              : LayoutMode.tabletV2.obs;
    }
    actualLayout = layout.value;
  }

  @override
  String toConfigString() {
    return jsonEncode({
      'themeMode': themeMode.value.index,
      'lightThemeColor': lightThemeColor.value.value,
      'darkThemeColor': darkThemeColor.value.value,
      'listMode': listMode.value.index,
      'crossAxisCountInWaterFallFlow': crossAxisCountInWaterFallFlow.value,
      'crossAxisCountInGridDownloadPageForGroup':
          crossAxisCountInGridDownloadPageForGroup.value,
      'crossAxisCountInGridDownloadPageForGallery':
          crossAxisCountInGridDownloadPageForGallery.value,
      'crossAxisCountInDetailPage': crossAxisCountInDetailPage.value,
      'pageListMode': pageListMode
          .map((route, listMode) => MapEntry(route, listMode.index)),
      'moveCover2RightSide': moveCover2RightSide.value,
      'layout': layout.value.index,
    });
  }

  @override
  Future<void> doInitBean() async {}

  @override
  void doAfterBeanReady() {
    ever(themeMode, (_) {
      Get.changeThemeMode(themeMode.value);
    });
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    log.debug('saveThemeMode:${themeMode.name}');
    this.themeMode.value = themeMode;
    await saveBeanConfig();
  }

  Future<void> saveLightThemeColor(Color color) async {
    log.debug('saveLightThemeColor:$color');
    this.lightThemeColor.value = color;
    await saveBeanConfig();
  }

  Future<void> saveDarkThemeColor(Color color) async {
    log.debug('saveDarkThemeColor:$color');
    this.darkThemeColor.value = color;
    await saveBeanConfig();
  }

  Future<void> saveListMode(ListMode listMode) async {
    log.debug('saveListMode:${listMode.name}');
    this.listMode.value = listMode;
    await saveBeanConfig();
  }

  Future<void> saveCrossAxisCountInWaterFallFlow(
      int? crossAxisCountInWaterFallFlow) async {
    log.debug(
        'saveCrossAxisCountInWaterFallFlow:$crossAxisCountInWaterFallFlow');
    crossAxisCountInWaterFallFlowMenu.value = false;
    this.crossAxisCountInWaterFallFlow.value = crossAxisCountInWaterFallFlow;
    await saveBeanConfig();
  }

  Future<void> saveCrossAxisCountInGridDownloadPageForGroup(
      int? crossAxisCountInGridDownloadPageForGroup) async {
    log.debug(
        'saveCrossAxisCountInGridDownloadPageForGroup:$crossAxisCountInGridDownloadPageForGroup');
    crossAxisCountInGridDownloadPageForGroupMenu.value = false;
    this.crossAxisCountInGridDownloadPageForGroup.value =
        crossAxisCountInGridDownloadPageForGroup;
    await saveBeanConfig();
  }

  Future<void> saveCrossAxisCountInGridDownloadPageForGallery(
      int? crossAxisCountInGridDownloadPageForGallery) async {
    log.debug(
        'saveCrossAxisCountInGridDownloadPageForGallery:$crossAxisCountInGridDownloadPageForGallery');
    crossAxisCountInGridDownloadPageForGalleryMenu.value = false;
    this.crossAxisCountInGridDownloadPageForGallery.value =
        crossAxisCountInGridDownloadPageForGallery;
    await saveBeanConfig();
  }

  Future<void> saveCrossAxisCountInDetailPage(
      int? crossAxisCountInDetailPage) async {
    log.debug('saveCrossAxisCountInDetailPage:$crossAxisCountInDetailPage');
    crossAxisCountInDetailPageMenu.value = false;
    this.crossAxisCountInDetailPage.value = crossAxisCountInDetailPage;
    await saveBeanConfig();
  }

  Future<void> savePageListMode(String routeName, ListMode? listMode) async {
    log.debug('savePageListMode:$routeName, $listMode');
    if (listMode == null) {
      this.pageListMode.remove(routeName);
    } else {
      this.pageListMode[routeName] = listMode;
    }
    await saveBeanConfig();
  }

  Future<void> saveMoveCover2RightSide(bool moveCover2RightSide) async {
    log.debug('saveMoveCover2RightSide:$moveCover2RightSide');
    this.moveCover2RightSide.value = moveCover2RightSide;
    await saveBeanConfig();
  }

  Future<void> saveLayoutMode(LayoutMode layoutMode) async {
    log.debug('saveLayoutMode:${layoutMode.name}');
    this.layout.value = layoutMode;
    await saveBeanConfig();
  }
}

enum ListMode {
  listWithoutTags,
  listWithTags,
  waterfallFlowSmall,
  waterfallFlowBig,
  flat,
  flatWithoutTags,
  waterfallFlowMedium,
}
