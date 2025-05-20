import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/get_logic_extension.dart';
import 'package:skana_ehentai/src/extension/list_extension.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/pages/search/mixin/search_page_mixin.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:throttling/throttling.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../database/database.dart';
import '../model/eh_raw_tag.dart';
import '../network/eh_request.dart';
import '../service/tag_translation_service.dart';
import '../utils/eh_spider_parser.dart';
import '../service/log.dart';
import '../utils/route_util.dart';
import '../utils/string_uril.dart';
import 'loading_state_indicator.dart';

class EHAddTagDialog extends StatelessWidget {
  final EHAddTagDialogLogic logic = Get.put(EHAddTagDialogLogic());
  final EHAddTagDialogState state = Get.find<EHAddTagDialogLogic>().state;

  EHAddTagDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context: context,
      title: 'addTag'.tr,
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tagTranslationService.isReady)
            Row(
              children: [
                Text('useTranslation'.tr).small(),
                GetBuilder<EHAddTagDialogLogic>(
                  id: EHAddTagDialogLogic.checkBoxId,
                  builder: (_) => MoonCheckbox(
                    value: state.useTranslation,
                    onChanged: (value) {
                      state.useTranslation = value!;
                      logic.updateSafely([EHAddTagDialogLogic.checkBoxId]);
                    },
                  ),
                ),
              ],
            ),
          SizedBox(
            width: UIConfig.addTagDialogWidth,
            height: UIConfig.addTagDialogHeight,
            child: Column(
              children: [
                _buildSearchField(),
                _buildNoDataIndicator(),
                Expanded(child: _buildSuggestions(context)),
              ],
            ),
          )
        ],
      ),
      actions: [
        MoonButton.icon(
          icon: Icon(BootstrapIcons.question_circle, color: UIConfig.primaryColor(context), size: 20,),
          onTap: () => launchUrlString(
              'https://ehwiki.org/wiki/Gallery_Tagging',
              mode: LaunchMode.externalApplication),
        ),
        filledButton(
            label: 'OK'.tr,
            onPressed: () => backRoute(result: state.keyword)),
      ],
    );
  }

  Widget _buildSearchField() {
    return GetBuilder<EHAddTagDialogLogic>(
      id: EHAddTagDialogLogic.searchFieldId,
      builder: (_) {
        return MoonTextInput(
          focusNode: state.focusNode,
          textInputAction: TextInputAction.search,
          textAlignVertical: TextAlignVertical.center,
          controller: TextEditingController.fromValue(
            TextEditingValue(
              text: state.keyword,

              /// make cursor stay at last letter
              selection: TextSelection.fromPosition(
                  TextPosition(offset: state.keyword.length)),
            ),
          ),
          onChanged: (text) {
            state.keyword = text;
            logic.waitAndSearchTags();
          },
          hintText: 'addTagHint'.tr,
          leading: moonIcon(icon: BootstrapIcons.search),
          trailing: _buildLoadingIndicator(),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return GetBuilder<EHAddTagDialogLogic>(
      id: EHAddTagDialogLogic.loadingIndicatorId,
      builder: (_) => state.searchLoadingState == LoadingState.loading
          ? const CupertinoActivityIndicator()
          : const SizedBox(),
    );
  }

  Widget _buildNoDataIndicator() {
    return GetBuilder<EHAddTagDialogLogic>(
      id: EHAddTagDialogLogic.loadingIndicatorId,
      builder: (_) => state.searchLoadingState == LoadingState.noData
          ? Text('noData'.tr).appHeader().marginOnly(top: 24)
          : const SizedBox(),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    return GetBuilder<EHAddTagDialogLogic>(
      id: EHAddTagDialogLogic.tagsId,
      builder: (_) => ListView.builder(
        padding: const EdgeInsets.only(top: 12),
        itemCount: state.suggestions.length,
        itemBuilder: (_, int index) => moonListTileWidgets(
          onTap: () {
            logic.defaultOnTap(state.suggestions[index].tagData);
          },
          label: state.suggestions[index].tagData.tagName == null
              ? highlightRawTag(
                  context,
                  state.suggestions[index],
                  TextStyle(
                      fontSize: UIConfig.searchPageSuggestionTitleTextSize,
                      color: UIConfig.searchPageSuggestionTitleColor(context)),
                  const TextStyle(
                      fontSize: UIConfig.searchPageSuggestionTitleTextSize,
                      color: UIConfig.searchPageSuggestionHighlightColor),
                )
              : highlightTranslatedTag(
                  context,
                  state.suggestions[index],
                  TextStyle(
                      fontSize: UIConfig.searchPageSuggestionTitleTextSize,
                      color: UIConfig.searchPageSuggestionTitleColor(context)),
                  const TextStyle(
                      fontSize: UIConfig.searchPageSuggestionTitleTextSize,
                      color: UIConfig.searchPageSuggestionHighlightColor),
                ),
          content: state.suggestions[index].tagData.tagName == null
              ? null
              : highlightRawTag(
                  context,
                  state.suggestions[index],
                  TextStyle(
                      fontSize: UIConfig.searchPageSuggestionSubTitleTextSize,
                      color:
                          UIConfig.searchPageSuggestionSubTitleColor(context)),
                  const TextStyle(
                      fontSize: UIConfig.searchPageSuggestionSubTitleTextSize,
                      color: UIConfig.searchPageSuggestionHighlightColor),
                ),
          trailing: const Icon(BootstrapIcons.plus),
        ),
      ).enableMouseDrag(withScrollBar: true),
    );
  }

  RichText highlightKeyword(BuildContext context, String rawText,
      String currentKeyword, bool isSubTitle) {
    List<TextSpan> children = <TextSpan>[];

    List<int> matchIndexes =
        currentKeyword.allMatches(rawText).map((match) => match.start).toList();

    int indexHandling = 0;
    for (int index in matchIndexes) {
      if (index > indexHandling) {
        children.add(
          TextSpan(
            text: rawText.substring(indexHandling, index),
            style: TextStyle(
              fontSize: isSubTitle
                  ? UIConfig.searchPageSuggestionSubTitleTextSize
                  : UIConfig.searchPageSuggestionTitleTextSize,
              color: isSubTitle
                  ? UIConfig.searchPageSuggestionSubTitleColor(context)
                  : UIConfig.searchPageSuggestionTitleColor(context),
            ),
          ),
        );
      }

      children.add(
        TextSpan(
          text: currentKeyword,
          style: TextStyle(
            fontSize: isSubTitle
                ? UIConfig.searchPageSuggestionSubTitleTextSize
                : UIConfig.searchPageSuggestionTitleTextSize,
            color: UIConfig.searchPageSuggestionHighlightColor,
          ),
        ),
      );

      indexHandling = index + currentKeyword.length;
    }

    if (rawText.length > indexHandling) {
      children.add(
        TextSpan(
          text: rawText.substring(indexHandling, rawText.length),
          style: TextStyle(
            fontSize: isSubTitle
                ? UIConfig.searchPageSuggestionSubTitleTextSize
                : UIConfig.searchPageSuggestionTitleTextSize,
            color: isSubTitle
                ? UIConfig.searchPageSuggestionSubTitleColor(context)
                : UIConfig.searchPageSuggestionTitleColor(context),
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: children));
  }
}

class EHAddTagDialogLogic extends GetxController {
  static const String checkBoxId = 'checkBoxId';
  static const String searchFieldId = 'searchFieldId';
  static const String loadingIndicatorId = 'loadingIndicatorId';
  static const String tagsId = 'tagsId';

  EHAddTagDialogState state = EHAddTagDialogState();

  String get lastKeyWord => state.keyword.split(',').last.trim();

  @override
  void onClose() {
    super.onClose();
    state.focusNode.dispose();
  }

  void waitAndSearchTags() {
    if (isEmptyOrNull(state.keyword)) {
      return;
    }
    state.searchDebouncing.debounce(searchTags);
  }

  Future<void> searchTags() async {
    if (state.searchLoadingState == LoadingState.loading) {
      return;
    }
    if (isEmptyOrNull(state.keyword)) {
      return;
    }

    log.info('search for $lastKeyWord');

    state.searchLoadingState = LoadingState.loading;
    updateSafely([loadingIndicatorId]);

    if (state.useTranslation && tagTranslationService.isReady) {
      state.suggestions =
          await tagTranslationService.searchTags(lastKeyWord, limit: 100);
    } else {
      try {
        List<EHRawTag> tags = await ehRequest.requestTagSuggestion(
            lastKeyWord, EHSpiderParser.tagSuggestion2TagList);
        state.suggestions = tags
            .map((t) => (
                  searchText: lastKeyWord,
                  matchStart: 0,
                  matchEnd: lastKeyWord.length,
                  tagData: TagData(namespace: t.namespace, key: t.key),
                  operator: null,
                  score: 0.0,
                  namespaceMatch: t.namespace.contains(lastKeyWord)
                      ? (
                          start: t.namespace.indexOf(lastKeyWord),
                          end: t.namespace.indexOf(lastKeyWord) +
                              lastKeyWord.length
                        )
                      : null,
                  translatedNamespaceMatch: null,
                  keyMatch: t.key.contains(lastKeyWord)
                      ? (
                          start: t.key.indexOf(lastKeyWord),
                          end: t.key.indexOf(lastKeyWord) + lastKeyWord.length
                        )
                      : null,
                  tagNameMatch: null,
                ))
            .toList();
      } on DioException catch (e) {
        log.error('Request tag suggestion failed', e);
        state.suggestions = [];
        state.searchLoadingState = LoadingState.error;
        updateSafely([loadingIndicatorId]);
        return;
      }
    }

    if (state.suggestions.isEmpty) {
      state.searchLoadingState = LoadingState.noData;
    } else {
      state.searchLoadingState = LoadingState.success;
    }
    updateSafely([loadingIndicatorId, tagsId]);
  }

  void defaultOnTap(TagData tag) {
    List<String> segments = state.keyword.split(',');
    segments.removeLast();
    segments.add('${tag.namespace}:${tag.key}');
    state.keyword = segments.joinNewElement(',', joinAtLast: true).join('');
    updateSafely([searchFieldId]);
    state.focusNode.requestFocus();
  }
}

class EHAddTagDialogState {
  String keyword = '';
  List<TagAutoCompletionMatch> suggestions = [];

  bool useTranslation = true;

  final Debouncing searchDebouncing =
      Debouncing(duration: const Duration(milliseconds: 300));
  LoadingState searchLoadingState = LoadingState.idle;
  FocusNode focusNode = FocusNode();
}
