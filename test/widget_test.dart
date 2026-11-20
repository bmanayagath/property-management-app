import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:villabooks/core/startup/startup_status.dart';
import 'package:villabooks/main.dart';
import 'package:villabooks/domain/models/app_user.dart';
import 'package:villabooks/presentation/providers/auth_provider.dart';
import 'package:villabooks/presentation/providers/expense_provider.dart';
import 'package:villabooks/presentation/providers/income_provider.dart';
import 'package:villabooks/presentation/providers/navigation_provider.dart';
import 'package:villabooks/presentation/providers/notification_provider.dart';
import 'package:villabooks/presentation/providers/room_provider.dart';
import 'package:villabooks/presentation/providers/rent_status_provider.dart';
import 'package:villabooks/presentation/providers/villa_provider.dart';
import 'package:villabooks/presentation/screens/villas_screen.dart';
import 'package:villabooks/presentation/screens/income/income_screen.dart';
import 'package:villabooks/presentation/screens/expenses_screen.dart';
import 'package:villabooks/presentation/screens/settings/settings_screen.dart';

void main() {
  testWidgets('VillaBooks shows login screen when signed out', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          startupStatusProvider.overrideWithValue(
            const StartupStatus(firebaseInitialized: false),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('VillaBooks'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('tabs build on first visit and retain their state',
      (tester) async {
    final container = ProviderContainer(overrides: [
      authProvider.overrideWith((ref) => _SignedInNotifier(ref)),
      villasProvider.overrideWith((ref) => Stream.value([])),
      allRoomsProvider.overrideWith((ref) => Stream.value([])),
      incomeListProvider.overrideWith((ref) => Stream.value([])),
      expenseListProvider.overrideWith((ref) => Stream.value([])),
      rentStatusClockProvider.overrideWith((ref) => Stream.value(DateTime(2026))),
      unreadNotificationCountProvider.overrideWith((ref) => const AsyncData(0)),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: MainScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(VillasScreen, skipOffstage: false), findsNothing);
    expect(find.byType(IncomeScreen, skipOffstage: false), findsNothing);
    expect(find.byType(ExpensesScreen, skipOffstage: false), findsNothing);
    expect(find.byType(SettingsScreen, skipOffstage: false), findsNothing);

    container.read(selectedTabProvider.notifier).state = 1;
    await tester.pumpAndSettle();
    final villasState = tester.state(find.byType(VillasScreen));
    container.read(selectedTabProvider.notifier).state = 0;
    await tester.pumpAndSettle();
    container.read(selectedTabProvider.notifier).state = 1;
    await tester.pumpAndSettle();
    expect(tester.state(find.byType(VillasScreen)), same(villasState));
    expect(find.byType(SettingsScreen, skipOffstage: false), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
  });
}

class _SignedInNotifier extends AuthNotifier {
  _SignedInNotifier(Ref ref)
      : super(ref: ref, service: null, startupStatus: const StartupStatus()) {
    state = AuthState.ready(
      users: const [],
      currentUser: AppUser(
        id: 'reader',
        username: 'reader@example.com',
        role: 'Reader',
        createdAt: DateTime(2026),
      ),
    );
  }
}
