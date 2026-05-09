import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/room.dart';
import '../../domain/models/villa_model.dart';

class VillaCard extends StatelessWidget {
  final VillaModel villa;
  final List<Room> rooms;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const VillaCard({
    Key? key,
    required this.villa,
    this.rooms = const [],
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  bool get _hasOccupiedRoom => rooms.any((room) => room.isOccupied);

  double get _totalMonthlyRent =>
      rooms.fold<double>(0, (sum, room) => sum + room.monthlyRent);

  String get _statusLabel => _hasOccupiedRoom ? 'Occupied' : 'Vacant';

  Color get _statusColor =>
      _hasOccupiedRoom ? AppColors.success : AppColors.warning;

  String get _tenantSummary {
    final tenants = rooms
        .where((room) => room.isOccupied && room.tenantName.trim().isNotEmpty)
        .map((room) => room.tenantName.trim())
        .toSet()
        .toList();

    if (tenants.isEmpty) return 'No tenant';
    if (tenants.length == 1) return tenants.first;
    return '${tenants.length} tenants';
  }

  String get _roomSummary {
    if (rooms.isEmpty) return 'No rooms';
    final occupiedCount = rooms.where((room) => room.isOccupied).length;
    return '${rooms.length} room${rooms.length == 1 ? '' : 's'}'
        ' / $occupiedCount occupied';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.home_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    villa.villaName,
                    style: const TextStyle(
                      color: Color(0xFF060B26),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 2,
                    children: [
                      Text(
                        villa.location,
                        style: const TextStyle(
                          color: Color(0xFF646B7A),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _tenantSummary,
                        style: const TextStyle(
                          color: Color(0xFF646B7A),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _roomSummary,
                        style: const TextStyle(
                          color: Color(0xFF646B7A),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                _statusLabel,
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              CurrencyFormatter.format(_totalMonthlyRent),
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Delete villa',
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints.tightFor(width: 30, height: 30),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
