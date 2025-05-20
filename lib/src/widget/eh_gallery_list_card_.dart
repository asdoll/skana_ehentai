import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:blur/blur.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/model/gallery.dart';
import 'package:skana_ehentai/src/model/gallery_tag.dart';
import 'package:skana_ehentai/src/setting/preference_setting.dart';
import 'package:skana_ehentai/src/setting/style_setting.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../consts/locale_consts.dart';
import '../utils/date_util.dart';
import 'eh_image.dart';
import 'eh_tag.dart';
import 'eh_gallery_category_tag.dart';

typedef CardCallback = FutureOr<void> Function(Gallery gallery);

class EHGalleryListCard extends StatelessWidget {
  final Gallery gallery;
  final bool downloaded;
  final ListMode listMode;
  final CardCallback handleTapCard;
  final CardCallback? handleLongPressCard;
  final CardCallback? handleSecondaryTapCard;
  final bool withTags;

  const EHGalleryListCard({
    super.key,
    required this.gallery,
    required this.downloaded,
    required this.listMode,
    required this.handleTapCard,
    this.withTags = true,
    this.handleLongPressCard,
    this.handleSecondaryTapCard,
  });

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 100),
      child: SizedBox(
        height: withTags
            ? UIConfig.galleryCardHeight
            : UIConfig.galleryCardHeightWithoutTags,
        child: buildGalleryCard(context),
      ),
    );
  }

  Widget buildGalleryCard(BuildContext context) {
    final isFlat =
        listMode == ListMode.flat || listMode == ListMode.flatWithoutTags;
    Widget child = moonListTileWidgets(
      label: buildGalleryCardInfo(context),
      leading: styleSetting.moveCover2RightSide.isTrue ? null : buildGalleryCardCover(context),
      trailing: styleSetting.moveCover2RightSide.isTrue ? buildGalleryCardCover(context) : null,
      menuItemPadding: const EdgeInsets.all(4),
      onTap: () => handleTapCard(gallery),
      onLongPress: handleLongPressCard == null
          ? null
          : () => handleLongPressCard!(gallery),
      onSecondaryTap: handleSecondaryTapCard == null
          ? null
          : () => handleSecondaryTapCard!(gallery),
      noPadding: isFlat,
      borderRadius: isFlat ? BorderRadius.zero : null,
    );

    if (gallery.blockedByLocalRules) {
      child = Blur(
        blur: 8,
        blurColor: UIConfig.backGroundColor(context),
        colorOpacity: 0.7,
        overlay: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel_outlined,
                size: UIConfig.galleryCardFilteredIconSize,
                color: UIConfig.onBackGroundColor(context)),
            Text('filtered'.tr,
                style: TextStyle(color: UIConfig.onBackGroundColor(context))).subHeader(),
          ],
        ),
        child: child,
      );
    }
    return child;
  }

  Widget buildGalleryCardCover(BuildContext context) {
    return EHImage(
      galleryImage: gallery.cover,
      containerColor: UIConfig.galleryCardBackGroundColor(context),
      containerHeight: withTags
          ? UIConfig.galleryCardHeight
          : UIConfig.galleryCardHeightWithoutTags,
      containerWidth: withTags
          ? UIConfig.galleryCardCoverWidth
          : UIConfig.galleryCardCoverWidthWithoutTags,
      heroTag: gallery.blockedByLocalRules ? null : gallery.cover,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(8),
    );
  }

  Widget buildGalleryCardInfo(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildGalleryCardInfoHeader(context),
        buildGalleryCardTagWaterFlow(context),
        buildGalleryInfoFooter(context),
      ],
    );
  }

  Widget buildGalleryCardInfoHeader(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${gallery.title}\n', maxLines: 2, overflow: TextOverflow.ellipsis)
            .subHeader(),
        Text(
          gallery.uploader ?? "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: UIConfig.galleryCardUploaderColor(context)),
        ).small().paddingOnly(bottom: 2),
      ],
    );
  }

  Widget buildGalleryCardTagWaterFlow(BuildContext context) {
    if (!withTags) {
      return SizedBox(
        height: listMode == ListMode.flatWithoutTags
            ? UIConfig.galleryCardNoTagsFlatHeight
            : UIConfig.galleryCardNoTagsHeight,
      );
    }
    List<GalleryTag> mergedList = [];
    gallery.tags.forEach((namespace, galleryTags) {
      mergedList.addAll(galleryTags);
    });
    mergedList.sort((a, b) {
      bool aWatched = a.backgroundColor != null;
      bool bWatched = b.backgroundColor != null;
      if (aWatched && !bWatched) {
        return -1;
      } else if (!aWatched && bWatched) {
        return 1;
      } else {
        return 0;
      }
    });

    if (gallery.tags.isEmpty) {
      return SizedBox(height: UIConfig.galleryCardTagsHeight);
    }

    return SizedBox(
      height: UIConfig.galleryCardTagsHeight,
      child: WaterfallFlow.builder(
        scrollDirection: Axis.horizontal,

        /// disable keepScrollOffset because we used [PageStorageKey], which leads to a conflict with this WaterfallFlow
        controller: ScrollController(keepScrollOffset: false),
        gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: mergedList.length,
        itemBuilder: (_, int index) => EHTag(tag: mergedList[index]),
      ).enableMouseDrag(withScrollBar: false),
    ).paddingBottom(3);
  }

  Widget buildGalleryInfoFooter(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            EHGalleryCategoryTag(category: gallery.category),
            const Expanded(child: SizedBox()),
            if (downloaded) _buildDownloadIcon(context).marginOnly(right: 4),
            if (gallery.isFavorite) _buildFavoriteIcon().marginOnly(right: 4),
            if (gallery.language != null)
              _buildLanguage(context).marginOnly(right: 4),
            if (gallery.pageCount != null) _buildPageCount(context),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRatingBar(context),
            _buildTime(context),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingBar(BuildContext context) {
    return RatingBar.builder(
      unratedColor: UIConfig.galleryRatingStarUnRatedColor(context),
      initialRating: gallery.rating,
      itemCount: 5,
      allowHalfRating: true,
      itemSize: 12,
      ignoreGestures: true,
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: gallery.hasRated
            ? UIConfig.galleryRatingStarRatedColor(context)
            : UIConfig.galleryRatingStarColor,
      ),
      onRatingUpdate: (rating) {},
    );
  }

  Widget _buildDownloadIcon(BuildContext context) =>
      Icon(Icons.arrow_circle_down_rounded,
          size: 14, color: UIConfig.galleryCardUploaderColor(context)).paddingTop(1);

  Widget _buildFavoriteIcon() => Icon(BootstrapIcons.heart_fill,
      size: 11, color: UIConfig.favoriteTagColor[gallery.favoriteTagIndex!]).paddingTop(2);

  Text _buildPageCount(BuildContext context) =>
      Text('${gallery.pageCount}P',style: TextStyle(color: UIConfig.galleryCardUploaderColor(context))).small();

  Text _buildLanguage(BuildContext context) {
    return Text(LocaleConsts.language2Abbreviation[gallery.language] ?? '',
            style: TextStyle(color: UIConfig.galleryCardUploaderColor(context)))
        .small();
  }

  Text _buildTime(BuildContext context) {
    return Text(
      preferenceSetting.showUtcTime.isTrue
          ? gallery.publishTime
          : DateUtil.transformUtc2LocalTimeString(gallery.publishTime),
      style: TextStyle(
          decoration: gallery.isExpunged ? TextDecoration.lineThrough : null),
    ).xSmall();
  }
}
