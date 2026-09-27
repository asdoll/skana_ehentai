# OHOS (HarmonyOS) 适配说明

记录 skana_ehentai 适配 OHOS 时改了什么、为什么，以及在新机器上怎么复现。
同一套做法参见 [skana_pica/docs/ohos-setup.md](../../skana_pica/docs/ohos-setup.md)
与 [skana_pix](../../skana_pix)（PiliPlusX 只作参考）。

## 前置条件

- **Flutter SDK 必须是 OHOS 分支**（`flutter_flutter`），不是官方 Flutter：
  `flutter --version` 应显示 `3.41.10-ohos-1.0.1` 之类。`ohos/local.properties`
  已经指向 `/Applications/DevEco-Studio.app/Contents/sdk` 与
  `flutter.sdk=/Users/fla/repos/flutter_flutter`。
- DevEco Studio（提供 hvigorw / ohpm / SDK）。

## 这一步必须手动做一次：调试签名

`flutter build hap` 在 `app.signingConfigs` 为空时会直接失败（flutter_tools 的
`checkOhosSignedInfo()` 要求签名配置非空），提示：

> 请通过 DevEco Studio 打开 ohos 工程后配置调试签名(File -> Project Structure ->
> Signing Configs 勾选 Automatically generate signature)

用 DevEco 打开一次本目录下的 `ohos/`，勾选自动生成签名即可，产物会写到
`~/.ohos/config/`。**签名与 bundleName 绑定**，所以不能借用别的项目的 `.p7b`。
签名材料在 `ohos/build-profile.json5` 里，该文件已加入版本库（与 skana_pix 不同），
换机器时要么重新生成、要么把它排除掉。

## 编译期阻塞项（改完才能出包）

| 包 | 处理 | 原因 |
| --- | --- | --- |
| `moon_design` | 换成 git `asdoll/moon_flutter` 固定 revision | 1.1.0 对 `TargetPlatform` 穷举 `switch` 且没有 `ohos` 分支，OHOS 目标下编译报错 |
| `google_fonts` | `^6.2.1` → `^8.2.1` | 6.2.1 用 `FontWeight` 作 `const` map 的 key，常量求值拒绝（`does not have a primitive operator '=='`）；8.x 是 `final` |
| `flex_color_picker` | **vendor 到 `third_party/flex_color_picker`** 并补 `TargetPlatform.ohos` | 上游 3.7.1 与 master(4.0.0) 都漏了 `ohos`，没有可用 fork，只能本地改 |
| `context_menu_region.dart` | 补 `TargetPlatform.ohos` case | 项目自己的文件，同一类问题 |
| `third_party/**` | 加进 `analysis_options.yaml` 的 `analyzer.exclude` | 避免把 vendored 包的 lint 算进本项目 |

`flex_color_picker` 走的是 path 依赖（不是 override），因为它同时是 app 的直接依赖，
版本号 3.7.1 仍满足 `^3.7.0`。

## 插件：为什么只能写在 dependency_overrides 里

像 `drift`、`get_storage`、`share_plus` 这类包会**按名字**依赖 pub.dev 上的
`path_provider`，而 pub 不允许同一个包名同时来自两个源，所以「换实现」只能写在
`dependency_overrides`。

下面全部是**整包 fork**（fork 里在 android/、ios/ 旁边多一个 ohos/ 目录），不是
pub.dev 上的 `xxx_ohos` 包 —— 后者是独立原生实现，自带 `XxxOhos` 类，并没有接进父包的
federated 机制，父包的 Dart 调用照样会 `MissingPluginException`。

