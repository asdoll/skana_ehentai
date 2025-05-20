import 'package:get/get.dart';
import 'package:skana_ehentai/src/pages/gallerys/simple/gallerys_page_logic.dart';
import 'package:skana_ehentai/src/pages/gallerys/simple/gallerys_page_state.dart';
import '../../base/base_page.dart';

/// For desktop layout
class GallerysPage extends BasePage {
  const GallerysPage({super.key}) : super(showFilterButton: true, showScroll2TopButton: true);

  @override
  GallerysPageLogic get logic => Get.put<GallerysPageLogic>(GallerysPageLogic(), permanent: true);

  @override
  GallerysPageState get state => Get.find<GallerysPageLogic>().state;
}
