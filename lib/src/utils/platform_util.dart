import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get_utils/src/platform/platform.dart';

/// HarmonyOS predicate.
///
/// `GetPlatform` has no OHOS case - its `isMobile` is Android/iOS only and
/// `isDesktop` is the desktop trio - so OHOS has to be tested through `dart:io`.
/// `Platform.isOhos` is provided by the OHOS Flutter fork this project builds
/// with on every platform; stock Flutter does not define it.
bool get isOhos => Platform.isOhos;

/// The platforms whose touch-oriented code paths also apply to OHOS.
///
/// Used where this app branches on `GetPlatform.isMobile` for something that
/// works on OHOS too (screen brightness, for instance).
bool get isMobileOrOhos => GetPlatform.isMobile || isOhos;

/// Shows the status bar and keeps the system navigation (gesture) bar hidden.
///
/// `SystemUiMode` cannot express "top only": every one of its values is
/// all-or-nothing (`edgeToEdge` shows both, `immersive`/`immersiveSticky`/
/// `leanBack` hide both) and the OHOS engine returns early for
/// `SystemUiMode.manual` (PlatformPlugin.ets#setSystemChromeEnabledSystemUIMode).
/// The overlay list is a separate code path though: `setEnabledSystemUIMode`
/// sends `SystemChrome.setEnabledSystemUIOverlays` instead of the mode when it is
/// called with `SystemUiMode.manual`, and the OHOS engine implements that one as
/// `mainWindow.setWindowSystemBarEnable(['status'])` - status bar in, navigation
/// bar out.
///
/// No-op off OHOS, so Android/iOS keep the bars they always had.
void showStatusBarOnly() {
  if (!isOhos) {
    return;
  }

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: const [SystemUiOverlay.top],
  );
}
