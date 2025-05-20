import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/utils/route_util.dart';
import 'package:skana_ehentai/src/utils/toast_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

import 'eh_group_name_selector.dart';

class EHDownloadDialog extends StatefulWidget {
  final String title;
  final String? currentGroup;
  final List<String> candidates;
  final bool showDownloadOriginalImageCheckBox;
  final bool downloadOriginalImage;

  const EHDownloadDialog({
    super.key,
    required this.title,
    this.currentGroup,
    required this.candidates,
    this.showDownloadOriginalImageCheckBox = false,
    this.downloadOriginalImage = false,
  });

  @override
  State<EHDownloadDialog> createState() => _EHDownloadDialogState();
}

class _EHDownloadDialogState extends State<EHDownloadDialog> {
  late String group;
  late List<String> candidates;
  late bool downloadOriginalImage;

  @override
  void initState() {
    super.initState();

    group =
        widget.currentGroup ?? widget.candidates.firstOrNull ?? 'default'.tr;
    candidates = List.of(widget.candidates);
    candidates.remove(group);
    candidates.insert(0, group);
    downloadOriginalImage = widget.downloadOriginalImage;
  }

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
        context: context,
        title: widget.title,
        contentWidget: _buildBody(),
        actions: [
          outlinedButton(onPressed: backRoute, label: 'cancel'.tr),
          filledButton(
            onPressed: () {
              if (group.isEmpty) {
                toast('invalid'.tr);
                backRoute();
                return;
              }
              backRoute(
                result: (
                  group: group,
                  downloadOriginalImage: downloadOriginalImage
                ),
              );
            },
            label: 'OK'.tr,
          ),
        ]);
  }

  Widget _buildBody() {
    return SizedBox(
      width: UIConfig.downloadDialogWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EHGroupNameSelector(
            currentGroup: widget.currentGroup ?? 'default'.tr,
            candidates: candidates,
            listener: (g) => group = g,
          ),
          if (widget.showDownloadOriginalImageCheckBox)
            _buildDownloadOriginalImageCheckBox().marginOnly(top: 8),
        ],
      ),
    );
  }

  Widget _buildDownloadOriginalImageCheckBox() {
    return SizedBox(
      height: UIConfig.downloadDialogCheckBoxHeight,
      width: UIConfig.downloadDialogWidth,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('${'downloadOriginalImage'.tr} ?',
                  style: const TextStyle(
                      fontSize: UIConfig.groupDialogCheckBoxTextSize))
              .small(),
          MoonCheckbox(
            value: downloadOriginalImage,
            onChanged: (bool? value) =>
                setState(() => downloadOriginalImage = (value ?? true)),
          ),
        ],
      ),
    );
  }
}
