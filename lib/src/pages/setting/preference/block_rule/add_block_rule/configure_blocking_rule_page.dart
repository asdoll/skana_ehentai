import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/get_logic_extension.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

import '../../../../../service/local_block_rule_service.dart';
import '../../../../../widget/eh_wheel_speed_controller.dart';
import 'configure_blocking_rule_page_logic.dart';
import 'configure_blocking_rule_page_state.dart';

class ConfigureBlockingRulePage extends StatelessWidget {
  final ConfigureBlockingRulePageLogic logic = Get.put<ConfigureBlockingRulePageLogic>(ConfigureBlockingRulePageLogic());
  final ConfigureBlockingRulePageState state = Get.find<ConfigureBlockingRulePageLogic>().state;

  ConfigureBlockingRulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        title: 'blockingRules'.tr,
        actions: [
          filledButton(onPressed: logic.configureCurrentBlockRulesByGroup, label: 'OK'.tr),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return GetBuilder<ConfigureBlockingRulePageLogic>(
      id: logic.bodyId,
      builder: (_) => EHWheelSpeedController(
        controller: state.scrollController,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 80, left: 8, right: 8),
          controller: state.scrollController,
          children: [
            ...state.rules.map((rule) => _buildRuleForm(rule).marginOnly(bottom: 12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MoonEhButton(
                  icon: BootstrapIcons.plus_circle,
                  color: UIConfig.resumePauseButtonColor(Get.context!),
                  onTap: logic.addRuleForm,
                ),
              ],
            ).marginOnly(top: 12),
            const Divider(height: 48),
            _buildHelp(context).marginOnly(),
          ],
        ).enableMouseDrag(withScrollBar: true),
      ),
    );
  }

  Widget _buildRuleForm(LocalBlockRule rule) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Column(
              children: [
                moonListTile(
                  title: 'blockingTarget'.tr,
                  trailing: popupMenuButton<LocalBlockTargetEnum>(
                    itemBuilder: (context) => LocalBlockTargetEnum.values.map((e) => PopupMenuItem(value: e, child: Text(e.desc.tr).small())).toList(),
                    onSelected: (LocalBlockTargetEnum newValue) {
                      rule.target = newValue;
                      rule.attribute = LocalBlockAttributeEnum.withTarget(rule.target).first;
                      rule.pattern = LocalBlockPatternEnum.withAttribute(rule.attribute).first;
                      logic.updateSafely([logic.bodyId]);
                    },
                    child: filledButton(onPressed: () {}, label: rule.target.desc.tr),
                  ),
                ),
                moonListTile(
                  title: 'blockingAttribute'.tr,
                  trailing: popupMenuButton<LocalBlockAttributeEnum>(
                    itemBuilder: (context) => LocalBlockAttributeEnum.withTarget(rule.target)
                        .map((e) => PopupMenuItem(value: e, child: Text(e.desc.tr).small()))
                        .toList(),
                    onSelected: (LocalBlockAttributeEnum newValue) {
                      rule.attribute = newValue;
                      rule.pattern = LocalBlockPatternEnum.withAttribute(rule.attribute).first;
                      logic.updateSafely([logic.bodyId]);
                    },
                    child: filledButton(onPressed: () {}, label: rule.attribute.desc.tr),
                  ),
                ),
                moonListTile(
                  title: 'blockingPattern'.tr,
                  trailing: popupMenuButton<LocalBlockPatternEnum>(
                    itemBuilder: (context) => LocalBlockPatternEnum.withAttribute(rule.attribute)
                        .map((e) => PopupMenuItem(value: e, child: Text(e.desc.tr).small()))
                        .toList(),
                    onSelected: (LocalBlockPatternEnum newValue) {
                      rule.pattern = newValue;
                      logic.updateSafely([logic.bodyId]);
                    },
                    child: filledButton(onPressed: () {}, label: rule.pattern.desc.tr),
                  ),
                ),
                moonListTile(
                  title: 'blockingExpression'.tr,
                  trailing: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180, minWidth: 100),
                    child: MoonTextInput(
                      controller: TextEditingController(text: rule.expression),
                      textAlign: TextAlign.right,
                      onChanged: (text) {
                        rule.expression = text;
                      },
                    ),
                  ),
                ),
              ],
            ).paddingAll(8),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MoonEhButton(
              icon: BootstrapIcons.dash_circle,
              color: UIConfig.resumePauseButtonColor(Get.context!),
              onTap: () {
                logic.removeRuleForm(rule);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHelp(BuildContext context) {
    return Text(
      'blockingRuleHelp'.tr,
      style: TextStyle(
        fontSize: 12,
        color: UIConfig.blockingRulePageHelpTextColor(context),
      ),
    );
  }
}
