import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/enum/config_type_enum.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

import '../utils/route_util.dart';

class EHConfigTypeSelectDialog extends StatefulWidget {
  final String title;

  const EHConfigTypeSelectDialog({super.key, required this.title});

  @override
  State<EHConfigTypeSelectDialog> createState() => _EHConfigTypeSelectDialogState();
}

class _EHConfigTypeSelectDialogState extends State<EHConfigTypeSelectDialog> {
  List<CloudConfigTypeEnum> selected = [...CloudConfigTypeEnum.values];

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context: context,
      title: widget.title,
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: CloudConfigTypeEnum.values
            .map((e) => moonListTile(
                  title: e.name.tr,
                  trailing: MoonSwitch(
                    value: selected.contains(e),
                    onChanged: (bool? value) {
                      setStateSafely(() {
                        if (value ?? false) {
                        selected.add(e);
                      } else {
                        selected.remove(e);
                      }
                    });
                  },
                )))
            .toList(),
      ).paddingBottom(16),
      actions: [
        outlinedButton(onPressed: backRoute, label: 'cancel'.tr),
        filledButton(onPressed: () => backRoute(result: selected), label: 'OK'.tr),
      ],
    );
  }
}
