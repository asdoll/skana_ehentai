import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skana_ehentai/src/setting/style_setting.dart';

import '../model/jh_layout.dart';

class FocusWidget extends StatefulWidget {
  final Widget child;
  final bool enableFocus;

  final BoxDecoration? focusedDecoration;
  final BoxDecoration? foregroundDecoration;
  final VoidCallback? handleTapEnter;
  final VoidCallback? handleTapArrowLeft;
  final VoidCallback? handleTapArrowRight;

  const FocusWidget({
    Key? key,
    required this.child,
    this.enableFocus = true,
    this.focusedDecoration,
    this.foregroundDecoration,
    this.handleTapEnter,
    this.handleTapArrowLeft,
    this.handleTapArrowRight,
  }) : super(key: key);

  @override
  State<FocusWidget> createState() => _FocusWidgetState();
}

class _FocusWidgetState extends State<FocusWidget> {
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enableFocus || styleSetting.actualLayout != LayoutMode.desktop) {
      return widget.child;
    }

    return Focus(
      onFocusChange: (v) => setState(() => isFocused = v),
      onKeyEvent: (_, KeyEvent event) {
        if (event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }

        if (event.logicalKey == LogicalKeyboardKey.enter && widget.handleTapEnter != null) {
          widget.handleTapEnter?.call();
          return KeyEventResult.handled;
        }

        if (event.logicalKey == LogicalKeyboardKey.arrowLeft && widget.handleTapArrowLeft != null) {
          widget.handleTapArrowLeft?.call();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight && widget.handleTapArrowRight != null) {
          widget.handleTapArrowRight?.call();
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Container(
        foregroundDecoration: widget.foregroundDecoration,
        decoration: isFocused ? widget.focusedDecoration : null,
        child: widget.child,
      ),
    );
  }
}
