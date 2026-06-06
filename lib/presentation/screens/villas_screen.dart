import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/constants/app_permissions.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/income.dart';
import '../../domain/models/room.dart';
import '../../domain/models/villa_model.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/database_provider.dart';
import '../providers/income_provider.dart';
import '../providers/room_provider.dart';
import '../providers/villa_provider.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/villa_summary_card.dart';
import 'add_edit_villa_screen.dart';
import 'villa_detail_screen.dart';

class VillasScreen extends ConsumerStatefulWidget {
  const VillasScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VillasScreen> createState() => _VillasScreenState();
}

class _VillasScreenState extends ConsumerState<VillasScreen> {
  String _searchQuery = '';
  bool _hasLoggedRoomSummary = false;

  @override
  Widget build(BuildContext context) {
    final villasAsync = ref.watch(villasProvider);
    final roomsAsync = ref.watch(allRoomsProvider);
    final incomesAsync = ref.watch(incomeListProvider);
    final authState = ref.watch(authProvider);
    final canManageVillas =
        authState.hasPermission(AppPermissions.manageVillas);
    final canDeleteVillas = canManageVillas &&
        authState.hasPermission(AppPermissions.deleteRecords);

    return PremiumScaffold(
      body: villasAsync.when(
        data: (villas) => roomsAsync.when(
          data: (rooms) {
            final activeVillas = villas;
            final activeRooms = activeRoomsOnly(
              rooms: rooms,
              villas: activeVillas,
            );
            _logRoomSummaryOnce(
              rawRoomsFromProvider: rooms,
              activeRooms: activeRooms,
              activeVillas: activeVillas,
            );
            final rentReceivedByRoom = _rentReceivedByRoom(
              incomesAsync.valueOrNull ?? const <Income>[],
              DateTime.now(),
              activeRoomIds: activeRooms.map((room) => room.id).toSet(),
            );
            final roomsByVilla = <String, List<Room>>{};
            for (final room in activeRooms) {
              roomsByVilla.putIfAbsent(room.villaId, () => []).add(room);
            }

            final filteredVillas = activeVillas
                .where((villa) =>
                    villa.villaName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    _villaRooms(villa, roomsByVilla).any(
                      (room) =>
                          room.tenantName
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          room.roomName
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()),
                    ))
                .toList();

            final occupiedRooms =
                activeRooms.where((room) => room.isOccupied).length;
            final vacantRooms =
                activeRooms.where((room) => room.isVacant).length;
            final totalRoomRent = activeRooms.fold<double>(
              0,
              (sum, room) => sum + room.monthlyRent,
            );

            return SingleChildScrollView(
              child: Padding(
                padding: PremiumTokens.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PremiumPageHeader(
                      title: 'Villas',
                      subtitle: 'Homes, rooms, tenants, and rent at a glance',
                      actions: [
                        if (canManageVillas)
                          PremiumButton(
                            onPressed: _openAddVillaScreen,
                            icon: Icons.add_rounded,
                            label: 'Add Villa',
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: SoftStatCard(
                            title: 'Total Villas',
                            value: activeVillas.length.toString(),
                            color: AppColors.primary,
                            icon: Icons.home,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SoftStatCard(
                            title: 'Occupied Rooms',
                            value: occupiedRooms.toString(),
                            color: AppColors.success,
                            icon: Icons.check_circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SoftStatCard(
                            title: 'Vacant Rooms',
                            value: vacantRooms.toString(),
                            color: AppColors.warning,
                            icon: Icons.home_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SoftStatCard(
                            title: 'Total Room Rent',
                            value: CurrencyFormatter.format(totalRoomRent),
                            color: AppColors.profit,
                            icon: Icons.trending_up,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    PremiumSearchBar(
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      hintText: 'Search villas or tenants...',
                      value: _searchQuery,
                      onClear: () => setState(() => _searchQuery = ''),
                    ),
                    const SizedBox(height: 24),

                    // Villas List - Grid Layout
                    if (filteredVillas.isEmpty)
                      EmptyStateCard(
                        icon: Icons.home_outlined,
                        title:
                            _searchQuery.isEmpty ? 'No Villas' : 'No Results',
                        subtitle: _searchQuery.isEmpty
                            ? 'Create your first villa to get started'
                            : 'Try a different search term',
                      )
                    else
                      Column(
                        children: List.generate(
                          filteredVillas.length,
                          (index) {
                            final villa = filteredVillas[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: VillaSummaryCard(
                                villa: villa,
                                rooms: _villaRooms(villa, roomsByVilla),
                                rentReceivedByRoom: rentReceivedByRoom,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => VillaDetailScreen(
                                        villaId: villa.id,
                                      ),
                                    ),
                                  );
                                },
                                onEdit: canManageVillas
                                    ? () => _openEditVillaScreen(villa)
                                    : null,
                                onDelete: canDeleteVillas
                                    ? () {
                                        _showDeleteConfirmation(
                                          context,
                                          villa.id,
                                        );
                                      }
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
          error: (error, stack) => _ErrorView(error: error),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
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
                'Error loading villas',
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
      floatingActionButton: canManageVillas
          ? FloatingActionButton(
              heroTag: 'add-villa-fab',
              onPressed: _openAddVillaScreen,
              tooltip: 'Add Villa',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _openAddVillaScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditVillaScreen(),
      ),
    );
  }

  void _openEditVillaScreen(VillaModel villa) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditVillaScreen(villa: villa),
      ),
    );
  }

  List<Room> _villaRooms(
    VillaModel villa,
    Map<String, List<Room>> roomsByVilla,
  ) {
    return roomsByVilla[villa.id] ?? const [];
  }

  Map<String, double> _rentReceivedByRoom(
    List<Income> incomes,
    DateTime month, {
    required Set<String> activeRoomIds,
  }) {
    final totals = <String, double>{};
    for (final income in incomes.where(
      (income) =>
          !income.isDeleted &&
          income.incomeType.toLowerCase() == IncomeTypes.rent.toLowerCase() &&
          income.roomId.trim().isNotEmpty &&
          activeRoomIds.contains(income.roomId) &&
          income.monthCovered.year == month.year &&
          income.monthCovered.month == month.month,
    )) {
      totals.update(
        income.roomId,
        (value) => value + income.amount,
        ifAbsent: () => income.amount,
      );
    }
    return totals;
  }

  void _logRoomSummaryOnce({
    required List<Room> rawRoomsFromProvider,
    required List<Room> activeRooms,
    required List<VillaModel> activeVillas,
  }) {
    if (_hasLoggedRoomSummary) return;
    _hasLoggedRoomSummary = true;

    Future.microtask(() async {
      final database = ref.read(databaseProvider);
      final rawVillaCount = await database.getRawVillaCount();
      final activeVillaCount = await database.getActiveVillaCount();
      final rawRoomCount = await database.getRawRoomCount();
      final activeRoomCount = await database.getActiveRoomCount();
      final orphanRoomCount = await database.getOrphanRoomCount();
      final deletedRoomCount = await database.getDeletedRoomCount();

      debugPrint('[VillasScreen] total villas raw=$rawVillaCount');
      debugPrint('[VillasScreen] active villas=$activeVillaCount');
      debugPrint('[VillasScreen] total rooms raw=$rawRoomCount');
      debugPrint('[VillasScreen] active rooms=$activeRoomCount');
      debugPrint('[VillasScreen] orphan rooms count=$orphanRoomCount');
      debugPrint('[VillasScreen] deleted rooms count=$deletedRoomCount');
      debugPrint(
        '[VillasScreen] provider active villas=${activeVillas.length}, '
        'provider rooms=${rawRoomsFromProvider.length}, '
        'ui active rooms=${activeRooms.length}',
      );
    });
  }

  void _showDeleteConfirmation(BuildContext context, String villaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Villa?'),
          content: const Text(
            'Deleting this villa will also remove all rooms, income, and expenses linked to it from active records. This action will sync to other devices. Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await ref.read(deleteVillaProvider(villaId).future);
                ref.invalidate(villasProvider);
                ref.invalidate(allRoomsProvider);
                ref.invalidate(dashboardSummaryProvider);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text(
                'Delete Villa',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
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
            'Error loading rooms',
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
    );
  }
}
