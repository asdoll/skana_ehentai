import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/pages/popular/popular_page_logic.dart';
import 'package:skana_ehentai/src/pages/popular/popular_page_state.dart';

import '../base/base_page.dart';

class PopularPage extends BasePage {
  const PopularPage({
    Key? key,
    bool showMenuButton = false,
    bool showTitle = false,
    String? name,
  }) : super(
          key: key,
          showMenuButton: showMenuButton,
          showTitle: showTitle,
          showJumpButton: false,
          showScroll2TopButton: true,
          name: name,
        );

  @override
  PopularPageLogic get logic => Get.put<PopularPageLogic>(PopularPageLogic(), permanent: true);

  @override
  PopularPageState get state => Get.find<PopularPageLogic>().state;
}
