import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

import '../model/gallery_page.dart';
import '../utils/route_util.dart';

class EHFavoriteSortOrderDialog extends StatefulWidget {
  final FavoriteSortOrder? init;

  const EHFavoriteSortOrderDialog({super.key, this.init});

  @override
  State<EHFavoriteSortOrderDialog> createState() =>
      _EHFavoriteSortOrderDialogState();
}

class _EHFavoriteSortOrderDialogState extends State<EHFavoriteSortOrderDialog> {
  FavoriteSortOrder? _sortOrder;

  @override
  void initState() {
    super.initState();
    _sortOrder = widget.init;
  }

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context: context,
      title: 'orderBy'.tr,
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          moonListTile(
              title: 'favoritedTime'.tr,
              onTap: () =>
                  setState(() => _sortOrder = FavoriteSortOrder.favoritedTime),
              trailing: MoonRadio(
                  value: FavoriteSortOrder.favoritedTime,
                  groupValue: _sortOrder,
                  onChanged: (_) {setState(() => _sortOrder = FavoriteSortOrder.favoritedTime);})),
          moonListTile(
              title: 'publishedTime'.tr,
              onTap: () =>
                  setState(() => _sortOrder = FavoriteSortOrder.publishedTime),
              trailing: MoonRadio(
                  value: FavoriteSortOrder.publishedTime,
                  groupValue: _sortOrder,
                  onChanged: (_) {setState(() => _sortOrder = FavoriteSortOrder.publishedTime);})),
        ],
      ).paddingBottom(16),
      actions: [
        outlinedButton(onPressed: backRoute, label: 'cancel'.tr),
        filledButton(
            label: 'OK'.tr, onPressed: () => backRoute(result: _sortOrder)),
      ],
    );
  }
}
