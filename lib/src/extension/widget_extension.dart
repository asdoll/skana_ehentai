import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/widget/eh_keyboard_listener.dart';
import 'package:skana_ehentai/src/widget/eh_mouse_button_listener.dart';

import '../utils/route_util.dart';

extension WidgetExtension on Widget {
  Widget center([Key? key]) {
    return Center(key: key, child: this);
  }

  Widget fadeIn([Key? key]) {
    return FadeIn(key: key, child: this);
  }

  Widget fadeOut([Key? key]) {
    return FadeOut(key: key, animate: true, child: this);
  }

  Widget withListTileTheme(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.copyWith(
              bodyMedium: TextStyle(fontSize: UIConfig.settingPageListTileSubTitleTextSize, color: UIConfig.onBackGroundColor(context)),
              bodySmall: TextStyle(color: UIConfig.settingPageListTileSubTitleColor(context)),
            ),
      ),
      child: this,
    );
  }

  Widget withEscOrFifthButton2BackRightRoute() {
    return EHKeyboardListener(
      handleEsc: popRightRoute,
      child: EHMouseButtonListener(
        onFifthButtonTapDown: (_) => popRightRoute(),
        child: this,
      ),
    );
  }

  Widget enableMouseDrag({bool withScrollBar = true}) {
    return ScrollConfiguration(
      behavior: withScrollBar ? UIConfig.scrollBehaviourWithScrollBarWithMouse : UIConfig.scrollBehaviourWithoutScrollBarWithMouse,
      child: this,
    );
  }
}

extension StateExtension on State {
  void setStateSafely(VoidCallback fn) {
    if (mounted) {
      // ignore: invalid_use_of_protected_member
      setState(fn);
    }
  }
}
