import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/models/room.dart';
import '../../domain/models/room_rent_status.dart';
import '../../domain/models/villa_model.dart';
import 'currency_amount_text.dart';
import 'overdue_badge.dart';

class VillaCard extends StatelessWidget {
  final VillaModel villa;
  final List<Room> rooms;
  final Map<String, double> rentReceivedByRoom;
  final VillaRentStatus? rentStatus;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const VillaCard({
    Key? key,
    required this.villa,
    this.rooms = const [],
    this.rentReceivedByRoom = const {},
    this.rentStatus,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  Iterable<Room> get _activeRooms =>
      rooms.where((room) => !room.isDeleted && room.villaId == villa.id);

  int get _occupiedRooms =>
      _activeRooms.where((room) => room.isOccupied).length;

  int get _vacantRooms => _activeRooms.where((room) => room.isVacant).length;

  double get _totalRoomRent =>
      _activeRooms.fold<double>(0, (sum, room) => sum + room.monthlyRent);

  double get _expectedRent => _activeRooms
      .where((room) => room.isOccupied)
      .fold<double>(0, (sum, room) => sum + room.monthlyRent);

  double get _collectedRent =>
      _activeRooms.where((room) => room.isOccupied).fold<double>(
            0,
            (sum, room) => sum + (rentReceivedByRoom[room.id] ?? 0),
          );

  double get _pendingRent =>
      (_expectedRent - _collectedRent).clamp(0.0, double.infinity).toDouble();

  double get _vacancyLoss => _activeRooms
      .where((room) => room.isVacant)
      .fold<double>(0, (sum, room) => sum + room.monthlyRent);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
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
                  padding: const EdgeInsets.all(8),
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
                const SizedBox(width: 10),
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
                      if (rentStatus?.hasOverdueRent ?? false) ...[
                        const SizedBox(height: 5),
                        VillaOverdueIndicator(
                          count: rentStatus!.overdueRoomCount,
                        ),
                      ],
                      const SizedBox(height: 2),
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
            const SizedBox(height: 8),
            Row(
              children: [
                _RoomChip(
                  label: 'Occupied',
                  value: _occupiedRooms,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                _RoomChip(
                  label: 'Vacant',
                  value: _vacantRooms,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
                _RoomChip(label: 'Total', value: _activeRooms.length),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Expanded(
                  child: _FinancialValue(
                    label: 'Total Room Rent',
                    value: _totalRoomRent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FinancialValue(
                    label: 'Expected Rent',
                    value: _expectedRent,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _FinancialValue(
                    label: 'Collected',
                    value: _collectedRent,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FinancialValue(
                    label: 'Pending',
                    value: _pendingRent,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FinancialValue(
                    label: 'Vacancy Loss',
                    value: _vacancyLoss,
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
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
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
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
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
  final double value;
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
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: CurrencyAmountText(
            amount: value,
            amountColor: color,
            amountFontSize: 13,
            currencyFontSize: 7,
          ),
        ),
      ],
    );
  }
}
