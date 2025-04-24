import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/utils/route_util.dart';
import 'package:skana_ehentai/src/utils/toast_util.dart';

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

    group = widget.currentGroup ?? widget.candidates.firstOrNull ?? 'default'.tr;
    candidates = List.of(widget.candidates);
    candidates.remove(group);
    candidates.insert(0, group);
    downloadOriginalImage = widget.downloadOriginalImage;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 12, top: 24),
      actionsPadding: const EdgeInsets.only(left: 24, right: 20, bottom: 12),
      content: _buildBody(),
      actions: [
        TextButton(onPressed: backRoute, child: Text('cancel'.tr)),
        TextButton(
          onPressed: () {
            if (group.isEmpty) {
              toast('invalid'.tr);
              backRoute();
              return;
            }
            backRoute(
              result: (group: group, downloadOriginalImage: downloadOriginalImage),
            );
          },
          child: Text('OK'.tr),
        ),
      ],
    );
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
          if (widget.showDownloadOriginalImageCheckBox) _buildDownloadOriginalImageCheckBox().marginOnly(top: 16),
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
          Text('downloadOriginalImage'.tr + ' ?', style: const TextStyle(fontSize: UIConfig.groupDialogCheckBoxTextSize)),
          Checkbox(
            value: downloadOriginalImage,
            activeColor: UIConfig.groupDialogCheckBoxColor(context),
            onChanged: (bool? value) => setState(() => downloadOriginalImage = (value ?? true)),
          ),
        ],
      ),
    );
  }
}
