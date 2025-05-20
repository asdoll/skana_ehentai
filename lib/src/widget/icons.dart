import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';

class NormalBackButton extends StatelessWidget {
  final bool isDark;
  const NormalBackButton({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return MoonButton.icon(
      onTap: Get.back,
      icon: Icon(
        BootstrapIcons.arrow_left,
        color: isDark ? Colors.white : context.moonTheme?.tokens.colors.bulma,
        size: 20,
      ),
    );
  }
}

class NormalDrawerButton extends StatelessWidget {
  final VoidCallback onTap;

  const NormalDrawerButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MoonButton.icon(
      onTap: onTap,
      icon: Icon(
        BootstrapIcons.justify,
        color: context.moonTheme?.tokens.colors.bulma,
        size: 20,
      ),
    );
  }
}

class MoonEhButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final double size;
  final MoonButtonSize buttonSize;
  final Color? color;

  const MoonEhButton(
      {super.key,
      required this.onTap,
      required this.icon,
      this.size = 20,
      this.buttonSize = MoonButtonSize.sm,
      this.color});

  const MoonEhButton.md(
      {super.key,
      required this.onTap,
      required this.icon,
      this.size = 20,
      this.color})
      : buttonSize = MoonButtonSize.md;

  @override
  Widget build(BuildContext context) {
    return MoonButton.icon(
      onTap: onTap,
      buttonSize: buttonSize,
      icon: Icon(
        icon,
        color: color ?? context.moonTheme?.tokens.colors.bulma,
        size: size,
      ),
    );
  }
}

Widget progressIndicator(BuildContext context,
    {Color? color, double? size, Duration? duration}) {
  return SpinKitPulse(
    size: size ?? 30,
    color: color ?? context.moonTheme?.tokens.colors.bulma,
    duration: duration ?? const Duration(milliseconds: 1000),
  );
}
