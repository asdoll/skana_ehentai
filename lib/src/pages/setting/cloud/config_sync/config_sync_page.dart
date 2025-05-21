import 'dart:io';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/enum/config_type_enum.dart';
import 'package:skana_ehentai/src/extension/dio_exception_extension.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/network/jh_request.dart';
import 'package:skana_ehentai/src/service/cloud_service.dart';
import 'package:skana_ehentai/src/setting/user_setting.dart';
import 'package:skana_ehentai/src/service/log.dart';
import 'package:skana_ehentai/src/utils/snack_util.dart';
import 'package:skana_ehentai/src/utils/toast_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/eh_config_type_select_dialog.dart';
import 'package:skana_ehentai/src/widget/loading_state_indicator.dart';

import '../../../../config/ui_config.dart';
import '../../../../model/config.dart';
import '../../../../utils/jh_spider_parser.dart';
import '../../../../utils/permission_util.dart';
import '../../../../utils/route_util.dart';

class ConfigSyncPage extends StatefulWidget {
  const ConfigSyncPage({super.key});

  @override
  State<ConfigSyncPage> createState() => _ConfigSyncPageState();
}

class _ConfigSyncPageState extends State<ConfigSyncPage> {
  LoadingState _loadingState = LoadingState.idle;
  List<CloudConfig> configs = [];