| 包 | 来源 | ref |
| --- | --- | --- |
| `url_launcher` | openharmony-tpc/flutter_packages | `url_launcher_v6.3.2-ohos-1.0.2` |
| `path_provider` | 同上 | `provider-v2.1.5-ohos-1.0.1` |
| `webview_flutter` | 同上 | `webview_flutter-v4.13.1-ohos-1.0.2` |
| `share_plus` | openharmony-sig/flutter_plus_plugins | `br_share_plus-v12.0.1_ohos` |
| `package_info_plus` | 同上 | `br_package_info_plus_v8.3.0_ohos` |
| `device_info_plus` | 同上 | `br_device_info_plus_v11.4.0_ohos` |
| `battery_plus` | 同上 | `br_battery_plus-v6.1.0_ohos` |
| `sqlite3_flutter_libs` | SageMik/sqlite3-ohos.dart | `sqlite3_flutter_libs-0.5.25-ohos` |
| `image_gallery_saver_plus` | CPF-Flutter | `br_3.41_dev` |
| `screen_brightness_ohos` | pub.dev（`screen_brightness` 自带的 endorsed 实现） | — |
| `file_picker_ohos` | 见下，vendor 到 `third_party/file_picker_ohos` | `br_v10.3.8_ohos` |

注意 `device_info_plus` 那个分支名虽然是 `v11.4.0`，解出来的版本其实是 **9.1.0**；
本项目只在 `permission_util.dart` 里、且只在 `Platform.isAndroid` 分支用它的
`androidInfo`，所以无影响。`battery_plus` 同理从 6.2.1 降到 6.1.0。

### `sqlite3` 不能一起换

drift 2.26 需要 `sqlite3: ^2.6.0`（`Converters.jsonb` 会调 `sqlite3.jsonb`），而
SageMik 那个 `sqlite3-2.4.7-ohos` 是 2.4.7。`dependency_overrides` **会连版本约束一起
绕过**，所以写上去 pub 照样成功，直到 kernel 编译才炸：

```
drift-2.26.1/lib/src/runtime/types/converters.dart:154:26: Error: Undefined name 'jsonb'.
  jsonForDb: sqlite3.jsonb,
```

所以只换 `sqlite3_flutter_libs`（它只负责把 `libsqlite3.so` 带进包里，不约束
`sqlite3` 版本），`sqlite3` 用 pub.dev 的版本；OHOS 上的**加载路径**改在运行时做：

```dart
// lib/src/database/database.dart, _openConnection()
if (Platform.isOhos) {
  open.overrideForAll(() => DynamicLibrary.open('libsqlite3.so'));
}
```

`package:sqlite3` 的 `_defaultOpen()` 只认 Android/Linux/iOS/macOS/Windows，OHOS 会落到
`throw UnsupportedError`；`overrideForAll` 走的是另一条路，不需要 `OperatingSystem.ohos`
枚举成员（上游没有）。这段必须放在 `sqlite3.tempDirectory = ...` **之前**，因为
`sqlite3` 这个 getter 本身就会去解析动态库。

`sqlite3_flutter_libs` 的 OHOS 实现依赖一个 bytecode HAR（`sqlite3-native-library`），
hvigor 对 bytecode HAR 有要求，所以 `ohos/build-profile.json5` 必须开：

```json5
"buildOption": { "strictMode": { "useNormalizedOHMUrl": true } }
```

否则报 00306046。

## OHOS 上跑不了 / 降级的功能

| 功能 | 涉及的包 | 处理 |
| --- | --- | --- |
| 生物识别解锁 | `local_auth` | **不覆盖**。它的每个 OHOS 分支都拉一个 `local_auth_ohos`，而后者把 `intl` 钉在 `>=0.17.0 <0.19.0`（3.0.1 分支更窄），和本项目的 `intl ^0.20.2` 冲突；`intl` 又被 `flutter_localizations` 钉住，降不了。OHOS 上 `securitySetting.supportBiometricAuth` 保持 false，设置项直接不显示，`lock_page.biometricAuth()` 只留一个 `isOhos` 兜底 |
| 屏幕常亮 | `wakelock_plus` | `read_page_logic.dart` 里 `!isOhos` 才调用（没有 OHOS 实现） |
| 导出的相册保存 | `saver_gallery` | 无 OHOS 实现，改走 `image_gallery_saver_plus`，见 `lib/src/utils/gallery_util.dart` |
| 存储/相册权限 | `permission_handler` | OHOS 上直接跳过（权限模型不同，存图走 `photoAccessHelper` 自己的确认弹窗） |
| 选文件/选目录 | `file_picker` | 接上了，见下 |
| 分享进 App / 安卓专有项 | `receive_sharing_intent`、`android_intent_plus`、`flutter_windowmanager_plus`、`flutter_displaymode`、`window_manager`、`desktop_webview_window`、`http_proxy`、`system_network_proxy` | 调用点原本就被 `GetPlatform.isAndroid/isMobile/isDesktop` 挡住，OHOS 上都不会走到 |

