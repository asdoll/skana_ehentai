import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart' show MoonTextButton;
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

class IconTextButton extends StatelessWidget {
  final double? height;
  final double? width;
  final Icon icon;
  final Widget text;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  const IconTextButton({
    Key? key,
    this.height,
    this.width,
    required this.icon,
    required this.text,
    this.onPressed,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: MoonTextButton(
          onTap: onPressed,
          label: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [icon.paddingBottom(2), text],
          ),
        ),
      ),
    );
  }
}
