import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/extension/get_logic_extension.dart';
import 'package:skana_ehentai/src/model/read_page_info.dart';
import 'package:skana_ehentai/src/setting/read_setting.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../config/ui_config.dart';
import '../../../../service/gallery_download_service.dart';
import '../../../../service/super_resolution_service.dart';
import '../../../../service/log.dart';
import '../../../../widget/eh_image.dart';
import '../../../../widget/icon_text_button.dart';
import '../../../../widget/loading_state_indicator.dart';
import '../../read_page_logic.dart';
import '../../read_page_state.dart';
import 'base_layout_logic.dart';

class ScrollOffsetToScrollController extends ScrollController {
  ScrollOffsetToScrollController({required this.scrollOffsetController});

  final ScrollOffsetController scrollOffsetController;

  @override
  ScrollPosition get position => scrollOffsetController.position;

  @override
  Future<void> animateTo(double offset,
      {required Duration duration, required Curve curve}) async {
    await position.animateTo(offset, duration: duration, curve: curve);
  }

  @override
  void jumpTo(double value) {
    scrollOffsetController.jumpTo(value: value);
  }
}

abstract class BaseLayout extends StatelessWidget {
  BaseLayout({super.key});

  final ReadPageLogic readPageLogic = Get.find<ReadPageLogic>();
  final ReadPageState readPageState = Get.find<ReadPageLogic>().state;

