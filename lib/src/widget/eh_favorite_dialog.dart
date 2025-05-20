import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_ehentai/src/config/ui_config.dart';
import 'package:skana_ehentai/src/extension/dio_exception_extension.dart';
import 'package:skana_ehentai/src/model/gallery_note.dart';
import 'package:skana_ehentai/src/setting/preference_setting.dart';
import 'package:skana_ehentai/src/utils/toast_util.dart';
import 'package:skana_ehentai/src/utils/widgetplugin.dart';
import 'package:skana_ehentai/src/widget/loading_state_indicator.dart';

import '../exception/eh_site_exception.dart';
import '../setting/favorite_setting.dart';
import '../service/log.dart';
import '../utils/route_util.dart';
import '../utils/snack_util.dart';

typedef GalleryNoteFetchFunction = Future<GalleryNote> Function();

class EHFavoriteDialog extends StatefulWidget {
  final int? selectedIndex;
  final bool needInitNote;
  final GalleryNoteFetchFunction? initNoteFuture;

  const EHFavoriteDialog({
    super.key,
    this.selectedIndex,
    this.needInitNote = false,
    this.initNoteFuture,
  }) : assert(needInitNote == false || initNoteFuture != null);

  @override
  State<EHFavoriteDialog> createState() => _EHFavoriteDialogState();
}

class _EHFavoriteDialogState extends State<EHFavoriteDialog> {
  int? selectedIndex;

  final TextEditingController _controller = TextEditingController();

  bool remember = false;

  bool inNoteMode = false;

  LoadingState _loadingState = LoadingState.idle;

  @override
  void initState() {
    selectedIndex = widget.selectedIndex;
    if (widget.needInitNote) {
      _initFavoriteNote();
    } else {
      _loadingState = LoadingState.success;
    }

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return moonAlertDialog(
      context: context,
      title: 'chooseFavorite'.tr,
      contentWidget: LoadingStateIndicator(
        loadingState: _loadingState,
        errorTapCallback: _initFavoriteNote,
        successWidgetBuilder: () => Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 6),
              ...favoriteSetting.favoriteTagNames.mapIndexed((index, tagName) =>
                  moonListTile(
                      title: tagName,
                      titleColor: index == selectedIndex
                          ? UIConfig.favoriteDialogTileColor(context)
                          : null,
                      trailing: Text(
                        favoriteSetting.favoriteCounts[index].toString(),
                        style: TextStyle(
                            color:
                                UIConfig.favoriteDialogCountTextColor(context)),
                      ).small(),
                      onTap: () {
                        backRoute(
                          result: (
                            isDelete: index == selectedIndex,
                            favIndex: index,
                            note: _controller.text,
                            remember: remember,
                          ),
                        );
                      })),
              Divider(height: 12, color: UIConfig.layoutDividerColor(context)),
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.only(left: 12, right: 12),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (preferenceSetting.enableDefaultFavorite.isTrue)
                      Text('asYourDefault'.tr).small(),
                    if (preferenceSetting.enableDefaultFavorite.isTrue)
                      MoonCheckbox(
                          value: remember,
                          onChanged: (value) =>
                              setState(() => remember = value!)),
                  ],
                ),
                trailing: MoonButton.icon(
                  icon: const Icon(BootstrapIcons.pencil_square, size: 20),
                  onTap: () {
                    setState(() {
                      inNoteMode = !inNoteMode;
                    });
                  },
                ),
              ),
              if (inNoteMode)
                MoonTextInput(
                  controller: _controller,
                  padding: const EdgeInsets.only(left: 12, right: 0),
                  inputFormatters: [LengthLimitingTextInputFormatter(200)],
                  style: const TextStyle(fontSize: 12),
                  minLines: 1,
                  maxLines: 4,
                  trailing: MoonButton.icon(
                    icon: moonIcon(icon: BootstrapIcons.check2),
                    onTap: () {
                      if (selectedIndex == null) {
                        toast('addNoteHint'.tr);
                        return;
                      }

                      backRoute(
                        result: (
                          isDelete: false,
                          favIndex: selectedIndex,
                          note: _controller.text,
                          remember: remember,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initFavoriteNote() async {
    assert(widget.initNoteFuture != null);

    if (_loadingState == LoadingState.loading) {
      return;
    }
    setState(() => _loadingState = LoadingState.loading);

    log.info('Get gallery favorite info');
    GalleryNote note;
    try {
      note = await widget.initNoteFuture!();
      _controller.text = note.note;
      setState(() {
        if (_controller.text.isNotEmpty) {
          inNoteMode = true;
        }
        _loadingState = LoadingState.success;
      });
    } on DioException catch (e) {
      log.error('getGalleryFavoriteInfoFailed'.tr, e.errorMsg);
      snack('getGalleryFavoriteInfoFailed'.tr, e.errorMsg ?? '', isShort: true);
      setState(() => _loadingState = LoadingState.error);
      return;
    } on EHSiteException catch (e) {
      log.error('getGalleryFavoriteInfoFailed'.tr, e.message);
      snack('getGalleryFavoriteInfoFailed'.tr, e.message, isShort: true);
      setState(() => _loadingState = LoadingState.error);
      return;
    } catch (e, s) {
      log.error('getGalleryFavoriteInfoFailed'.tr, e, s);
      snack('getGalleryFavoriteInfoFailed'.tr, e.toString(), isShort: true);
      setState(() => _loadingState = LoadingState.error);
      return;
    }
  }
}
