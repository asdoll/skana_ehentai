import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/extension/dio_exception_extension.dart';
import 'package:skana_ehentai/src/extension/get_logic_extension.dart';
import 'package:skana_ehentai/src/mixin/scroll_to_top_logic_mixin.dart';
import 'package:skana_ehentai/src/pages/details/details_page_logic.dart';
import 'package:skana_ehentai/src/pages/details/details_page_state.dart';
import 'package:skana_ehentai/src/pages/details/thumbnails/thumbnails_page_state.dart';

import '../../../exception/eh_site_exception.dart';
import '../../../mixin/scroll_to_top_state_mixin.dart';
import '../../../model/detail_page_info.dart';
import '../../../network/eh_request.dart';
import '../../../utils/eh_spider_parser.dart';
import '../../../service/log.dart';
import '../../../utils/snack_util.dart';
import '../../../widget/jump_page_dialog.dart';
import '../../../widget/loading_state_indicator.dart';

class ThumbnailsPageLogic extends GetxController with Scroll2TopLogicMixin {
  static const String thumbnailsId = 'thumbnailsId';
  static const String loadingStateId = 'loadingStateId';

  ThumbnailsPageState state = ThumbnailsPageState();

  @override
  Scroll2TopStateMixin get scroll2TopState => state;

  DetailsPageLogic detailsPageLogic = DetailsPageLogic.current!;
  DetailsPageState detailsPageState = DetailsPageLogic.current!.state;

  @override
  void onReady() {
    super.onReady();
    loadMoreThumbnails();
  }

  Future<void> loadMoreThumbnails() async {
    if (state.loadingState == LoadingState.loading) {
      return;
    }

    /// no more thumbnails
    if (state.nextPageIndexToLoadThumbnails >= detailsPageState.galleryDetails!.thumbnailsPageCount) {
      state.loadingState = LoadingState.noMore;
      updateSafely([loadingStateId]);
      return;
    }

    state.loadingState = LoadingState.loading;
    updateSafely([loadingStateId]);

    DetailPageInfo detailPageInfo;
    try {
      detailPageInfo = await ehRequest.requestDetailPage(
        galleryUrl: detailsPageState.galleryUrl.url,
        thumbnailsPageIndex: state.nextPageIndexToLoadThumbnails,
        parser: EHSpiderParser.detailPage2RangeAndThumbnails,
      );
    } on DioException catch (e) {
      log.error('failToGetThumbnails'.tr, e.errorMsg);
      snack('failToGetThumbnails'.tr, e.errorMsg ?? '', isShort: true);
      state.loadingState = LoadingState.error;
      updateSafely([loadingStateId]);
      return;
    } on EHSiteException catch (e) {
      log.error('failToGetThumbnails'.tr, e.message);
      snack('failToGetThumbnails'.tr, e.message, isShort: true);
      state.loadingState = LoadingState.error;
      updateSafely([loadingStateId]);
      return;
    }

    state.thumbnails.addAll(detailPageInfo.thumbnails);
    for (int i = detailPageInfo.imageNoFrom; i <= detailPageInfo.imageNoTo; i++) {
      state.absoluteIndexOfThumbnails.add(i);
    }
    state.nextPageIndexToLoadThumbnails++;

    state.loadingState = LoadingState.idle;
    updateSafely();
  }

  Future<void> handleTapJumpButton() async {
    int? pageIndex = await Get.dialog(
      JumpPageDialog(
        totalPageNo: detailsPageState.galleryDetails!.thumbnailsPageCount,
        currentNo: state.nextPageIndexToLoadThumbnails,
      ),
    );

    if (pageIndex != null && state.loadingState != LoadingState.loading) {
      state.thumbnails.clear();
      state.absoluteIndexOfThumbnails.clear();
      state.initialPageIndex = pageIndex;
      state.nextPageIndexToLoadThumbnails = pageIndex;
      updateSafely();
      loadMoreThumbnails();
    }
  }
}
