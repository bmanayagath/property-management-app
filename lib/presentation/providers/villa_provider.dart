import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/villa_model.dart';
import 'auth_provider.dart';
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
  ref.invalidate(allRoomsProvider);
  ref.invalidate(incomeListProvider);
  ref.invalidate(expenseListProvider);
});

final deleteVillaProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final repository = ref.watch(villaRepositoryProvider);
  final currentUser = ref.read(authProvider).currentUser;
  await repository.deleteVilla(id, deletedBy: currentUser?.id);
  if (currentUser != null) {
    await ref.read(firebaseSyncServiceProvider).queueDelete(
          collection: 'villas',
          id: id,
          userId: currentUser.id,
        );
    await ref.read(firebaseSyncServiceProvider).syncPendingDeletes();
    ref.read(syncRefreshProvider.notifier).state++;
  }
  ref.invalidate(villasProvider);
  ref.invalidate(allRoomsProvider);
  ref.invalidate(incomeListProvider);
  ref.invalidate(expenseListProvider);
});
