import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/extension/string_extension.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/model/gallery_detail.dart';
import 'package:skana_ehentai/src/setting/preference_setting.dart';
import 'package:skana_ehentai/src/utils/date_util.dart';
import 'package:skana_ehentai/src/utils/string_uril.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

import '../utils/toast_util.dart';

class EHGalleryDetailDialog extends StatelessWidget {
  final GalleryDetail galleryDetail;

  const EHGalleryDetailDialog({super.key, required this.galleryDetail});

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context: context,
      title: "",
      contentWidget: Column(
        children: [
          _Item(name: 'gid'.tr, value: galleryDetail.galleryUrl.gid.toString()),
          _Item(name: 'token'.tr, value: (galleryDetail.galleryUrl.token)),
          _Item(name: ('galleryUrl'.tr), value: (galleryDetail.galleryUrl.url)),
          _Item(name: ('title'.tr), value: (galleryDetail.rawTitle)),
          _Item(
              name: ('japaneseTitle'.tr), value: (galleryDetail.japaneseTitle)),
          _Item(name: ('category'.tr), value: (galleryDetail.category)),
          _Item(name: ('uploader'.tr), value: (galleryDetail.uploader)),
          _Item(
            name: ('publishTime'.tr),
            value: (preferenceSetting.showUtcTime.isTrue
                ? galleryDetail.publishTime
                : DateUtil.transformUtc2LocalTimeString(
                    galleryDetail.publishTime)),
          ),
          _Item(name: ('language'.tr), value: (galleryDetail.language)),
          _Item(
              name: ('pageCount'.tr),
              value: (galleryDetail.pageCount.toString())),
          _Item(
              name: ('favoriteCount'.tr),
              value: (galleryDetail.favoriteCount.toString())),
          _Item(
              name: ('ratingCount'.tr),
              value: (galleryDetail.ratingCount.toString())),
          _Item(
              name: ('rating'.tr),
              value: (galleryDetail.realRating.toString())),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
    ).enableMouseDrag(withScrollBar: false);
  }
}

class _Item extends StatelessWidget {
  final String name;
  final String? value;

  const _Item({required this.name, this.value});

  @override
  Widget build(BuildContext context) {
    return moonListTile(
      title: value?.breakWord ?? '',
      leading: SizedBox(width: 50, child: Text(name).small()),
      smallerTitle: true,
      onTap: () {
        if (!isEmptyOrNull(value)) {
          FlutterClipboard.copy(value!)
              .then((value) => toast('hasCopiedToClipboard'.tr));
        }
      },
    );
  }
}
