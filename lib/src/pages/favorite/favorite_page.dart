import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../base/base_page.dart';
import 'favorite_page_logic.dart';
import 'favorite_page_state.dart';

class FavoritePage extends BasePage {
  const FavoritePage({
    super.key,
    super.showMenuButton,
    super.showTitle,
    super.name,
  }) : super(
          showJumpButton: true,
          showFilterButton: true,
          showScroll2TopButton: true,
        );

  @override
  FavoritePageLogic get logic =>
      Get.put<FavoritePageLogic>(FavoritePageLogic(), permanent: true);

  @override
  FavoritePageState get state => Get.find<FavoritePageLogic>().state;

  @override
  List<Widget> buildAppBarActions() {
    return [
      if (state.gallerys.isNotEmpty)
        MoonEhButton.md(
            icon: BootstrapIcons.send, onTap: logic.handleTapJumpButton),
      if (state.gallerys.isNotEmpty)
        MoonEhButton.md(
            icon: BootstrapIcons.funnel, onTap: logic.handleChangeSortOrder),
      MoonEhButton.md(
          icon: BootstrapIcons.filter, onTap: logic.handleTapFilterButton),
    ];
  }
}
