import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/exception/eh_parse_exception.dart';
import 'package:skana_ehentai/src/exception/eh_site_exception.dart';
import 'package:skana_ehentai/src/extension/dio_exception_extension.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/mixin/login_required_logic_mixin.dart';
import 'package:skana_ehentai/src/routes/routes.dart';
import 'package:skana_ehentai/src/setting/my_tags_setting.dart';
import 'package:skana_ehentai/src/setting/preference_setting.dart';
import 'package:skana_ehentai/src/utils/eh_spider_parser.dart';
import 'package:skana_ehentai/src/utils/route_util.dart';
import 'package:skana_ehentai/src/utils/toast_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/eh_tag_set_dialog.dart';
import 'package:skana_ehentai/src/widget/eh_warning_image.dart';
import 'package:skana_ehentai/src/widget/eh_wheel_speed_controller.dart';
import 'package:like_button/like_button.dart';
import 'package:skana_ehentai/src/widget/icons.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../config/ui_config.dart';
import '../database/database.dart';
import '../network/eh_request.dart';
import '../setting/user_setting.dart';
import '../service/log.dart';
import '../utils/snack_util.dart';
import '../utils/string_uril.dart';
import 'loading_state_indicator.dart';

class EHTagDialog extends StatefulWidget {
  final TagData tagData;
  final int gid;
  final String token;
  final String apikey;
  final ValueChanged<bool>? onTagVoted;

  const EHTagDialog({
    super.key,
    required this.tagData,
    required this.gid,
    required this.token,
    required this.apikey,
    this.onTagVoted,
  });

  @override
  State<EHTagDialog> createState() => _EHTagDialogState();
}

