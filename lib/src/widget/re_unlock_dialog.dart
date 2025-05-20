import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import '../utils/route_util.dart';

class ReUnlockDialog extends StatelessWidget {
  const ReUnlockDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context: context,
      title: '${'reUnlock'.tr} ?',
      content: 'reUnlockHint'.tr,
      actions: [
        outlinedButton(
          onPressed: backRoute,
          label: 'cancel'.tr,
        ),
        filledButton(
          label: 'OK'.tr,
          onPressed: () => backRoute(result: true),
        ),
      ],
    );
  }
}
