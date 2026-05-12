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
import '../providers/income_provider.dart';
import '../providers/room_provider.dart';
import '../providers/villa_provider.dart';
import '../widgets/villa_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/summary_card.dart';
import 'add_edit_villa_screen.dart';
import 'villa_detail_screen.dart';

class VillasScreen extends ConsumerStatefulWidget {
  const VillasScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VillasScreen> createState() => _VillasScreenState();
}

class _VillasScreenState extends ConsumerState<VillasScreen> {
  String _searchQuery = '';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Villas'),
        elevation: 0,
        actions: [
          if (canManageVillas)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                onPressed: _openAddVillaScreen,
                icon: const Icon(Icons.add),
                label: const Text('Add Villa'),
              ),
            ),
        ],
      ),
      body: villasAsync.when(
        data: (villas) => roomsAsync.when(
          data: (rooms) {
            final rentReceivedByRoom = _rentReceivedByRoom(
              incomesAsync.valueOrNull ?? const <Income>[],
              DateTime.now(),
            );
            final roomsByVilla = <String, List<Room>>{};
            for (final room in rooms) {
              roomsByVilla.putIfAbsent(room.villaId, () => []).add(room);
            }

            final filteredVillas = villas
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

            final activeRooms = rooms.where((room) => !room.isDeleted).toList();
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: 'Total Villas',
                            value: villas.length.toString(),
                            color: AppColors.primary,
                            icon: Icons.home,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryCard(
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
                          child: SummaryCard(
                            title: 'Vacant Rooms',
                            value: vacantRooms.toString(),
                            color: AppColors.warning,
                            icon: Icons.home_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryCard(
                            title: 'Total Room Rent',
                            value: CurrencyFormatter.format(totalRoomRent),
                            color: AppColors.profit,
                            icon: Icons.trending_up,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Search Bar
                    TextField(
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search villas or tenants...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Villas List - Grid Layout
                    if (filteredVillas.isEmpty)
                      EmptyState(
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
                              padding: const EdgeInsets.only(bottom: 12),
                              child: VillaCard(
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

  List<Room> _villaRooms(
    VillaModel villa,
    Map<String, List<Room>> roomsByVilla,
  ) {
    return roomsByVilla[villa.id] ?? const [];
  }

  Map<String, double> _rentReceivedByRoom(
      List<Income> incomes, DateTime month) {
    final totals = <String, double>{};
    for (final income in incomes.where(
      (income) =>
          income.incomeType.toLowerCase() == IncomeTypes.rent.toLowerCase() &&
          income.roomId.trim().isNotEmpty &&
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

  void _showDeleteConfirmation(BuildContext context, String villaId) {
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
              onPressed: () async {
                await ref.read(deleteVillaProvider(villaId).future);
                ref.invalidate(villasProvider);
                ref.invalidate(allRoomsProvider);
                ref.invalidate(dashboardSummaryProvider);
                if (!context.mounted) return;
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
