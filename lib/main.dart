import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/network/eh_request.dart';
import 'package:skana_ehentai/src/network/jh_request.dart';
import 'package:skana_ehentai/src/service/app_update_service.dart';
import 'package:skana_ehentai/src/service/archive_download_service.dart';
import 'package:skana_ehentai/src/service/built_in_blocked_user_service.dart';
import 'package:skana_ehentai/src/service/cloud_service.dart';
import 'package:skana_ehentai/src/service/frame_rate_service.dart';
import 'package:skana_ehentai/src/service/gallery_download_service.dart';
import 'package:skana_ehentai/src/service/history_service.dart';
import 'package:skana_ehentai/src/service/isolate_service.dart';
import 'package:skana_ehentai/src/service/jh_service.dart';
import 'package:skana_ehentai/src/service/local_block_rule_service.dart';
import 'package:skana_ehentai/src/service/local_config_service.dart';
import 'package:skana_ehentai/src/service/local_gallery_service.dart';
import 'package:skana_ehentai/src/service/path_service.dart';
import 'package:skana_ehentai/src/service/quick_search_service.dart';
import 'package:skana_ehentai/src/service/schedule_service.dart';
import 'package:skana_ehentai/src/service/search_history_service.dart';
import 'package:skana_ehentai/src/service/storage_service.dart';
import 'package:skana_ehentai/src/service/super_resolution_service.dart';
import 'package:skana_ehentai/src/service/tag_search_order_service.dart';
import 'package:skana_ehentai/src/service/tag_translation_service.dart';
import 'package:skana_ehentai/src/service/volume_service.dart';
import 'package:skana_ehentai/src/service/windows_service.dart';
import 'package:skana_ehentai/src/setting/advanced_setting.dart';
import 'package:skana_ehentai/src/setting/archive_bot_setting.dart';
import 'package:skana_ehentai/src/setting/download_setting.dart';
import 'package:skana_ehentai/src/setting/eh_setting.dart';
import 'package:skana_ehentai/src/setting/favorite_setting.dart';
import 'package:skana_ehentai/src/setting/mouse_setting.dart';
import 'package:skana_ehentai/src/setting/my_tags_setting.dart';
import 'package:skana_ehentai/src/setting/network_setting.dart';
import 'package:skana_ehentai/src/setting/performance_setting.dart';
import 'package:skana_ehentai/src/setting/preference_setting.dart';
import 'package:skana_ehentai/src/setting/read_setting.dart';
import 'package:skana_ehentai/src/setting/site_setting.dart';
import 'package:skana_ehentai/src/setting/super_resolution_setting.dart';
import 'package:skana_ehentai/src/setting/user_setting.dart';
import 'package:skana_ehentai/src/widget/app_manager.dart';
import 'package:skana_ehentai/src/l18n/locale_text.dart';
import 'package:skana_ehentai/src/routes/getx_router_observer.dart';
import 'package:skana_ehentai/src/routes/routes.dart';
import 'package:skana_ehentai/src/setting/security_setting.dart';
import 'package:skana_ehentai/src/setting/style_setting.dart';
import 'package:skana_ehentai/src/service/log.dart';

import 'src/config/theme_config.dart';
import 'src/network/archive_bot_request.dart';

List<JHLifeCircleBean> lifeCircleBeans = [
  ehRequest,
  jhRequest,
  archiveBotRequest,
  appUpdateService,
  galleryDownloadService,
  archiveDownloadService,
  localGalleryService,
  cloudConfigService,
  frameRateService,
  historyService,
  isolateService,
  localBlockRuleService,
  localConfigService,
  log,
  pathService,
  quickSearchService,
  scheduleService,
  searchHistoryService,
  storageService,
  superResolutionService,
  tagTranslationService,
  tagSearchOrderOptimizationService,
  volumeService,
  windowService,
  advancedSetting,
  downloadSetting,
  archiveBotSetting,
  ehSetting,
  favoriteSetting,
  mouseSetting,
  myTagsSetting,
  networkSetting,
  performanceSetting,
  preferenceSetting,
  readSetting,
  securitySetting,
  siteSetting,
  styleSetting,
  superResolutionSetting,
  userSetting,
  builtInBlockedUserService,
];

void main(List<String> args) async {
  if (GetPlatform.isDesktop && runWebViewTitleBarWidget(args)) {
    return;
  }

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));

  lifeCircleBeans = topologicalSort(lifeCircleBeans);
  for (JHLifeCircleBean bean in lifeCircleBeans) {
    await bean.initBean();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SkanaEH',
      themeMode: styleSetting.themeMode.value,
      theme: ThemeConfig.theme(Brightness.light),
      darkTheme: ThemeConfig.theme(Brightness.dark),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('zh', 'CN'),
        Locale('zh', 'TW'),
        Locale('ko', 'KR'),
        Locale('pt', 'BR'),
      ],
      locale: preferenceSetting.locale.value,
      fallbackLocale: const Locale('en', 'US'),
      translations: LocaleText(),

      getPages: Routes.pages,
      initialRoute: securitySetting.enablePasswordAuth.isTrue ||
              securitySetting.enableBiometricAuth.isTrue
          ? Routes.lock
          : Routes.home,
      navigatorObservers: [GetXRouterObserver()],
      builder: (context, child) => AppManager(child: child!),

      /// enable swipe back feature
      popGesture: preferenceSetting.enableSwipeBackGesture.isTrue,
      onReady: () {
        for (JHLifeCircleBean bean in lifeCircleBeans) {
          bean.afterBeanReady();
        }
      },
    );
  }
}

List<JHLifeCircleBean> topologicalSort(List<JHLifeCircleBean> lifeCircleBeans) {
  // Maps to store the visiting state and result order
  final visiting = <JHLifeCircleBean, bool>{};
  final visited = <JHLifeCircleBean, bool>{};
  final result = <JHLifeCircleBean>[];

  // Helper function for DFS
  void visit(JHLifeCircleBean node) {
    if (visited.containsKey(node)) {
      return;
    }
    if (visiting[node] == true) {
      throw Exception('Circular dependency detected');
    }
    visiting[node] = true;
    for (final dependency in node.initDependencies) {
      visit(dependency);
    }
    visiting[node] = false;
    visited[node] = true;
    result.add(node);
  }

  // Visit all nodes
  for (final node in lifeCircleBeans) {
    visit(node);
  }

  return result.toList();
}
