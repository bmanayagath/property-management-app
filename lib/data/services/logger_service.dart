import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../models/app_log.dart';
import '../local/app_logs_dao.dart';
import '../local/database.dart';

class LoggerService {
  LoggerService._();

  static final LoggerService instance = LoggerService._();
  static const appVersion = '1.0.2+32';

  AppLogsDao? _dao;
  final _uuid = const Uuid();

  static void initialize(AppDatabase database) {
    instance._dao = AppLogsDao(database);
  }

  static Stream<List<AppLog>> watchLogs({
    String search = '',
    String? category,
    bool newestFirst = true,
  }) {
    return instance._requireDao().watchLogs(
          search: search,
          category: category,
          newestFirst: newestFirst,
        );
  }

  static Future<List<AppLog>> getLogs({
    String search = '',
    String? category,
    bool newestFirst = true,
  }) {
    return instance._requireDao().getLogs(
          search: search,
          category: category,
          newestFirst: newestFirst,
        );
  }

  static Future<void> clearLogs() {
    return instance._requireDao().clearLogs();
  }

  static Future<void> exportLogs({
    String search = '',
    String? category,
    bool newestFirst = true,
  }) async {
    final logs = await getLogs(
      search: search,
      category: category,
      newestFirst: newestFirst,
    );
    final payload = logs.map(_logToJson).toList();
    final directory = await getTemporaryDirectory();
    final fileName =
        'villabooks_logs_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File(path.join(directory.path, fileName));
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    await SharePlus.instance.share(
      ShareParams(
        text: 'VillaBooks developer logs',
        files: [XFile(file.path)],
      ),
    );
  }

  static Future<void> logInfo({
    required String screenName,
    required String operation,
    required String message,
    String details = '',
  }) {
    return instance._write(
      category: AppLogCategory.info,
      level: AppLogLevel.info,
      screenName: screenName,
      operation: operation,
      message: message,
      details: details,
    );
  }

  static Future<void> logWarning({
    required String screenName,
    required String operation,
    required String message,
    String details = '',
    String stackTrace = '',
  }) {
    return instance._write(
      category: AppLogCategory.warning,
      level: AppLogLevel.warning,
      screenName: screenName,
      operation: operation,
      message: message,
      details: details,
      stackTrace: stackTrace,
    );
  }

  static Future<void> logError({
    required String screenName,
    required String operation,
    required String message,
    String details = '',
    String stackTrace = '',
  }) {
    return instance._write(
      category: AppLogCategory.error,
      level: AppLogLevel.error,
      screenName: screenName,
      operation: operation,
      message: message,
      details: details,
      stackTrace: stackTrace,
    );
  }

  static Future<void> logSync({
    required String screenName,
    required String operation,
    required String message,
    String details = '',
    String stackTrace = '',
    String level = AppLogLevel.info,
  }) {
    return instance._write(
      category: AppLogCategory.sync,
      level: level,
      screenName: screenName,
      operation: operation,
      message: message,
      details: details,
      stackTrace: stackTrace,
    );
  }

  static Future<void> logUpload({
    required String screenName,
    required String operation,
    required String message,
    String details = '',
    String stackTrace = '',
    String level = AppLogLevel.info,
  }) {
    return instance._write(
      category: AppLogCategory.upload,
      level: level,
      screenName: screenName,
      operation: operation,
      message: message,
      details: details,
      stackTrace: stackTrace,
    );
  }

  static Future<void> logFirebase({
    required String screenName,
    required String operation,
    required String message,
    String details = '',
    String stackTrace = '',
    String level = AppLogLevel.error,
  }) {
    return instance._write(
      category: AppLogCategory.firebase,
      level: level,
      screenName: screenName,
      operation: operation,
      message: message,
      details: details,
      stackTrace: stackTrace,
    );
  }

  static Future<void> logAuth({
    required String screenName,
    required String operation,
    required String message,
    String details = '',
    String stackTrace = '',
    String level = AppLogLevel.info,
  }) {
    return instance._write(
      category: AppLogCategory.auth,
      level: level,
      screenName: screenName,
      operation: operation,
      message: message,
      details: details,
      stackTrace: stackTrace,
    );
  }

  static Future<void> logNetwork({
    required String screenName,
    required String operation,
    required String message,
    String details = '',
    String stackTrace = '',
    String level = AppLogLevel.info,
  }) {
    return instance._write(
      category: AppLogCategory.network,
      level: level,
      screenName: screenName,
      operation: operation,
      message: message,
      details: details,
      stackTrace: stackTrace,
    );
  }

  Future<void> _write({
    required String category,
    required String level,
    required String screenName,
    required String operation,
    required String message,
    String details = '',
    String stackTrace = '',
  }) async {
    debugPrint('[$category][$level][$screenName][$operation] $message');
    if (details.isNotEmpty) {
      debugPrint(details);
    }
    final dao = _dao;
    if (dao == null) {
      debugPrint('[LoggerService] skipped log before initialization: $message');
      return;
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      await dao.insertLog(
        AppLogsCompanion.insert(
          id: _uuid.v4(),
          timestamp: DateTime.now().toIso8601String(),
          category: category,
          level: level,
          screenName: screenName,
          operation: operation,
          message: message,
          details: Value(details),
          stackTrace: Value(stackTrace),
          userId: Value(user?.uid ?? ''),
          userEmail: Value(user?.email ?? ''),
          devicePlatform: Value(_platformName()),
          appVersion: const Value(appVersion),
        ),
      );
    } catch (error, stack) {
      debugPrint('[LoggerService] failed to write log: $error');
      debugPrintStack(stackTrace: stack);
    }
  }

  AppLogsDao _requireDao() {
    final dao = _dao;
    if (dao == null) {
      throw StateError('LoggerService has not been initialized.');
    }
    return dao;
  }

  static Map<String, Object?> _logToJson(AppLog log) {
    return {
      'id': log.id,
      'timestamp': log.timestamp,
      'category': log.category,
      'level': log.level,
      'screenName': log.screenName,
      'operation': log.operation,
      'message': log.message,
      'details': log.details,
      'stackTrace': log.stackTrace,
      'userId': log.userId,
      'userEmail': log.userEmail,
      'devicePlatform': log.devicePlatform,
      'appVersion': log.appVersion,
    };
  }

  String _platformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}
