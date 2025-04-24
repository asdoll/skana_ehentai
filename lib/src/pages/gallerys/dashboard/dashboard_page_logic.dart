import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/extension/dio_exception_extension.dart';
import 'package:skana_ehentai/src/pages/base/base_page_logic.dart';
import 'package:skana_ehentai/src/pages/gallerys/dashboard/dashboard_page_state.dart';
import 'package:skana_ehentai/src/pages/ranklist/ranklist_page_state.dart';

import '../../../consts/eh_consts.dart';
import '../../../exception/eh_site_exception.dart';
import '../../../mixin/scroll_to_top_state_mixin.dart';
import '../../../model/gallery_page.dart';
import '../../../network/eh_request.dart';
import '../../../utils/eh_spider_parser.dart';
import '../../../service/log.dart';
import '../../../utils/snack_util.dart';
import '../../../widget/loading_state_indicator.dart';

class DashboardPageLogic extends BasePageLogic {
  final String ranklistId = 'ranklistId';
  final String popularListId = 'popularListId';
  final String galleryListId = 'galleryListId';

  @override
  bool get autoLoadForFirstTime => false;

  @override
  bool get useSearchConfig => true;

  @override
  String get searchConfigKey => 'DashboardPageLogic';

  @override
  DashboardPageState state = DashboardPageState();

  @override
  Scroll2TopStateMixin get scroll2TopState => state;

  @override
  Future<void> onReady() async {
    loadMore();
    loadRanklist();
    loadPopular();
  }

  Future<void> loadRanklist() async {
    if (state.ranklistLoadingState == LoadingState.loading) {
      return;
    }

    LoadingState prevState = state.ranklistLoadingState;
    state.ranklistLoadingState = LoadingState.loading;
    if (prevState == LoadingState.error || prevState == LoadingState.noData) {
      update([ranklistId]);
    }

    log.info('Get ranklist data');

    List<dynamic> gallerysAndPageInfo;
    try {
      gallerysAndPageInfo = await ehRequest.requestRanklistPage(
        ranklistType: RanklistType.day,
        pageNo: 0,
        parser: EHSpiderParser.ranklistPage2GalleryPageInfo,
      );
    } on DioException catch (e) {
      log.error('getRanklistFailed'.tr, e.errorMsg);
      snack('getRanklistFailed'.tr, e.errorMsg ?? '', isShort: true);
      state.ranklistLoadingState = LoadingState.error;
      update([ranklistId]);
      return;
    } on EHSiteException catch (e) {
      log.error('getRanklistFailed'.tr, e.message);
      snack('getRanklistFailed'.tr, e.message, isShort: true);
      state.ranklistLoadingState = LoadingState.error;
      update([ranklistId]);
      return;
    }

    state.ranklistGallerys = await super.postHandleNewGallerys(gallerysAndPageInfo[0], cleanDuplicate: false);

    state.ranklistLoadingState = LoadingState.success;
    update([ranklistId]);
  }

  Future<void> loadPopular() async {
    if (state.popularLoadingState == LoadingState.loading) {
      return;
    }

    LoadingState prevState = state.popularLoadingState;
    state.popularLoadingState = LoadingState.loading;
    if (prevState == LoadingState.error || prevState == LoadingState.noData) {
      update([popularListId]);
    }

    log.info('Get popular list data');

    GalleryPageInfo gallerysPage;
    try {
      gallerysPage = await ehRequest.requestGalleryPage(
        url: EHConsts.EPopular,
        parser: EHSpiderParser.galleryPage2GalleryPageInfo,
      );
    } on DioException catch (e) {
      log.error('getPopularListFailed'.tr, e.errorMsg);
      snack('getPopularListFailed'.tr, e.errorMsg ?? '', isShort: true);
      state.popularLoadingState = LoadingState.error;
      update([popularListId]);
      return;
    } on EHSiteException catch (e) {
      log.error('getPopularListFailed'.tr, e.message);
      snack('getPopularListFailed'.tr, e.message, isShort: true);
      state.popularLoadingState = LoadingState.error;
      update([popularListId]);
      return;
    }

    state.popularGallerys = await super.postHandleNewGallerys(gallerysPage.gallerys, cleanDuplicate: false);

    state.popularLoadingState = LoadingState.success;
    update([popularListId]);
  }

  /// pull-down to refresh ranklist & popular & gallerys, we need to sync loading state manually because [handleRefresh] doesn't
  /// refresh loading state
  Future<void> handleRefreshTotalPage() async {
    state.loadingState = LoadingState.loading;
    update([loadingStateId]);

    loadRanklist();
    loadPopular();

    await super.handleRefresh(updateId: galleryListId);

    state.loadingState = state.refreshState;
    update([loadingStateId]);
  }
}
