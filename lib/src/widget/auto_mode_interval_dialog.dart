import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/setting/read_setting.dart';

import '../config/ui_config.dart';
import '../utils/route_util.dart';

class AutoModeIntervalDialog extends StatefulWidget {
  const AutoModeIntervalDialog({Key? key}) : super(key: key);

  @override
  State<AutoModeIntervalDialog> createState() => _AutoModeIntervalDialogState();
}

class _AutoModeIntervalDialogState extends State<AutoModeIntervalDialog> {
  double interval = readSetting.autoModeInterval.value;
  FixedExtentScrollController scrollController = FixedExtentScrollController(initialItem: readSetting.autoModeInterval.value ~/ 0.5 - 1);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 6),
      actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      title: Text('autoModeInterval'.tr),
      content: SizedBox(
        height: 150,
        child: CupertinoPicker.builder(
          itemExtent: 30,
          onSelectedItemChanged: (index) => interval = (index + 1) * 0.5,
          scrollController: scrollController,
          itemBuilder: (_, int index) => Center(
            child: Text('${(index + 1) * 0.5} s', style: TextStyle(color: UIConfig.onBackGroundColor(context))),
          ),
          childCount: 39,
        ),
      ),
      actions: [
        TextButton(child: Text('cancel'.tr), onPressed: backRoute),
        TextButton(
          child: Text('OK'.tr),
          onPressed: () {
            readSetting.saveAutoModeInterval(interval);
            backRoute(result: true);
          },
        ),
      ],
    ).enableMouseDrag(withScrollBar: false);
  }
}
