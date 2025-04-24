import 'dart:convert';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/model/config.dart';
import 'package:skana_ehentai/src/network/eh_request.dart';
import 'package:skana_ehentai/src/service/cloud_service.dart';
import 'package:skana_ehentai/src/setting/advanced_setting.dart';
import 'package:skana_ehentai/src/service/path_service.dart';
import 'package:skana_ehentai/src/service/log.dart';
import 'package:skana_ehentai/src/utils/toast_util.dart';
import 'package:skana_ehentai/src/widget/loading_state_indicator.dart';
import 'package:path/path.dart';

import '../../../config/ui_config.dart';
import '../../../enum/config_type_enum.dart';
import '../../../routes/routes.dart';
import '../../../service/isolate_service.dart';
import '../../../utils/byte_util.dart';
import '../../../utils/route_util.dart';
import '../../../widget/eh_config_type_select_dialog.dart';

class SettingAdvancedPage extends StatefulWidget {
  const SettingAdvancedPage({super.key});

  @override
  State<SettingAdvancedPage> createState() => _SettingAdvancedPageState();
}

class _SettingAdvancedPageState extends State<SettingAdvancedPage> {
  LoadingState _logLoadingState = LoadingState.idle;
  String _logSize = '...';

  LoadingState _imageCacheLoadingState = LoadingState.idle;
  String _imageCacheSize = '...';

  LoadingState _exportDataLoadingState = LoadingState.idle;
  LoadingState _importDataLoadingState = LoadingState.idle;

