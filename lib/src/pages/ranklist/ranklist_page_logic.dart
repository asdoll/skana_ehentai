import 'dart:async';

import 'package:skana_ehentai/src/network/eh_request.dart';
import 'package:skana_ehentai/src/pages/ranklist/ranklist_page_state.dart';
import 'package:skana_ehentai/src/utils/eh_spider_parser.dart';
import 'package:skana_ehentai/src/widget/loading_state_indicator.dart';

import '../../service/log.dart';
import '../base/old_base_page_logic.dart';

class RanklistPageLogic extends OldBasePageLogic {
  @override
  final RanklistPageState state = RanklistPageState();

  @override
  bool get useSearchConfig => false;

  Future<void> handleChangeRanklist(RanklistType newType) async {
    if (state.loadingState == LoadingState.loading) {
      return;
    }
    if (newType == state.ranklistType) {
      return;
    }

    state.ranklistType = newType;
    super.handleClearAndRefresh();
  }

  @override
  Future<List<dynamic>> getGallerysAndPageInfoByPage(int pageIndex) async {
    log.info('Get ranklist data, type:${state.ranklistType.name}, pageIndex:$pageIndex');

    return await ehRequest.requestRanklistPage(
      ranklistType: state.ranklistType,
      pageNo: pageIndex,
      parser: EHSpiderParser.ranklistPage2GalleryPageInfo,
    );
  }
}
