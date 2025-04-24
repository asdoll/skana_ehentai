import 'package:skana_ehentai/src/service/local_gallery_service.dart';

import '../../../../mixin/scroll_to_top_state_mixin.dart';
import '../../mixin/basic/multi_select/multi_select_download_page_state_mixin.dart';
import '../mixin/grid_download_page_state_mixin.dart';

class LocalGalleryGridPageState with Scroll2TopStateMixin, MultiSelectDownloadPageStateMixin, GridBasePageState {
  @override
  List<String> get allRootGroups => localGalleryService.rootDirectories;

  @override
  List<LocalGallery> galleryObjectsWithGroup(String groupName) {
    return localGalleryService.path2GalleryDir[groupName] ?? [];
  }
}