  BaseLayoutLogic get logic;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: logic.readPageLogic.delayInitCompleter.future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return GetBuilder<BaseLayoutLogic>(
              id: BaseLayoutLogic.pageId,
              global: false,
              init: logic,
              builder: (_) => ScrollConfiguration(
                behavior: readSetting.showScrollBar.isTrue
                    ? UIConfig.scrollBehaviourWithScrollBarWithMouse
                    : UIConfig.scrollBehaviourWithoutScrollBarWithMouse,
                child: buildBody(context),
              ),
            );
          }

          return Center(
              child: Container(color: UIConfig.readPageBackGroundColor));
        });
  }

  Widget buildBody(BuildContext context);

  /// online mode: parsing and loading automatically while scrolling
  Widget buildItemInOnlineMode(BuildContext context, int index) {
    return GetBuilder<ReadPageLogic>(
      id: '${readPageLogic.onlineImageId}::$index',
      builder: (_) {
        /// step 1: parse image href if needed. check if thumbnail's info exists, if not, [parse] one page of thumbnails to get image hrefs.
        if (readPageState.thumbnails[index] == null) {
          if (readPageState.parseImageHrefsStates[index] == LoadingState.idle) {
            readPageLogic.beginToParseImageHref(index);
          }
          return _buildParsingHrefsIndicator(context, index);
        }

        /// step 2: parse image url.
        if (readPageState.images[index] == null) {
          if (readPageState.parseImageUrlStates[index] == LoadingState.idle) {
            readPageLogic.beginToParseImageUrl(index, false);
          }
          return _buildParsingUrlIndicator(context, index);
        }

        /// step 3: use url to load image
        return _buildOnlineImage(context, index);
      },
    );
  }

  /// wait for [readPageLogic] to parse image href in online mode
  Widget _buildParsingHrefsIndicator(BuildContext context, int index) {
    Size placeHolderSize = logic.getPlaceHolderSize(index);

    return GestureDetector(
      onTap: () => readPageLogic.beginToParseImageHref(index),
      child: SizedBox(
        height: placeHolderSize.height,
        width: placeHolderSize.width,
        child: GetBuilder<ReadPageLogic>(
          id: '${readPageLogic.parseImageHrefsStateId}::$index',
          builder: (_) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingStateIndicator(
                loadingState: readPageState.parseImageHrefsStates[index],
                idleWidgetBuilder: () => UIConfig.loadingAnimation(context),
                errorWidgetBuilder: () => const Icon(Icons.warning,
                    color: UIConfig.readPageWarningButtonColor),
              ),
              Text(
                readPageState.parseImageHrefsStates[index] == LoadingState.error
                    ? readPageState.parseImageHrefErrorMsg!
                    : 'parsingPage'.tr,
              ).marginOnly(top: 8),
              Text((index + 1).toString()).marginOnly(top: 4),
            ],
          ),
        ),
      ),
    );
  }

  /// wait for [readPageLogic] to parse image url in online mode
  Widget _buildParsingUrlIndicator(BuildContext context, int index) {
    Size placeHolderSize = logic.getPlaceHolderSize(index);

    return GestureDetector(
      onTap: () => readPageLogic.beginToParseImageUrl(index, true),
      child: SizedBox(
        height: placeHolderSize.height,
        width: placeHolderSize.width,
        child: GetBuilder<ReadPageLogic>(
          id: '${readPageLogic.parseImageUrlStateId}::$index',
          builder: (_) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingStateIndicator(
                loadingState: readPageState.parseImageUrlStates[index],
                idleWidgetBuilder: () => UIConfig.loadingAnimation(context),
                errorWidgetBuilder: () => const Icon(Icons.warning,
                    color: UIConfig.readPageWarningButtonColor),
              ),
              Text(
                readPageState.parseImageUrlStates[index] == LoadingState.error
                    ? readPageState.parseImageUrlErrorMsg[index]!
                    : 'parsingURL'.tr,
              ).marginOnly(top: 8),
              Text((index + 1).toString()).marginOnly(top: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineImage(BuildContext context, int index) {
    return GestureDetector(
      onLongPress: () => logic.showBottomMenuInOnlineMode(index, context),
      onSecondaryTap: () => logic.showBottomMenuInOnlineMode(index, context),
      child: EHImage(
        galleryImage: readPageState.images[index]!,
        containerWidth: logic.readPageState.imageContainerSizes[index]?.width ??
            logic.getPlaceHolderSize(index).width,
        containerHeight:
            logic.readPageState.imageContainerSizes[index]?.height ??
                logic.getPlaceHolderSize(index).height,
        clearMemoryCacheWhenDispose: true,
        loadingProgressWidgetBuilder: (double progress) =>
            _loadingProgressWidgetBuilder(index, progress),
        failedWidgetBuilder: (ExtendedImageState state) =>
            _failedWidgetBuilder(index, state),
        completedWidgetBuilder: (state) =>
            completedWidgetBuilderCallBack(index, state),
        maxBytes: readSetting.enableMaxImageKilobyte.isTrue
            ? readSetting.maxImageKilobyte.toInt() * 1024
            : null,
      ),
    );
  }

  /// loading for online mode
  Widget _loadingProgressWidgetBuilder(int index, double progress) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
            value: progress, color: UIConfig.primaryColor(Get.context!)),
        Text('loading'.tr).marginOnly(top: 8),
        Text((index + 1).toString()).marginOnly(top: 4),
      ],
    );
  }

  /// failed for online mode
  Widget _failedWidgetBuilder(int index, ExtendedImageState state) {
    log.warning('online image widget build failed', state.lastException);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconTextButton(
          icon: const Icon(Icons.error, color: UIConfig.readPageButtonColor),
          text: Text('networkError'.tr,
              style: const TextStyle(color: UIConfig.readPageButtonColor)),
          onPressed: () => logic.readPageLogic.reloadImage(index),
        ),
        Text((index + 1).toString()),
      ],
    );
  }

  /// completed for online mode
  Widget? completedWidgetBuilderCallBack(int index, ExtendedImageState state) {
    if (state.extendedImageInfo == null ||
        logic.readPageState.imageContainerSizes[index] != null) {
      return null;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.extendedImageInfo == null ||
          logic.readPageState.imageContainerSizes[index] != null) {
        return;
      }
      FittedSizes fittedSizes = logic.getImageFittedSize(
        Size(state.extendedImageInfo!.image.width.toDouble(),
            state.extendedImageInfo!.image.height.toDouble()),
      );
      logic.readPageState.imageContainerSizes[index] = fittedSizes.destination;
      logic.readPageLogic
          .updateSafely(['${readPageLogic.onlineImageId}::$index']);
    });

    return null;
  }

  /// local mode: wait for download service to parse and download
  Widget buildItemInLocalMode(BuildContext context, int index) {
    return GetBuilder<GalleryDownloadService>(
      id: '${galleryDownloadService.downloadImageId}::${readPageState.readPageInfo.gid}::$index',
      builder: (_) {
        /// step 1: wait for parsing image's href for this image. But if image's url has been parsed,
        /// we don't need to wait parsing thumbnail.
        if (readPageState.thumbnails[index] == null &&
            readPageState.images[index] == null) {
          return _buildWaitParsingHrefsIndicator(context, index);
        }

        /// step 2: wait for parsing image's url.
        if (readPageState.images[index] == null) {
          return _buildWaitParsingUrlIndicator(context, index);
        }

        /// step 3: check if we are using super resolution
        if (logic.readPageState.useSuperResolution) {
          return _buildLocalSuperResolutionImage(context, index);
        }

        /// step 4: wait for downloading or display it
        return _buildLocalImage(context, index);
      },
    );
  }

  Widget _buildLocalSuperResolutionImage(BuildContext context, int index) {
    return GetBuilder<SuperResolutionService>(
      id: '${SuperResolutionService.superResolutionImageId}::${readPageState.readPageInfo.gid!}::$index',
      builder: (_) {
        int gid = readPageState.readPageInfo.gid!;
        SuperResolutionType type =
            readPageState.readPageInfo.mode == ReadMode.downloaded
                ? SuperResolutionType.gallery
                : SuperResolutionType.archive;
        if (superResolutionService.get(gid, type)?.imageStatuses[index] !=
            SuperResolutionStatus.success) {
          return _buildLocalImage(context, index);
        }

        return GestureDetector(
          onLongPress: () => logic.showBottomMenuInLocalMode(index, context),
          onSecondaryTap: () => logic.showBottomMenuInLocalMode(index, context),
          child: EHImage(
            galleryImage: readPageState.images[index]!.copyWith(
              path: superResolutionService.computeImageOutputRelativePath(
                  readPageState.images[index]!.path!),
            ),
            containerWidth:
                logic.readPageState.imageContainerSizes[index]?.width ??
                    logic.getPlaceHolderSize(index).width,
            containerHeight:
                logic.readPageState.imageContainerSizes[index]?.height ??
                    logic.getPlaceHolderSize(index).height,
            clearMemoryCacheWhenDispose: true,
            loadingWidgetBuilder: () => _loadingWidgetBuilder(context, index),
            failedWidgetBuilder: (state) =>
                _failedWidgetBuilderForLocalMode(index, state),
            completedWidgetBuilder: (state) =>
                completedWidgetBuilderForLocalModeCallBack(index, state),
            maxBytes: readSetting.enableMaxImageKilobyte.isTrue
                ? readSetting.maxImageKilobyte.toInt() * 1024
                : null,
          ),
        );
      },
    );
  }

  /// wait for [GalleryDownloadService] to parse image href in local mode
  Widget _buildWaitParsingHrefsIndicator(BuildContext context, int index) {
    DownloadStatus downloadStatus = galleryDownloadService
        .galleryDownloadInfos[readPageState.readPageInfo.gid]!
        .downloadProgress
        .downloadStatus;
    Size placeHolderSize = logic.getPlaceHolderSize(index);

    return SizedBox(
      height: placeHolderSize.height,
      width: placeHolderSize.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (downloadStatus == DownloadStatus.downloading)
            UIConfig.loadingAnimation(context),
          if (downloadStatus == DownloadStatus.paused)
            const Icon(Icons.pause_circle_outline,
                color: UIConfig.readPageButtonColor),
          Text(downloadStatus == DownloadStatus.downloading
                  ? 'parsingPage'.tr
                  : 'paused'.tr)
              .marginOnly(top: 8),
          Text((index + 1).toString()).marginOnly(top: 4),
        ],
      ),
    );
  }

  /// wait for [GalleryDownloadService] to parse image url in local mode
  Widget _buildWaitParsingUrlIndicator(BuildContext context, int index) {
    DownloadStatus downloadStatus = galleryDownloadService
        .galleryDownloadInfos[readPageState.readPageInfo.gid]!
        .downloadProgress
        .downloadStatus;
    Size placeHolderSize = logic.getPlaceHolderSize(index);
    return SizedBox(
      height: placeHolderSize.height,
      width: placeHolderSize.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (downloadStatus == DownloadStatus.downloading)
            UIConfig.loadingAnimation(context),
          if (downloadStatus == DownloadStatus.paused)
            const Icon(Icons.pause_circle_outline,
                color: UIConfig.readPageButtonColor),
          Text(downloadStatus == DownloadStatus.downloading
                  ? 'parsingURL'.tr
                  : 'paused'.tr)
              .marginOnly(top: 8),
          Text((index + 1).toString()).marginOnly(top: 4),
        ],
      ),
    );
  }

  Widget _buildLocalImage(BuildContext context, int index) {
    return GestureDetector(
      onLongPress: () => logic.showBottomMenuInLocalMode(index, context),
      onSecondaryTap: () => logic.showBottomMenuInLocalMode(index, context),
      child: EHImage(
        galleryImage: readPageState.images[index]!,
        containerWidth: logic.readPageState.imageContainerSizes[index]?.width ??
            logic.getPlaceHolderSize(index).width,
        containerHeight:
            logic.readPageState.imageContainerSizes[index]?.height ??
                logic.getPlaceHolderSize(index).height,
        clearMemoryCacheWhenDispose: true,
        downloadingWidgetBuilder: () => _downloadingWidgetBuilder(index),
        pausedWidgetBuilder: () => _pausedWidgetBuilder(index),
        loadingWidgetBuilder: () => _loadingWidgetBuilder(context, index),
        failedWidgetBuilder: (state) =>
            _failedWidgetBuilderForLocalMode(index, state),
        completedWidgetBuilder: (state) =>
            completedWidgetBuilderForLocalModeCallBack(index, state),
        maxBytes: readSetting.enableMaxImageKilobyte.isTrue
            ? readSetting.maxImageKilobyte.toInt() * 1024
            : null,
      ),
    );
  }

  /// downloading for local mode
  Widget _downloadingWidgetBuilder(int index) {
    return GetBuilder<GalleryDownloadService>(
      id: '${galleryDownloadService.galleryDownloadSpeedComputerId}::${readPageState.readPageInfo.gid}',
      builder: (_) {
        GalleryDownloadSpeedComputer speedComputer = galleryDownloadService
            .galleryDownloadInfos[readPageState.readPageInfo.gid]!
            .speedComputer;
        int downloadedBytes = speedComputer.imageDownloadedBytes[index];
        int totalBytes = speedComputer.imageTotalBytes[index];

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
                value: max(downloadedBytes / totalBytes, 0.01),
                color: UIConfig.primaryColor(Get.context!)),
            Text('downloading'.tr).marginOnly(top: 8),
            Text((index + 1).toString()),
          ],
        );
      },
    );
  }

  /// paused for local mode
  Widget _pausedWidgetBuilder(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.pause_circle_outline,
            color: UIConfig.readPageButtonColor),
        Text('paused'.tr).marginOnly(top: 8),
        Text((index + 1).toString()),
      ],
    );
  }

  /// loading for local mode
  Widget _loadingWidgetBuilder(BuildContext context, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        UIConfig.loadingAnimation(context),
        Text((index + 1).toString()),
      ],
    );
  }

  /// failed for local mode
  Widget _failedWidgetBuilderForLocalMode(int index, ExtendedImageState state) {
    log.warning('local image widget build failed', state.lastException);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconTextButton(
          icon: const Icon(Icons.sentiment_very_dissatisfied),
          text: Text('error'.tr,
              style: const TextStyle(color: UIConfig.readPageButtonColor)),
          onPressed: state.reLoadImage,
        ),
        Text((index + 1).toString()),
      ],
    );
  }

  /// completed for local mode
  Widget? completedWidgetBuilderForLocalModeCallBack(
      int index, ExtendedImageState state) {
    if (state.extendedImageInfo == null ||
        logic.readPageState.imageContainerSizes[index] != null) {
      return null;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.extendedImageInfo == null ||
          logic.readPageState.imageContainerSizes[index] != null) {
        return;
      }
      FittedSizes fittedSizes = logic.getImageFittedSize(
        Size(state.extendedImageInfo!.image.width.toDouble(),
            state.extendedImageInfo!.image.height.toDouble()),
      );
      logic.readPageState.imageContainerSizes[index] = fittedSizes.destination;
      galleryDownloadService.updateSafely([
        '${galleryDownloadService.downloadImageId}::${readPageState.readPageInfo.gid}::$index'
      ]);
    });

    return null;
  }
}
