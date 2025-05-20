import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

import '../network/eh_request.dart';
import '../utils/route_util.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context: context,
      title: '${'logout'.tr} ?',
      actions: [
        outlinedButton(onPressed: backRoute, label: 'cancel'.tr),
        filledButton(
          label: 'OK'.tr,
          onPressed: () async {
            await ehRequest.requestLogout();
            backRoute();
          },
        ),
      ],
    );
  }
}
