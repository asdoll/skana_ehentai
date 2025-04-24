import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/extension/dio_exception_extension.dart';
import 'package:skana_ehentai/src/extension/get_logic_extension.dart';
import 'package:skana_ehentai/src/pages/base/base_page_logic.dart';
import '../../mixin/scroll_to_top_state_mixin.dart';
import '../../model/gallery.dart';
import '../../service/log.dart';
import '../../utils/snack_util.dart';
import '../../utils/uuid_util.dart';
import '../../widget/jump_page_dialog.dart';
import '../../widget/loading_state_indicator.dart';
import 'old_base_page_state.dart';

/// load pages by page index, not by nextGid or prevGid, to deal with EHentai's old search rule
abstract class OldBasePageLogic extends BasePageLogic {
  @override
  OldBasePageState get state;

  @override
  Scroll2TopStateMixin get scroll2TopState => state;

  /// pull-down
  @override
  Future<void> handlePullDown() async {
    if (state.prevPageIndexToLoad == null) {
      return handleRefresh();
    }

    return loadBefore();
  }

  /// clear current data first, then refresh
  @override
  Future<void> handleClearAndRefresh() async {
    if (state.loadingState == LoadingState.loading) {
      return;
    }

    state.loadingState = LoadingState.loading;

    state.gallerys.clear();
    state.prevPageIndexToLoad = null;
    state.nextPageIndexToLoad = 0;
    state.pageCount = -1;

    jump2Top();

    updateSafely();

    loadMore(checkLoadingState: false);
  }

  /// not clear current data before refresh
  /// updateId is for subclass to override
  @override
  Future<void> handleRefresh({String? updateId}) async {
    if (state.refreshState == LoadingState.loading) {
      return;
    }

    state.refreshState = LoadingState.loading;
    updateSafely([refreshStateId]);

    List<dynamic> gallerysAndPageInfo;
    try {
      gallerysAndPageInfo = await getGallerysAndPageInfoByPage(0);
    } on DioException catch (e) {
      log.error('refreshGalleryFailed'.tr, e.errorMsg);
      snack('refreshGalleryFailed'.tr, e.errorMsg ?? '', isShort: true);
      state.refreshState = LoadingState.error;
      updateSafely([refreshStateId]);
      return;
    }

    List<Gallery> gallerys = await super.postHandleNewGallerys(gallerysAndPageInfo[0], cleanDuplicate: false);

    state.gallerys = gallerys;
    state.pageCount = gallerysAndPageInfo[1];
    state.prevPageIndexToLoad = gallerysAndPageInfo[2];
    state.nextPageIndexToLoad = gallerysAndPageInfo[3];
    state.galleryCollectionKey = Key(newUUID());

    state.refreshState = LoadingState.idle;
    if (state.pageCount == 0) {
      state.loadingState = LoadingState.noData;
      state.nextPageIndexToLoad = 0;
    } else if (state.nextPageIndexToLoad == null) {
      state.loadingState = LoadingState.noMore;
    } else {
      state.loadingState = LoadingState.idle;
    }

    if (updateId != null) {
      updateSafely([updateId]);
    } else {
      updateSafely();
    }
  }

  /// pull-down to load page before(after jumping to a certain page), after load, we must restore [state.downloadState]
  /// to [prevState] in case of [prevState] is [noMore]
  @override
  Future<void> loadBefore() async {
    if (state.loadingState == LoadingState.loading) {
      return;
    }

    LoadingState prevState = state.loadingState;
    state.loadingState = LoadingState.loading;

    List<dynamic> gallerysAndPageInfo;
    try {
      gallerysAndPageInfo = await getGallerysAndPageInfoByPage(state.prevPageIndexToLoad!);
    } on DioException catch (e) {
      log.error('getGallerysFailed'.tr, e.errorMsg);
      snack('getGallerysFailed'.tr, e.errorMsg ?? '', isShort: true);
      state.loadingState = prevState;
      updateSafely([loadingStateId]);
      return;
    }

    List<Gallery> gallerys = await super.postHandleNewGallerys(gallerysAndPageInfo[0]);

    state.gallerys.insertAll(0, gallerys);
    state.pageCount = gallerysAndPageInfo[1];
    state.prevPageIndexToLoad = gallerysAndPageInfo[2];

    state.loadingState = prevState;
    updateSafely();
  }

