import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/enum/config_enum.dart';
import 'package:skana_ehentai/src/extension/dio_exception_extension.dart';
import 'package:skana_ehentai/src/network/eh_request.dart';
import 'package:skana_ehentai/src/setting/user_setting.dart';
import 'package:skana_ehentai/src/service/log.dart';
import 'package:retry/retry.dart';

import '../exception/eh_site_exception.dart';
import '../service/jh_service.dart';
import '../utils/eh_spider_parser.dart';

FavoriteSetting favoriteSetting = FavoriteSetting();

class FavoriteSetting with JHLifeCircleBeanWithConfigStorage implements JHLifeCircleBean {
  RxList<String> favoriteTagNames = [
    'Favorite 0',
    'Favorite 1',
    'Favorite 2',
    'Favorite 3',
    'Favorite 4',
    'Favorite 5',
    'Favorite 6',
    'Favorite 7',
    'Favorite 8',
    'Favorite 9',
  ].obs;

  List<int> favoriteCounts = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1];

  bool get inited => favoriteTagNames[0] != 'Favorite 0' || favoriteCounts[0] != -1;

  @override
  List<JHLifeCircleBean> get initDependencies => super.initDependencies..add(userSetting);

  @override
  ConfigEnum get configEnum => ConfigEnum.favoriteSetting;

  @override
  void applyBeanConfig(String configString) {
    Map map = jsonDecode(configString);

    favoriteTagNames.value = (jsonDecode(map['favoriteTagNames']) as List).cast<String>();
    favoriteCounts = (jsonDecode(map['favoriteCounts']) as List).cast<int>();
  }

  @override
  String toConfigString() {
    return jsonEncode({
      // ignore: invalid_use_of_protected_member
      'favoriteTagNames': jsonEncode(favoriteTagNames.value),
      'favoriteCounts': jsonEncode(favoriteCounts),
    });
  }

  @override
  Future<void> doInitBean() async {
    /// listen to login and logout
    ever(userSetting.ipbMemberId, (v) {
      if (userSetting.hasLoggedIn()) {
        fetchDataFromEH();
      } else {
        favoriteTagNames.value = [
          'Favorite 0',
          'Favorite 1',
          'Favorite 2',
          'Favorite 3',
          'Favorite 4',
          'Favorite 5',
          'Favorite 6',
          'Favorite 7',
          'Favorite 8',
          'Favorite 9',
        ];
        favoriteCounts = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1];
        super.clearBeanConfig();
      }
    });
  }

  @override
  void doAfterBeanReady() {
    fetchDataFromEH();
  }

  Future<void> fetchDataFromEH() async {
    /// only refresh when logged in
    if (!userSetting.hasLoggedIn()) {
      return;
    }

    log.info('Fetch favorite setting from EH');
    try {
      await retry(
        () async {
          Map<String, List> map = await ehRequest.requestFavoritePage(EHSpiderParser.favoritePage2FavoriteTagsAndCounts);
          favoriteTagNames.value = map['favoriteTagNames'] as List<String>;
          favoriteCounts = map['favoriteCounts'] as List<int>;
        },
        retryIf: (e) => e is DioException,
        maxAttempts: 3,
      );
    } on DioException catch (e) {
      log.error('Fetch favorite setting from EH fail', e.errorMsg);
      return;
    } on EHSiteException catch (e) {
      log.error('Fetch favorite setting from EH fail', e.message);
      return;
    }

    log.info('Fetch favorite setting from EH success');
    await saveBeanConfig();
  }

  void incrementFavByIndex(int? index) async {
    if (index == null || index < 0 || index >= favoriteTagNames.length) {
      return;
    }
    favoriteCounts[index]++;
    await saveBeanConfig();
  }

  void decrementFavByIndex(int? index) async {
    if (index == null || index < 0 || index >= favoriteTagNames.length) {
      return;
    }
    favoriteCounts[index]--;
    await saveBeanConfig();
  }
}
