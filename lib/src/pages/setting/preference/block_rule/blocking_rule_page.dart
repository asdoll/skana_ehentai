import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/pages/setting/preference/block_rule/add_block_rule/configure_blocking_rule_page_logic.dart';
import 'package:skana_ehentai/src/service/local_block_rule_service.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/eh_alert_dialog.dart';
import 'package:skana_ehentai/src/widget/grouped_list.dart';
import 'package:skana_ehentai/src/widget/icons.dart';
import '../../../../config/ui_config.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/route_util.dart';
import '../../../../widget/eh_wheel_speed_controller.dart';
import '../../../download/download_base_page.dart';
import 'blocking_rule_page_logic.dart';
import 'blocking_rule_page_state.dart';

class BlockingRulePage extends StatelessWidget {
  final BlockingRulePageLogic logic =
      Get.put<BlockingRulePageLogic>(BlockingRulePageLogic());
  final BlockingRulePageState state = Get.find<BlockingRulePageLogic>().state;

  BlockingRulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        title: 'blockingRules'.tr,
        actions: [
          MoonEhButton.md(
            icon: BootstrapIcons.list,
            onTap: logic.toggleShowGroup,
          ),
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: MoonButton.icon(
        buttonSize: MoonButtonSize.lg,
        showBorder: true,
        borderColor: Get.context?.moonTheme?.buttonTheme.colors.borderColor
            .withValues(alpha: 0.5),
        backgroundColor: Get.context?.moonTheme?.tokens.colors.zeno,
        onTap: () {
          toRoute(Routes.configureBlockingRules,
                  arguments: const ConfigureBlockingRulePageArgument(
                      mode: ConfigureBlockingRulePageMode.add))
              ?.then((_) {
            logic.getBlockRules();
          });
        },
        icon: Icon(
          BootstrapIcons.plus,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return GetBuilder<BlockingRulePageLogic>(
      id: logic.bodyId,
      builder: (_) {
        Widget child = FutureBuilder(
          future: state.showGroupCompleter.future,
          builder: (_, __) => !state.showGroupCompleter.isCompleted
              ? Center(child: UIConfig.loadingAnimation(context))
              : state.showGroup
                  ? GroupedList<String, List<LocalBlockRule>>(
                      maxGalleryNum4Animation: 50,
                      scrollController: state.scrollController,
                      controller: state.groupedListController,
                      groups: state.groupedRules.map(
                        (groupId, rules) => MapEntry(
                            '${rules.first.target.desc.tr}${rules.length > 1 ? '' : ' - ${rules.first.attribute.desc.tr}'}',
                            true),
                      ),
                      elements: state.groupedRules.values.toList(),
                      elementGroup: (List<LocalBlockRule> rules) =>
                          '${rules.first.target.desc.tr}${rules.length > 1 ? '' : ' - ${rules.first.attribute.desc.tr}'}',
                      groupBuilder: (context, group, isOpen) =>
                          _groupBuilder(context, group, isOpen).marginAll(5),
                      elementBuilder: (BuildContext context, String group,
                              List<LocalBlockRule> rules, isOpen) =>
                          _elementBuilder(context, group, rules),
                      groupUniqueKey: (String group) => group,
                      elementUniqueKey: (List<LocalBlockRule> rules) =>
                          rules.first.groupId!,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      itemCount: state.groupedRules.keys.length,
                      controller: state.scrollController,
                      itemBuilder: _itemBuilder,
                    ),
        );

        return EHWheelSpeedController(
          controller: state.scrollController,
          child: SafeArea(child: child..withListTileTheme(context)),
        );
      },
    );
  }

  Widget _groupBuilder(BuildContext context, String groupName, bool isOpen) {
    return GestureDetector(
      onTap: () => logic.toggleDisplayGroups(groupName),
      child: Container(
        height: UIConfig.groupListHeight,
        decoration: BoxDecoration(
          color: UIConfig.groupListColor(context),
          boxShadow: [if (!Get.isDarkMode) UIConfig.groupListShadow(context)],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Text(groupName, maxLines: 1, overflow: TextOverflow.ellipsis),
            const Expanded(child: SizedBox()),
            GroupOpenIndicator(isOpen: isOpen).marginOnly(right: 8),
          ],
        ),
      ),
    );
  }

  Widget _elementBuilder(
      BuildContext context, String group, List<LocalBlockRule> rules) {
    return moonListTileWidgets(
      leading: Text(
          rules.length == 1 ? rules.first.pattern.desc.tr : 'other'.tr).small(),
      label: Text(
        rules.length == 1
            ? rules.first.expression
            : rules
                .map((rule) =>
                    '(${rule.attribute.desc.tr} ${rule.pattern.desc.tr} ${rule.expression})')
                .join(' && '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ).subHeader(),
      trailing: _buildListTileTrailing(context, rules.first.groupId!, rules),
    ).paddingSymmetric(horizontal: 4);
  }

  Widget _itemBuilder(BuildContext context, int index) {
    MapEntry<String, List<LocalBlockRule>> entry =
        state.groupedRules.entries.toList()[index];

    return moonListTile(
      leading: Text(entry.value.first.target.desc.tr).small(),
      title: entry.value.map((rule) => rule.attribute.desc.tr).join('+'),
      subtitleWidget: Text(
        entry.value
            .map((rule) =>
                '(${rule.attribute.desc.tr} ${rule.pattern.desc.tr} ${rule.expression})')
            .join(' && '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ).small(),
      trailing: _buildListTileTrailing(context, entry.key, entry.value),
    );
  }

  Row _buildListTileTrailing(
      BuildContext context, String groupId, List<LocalBlockRule> rules) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MoonEhButton(
          icon: BootstrapIcons.pencil,
          onTap: () async {
            toRoute(
              Routes.configureBlockingRules,
              arguments: ConfigureBlockingRulePageArgument(
                mode: ConfigureBlockingRulePageMode.edit,
                groupRules: (groupId: groupId, rules: rules),
              ),
            )?.then((_) => logic.getBlockRules());
          },
        ),
        MoonEhButton(
          icon: BootstrapIcons.trash,
          onTap: () async {
            bool? result = await showDialog(
                context: context,
                builder: (_) => EHDialog(title: '${'delete'.tr}?'));
            if (result == true) {
              await logic.removeLocalBlockRulesByGroupId(groupId);
              logic.getBlockRules();
            }
          },
        ),
      ],
    );
  }
}
