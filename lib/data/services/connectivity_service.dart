import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'logger_service.dart';

class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  Stream<bool> get onlineStatus async* {
    final initialResults = await _connectivity.checkConnectivity();
    final initialIsOnline = _hasConnection(initialResults);
    debugPrint(
      '[Connectivity] initial results=$initialResults, isOnline=$initialIsOnline',
    );
    unawaited(
      LoggerService.logNetwork(
        screenName: 'ConnectivityService',
        operation: 'InitialStatus',
        message: initialIsOnline ? 'Device is online' : 'Device is offline',
        details: initialResults.toString(),
      ),
    );
    yield initialIsOnline;

    yield* _connectivity.onConnectivityChanged.map((results) {
      final isOnline = _hasConnection(results);
      debugPrint('[Connectivity] changed results=$results, isOnline=$isOnline');
      unawaited(
        LoggerService.logNetwork(
          screenName: 'ConnectivityService',
          operation: 'ConnectivityChanged',
          message: isOnline ? 'Device is online' : 'Device is offline',
          details: results.toString(),
        ),
      );
      return isOnline;
    }).distinct();
  }

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    final isOnline = _hasConnection(results);
    debugPrint('[Connectivity] check results=$results, isOnline=$isOnline');
    if (!isOnline) {
      unawaited(
        LoggerService.logNetwork(
          screenName: 'ConnectivityService',
          operation: 'CheckConnectivity',
          message: 'Device is offline',
          details: results.toString(),
          level: 'WARNING',
        ),
      );
    }
    return isOnline;
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
