import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/model/search_config.dart';
import 'package:skana_ehentai/src/service/quick_search_service.dart';
import 'package:skana_ehentai/src/utils/search_util.dart';

class QuickSearchPage extends StatelessWidget {
  final bool automaticallyImplyLeading;

  const QuickSearchPage({Key? key, this.automaticallyImplyLeading = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('quickSearch'.tr),
        automaticallyImplyLeading: automaticallyImplyLeading,
        actions: const [
          IconButton(icon: Icon(Icons.add_circle_outline, size: 24), onPressed: handleAddQuickSearch),
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
                ListTile(
                  dense: true,
                  title: Text(entries[index].key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => quickSearchService.handleUpdateQuickSearch(entries[index]),
                  ).marginOnly(right: GetPlatform.isDesktop ? 24 : 0),
                  onTap: () => newSearch(rewriteSearchConfig: entries[index].value, forceNewRoute: true),
                ),
                const Divider(thickness: 0.7, height: 2),
              ],
            ),
          ).enableMouseDrag();
        },
      ),
    );
  }
}
