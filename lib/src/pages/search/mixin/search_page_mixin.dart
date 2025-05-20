import 'package:animate_do/animate_do.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/pages/base/base_page.dart';
import 'package:skana_ehentai/src/pages/details/details_page_logic.dart';
import 'package:skana_ehentai/src/pages/gallery_image/gallery_image_page_logic.dart';
import 'package:skana_ehentai/src/pages/search/mixin/search_page_logic_mixin.dart';
import 'package:skana_ehentai/src/pages/search/mixin/search_page_state_mixin.dart';
import 'package:skana_ehentai/src/setting/style_setting.dart';
import 'package:skana_ehentai/src/utils/search_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../../../database/database.dart';
import '../../../model/gallery_tag.dart';
import '../../../model/search_history.dart';
import '../../../routes/routes.dart';
import '../../../service/search_history_service.dart';
import '../../../service/tag_translation_service.dart';
import '../../../utils/route_util.dart';
import '../../../widget/eh_search_config_dialog.dart';
import '../../../widget/eh_tag.dart';
import '../../../widget/eh_wheel_speed_controller.dart';

mixin SearchPageMixin<L extends SearchPageLogicMixin,
    S extends SearchPageStateMixin> on BasePage<L, S> {
  @override
  L get logic;

  @override
  S get state;

  List<Widget> buildActionButtons({VisualDensity? visualDensity}) {
    return [
      MoonEhButton(
        icon: BootstrapIcons.paperclip,
        onTap: logic.handleFileSearch,
      ),
      MoonEhButton(
        icon: BootstrapIcons.clock_history,
        onTap: logic.handleTapJumpButton,
      ),
      MoonEhButton(
        icon: state.bodyType == SearchPageBodyType.gallerys
            ? BootstrapIcons.search
            : BootstrapIcons.image,
        onTap: logic.toggleBodyType,
      ),
      MoonEhButton(
        icon: BootstrapIcons.filter,
        onTap: () =>
            logic.handleTapFilterButton(EHSearchConfigDialogType.filter),
      ),
      MoonEhButton(
        icon: BootstrapIcons.three_dots,
        onTap: () => toRoute(Routes.quickSearch),
      ),
    ];
  }

  Widget buildSearchField() {
    return GetBuilder<L>(
      global: false,
      init: logic,
      id: logic.searchFieldId,
      builder: (_) => SizedBox(
        height: styleSetting.isInDesktopLayout
            ? UIConfig.desktopSearchBarHeight
            : UIConfig.mobileV2SearchBarHeight,
        child: FutureBuilder(
          future: state.searchConfigInitCompleter.future,
          builder: (_, __) => MoonTextInput(
            focusNode: state.searchFieldFocusNode,
            textInputAction: TextInputAction.search,
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: state.searchConfig.keyword == null ||
                        state.searchConfig.keyword!.trim().isEmpty
                    ? state.searchConfig.computeFullKeywords()
                    : state.searchConfig.keyword!,

                /// make cursor stay at last letter
                selection: TextSelection.fromPosition(TextPosition(
                    offset: state.searchConfig.keyword?.length ?? 0)),
              ),
            ),
            style: const TextStyle(fontSize: 15),
            textAlignVertical: TextAlignVertical.center,
            hintText: 'search'.tr,
            hasFloatingLabel: true,
            leading: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: logic.handleClearAndRefresh,
                  child: moonIcon(icon: BootstrapIcons.search)),
            ),
            trailing: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: logic.handleTapClearButton,
                  child: moonIcon(icon: BootstrapIcons.x)),
            ),
            onTap: () {
              if (state.bodyType == SearchPageBodyType.gallerys) {
                state.hideSearchHistory = false;
                logic.toggleBodyType();
              }
            },
            onChanged: logic.onInputChanged,
            onSubmitted: (_) => logic.handleClearAndRefresh(),
          ),
        ),
      ),
    );
  }

  Widget buildOpenGalleryArea() {
    if (state.inputGalleryUrl == null &&
        state.inputGalleryImagePageUrl == null) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        title: Text('openGallery'.tr),
        subtitle: Text(
            state.inputGalleryUrl?.url ?? state.inputGalleryImagePageUrl!.url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        leading: const Icon(Icons.open_in_new),
        onTap: () {
          state.searchFieldFocusNode.unfocus();

          if (state.inputGalleryUrl != null) {
            toRoute(Routes.details,
                arguments:
                    DetailsPageArgument(galleryUrl: state.inputGalleryUrl!));
          } else if (state.inputGalleryImagePageUrl != null) {
            toRoute(Routes.imagePage,
                arguments: GalleryImagePageArgument(
                    galleryImagePageUrl: state.inputGalleryImagePageUrl!));
          }
        },
      ),
    );
  }

  Widget buildSuggestionAndHistoryBody(BuildContext context) {
    return EHWheelSpeedController(
      controller: state.scrollController,
      child: CustomScrollView(
        key: const PageStorageKey('suggestionBody'),
        controller: state.scrollController,
        scrollBehavior: UIConfig.scrollBehaviourWithScrollBarWithMouse,
        slivers: [
          if (searchHistoryService.histories.isNotEmpty) buildSearchHistory(),
          if (searchHistoryService.histories.isNotEmpty) buildButtons(context),
          buildSuggestions(context),
        ],
      ),
    );
  }

  Widget buildSearchHistory() {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      sliver: SliverToBoxAdapter(
        child: AnimatedSwitcher(
          duration: const Duration(
              milliseconds: UIConfig.searchPageAnimationDuration),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SizeTransition(sizeFactor: animation, child: child)),
          child:
              state.hideSearchHistory ? const SizedBox() : buildHistoryChips(),
        ),
      ),
    );
  }

  Widget buildHistoryChips() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 7,
            children:
                searchHistoryService.histories.map(buildHistoryChip).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildHistoryChip(SearchHistory history) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (state.inDeleteSearchHistoryMode) {
            logic.handleDeleteSearchHistory(history);
          } else {
            newSearch(keyword: '${history.rawKeyword} ');
          }
        },
        onLongPress: state.inDeleteSearchHistoryMode
            ? null
            : () {
                if (state.searchConfigInitCompleter.isCompleted) {
                  state.searchConfig.keyword =
                      '${(state.searchConfig.keyword ?? '').trimLeft()} ${history.rawKeyword}';
                  logic.update([logic.searchFieldId]);
                }
              },
        child: EHTag(
          tag: GalleryTag(
            tagData: TagData(
              namespace: '',
              key: state.enableSearchHistoryTranslation
                  ? history.translatedKeyword ?? history.rawKeyword
                  : history.rawKeyword,
            ),
          ),
          inDeleteMode: state.inDeleteSearchHistoryMode,
        ),
      ),
    );
  }

  Widget buildButtons(BuildContext context) {
    return SliverToBoxAdapter(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedSwitcher(
            duration: const Duration(
                milliseconds: UIConfig.searchPageAnimationDuration),
            child: state.hideSearchHistory || !tagTranslationService.isReady
                ? null
                : MoonEhButton(
                    onTap: logic.toggleEnableSearchHistoryTranslation,
                    icon: BootstrapIcons.translate,
                    color: UIConfig.primaryColor((context)),
                  ),
          ),
          AnimatedSwitcher(
            duration: const Duration(
                milliseconds: UIConfig.searchPageAnimationDuration),
            child: GestureDetector(
              onLongPress: state.hideSearchHistory
                  ? null
                  : logic.handleClearAllSearchHistories,
              child: MoonEhButton(
                  key: ValueKey(state.hideSearchHistory),
                  onTap: state.hideSearchHistory
                      ? logic.toggleHideSearchHistory
                      : logic.toggleDeleteSearchHistoryMode,
                  icon: state.hideSearchHistory
                      ? BootstrapIcons.eye
                      : state.inDeleteSearchHistoryMode
                          ? BootstrapIcons.x
                          : BootstrapIcons.trash,
                  color: !(state.hideSearchHistory ||
                          state.inDeleteSearchHistoryMode)
                      ? UIConfig.alertColor(context)
                      : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSuggestions(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 16, bottom: 400),
      sliver: SliverList.builder(
        itemBuilder: (context, index) => FadeIn(
          duration: const Duration(milliseconds: 400),
          child: ListTile(
            title: highlightRawTag(
              context,
              state.suggestions[index],
              TextStyle(
                  fontSize: UIConfig.searchPageSuggestionTitleTextSize,
                  color: UIConfig.searchPageSuggestionTitleColor(context)),
              const TextStyle(
                  fontSize: UIConfig.searchPageSuggestionTitleTextSize,
                  color: UIConfig.searchPageSuggestionHighlightColor),
            ),
            subtitle: state.suggestions[index].tagData.tagName == null
                ? null
                : highlightTranslatedTag(
                    context,
                    state.suggestions[index],
                    TextStyle(
                        fontSize: UIConfig.searchPageSuggestionSubTitleTextSize,
                        color: UIConfig.searchPageSuggestionSubTitleColor(
                            context)),
                    const TextStyle(
                        fontSize: UIConfig.searchPageSuggestionSubTitleTextSize,
                        color: UIConfig.searchPageSuggestionHighlightColor),
                  ),
            leading: Icon(Icons.search,
                color: UIConfig.searchPageSuggestionTitleColor(context)),
            dense: true,
            minLeadingWidth: 20,
            visualDensity: const VisualDensity(vertical: -1),
            onTap: () {
              if (state.searchConfigInitCompleter.isCompleted) {
                state.searchConfig.keyword =
                    '${state.searchConfig.keyword?.substring(0, state.suggestions[index].matchStart) ?? ''}${state.suggestions[index].operator ?? ''}${state.suggestions[index].tagData.namespace}:"${state.suggestions[index].tagData.key}\$" ';
                state.searchFieldFocusNode.requestFocus();
                logic.update([logic.searchFieldId]);
              }
            },
          ),
        ),
        itemCount: state.suggestions.length,
      ),
    );
  }
}

RichText highlightRawTag(BuildContext context, TagAutoCompletionMatch match,
    TextStyle? style, TextStyle? highlightStyle,
    {bool singleLine = false}) {
  List<TextSpan> children = <TextSpan>[];

  if (match.namespaceMatch == null) {
    children.add(TextSpan(text: match.tagData.namespace, style: style).small());
  } else {
    children.addAll(
      [
        TextSpan(
                text: match.tagData.namespace
                    .substring(0, match.namespaceMatch!.start),
                style: style)
            .small(),
        TextSpan(
                text: match.tagData.namespace.substring(
                    match.namespaceMatch!.start, match.namespaceMatch!.end),
                style: highlightStyle)
            .small(),
        TextSpan(
                text: match.tagData.namespace
                    .substring(match.namespaceMatch!.end),
                style: style)
            .small(),
      ],
    );
  }

  bool namespaceTotalMatch = match.namespaceMatch != null &&
      match.namespaceMatch!.start == 0 &&
      match.namespaceMatch!.end == match.tagData.namespace.length;
  children.add(
      TextSpan(text: ' : ', style: namespaceTotalMatch ? highlightStyle : style)
          .small());

  if (match.keyMatch == null) {
    children.add(TextSpan(text: match.tagData.key, style: style).small());
  } else {
    children.addAll(
      [
        TextSpan(
                text: match.tagData.key.substring(0, match.keyMatch!.start),
                style: style)
            .small(),
        TextSpan(
                text: match.tagData.key
                    .substring(match.keyMatch!.start, match.keyMatch!.end),
                style: highlightStyle)
            .small(),
        TextSpan(
                text: match.tagData.key.substring(match.keyMatch!.end),
                style: style)
            .small(),
      ],
    );
  }

  return RichText(
    text: TextSpan(children: children),
    maxLines: singleLine ? 1 : null,
    overflow: TextOverflow.ellipsis,
  );
}

RichText highlightTranslatedTag(BuildContext context,
    TagAutoCompletionMatch match, TextStyle? style, TextStyle? highlightStyle,
    {bool singleLine = false}) {
  List<TextSpan> children = <TextSpan>[];
  if (match.tagData.translatedNamespace == null ||
      match.tagData.tagName == null) {
    return RichText(text: TextSpan(children: children).small());
  }

  if (match.translatedNamespaceMatch == null) {
    children.add(TextSpan(text: match.tagData.translatedNamespace, style: style)
        .small());
  } else {
    children.addAll(
      [
        TextSpan(
                text: match.tagData.translatedNamespace!
                    .substring(0, match.translatedNamespaceMatch!.start),
                style: style)
            .small(),
        TextSpan(
                text: match.tagData.translatedNamespace!.substring(
                    match.translatedNamespaceMatch!.start,
                    match.translatedNamespaceMatch!.end),
                style: highlightStyle)
            .small(),
        TextSpan(
                text: match.tagData.translatedNamespace!
                    .substring(match.translatedNamespaceMatch!.end),
                style: style)
            .small(),
      ],
    );
  }

  bool translatedNamespaceTotalMatch = match.translatedNamespaceMatch != null &&
      match.translatedNamespaceMatch!.start == 0 &&
      match.translatedNamespaceMatch!.end ==
          match.tagData.translatedNamespace!.length;
  children.add(TextSpan(
          text: ' : ',
          style: translatedNamespaceTotalMatch ? highlightStyle : style)
      .small());

  if (match.tagNameMatch == null) {
    children.add(TextSpan(text: match.tagData.tagName!, style: style).small());
  } else {
    children.addAll(
      [
        TextSpan(
                text: match.tagData.tagName!
                    .substring(0, match.tagNameMatch!.start),
                style: style)
            .small(),
        TextSpan(
                text: match.tagData.tagName!.substring(
                    match.tagNameMatch!.start, match.tagNameMatch!.end),
                style: highlightStyle)
            .small(),
        TextSpan(
                text: match.tagData.tagName!.substring(match.tagNameMatch!.end),
                style: style)
            .small(),
      ],
    );
  }

  return RichText(
    text: TextSpan(children: children),
    maxLines: singleLine ? 1 : null,
    overflow: TextOverflow.ellipsis,
  );
}
