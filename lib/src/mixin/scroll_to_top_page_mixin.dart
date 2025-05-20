import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/mixin/scroll_to_top_logic_mixin.dart';
import 'package:skana_ehentai/src/mixin/scroll_to_top_state_mixin.dart';

mixin Scroll2TopPageMixin on Widget {
  Scroll2TopLogicMixin get scroll2TopLogic;

  Scroll2TopStateMixin get scroll2TopState;

  Widget buildFloatingActionButton() {
    return GetBuilder<Scroll2TopLogicMixin>(
      id: scroll2TopLogic.scroll2TopButtonId,
      global: false,
      init: scroll2TopLogic,
      builder: (_) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: scroll2TopLogic.shouldDisplayFAB
              ? MoonButton.icon(
                  buttonSize: MoonButtonSize.lg,
                  showBorder: true,
                  borderColor: Get
                      .context?.moonTheme?.buttonTheme.colors.borderColor
                      .withValues(alpha: 0.5),
                  backgroundColor: Get.context?.moonTheme?.tokens.colors.zeno,
                  onTap: scroll2TopLogic.scroll2Top,
                  icon: Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                  ),
                )
              : null,
        );
      },
    );
  }
}
