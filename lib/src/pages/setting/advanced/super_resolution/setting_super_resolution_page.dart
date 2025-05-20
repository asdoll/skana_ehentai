import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/setting/preference_setting.dart';
import 'package:skana_ehentai/src/utils/toast_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../service/super_resolution_service.dart';
import '../../../../setting/super_resolution_setting.dart';
import '../../../../service/log.dart';
import '../../../../widget/loading_state_indicator.dart';

class SettingSuperResolutionPage extends StatelessWidget {
  const SettingSuperResolutionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        title: 'superResolution'.tr,
        actions: [
          MoonEhButton.md(
            icon: BootstrapIcons.question_circle,
            onTap: () => launchUrlString(
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
    return moonListTile(
      title: 'modelDirectoryPath'.tr,
      subtitle: superResolutionSetting.modelDirectoryPath.value,
      trailing: moonIcon(icon: BootstrapIcons.chevron_right),
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
    return moonListTile(
      title: 'modelType'.tr,
      subtitleWidget: GetBuilder<SuperResolutionService>(
        id: SuperResolutionService.downloadId,
        builder: (superResolutionService) => superResolutionService.downloadState == LoadingState.loading
            ? Text('${'downloading'.tr} ${superResolutionService.downloadProgress}').subHeader()
            : superResolutionService.downloadState == LoadingState.success
                ? Text('downloaded'.tr).subHeader()
                : const SizedBox(),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GetBuilder<SuperResolutionService>(
            id: SuperResolutionService.downloadId,
            builder: (superResolutionService) => superResolutionService.downloadState == LoadingState.loading
                ? IconButton(icon: UIConfig.loadingAnimation(Get.context!), onPressed: () {}, enableFeedback: false)
                : IconButton(
                    icon: moonIcon(icon: BootstrapIcons.download),
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
          popupMenuButton<ModelType>(
            child: IgnorePointer(
              child: filledButton(
                onPressed: () {},
                label: superResolutionSetting.model.value.subType,
              ),
            ),
            initialValue: superResolutionSetting.model.value,
            itemBuilder: (context) => [
              PopupMenuItem(value: ModelType.CUGAN, child: Text(ModelType.CUGAN.subType).small()),
              PopupMenuItem(value: ModelType.ESRGAN, child: Text(ModelType.ESRGAN.subType).small()),
              PopupMenuItem(value: ModelType.ESRGAN_ANIME, child: Text(ModelType.ESRGAN_ANIME.subType).small()),
            ],
            onSelected: (ModelType? newValue) => superResolutionSetting.saveModel(newValue!),
          )
        ],
      ),
    );
  }

  Widget _buildGpuId() {
    return moonListTile(
      title: 'GPU-id'.tr,
      trailing: popupMenuButton<int>(
        initialValue: superResolutionSetting.gpuId.value,
        onSelected: (int? newValue) => superResolutionSetting.saveGpuId(newValue!),
        itemBuilder: (context) => [
          PopupMenuItem(value: -1, child: Text('-1').small()),
          PopupMenuItem(value: 0, child: Text('0').small()),
          PopupMenuItem(value: 1, child: Text('1').small()),
          PopupMenuItem(value: 2, child: Text('2').small()),
          PopupMenuItem(value: 3, child: Text('3').small()),
          PopupMenuItem(value: 4, child: Text('4').small()),
          PopupMenuItem(value: 5, child: Text('5').small()),
          PopupMenuItem(value: 6, child: Text('6').small()),
          PopupMenuItem(value: 7, child: Text('7').small()),
        ],
        child: IgnorePointer(
          child: filledButton(
            onPressed: () {},
            label: superResolutionSetting.gpuId.value.toString(),
          ),
        ),
      ),
    );
  }
}
