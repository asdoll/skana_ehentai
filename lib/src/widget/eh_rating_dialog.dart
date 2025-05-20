import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

import '../utils/route_util.dart';

class EHRatingDialog extends StatefulWidget {
  final double rating;
  final bool hasRated;

  const EHRatingDialog(
      {super.key, required this.rating, required this.hasRated});

  @override
  State<EHRatingDialog> createState() => _EHRatingDialogState();
}

class _EHRatingDialogState extends State<EHRatingDialog> {
  late double rating = widget.rating;
  late bool hasRated = widget.hasRated;

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context: context,
      title: "rating".tr,
      contentWidget: _buildRatingBar().paddingOnly(bottom: 16),
      actions: [_buildSubmitButton()],
    );
  }

  Widget _buildRatingBar() {
    return Center(
      child: RatingBar.builder(
        unratedColor: UIConfig.galleryRatingStarUnRatedColor(context),
        minRating: 0.5,
        initialRating: max(rating, 0.5),
        itemCount: 5,
        allowHalfRating: true,
        itemSize: UIConfig.ratingDialogStarSize,
        itemPadding: const EdgeInsets.only(left: 4),
        updateOnDrag: true,
        itemBuilder: (context, index) => Icon(Icons.star,
            color: hasRated
                ? UIConfig.galleryRatingStarRatedColor(context)
                : UIConfig.galleryRatingStarColor),
        onRatingUpdate: (rating) => setState(() => this.rating = rating),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return filledButton(
      onPressed: () => backRoute(result: rating),
      label: 'submit'.tr,
    );
  }
}
