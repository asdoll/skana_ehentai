import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/extension/dio_exception_extension.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/loading_state_indicator.dart';
import 'package:retry/retry.dart';

import '../../../../exception/eh_site_exception.dart';
import '../../../../model/profile.dart';
import '../../../../network/eh_request.dart';
import '../../../../setting/site_setting.dart';
import '../../../../utils/eh_spider_parser.dart';
import '../../../../service/log.dart';

class SettingEHProfilePage extends StatefulWidget {
  const SettingEHProfilePage({super.key});

  @override
  State<SettingEHProfilePage> createState() => _SettingEHProfilePageState();
}

class _SettingEHProfilePageState extends State<SettingEHProfilePage> {
  LoadingState loadingState = LoadingState.idle;
  late List<Profile> profiles;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'profileSetting'.tr),
      body: _buildProfile(),
    );
  }

  Widget _buildProfile() {
    if (loadingState != LoadingState.success) {
      return LoadingStateIndicator(
          loadingState: loadingState, errorTapCallback: _loadProfile);
    }

    int number = profiles.firstWhere((p) => p.selected).number;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(top: 16),
        children: [
          moonListTile(
            title: 'selectedProfile'.tr,
            subtitle: 'resetIfSwitchSite'.tr,
            trailing: popupMenuButton<int>(
              child: IgnorePointer(
                  child: filledButton(
                label: profiles[number-1].name,
                onPressed: () {},
              )),
              onSelected: (int? newValue) {
                ehRequest.storeEHCookies(
                    [Cookie('sp', newValue?.toString() ?? '1')]);
                setState(() {
                  for (Profile value in profiles) {
                    value.selected = value.number == newValue;
                  }
                });
              },
              itemBuilder: (context) => profiles
                  .map(
                    (p) => PopupMenuItem(value: p.number, child: Text(p.name).small()),
                  )
                  .toList(),
            ),
          )
        ],
      ).withListTileTheme(context),
    );
  }

  Future<void> _loadProfile() async {
    if (loadingState == LoadingState.loading) {
      return;
    }

    loadingState = LoadingState.loading;
    ({
      bool preferJapaneseTitle,
      List<Profile> profiles,
      FrontPageDisplayType frontPageDisplayType,
      bool isLargeThumbnail,
      int thumbnailRows,
    }) settings;
    try {
      settings = await retry(
        () => ehRequest
            .requestSettingPage(EHSpiderParser.settingPage2SiteSetting),
        retryIf: (e) => e is DioException,
        maxAttempts: 3,
      );
    } on DioException catch (e) {
      log.error('Load profile fail', e.errorMsg);
      setState(() {
        loadingState = LoadingState.error;
      });
      return;
    } on EHSiteException catch (e) {
      log.error('Load profile fail', e.message);
      setState(() {
        loadingState = LoadingState.error;
      });
      return;
    }

    setStateSafely(() {
      profiles = settings.profiles;
      loadingState = LoadingState.success;
    });
  }
}
