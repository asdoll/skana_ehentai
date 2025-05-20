import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/utils/route_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

class EHDialog extends StatelessWidget {
  final String title;
  final String? content;
  final bool showCancelButton;

  const EHDialog({
    super.key,
    required this.title,
    this.content,
    this.showCancelButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context: context,
      title: title,
      content: content,
      actions:[
        if (showCancelButton)
          outlinedButton(onPressed: backRoute, label: 'cancel'.tr),
        filledButton(onPressed: () => backRoute(result: true), label: 'OK'.tr),
      ],
    );
  }
}
