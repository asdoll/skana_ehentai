import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/pages/download/mixin/basic/multi_select/multi_select_download_page_mixin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../../../../mixin/scroll_to_top_logic_mixin.dart';
import '../../../../mixin/scroll_to_top_page_mixin.dart';
import '../../../../mixin/scroll_to_top_state_mixin.dart';
import '../basic/multi_select/multi_select_download_page_logic_mixin.dart';
import '../basic/multi_select/multi_select_download_page_state_mixin.dart';
import 'archive_download_page_logic_mixin.dart';
import 'archive_download_page_state_mixin.dart';

mixin ArchiveDownloadPageMixin on StatelessWidget
    implements Scroll2TopPageMixin, MultiSelectDownloadPageMixin {
  ArchiveDownloadPageLogicMixin get archiveDownloadPageLogic;

  ArchiveDownloadPageStateMixin get archiveDownloadPageState;

  @override
  Scroll2TopLogicMixin get scroll2TopLogic => archiveDownloadPageLogic;

  @override
  Scroll2TopStateMixin get scroll2TopState => archiveDownloadPageState;

  @override
  MultiSelectDownloadPageLogicMixin get multiSelectDownloadPageLogic =>
      archiveDownloadPageLogic;

  @override
  MultiSelectDownloadPageStateMixin get multiSelectDownloadPageState =>
      archiveDownloadPageState;

  @override
  List<Widget> buildBottomAppBarButtons() {
    return [
      MoonEhButton(
          icon: BootstrapIcons.check2_all,
          size: 25,
          buttonSize: MoonButtonSize.lg,
          onTap: archiveDownloadPageLogic.selectAllItem),
      MoonEhButton(
          icon: BootstrapIcons.play_circle,
          size: 25,
          buttonSize: MoonButtonSize.md,
          onTap: archiveDownloadPageLogic.handleMultiResumeTasks),
      MoonEhButton(
          icon: BootstrapIcons.pause_circle,
          size: 25,
          buttonSize: MoonButtonSize.md,
          onTap: archiveDownloadPageLogic.handleMultiPauseTasks),
      MoonEhButton(
          icon: BootstrapIcons.bookmark,
          size: 25,
          buttonSize: MoonButtonSize.md,
          onTap: archiveDownloadPageLogic.handleMultiChangeGroup),
      MoonEhButton(
          icon: BootstrapIcons.trash,
          size: 25,
          buttonSize: MoonButtonSize.md,
          onTap: archiveDownloadPageLogic.handleMultiDelete),
      MoonEhButton(
          icon: BootstrapIcons.robot,
          size: 25,
          buttonSize: MoonButtonSize.md,
          onTap: archiveDownloadPageLogic.handleChangeParseSource),
      const Expanded(child: SizedBox()),
      MoonEhButton(
          icon: BootstrapIcons.x,
          size: 25,
          buttonSize: MoonButtonSize.md,
          onTap: multiSelectDownloadPageLogic.exitSelectMode),
    ];
  }
}
