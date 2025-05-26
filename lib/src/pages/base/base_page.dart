import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/pages/layout/mobile_v2/notification/tap_menu_button_notification.dart';
import 'package:skana_ehentai/src/setting/style_setting.dart';
import 'package:skana_ehentai/src/service/log.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/eh_wheel_speed_controller.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../../config/ui_config.dart';
import '../../mixin/scroll_to_top_logic_mixin.dart';
import '../../mixin/scroll_to_top_page_mixin.dart';
import '../../mixin/scroll_to_top_state_mixin.dart';
import '../../widget/eh_gallery_collection.dart';
import '../../widget/loading_state_indicator.dart';
import 'base_page_logic.dart';
import 'base_page_state.dart';

abstract class BasePage<L extends BasePageLogic, S extends BasePageState> extends StatelessWidget with Scroll2TopPageMixin {
  /// For mobile layout v2
  final bool showMenuButton;
  final bool showJumpButton;
  final bool showFilterButton;
  final bool showScroll2TopButton;
  final bool showTitle;
  final String? name;

  const BasePage({
    super.key,
    this.showMenuButton = false,
    this.showJumpButton = false,
    this.showFilterButton = false,
    this.showScroll2TopButton = false,
    this.showTitle = false,
    this.name,
  });

  L get logic;

  S get state;

  @override
  Scroll2TopLogicMixin get scroll2TopLogic => logic;

  @override
  Scroll2TopStateMixin get scroll2TopState => state;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<L>(
      global: false,
      init: logic,
      builder: (_) => Scaffold(
        backgroundColor: UIConfig.backGroundColor(context),
        appBar: showFilterButton || showJumpButton || showMenuButton || showTitle ? buildAppBar(context) : null,
        body: SafeArea(child: buildBody(context)),
        floatingActionButton: showScroll2TopButton ? buildFloatingActionButton() : null,
      ),
    );
  }

  AppBar? buildAppBar(BuildContext context) {
    return appBar(
      leading: showMenuButton ? buildAppBarMenuButton(context) : null,
      title: showTitle ? name! : "",
      actions: buildAppBarActions(),
    );
  }

  Widget buildAppBarMenuButton(BuildContext context) {
    return NormalDrawerButton(
      onTap: () => TapMenuButtonNotification().dispatch(context),
    );
  }

  List<Widget> buildAppBarActions() {
    return [
      if (showJumpButton && state.gallerys.isNotEmpty)
        MoonEhButton.md(onTap: logic.handleTapJumpButton, icon: BootstrapIcons.send),
      if (showFilterButton) MoonEhButton.md(onTap: logic.handleTapFilterButton, icon: BootstrapIcons.funnel),
    ];
  }

  Widget buildBody(BuildContext context) {
    return buildListBody(context);
  }

  Widget buildListBody(BuildContext context) {
    return GetBuilder<L>(
      id: logic.bodyId,
      global: false,
      init: logic,
      builder: (_) => state.gallerys.isEmpty && state.loadingState != LoadingState.idle
          ? buildCenterStatusIndicator()
          : NotificationListener<UserScrollNotification>(
              onNotification: logic.onUserScroll,
              child: EHWheelSpeedController(
                controller: state.scrollController,
                child: CustomScrollView(
                  key: state.pageStorageKey,
                  controller: state.scrollController,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  scrollBehavior: UIConfig.scrollBehaviourWithScrollBarWithMouse,
                  slivers: <Widget>[
                    buildPullDownIndicator(),
                    SliverToBoxAdapter(child: SizedBox(height: 4)),
                    buildGalleryCollection(context),
                    buildLoadMoreIndicator(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildCenterStatusIndicator() {
    return Center(
      child: GetBuilder<L>(
        id: logic.loadingStateId,
        global: false,
        init: logic,
        builder: (_) => LoadingStateIndicator(
          loadingState: state.loadingState,
          errorTapCallback: () {
            log.info('CenterStatusIndicator errorTapCallback => loadMore');
            logic.loadMore();
          },
          noDataTapCallback: () {
            log.info('CenterStatusIndicator noDataTapCallback => loadMore');
            logic.loadMore();
          },
        ),
      ),
    );
  }

  Widget buildPullDownIndicator() {
    return CupertinoSliverRefreshControl(
      refreshTriggerPullDistance: UIConfig.refreshTriggerPullDistance,
      onRefresh: logic.handlePullDown,
      builder: buildRefreshIndicator,
    );
  }

  Widget buildLoadMoreIndicator() {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 16, bottom: 40),
      sliver: SliverToBoxAdapter(
        child: GetBuilder<L>(
          id: logic.loadingStateId,
          global: false,
          init: logic,
          builder: (_) => LoadingStateIndicator(
            loadingState: state.loadingState,
            errorTapCallback: () {
              log.info('LoadMoreIndicator errorTapCallback => loadMore');
              logic.loadMore();
            },
          ),
        ),
      ),
    );
  }

  Widget buildGalleryCollection(BuildContext context) {
    return Obx(
      () => EHGalleryCollection(
        key: state.galleryCollectionKey,
        context: context,
        gallerys: state.gallerys,
        listMode: styleSetting.pageListMode[state.route] ?? styleSetting.listMode.value,
        loadingState: state.loadingState,
        handleTapCard: logic.handleTapGalleryCard,
        handleLongPressCard: (gallery) => logic.handleLongPressCard(context, gallery),
        handleSecondaryTapCard: (gallery) => logic.handleSecondaryTapCard(context, gallery),
        handleLoadMore: logic.loadMore,
      ),
    );
  }
}
