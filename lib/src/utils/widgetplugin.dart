import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/cupertino.dart' show RefreshIndicatorMode;
import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/widget/icons.dart';

extension WidgetExtension on Widget {
  Widget padding(EdgeInsetsGeometry padding) {
    return Padding(padding: padding, child: this);
  }

  Widget paddingLeft(double padding) {
    return Padding(padding: EdgeInsets.only(left: padding), child: this);
  }

  Widget paddingRight(double padding) {
    return Padding(padding: EdgeInsets.only(right: padding), child: this);
  }

  Widget paddingTop(double padding) {
    return Padding(padding: EdgeInsets.only(top: padding), child: this);
  }

  Widget paddingBottom(double padding) {
    return Padding(padding: EdgeInsets.only(bottom: padding), child: this);
  }

  Widget paddingVertical(double padding) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: padding), child: this);
  }

  Widget paddingHorizontal(double padding) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: padding), child: this);
  }

  Widget rounded(double radius) {
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: this);
  }

  Widget toCenter() {
    return Center(child: this);
  }

  Widget toAlign(AlignmentGeometry alignment) {
    return Align(alignment: alignment, child: this);
  }

  Widget sliverPadding(EdgeInsetsGeometry padding) {
    return SliverPadding(padding: padding, sliver: this);
  }

  Widget sliverPaddingAll(double padding) {
    return SliverPadding(padding: EdgeInsets.all(padding), sliver: this);
  }

  Widget sliverPaddingVertical(double padding) {
    return SliverPadding(
        padding: EdgeInsets.symmetric(vertical: padding), sliver: this);
  }

  Widget sliverPaddingHorizontal(double padding) {
    return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: padding), sliver: this);
  }

  Widget fixWidth(double width) {
    return SizedBox(width: width, child: this);
  }

  Widget fixHeight(double height) {
    return SizedBox(height: height, child: this);
  }

  Widget bgColor(Color color) {
    return Container(color: color, child: this);
  }

  PreferredSizeWidget preferredSize(double height) {
    return PreferredSize(preferredSize: Size.fromHeight(height), child: this);
  }
}

extension ColorExtension on Color {
  Color darken([int percent = 10]) {
    return Color.lerp(this, Colors.black, percent / 100) ?? this;
  }

  Color lighten([int percent = 10]) {
    return Color.lerp(this, Colors.white, percent / 100) ?? this;
  }

  // lighten if dark by default
  Color applyDarkMode({bool reverse = false, int percent = 20}) {
    if (reverse) {
      return Get.isDarkMode ? darken(percent) : lighten(percent);
    }
    return Get.isDarkMode ? lighten(percent) : darken(percent);
  }
}

final homeKey = GlobalKey<ScaffoldState>();

void openDrawer() {
  homeKey.currentState!.openDrawer();
}

void closeDrawer() {
  homeKey.currentState!.closeDrawer();
}

Future<T?> alertDialog<T>(
    BuildContext context, String title, String? content, Widget? contentWidget,
    [List<Widget>? actions]) {
  return showMoonModal<T>(
      context: context,
      builder: (context) {
        return Dialog(
            child: ListView(
          shrinkWrap: true,
          children: [
            MoonAlert(
                borderColor: Get
                    .context?.moonTheme?.buttonTheme.colors.borderColor
                    .withValues(alpha: 0.5),
                showBorder: true,
                label: Text(title).header(),
                verticalGap: 16,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (content != null && content.isNotEmpty)
                      Text(content).paddingBottom(16),
                    if (contentWidget != null) contentWidget.paddingBottom(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions
                              ?.map((action) => action.paddingRight(8))
                              .toList() ??
                          [],
                    ),
                  ],
                )),
          ],
        ));
      });
}

