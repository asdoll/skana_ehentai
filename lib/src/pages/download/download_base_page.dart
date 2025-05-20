import 'dart:async';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/enum/config_enum.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/pages/download/grid/local/local_gallery_grid_page.dart';
import 'package:skana_ehentai/src/service/local_config_service.dart';
import 'package:simple_animations/animation_controller_extension/animation_controller_extension.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import '../../config/ui_config.dart';
import 'grid/archive/archive_grid_download_page.dart';
import 'grid/gallery/gallery_grid_download_page.dart';
import 'list/archive/archive_list_download_page.dart';
import 'list/gallery/gallery_list_download_page.dart';
import 'list/local/local_gallery_list_page.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  DownloadPageGalleryType galleryType = DownloadPageGalleryType.download;
  DownloadPageBodyType bodyType = GetPlatform.isMobile
      ? DownloadPageBodyType.list
      : DownloadPageBodyType.grid;
  Completer<void> bodyTypeCompleter = Completer<void>();

  @override
  void initState() {
    super.initState();

    localConfigService
        .read(configKey: ConfigEnum.downloadPageBodyType)
        .then((bodyTypeString) {
      if (bodyTypeString != null) {
        bodyType =
            DownloadPageBodyType.values[int.tryParse(bodyTypeString) ?? 0];
      }
    }).whenComplete(() {
      bodyTypeCompleter.complete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: NotificationListener<DownloadPageBodyTypeChangeNotification>(
        onNotification: (DownloadPageBodyTypeChangeNotification notification) {
          setState(() {
            galleryType = notification.galleryType ?? galleryType;
            bodyType = notification.bodyType ?? bodyType;
          });
          localConfigService.write(
              configKey: ConfigEnum.downloadPageBodyType,
              value: (notification.bodyType ?? bodyType).index.toString());
          return true;
        },
        child: FutureBuilder(
          future: bodyTypeCompleter.future,
          builder: (_, __) => !bodyTypeCompleter.isCompleted
              ? const Center()
              : galleryType == DownloadPageGalleryType.download
                  ? bodyType == DownloadPageBodyType.list
                      ? GalleryListDownloadPage(
                          key: const PageStorageKey('GalleryListDownloadBody'))
                      : GalleryGridDownloadPage(
                          key: const PageStorageKey('GalleryGridDownloadBody'))
                  : galleryType == DownloadPageGalleryType.archive
                      ? bodyType == DownloadPageBodyType.list
                          ? ArchiveListDownloadPage(
                              key: const PageStorageKey(
                                  'ArchiveListDownloadBody'))
                          : ArchiveGridDownloadPage(
                              key: const PageStorageKey(
                                  'ArchiveGridDownloadBody'))
                      : bodyType == DownloadPageBodyType.list
                          ? LocalGalleryListPage(
                              key: const PageStorageKey('LocalGalleryListBody'))
                          : LocalGalleryGridPage(
                              key:
                                  const PageStorageKey('LocalGalleryGridBody')),
        ),
      ),
    ).enableMouseDrag();
  }
}

enum DownloadPageGalleryType { download, archive, local }

enum DownloadPageBodyType { list, grid }

class DownloadPageBodyTypeChangeNotification extends Notification {
  DownloadPageGalleryType? galleryType;
  DownloadPageBodyType? bodyType;

  DownloadPageBodyTypeChangeNotification({this.galleryType, this.bodyType});
}

class DownloadPageSegmentControl extends StatefulWidget {
  final DownloadPageGalleryType galleryType;

  const DownloadPageSegmentControl({super.key, required this.galleryType});

  @override
  State<DownloadPageSegmentControl> createState() =>
      _DownloadPageSegmentControlState();
}

class _DownloadPageSegmentControlState
    extends State<DownloadPageSegmentControl> {
  @override
  Widget build(BuildContext context) {
    return MoonSegmentedControl(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
      segmentedControlSize: MoonSegmentedControlSize.sm,
      initialIndex: widget.galleryType == DownloadPageGalleryType.archive
          ? 1
          : widget.galleryType == DownloadPageGalleryType.local
              ? 2
              : 0,
      isExpanded: true,
      segments: [
        Segment(
          label: Text(
            'download'.tr,
            style: const TextStyle(
                fontSize: UIConfig.downloadPageSegmentedTextSize,
                fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Segment(
          label: Text(
            'archive'.tr,
            style: const TextStyle(
                fontSize: UIConfig.downloadPageSegmentedTextSize,
                fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Segment(
          label: Text(
            'local'.tr,
            style: const TextStyle(
                fontSize: UIConfig.downloadPageSegmentedTextSize,
                fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
      onSegmentChanged: (value) {
        setState(() {
          DownloadPageBodyTypeChangeNotification(
                  galleryType: value == 0
                      ? DownloadPageGalleryType.download
                      : value == 1
                          ? DownloadPageGalleryType.archive
                          : DownloadPageGalleryType.local)
              .dispatch(context);
        });
      },
    );
  }
}

class GroupOpenIndicator extends StatefulWidget {
  final bool isOpen;

  const GroupOpenIndicator({super.key, required this.isOpen});

  @override
  State<GroupOpenIndicator> createState() => _GroupOpenIndicatorState();
}

class _GroupOpenIndicatorState extends State<GroupOpenIndicator>
    with AnimationMixin {
  bool isOpen = false;
  late Animation<double> animation =
      Tween<double>(begin: 0.0, end: -0.25).animate(controller);

  @override
  void initState() {
    super.initState();

    isOpen = widget.isOpen;
    if (isOpen) {
      controller.forward(from: 1);
    }
  }

  @override
  void didUpdateWidget(covariant GroupOpenIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isOpen == widget.isOpen) {
      return;
    }

    isOpen = widget.isOpen;
    if (isOpen) {
      controller.play(duration: const Duration(milliseconds: 150));
    } else {
      controller.playReverse(duration: const Duration(milliseconds: 150));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: animation,
      child: moonIcon(icon:BootstrapIcons.caret_left),
    );
  }
}
