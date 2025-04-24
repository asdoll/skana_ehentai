import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/string_extension.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/model/gallery_detail.dart';
import 'package:skana_ehentai/src/setting/preference_setting.dart';
import 'package:skana_ehentai/src/utils/date_util.dart';
import 'package:skana_ehentai/src/utils/string_uril.dart';

import '../utils/toast_util.dart';

class EHGalleryDetailDialog extends StatelessWidget {
  final GalleryDetail galleryDetail;

  const EHGalleryDetailDialog({Key? key, required this.galleryDetail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      children: [
        _Item(name: 'gid'.tr, value: galleryDetail.galleryUrl.gid.toString()),
        _Item(name: 'token'.tr, value: (galleryDetail.galleryUrl.token)),
        _Item(name: ('galleryUrl'.tr), value: (galleryDetail.galleryUrl.url)),
        _Item(name: ('title'.tr), value: (galleryDetail.rawTitle)),
        _Item(name: ('japaneseTitle'.tr), value: (galleryDetail.japaneseTitle)),
        _Item(name: ('category'.tr), value: (galleryDetail.category)),
        _Item(name: ('uploader'.tr), value: (galleryDetail.uploader)),
        _Item(
          name: ('publishTime'.tr),
          value: (preferenceSetting.showUtcTime.isTrue ? galleryDetail.publishTime : DateUtil.transformUtc2LocalTimeString(galleryDetail.publishTime)),
        ),
        _Item(name: ('language'.tr), value: (galleryDetail.language)),
        _Item(name: ('pageCount'.tr), value: (galleryDetail.pageCount.toString())),
        _Item(name: ('favoriteCount'.tr), value: (galleryDetail.favoriteCount.toString())),
        _Item(name: ('ratingCount'.tr), value: (galleryDetail.ratingCount.toString())),
        _Item(name: ('rating'.tr), value: (galleryDetail.realRating.toString())),
      ],
    ).enableMouseDrag(withScrollBar: false);
  }
}

class _Item extends StatelessWidget {
  final String name;
  final String? value;

  const _Item({Key? key, required this.name, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: UIConfig.galleryDetailDialogItemBorderRadius,
      onTap: () {
        if (!isEmptyOrNull(value)) {
          FlutterClipboard.copy(value!).then((value) => toast('hasCopiedToClipboard'.tr));
        }
      },
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(name, style: UIConfig.galleryDetailDialogItemNameTextStyle),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: UIConfig.galleryDetailDialogItemValueMaxWidth),
                    child: Text(value?.breakWord ?? '', style: UIConfig.galleryDetailDialogItemValueTextStyle),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
