import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/extension/dio_exception_extension.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

import '../config/ui_config.dart';
import '../exception/eh_site_exception.dart';
import '../model/tag_set.dart';
import '../network/eh_request.dart';
import '../setting/preference_setting.dart';
import '../utils/eh_spider_parser.dart';
import '../service/log.dart';
import '../utils/route_util.dart';
import '../utils/snack_util.dart';
import 'loading_state_indicator.dart';

class EHTagSetDialog extends StatefulWidget {
  const EHTagSetDialog({super.key});

  @override
  State<EHTagSetDialog> createState() => _EHTagSetDialogState();
}

class _EHTagSetDialogState extends State<EHTagSetDialog> {
  LoadingState _loadingState = LoadingState.idle;
  List<({int number, String name})> _tagSets = [];

  bool remember = false;

  @override
  void initState() {
    super.initState();
    _getTagSet();
  }

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context: context,
      title: 'chooseTagSet'.tr,
      contentWidget: Column(
        children: [
          if (_loadingState == LoadingState.loading)
            SizedBox(
                height: 24,
                child: Center(child: UIConfig.loadingAnimation(context))),
          if (_loadingState == LoadingState.error)
            GestureDetector(
              onTap: _getTagSet,
              child: moonIcon(
                  icon: BootstrapIcons.arrow_clockwise,
                  size: 24,
                  color: UIConfig.loadingStateIndicatorButtonColor(context)),
            ),
          if (_loadingState == LoadingState.success)
            ..._tagSets.map(
              (tagSet) => moonListTile(
                title: tagSet.name,
                onTap: () => backRoute(
                    result: (tagSetNo: tagSet.number, remember: remember)),
              ),
            ),
          if (_loadingState == LoadingState.success &&
              preferenceSetting.enableDefaultTagSet.isTrue)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('asYourDefault'.tr).small(),
                SizedBox(width: 4),
                MoonCheckbox(
                    value: remember,
                    onChanged: (value) => setState(() => remember = value!))
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _getTagSet() async {
    setStateSafely(() {
      _loadingState = LoadingState.loading;
    });

    ({
      List<({int number, String name})> tagSets,
      bool tagSetEnable,
      Color? tagSetBackgroundColor,
      List<WatchedTag> tags,
      String apikey
    }) pageInfo;
    try {
      pageInfo = await ehRequest.requestMyTagsPage(
        parser: EHSpiderParser.myTagsPage2TagSetNamesAndTagSetsAndApikey,
      );
    } on DioException catch (e) {
      log.error('getTagSetFailed'.tr, e.errorMsg);
      snack('getTagSetFailed'.tr, e.errorMsg ?? '', isShort: true);
      setStateSafely(() {
        _loadingState = LoadingState.error;
      });
      return;
    } on EHSiteException catch (e) {
      log.error('getTagSetFailed'.tr, e.message);
      snack('getTagSetFailed'.tr, e.message, isShort: true);
      setStateSafely(() {
        _loadingState = LoadingState.error;
      });
      return;
    } catch (e) {
      log.error('getTagSetFailed'.tr, e.toString());
      snack('getTagSetFailed'.tr, e.toString(), isShort: true);
      setStateSafely(() {
        _loadingState = LoadingState.error;
      });
      return;
    }

    setStateSafely(() {
      _tagSets = pageInfo.tagSets;
      _loadingState = LoadingState.success;
    });
  }
}
