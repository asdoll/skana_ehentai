import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/enum/config_enum.dart';
import 'package:skana_ehentai/src/service/local_config_service.dart';
import 'package:skana_ehentai/src/utils/route_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UpdateDialog extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;

  const UpdateDialog({super.key, required this.currentVersion, required this.latestVersion});

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context: context,
      title: 'availableUpdate'.tr,
      contentWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text('${'CurrentVersion'.tr}:'), const SizedBox(height: 6), Text('${'LatestVersion'.tr}:')],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(currentVersion), const SizedBox(height: 6), Text(latestVersion)],
            ),
          ),
        ],
      ).paddingBottom(16),
      actions: [
        outlinedButton(
          label: 'dismiss'.tr,
          onPressed: () {
            localConfigService.write(configKey: ConfigEnum.dismissVersion, value: latestVersion);
            backRoute();
          },
        ),
        filledButton(
          label: '${'check'.tr} ->',
          onPressed: () {
            backRoute();
            launchUrlString('https://github.com/asdoll/skana_ehentai/releases', mode: LaunchMode.externalApplication);
          },
        )
      ]
    );
  }
}