### `file_picker` 怎么接上的

`openharmony-sig/fluttertpc_file_picker` 的 `br_3.41_dev` 分支已经是 Dart workspace
结构（根 `pubspec.yaml` 是 `flutter_file_picker_workspace`，子包写着
`resolution: workspace`，版本 12.2.0），没法当普通 path 依赖用。所以用的是老的
`br_v10.3.8_ohos` 分支，但**只取它的 `ohos/` 原生部分**，vendor 成
`third_party/file_picker_ohos`，pubspec 里只声明 ohos 一个平台。

为什么不整包替换 `file_picker`：那个分支的 Dart 包名就叫 `file_picker_ohos`，改名叫
`file_picker` 需要连 har 名一起改（ohpm 会因为插件名与 har 名不一致报 00604006），而且它
自己多了一个 `image_picker` 依赖（会渗到 Android/iOS），Dart 侧还会从 10.1.4 跳到
10.3.8。丢到 `third_party/` 单独一个包，这些问题都没有。

它没有任何 Dart 代码，全靠 method channel 通信，所以 Dart 侧还是官方 `file_picker`；
**但必须手动把实现接上**。`FilePicker.platform` 是个 `late` 字段，只有生成的插件
注册表会赋值，OHOS 没有注册实现，一读就抛 `LateInitializationError` —— 而它是
`Error` 不是 `Exception`，连调用点的 `on Exception` 都拦不住，这就是「导入导出点了没
反应」的直接原因。`lib/main.dart` 里补上：

```dart
if (isOhos) {
  FilePicker.platform = FilePickerIO();
}
```

`FilePickerIO` 和 OHOS 原生插件用的是同一个 channel
（`miguelruivo.flutter.plugins.filepicker`），方法名也一致（`pickFiles` / `dir` /
`save` / `clear`）。

顺带一个细节：OHOS 的 `documentViewPicker` 返回的是 `file://docs/...` URI，`dart:io`
读不了。插件的 `FileUtils.openFileStream` 会把选中的文件**复制到
`<cacheDir>/file_picker/`** 再把真实沙箱路径回给 Dart，所以导入时
`File(path).readAsString()` 是能用的。

### 导入 / 导出数据

- **导入**：直接用 `pickFiles(type: FileType.custom, allowedExtensions: ['json'])`，靠
  上面的 cache 复制机制拿到可读路径。
- **导出**：**不能用** `FilePicker.platform.saveFile`。OHOS 那份实现是「把刚选中的文件
  另存到别处」，要求前一次 pick 先把 `bytesList` 填好，Dart 直接传 `bytes` 是收不到的
  （会报 `Bytes are required on HarmonyOS & Android & IOS when saving a file`）。
  所以 `setting_advanced_page.dart` 在 OHOS 上走 `_exportDataOhos()`：把 JSON 写进
  `pathService.tempDir`，再用 `Share.shareXFiles` 拉起系统分享面板，由用户决定存到哪里。

### 选目录：两层修复

**原生侧（`third_party/file_picker_ohos` 内的补丁）**：上游 `case "dir"` 把一个目录 URI
丢进只处理文件的 `openFileStream`（会把文件内容拷进缓存），既会失败，回给 Dart 的又是
`List<Map>` —— 而 `getDirectoryPath()` 读的是 `String`，类型不符直接抛
`PlatformException`。现在改成直接把路径回给 Dart：

```ts
this.saveFinishWithSuccess(FileUtils.uriToPath(documentSelectResult[0]));
```

`FileUtils.uriToPath()` 是本项目新加的，用 `fileUri.FileUri(uri).path` 把
`file://docs/...` 转成路径。

