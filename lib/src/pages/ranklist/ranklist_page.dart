import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/pages/base/base_page.dart';
import 'package:skana_ehentai/src/pages/ranklist/ranklist_page_logic.dart';
import 'package:skana_ehentai/src/pages/ranklist/ranklist_page_state.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

class RanklistPage extends BasePage {
  const RanklistPage({
    super.key,
    super.showMenuButton,
    super.showTitle,
    super.showScroll2TopButton = true,
  }) : super(
          showJumpButton: true,
        );

  @override
  RanklistPageLogic get logic => Get.put<RanklistPageLogic>(RanklistPageLogic(), permanent: true);

  @override
  RanklistPageState get state => Get.find<RanklistPageLogic>().state;

  @override
  AppBar? buildAppBar(BuildContext context) {
    return appBar(
      title: '${state.ranklistType.name.tr} ${'ranklist'.tr}',
      leading: showMenuButton ? super.buildAppBarMenuButton(context) : null,
      actions: [
        ...super.buildAppBarActions(),
        popupMenuButton(
          tooltip: '',
          onSelected: logic.handleChangeRanklist,
          constraints: BoxConstraints(maxWidth: 100),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<RanklistType>>[
            PopupMenuItem<RanklistType>(value: RanklistType.allTime, child: Center(child: Text('allTime'.tr).small())),
            PopupMenuItem<RanklistType>(value: RanklistType.year, child: Center(child: Text('year'.tr).small())),
            PopupMenuItem<RanklistType>(value: RanklistType.month, child: Center(child: Text('month'.tr).small())),
            PopupMenuItem<RanklistType>(value: RanklistType.day, child: Center(child: Text('day'.tr).small())),
          ],
        ),
      ],
    );
  }
}