  @override
  void initState() {
    _refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'configSync'.tr),
      body: LoadingStateIndicator(
        loadingState: _loadingState,
        successWidgetBuilder: () => configs.isEmpty
            ? Center(
                child: Text('noData'.tr, style: const TextStyle(fontSize: 16))
                    .appHeader())
            : ListView(
                padding: const EdgeInsets.only(top: 16),
                children: configs
                    .mapIndexed(
                      (index, config) => moonListTile(
                        leading:
                            Text((configs.length - index).toString()).small(),
                        title: config.type.name.tr,
                        subtitle: 'v${config.version}\n${config.shareCode}',
                        trailing: Text(DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(config.ctime))
                            .small(),
                        onTap: () => _handleTapConfig(context, config),
                      ),
                    )
                    .toList(),
              ).withListTileTheme(context),
        errorTapCallback: _refresh,
      ),
      floatingActionButton: userSetting.hasLoggedIn()
          ? _buildFloatingActionButton(context)
          : null,
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return MoonButton.icon(
      buttonSize: MoonButtonSize.lg,
      showBorder: true,
      borderColor: Get.context?.moonTheme?.buttonTheme.colors.borderColor
          .withValues(alpha: 0.5),
      backgroundColor: Get.context?.moonTheme?.tokens.colors.zeno,
      onTap: () async {
        if (_loadingState == LoadingState.loading) {
          return;
        }

        List<CloudConfigTypeEnum>? result = await showDialog(
          context: context,
          builder: (_) =>
              EHConfigTypeSelectDialog(title: '${'upload2cloud'.tr}?'),
        );

        if (result?.isNotEmpty ?? false) {
          _uploadConfig(result!);
        }
      },
      icon: Icon(
        BootstrapIcons.cloud_upload,
        color: Colors.white,
      ),
    );
  }

  Future<void> _refresh() async {
    if (_loadingState == LoadingState.loading) {
      return;
    }

    if (!userSetting.hasLoggedIn()) {
      setStateSafely(() => _loadingState = LoadingState.success);
      return;
    }

    setStateSafely(() => _loadingState = LoadingState.loading);

    try {
      List<CloudConfig> configs =
          await jhRequest.requestListConfig<List<CloudConfig>>(
              parser: JHResponseParser.listConfigApi2Configs);
      setStateSafely(() {
        this.configs = configs;
        _loadingState = LoadingState.success;
      });
    } on DioException catch (e) {
      log.error('requestListConfig error: $e');
      snack('failed'.tr, e.errorMsg ?? '');
      setStateSafely(() => _loadingState = LoadingState.error);
    } catch (e) {
      log.error('requestListConfig error: $e');
      snack('failed'.tr, e.toString());
      setStateSafely(() {
        _loadingState = LoadingState.error;
      });
    }
  }

  Future<void> _handleTapConfig(
      BuildContext context, CloudConfig config) async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: Text('copyShareCode'.tr),
            onPressed: () {
              backRoute();
              Clipboard.setData(ClipboardData(text: config.shareCode));
              toast('hasCopiedToClipboard'.tr);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('download'.tr),
            onPressed: () {
              backRoute();
              _downloadConfig(config);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('import'.tr),
            onPressed: () {
              backRoute();
              _importConfig(config);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('delete'.tr,
                style: TextStyle(color: UIConfig.alertColor(context))),
            onPressed: () {
              backRoute();
              _deleteConfig(config);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
            child: Text('cancel'.tr), onPressed: backRoute),
      ),
    );
  }

  Future<void> _downloadConfig(CloudConfig config) async {
    await requestStoragePermission();

    String? path;
    try {
      path = await FilePicker.platform.getDirectoryPath();
    } on Exception catch (e) {
      log.error('Pick download config path failed', e);
    }

    if (path == null) {
      return;
    }

    if (!checkPermissionForPath(path)) {
      toast('invalidPath'.tr, isShort: false);
      return;
    }

    String fileName =
        '${config.type.name.tr}_${config.version}_${config.shareCode}.json';
    File file = File('$path/$fileName');
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await file.writeAsString(config.config);
    toast('success'.tr);
  }

  Future<void> _importConfig(CloudConfig config) async {
    try {
      await cloudConfigService.importConfig(config);
      toast('success'.tr);
    } on Exception catch (e) {
      log.error('importConfig error: $e');
      toast('failed'.tr);
    }
  }

  Future<void> _deleteConfig(CloudConfig config) async {
    if (_loadingState == LoadingState.loading) {
      return;
    }
    setStateSafely(() {
      configs = [];
      _loadingState = LoadingState.loading;
    });

    try {
      await jhRequest.requestDeleteConfig(
        id: config.id,
        parser: JHResponseParser.api2Success,
      );
    } on DioException catch (e) {
      log.error('requestDeleteConfig error: $e');
      snack('failed'.tr, e.errorMsg ?? '');
      setStateSafely(() => _loadingState = LoadingState.error);
      return;
    } catch (e) {
      log.error('requestDeleteConfig error: $e');
      snack('failed'.tr, e.toString());
      setStateSafely(() => _loadingState = LoadingState.error);
      return;
    }

    toast('success'.tr);
    _loadingState = LoadingState.success;

    _refresh();
  }

  Future<void> _uploadConfig(List<CloudConfigTypeEnum> types) async {
    if (_loadingState == LoadingState.loading) {
      return;
    }
    setStateSafely(() {
      configs = [];
      _loadingState = LoadingState.loading;
    });

    Map<CloudConfigTypeEnum, String> currentConfigMap = {};
    List<({int type, String version, String config})> uploadConfigs =
        currentConfigMap.entries
            .where((entry) => types.contains(entry.key))
            .map((entry) {
      return (
        type: entry.key.code,
        version: CloudConfigService.configTypeVersionMap[entry.key] ?? '1.0.0',
        config: entry.value,
      );
    }).toList();

    try {
      await jhRequest.requestBatchUploadConfig(
        configs: uploadConfigs,
        parser: JHResponseParser.api2Success,
      );
    } on DioException catch (e) {
      log.error('requestUploadConfig error: $e');
      snack('failed'.tr, e.errorMsg ?? '');
      setStateSafely(() => _loadingState = LoadingState.error);
      return;
    } catch (e) {
      log.error('requestUploadConfig error: $e');
      snack('failed'.tr, e.toString());
      setStateSafely(() => _loadingState = LoadingState.error);
      return;
    }

    toast('success'.tr);
    _loadingState = LoadingState.success;

    _refresh();
  }
}
