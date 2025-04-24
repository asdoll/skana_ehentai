import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/extension/dio_exception_extension.dart';
import 'package:skana_ehentai/src/utils/toast_util.dart';

import '../exception/eh_site_exception.dart';
import '../network/eh_request.dart';
import '../pages/details/details_page_logic.dart';
import '../utils/eh_spider_parser.dart';
import '../service/log.dart';
import '../utils/route_util.dart';
import '../utils/snack_util.dart';
import 'loading_state_indicator.dart';

enum CommentDialogType { add, update }

class EHCommentDialog extends StatefulWidget {
  final CommentDialogType type;
  final String title;

  final String initText;
  final int? commentId;

  const EHCommentDialog({
    Key? key,
    required this.type,
    required this.title,
    this.initText = '',
    this.commentId,
  }) : super(key: key);

  @override
  EHCommentDialogState createState() => EHCommentDialogState();
}

class EHCommentDialogState extends State<EHCommentDialog> {
  String content = '';
  TextEditingController controller = TextEditingController();
  LoadingState sendCommentState = LoadingState.idle;

  @override
  void initState() {
    super.initState();
    content = widget.initText;
    controller.text = content;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        autofocus: true,
        controller: controller,
        minLines: 1,
        maxLines: 10,
        onChanged: (String text) => content = text,
        decoration: InputDecoration(
          isDense: true,
          alignLabelWithHint: true,
          labelText: 'atLeast3Characters'.tr,
          labelStyle: const TextStyle(fontSize: 14),
        ),
      ),
      actions: [
        if (sendCommentState == LoadingState.loading) const CupertinoActivityIndicator(radius: 10),
        TextButton(child: const Icon(Icons.send), onPressed: _sendComment)
      ],
    );
  }

  Future<void> _sendComment() async {
    if (content.length <= 2) {
      toast('commentTooShort'.tr);
      return;
    }

    if (content.removeAllWhitespace.toLowerCase().contains('jhentai')) {
      toast('noJHenTaiHints'.tr, isShort: false);
      return;
    }

    if (sendCommentState == LoadingState.loading) {
      return;
    }

    setState(() => sendCommentState = LoadingState.loading);

    String? errMsg;
    try {
      if (widget.type == CommentDialogType.add) {
        errMsg = await ehRequest.requestSendComment(
          galleryUrl: DetailsPageLogic.current!.state.galleryDetails?.galleryUrl.url ?? DetailsPageLogic.current!.state.gallery!.galleryUrl.url,
          content: content,
          parser: EHSpiderParser.sendComment2ErrorMsg,
        );
      }

      if (widget.type == CommentDialogType.update) {
        errMsg = await ehRequest.requestUpdateComment(
          galleryUrl: DetailsPageLogic.current!.state.galleryDetails?.galleryUrl.url ?? DetailsPageLogic.current!.state.gallery!.galleryUrl.url,
          commentId: widget.commentId!,
          content: content,
          parser: EHSpiderParser.sendComment2ErrorMsg,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode != 302) {
        log.error('sendCommentFailed'.tr, e.errorMsg);
        snack('sendCommentFailed'.tr, e.errorMsg ?? '');
        return;
      }
    } on EHSiteException catch (e) {
      log.error('sendCommentFailed'.tr, e.message);
      snack('sendCommentFailed'.tr, e.message);
      return;
    } finally {
      setState(() => sendCommentState = LoadingState.idle);
    }

    if (errMsg == null) {
      toast('success'.tr);
      backRoute(result: true);
      return;
    }

    snack('sendCommentFailed'.tr, errMsg);
  }
}
