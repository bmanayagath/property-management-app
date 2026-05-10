import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/room.dart';
import '../../domain/models/villa_model.dart';

class VillaCard extends StatelessWidget {
  final VillaModel villa;
  final List<Room> rooms;
  final Map<String, double> rentReceivedByRoom;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const VillaCard({
    Key? key,
    required this.villa,
    this.rooms = const [],
    this.rentReceivedByRoom = const {},
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  int get _occupiedRooms => rooms.where((room) => room.isOccupied).length;

  int get _vacantRooms => rooms.where((room) => room.isVacant).length;

  double get _expectedRent => rooms
      .where((room) => room.isOccupied)
      .fold<double>(0, (sum, room) => sum + room.monthlyRent);

  double get _collectedRent => rooms.fold<double>(
        0,
        (sum, room) => sum + (rentReceivedByRoom[room.id] ?? 0),
      );

  double get _pendingRent =>
      (_expectedRent - _collectedRent).clamp(0.0, double.infinity).toDouble();

  double get _vacancyLoss => rooms
      .where((room) => room.isVacant)
      .fold<double>(0, (sum, room) => sum + room.monthlyRent);

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
        child: Column(
          children: [
            Row(
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        villa.location,
                        style: const TextStyle(
                          color: Color(0xFF646B7A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.meeting_room_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF89909E),
                      size: 24,
                    ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 4),
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
                        constraints: const BoxConstraints.tightFor(
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _RoomChip(label: 'Total', value: rooms.length),
                const SizedBox(width: 8),
                _RoomChip(
                  label: 'Occupied',
                  value: _occupiedRooms,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _RoomChip(
                  label: 'Vacant',
                  value: _vacantRooms,
                  color: AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _FinancialValue(
                    label: 'Expected',
                    value: CurrencyFormatter.format(_expectedRent),
                  ),
                ),
                Expanded(
                  child: _FinancialValue(
                    label: 'Collected',
                    value: CurrencyFormatter.format(_collectedRent),
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _FinancialValue(
                    label: 'Pending',
                    value: CurrencyFormatter.format(_pendingRent),
                    color: AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _FinancialValue(
                    label: 'Vacancy Loss',
                    value: CurrencyFormatter.format(_vacancyLoss),
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _RoomChip({
    required this.label,
    required this.value,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialValue extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _FinancialValue({
    required this.label,
    required this.value,
    this.color = const Color(0xFF060B26),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
