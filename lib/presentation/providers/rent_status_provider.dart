import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/rent_status_calculation_service.dart';
import '../../domain/models/income.dart';
import '../../domain/models/room.dart';
import '../../domain/models/room_rent_status.dart';
import '../../domain/models/villa_model.dart';
import 'income_provider.dart';
import 'room_provider.dart';
import 'villa_provider.dart';

final rentStatusClockProvider = StreamProvider<DateTime>((ref) {
  final controller = StreamController<DateTime>();
  Timer? timer;

  void scheduleNextDay() {
    final now = DateTime.now();
    controller.add(now);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    timer = Timer(tomorrow.difference(now), scheduleNextDay);
  }

  scheduleNextDay();
  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });

  return controller.stream;
});

final rentStatusSummaryProvider = Provider<RentStatusSummary>((ref) {
  final villas =
      ref.watch(villaListProvider).valueOrNull ?? const <VillaModel>[];
  final rooms = ref.watch(roomListProvider).valueOrNull ?? const <Room>[];
  final incomes = ref.watch(incomeListProvider).valueOrNull ?? const <Income>[];
  final now = ref.watch(rentStatusClockProvider).valueOrNull ?? DateTime.now();
  final activeRooms = activeRoomsOnly(rooms: rooms, villas: villas);

  return const RentStatusCalculationService().buildSummary(
    rooms: activeRooms,
    incomes: incomes,
    now: now,
  );
});
