import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/setting/preference_setting.dart';
import 'package:skana_ehentai/src/utils/toast_util.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../service/super_resolution_service.dart';
import '../../../../setting/super_resolution_setting.dart';
import '../../../../service/log.dart';
import '../../../../widget/loading_state_indicator.dart';

class SettingSuperResolutionPage extends StatelessWidget {
  const SettingSuperResolutionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('superResolution'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () => launchUrlString(
              preferenceSetting.locale.value.languageCode == 'zh'
                  ? 'https://github.com/jiangtian616/JHenTai/wiki/%E5%9B%BE%E7%89%87%E8%B6%85%E5%88%86%E8%BE%A8%E7%8E%87%E6%94%BE%E5%A4%A7%E4%BD%BF%E7%94%A8%E6%96%B9%E6%B3%95'
                  : preferenceSetting.locale.value.languageCode == 'ko'
                      ? 'https://github.com/jiangtian616/JHenTai/wiki/AI-%EC%B4%88%EA%B3%A0%ED%99%94%EC%A7%88-%EC%9D%B4%EB%AF%B8%EC%A7%80-%EC%82%AC%EC%9A%A9-%EB%B0%A9%EB%B2%95'
                      : 'https://github.com/jiangtian616/JHenTai/wiki/AI-Image-Super-Resolution-Usage',
            ),
          )
        ],
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.only(top: 16),
          children: [
            _buildModelDirectoryPath(),
            _buildModelType(),
            _buildGpuId(),
          ],
        ).withListTileTheme(context),
      ),
    );
  }

  Widget _buildModelDirectoryPath() {
    return ListTile(
      title: Text('modelDirectoryPath'.tr),
      subtitle: Text(superResolutionSetting.modelDirectoryPath.value ?? ''),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () async {
        String? result;
        try {
          result = await FilePicker.platform.getDirectoryPath();
        } on Exception catch (e) {
          log.error('Pick executable file path failed', e);
          log.uploadError(e);
          toast('internalError'.tr);
        }

        if (result == null) {
          return;
        }

        superResolutionSetting.saveModelDirectoryPath(result);
      },
    );
  }

  Widget _buildModelType() {
    return ListTile(
      title: Text('modelType'.tr),
      subtitle: GetBuilder<SuperResolutionService>(
        id: SuperResolutionService.downloadId,
        builder: (superResolutionService) => superResolutionService.downloadState == LoadingState.loading
            ? Text('${'downloading'.tr} ${superResolutionService.downloadProgress}')
            : superResolutionService.downloadState == LoadingState.success
                ? Text('downloaded'.tr)
                : const SizedBox(),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GetBuilder<SuperResolutionService>(
            id: SuperResolutionService.downloadId,
            builder: (superResolutionService) => superResolutionService.downloadState == LoadingState.loading
                ? IconButton(icon: const CupertinoActivityIndicator(), onPressed: () {}, enableFeedback: false)
                : IconButton(
                    icon: const Icon(Icons.download),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      if (superResolutionService.downloadState == LoadingState.loading) {
                        return;
                      }
                      superResolutionService.downloadModelFile(superResolutionSetting.model.value);
                    },
                  ),
          ),
          const SizedBox(width: 8),
          DropdownButton<ModelType>(
            value: superResolutionSetting.model.value,
            elevation: 4,
            onChanged: (ModelType? newValue) => superResolutionSetting.saveModel(newValue!),
            items: [
              DropdownMenuItem(child: Text(ModelType.CUGAN.subType), value: ModelType.CUGAN),
              DropdownMenuItem(child: Text(ModelType.ESRGAN.subType), value: ModelType.ESRGAN),
              DropdownMenuItem(child: Text(ModelType.ESRGAN_ANIME.subType), value: ModelType.ESRGAN_ANIME),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGpuId() {
    return ListTile(
      title: const Text('GPU-id'),
      trailing: DropdownButton<int>(
        value: superResolutionSetting.gpuId.value,
        elevation: 4,
        alignment: AlignmentDirectional.centerEnd,
        onChanged: (int? newValue) => superResolutionSetting.saveGpuId(newValue!),
        items: const [
          DropdownMenuItem(child: Text('-1'), value: -1),
          DropdownMenuItem(child: Text('0'), value: 0),
          DropdownMenuItem(child: Text('1'), value: 1),
          DropdownMenuItem(child: Text('2'), value: 2),
          DropdownMenuItem(child: Text('3'), value: 3),
          DropdownMenuItem(child: Text('4'), value: 4),
          DropdownMenuItem(child: Text('5'), value: 5),
          DropdownMenuItem(child: Text('6'), value: 6),
          DropdownMenuItem(child: Text('7'), value: 7),
        ],
      ),
    );
  }
}
