import 'package:clipboard/clipboard.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/dio_exception_extension.dart';
import 'package:skana_ehentai/src/extension/list_extension.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/model/gallery_torrent.dart';
import 'package:skana_ehentai/src/network/eh_request.dart';
import 'package:skana_ehentai/src/utils/eh_spider_parser.dart';
import 'package:skana_ehentai/src/service/log.dart';
import 'package:skana_ehentai/src/widget/loading_state_indicator.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../exception/eh_site_exception.dart';
import '../utils/snack_util.dart';
import '../utils/toast_util.dart';

class EHGalleryTorrentsDialog extends StatefulWidget {
  final int gid;
  final String token;

  const EHGalleryTorrentsDialog({Key? key, required this.gid, required this.token}) : super(key: key);

  @override
  _EHGalleryTorrentsDialogState createState() => _EHGalleryTorrentsDialogState();
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
    return SimpleDialog(
      title: Center(child: Text('torrent'.tr)),
      contentPadding: const EdgeInsets.only(bottom: 12, top: 24),
      children: [
        LoadingStateIndicator(
          loadingState: loadingState,
          indicatorRadius: 16,
          successWidgetBuilder: () => _TorrentList(galleryTorrents: galleryTorrents),
          errorWidgetBuilder: () => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _getTorrent,
            child: Icon(Icons.refresh, size: 32, color: UIConfig.loadingStateIndicatorButtonColor(context)),
          ),
        ),
      ],
    ).enableMouseDrag(withScrollBar: false);
  }

  Future<void> _getTorrent() async {
    setState(() {
      loadingState = LoadingState.loading;
    });

    try {
      galleryTorrents = await ehRequest.requestTorrentPage<List<GalleryTorrent>>(
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

  const _TorrentList({Key? key, required this.galleryTorrents}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<GalleryTorrent> lastestTorrents = galleryTorrents.where((torrent) => !torrent.outdated).toList();
    List<GalleryTorrent> outdatedTorrents = galleryTorrents.where((torrent) => torrent.outdated).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...lastestTorrents.map<Widget>((torrent) => _buildListTile(torrent, context)).toList().joinNewElement(const Divider(height: 1), joinAtFirst: true),
        if (lastestTorrents.isNotEmpty && outdatedTorrents.isNotEmpty) const Divider(height: 1),
        if (outdatedTorrents.isNotEmpty) _buildOutdatedHint(context),
        if (outdatedTorrents.isNotEmpty)
          ...outdatedTorrents.map<Widget>((torrent) => _buildListTile(torrent, context)).toList().joinNewElement(const Divider(height: 1), joinAtFirst: true),
      ],
    );
  }

  Widget _buildOutdatedHint(BuildContext context) {
    return Container(
      height: 24,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      alignment: Alignment.center,
      child: Text('outdated'.tr + '↓'),
    );
  }

  Widget _buildListTile(GalleryTorrent torrent, BuildContext context) {
    return ListTile(
      dense: true,
      title: InkWell(
        onTap: () => launchUrlString(
          torrent.torrentUrl.replaceFirst('https://exhentai.org/torrent', 'https://ehtracker.org/get'),
          mode: LaunchMode.externalApplication,
        ),
        child: Text(torrent.title, style: TextStyle(fontSize: UIConfig.torrentDialogTitleSize, color: UIConfig.resumePauseButtonColor(context))),
      ),
      subtitle: Row(
        children: [
          const Icon(Icons.account_circle, size: UIConfig.torrentDialogSubtitleIconSize),
          Text(torrent.peers.toString(), style: const TextStyle(fontSize: UIConfig.torrentDialogSubtitleTextSize)),
          const Icon(Icons.download, size: UIConfig.torrentDialogSubtitleIconSize).marginOnly(left: 6),
          Text(torrent.downloads.toString(), style: const TextStyle(fontSize: UIConfig.torrentDialogSubtitleTextSize)),
          const Icon(Icons.attach_file, size: UIConfig.torrentDialogSubtitleIconSize).marginOnly(left: 6),
          Text(torrent.size, style: const TextStyle(fontSize: UIConfig.torrentDialogSubtitleTextSize)),
          Text(torrent.postTime, style: const TextStyle(fontSize: UIConfig.torrentDialogSubtitleTextSize)).marginOnly(left: 6),
        ],
      ),
      trailing: IconButton(
        icon: Icon(FontAwesomeIcons.magnet, size: 16, color: UIConfig.resumePauseButtonColor(context)),
        padding: EdgeInsets.zero,
        onPressed: () => FlutterClipboard.copy(torrent.magnetUrl).then((_) => toast('hasCopiedToClipboard'.tr)),
      ),
    );
  }
}