Widget moonAlertDialog(
    {required BuildContext context,
    required String title,
    String? content,
    Widget? contentWidget,
    List<Widget>? actions,
    EdgeInsetsGeometry? padding,
    Function()? titleAction,
    bool columnActions = false,
    bool scrollable = true}) {
  double left = padding?.horizontal ?? 0;
  left = (20 - left / 2) < 0 ? 0 : left;
  return Dialog(
    child: scrollable
        ? ListView(
            shrinkWrap: true,
            children: [
              MoonAlert(
                  borderColor: Get
                      .context?.moonTheme?.buttonTheme.colors.borderColor
                      .withValues(alpha: 0.5),
                  showBorder: true,
                  padding: padding ?? EdgeInsets.all(20),
                  label: title.isNotEmpty
                      ? GestureDetector(
                          onTap: titleAction,
                          child: Text(title).header().paddingLeft(left),
                        )
                      : Container(),
                  verticalGap: title.isNotEmpty ? 16 : 0,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (content != null && content.isNotEmpty)
                        Text(content).paddingBottom(16),
                      if (contentWidget != null) contentWidget,
                      if (columnActions && actions != null)
                        ...actions.map((action) => action.paddingBottom(4)),
                      if (!columnActions)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: actions
                                  ?.map((action) => action.paddingRight(8))
                                  .toList() ??
                              [],
                        ),
                    ],
                  )),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MoonAlert(
                  borderColor: Get
                      .context?.moonTheme?.buttonTheme.colors.borderColor
                      .withValues(alpha: 0.5),
                  showBorder: true,
                  padding: padding ?? EdgeInsets.all(20),
                  label: GestureDetector(
                    onTap: titleAction,
                    child: Text(title).header().paddingLeft(left),
                  ),
                  verticalGap: 16,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (content != null && content.isNotEmpty)
                        Text(content).paddingBottom(16),
                      if (contentWidget != null) contentWidget,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions
                                ?.map((action) => action.paddingRight(8))
                                .toList() ??
                            [],
                      ),
                    ],
                  ))
            ],
          ),
  );
}

Widget moonWidgetDialog(
    {required BuildContext context,
    required Widget title,
    Widget? content,
    List<Widget>? actions,
    EdgeInsetsGeometry? padding}) {
  return Dialog(
      child: ListView(
    shrinkWrap: true,
    children: [
      MoonAlert(
          borderColor: Get.context?.moonTheme?.buttonTheme.colors.borderColor
              .withValues(alpha: 0.5),
          showBorder: true,
          padding: padding ?? EdgeInsets.all(20),
          label: title,
          verticalGap: 4,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (content != null) content.paddingBottom(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children:
                    actions?.map((action) => action.paddingRight(8)).toList() ??
                        [],
              ),
            ],
          )),
    ],
  ));
}

Widget moonCard(
    {String? title,
    required Widget content,
    List<Widget>? actions,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor}) {
  return MoonAlert(
      backgroundColor: backgroundColor ??
          (Get.context?.moonTheme?.tokens.colors.gohan ?? Colors.white),
      padding: padding,
      showBorder: false,
      label: title == null ? Container() : Text(title).header(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          content,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children:
                actions?.map((action) => action.paddingRight(8)).toList() ?? [],
          ),
        ],
      ));
}

Widget outlinedButton(
    {String? label,
    Widget? labelWidget,
    VoidCallback? onPressed,
    MoonButtonSize? buttonSize,
    bool isFullWidth = false}) {
  return MoonOutlinedButton(
      isFullWidth: isFullWidth,
      buttonSize: buttonSize ?? MoonButtonSize.sm,
      onTap: onPressed,
      label: label == null ? labelWidget : Text(label),
      borderColor: Get.context?.moonTheme?.buttonTheme.colors.borderColor
          .withValues(alpha: 0.5));
}

Widget textButton(
    {String? label,
    Widget? labelWidget,
    VoidCallback? onPressed,
    MoonButtonSize? buttonSize,
    bool isFullWidth = false}) {
  return MoonTextButton(
    isFullWidth: isFullWidth,
    buttonSize: buttonSize ?? MoonButtonSize.sm,
    onTap: onPressed,
    label: label == null ? labelWidget : Text(label).small(),
  );
}