  /// has scrolled to bottom, so need to load more data.
  @override
  Future<void> loadMore({bool checkLoadingState = true}) async {
    if (checkLoadingState && state.loadingState == LoadingState.loading) {
      return;
    }

    LoadingState prevState = state.loadingState;
    state.loadingState = LoadingState.loading;

    if (state.gallerys.isEmpty) {
      /// for [CenterStatusIndicator]
      updateSafely([bodyId]);
    } else if (prevState == LoadingState.error || prevState == LoadingState.noData) {
      /// for [LoadMoreIndicator]
      updateSafely([loadingStateId]);
    }

    List<dynamic> gallerysAndPageInfo;
    try {
      gallerysAndPageInfo = await getGallerysAndPageInfoByPage(state.nextPageIndexToLoad!);
    } on DioException catch (e) {
      log.error('getGallerysFailed'.tr, e.errorMsg);
      snack('getGallerysFailed'.tr, e.errorMsg ?? '', isShort: true);
      state.loadingState = LoadingState.error;
      updateSafely([loadingStateId]);
      return;
    }

    List<Gallery> gallerys = await super.postHandleNewGallerys(gallerysAndPageInfo[0]);

    state.gallerys.addAll(gallerys);
    state.pageCount = gallerysAndPageInfo[1];
    state.nextPageIndexToLoad = gallerysAndPageInfo[3];

    if (state.pageCount == 0) {
      state.loadingState = LoadingState.noData;
      state.nextPageIndexToLoad = 0;
    } else if (state.nextPageIndexToLoad == null) {
      state.loadingState = LoadingState.noMore;
    } else {
      state.loadingState = LoadingState.idle;
    }

    updateSafely();
  }

  Future<void> jumpPageByIndex(int pageIndex) async {
    if (state.loadingState == LoadingState.loading) {
      return;
    }

    state.gallerys.clear();
    state.loadingState = LoadingState.loading;
    updateSafely();
    state.scrollController.jumpTo(0);

    pageIndex = max(pageIndex, 0);
    pageIndex = min(pageIndex, state.pageCount - 1);
    state.prevPageIndexToLoad = null;
    state.nextPageIndexToLoad = 0;

    List<dynamic> gallerysAndPageInfo;
    try {
      gallerysAndPageInfo = await getGallerysAndPageInfoByPage(pageIndex);
    } on DioException catch (e) {
      log.error('refreshGalleryFailed'.tr, e.errorMsg);
      snack('refreshGalleryFailed'.tr, e.errorMsg ?? '', isShort: true);
      state.loadingState = LoadingState.error;
      updateSafely([loadingStateId]);
      return;
    }

    List<Gallery> gallerys = await postHandleNewGallerys(gallerysAndPageInfo[0]);

    state.gallerys.addAll(gallerys);
    state.pageCount = gallerysAndPageInfo[1];
    state.prevPageIndexToLoad = gallerysAndPageInfo[2];
    state.nextPageIndexToLoad = gallerysAndPageInfo[3];

    if (state.pageCount == 0) {
      state.loadingState = LoadingState.noData;
      state.nextPageIndexToLoad = 0;
    } else if (state.nextPageIndexToLoad == null) {
      state.loadingState = LoadingState.noMore;
    } else {
      state.loadingState = LoadingState.idle;
    }

    updateSafely();
  }

  @override
  Future<void> handleTapJumpButton() async {
    int? pageIndex = await Get.dialog(
      JumpPageDialog(
        totalPageNo: state.pageCount,
        currentNo: state.nextPageIndexToLoad ?? state.pageCount,
      ),
    );

    if (pageIndex != null) {
      jumpPageByIndex(pageIndex);
    }
  }

  Future<List<dynamic>> getGallerysAndPageInfoByPage(int pageIndex);
}
