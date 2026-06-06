import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../models/app_log.dart';
import '../../widgets/premium_widgets.dart';

class LogDetailsScreen extends StatelessWidget {
  final AppLog log;

  const LogDetailsScreen({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    final timestamp = _formatTimestamp(log.timestamp);

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text('Log Details'),
        actions: [
          IconButton(
            onPressed: () => _copyStackTrace(context),
            icon: const Icon(Icons.copy_all_outlined),
            tooltip: 'Copy Stack Trace',
          ),
          IconButton(
            onPressed: () => _copyEntireLog(context),
            icon: const Icon(Icons.content_copy_outlined),
            tooltip: 'Copy Entire Log',
          ),
        ],
      ),
      body: ListView(
        padding: PremiumTokens.pagePadding,
        children: [
          _DetailRow(label: 'Timestamp', value: timestamp),
          _DetailRow(label: 'Category', value: log.category),
          _DetailRow(label: 'Level', value: log.level),
          _DetailRow(label: 'Screen', value: log.screenName),
          _DetailRow(label: 'Operation', value: log.operation),
          _DetailRow(label: 'Message', value: log.message),
          _DetailRow(label: 'Details', value: log.details),
          _DetailRow(
            label: 'User',
            value: [log.userEmail, log.userId]
                .where((v) => v.isNotEmpty)
                .join(' / '),
          ),
          _DetailRow(label: 'App Version', value: log.appVersion),
          _DetailRow(label: 'Platform', value: log.devicePlatform),
          const SizedBox(height: 12),
          const Text(
            'Stack Trace',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE4E7EC)),
            ),
            child: SelectableText(
              log.stackTrace.trim().isEmpty
                  ? 'No stack trace.'
                  : log.stackTrace,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyStackTrace(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: log.stackTrace));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stack trace copied.')),
    );
  }

  Future<void> _copyEntireLog(BuildContext context) async {
    final payload = {
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
    await Clipboard.setData(
      ClipboardData(text: const JsonEncoder.withIndent('  ').convert(payload)),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Log copied.')),
    );
  }

  String _formatTimestamp(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return DateFormat('dd-MMM-yyyy hh:mm a').format(parsed);
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value.trim().isEmpty ? '-' : value,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
