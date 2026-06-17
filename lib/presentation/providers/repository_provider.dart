import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/villa_repository_impl.dart';
import '../../data/repositories/room_repository_impl.dart';
import '../../data/repositories/income_repository_impl.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../data/repositories/local_database_repository.dart';
import '../../domain/repositories/villa_repository.dart';
import '../../domain/repositories/room_repository.dart';
import '../../domain/repositories/income_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import 'active_org_provider.dart';
import 'database_provider.dart';

final villaRepositoryProvider = Provider<VillaRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final orgId = ref.watch(activeOrgProvider);
  return VillaRepositoryImpl(database, orgId: orgId);
});

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final orgId = ref.watch(activeOrgProvider);
  return RoomRepositoryImpl(database, orgId: orgId);
});

final incomeRepositoryProvider = Provider<IncomeRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final orgId = ref.watch(activeOrgProvider);
  return IncomeRepositoryImpl(database, orgId: orgId);
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final orgId = ref.watch(activeOrgProvider);
  return ExpenseRepositoryImpl(database, orgId: orgId);
});

final localDatabaseRepositoryProvider =
    Provider<LocalDatabaseRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return LocalDatabaseRepository(database);
});
