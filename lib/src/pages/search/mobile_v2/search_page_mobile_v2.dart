import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/pages/search/mobile_v2/search_page_mobile_v2_logic.dart';
import 'package:skana_ehentai/src/pages/search/mobile_v2/search_page_mobile_v2_state.dart';
import 'package:skana_ehentai/src/setting/preference_setting.dart';
import 'package:skana_ehentai/src/utils/uuid_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

import '../../base/base_page.dart';
import '../mixin/search_page_mixin.dart';
import '../mixin/search_page_state_mixin.dart';
import '../quick_search/quick_search_page.dart';

class SearchPageMobileV2 extends BasePage<SearchPageMobileV2Logic, SearchPageMobileV2State>
    with SearchPageMixin<SearchPageMobileV2Logic, SearchPageMobileV2State> {
  final String tag = newUUID();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  SearchPageMobileV2({super.key}) : super(showJumpButton: true, showScroll2TopButton: true) {
    logic = Get.put(SearchPageMobileV2Logic(), tag: tag);
    state = logic.state;
  }

  @override
  late final SearchPageMobileV2Logic logic;

  @override
  late final SearchPageMobileV2State state;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchPageMobileV2Logic>(
      global: false,
      init: logic,
      builder: (_) => Obx(
        () => Scaffold(
          key: scaffoldKey,
          appBar: buildAppBar(context),
          drawerEdgeDragWidth: preferenceSetting.drawerGestureEdgeWidth.value.toDouble(),
          endDrawer: Drawer(width: 278, child: QuickSearchPage()),
          endDrawerEnableOpenDragGesture: preferenceSetting.enableQuickSearchDrawerGesture.isTrue,
          body: SafeArea(child: buildBody(context)),
          floatingActionButton: buildFloatingActionButton(),
          resizeToAvoidBottomInset: false,
        ),
      ),
    );
  }

  @override
  AppBar? buildAppBar(BuildContext context) {
    return appBar(
      title: state.totalCount?.toPrintString(),
      actions: buildActionButtons(visualDensity: const VisualDensity(horizontal: -4)),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        buildSearchField().paddingAll(8),
        if (state.bodyType == SearchPageBodyType.suggestionAndHistory)
          GetBuilder<SearchPageMobileV2Logic>(
            id: logic.suggestionBodyId,
            global: false,
            init: logic,
            builder: (_) => state.inputGalleryUrl == null && state.inputGalleryImagePageUrl == null
                ? Expanded(child: buildSuggestionAndHistoryBody(context))
                : buildOpenGalleryArea(),
          )
        else if (state.hasSearched)
          Expanded(
            child: GetBuilder<SearchPageMobileV2Logic>(
              id: logic.galleryBodyId,
              global: false,
              init: logic,
              builder: (_) => super.buildBody(context),
            ),
          ),
      ],
    );
  }
}
