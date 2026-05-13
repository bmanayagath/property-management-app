import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/villa_model.dart';
import 'auth_provider.dart';
import 'dashboard_provider.dart';
import 'expense_provider.dart';
import 'income_provider.dart';
import 'repository_provider.dart';
import 'room_provider.dart';
import 'sync_provider.dart';

final villasProvider = StreamProvider<List<VillaModel>>((ref) {
  final repository = ref.watch(villaRepositoryProvider);
  return repository.watchActiveVillas();
});

final villaListProvider = villasProvider;
final activeVillaListProvider = villaListProvider;

final villaByIdProvider =
    FutureProvider.family<VillaModel?, String>((ref, id) async {
  final repository = ref.watch(villaRepositoryProvider);
  return repository.getVillaById(id);
});

final addVillaProvider =
    FutureProvider.family<String, VillaModel>((ref, villa) async {
  final repository = ref.watch(villaRepositoryProvider);
  final id = await repository.addVilla(villa);
  final currentUser = ref.read(authProvider).currentUser;
  if (currentUser != null) {
    await ref.read(firebaseSyncServiceProvider).queueVilla(
          villa: villa.copyWith(id: id),
          userId: currentUser.id,
        );
    ref.read(syncRefreshProvider.notifier).state++;
  }
  ref.invalidate(villasProvider);
  ref.invalidate(villaListProvider);
  ref.invalidate(activeVillaListProvider);
  ref.invalidate(roomListProvider);
  ref.invalidate(activeRoomListProvider);
  ref.invalidate(dashboardSummaryProvider);
  return id;
});

final updateVillaProvider =
    FutureProvider.family<void, VillaModel>((ref, villa) async {
  final repository = ref.watch(villaRepositoryProvider);
  await repository.updateVilla(villa);
  final currentUser = ref.read(authProvider).currentUser;
  if (currentUser != null) {
    await ref.read(firebaseSyncServiceProvider).queueVilla(
          villa: villa,
          userId: currentUser.id,
        );
    ref.read(syncRefreshProvider.notifier).state++;
  }
  ref.invalidate(villasProvider);
  ref.invalidate(villaListProvider);
  ref.invalidate(activeVillaListProvider);
  ref.invalidate(allRoomsProvider);
  ref.invalidate(roomListProvider);
  ref.invalidate(activeRoomListProvider);
  ref.invalidate(incomeListProvider);
  ref.invalidate(expenseListProvider);
  ref.invalidate(dashboardSummaryProvider);
});

final deleteVillaProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final repository = ref.watch(villaRepositoryProvider);
  final currentUser = ref.read(authProvider).currentUser;
  if (currentUser == null) {
    await repository.deleteVilla(id);
  } else {
    await repository.deleteVillaCascade(id, currentUser.id);
  }
  if (currentUser != null) {
    await ref.read(firebaseSyncServiceProvider).syncPendingDeletes();
    ref.read(syncRefreshProvider.notifier).state++;
  }
  ref.invalidate(villasProvider);
  ref.invalidate(villaListProvider);
  ref.invalidate(activeVillaListProvider);
  ref.invalidate(allRoomsProvider);
  ref.invalidate(roomListProvider);
  ref.invalidate(activeRoomListProvider);
  ref.invalidate(incomeListProvider);
  ref.invalidate(expenseListProvider);
  ref.invalidate(expenseProvider);
  ref.invalidate(dashboardSummaryProvider);
  ref.invalidate(occupiedRoomsProvider);
  ref.invalidate(vacantRoomsProvider);
  ref.invalidate(totalExpectedRentProvider);
});
