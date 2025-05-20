import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/pages/gallery_image/gallery_image_page_logic.dart';
import 'package:skana_ehentai/src/pages/gallery_image/gallery_image_page_state.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/loading_state_indicator.dart';

class GalleryImagePage extends StatelessWidget {
  final GalleryImagePageLogic logic = Get.put(GalleryImagePageLogic());
  final GalleryImagePageState state = Get.find<GalleryImagePageLogic>().state;

  GalleryImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: () {
        return GetBuilder<GalleryImagePageLogic>(builder: (_) {
          return LoadingStateIndicator(
            loadingState: state.loadingState,
            errorTapCallback: logic.getPageInfoAndRedirect,
          );
        });
      }(),
    );
  }
}
