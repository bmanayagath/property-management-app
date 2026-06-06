import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_roles.dart';
import '../../../data/services/logger_service.dart';
import '../../../models/app_log.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/premium_widgets.dart';
import 'log_details_screen.dart';

class DeveloperLogsScreen extends ConsumerStatefulWidget {
  const DeveloperLogsScreen({super.key});

  @override
  ConsumerState<DeveloperLogsScreen> createState() =>
      _DeveloperLogsScreenState();
}

class _DeveloperLogsScreenState extends ConsumerState<DeveloperLogsScreen> {
  final _searchController = TextEditingController();
  String? _category;
  bool _newestFirst = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).currentUser;
    if (user?.role != AppRoles.admin) {
      return const PremiumScaffold(
        body: Center(child: Text('Access denied.')),
      );
    }

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text('Developer Logs'),
        actions: [
          IconButton(
            onPressed: _exportLogs,
            icon: const Icon(Icons.ios_share_outlined),
            tooltip: 'Export Logs',
          ),
          IconButton(
            onPressed: _confirmClearLogs,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search logs',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                        tooltip: 'Clear search',
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _category == null,
                  onSelected: () => setState(() => _category = null),
                ),
                for (final category in AppLogCategory.values)
                  _FilterChip(
                    label: _titleCase(category),
                    selected: _category == category,
                    onSelected: () => setState(() => _category = category),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.sort_outlined, size: 20),
                const SizedBox(width: 8),
                DropdownButton<bool>(
                  value: _newestFirst,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(
                      value: true,
                      child: Text('Newest First'),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text('Oldest First'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _newestFirst = value);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AppLog>>(
              stream: LoggerService.watchLogs(
                search: _searchController.text,
                category: _category,
                newestFirst: _newestFirst,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final logs = snapshot.data ?? const [];
                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: logs.isEmpty
                      ? ListView(
                          padding: PremiumTokens.pagePadding,
                          children: const [
                            SizedBox(height: 180),
                            Center(child: Text('No logs found.')),
                          ],
                        )
                      : ListView.separated(
                          padding: PremiumTokens.pagePadding,
                          itemCount: logs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return _LogCard(log: logs[index]);
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear logs?'),
          content: const Text('This removes all local developer logs.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear Logs'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await LoggerService.clearLogs();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs cleared.')),
    );
  }

  Future<void> _exportLogs() async {
    try {
      await LoggerService.exportLogs(
        search: _searchController.text,
        category: _category,
        newestFirst: _newestFirst,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $error')),
      );
    }
  }

  static String _titleCase(String value) {
    final lower = value.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final AppLog log;

  const _LogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final timestamp = _formatTimestamp(log.timestamp);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogDetailsScreen(log: log),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CategoryBadge(category: log.category),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      log.operation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF101828),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                log.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (log.details.trim().isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  log.details,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      log.screenName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF475467),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    timestamp,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return DateFormat('dd-MMM-yyyy hh:mm a').format(parsed);
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case AppLogCategory.info:
        return const Color(0xFF2563EB);
      case AppLogCategory.warning:
        return const Color(0xFFF97316);
      case AppLogCategory.error:
        return const Color(0xFFDC2626);
      case AppLogCategory.sync:
        return const Color(0xFF7C3AED);
      case AppLogCategory.upload:
        return const Color(0xFF059669);
      case AppLogCategory.firebase:
        return const Color(0xFFD97706);
      case AppLogCategory.auth:
        return const Color(0xFF0891B2);
      case AppLogCategory.network:
      default:
        return const Color(0xFF667085);
    }
  }
}
