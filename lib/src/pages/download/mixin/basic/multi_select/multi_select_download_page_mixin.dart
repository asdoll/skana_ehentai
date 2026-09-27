import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/widget/fade_slide_widget.dart';

import 'multi_select_download_page_logic_mixin.dart';
import 'multi_select_download_page_state_mixin.dart';

mixin MultiSelectDownloadPageMixin on StatelessWidget {
  MultiSelectDownloadPageLogicMixin get multiSelectDownloadPageLogic;

  MultiSelectDownloadPageStateMixin get multiSelectDownloadPageState;

  Widget buildBottomAppBar() {
    return GetBuilder<MultiSelectDownloadPageLogicMixin>(
      id: multiSelectDownloadPageLogic.bottomAppbarId,
      init: multiSelectDownloadPageLogic,
      global: false,
      builder: (_) => Builder(
        builder: (context) => FadeSlideWidget(
          show: multiSelectDownloadPageState.inMultiSelectMode,
          axis: Axis.vertical,
          child: Padding(
            // The mobile layout's navigation bar is transparent and the page runs
            // under it, so this bar has to be lifted above it by hand - otherwise
            // the two are drawn on top of each other. 0 on the other layouts,
            // which have no such bar.
            padding: EdgeInsets.only(
                bottom: UIConfig.mobileBottomBarHeight(context)),
            child: BottomAppBar(
              color: UIConfig.downloadPageCardColor(Get.context!),
              child: Row(
                children: buildBottomAppBarButtons(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildBottomAppBarButtons();
}
