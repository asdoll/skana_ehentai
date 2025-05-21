import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

import '../config/ui_config.dart';

class EHAppPasswordSettingDialog extends StatefulWidget {
  const EHAppPasswordSettingDialog({super.key});

  @override
  State<EHAppPasswordSettingDialog> createState() => _EHAppPasswordSettingDialogState();
}

class _EHAppPasswordSettingDialogState extends State<EHAppPasswordSettingDialog> {
  String? firstPassword;
  late String hintText;

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    hintText = 'setPasswordHint'.tr;
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context: context,
      title: "",
      contentWidget: Column(
        children: [
          SizedBox(
            height: UIConfig.authDialogPinHeight,
            width: UIConfig.authDialogPinWidth,
            child: MoonAuthCode(
            authInputFieldCount: 4,
            textController: controller,
            obscureText: true,
            autoFocus: true,
            autoDismissKeyboard: false,
            validator: (value) {
              return null;
            },
            errorBuilder: (context, error) {
              return Text(error??"", style: const TextStyle(color: Colors.red));
            },
            onCompleted: (String value) {
              if (firstPassword == null) {
                setState(() {
                  firstPassword = value;
                  hintText = 'confirmPasswordHint'.tr;
                  controller.clear();
                });
              } else {
                if (firstPassword == value) {
                  Get.back(result: value);
                } else {
                  setState(() {
                    firstPassword = null;
                    hintText = 'passwordNotMatchHint'.tr;
                    controller.clear();
                  });
                }
              }
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 4),
          alignment: Alignment.center,
          child: Text(hintText).subHeader(),
        ),
      ],
      ),
    );
  }
}
