import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

import '../../../../routes/routes.dart';
import '../../../../setting/style_setting.dart';

class SettingPageListStylePage extends StatefulWidget {
  const SettingPageListStylePage({super.key});

  @override
  State<SettingPageListStylePage> createState() =>
      _SettingPageListStylePageState();
}

class _SettingPageListStylePageState extends State<SettingPageListStylePage> {
  final List<PageListStyleItem> items = [
    PageListStyleItem(
        name: 'home'.tr,
        route: Routes.gallerys,
        show: () => styleSetting.isInDesktopLayout),
    PageListStyleItem(
        name: 'home'.tr,
        route: Routes.dashboard,
        show: () =>
            styleSetting.isInMobileLayout || styleSetting.isInTabletLayout),
    PageListStyleItem(
        name: 'search'.tr,
        route: Routes.desktopSearch,
        show: () => styleSetting.isInDesktopLayout),
    PageListStyleItem(
        name: 'search'.tr,
        route: Routes.mobileV2Search,
        show: () =>
            styleSetting.isInMobileLayout || styleSetting.isInTabletLayout),
    PageListStyleItem(
        name: 'popular'.tr, route: Routes.popular, show: () => true),
    PageListStyleItem(
        name: 'ranklist'.tr, route: Routes.ranklist, show: () => true),
    PageListStyleItem(
        name: 'favorite'.tr, route: Routes.favorite, show: () => true),
    PageListStyleItem(
        name: 'watched'.tr, route: Routes.watched, show: () => true),
    PageListStyleItem(
        name: 'history'.tr, route: Routes.history, show: () => true),
  ];

  Map<String, bool> showMap = {
    Routes.gallerys: false,
    Routes.dashboard: false,
    Routes.desktopSearch: false,
    Routes.mobileV2Search: false,
    Routes.popular: false,
    Routes.ranklist: false,
    Routes.favorite: false,
    Routes.watched: false,
    Routes.history: false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('pageListStyle'.tr)),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.only(top: 16),
          children: items
              .where((item) => item.show())
              .map(
                (item) => moonListTile(
                  title: item.name,
                  trailing: dropdownButton<ListMode?>(
                      show: showMap[item.route]!,
                      onTapOutside: () =>
                          setState(() => showMap[item.route] = false),
                      content: [
                        MoonMenuItem(
                          label: Text('global'.tr).small(),
                          onTap: () {
                            setState(() {
                              showMap[item.route] = false;
                              styleSetting.savePageListMode(item.route, null);
                            });
                          },
                        ),
                        MoonMenuItem(
                          label: Text('flat'.tr).small(),
                          onTap: () {
                            setState(() {
                              showMap[item.route] = false;
                              styleSetting.savePageListMode(
                                  item.route, ListMode.flat);
                            });
                          },
                        ),
                        MoonMenuItem(
                          label: Text('flatWithoutTags'.tr).small(),
                          onTap: () {
                            setState(() {
                              showMap[item.route] = false;
                              styleSetting.savePageListMode(
                                  item.route, ListMode.flatWithoutTags);
                            });
                          },
                        ),
                        MoonMenuItem(
                          label: Text('listWithTags'.tr).small(),
                          onTap: () {
                            setState(() {
                              showMap[item.route] = false;
                              styleSetting.savePageListMode(
                                  item.route, ListMode.listWithTags);
                            });
                          },
                        ),
                        MoonMenuItem(
                          label: Text('listWithoutTags'.tr).small(),
                          onTap: () {
                            setState(() {
                              showMap[item.route] = false;
                              styleSetting.savePageListMode(
                                  item.route, ListMode.listWithoutTags);
                            });
                          },
                        ),
                        MoonMenuItem(
                          label: Text('waterfallFlowSmall'.tr).small(),
                          onTap: () {
                            setState(() {
                              showMap[item.route] = false;
                              styleSetting.savePageListMode(
                                  item.route, ListMode.waterfallFlowSmall);
                            });
                          },
                        ),
                        MoonMenuItem(
                          label: Text('waterfallFlowMedium'.tr).small(),
                          onTap: () {
                            setState(() {
                              showMap[item.route] = false;
                              styleSetting.savePageListMode(
                                  item.route, ListMode.waterfallFlowMedium);
                            });
                          },
                        ),
                        MoonMenuItem(
                          label: Text('waterfallFlowBig'.tr).small(),
                          onTap: () {
                            setState(() {
                              showMap[item.route] = false;
                              styleSetting.savePageListMode(
                                  item.route, ListMode.waterfallFlowBig);
                            });
                          },
                        ),
                      ],
                      child: filledButton(
                        label: styleSetting.pageListMode[item.route] == null
                            ? 'global'.tr
                            : styleSetting.pageListMode[item.route] ==
                                    ListMode.flat
                                ? 'flat'.tr
                                : styleSetting.pageListMode[item.route] ==
                                        ListMode.flatWithoutTags
                                    ? 'flatWithoutTags'.tr
                                    : styleSetting.pageListMode[item.route] ==
                                            ListMode.listWithTags
                                        ? 'listWithTags'.tr
                                        : styleSetting
                                                    .pageListMode[item.route] ==
                                                ListMode.listWithoutTags
                                            ? 'listWithoutTags'.tr
                                            : styleSetting.pageListMode[
                                                        item.route] ==
                                                    ListMode.waterfallFlowSmall
                                                ? 'waterfallFlowSmall'.tr
                                                : styleSetting.pageListMode[
                                                            item.route] ==
                                                        ListMode
                                                            .waterfallFlowMedium
                                                    ? 'waterfallFlowMedium'.tr
                                                    : 'waterfallFlowBig'.tr,
                        onPressed: () {
                          setState(() {
                            showMap[item.route] = !showMap[item.route]!;
                          });
                        },
                      )),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class PageListStyleItem {
  final String name;
  final String route;
  final ValueGetter<bool> show;

  const PageListStyleItem(
      {required this.name, required this.route, required this.show});
}
