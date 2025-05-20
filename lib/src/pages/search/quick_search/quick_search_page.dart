import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/model/search_config.dart';
import 'package:skana_ehentai/src/service/quick_search_service.dart';
import 'package:skana_ehentai/src/utils/search_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

class QuickSearchPage extends StatelessWidget {
  final bool automaticallyImplyLeading;

  const QuickSearchPage({super.key, this.automaticallyImplyLeading = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        title: 'quickSearch'.tr,
        actions: [
          MoonEhButton(
            buttonSize: MoonButtonSize.lg,
            icon: BootstrapIcons.plus_circle,
            onTap: handleAddQuickSearch,
          ),
        ],
      ),
      body: GetBuilder<QuickSearchService>(
        builder: (_) {
          List<MapEntry<String, SearchConfig>> entries = quickSearchService.quickSearchConfigs.entries.toList();

          return ReorderableListView.builder(
            itemCount: quickSearchService.quickSearchConfigs.length,
            onReorder: quickSearchService.reOrderQuickSearch,
            padding: const EdgeInsets.only(bottom: 120),
            itemBuilder: (_, int index) => Column(
              key: Key(entries[index].key),
              mainAxisSize: MainAxisSize.min,
              children: [
                moonListTile(
                  title: entries[index].key,
                  trailing: MoonButton.icon(
                    buttonSize: MoonButtonSize.sm,
                    icon: moonIcon(icon: BootstrapIcons.gear),
                    onTap: () => quickSearchService.handleUpdateQuickSearch(entries[index]),
                  ).marginOnly(right: GetPlatform.isDesktop ? 24 : 0),
                  onTap: () => newSearch(rewriteSearchConfig: entries[index].value, forceNewRoute: true),
                ),
              ],
            ),
          ).enableMouseDrag();
        },
      ),
    );
  }
}
