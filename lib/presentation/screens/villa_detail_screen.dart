import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/app_permissions.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/villa_model.dart';
import '../providers/auth_provider.dart';
import '../providers/villa_provider.dart';
import '../providers/room_provider.dart';
import '../widgets/room_card.dart';
import 'add_edit_villa_screen.dart';
import 'add_edit_room_screen.dart';

class VillaDetailScreen extends ConsumerWidget {
  final String villaId;

  const VillaDetailScreen({
    Key? key,
    required this.villaId,
  }) : super(key: key);

  Color _getStatusColor(VillaStatus status) {
    switch (status) {
      case VillaStatus.occupied:
        return AppColors.success;
      case VillaStatus.vacant:
        return AppColors.warning;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Villa?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(deleteVillaProvider(villaId));
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final villaAsync = ref.watch(villaByIdProvider(villaId));
    final authState = ref.watch(authProvider);
    final canManageVillas =
        authState.hasPermission(AppPermissions.manageVillas);
    final canDeleteVillas = canManageVillas &&
        authState.hasPermission(AppPermissions.deleteRecords);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Villa Details'),
        elevation: 0,
      ),
      body: villaAsync.when(
        data: (villa) {
          if (villa == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: 48,
                    color: AppColors.border,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Villa not found',
                    style: AppStyles.titleMedium,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card with Villa Name and Status
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    villa.villaName,
                                    style: AppStyles.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Villa # ${villa.villaNumber}',
                                    style: AppStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(villa.status)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                villa.status.displayName,
                                style: AppStyles.labelMedium.copyWith(
                                  color: _getStatusColor(villa.status),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                villa.location,
                                style: AppStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Rooms Summary Card
                  _buildRoomsSummary(context, ref, villa.id),
                  const SizedBox(height: 24),

                  // Rooms List
                  _buildRoomsList(context, ref, villa.id, canManageVillas),
                  const SizedBox(height: 24),

                  if (canManageVillas) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddEditVillaScreen(villa: villa),
                            ),
                          ).then((_) {
                            ref.invalidate(villaByIdProvider);
                          });
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Villa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (canDeleteVillas)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showDeleteConfirmation(context, ref),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete Villa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.error.withValues(alpha: 0.1),
                          foregroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading villa',
                style: AppStyles.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildRoomsSummary(
      BuildContext context, WidgetRef ref, String villaId) {
    final roomsAsync = ref.watch(roomsByVillaProvider(villaId));
    
    return roomsAsync.when(
      data: (rooms) {
        final occupiedCount = rooms.where((r) => r.isOccupied).length;
        final vacantCount = rooms.where((r) => r.isVacant).length;
        final expectedRent = rooms
            .where((r) => r.isOccupied)
            .fold<double>(0, (sum, r) => sum + r.monthlyRent);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room Summary',
              style: AppStyles.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Rooms',
                          style: AppStyles.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rooms.length.toString(),
                          style: AppStyles.headlineSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Occupied',
                          style: AppStyles.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          occupiedCount.toString(),
                          style: AppStyles.headlineSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vacant',
                          style: AppStyles.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vacantCount.toString(),
                          style: AppStyles.headlineSmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expected Rent',
                          style: AppStyles.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(expectedRent),
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error loading rooms: $error'),
    );
  }

  Widget _buildRoomsList(
      BuildContext context, WidgetRef ref, String villaId, bool canManageVillas) {
    final roomsAsync = ref.watch(watchRoomsByVillaProvider(villaId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rooms',
              style: AppStyles.titleMedium,
            ),
            if (canManageVillas)
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditRoomScreen(villaId: villaId),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Room'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        roomsAsync.when(
          data: (rooms) {
            if (rooms.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.meeting_room_outlined,
                        size: 48,
                        color: AppColors.border,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No rooms added yet',
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (canManageVillas) ...[
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddEditRoomScreen(villaId: villaId),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Room'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return RoomCard(
                  room: room,
                  onTap: () {
                    // Can add room detail screen later
                  },
                  onEdit: canManageVillas
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddEditRoomScreen(room: room, villaId: villaId),
                            ),
                          );
                        }
                      : null,
                  onDelete: canManageVillas
                      ? () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Room?'),
                              content: const Text('This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref.read(deleteRoomProvider(room.id));
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      : null,
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error loading rooms: $error'),
        ),
      ],
    );
  }
}