Widget filledButton(
    {String? label,
    VoidCallback? onPressed,
    MoonButtonSize? buttonSize,
    Widget? leading,
    Color? textColor,
    Color? color,
    double? width,
    double? height,
    bool isFullWidth = false,
    bool applyDarkMode = false}) {
  return MoonFilledButton(
    isFullWidth: isFullWidth,
    buttonSize: buttonSize ?? MoonButtonSize.sm,
    onTap: onPressed,
    width: width,
    height: height,
    label: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) leading.paddingRight(6),
        if (label != null)
          Text(label,
              style: TextStyle(
                  color: textColor ??
                      (applyDarkMode
                          ? (Get.isDarkMode ? Colors.white : Colors.black)
                          : null)))
      ],
    ),
    backgroundColor: color,
  );
}

Widget moonListTile(
    {required String title,
    String? subtitle,
    Widget? subtitleWidget,
    bool? centerTitle,
    Color? titleColor,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool? enabled,
    EdgeInsetsGeometry? menuItemPadding,
    bool smallerTitle = false,
    Widget? leading,
    Widget? trailing}) {
  return InkWell(
      onTap: enabled == false ? null : onTap ?? () {},
      onLongPress: onLongPress,
      child: MoonMenuItem(
        menuItemPadding: menuItemPadding,
        backgroundColor:
            Get.isDarkMode ? MoonColors.dark.gohan : MoonColors.light.gohan,
        onTap: enabled == false ? null : onTap ?? () {},
        onLongPress: onLongPress,
        labelAndContentCrossAxisAlignment: centerTitle == true
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        label: smallerTitle
            ? Text(
                title,
                style: TextStyle(color: titleColor),
              ).subHeader()
            : Text(
                title,
                style: TextStyle(color: titleColor),
              ).header(),
        content: subtitle == null ? subtitleWidget : Text(subtitle).subHeader(),
        leading: leading,
        trailing: trailing,
      ).paddingSymmetric(vertical: 2, horizontal: 8));
}

Widget moonListTileWidgets(
    {required Widget label,
    Widget? content,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    VoidCallback? onSecondaryTap,
    VoidCallback? onLongPress,
    EdgeInsetsGeometry? menuItemPadding,
    CrossAxisAlignment? menuItemCrossAxisAlignment,
    BorderRadiusGeometry? borderRadius,
    bool noPadding = false}) {
  return InkWell(
      onTap: onTap ?? () {},
      onSecondaryTap: onSecondaryTap,
      onLongPress: onLongPress,
      child: MoonMenuItem(
        backgroundColor:
            Get.isDarkMode ? MoonColors.dark.gohan : MoonColors.light.gohan,
        menuItemPadding: menuItemPadding,
        menuItemCrossAxisAlignment: menuItemCrossAxisAlignment,
        borderRadius: borderRadius,
        onTap: onTap ?? () {},
        onLongPress: onLongPress,
        label: label,
        content: content,
        leading: leading,
        trailing: trailing,
      ).paddingSymmetric(
          vertical: noPadding ? 0 : 2, horizontal: noPadding ? 0 : 8));
}

Widget emptyPlaceholder(BuildContext context) {
  return Container(
    padding: const EdgeInsets.only(bottom: 100),
    width: double.infinity,
    height: context.height / 1.5,
    alignment: Alignment.center,
    child: Center(
      child: Text('[ ]').h1(),
    ),
  );
}

AppBar appBar(
        {String? title,
        Widget? titleWidget,
        String? subtitle,
        Widget? leading = const NormalBackButton(),
        bool forceMaterialTransparency = false,
        bool centerTitle = false,
        PreferredSizeWidget? bottom,
        bool alwaysDark = false,
        List<Widget>? actions}) =>
    AppBar(
      backgroundColor: alwaysDark ? Colors.black : null,
      leadingWidth: 40,
      centerTitle: centerTitle,
      title: MoonMenuItem(
          onTap: () {},
          label: titleWidget ??
              Text(
                title ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: alwaysDark ? Colors.white : null),
              ).appSubHeader().paddingRight(8),
          verticalGap: 0,
          content: subtitle == null
              ? null
              : Text(subtitle,
                      style: TextStyle(
                          color: Get.context?.moonTheme?.textAreaTheme.colors
                              .helperTextColor))
                  .subHeader()),
      leading: leading,
      actions: actions,
      shape: Border(
          bottom: BorderSide(
        color: Get.isDarkMode || alwaysDark
            ? Colors.white.withValues(alpha: 0.5)
            : Colors.black.withValues(alpha: 0.5),
        width: 0.2,
      )),
      forceMaterialTransparency: forceMaterialTransparency,
      bottom: bottom,
    );

