import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

class EHAsset extends StatelessWidget {
  final int gpCount;
  final int creditCount;

  const EHAsset({super.key, required this.gpCount, required this.creditCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _CircleAssetChip(str: 'C'),
        Text(creditCount.toString()).small().marginOnly(left: 2),
        const _CircleAssetChip(str: 'G').marginOnly(left: 16),
        Text(gpCount.toString()).small().marginOnly(left: 2),
      ],
    );
  }
}

class _CircleAssetChip extends StatelessWidget {
  final String str;

  const _CircleAssetChip({required this.str});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: UIConfig.primaryColor(context), shape: BoxShape.circle),
      child: Center(
        child: Transform.translate(offset: const Offset(0, 1),
        child: Text(
          str,
          style: TextStyle(
            color: UIConfig.onPrimaryColor(context),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        ),
      ),
    );
  }
}
