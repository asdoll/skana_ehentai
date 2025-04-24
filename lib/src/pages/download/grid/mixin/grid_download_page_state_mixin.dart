import 'package:flutter/cupertino.dart';
import 'package:skana_ehentai/src/service/local_gallery_service.dart';

import '../../../../mixin/scroll_to_top_state_mixin.dart';

mixin GridBasePageState implements Scroll2TopStateMixin {
  bool inEditMode = false;

  String currentGroup = LocalGalleryService.rootPath;

  bool get isAtRoot => currentGroup == LocalGalleryService.rootPath;

  List<String> get allRootGroups;

  List get currentGalleryObjects => galleryObjectsWithGroup(currentGroup);

  List galleryObjectsWithGroup(String groupName);

  final ScrollController rootScrollController = ScrollController();
  final ScrollController galleryScrollController = ScrollController();

  @override
  ScrollController get scrollController => isAtRoot ? rootScrollController : galleryScrollController;
}