extension TextExtension on Text {
  Color get _textColor =>
      style?.color ?? (Get.isDarkMode ? Colors.white : Colors.black);

  StrutStyle get _strutStyle =>
      strutStyle ?? StrutStyle(forceStrutHeight: true, leading: 0);

  Text appHeader() => Text(
        data ?? '',
        maxLines: maxLines,
        overflow: overflow,
        strutStyle: _strutStyle,
        style: Get.context?.moonTheme?.tokens.typography.heading.text18
            .copyWith(color: _textColor),
      );

  Text appSubHeader() => Text(
        data ?? '',
        maxLines: maxLines,
        overflow: overflow,
        strutStyle: _strutStyle,
        style: Get.context?.moonTheme?.tokens.typography.heading.text16
            .copyWith(color: _textColor),
      );

  Text header() => Text(
        data ?? '',
        maxLines: maxLines,
        overflow: overflow,
        strutStyle: _strutStyle,
        style: Get.context?.moonTheme?.tokens.typography.heading.text16
            .copyWith(color: _textColor),
      );

  Text subHeader() => Text(
        data ?? '',
        maxLines: maxLines,
        overflow: overflow,
        strutStyle: _strutStyle,
        style: Get.context?.moonTheme?.tokens.typography.heading.text14
            .copyWith(color: _textColor),
      );

  Text small({bool noColor = false}) {
    return Text(
      data ?? '',
      maxLines: maxLines,
      overflow: overflow,
      strutStyle: _strutStyle,
      style: Get.context?.moonTheme?.tokens.typography.heading.text12.copyWith(
          color: noColor ? null : _textColor, decoration: style?.decoration),
    );
  }

  Text underlineSmall() => Text(
        data ?? '',
        maxLines: maxLines,
        overflow: overflow,
        strutStyle: _strutStyle,
        style: Get.context?.moonTheme?.tokens.typography.heading.text12
            .copyWith(color: _textColor, decoration: TextDecoration.underline),
      );

  Text subHeaderForgound() => Text(
        data ?? '',
        maxLines: maxLines,
        overflow: overflow,
        strutStyle: _strutStyle,
        style:
            Get.context?.moonTheme?.tokens.typography.heading.text14.copyWith(
          foreground: style?.foreground ??
              Get.context?.moonTheme?.tokens.typography.heading.text14
                  .foreground,
        ),
      );

  Text xSmall() => Text(
        data ?? '',
        maxLines: maxLines,
        overflow: overflow,
        strutStyle: _strutStyle,
        style: Get.context?.moonTheme?.tokens.typography.heading.text10
            .copyWith(color: _textColor),
      );

  Text h1() => Text(
        data ?? '',
        maxLines: maxLines,
        overflow: overflow,
        strutStyle: _strutStyle,
        style: Get.context?.moonTheme?.tokens.typography.heading.text40
            .copyWith(color: _textColor),
      );

  Text h2() => Text(
        data ?? '',
        maxLines: maxLines,
        overflow: overflow,
        strutStyle: _strutStyle,
        style: Get.context?.moonTheme?.tokens.typography.heading.text32
            .copyWith(color: _textColor),
      );

  Text of(MoonButtonSize? size) => size == MoonButtonSize.xs
      ? xSmall()
      : size == MoonButtonSize.lg
          ? subHeader()
          : small();
}

extension TextSpanExtension on TextSpan {
  TextSpan small() => TextSpan(
        style: Get.context?.moonTheme?.tokens.typography.heading.text12
            .copyWith(
                color: style?.color ??
                    (Get.isDarkMode ? Colors.white : Colors.black),
                fontWeight: style?.fontWeight,
                fontStyle: style?.fontStyle),
        text: text,
        children: children,
        recognizer: recognizer,
        mouseCursor: mouseCursor,
        locale: locale,
        spellOut: spellOut,
        onEnter: onEnter,
        onExit: onExit,
      );
}

const double _kActivityIndicatorRadius = 40.0;
const double _kActivityIndicatorMargin = 10.0;