**应用侧**：即便转成了路径也仍然不能用 —— OHOS 选目录授权的是 **URI** 而不是它背后的
路径，而应用所有调用点都是拿这个目录去 `dart:io` 下载、扫描、写配置文件；何况 OHOS 应用
本来就只能写自己的沙箱。所以新增 `lib/src/utils/directory_util.dart`：

```dart
Future<String?> pickUsableDirectoryPath() async { ... }
```

- 拿到普通路径（不以 `file://` 开头）→ 原样返回，正常走；
- 在 OHOS 上拿到 `file://` URI → 丢弃，改为返回应用自己的目录，并 toast 一条
  `ohosAppDirectoryOnly`（新增的翻译，6 种语言都补了）说明原因。

原来 5 处调用点（下载目录、单图保存目录、额外扫描目录、超分模型目录、配置同步下载目录）
全部改走这个函数。行为上：**不会再「点了没反应」**，而是明确告诉用户「鸿蒙只能用应用目录」
并给出实际路径。

## 其它改动

- **沉浸模式的两处坑**（`read_page_logic.dart` / `read_page.dart`）：
  1. `restoreImmersiveMode()` 原本守卫在 `GetPlatform.isMobile` 上（只含 Android/iOS），
     OHOS 上是 false，所以第一次进过阅读页之后整个 App 一直停在全屏。
     改成 `isMobileOrOhos`。
     OHOS 引擎确实认 `SystemUiMode.edgeToEdge`
     （`setWindowSystemBarEnable(['status','navigation'])`，见
     `engine/.../ohos/.../plugin/PlatformPlugin.ets`）；注意 `SystemUiMode.manual`
     在那个 switch 里落到 `else { return; }`，**在 OHOS 上完全不生效**，不能用它来恢复。
  2. 恢复的**时机**也很重要：放在 `onClose()` 里是在退场动画结束之后，
     而引擎在隐藏状态栏时把 `MediaQuery.padding.top` 报成 0、恢复时又变成状态栏高度，
     于是下面那一页（详情页）已经显示出来之后才重新布局，看起来就是「状态栏跳出来、
     整个页面动一下」。现在改到 `read_page.dart` 的 `PopScope.onPopInvokedWithResult`
     里（`didPop == true` 时调用），它发生在 pop 处理阶段、本路由开始做退场动画之前，
     所以被露出来的页面在可见之前就已经按正确 inset 排好版了。
     `canPop` 保持默认 true，不会拦截任何 pop；Android 上系统返回本来就被
     全局 `WillPopInterceptor` 拦下，这里只会拿到 `didPop == false`。
     `onClose()` 里那次保留作为兜底（`Get.offAll` 之类的替换路径不触发 pop）。
- 阅读页的亮度设置：`applyCurrentBrightness()` / `resetBrightness()` 同样是
  `GetPlatform.isMobile`，`screen_brightness` 有可用的 OHOS 实现，已一起放开。
- 阅读页的「屏幕方向」设置（`updateDeviceOrientation` / `restoreDeviceOrientation`）
  仍是 `GetPlatform.isMobile` 守卫，**在 OHOS 上不生效**，需要时再放开。
- `ohos/AppScope/app.json5`：`bundleName` = `com.skanaone.skana_ehentai`。
- 应用名统一成 `SkanaEH`（和 `AndroidManifest.xml` 的 `android:label`、关于页一致）：
  `ohos/AppScope/resources/base/element/string.json` 的 `app_name`，
  以及 `ohos/entry/src/main/resources/{base,en_US,zh_CN}/element/string.json` 的
  `EntryAbility_label`。
- 新增 `lib/src/utils/platform_util.dart`：`GetPlatform` 没有 OHOS 判定（它的
  `isMobile` 只含 Android/iOS），所以用 `Platform.isOhos`，并暴露 `isMobileOrOhos`。
  注意 `Platform.isOhos` 只有 OHOS 分支的 Flutter 才有。

## 构建

```bash
flutter pub get          # 首次会 clone gitcode 上的 fork，比较慢
flutter build hap --debug
# ✓ Built build/ohos/hap/entry-default-signed.hap.
```

`flutter build hap` 会自己跑 `pub get`，所以只跑第二条也行。