class _EHTagDialogState extends State<EHTagDialog> with LoginRequiredMixin {
  LoadingState voteUpState = LoadingState.idle;
  LoadingState voteDownState = LoadingState.idle;
  LoadingState addWatchedTagState = LoadingState.idle;
  LoadingState addHiddenTagState = LoadingState.idle;

  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
            context: context,
            title: '${widget.tagData.namespace}:${widget.tagData.key}',
            contentWidget: Column(children: [
              if (widget.tagData.tagName != null) ...[
                _buildInfo(),
                Divider(height: 1, color: UIConfig.layoutDividerColor(context))
                    .marginOnly(top: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildVoteUpButton(),
                  _buildVoteDownButton(),
                  _buildWatchTagButton(),
                  _buildHideTagButton(),
                  if (userSetting.hasLoggedIn()) _buildGoToTagSetsButton(),
                ],
              ).marginOnly(top: 12),
            ]),
            titleAction: () => FlutterClipboard.copy(
                    '${widget.tagData.namespace}:"${widget.tagData.key}"')
                .then((_) => toast('hasCopiedToClipboard'.tr)),
            scrollable: false)
        .enableMouseDrag();
  }

  Widget _buildInfo() {
    String content = widget.tagData.fullTagName! +
        widget.tagData.intro! +
        widget.tagData.links!;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 50,
        maxHeight: 400,
        minWidth: 250,
        maxWidth: 250,
      ),
      child: EHWheelSpeedController(
        controller: scrollController,
        child: HtmlWidget(
          content,
          renderMode:
              ListViewMode(shrinkWrap: true, controller: scrollController),
          textStyle: const TextStyle(fontSize: 12),
          onErrorBuilder: (context, element, error) =>
              Text('$element error: $error'),
          onLoadingBuilder: (context, element, loadingProgress) =>
              progressIndicator(context),
          onTapUrl: launchUrlString,
          customWidgetBuilder: (element) {
            if (element.localName != 'img') {
              return null;
            }
            return Center(
              child: EHWarningImage(
                warning: preferenceSetting.showR18GImageDirectly.isFalse &&
                    element.attributes['nsfw'] == 'R18G',
                src: element.attributes['src']!,
              ).rounded(8).marginSymmetric(vertical: 20),
            );
          },
        ).paddingSymmetric(horizontal: 12),
      ),
    );
  }

  Widget _buildVoteUpButton() {
    return LikeButton(
      likeBuilder: (bool liked) => Icon(
        liked
            ? BootstrapIcons.hand_thumbs_up_fill
            : BootstrapIcons.hand_thumbs_up,
        size: UIConfig.tagDialogButtonSize,
        color: liked
            ? UIConfig.tagDialogLikedButtonColor(context)
            : UIConfig.tagDialogButtonColor(context),
      ),
      onTap: (bool liked) =>
          liked ? Future.value(true) : vote(isVotingUp: true),
    );
  }

  Widget _buildVoteDownButton() {
    return LikeButton(
      likeBuilder: (bool liked) => Icon(
        liked
            ? BootstrapIcons.hand_thumbs_down_fill
            : BootstrapIcons.hand_thumbs_down,
        size: UIConfig.tagDialogButtonSize,
        color: liked
            ? UIConfig.tagDialogLikedButtonColor(context)
            : UIConfig.tagDialogButtonColor(context),
      ),
      onTap: (bool liked) =>
          liked ? Future.value(true) : vote(isVotingUp: false),
    );
  }

  Widget _buildWatchTagButton() {
    return LikeButton(
      isLiked: myTagsSetting.containWatchedOnlineTag(widget.tagData),
      likeBuilder: (bool liked) => Icon(
        liked ? BootstrapIcons.heart_fill : BootstrapIcons.heart,
        size: UIConfig.tagDialogButtonSize,
        color: liked
            ? UIConfig.tagDialogLikedButtonColor(context)
            : UIConfig.tagDialogButtonColor(context),
      ),
      onTap: (bool liked) => liked
          ? Future.value(true)
          : handleAddWatchedTag(true,
              useDefault: preferenceSetting.enableDefaultTagSet.isTrue),
      onLongPress: preferenceSetting.enableDefaultTagSet.isFalse
          ? null
          : (bool liked) => liked
              ? Future.value(true)
              : handleAddWatchedTag(true, useDefault: false),
    );
  }

  Widget _buildHideTagButton() {
    return LikeButton(
      isLiked: myTagsSetting.containHiddenOnlineTag(widget.tagData),
      likeBuilder: (bool liked) => Icon(
        BootstrapIcons.eye_slash,
        size: UIConfig.tagDialogButtonSize,
        color: liked
            ? UIConfig.tagDialogLikedButtonColor(context)
            : UIConfig.tagDialogButtonColor(context),
      ),
      onTap: (bool liked) => liked
          ? Future.value(true)
          : handleAddWatchedTag(false,
              useDefault: preferenceSetting.enableDefaultTagSet.isTrue),
      onLongPress: preferenceSetting.enableDefaultTagSet.isFalse
          ? null
          : (bool liked) => liked
              ? Future.value(true)
              : handleAddWatchedTag(false, useDefault: false),
    );
  }

  Widget _buildGoToTagSetsButton() {
    return LikeButton(
      likeBuilder: (_) => Icon(
        BootstrapIcons.gear,
        size: UIConfig.tagDialogButtonSize,
        color: UIConfig.tagDialogButtonColor(context),
      ),
      onTap: (_) async {
        backRoute();
        toRoute(Routes.tagSets);
        return null;
      },
    );
  }

  Future<bool> vote({required bool isVotingUp}) async {
    if (!userSetting.hasLoggedIn()) {
      showLoginToast();
      return false;
    }

    if (voteUpState == LoadingState.loading ||
        voteDownState == LoadingState.loading) {
      return true;
    }

    if (isVotingUp) {
      voteUpState = LoadingState.loading;
    } else {
      voteDownState = LoadingState.loading;
    }

    _doVote(isVotingUp: isVotingUp).then((bool success) {
      if (success) {
        widget.onTagVoted?.call(isVotingUp);
      }
    });

    return true;
  }

  Future<bool> _doVote({required bool isVotingUp}) async {
    log.info('Vote for tag:${widget.tagData.key}, isVotingUp: $isVotingUp');

    String? errMsg;
    try {
      errMsg = await ehRequest.voteTag(
        widget.gid,
        widget.token,
        userSetting.ipbMemberId.value!,
        widget.apikey,
        '${widget.tagData.namespace}:${widget.tagData.key}',
        isVotingUp,
        parser: EHSpiderParser.voteTagResponse2ErrorMessage,
      );
    } on DioException catch (e) {
      if (isVotingUp) {
        voteUpState = LoadingState.error;
      } else {
        voteDownState = LoadingState.error;
      }
      log.error('voteTagFailed'.tr, e.message);
      snack('voteTagFailed'.tr, e.message ?? '');
      return false;
    } on EHSiteException catch (e) {
      if (isVotingUp) {
        voteUpState = LoadingState.error;
      } else {
        voteDownState = LoadingState.error;
      }
      log.error('voteTagFailed'.tr, e.message);
      snack('voteTagFailed'.tr, e.message);
      return false;
    }

    if (isVotingUp) {
      voteUpState = LoadingState.success;
    } else {
      voteDownState = LoadingState.success;
    }

    if (!isEmptyOrNull(errMsg)) {
      snack('voteTagFailed'.tr, errMsg!, isShort: true);
      return false;
    } else {
      toast('success'.tr);
      return true;
    }
  }

  Future<bool> handleAddWatchedTag(bool watch,
      {required bool useDefault}) async {
    if (!userSetting.hasLoggedIn()) {
      showLoginToast();
      return false;
    }

    if (addWatchedTagState == LoadingState.loading ||
        addHiddenTagState == LoadingState.loading) {
      return true;
    }

    if (useDefault &&
        preferenceSetting.enableDefaultTagSet.isTrue &&
        userSetting.defaultTagSetNo.value != null) {
      _doAddNewTagSet(userSetting.defaultTagSetNo.value!, watch);
      return true;
    }

    ({int tagSetNo, bool remember})? result =
        await Get.dialog(const EHTagSetDialog());
    if (result == null) {
      return false;
    }

    if (result.remember == true) {
      userSetting.saveDefaultTagSetNo(result.tagSetNo);
    }

    _doAddNewTagSet(result.tagSetNo, watch);
    return true;
  }

  Future<void> _doAddNewTagSet(int tagSetNumber, bool watch) async {
    log.info(
        'Add new watched tag: ${widget.tagData.namespace}:${widget.tagData.key},tagSetNumber:$tagSetNumber, watch:$watch');

    if (watch) {
      addWatchedTagState = LoadingState.loading;
    } else {
      addHiddenTagState = LoadingState.loading;
    }

    try {
      await ehRequest.requestAddWatchedTag(
        tag: '${widget.tagData.namespace}:${widget.tagData.key}',
        tagWeight: 10,
        watch: watch,
        hidden: !watch,
        tagSetNo: tagSetNumber,
        parser: EHSpiderParser.addTagSetResponse2Result,
      );
    } on DioException catch (e) {
      log.error('addNewTagSetFailed'.tr, e.errorMsg);
      toast('${'addNewTagSetFailed'.tr}: ${e.errorMsg}', isShort: false);

      if (watch) {
        addWatchedTagState = LoadingState.error;
      } else {
        addHiddenTagState = LoadingState.error;
      }
      return;
    } on EHParseException catch (e) {
      toast(e.message.tr, isShort: false);
      if (watch) {
        addWatchedTagState = LoadingState.error;
      } else {
        addHiddenTagState = LoadingState.error;
      }
      return;
    }

    if (watch) {
      addWatchedTagState = LoadingState.success;
    } else {
      addHiddenTagState = LoadingState.success;
    }

    toast(watch
        ? 'addNewWatchedTagSetSuccess'.tr
        : 'addNewHiddenTagSetSuccess'.tr);

    myTagsSetting.refreshOnlineTagSets(tagSetNumber);
  }
}
