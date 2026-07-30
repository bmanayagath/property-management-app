import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_permissions.dart';
import '../../domain/models/room_rent_status.dart';
import '../providers/auth_provider.dart';
import '../providers/rent_status_provider.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/room_card.dart';
import 'room_detail_screen.dart';

class RoomRentStatusScreen extends ConsumerStatefulWidget {
  final RoomRentFilter initialFilter;
  final DateTime? month;

  const RoomRentStatusScreen({
    super.key,
    this.initialFilter = RoomRentFilter.overdue,
    this.month,
  });

  @override
  ConsumerState<RoomRentStatusScreen> createState() =>
      _RoomRentStatusScreenState();
}

class _RoomRentStatusScreenState extends ConsumerState<RoomRentStatusScreen> {
  late RoomRentFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.month == null
        ? ref.watch(rentStatusSummaryProvider)
        : ref.watch(rentStatusSummaryForMonthProvider(widget.month!));
    final rooms = summary.filtered(_filter);
    final canManage =
        ref.watch(authProvider).hasPermission(AppPermissions.manageVillas);

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text('Room Rent Status'),
        elevation: 0,
      ),
      body: ListView(
        padding: PremiumTokens.pagePadding,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overdue Rent',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${summary.overdueRoomCount} rooms across '
                        '${summary.overdueVillaCount} villas',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: RoomRentFilter.values.map((filter) {
                final selected = filter == _filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter.label),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = filter),
                    selectedColor: filter == RoomRentFilter.overdue
                        ? AppColors.error.withValues(alpha: 0.13)
                        : AppColors.primary.withValues(alpha: 0.12),
                    labelStyle: TextStyle(
                      color: selected && filter == RoomRentFilter.overdue
                          ? AppColors.error
                          : selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (rooms.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(
                    _filter == RoomRentFilter.overdue
                        ? Icons.check_circle_outline_rounded
                        : Icons.meeting_room_outlined,
                    color: _filter == RoomRentFilter.overdue
                        ? AppColors.success
                        : AppColors.textSecondary,
                    size: 42,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _filter == RoomRentFilter.overdue
                        ? 'No overdue rooms'
                        : 'No ${_filter.label.toLowerCase()} rooms found',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            )
          else
            ...rooms.map((status) {
              final room = status.room;
              return RoomCard(
                room: room,
                pendingRent:
                    room.isOccupied ? status.pendingRent : room.monthlyRent,
                pendingRentLabel:
                    room.isOccupied ? 'Pending' : 'Potential Loss',
                isOverdue: status.isOverdue,
                showVillaName: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RoomDetailScreen(
                      room: room,
                      canManage: canManage,
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
