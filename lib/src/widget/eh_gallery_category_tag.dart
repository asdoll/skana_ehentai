import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

class EHGalleryCategoryTag extends StatelessWidget {
  final String category;
  final double? height;
  final double? width;
  final double borderRadius;
  final bool enabled;
  final Color? color;
  final EdgeInsets padding;
  final TextStyle textStyle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSecondaryTap;
  final MoonButtonSize? size; 

  const EHGalleryCategoryTag({
    super.key,
    required this.category,
    this.height,
    this.width,
    this.borderRadius = 8,
    this.enabled = true,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    this.textStyle =
        const TextStyle(color: UIConfig.galleryCategoryTagTextColor),
    this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.size = MoonButtonSize.sm
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onSecondaryTap: onSecondaryTap,
      child: Container(
        alignment: Alignment.center,
        height: height,
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          color: enabled
              ? color ?? UIConfig.galleryCategoryColor[category]
              : UIConfig.galleryCategoryTagDisabledBackGroundColor(context),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Transform.translate(
            offset: const Offset(0, -1),
            child: Text(category,
                    style: enabled
                        ? textStyle
                        : textStyle.copyWith(
                            color: UIConfig.galleryCategoryTagDisabledTextColor(
                                context)))
                .of(size)),
      ),
    );
  }
}