  @override
  void initState() {
    super.initState();

    _loadingLogSize();
    _getImagesCacheSize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('advancedSetting'.tr)),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.only(top: 16),
          children: [
            _buildEnableLogging(),
            if (advancedSetting.enableLogging.isTrue) _buildRecordAllLogs().fadeIn(),
            _buildOpenLogs(),
            _buildClearLogs(context),
            _buildClearImageCache(context),
            _buildClearNetworkCache(),
            if (GetPlatform.isDesktop) _buildSuperResolution(),
            _buildCheckUpdate(),
            _buildCheckClipboard(),
            if (GetPlatform.isAndroid) _buildVerifyAppLinks(),
            _buildInNoImageMode(),
            _buildImportData(context),
            _buildExportData(context),
          ],
        ).withListTileTheme(context),
      ),
    );
  }

  Widget _buildEnableLogging() {
    return ListTile(
      title: Text('enableLogging'.tr),
      subtitle: Text('needRestart'.tr),
      trailing: Switch(value: advancedSetting.enableLogging.value, onChanged: advancedSetting.saveEnableLogging),
    );
  }

  Widget _buildRecordAllLogs() {
    return SwitchListTile(
      title: Text('enableVerboseLogging'.tr),
      subtitle: Text('needRestart'.tr),
      value: advancedSetting.enableVerboseLogging.value,
      onChanged: advancedSetting.saveEnableVerboseLogging,
    );
  }

  Widget _buildOpenLogs() {
    return ListTile(
      title: Text('openLog'.tr),
      trailing: const Icon(Icons.keyboard_arrow_right).marginOnly(right: 4),
      onTap: () => toRoute(Routes.logList),
    );
  }

  Widget _buildClearLogs(BuildContext context) {
    return ListTile(
      title: Text('clearLogs'.tr),
      subtitle: Text('longPress2Clear'.tr),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingStateIndicator(
            loadingState: _logLoadingState,
            useCupertinoIndicator: true,
            successWidgetBuilder: () => Text(
              _logSize,
              style: TextStyle(color: UIConfig.resumePauseButtonColor(context), fontWeight: FontWeight.w500),
            ),
            errorTapCallback: _loadingLogSize,
          ).marginOnly(right: 8)
        ],
      ),
      onLongPress: _clearAndLoadingLogSize,
    );
  }

  Widget _buildClearImageCache(BuildContext context) {
    return ListTile(
      title: Text('clearImagesCache'.tr),
      subtitle: Text('longPress2Clear'.tr),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingStateIndicator(
            loadingState: _imageCacheLoadingState,
            useCupertinoIndicator: true,
            successWidgetBuilder: () => Text(
              _imageCacheSize,
              style: TextStyle(color: UIConfig.resumePauseButtonColor(context), fontWeight: FontWeight.w500),
            ),
            errorTapCallback: _getImagesCacheSize,
          ).marginOnly(right: 8)
        ],
      ),
      onLongPress: _clearAndLoadingImageCacheSize,
    );
  }

  Widget _buildClearNetworkCache() {
    return ListTile(
      title: Text('clearPageCache'.tr),
      subtitle: Text('longPress2Clear'.tr),
      onLongPress: () async {
        await ehRequest.removeAllCache();
        toast('clearSuccess'.tr, isCenter: false);
      },
    );
  }

  Widget _buildSuperResolution() {
    return ListTile(
      title: Text('superResolution'.tr),
      trailing: const Icon(Icons.keyboard_arrow_right).marginOnly(right: 4),
      onTap: () => toRoute(Routes.superResolution),
    );
  }

  Widget _buildCheckUpdate() {
    return SwitchListTile(
      title: Text('checkUpdateAfterLaunchingApp'.tr),
      value: advancedSetting.enableCheckUpdate.value,
      onChanged: advancedSetting.saveEnableCheckUpdate,
    );
  }

  Widget _buildCheckClipboard() {
    return SwitchListTile(
      title: Text('checkClipboard'.tr),
      value: advancedSetting.enableCheckClipboard.value,
      onChanged: advancedSetting.saveEnableCheckClipboard,
    );
  }

  Widget _buildVerifyAppLinks() {
    return ListTile(
      title: Text('verityAppLinks4Android12'.tr),
      subtitle: Text('verityAppLinks4Android12Hint'.tr),
      trailing: const Icon(Icons.keyboard_arrow_right).marginOnly(right: 4),
      onTap: () async {
        try {
          await const AndroidIntent(
            action: 'android.settings.APP_OPEN_BY_DEFAULT_SETTINGS',
            data: 'package:com.skanaone.skana_ehentai',
          ).launch();
        } on Exception catch (e) {
          log.error(e);
          log.uploadError(e);
          toast('error'.tr);
        }
      },
    );
  }

  Widget _buildInNoImageMode() {
    return SwitchListTile(
      title: Text('noImageMode'.tr),
      value: advancedSetting.inNoImageMode.value,
      onChanged: advancedSetting.saveInNoImageMode,
    );
  }

  Widget _buildImportData(BuildContext context) {
    return ListTile(
      title: Text('importData'.tr),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingStateIndicator(
            loadingState: _importDataLoadingState,
            idleWidgetBuilder: () => const Icon(Icons.keyboard_arrow_right),
            successWidgetSameWithIdle: true,
            useCupertinoIndicator: true,
            errorWidgetSameWithIdle: true,
          ).marginOnly(right: 8)
        ],
      ),
      onTap: () => _importData(context),
    );
  }

  Widget _buildExportData(BuildContext context) {
    return ListTile(
      title: Text('exportData'.tr),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingStateIndicator(
            loadingState: _exportDataLoadingState,
            idleWidgetBuilder: () => const Icon(Icons.keyboard_arrow_right),
            successWidgetSameWithIdle: true,
            useCupertinoIndicator: true,
            errorWidgetSameWithIdle: true,
          ).marginOnly(right: 8)
        ],
      ),
      onTap: () => _exportData(context),
    );
  }

  Future<void> _loadingLogSize() async {
    if (_logLoadingState == LoadingState.loading) {
      return;
    }

    setStateSafely(() => _logLoadingState = LoadingState.loading);

    try {
      _logSize = await log.getSize();
    } catch (e) {
      log.error('loading log size error', e);
      _logSize = '-1B';
      setStateSafely(() => _imageCacheLoadingState = LoadingState.error);
      return;
    }

    setStateSafely(() => _logLoadingState = LoadingState.success);
  }

  Future<void> _clearAndLoadingLogSize() async {
    if (_logLoadingState == LoadingState.loading) {
      return;
    }

    await log.clear();
    await _loadingLogSize();

    toast('clearSuccess'.tr, isCenter: false);
  }

  Future<void> _getImagesCacheSize() async {
    if (_imageCacheLoadingState == LoadingState.loading) {
      return;
    }

    setStateSafely(() => _imageCacheLoadingState = LoadingState.loading);

    try {
      _imageCacheSize = await compute(
        (dirPath) {
          Directory cacheImagesDirectory = Directory(dirPath);

          int totalBytes;
          if (!cacheImagesDirectory.existsSync()) {
            totalBytes = 0;
          } else {
            totalBytes = cacheImagesDirectory.listSync().fold<int>(0, (previousValue, element) => previousValue += (element as File).lengthSync());
          }

          return byte2String(totalBytes.toDouble());
        },
        join(pathService.tempDir.path, cacheImageFolderName),
      );
    } catch (e) {
      log.error(e);
      _imageCacheSize = '-1B';
      setStateSafely(() => _imageCacheLoadingState = LoadingState.error);
      return;
    }

    setStateSafely(() => _imageCacheLoadingState = LoadingState.success);
  }

  Future<void> _clearAndLoadingImageCacheSize() async {
    if (_imageCacheLoadingState == LoadingState.loading) {
      return;
    }

    await clearDiskCachedImages();
    await _getImagesCacheSize();

    toast('clearSuccess'.tr, isCenter: false);
  }

  Future<void> _importData(BuildContext context) async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowCompression: false,
        compressionQuality: 0,
      );
    } on Exception catch (e) {
      log.error('Pick import data file failed', e);
      return;
    }

    if (result == null) {
      return;
    }

    if (_importDataLoadingState == LoadingState.loading) {
      return;
    }

    log.info('Import data from ${result.files.first.path}');
    setStateSafely(() => _importDataLoadingState = LoadingState.loading);

    File file = File(result.files.first.path!);
    String string = await file.readAsString();

    try {
      List list = await isolateService.jsonDecodeAsync(string);
      List<CloudConfig> configs = list.map((e) => CloudConfig.fromJson(e)).toList();
      for (CloudConfig config in configs) {
        await cloudConfigService.importConfig(config);
      }

      toast('success'.tr);
      setStateSafely(() => _importDataLoadingState = LoadingState.success);
    } catch (e, s) {
      log.error('Import data failed', e, s);
      toast('internalError'.tr);
      setStateSafely(() => _importDataLoadingState = LoadingState.error);
      return;
    }
  }

  Future<void> _exportData(BuildContext context) async {
    List<CloudConfigTypeEnum>? result = await showDialog(
      context: context,
      builder: (_) => EHConfigTypeSelectDialog(title: 'selectExportItems'.tr),
    );
    if (result?.isEmpty ?? true) {
      return;
    }

    String fileName = '${CloudConfigService.configFileName}-${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.json';
    if (GetPlatform.isMobile) {
      return _exportDataMobile(fileName, result);
    } else {
      return _exportDataDesktop(fileName, result);
    }
  }

  Future<void> _exportDataMobile(String fileName, List<CloudConfigTypeEnum>? result) async {
    if (_exportDataLoadingState == LoadingState.loading) {
      return;
    }
    setStateSafely(() => _exportDataLoadingState = LoadingState.loading);

    List<CloudConfig> uploadConfigs = [];
    for (CloudConfigTypeEnum type in result!) {
      CloudConfig? config = await cloudConfigService.getLocalConfig(type);
      if (config != null) {
        uploadConfigs.add(config);
      }
    }

    try {
      String? savedPath = await FilePicker.platform.saveFile(
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: utf8.encode(await isolateService.jsonEncodeAsync(uploadConfigs)),
        lockParentWindow: true,
      );
      if (savedPath != null) {
        log.info('Export data to $savedPath success');
        toast('success'.tr);
        setStateSafely(() => _exportDataLoadingState = LoadingState.success);
      }
    } on Exception catch (e) {
      log.error('Export data failed', e);
      toast('internalError'.tr);
      setStateSafely(() => _exportDataLoadingState = LoadingState.error);
    }
  }

  Future<void> _exportDataDesktop(String fileName, List<CloudConfigTypeEnum>? result) async {
    if (_exportDataLoadingState == LoadingState.loading) {
      return;
    }
    setStateSafely(() => _exportDataLoadingState = LoadingState.loading);

    String? savedPath;
    try {
      savedPath = await FilePicker.platform.saveFile(
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        lockParentWindow: true,
      );
    } on Exception catch (e) {
      log.error('Select save path for exporting data failed', e);
      toast('internalError'.tr);
      setStateSafely(() => _exportDataLoadingState = LoadingState.error);
      return;
    }

    if (savedPath == null) {
      return;
    }

    List<CloudConfig> uploadConfigs = [];
    for (CloudConfigTypeEnum type in result!) {
      CloudConfig? config = await cloudConfigService.getLocalConfig(type);
      if (config != null) {
        uploadConfigs.add(config);
      }
    }

    File file = File(savedPath);
    try {
      if (await file.exists()) {
        await file.create(recursive: true);
      }
      await file.writeAsString(await isolateService.jsonEncodeAsync(uploadConfigs));
      log.info('Export data to $savedPath success');
      toast('success'.tr);
      setStateSafely(() => _exportDataLoadingState = LoadingState.success);
    } on Exception catch (e) {
      log.error('Export data failed', e);
      toast('internalError'.tr);
      setStateSafely(() => _exportDataLoadingState = LoadingState.error);
      file.delete().ignore();
    }
  }
}
