import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingAboutPage extends StatefulWidget {
  const SettingAboutPage({super.key});

  @override
  State<SettingAboutPage> createState() => _SettingAboutPageState();
}

class _SettingAboutPageState extends State<SettingAboutPage> {
  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';
  String author = 'asdoll';
  String telegram = 'https://t.me/+PindoE9yvIpmOWI9';
  String gitOrigin = 'https://github.com/jiangtian616/JHenTai';
  String gitRepo = 'https://github.com/asdoll/skana_ehentai';
  String helpPage = 'https://github.com/jiangtian616/JHenTai/wiki';

  @override
  void initState() {
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        appName = packageInfo.appName;
        packageName = packageInfo.packageName;
        version = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'SkanaEH'),
      body: ListView(
        padding: const EdgeInsets.only(top: 16),
        children: [
          moonListTile(
              title: 'version'.tr,
              subtitle: version.isEmpty
                  ? '1.0.0'
                  : version + (buildNumber.isEmpty ? '' : '+$buildNumber')),
          moonListTile(
              title: 'author'.tr,
              subtitleWidget: SelectableText(author,
                  strutStyle: StrutStyle(forceStrutHeight: true, leading: 0),
                  style: Get
                      .context?.moonTheme?.tokens.typography.heading.text14)),
          moonListTile(
            title: 'Github',
            subtitleWidget: SelectableText(gitRepo,
                strutStyle: StrutStyle(forceStrutHeight: true, leading: 0),
                style:
                    Get.context?.moonTheme?.tokens.typography.heading.text14),
            onTap: () =>
                launchUrlString(gitRepo, mode: LaunchMode.externalApplication),
          ),
          moonListTile(
            title: 'Github Origin',
            subtitleWidget: SelectableText(gitOrigin,
                strutStyle: StrutStyle(forceStrutHeight: true, leading: 0),
                style:
                    Get.context?.moonTheme?.tokens.typography.heading.text14),
            onTap: () => launchUrlString(gitOrigin,
                mode: LaunchMode.externalApplication),
          ),
          // ListTile(
          //   title: const Text('Telegram(Chinese Mainly)'),
          //   subtitle: Text('${'telegramHint'.tr}\n$telegram'),
          //   onTap: () => launchUrlString(telegram, mode: LaunchMode.externalApplication),
          // ),
          moonListTile(
            title: 'Q&A'.tr,
            subtitleWidget: SelectableText(helpPage,
                strutStyle: StrutStyle(forceStrutHeight: true, leading: 0),
                style:
                    Get.context?.moonTheme?.tokens.typography.heading.text14),
            onTap: () =>
                launchUrlString(helpPage, mode: LaunchMode.externalApplication),
          ),
        ],
      ).withListTileTheme(context),
    );
  }
}
