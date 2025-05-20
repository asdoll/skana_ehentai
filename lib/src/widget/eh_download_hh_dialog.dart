import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/extension/dio_exception_extension.dart';
import 'package:skana_ehentai/src/extension/widget_extension.dart';
import 'package:skana_ehentai/src/utils/route_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';

import '../config/ui_config.dart';
import '../exception/eh_site_exception.dart';
import '../exception/upload_exception.dart';
import '../model/gallery_hh_archive.dart';
import '../model/gallery_hh_info.dart';
import '../network/eh_request.dart';
import '../utils/eh_spider_parser.dart';
import '../service/log.dart';
import '../utils/snack_util.dart';
import 'eh_asset.dart';
import 'loading_state_indicator.dart';

class EHDownloadHHDialog extends StatefulWidget {
  final String archivePageUrl;

  const EHDownloadHHDialog({super.key, required this.archivePageUrl});

  @override
  State<EHDownloadHHDialog> createState() => _EHDownloadHHDialogState();
}

class _EHDownloadHHDialogState extends State<EHDownloadHHDialog> {
  late GalleryHHInfo hhInfo;
  LoadingState loadingState = LoadingState.idle;

  @override
  void initState() {
    super.initState();
    _getHHInfo();
  }

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context: context,
      title: 'H@H ${'download'.tr}',
      contentWidget: SizedBox(
        height: UIConfig.hhDialogBodyHeight,
        child: LoadingStateIndicator(
          loadingState: loadingState,
          errorTapCallback: _getHHInfo,
          successWidgetBuilder: _buildBody,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (hhInfo.creditCount != null && hhInfo.gpCount != null)
          EHAsset(gpCount: hhInfo.gpCount!, creditCount: hhInfo.creditCount!),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _HHDownloadButtonSet(archive: hhInfo.archives[0]),
            _HHDownloadButtonSet(archive: hhInfo.archives[1])
          ],
        ).marginOnly(top: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _HHDownloadButtonSet(archive: hhInfo.archives[2]),
            _HHDownloadButtonSet(archive: hhInfo.archives[3])
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _HHDownloadButtonSet(archive: hhInfo.archives[4]),
            if (hhInfo.archives.length >= 6)
              _HHDownloadButtonSet(archive: hhInfo.archives[5])
          ],
        ),
      ],
    );
  }

  Future<void> _getHHInfo() async {
    setState(() => loadingState = LoadingState.loading);

    try {
      hhInfo = await ehRequest.get(
          url: widget.archivePageUrl,
          parser: EHSpiderParser.archivePage2HHInfo);
    } on DioException catch (e) {
      log.error('Get H@H download info failed', e.errorMsg);
      snack('failed'.tr, e.errorMsg ?? '');
      setStateSafely(() => loadingState = LoadingState.error);
      return;
    } on EHSiteException catch (e) {
      log.error('Get H@H download info failed', e.message);
      snack('failed'.tr, e.message);
      setStateSafely(() => loadingState = LoadingState.error);
      return;
    } on NotUploadException catch (_) {
      snack('Get H@H download info failed', 'parseGalleryArchiveFailed'.tr);
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

class _HHDownloadButtonSet extends StatelessWidget {
  final GalleryHHArchive archive;

  const _HHDownloadButtonSet({required this.archive});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MoonFilledButton(
          buttonSize: MoonButtonSize.sm,
          onTap: archive.resolution == null
              ? null
              : () => backRoute(result: archive.resolution),
          label: SizedBox(
            width: UIConfig.hhDialogTextButtonWidth,
            child: Center(
              child: Text(archive.resolutionDesc).small(),
            ),
          ),
        ),
        Row(
          children: [
            Text(
              archive.size.removeAllWhitespace,
              style: TextStyle(
                  color: UIConfig.hhDialogCostTextColor(context),
                  fontSize: UIConfig.hhDialogTextSize),
            ).small().marginOnly(right: 6),
            Text(
              archive.cost.removeAllWhitespace,
              style: TextStyle(
                  color: UIConfig.hhDialogCostTextColor(context),
                  fontSize: UIConfig.hhDialogTextSize),
            ).small(),
          ],
        )
      ],
    );
  }
}
