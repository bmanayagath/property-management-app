import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/models/room.dart';
import '../../domain/models/villa_model.dart';
import 'premium_widgets.dart';
import 'currency_amount_text.dart';

class VillaSummaryCard extends StatelessWidget {
  final VillaModel villa;
  final List<Room> rooms;
  final Map<String, double> rentReceivedByRoom;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VillaSummaryCard({
    super.key,
    required this.villa,
    this.rooms = const [],
    this.rentReceivedByRoom = const {},
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  Iterable<Room> get _activeRooms {
    return rooms.where((room) => !room.isDeleted && room.villaId == villa.id);
  }

  int get _totalRooms => _activeRooms.length;

  int get _occupiedRooms {
    return _activeRooms.where((room) => room.isOccupied).length;
  }

  int get _vacantRooms => _activeRooms.where((room) => room.isVacant).length;

  double get _totalRoomRent {
    return _activeRooms.fold<double>(0, (sum, room) => sum + room.monthlyRent);
  }

  double get _expectedRent {
    return _activeRooms
        .where((room) => room.isOccupied)
        .fold<double>(0, (sum, room) => sum + room.monthlyRent);
  }

  double get _collectedRent {
    return _activeRooms.where((room) => room.isOccupied).fold<double>(
          0,
          (sum, room) => sum + (rentReceivedByRoom[room.id] ?? 0),
        );
  }

  double get _pendingRent {
    return (_expectedRent - _collectedRent)
        .clamp(0.0, double.infinity)
        .toDouble();
  }

  double get _vacancyLoss {
    return _activeRooms
        .where((room) => room.isVacant)
        .fold<double>(0, (sum, room) => sum + room.monthlyRent);
  }

  _DepositSummary get _depositSummary {
    return _DepositSummary.fromRooms(_activeRooms);
  }

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      PremiumTokens.glowLavender,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.villa_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      villa.villaName.trim().isEmpty
                          ? 'Villa'
                          : villa.villaName.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: PremiumTokens.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: PremiumTokens.muted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            villa.location.trim().isEmpty
                                ? 'No location'
                                : villa.location.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: PremiumTokens.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onEdit != null) ...[
                RoundedActionButton(
                  onPressed: onEdit,
                  icon: Icons.edit_rounded,
                  filled: false,
                  tooltip: 'Edit villa',
                ),
                const SizedBox(width: 6),
              ],
              if (onDelete != null)
                PopupMenuButton<String>(
                  tooltip: 'More',
                  icon: const Icon(Icons.more_horiz_rounded),
                  onSelected: (value) {
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                            size: 19,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Occupancy',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: PremiumTokens.muted,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Text(
                '$_occupiedRooms / $_totalRooms rooms',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: PremiumTokens.ink,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _OccupancyLine(hasOccupiedRooms: _occupiedRooms > 0),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RoomPill(
                label: 'Occupied',
                value: _occupiedRooms.toString(),
                color: AppColors.success,
              ),
              _RoomPill(
                label: 'Vacant',
                value: _vacantRooms.toString(),
                color: AppColors.warning,
              ),
              _RoomPill(
                label: 'Total',
                value: _totalRooms.toString(),
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 15),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 350;
              final firstRow = [
                _MoneyMetric(
                  label: 'Total Room Rent',
                  value: _totalRoomRent,
                  color: PremiumTokens.ink,
                ),
                _MoneyMetric(
                  label: 'Expected Rent',
                  value: _expectedRent,
                  color: AppColors.primary,
                ),
              ];
              final secondRow = [
                _MoneyMetric(
                  label: 'Collected',
                  value: _collectedRent,
                  color: AppColors.success,
                ),
                _MoneyMetric(
                  label: 'Pending',
                  value: _pendingRent,
                  color: AppColors.warning,
                ),
                _MoneyMetric(
                  label: 'Vacancy Loss',
                  value: _vacancyLoss,
                  color: AppColors.error,
                ),
              ];
              final depositSummary = _depositSummary;
              final depositRow = [
                _MoneyMetric(
                  label: 'Deposit Collected',
                  value: depositSummary.totalCollected,
                  color: AppColors.primary,
                ),
                _MoneyMetric(
                  label: 'Held',
                  value: depositSummary.totalHeld,
                  color: AppColors.success,
                ),
                _MoneyMetric(
                  label: 'Refunded',
                  value: depositSummary.totalRefunded,
                  color: AppColors.warning,
                ),
                _MoneyMetric(
                  label: 'Forfeited',
                  value: depositSummary.totalForfeited,
                  color: AppColors.error,
                ),
              ];

              if (isNarrow) {
                return Column(
                  children: [
                    for (final metric in [
                      ...firstRow,
                      ...secondRow,
                      ...depositRow,
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: metric,
                      ),
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: firstRow[0]),
                      const SizedBox(width: 10),
                      Expanded(child: firstRow[1]),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: secondRow[0]),
                      const SizedBox(width: 10),
                      Expanded(child: secondRow[1]),
                      const SizedBox(width: 10),
                      Expanded(child: secondRow[2]),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: depositRow[0]),
                      const SizedBox(width: 10),
                      Expanded(child: depositRow[1]),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: depositRow[2]),
                      const SizedBox(width: 10),
                      Expanded(child: depositRow[3]),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DepositSummary {
  final double totalCollected;
  final double totalHeld;
  final double totalRefunded;
  final double totalForfeited;

  const _DepositSummary({
    required this.totalCollected,
    required this.totalHeld,
    required this.totalRefunded,
    required this.totalForfeited,
  });

  factory _DepositSummary.fromRooms(Iterable<Room> rooms) {
    var collected = 0.0;
    var held = 0.0;
    var refunded = 0.0;
    var forfeited = 0.0;

    for (final room in rooms) {
      if (room.depositType != DepositTypes.none) {
        collected += room.depositAmount;
      }
      if (room.depositStatus == DepositStatuses.held) {
        held += room.depositAmount;
      }
      if (room.depositStatus == DepositStatuses.refunded ||
          room.depositStatus == DepositStatuses.partiallyRefunded) {
        refunded += room.refundAmount;
      }
      if (room.depositStatus == DepositStatuses.forfeited ||
          room.depositStatus == DepositStatuses.partiallyRefunded) {
        forfeited += room.retainedAmount;
      }
    }

    return _DepositSummary(
      totalCollected: collected,
      totalHeld: held,
      totalRefunded: refunded,
      totalForfeited: forfeited,
    );
  }
}

class _OccupancyLine extends StatelessWidget {
  final bool hasOccupiedRooms;

  const _OccupancyLine({
    required this.hasOccupiedRooms,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      width: double.infinity,
      decoration: BoxDecoration(
        color: hasOccupiedRooms ? AppColors.success : AppColors.border,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _RoomPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _RoomPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyMetric extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MoneyMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PremiumTokens.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: PremiumTokens.muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: CurrencyAmountText(
              amount: value,
              amountColor: color,
              amountFontSize: 13,
              currencyFontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}
