import 'dart:math';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/pages/setting/account/login/login_page_logic.dart';
import 'package:skana_ehentai/src/pages/setting/account/login/login_page_state.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/icons.dart';
import 'package:skana_ehentai/src/widget/loading_state_indicator.dart';

import '../../../../utils/screen_size_util.dart';

class LoginPage extends StatelessWidget {
  final LoginPageLogic logic = Get.put<LoginPageLogic>(LoginPageLogic());
  final LoginPageState state = Get.find<LoginPageLogic>().state;

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginPageLogic>(
      builder: (_) => Scaffold(
        /// set false to deal with keyboard
        resizeToAvoidBottomInset: false,
        appBar: appBar(),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _TopArea(),
            Text('EHenTai',
                style: TextStyle(
                    color: UIConfig.loginPageForegroundColor(context),
                    fontSize: 60)),
            _buildForm(context),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      height: 300,
      width: 300,
      decoration: BoxDecoration(
          color: UIConfig.loginPageBackgroundColor(context),
          borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<LoginPageLogic>(
        id: LoginPageLogic.formId,
        builder: (_) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 170,
              child: Center(
                  child: state.loginType == LoginType.password
                      ? _buildUserNameForm(context)
                      : _buildCookieForm(context)),
            ),
            _buildButtons(context).marginOnly(top: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUserNameForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildUsernameField(context).marginOnly(top: 6),
        _buildPasswordField(context).marginOnly(top: 4),
        _buildUserNameFormHint(context).marginOnly(top: 24),
      ],
    );
  }

  Widget _buildUsernameField(BuildContext context) {
    return MoonTextInput(
      padding: EdgeInsets.symmetric(horizontal: 8),
      onEditingComplete: state.passwordFocusNode.requestFocus,
      onChanged: (userName) => state.userName = userName,
      hintText: 'userName'.tr,
      leading: moonIcon(
          icon: BootstrapIcons.person,
          color: UIConfig.loginPagePrefixIconColor(context)),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return MoonTextInput(
      padding: EdgeInsets.symmetric(horizontal: 8),
      focusNode: state.passwordFocusNode,
      obscureText: state.obscureText,
      onChanged: (password) => state.password = password,
      onSubmitted: (v) => logic.handleLogin(),
      hintText: 'password'.tr,
      leading: moonIcon(
          icon: BootstrapIcons.key,
          color: UIConfig.loginPagePrefixIconColor(context)),
      trailing: MoonEhButton(
        icon: state.obscureText ? BootstrapIcons.eye : BootstrapIcons.eye_slash,
        onTap: () {
          state.obscureText = !state.obscureText;
          logic.update();
        },
      ),
    );
  }

  Widget _buildUserNameFormHint(BuildContext context) {
    return Center(
      child: Text(
        'userNameFormHint'.tr,
        style: TextStyle(
            color: UIConfig.loginPageFormHintColor(context), fontSize: 13),
      ).small(),
    );
  }

  Widget _buildCookieForm(BuildContext context) {
    return GetBuilder<LoginPageLogic>(
      id: LoginPageLogic.cookieFormId,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIpbMemberIdField(context).marginOnly(top: 6),
          _buildIpbPassHashField(context).marginOnly(top: 6),
          Row(
            children: [
              Expanded(child: _buildIgneousField(context)),
              InkWell(
                onTap: logic.pasteCookie,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MoonEhButton(
                      buttonSize: MoonButtonSize.xs,
                      onTap: logic.pasteCookie,
                      icon: BootstrapIcons.clipboard,
                    ),
                    Text('parse'.tr).xSmall(),
                  ],
                ),
              ),
            ],
          ).marginOnly(top: 6),
        ],
      ),
    );
  }

  Widget _buildIpbMemberIdField(BuildContext context) {
    return MoonTextInput(
      padding: EdgeInsets.symmetric(horizontal: 8),
      key: const Key('ipbMemberId'),
      onEditingComplete: state.passwordFocusNode.requestFocus,
      controller: TextEditingController(text: state.ipbMemberId ?? ''),
      hintText: 'ipb_member_id',
      leading: moonIcon(icon: BootstrapIcons.cookie),
      trailing: SizedBox(
        height: 8,
        width: 16,
        child: Center(child: Text('*').small()),
      ),
      onChanged: (ipbMemberId) => state.ipbMemberId = ipbMemberId,
    );
  }

  Widget _buildIpbPassHashField(BuildContext context) {
    return MoonTextInput(
      padding: EdgeInsets.symmetric(horizontal: 8),
      key: const Key('ipbPassHash'),
      focusNode: state.ipbPassHashFocusNode,
      controller: TextEditingController(text: state.ipbPassHash ?? ''),
      hintText: 'ipb_pass_hash',
      leading: moonIcon(icon: BootstrapIcons.cookie),
      trailing: SizedBox(
        height: 8,
        width: 16,
        child: Center(child: Text('*').small()),
      ),
      onEditingComplete: state.igneousFocusNode.requestFocus,
      onSubmitted: (v) => logic.handleLogin(),
      onChanged: (ipbPassHash) => state.ipbPassHash = ipbPassHash,
    );
  }

  Widget _buildIgneousField(BuildContext context) {
    return MoonTextInput(
      padding: EdgeInsets.symmetric(horizontal: 8),
      key: const Key('igneous'),
      focusNode: state.igneousFocusNode,
      controller: TextEditingController(text: state.igneous ?? ''),
      hintText: 'igneousHint'.tr,
      leading: moonIcon(icon: BootstrapIcons.cookie),
      onChanged: (igneous) => state.igneous = igneous,
      onSubmitted: (v) => logic.handleLogin(),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: logic.handleWebLogin,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MoonEhButton(
                buttonSize: MoonButtonSize.xs,
                onTap: logic.handleWebLogin,
                icon: BootstrapIcons.globe_americas,
              ),
              Text('Web').xSmall(),
            ],
          ),
        ),
        MoonButton.icon(
          onTap: logic.handleLogin,
          icon: GetBuilder<LoginPageLogic>(
            id: LoginPageLogic.loadingStateId,
            builder: (_) => LoadingStateIndicator(
              useCupertinoIndicator: false,
              loadingState: state.loginState,
              indicatorRadius: 20,
              indicatorColor: UIConfig.loginPageIndicatorColor(context),
              idleWidgetBuilder: () =>
                  moonIcon(icon: BootstrapIcons.box_arrow_in_right, size: 30),
              successWidgetBuilder: () =>
                  moonIcon(icon: BootstrapIcons.check2, size: 30),
              errorWidgetSameWithIdle: true,
            ),
          ),
        ).marginSymmetric(horizontal: 18),
        InkWell(
          onTap: logic.toggleLoginType,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MoonEhButton(
                buttonSize: MoonButtonSize.xs,
                onTap: logic.toggleLoginType,
                icon: state.loginType == LoginType.password
                    ? BootstrapIcons.cookie
                    : BootstrapIcons.person_gear,
              ),
              Text(state.loginType == LoginType.password ? 'Cookie' : 'User')
                  .xSmall(),
            ],
          ),
        )
      ],
    );
  }
}

class _TopArea extends StatelessWidget {
  const _TopArea();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:
          max(screenHeight / 10 - MediaQuery.of(context).viewInsets.bottom, 0),
      width: double.infinity,
    );
  }
}
