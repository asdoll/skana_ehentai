
# SkanaEh

## Description

A moded UI for Jhentai.

## References & Thanks

Layout and style references:

- [Jhentai](https://github.com/jiangtian616/JHenTai)

- [FEhviewer](https://github.com/honjow/FEhViewer) : Mainly
- [EHPanda](https://github.com/tatsuz0u/EhPanda)
- [EHViewer](https://gitlab.com/NekoInverter/EhViewer)

Tag translation:

- [EhTagTranslation](https://github.com/EhTagTranslation/Database)

Tag order optimization:

- [e-hentai-db](https://github.com/ccloli/e-hentai-db)
- [e-hentai-tag-count](https://github.com/mokurin000/e-hentai-tag-count)
- [EhSyringe](https://github.com/EhTagTranslation/EhSyringe)

App translation：

- [andyching168](https://github.com/andyching168) [kenny03211](https://github.com/kenny03211) [NeKoOuO](https://github.com/NeKoOuO) 繁體中文(台灣)
- [lucas-04](https://github.com/lucas-04) Português brasileiro
- [qlife1146](https://github.com/qlife1146) 한국어
- [bropines](https://github.com/bropines) Russian

mush thanks to these projects and people🙇‍

## Screenshots

### Mobile Layout

<img width="250" src="screenshot/mobile_v2.jpg"/>

### Tablet Layout

<img width="770" src="screenshot/tabletV2.png"/>

### Desktop Layout

<img width="770" src="screenshot/desktop1.png"/>

### Gallery & Search

<img width="250" style="margin-right:10px" src="screenshot/mobile_v2.jpg"/><img width="250" style="margin-right:10px" src="screenshot/search.jpg"/> 

### Gallery Detail

<img width="250" src="screenshot/detail.png" style="margin-right:10px" /><img width="250" src="screenshot/archive.jpg" style="margin-right:10px" />

### Setting & Download

<img width="270" src="screenshot/setting_en.jpg" style="margin-right:10px" /><img width="250" src="screenshot/download.jpg" style="margin-right:10px" />

### Read

<img width="250" src="screenshot/read.jpg" /><img src="screenshot/read_double_column.png" /><img src="screenshot/read_continuous_scroll.png" />

## Main Features

-   [x] Mobile, tablet, desktop layout(3 kinds)
-   [x] Vertical, horizontal, double column read page layout(4 kinds)
-   [x] GalleryPage, Popular, Favorite, Watched, History, support multiple gallery list style
-   [x] search, search suggestion, tap tag to search, file search, jump to a certain page
-   [x] online reading and download, support restore download task, support synchronize updates after the uploader has
    uploaded a new version
-   [x] archive download and automatic unpacking and reading
-   [x] support loading local images and read
-   [x] support assign priority to download task manually
-   [x] support assign group to gallery and archive
-   [x] favorite, rating, torrent, archive, statistics, share
-   [x] password login, Cookie login, web login
-   [x] support EX site(domain fronting optional)
-   [x] vote for Tag, watch and hidden tags
-   [x] comment, vote for comment
-   [x] Fingerprint unlock

## Translation

> [languageCode](https://github.com/unicode-org/cldr/blob/master/common/validity/language.xml)
>
> [countryCode](https://github.com/unicode-org/cldr/blob/master/common/validity/region.xml)

1. Copy `/lib/src/l18n/en_US.dart ` and rename to `{your_languageCode}_{your_countryCode}.dart`
2. Rename classname in new file(optional)
3. Modify k-v pairs in method `keys` ,translate values to your language

Now you can submit your PR, I'll do the remaining things. Or you can go on with:

4. Enter `/lib/src/l18n/locale_text.dart ` , add a new k-v pair in method `keys`
   => `{your_languageCode}_{your_countryCode} : {your_className}.keys()`
5. Enter `/lib/src/consts/locale_consts.dart`, add a new k-v pair in
   property `localeCode2Description`: `{your_languageCode}_{your_countryCode} : {languageDescription}` to describe your
   language.

## About compiling

1. You need to manage your Android signing by yourself,
   check https://docs.flutter.dev/deployment/android#signing-the-app
2. Just run this project via IDEA or VSCode simply.

## Main Dart Dependencies

- [get](https://pub.flutter-io.cn/packages/get): dependency management, state management, l18n, NoSQL
- [dio](https://pub.flutter-io.cn/packages?q=dio): network
- [extendedImage](https://pub.flutter-io.cn/packages/extended_image): image
- [drift](https://pub.flutter-io.cn/packages/drift): database
