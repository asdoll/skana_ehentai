import 'package:flutter/material.dart';
import 'package:skana_ehentai/src/pages/search/desktop/desktop_search_page_tab_logic.dart';
import 'package:skana_ehentai/src/pages/search/mixin/new_search_argument.dart';
import 'package:skana_ehentai/src/setting/preference_setting.dart';

import '../../../mixin/scroll_to_top_state_mixin.dart';
import '../../../utils/uuid_util.dart';
import 'desktop_search_page_tab_view.dart';

class DesktopSearchPageState with Scroll2TopStateMixin {
  List<DesktopSearchPageTabView> tabs = [];
  List<DesktopSearchPageTabLogic> tabLogics = [];

  int currentTabIndex = 0;
  PageController pageController = PageController();
  Key tabViewKey = Key(newUUID());

  ScrollController tabController = ScrollController();

  @override
  ScrollController get scrollController => tabLogics[currentTabIndex].scroll2TopState.scrollController;

  DesktopSearchPageState() {
    DesktopSearchPageTabLogic newTabLogic = DesktopSearchPageTabLogic(
      NewSearchArgument(keyword: '', keywordSearchBehaviour: preferenceSetting.searchBehaviour.value),
      false,
    );
    tabLogics.add(newTabLogic);
    tabs.add(DesktopSearchPageTabView(key: ValueKey(newUUID()), logic: newTabLogic));
  }
}
