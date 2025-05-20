import 'package:bootstrap_icons/bootstrap_icons.dart' show BootstrapIcons;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/model/gallery_url.dart';
import 'package:skana_ehentai/src/pages/details/details_page_logic.dart';
import 'package:skana_ehentai/src/utils/route_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/eh_wheel_speed_controller.dart';

import '../config/ui_config.dart';
import '../routes/routes.dart';

class EHGalleryHistoryDialog extends StatelessWidget {
  final String currentGalleryTitle;
  final GalleryUrl? parentUrl;
  final List<({GalleryUrl galleryUrl, String title, String updateTime})>?
      childrenGallerys;

  const EHGalleryHistoryDialog({
    super.key,
    required this.currentGalleryTitle,
    this.parentUrl,
    this.childrenGallerys,
  });

  @override
  Widget build(BuildContext context) {
    return EHWheelSpeedController(
      controller: null,
      child: moonAlertDialog(
        context: context,
        title: 'history'.tr,
        contentWidget: ListView(
          shrinkWrap: true,
          children: [
            ...?childrenGallerys?.reversed.map(
              (e) => moonListTileWidgets(
                label: Text(
                  e.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: UIConfig.galleryHistoryTitleSize),
                ).small(),
                trailing: Text(e.updateTime,
                        style: const TextStyle(
                            fontSize:
                                UIConfig.galleryHistoryDialogTrailingTextSize))
                    .xSmall(),
                onTap: () {
                  backRoute();
                  toRoute(
                    Routes.details,
                    arguments: DetailsPageArgument(galleryUrl: e.galleryUrl),
                    offAllBefore: false,
                    preventDuplicates: false,
                  );
                },
              ),
            ),
            moonListTileWidgets(
              label: Text(
                currentGalleryTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: UIConfig.galleryHistoryTitleSize,
                    color: UIConfig.favoriteDialogTileColor(context)),
              ).small(),
              trailing: Text('current'.tr,
                      style: TextStyle(
                          fontSize:
                              UIConfig.galleryHistoryDialogTrailingTextSize,
                          color: UIConfig.favoriteDialogTileColor(context)))
                  .xSmall(),
            ),
            if (parentUrl != null)
              moonListTileWidgets(
                label: Text('parentGallery'.tr,
                        style: const TextStyle(
                            fontSize: UIConfig.galleryHistoryTitleSize))
                    .small(),
                trailing: const Icon(BootstrapIcons.box_arrow_right,
                    size: UIConfig.galleryHistoryDialogSubtitleIconSize),
                onTap: () {
                  backRoute();
                  toRoute(
                    Routes.details,
                    arguments: DetailsPageArgument(galleryUrl: parentUrl!),
                    offAllBefore: false,
                    preventDuplicates: false,
                  );
                },
              ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      ),
    );
  }
}
