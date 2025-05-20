import 'package:flutter/material.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

class EHCommentScoreDetailsDialog extends StatelessWidget {
  final List<String> scoreDetails;

  const EHCommentScoreDetailsDialog({super.key, required this.scoreDetails});

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context:context,
      title: "",
      contentWidget: Column(
        children: scoreDetails
            .map((detail) => Center(child: Text(detail).small()))
            .toList(),
      ),
    );
  }
}
