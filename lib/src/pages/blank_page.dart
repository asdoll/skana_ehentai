import 'package:flutter/material.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';

class BlankPage extends StatelessWidget {
  const BlankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: UIConfig.backGroundColor(context),
      child: Center(
        child: Text(
          'S',
          style: TextStyle(color: UIConfig.jHentaiIconColor(context), fontSize: 120, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
