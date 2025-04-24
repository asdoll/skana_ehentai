import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/consts/eh_consts.dart';
import 'package:skana_ehentai/src/extension/dio_exception_extension.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/network/eh_request.dart';
import 'package:skana_ehentai/src/routes/routes.dart';
import 'package:skana_ehentai/src/setting/site_setting.dart';
import 'package:skana_ehentai/src/setting/user_setting.dart';
import 'package:skana_ehentai/src/utils/cookie_util.dart';
import 'package:skana_ehentai/src/utils/eh_spider_parser.dart';
import 'package:skana_ehentai/src/widget/loading_state_indicator.dart';
import 'package:retry/retry.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../exception/eh_site_exception.dart';
import '../../../setting/eh_setting.dart';
import '../../../service/log.dart';
import '../../../utils/route_util.dart';
import '../../../utils/snack_util.dart';

class SettingEHPage extends StatefulWidget {
  const SettingEHPage({Key? key}) : super(key: key);

  @override
  State<SettingEHPage> createState() => _SettingEHPageState();
}

class _SettingEHPageState extends State<SettingEHPage> {
  bool isDonator = false;
  int? currentConsumption;
  int? totalLimit;
  int? resetCost;

  LoadingState imageLimitLoadingState = LoadingState.idle;
  LoadingState resetLimitLoadingState = LoadingState.idle;

  String credit = '';
  String gp = '';
  LoadingState assetsLoadingState = LoadingState.idle;

  @override
  void initState() {
    super.initState();

    fetchDataFromHomePage();
    getAssets();
  }

