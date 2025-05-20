import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../base/base_page.dart';
import 'history_page_logic.dart';
import 'history_page_state.dart';

class HistoryPage extends BasePage {
  const HistoryPage({
    super.key,
    super.showMenuButton,
    super.showTitle,
    super.name,
  }) : super(
          showJumpButton: true,
          showScroll2TopButton: true,
        );

  @override
  HistoryPageLogic get logic =>
      Get.put<HistoryPageLogic>(HistoryPageLogic(), permanent: true);

  @override
  HistoryPageState get state => Get.find<HistoryPageLogic>().state;

  @override
  List<Widget> buildAppBarActions() {
    return [
      MoonEhButton.md(
          icon: BootstrapIcons.trash,
          onTap: logic.handleTapDeleteButton),
      ...super.buildAppBarActions(),
    ];
  }
}
