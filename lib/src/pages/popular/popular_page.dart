import 'package:get/get.dart';
import 'package:skana_ehentai/src/pages/popular/popular_page_logic.dart';
import 'package:skana_ehentai/src/pages/popular/popular_page_state.dart';

import '../base/base_page.dart';

class PopularPage extends BasePage {
  const PopularPage({
    super.key,
    super.showMenuButton,
    super.showTitle,
    super.name,
  }) : super(
          showJumpButton: false,
          showScroll2TopButton: true,
        );

  @override
  PopularPageLogic get logic => Get.put<PopularPageLogic>(PopularPageLogic(), permanent: true);

  @override
  PopularPageState get state => Get.find<PopularPageLogic>().state;
}
