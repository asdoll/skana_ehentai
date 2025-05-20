import 'package:get/get.dart';
import 'package:skana_ehentai/src/pages/watched/watched_page_state.dart';

import '../base/base_page.dart';
import 'watched_page_logic.dart';

class WatchedPage extends BasePage {
  const WatchedPage({
    super.key,
    super.showMenuButton,
    super.showTitle,
    super.name,
  }) : super(
          showJumpButton: true,
          showFilterButton: true,
          showScroll2TopButton: true,
        );

  @override
  WatchedPageLogic get logic => Get.put<WatchedPageLogic>(WatchedPageLogic(), permanent: true);

  @override
  WatchedPageState get state => Get.find<WatchedPageLogic>().state;
}
