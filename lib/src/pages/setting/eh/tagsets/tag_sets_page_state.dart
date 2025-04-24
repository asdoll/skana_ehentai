import 'dart:ui';

import 'package:skana_ehentai/src/mixin/scroll_to_top_state_mixin.dart';
import 'package:skana_ehentai/src/model/tag_set.dart';
import 'package:skana_ehentai/src/widget/loading_state_indicator.dart';

class TagSetsState with Scroll2TopStateMixin {
  int currentTagSetNo = 1;

  List<({int number, String name})> tagSets = [];
  List<WatchedTag> tags = <WatchedTag>[];

  late bool currentTagSetEnable;
  Color? currentTagSetBackgroundColor;
  late String apikey;

  LoadingState loadingState = LoadingState.idle;
  LoadingState updateTagSetState = LoadingState.idle;
  LoadingState updateTagState = LoadingState.idle;
}
