import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skana_ehentai/src/exception/eh_site_exception.dart';
import 'package:skana_ehentai/src/setting/advanced_setting.dart';
import 'package:skana_ehentai/src/service/path_service.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

import '../exception/upload_exception.dart';
import 'jh_service.dart';
import '../utils/byte_util.dart';

LogService log = LogService();

class LogService with JHLifeCircleBeanErrorCatch implements JHLifeCircleBean {
  String? logDirPath;

  Logger? _consoleLogger;
  Logger? _verboseFileLogger;
  Logger? _warningFileLogger;
  Logger? _downloadFileLogger;

  LogPrinter devPrinter = PrettyPrinter(stackTraceBeginIndex: 0, methodCount: 6, levelEmojis: {Level.trace: '✔ '});
  LogPrinter prodPrinterWithBox = PrettyPrinter(stackTraceBeginIndex: 0, methodCount: 6, colors: false, printTime: true, levelEmojis: {Level.trace: '✔ '});
  LogPrinter prodPrinterWithoutBox =
      PrettyPrinter(stackTraceBeginIndex: 0, methodCount: 6, colors: false, noBoxingByDefault: true, levelEmojis: {Level.trace: '✔ '});

  @override
  List<JHLifeCircleBean> get initDependencies => [pathService];

  @override
  Future<void> doInitBean() async {
    PlatformDispatcher.instance.onError = (error, stack) {
      if (error is NotUploadException) {
        return true;
      }

      log.error('Global Error', error, stack);
      return false;
    };

    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is NotUploadException) {
        return;
      }

      log.error('Global Error', details.exception, details.stack);
    };
  }

  @override
  Future<void> doAfterBeanReady() async {}

  /// For actions that print params
  void trace(Object msg, [bool withStack = false]) async {
    await _initLogger();
    _consoleLogger?.t(msg, stackTrace: withStack ? null : StackTrace.empty);
    _verboseFileLogger?.t(msg, stackTrace: withStack ? null : StackTrace.empty);
  }

  /// For actions that is invisible to user
  void debug(Object msg, [bool withStack = false]) async {
    await _initLogger();
    _consoleLogger?.d(msg, stackTrace: withStack ? null : StackTrace.empty);
    _verboseFileLogger?.d(msg, stackTrace: withStack ? null : StackTrace.empty);
  }

  /// For actions that is visible to user
  void info(Object msg, [bool withStack = false]) async {
    await _initLogger();
    _consoleLogger?.i(msg, stackTrace: withStack ? null : StackTrace.empty);
    _verboseFileLogger?.i(msg, stackTrace: withStack ? null : StackTrace.empty);
  }

  void warning(Object msg, [Object? error, bool withStack = false]) async {
    await _initLogger();
    _consoleLogger?.w(msg, error: error, stackTrace: withStack ? null : StackTrace.empty);
    _verboseFileLogger?.w(msg, error: error, stackTrace: withStack ? null : StackTrace.empty);
    _warningFileLogger?.w(msg, error: error, stackTrace: withStack ? null : StackTrace.empty);
  }

  void error(Object msg, [Object? error, StackTrace? stackTrace]) async {
    await _initLogger();
    _consoleLogger?.e(msg, error: error, stackTrace: stackTrace);
    _verboseFileLogger?.e(msg, error: error, stackTrace: stackTrace);
    _warningFileLogger?.e(msg, error: error, stackTrace: stackTrace);
  }

  void download(Object msg) async {
    await _initLogger();
    _consoleLogger?.t(msg, stackTrace: StackTrace.empty);
    _downloadFileLogger?.t(msg, stackTrace: StackTrace.empty);
  }

  Future<void> uploadError(dynamic throwable, {dynamic stackTrace, Map<String, dynamic>? extraInfos}) async {
    /// sentry is removed
  }

  Future<String> getSize() async {
    return compute(
      (logDirPath) {
        Directory logDirectory = Directory(logDirPath!);
        return logDirectory.exists().then<int>((exist) {
          if (!exist) {
            return 0;
          }

          return logDirectory.list().fold<int>(0, (previousValue, element) => previousValue += (element as File).lengthSync());
        }).then<String>((totalBytes) => byte2String(totalBytes.toDouble()));
      },
      logDirPath,
    );
  }

  Future<void> clear() async {
    await _verboseFileLogger?.close();
    await _warningFileLogger?.close();
    await _downloadFileLogger?.close();

    _verboseFileLogger = null;
    _warningFileLogger = null;
    _downloadFileLogger = null;

    if (await Directory(logDirPath!).exists()) {
      await Directory(logDirPath!).delete(recursive: true);
    }
  }

  Future<void> _initLogDir() async {
    if (logDirPath == null) {
      logDirPath = path.join(pathService.getVisibleDir().path, 'logs');
      if (!await Directory(logDirPath!).exists()) {
        await Directory(logDirPath!).create();
      }
    }
  }

  Future<void> _initLogger() async {
    _consoleLogger ??= Logger(printer: devPrinter);

    await _initLogDir();
    String fileName = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());

    _verboseFileLogger ??= Logger(
      printer: HybridPrinter(prodPrinterWithBox, trace: prodPrinterWithoutBox, debug: prodPrinterWithoutBox, info: prodPrinterWithoutBox),
      filter: EHLogFilter(),
      output: FileOutput(file: File(path.join(logDirPath!, '$fileName.log'))),
    );
    if (advancedSetting.enableVerboseLogging.isTrue) {
      _warningFileLogger ??= Logger(
        level: Level.warning,
        printer: prodPrinterWithBox,
        filter: ProductionFilter(),
        output: FileOutput(file: File(path.join(logDirPath!, '${fileName}_error.log'))),
      );
      _downloadFileLogger ??= Logger(
        printer: prodPrinterWithoutBox,
        filter: ProductionFilter(),
        output: FileOutput(file: File(path.join(logDirPath!, '${fileName}_download.log'))),
      );
    }

    await Future.wait([
      _consoleLogger!.init,
      _verboseFileLogger!.init,
      if (_warningFileLogger != null) _warningFileLogger!.init,
      if (_downloadFileLogger != null) _downloadFileLogger!.init,
    ]);
  }
}

class EHLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (advancedSetting.enableVerboseLogging.isTrue) {
      return event.level.index >= level!.index;
    }
    return event.level.index >= level!.index && event.level != Level.trace;
  }
}

T callWithParamsUploadIfErrorOccurs<T>(T Function() func, {dynamic params, T? defaultValue}) {
  try {
    return func.call();
  } on Exception catch (e) {
    if (e is DioException || e is EHSiteException) {
      rethrow;
    }

    log.error('operationFailed'.tr, e);
    log.uploadError(e, extraInfos: {'params': params});
    if (defaultValue == null) {
      throw NotUploadException(e);
    }
    return defaultValue;
  } on Error catch (e) {
    log.error('operationFailed'.tr, e);
    log.uploadError(e, extraInfos: {'params': params});
    if (defaultValue == null) {
      throw NotUploadException(e);
    }
    return defaultValue;
  }
}
