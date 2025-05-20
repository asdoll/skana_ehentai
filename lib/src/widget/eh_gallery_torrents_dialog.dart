import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/dio_exception_extension.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/model/gallery_torrent.dart';
import 'package:skana_ehentai/src/network/eh_request.dart';
import 'package:skana_ehentai/src/utils/eh_spider_parser.dart';
import 'package:skana_ehentai/src/service/log.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/loading_state_indicator.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../exception/eh_site_exception.dart';
import '../utils/snack_util.dart';
import '../utils/toast_util.dart';

class EHGalleryTorrentsDialog extends StatefulWidget {
  final int gid;
  final String token;

  const EHGalleryTorrentsDialog(
      {super.key, required this.gid, required this.token});

  @override
  State<EHGalleryTorrentsDialog> createState() =>
      _EHGalleryTorrentsDialogState();
}

class _EHGalleryTorrentsDialogState extends State<EHGalleryTorrentsDialog> {
  List<GalleryTorrent> galleryTorrents = <GalleryTorrent>[];
  LoadingState loadingState = LoadingState.idle;

  @override
  void initState() {
    super.initState();
    _getTorrent();
  }

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
            context: context,
            title: 'torrent'.tr,
            contentWidget: LoadingStateIndicator(
              loadingState: loadingState,
              indicatorRadius: 16,
              successWidgetBuilder: () =>
                  _TorrentList(galleryTorrents: galleryTorrents),
              errorWidgetBuilder: () => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _getTorrent,
                child: Icon(Icons.refresh,
                    size: 32,
                    color: UIConfig.loadingStateIndicatorButtonColor(context)),
              ),
            ),
            padding: EdgeInsets.only(top: 20, bottom: 20, left: 8, right: 8))
        .enableMouseDrag(withScrollBar: false);
  }

  Future<void> _getTorrent() async {
    setState(() {
      loadingState = LoadingState.loading;
    });

    try {
      galleryTorrents =
          await ehRequest.requestTorrentPage<List<GalleryTorrent>>(
        widget.gid,
        widget.token,
        EHSpiderParser.torrentPage2GalleryTorrent,
      );
    } on DioException catch (e) {
      log.error('getGalleryTorrentsFailed'.tr, e.errorMsg);
      snack('getGalleryTorrentsFailed'.tr, e.errorMsg ?? '');
      if (mounted) {
        setState(() => loadingState = LoadingState.error);
      }
      return;
    } on EHSiteException catch (e) {
      log.error('getGalleryTorrentsFailed'.tr, e.message);
      snack('getGalleryTorrentsFailed'.tr, e.message);
      if (mounted) {
        setState(() => loadingState = LoadingState.error);
      }
      return;
    }

    if (mounted) {
      setState(() => loadingState = LoadingState.success);
    }
  }
}

class _TorrentList extends StatelessWidget {
  final List<GalleryTorrent> galleryTorrents;

  const _TorrentList({required this.galleryTorrents});

  @override
  Widget build(BuildContext context) {
    List<GalleryTorrent> lastestTorrents =
        galleryTorrents.where((torrent) => !torrent.outdated).toList();
    List<GalleryTorrent> outdatedTorrents =
        galleryTorrents.where((torrent) => torrent.outdated).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...lastestTorrents
            .map<Widget>((torrent) => _buildListTile(torrent, context)),
        if (outdatedTorrents.isNotEmpty) _buildOutdatedHint(context),
        if (outdatedTorrents.isNotEmpty)
          ...outdatedTorrents
              .map<Widget>((torrent) => _buildListTile(torrent, context)),
      ],
    );
  }

  Widget _buildOutdatedHint(BuildContext context) {
    return Container(
      height: 24,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      alignment: Alignment.center,
      child: Text('${'outdated'.tr}↓'),
    );
  }

  Widget _buildListTile(GalleryTorrent torrent, BuildContext context) {
    return moonListTileWidgets(
      onTap: () => launchUrlString(
        torrent.torrentUrl.replaceFirst(
            'https://exhentai.org/torrent', 'https://ehtracker.org/get'),
        mode: LaunchMode.externalApplication,
      ),
      label: Text(torrent.title,
          style: TextStyle(
              fontSize: UIConfig.torrentDialogTitleSize,
              color: UIConfig.resumePauseButtonColor(context))),
      content: Column(
        children: [
          Row(
            children: [
              const Icon(BootstrapIcons.person,
                      size: UIConfig.torrentDialogSubtitleIconSize)
                  .paddingTop(2),
              SizedBox(width: 2),
              Text(torrent.peers.toString(),
                      style: const TextStyle(
                          fontSize: UIConfig.torrentDialogSubtitleTextSize))
                  .xSmall(),
              const Icon(BootstrapIcons.download,
                      size: UIConfig.torrentDialogSubtitleIconSize)
                  .paddingTop(2)
                  .marginOnly(left: 6),
              SizedBox(width: 4),
              Text(torrent.downloads.toString(),
                      style: const TextStyle(
                          fontSize: UIConfig.torrentDialogSubtitleTextSize))
                  .xSmall(),
            ],
          ).paddingBottom(2),
          Row(
            children: [
              const Icon(BootstrapIcons.paperclip,
                      size: UIConfig.torrentDialogSubtitleIconSize)
                  .paddingTop(2),
              SizedBox(width: 2),
              Text(torrent.size,
                      style: const TextStyle(
                          fontSize: UIConfig.torrentDialogSubtitleTextSize))
                  .xSmall(),
              Text(torrent.postTime,
                      style: const TextStyle(
                          fontSize: UIConfig.torrentDialogSubtitleTextSize))
                  .xSmall()
                  .marginOnly(left: 6),
            ],
          )
        ],
      ),
      trailing: MoonButton.icon(
        icon: Icon(BootstrapIcons.magnet,
            color: UIConfig.resumePauseButtonColor(context), size: 16),
        padding: EdgeInsets.zero,
        onTap: () => FlutterClipboard.copy(torrent.magnetUrl)
            .then((_) => toast('hasCopiedToClipboard'.tr)),
      ),
    );
  }
}
