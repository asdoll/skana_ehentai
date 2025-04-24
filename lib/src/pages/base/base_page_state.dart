import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:skana_ehentai/src/mixin/scroll_to_top_state_mixin.dart';
import 'package:skana_ehentai/src/model/gallery_count.dart';
import 'package:skana_ehentai/src/model/search_config.dart';
import 'package:skana_ehentai/src/utils/uuid_util.dart';

import '../../model/gallery.dart';
import '../../model/gallery_page.dart';
import '../../widget/loading_state_indicator.dart';

abstract class BasePageState with Scroll2TopStateMixin {
  String get route;

  SearchConfig searchConfig = SearchConfig();
  Completer<void> searchConfigInitCompleter = Completer<void>();

  List<Gallery> gallerys = List.empty(growable: true);

  /// The first gallery's id in current page
  String? prevGid;

  /// The last gallery's id in current page
  String? nextGid;

  /// used for jump page
  DateTime seek = DateTime.now();

  GalleryCount? totalCount;

  FavoriteSortOrder? favoriteSortOrder;

  LoadingState refreshState = LoadingState.idle;
  LoadingState loadingState = LoadingState.idle;

  /// used for refresh
  Key galleryCollectionKey = Key(newUUID());

  late PageStorageKey pageStorageKey;

  BasePageState() {
    pageStorageKey = PageStorageKey(runtimeType);
  }

  @override
  String toString() {
    return 'BasePageState{searchConfig: $searchConfig, gallerys: $gallerys, prevGid: $prevGid, nextGid: $nextGid, seek: $seek, totalCount: $totalCount, refreshState: $refreshState, loadingState: $loadingState, galleryCollectionKey: $galleryCollectionKey, pageStorageKey: $pageStorageKey}';
  }
}