  @override
  Widget build(BuildContext context) {
    if (!userSetting.hasLoggedIn()) {
      return const SizedBox();
    }
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('ehSetting'.tr)),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.only(top: 16),
          children: [
            _buildSiteSegmentControl(),
            _buildRedirect2EH(),
            _buildProfile(),
            _buildSiteSetting(),
            _buildImageLimit(),
            _buildAssets(),
            _buildMyTags(),
          ],
        ).withListTileTheme(context),
      ),
    );
  }

  Widget _buildSiteSegmentControl() {
    return ListTile(
      title: Text('site'.tr),
      onTap: () => ehSetting.saveSite(ehSetting.site.value == 'EH' ? 'EX' : 'EH'),
      trailing: CupertinoSlidingSegmentedControl<String>(
        groupValue: ehSetting.site.value,
        children: const {
          'EH': Text('E-Hentai'),
          'EX': Text('EXHentai'),
        },
        onValueChanged: (value) => ehSetting.saveSite(value ?? 'EH'),
      ),
    );
  }

  Widget _buildRedirect2EH() {
    if (ehSetting.site.value == 'EH') {
      return const SizedBox();
    }

    return SwitchListTile(
      title: Text('redirect2Eh'.tr),
      subtitle: Text('redirect2EhHint'.tr),
      value: ehSetting.redirect2Eh.value,
      onChanged: ehSetting.saveRedirect2Eh,
    ).fadeIn();
  }

  Widget _buildProfile() {
    return ListTile(
      title: Text('profileSetting'.tr),
      subtitle: Text('chooseProfileHint'.tr),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () => toRoute(Routes.profile),
    );
  }

  Widget _buildSiteSetting() {
    return ListTile(
      title: Text('siteSetting'.tr),
      subtitle: Text('siteSettingHint'.tr),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () async {
        if (GetPlatform.isDesktop) {
          launchUrlString(EHConsts.EUconfig);
          return;
        }

        await toRoute(
          Routes.webview,
          arguments: {
            'title': 'siteSetting'.tr,
            'url': EHConsts.EUconfig,
            'cookies': CookieUtil.parse2String(ehRequest.cookies),
          },
        );

        siteSetting.fetchDataFromEH();
      },
    );
  }

  Widget _buildImageLimit() {
    return GestureDetector(
      onLongPress: resetLimit,
      child: ListTile(
        title: Text('imageLimits'.tr),
        subtitle: LoadingStateIndicator(
          loadingState: imageLimitLoadingState,
          loadingWidgetBuilder: () => const Text(''),
          idleWidgetBuilder: () => const Text(''),
          errorWidgetSameWithIdle: true,
          successWidgetBuilder: () => isDonator ? Text('${'resetCost'.tr} $resetCost GP').fadeIn() : Text('isNotDonator'.tr),
        ),
        onTap: fetchDataFromHomePage,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingStateIndicator(
              useCupertinoIndicator: true,
              loadingState: imageLimitLoadingState,
              indicatorRadius: 10,
              idleWidgetBuilder: () => const SizedBox(),
              errorWidgetSameWithIdle: true,
              successWidgetBuilder: () => isDonator ? Text('$currentConsumption / $totalLimit').fadeIn() : const Text(''),
            ).marginOnly(right: 4),
            const Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }

  Widget _buildAssets() {
    return ListTile(
      title: Text('assets'.tr),
      subtitle: LoadingStateIndicator(
        loadingState: assetsLoadingState,
        loadingWidgetBuilder: () => const Text(''),
        idleWidgetBuilder: () => const Text(''),
        errorWidgetSameWithIdle: true,
        successWidgetBuilder: () => Text('GP: $gp    Credits: $credit').fadeIn(),
      ),
      onTap: getAssets,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingStateIndicator(
            useCupertinoIndicator: true,
            loadingState: assetsLoadingState,
            indicatorRadius: 10,
            idleWidgetBuilder: () => const SizedBox(),
            errorWidgetSameWithIdle: true,
          ).marginOnly(right: 4),
          const Icon(Icons.keyboard_arrow_right),
        ],
      ),
    );
  }

  Widget _buildMyTags() {
    return ListTile(
      title: Text('myTags'.tr),
      subtitle: Text('myTagsHint'.tr),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () => toRoute(Routes.tagSets),
    );
  }

  Future<void> fetchDataFromHomePage() async {
    if (imageLimitLoadingState == LoadingState.loading) {
      return;
    }
    if (!userSetting.hasLoggedIn()) {
      return;
    }

    log.debug('Fetch image quota');

    setStateSafely(() {
      imageLimitLoadingState = LoadingState.loading;
    });

    ({bool isDonator, int? currentConsumption, int? totalLimit, int? resetCost}) result;
    try {
      result = await retry(
        () async {
          return ehRequest.requestHomePage(parser: EHSpiderParser.homePage2ImageLimit);
        },
        retryIf: (e) => e is DioException,
        maxAttempts: 3,
      );
    } on DioException catch (e) {
      log.error('Fetch image quota failed', e.errorMsg);
      snack('fetchImageQuotaFailed'.tr, e.errorMsg ?? '', isShort: false);
      setStateSafely(() {
        imageLimitLoadingState = LoadingState.error;
      });
      return;
    } on EHSiteException catch (e) {
      log.error('Fetch image quota failed', e.message);
      snack('fetchImageQuotaFailed'.tr, e.message, isShort: false);
      setStateSafely(() {
        imageLimitLoadingState = LoadingState.error;
      });
      return;
    } catch (e) {
      log.error('Fetch image quota failed', e);
      snack('fetchImageQuotaFailed'.tr, e.toString(), isShort: false);
      setStateSafely(() {
        imageLimitLoadingState = LoadingState.error;
      });
      return;
    }

    log.debug('Fetch image quota success');

    setStateSafely(() {
      isDonator = result.isDonator;
      currentConsumption = result.currentConsumption;
      totalLimit = result.totalLimit;
      resetCost = result.resetCost;
      imageLimitLoadingState = LoadingState.success;
    });
  }

  Future<void> getAssets() async {
    if (assetsLoadingState == LoadingState.loading) {
      return;
    }

    setStateSafely(() {
      assetsLoadingState = LoadingState.loading;
    });

    log.debug('Get eh assets from exchange page');

    Map<String, String> assets;
    try {
      assets = await ehRequest.requestExchangePage(parser: EHSpiderParser.exchangePage2Assets);
    } on DioException catch (e) {
      log.error('Get eh assets failed', e.errorMsg);
      snack('Get eh failed'.tr, e.errorMsg ?? '', isShort: false);
      setStateSafely(() {
        assetsLoadingState = LoadingState.error;
      });
      return;
    } on EHSiteException catch (e) {
      log.error('Get eh assets failed', e.message);
      snack('Get eh assets failed'.tr, e.message, isShort: false);
      setStateSafely(() {
        assetsLoadingState = LoadingState.error;
      });
      return;
    } catch (e) {
      log.error('Get eh assets failed', e);
      snack('Get eh assets failed'.tr, e.toString(), isShort: false);
      setStateSafely(() {
        assetsLoadingState = LoadingState.error;
      });
      return;
    }

    setStateSafely(() {
      gp = assets['gp']!;
      credit = assets['credit']!;
      assetsLoadingState = LoadingState.success;
    });
  }

  Future<void> resetLimit() async {
    if (resetLimitLoadingState == LoadingState.loading) {
      return;
    }

    setStateSafely(() {
      resetLimitLoadingState = LoadingState.loading;
    });

    try {
      await ehRequest.requestResetImageLimit();
    } on DioException catch (e) {
      log.error('Reset image quota failed', e.errorMsg);
      snack('Reset image quota failed'.tr, e.errorMsg ?? '', isShort: false);
      setStateSafely(() {
        resetLimitLoadingState = LoadingState.error;
      });
      return;
    } on EHSiteException catch (e) {
      log.error('Reset image quota failed', e.message);
      snack('Reset image quota failed'.tr, e.message, isShort: false);
      setStateSafely(() {
        resetLimitLoadingState = LoadingState.error;
      });
      return;
    }

    setStateSafely(() {
      resetLimitLoadingState = LoadingState.success;
    });

    fetchDataFromHomePage();
    getAssets();
  }
}
