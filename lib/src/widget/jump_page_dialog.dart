import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/utils/route_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

class JumpPageDialog extends StatefulWidget {
  final int totalPageNo;
  final int currentNo;

  const JumpPageDialog(
      {super.key, required this.totalPageNo, required this.currentNo});

  @override
  State<JumpPageDialog> createState() => _JumpPageDialogState();
}

class _JumpPageDialogState extends State<JumpPageDialog> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context: context,
      title: 'jumpPageTo'.tr,
      contentWidget: MoonTextInput(
        controller: controller,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        hintText:
            '${'range'.tr}: 1 - ${widget.totalPageNo}, ${'current'.tr}: ${widget.currentNo}',
        onSubmitted: (_) => backRoute(
            result: controller.text.isEmpty
                ? null
                : int.parse(controller.text) - 1),
      ).paddingBottom(16),
      actions: [
        filledButton(
          label: 'OK'.tr,
          onPressed: () {
            if (controller.text.isNotEmpty) {
              backRoute(result: int.parse(controller.text) - 1);
            }
          },
        ),
      ],
    );
  }
}