Widget buildRefreshIndicator(
  BuildContext context,
  RefreshIndicatorMode refreshState,
  double pulledExtent,
  double refreshTriggerPullDistance,
  double refreshIndicatorExtent,
) {
  final double percentageComplete = clampDouble(
    pulledExtent / refreshTriggerPullDistance,
    0.0,
    1.0,
  );

  // Place the indicator at the top of the sliver that opens up. We're using a
  // Stack/Positioned widget because the CupertinoActivityIndicator does some
  // internal translations based on the current size (which grows as the user drags)
  // that makes Padding calculations difficult. Rather than be reliant on the
  // internal implementation of the activity indicator, the Positioned widget allows
  // us to be explicit where the widget gets placed. The indicator should appear
  // over the top of the dragged widget, hence the use of Clip.none.
  return Center(
    child: Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          top: _kActivityIndicatorMargin,
          left: 0.0,
          right: 0.0,
          child: _buildIndicatorForRefreshState(
            refreshState,
            _kActivityIndicatorRadius,
            percentageComplete,
          ),
        ),
      ],
    ),
  );
}

Widget _buildIndicatorForRefreshState(
  RefreshIndicatorMode refreshState,
  double radius,
  double percentageComplete,
) {
  switch (refreshState) {
    case RefreshIndicatorMode.drag:
      // While we're dragging, we draw individual ticks of the spinner while simultaneously
      // easing the opacity in. The opacity curve values here were derived using
      // Xcode through inspecting a native app running on iOS 13.5.
      const Curve opacityCurve = Interval(0.0, 0.35, curve: Curves.easeInOut);
      return Opacity(
        opacity: opacityCurve.transform(percentageComplete),
        child: progressIndicator(
          Get.context!,
          size: radius,
          duration: const Duration(milliseconds: 500),
        ),
      );
    case RefreshIndicatorMode.armed:
    case RefreshIndicatorMode.refresh:
      // Once we're armed or performing the refresh, we just show the normal spinner.
      return progressIndicator(
        Get.context!,
        size: radius,
      );
    case RefreshIndicatorMode.done:
      // When the user lets go, the standard transition is to shrink the spinner.
      return progressIndicator(
        Get.context!,
        size: radius * percentageComplete,
      );
    case RefreshIndicatorMode.inactive:
      // Anything else doesn't show anything.
      return const SizedBox.shrink();
  }
}

Widget popupMenuButton<T>({
  required PopupMenuItemBuilder<T> itemBuilder,
  PopupMenuItemSelected<T>? onSelected,
  Widget? child,
  dynamic initialValue,
  String? tooltip,
  BoxConstraints? constraints,
}) =>
    PopupMenuButton<T>(
      constraints: constraints,
      shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Get.isDarkMode
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.2),
            width: 0.5,
          ),
          borderRadius: BorderRadius.all(Radius.circular(12))),
      color: Get.context?.moonTheme?.dropdownTheme.colors.backgroundColor,
      itemBuilder: itemBuilder,
      onSelected: onSelected,
      initialValue: initialValue,
      tooltip: tooltip,
      child: child ??
          IgnorePointer(
            child: MoonEhButton(
                buttonSize: MoonButtonSize.md,
                onTap: () {},
                icon: BootstrapIcons.three_dots),
          ),
    );

Widget dropdownButton<T>(
        {double minWidth = 100,
        double maxWidth = 100,
        double minHeight = 100,
        double maxHeight = 200,
        required bool show,
        VoidCallback? onTapOutside,
        required List<MoonMenuItem> content,
        required Widget child}) =>
    MoonDropdown(
      minWidth: minWidth,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      minHeight: minHeight,
      offset: Offset(0, 0),
      borderColor: Get.isDarkMode
          ? Colors.white.withValues(alpha: 0.2)
          : Colors.black.withValues(alpha: 0.2),
      borderWidth: 0.2,
      show: show,
      onTapOutside: onTapOutside,
      content: ListView(
          padding: EdgeInsets.zero, shrinkWrap: true, children: content),
      child: child,
    );

Icon moonIcon({required IconData icon, double size = 20, Color? color}) =>
    Icon(icon,
        size: size,
        color: color ?? Get.context?.moonTheme?.tokens.colors.bulma);
