import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/setting/style_setting.dart';
import 'package:skana_ehentai/src/utils/screen_size_util.dart';

import '../config/ui_config.dart';

void snack(
  String title,
  String message, {
  bool isShort = true,
  VoidCallback? onPressed,
}) async {
  ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
  ScaffoldMessenger.of(Get.context!).showSnackBar(
    SnackBar(
      content: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (onPressed != null) {
            onPressed();
            ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18)),
            Text(message, style: const TextStyle(fontSize: 12)).marginOnly(top: 6),
          ],
        ),
      ),
      showCloseIcon: onPressed == null,
      action: onPressed == null ? null : SnackBarAction(label: '->', onPressed: onPressed),
      duration: Duration(milliseconds: isShort ? 3000 : 5000),
      behavior: styleSetting.isInMobileLayout ? null : SnackBarBehavior.floating,
      width: styleSetting.isInMobileLayout ? null : max(fullScreenWidth / 2, UIConfig.snackWidth),
    ),
  );
}
