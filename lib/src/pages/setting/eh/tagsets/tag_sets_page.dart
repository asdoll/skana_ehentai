import 'package:animate_do/animate_do.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/model/tag_set.dart';
import 'package:skana_ehentai/src/pages/setting/eh/tagsets/tag_sets_page_logic.dart';
import 'package:skana_ehentai/src/pages/setting/eh/tagsets/tag_sets_page_state.dart';
import 'package:skana_ehentai/src/utils/search_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/eh_wheel_speed_controller.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../../../../utils/route_util.dart';
import '../../../../utils/text_input_formatter.dart';
import '../../../../widget/loading_state_indicator.dart';

class TagSetsPage extends StatelessWidget {
  final TagSetsLogic logic = Get.put<TagSetsLogic>(TagSetsLogic());
  final TagSetsState state = Get.find<TagSetsLogic>().state;

  TagSetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context).paddingTop(4),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return appBar(
      titleWidget: GetBuilder<TagSetsLogic>(
        id: TagSetsLogic.titleId,
        builder: (_) => Text(state.tagSets.isEmpty
                ? 'myTags'.tr
                : state.tagSets
                    .firstWhere((t) => t.number == state.currentTagSetNo)
                    .name)
            .appSubHeader(),
      ),
      actions: [
        _buildTagSetColor(context),
        _buildTagSetSwitcher(),
      ],
    );
  }

  GetBuilder<TagSetsLogic> _buildTagSetColor(BuildContext context) {
    return GetBuilder<TagSetsLogic>(
      id: TagSetsLogic.tagSetId,
      builder: (_) => LoadingStateIndicator(
        loadingState: state.loadingState,
        idleWidgetBuilder: () => const SizedBox(),
        loadingWidgetBuilder: () => const SizedBox(),
        errorWidgetSameWithIdle: true,
        successWidgetBuilder: () => IconButton(
          icon: moonIcon(
            icon: BootstrapIcons.circle_fill,
            color: state.currentTagSetBackgroundColor ??
                UIConfig.ehWatchedTagDefaultBackGroundColor,
          ),
          onPressed: () async {
            dynamic result = await showDialog(
              context: context,
              builder: (context) => _ColorSettingDialog(
                  initialColor: state.currentTagSetBackgroundColor ??
                      UIConfig.ehWatchedTagDefaultBackGroundColor),
            );

            if (result == null) {
              return;
            }

            if (result == 'default') {
              logic.handleUpdateTagSetColor(null);
            }

            if (result is Color) {
              logic.handleUpdateTagSetColor(result);
            }
          },
        ),
      ),
    );
  }

  GetBuilder<TagSetsLogic> _buildTagSetSwitcher() {
    return GetBuilder<TagSetsLogic>(
      id: TagSetsLogic.titleId,
      builder: (_) => popupMenuButton<int>(
        initialValue: state.currentTagSetNo,
        onSelected: (value) {
          if (state.currentTagSetNo == value) {
            return;
          }
          state.currentTagSetNo = value;
          logic.getCurrentTagSet();
        },
        itemBuilder: (_) => state.tagSets
            .map(
              (t) => PopupMenuItem<int>(
                  value: t.number, child: Center(child: Text(t.name).small())),
            )
            .toList(),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return GetBuilder<TagSetsLogic>(
      id: TagSetsLogic.bodyId,
      builder: (_) {
        return LoadingStateIndicator(
          loadingState: state.loadingState,
          errorTapCallback: logic.getCurrentTagSet,
          successWidgetBuilder: () => EHWheelSpeedController(
            controller: state.scrollController,
            child: SafeArea(
              child: ListView.builder(
                itemExtent: 64,
                cacheExtent: 3000,
                itemCount: state.tags.length,
                controller: state.scrollController,
                itemBuilder: (_, int index) => GetBuilder<TagSetsLogic>(
                  id: '${TagSetsLogic.tagId}::${state.tags[index].tagId}',
                  builder: (_) => LoadingStateIndicator(
                    loadingState: state.updateTagState,
                    idleWidgetBuilder: () => FadeIn(
                      child: _Tag(
                        tag: state.tags[index],
                        tagSetBackgroundColor:
                            state.currentTagSetBackgroundColor,
                        onTap: () => logic.showTrigger(index, context),
                        onLongPress: () => newSearch(
                            keyword:
                                '${state.tags[index].tagData.namespace}:${state.tags[index].tagData.key}'),
                        onColorUpdated: (v) =>
                            logic.handleUpdateTagColor(index, v),
                        onWeightUpdated: (v) =>
                            logic.handleUpdateTagWeight(index, v),
                        onStatusUpdated: (v) =>
                            logic.handleUpdateTagStatus(index, v),
                      ),
                    ),
                    errorWidgetSameWithIdle: true,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  final WatchedTag tag;
  final Color? tagSetBackgroundColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<Color?> onColorUpdated;
  final ValueChanged<String> onWeightUpdated;
  final ValueChanged<TagSetStatus> onStatusUpdated;

  const _Tag({
    required this.tag,
    this.tagSetBackgroundColor,
    this.onTap,
    this.onLongPress,
    required this.onColorUpdated,
    required this.onWeightUpdated,
    required this.onStatusUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onSecondaryTap: onTap,
        onLongPress: onLongPress,
        child: moonListTile(
          onTap: () {
            Get.focusScope?.unfocus();
            onTap?.call();
          },
          leading: _buildLeadingIcon(context),
          title: tag.tagData.translatedNamespace == null
              ? '${tag.tagData.namespace}:${tag.tagData.key}'
              : '${tag.tagData.translatedNamespace}:${tag.tagData.tagName}',
          subtitle: tag.tagData.translatedNamespace == null
              ? null
              : '${tag.tagData.namespace}:${tag.tagData.key}',
          trailing: _buildWeight(),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    return MoonEhButton.md(
      icon: tag.watched
          ? BootstrapIcons.heart
          : tag.hidden
              ? BootstrapIcons.ban
              : BootstrapIcons.question_lg,
      color: tag.backgroundColor ??
          tagSetBackgroundColor ??
          UIConfig.ehWatchedTagDefaultBackGroundColor,
      onTap: () async {
        dynamic result = await showDialog(
          context: context,
          builder: (context) => _ColorSettingDialog(
              initialColor: tag.backgroundColor ??
                  tagSetBackgroundColor ??
                  UIConfig.ehWatchedTagDefaultBackGroundColor),
        );

        if (result == null) {
          return;
        }

        if (result == 'default') {
          onColorUpdated(null);
        }

        if (result is Color) {
          onColorUpdated(result);
        }
      },
    );
  }

  Widget _buildWeight() {
    return SizedBox(
      width: 40,
      child: MoonTextInput(
        textInputSize: MoonTextInputSize.sm,
        controller: TextEditingController(text: tag.weight.toString()),
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d-]')),
          IntRangeTextInputFormatter(minValue: -99, maxValue: 99),
        ],
        onSubmitted: onWeightUpdated,
      ),
    );
  }
}

enum TagSetStatus { watched, hidden, nope }

class _ColorSettingDialog extends StatefulWidget {
  final Color initialColor;

  const _ColorSettingDialog({required this.initialColor});

  @override
  State<_ColorSettingDialog> createState() => _ColorSettingDialogState();
}

class _ColorSettingDialogState extends State<_ColorSettingDialog> {
  late Color selectedColor;

  @override
  void initState() {
    selectedColor = widget.initialColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context: context,
      title: "",
      contentWidget: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ColorPicker(
          color: selectedColor,
          pickersEnabled: const <ColorPickerType, bool>{
            ColorPickerType.both: true,
            ColorPickerType.primary: false,
            ColorPickerType.accent: false,
            ColorPickerType.bw: false,
            ColorPickerType.custom: false,
            ColorPickerType.wheel: true,
          },
          pickerTypeLabels: <ColorPickerType, String>{
            ColorPickerType.both: 'preset'.tr,
            ColorPickerType.wheel: 'custom'.tr,
          },
          enableTonalPalette: true,
          showColorCode: true,
          colorCodeHasColor: true,
          materialNameTextStyle: Get.context?.moonTheme?.tokens.typography.heading.text12,
          colorNameTextStyle: Get.context?.moonTheme?.tokens.typography.heading.text12,
          pickerTypeTextStyle: Get.context?.moonTheme?.tokens.typography.heading.text12,
          colorCodeTextStyle: Get.context?.moonTheme?.tokens.typography.heading.text16,
          width: 30,
          height: 30,
          columnSpacing: 12,
          onColorChanged: (Color color) {
            selectedColor = color;
          },
        ),
      ),
      actions: [
        outlinedButton(label: 'cancel'.tr, onPressed: backRoute),
        filledButton(
          label: 'reset'.tr,
          onPressed: () {
            backRoute(result: 'default');
          },
        ),
        filledButton(
          label: 'OK'.tr,
          onPressed: () {
            backRoute(result: selectedColor);
          },
        ),
      ],
    );
  }
}
