import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/model/gallery.dart';
import 'package:skana_ehentai/src/pages/details/details_page_logic.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/eh_image.dart';
import '../config/ui_config.dart';

import '../consts/locale_consts.dart';
import '../model/gallery_image.dart';
import '../routes/routes.dart';
import '../utils/route_util.dart';

class EHDashboardCard extends StatefulWidget {
  final Gallery gallery;
  final String? badge;

  const EHDashboardCard({super.key, required this.gallery, this.badge});

  @override
  State<EHDashboardCard> createState() => _EHDashboardCardState();
}

class _EHDashboardCardState extends State<EHDashboardCard> {
  bool loadSuccess = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => toRoute(
          Routes.details,
          arguments: DetailsPageArgument(
              galleryUrl: widget.gallery.galleryUrl, gallery: widget.gallery),
        ),

        /// show info after image load success
        child: Stack(
          children: [
            _buildCover(widget.gallery.cover),
            if (loadSuccess)
              Positioned(
                  height: 90,
                  width: UIConfig.dashboardCardSize,
                  bottom: 0,
                  child: _buildShade()),
            if (loadSuccess)
              Positioned(
                  width: UIConfig.dashboardCardSize,
                  bottom: 10,
                  child: _buildGalleryDesc()),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(GalleryImage image) {
    return EHImage(
      containerHeight: UIConfig.dashboardCardSize,
      containerWidth: UIConfig.dashboardCardSize,
      galleryImage: image,
      fit: BoxFit.cover,
      completedWidgetBuilder: (_) {
        Get.engine.addPostFrameCallback((_) {
          if (mounted && !loadSuccess) {
            setState(() => loadSuccess = true);
          }
        });
        return null;
      },
    );
  }

  Widget _buildShade() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, UIConfig.dashboardCardShadeColor],
        ),
      ),
    );
  }

  Widget _buildGalleryDesc() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.gallery.title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: UIConfig.dashboardCardTextColor, fontSize: 12),
        ).small(),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              widget.gallery.uploader ?? 'unknownUser'.tr,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: UIConfig.galleryCardUploaderColor(context), fontSize: 10),
            ).xSmall().marginOnly(left: 2),
            const Expanded(child: SizedBox()),
            Text(
              '${widget.badge ?? ''} ${LocaleConsts.language2Abbreviation[widget.gallery.language] ?? ''}',
              style: TextStyle(
                  color: UIConfig.galleryCardUploaderColor(context), fontSize: 10),
            ).xSmall(),
          ],
        )
      ],
    ).paddingSymmetric(horizontal: 8);
  }
}
