import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/pages/download/mixin/basic/multi_select/multi_select_download_page_mixin.dart';
import 'package:skana_ehentai/src/pages/download/mixin/gallery/gallery_download_page_state_mixin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../../../../mixin/scroll_to_top_logic_mixin.dart';
import '../../../../mixin/scroll_to_top_page_mixin.dart';
import '../../../../mixin/scroll_to_top_state_mixin.dart';
import 'gallery_download_page_logic_mixin.dart';

mixin GalleryDownloadPageMixin on StatelessWidget
    implements Scroll2TopPageMixin, MultiSelectDownloadPageMixin {
  GalleryDownloadPageLogicMixin get galleryDownloadPageLogic;

  GalleryDownloadPageStateMixin get galleryDownloadPageState;

  @override
  Scroll2TopLogicMixin get scroll2TopLogic => galleryDownloadPageLogic;

  @override
  Scroll2TopStateMixin get scroll2TopState => galleryDownloadPageState;

  @override
  List<Widget> buildBottomAppBarButtons() {
    return [
      MoonEhButton(
          icon: BootstrapIcons.check2_all,
          size: 25,
          buttonSize: MoonButtonSize.lg,
          onTap: galleryDownloadPageLogic.selectAllItem),
      MoonEhButton(
          icon: BootstrapIcons.play_circle,
          size: 25,
          buttonSize: MoonButtonSize.md,
          onTap: galleryDownloadPageLogic.handleMultiResumeTasks),
      MoonEhButton(
          icon: BootstrapIcons.pause_circle,
          size: 25,
          buttonSize: MoonButtonSize.md,
          onTap: galleryDownloadPageLogic.handleMultiPauseTasks),
      MoonEhButton(
          icon: BootstrapIcons.bookmark,
          size: 25,
          buttonSize: MoonButtonSize.md,
          onTap: galleryDownloadPageLogic.handleMultiChangeGroup),
      MoonEhButton(
          icon: BootstrapIcons.trash,
          size: 25,
          buttonSize: MoonButtonSize.md,
          onTap: galleryDownloadPageLogic.handleMultiDelete),
      const Expanded(child: SizedBox()),
      MoonEhButton(
          icon: BootstrapIcons.x,
          size: 25,
          buttonSize: MoonButtonSize.md,
          onTap: multiSelectDownloadPageLogic.exitSelectMode),
    ];
  }
}
