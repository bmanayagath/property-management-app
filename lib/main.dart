import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/app_permissions.dart';
import 'core/constants/app_roles.dart';
import 'core/startup/startup_status.dart';
import 'core/theme/app_theme.dart';
import 'data/local/database.dart';
import 'data/services/logger_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/database_provider.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/auth/choose_organization_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/animated_splash_screen.dart';
import 'presentation/screens/expenses_screen.dart';
import 'presentation/screens/income/income_screen.dart';
import 'presentation/screens/reports/reports_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/super_admin/super_admin_dashboard_screen.dart';
import 'presentation/screens/villas_screen.dart';
import 'presentation/providers/navigation_provider.dart';
import 'presentation/widgets/premium_widgets.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final database = AppDatabase();
    LoggerService.initialize(database);
    final startupStatus = await _initializeStartup();

    runApp(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          startupStatusProvider.overrideWithValue(startupStatus),
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stackTrace) {
    debugPrint('[Startup] Unhandled async error: $error');
    debugPrintStack(stackTrace: stackTrace);
    unawaited(
      LoggerService.logError(
        screenName: 'Startup',
        operation: 'runZonedGuarded',
        message: 'Unhandled async error',
        details: error.toString(),
        stackTrace: stackTrace.toString(),
      ),
    );
  });
}

Future<StartupStatus> _initializeStartup() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('[Startup] Flutter error: ${details.exceptionAsString()}');
    debugPrintStack(stackTrace: details.stack);
    unawaited(
      LoggerService.logError(
        screenName: 'FlutterError',
        operation: 'FlutterError.onError',
        message: details.exceptionAsString(),
        details: details.library ?? '',
        stackTrace: details.stack?.toString() ?? '',
      ),
    );
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    debugPrint('[Startup] Platform error: $error');
    debugPrintStack(stackTrace: stackTrace);
    unawaited(
      LoggerService.logError(
        screenName: 'PlatformDispatcher',
        operation: 'PlatformDispatcher.onError',
        message: 'Unhandled platform error',
        details: error.toString(),
        stackTrace: stackTrace.toString(),
      ),
    );
    return true;
  };

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    debugPrint('[Startup] Firebase initialized successfully.');
    debugPrint('[Startup] Firebase apps: ${Firebase.apps.length}');
    unawaited(
      LoggerService.logFirebase(
        screenName: 'Startup',
        operation: 'FirebaseInitialize',
        message: 'Firebase initialized successfully.',
        level: 'INFO',
      ),
    );
    return const StartupStatus(firebaseInitialized: true);
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      debugPrint('[Startup] Firebase app already exists, continuing.');
      return const StartupStatus(firebaseInitialized: true);
    }
    debugPrint('[Startup] Firebase initialization failed: $e');
    debugPrintStack(stackTrace: e.stackTrace);
    unawaited(
      LoggerService.logFirebase(
        screenName: 'Startup',
        operation: 'FirebaseInitialize',
        message: 'Firebase initialization failed',
        details: '${e.code}: ${e.message}',
        stackTrace: e.stackTrace?.toString() ?? '',
      ),
    );
    debugPrint(
      '[Startup] Continuing in offline/local mode. Cloud sync and FCM will be disabled until Firebase initializes.',
    );
    return StartupStatus(
      firebaseInitialized: false,
      firebaseError: e.toString(),
    );
  } catch (error, stackTrace) {
    debugPrint('[Startup] Firebase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    unawaited(
      LoggerService.logError(
        screenName: 'Startup',
        operation: 'FirebaseInitialize',
        message: 'Firebase initialization failed',
        details: error.toString(),
        stackTrace: stackTrace.toString(),
      ),
    );
    debugPrint(
      '[Startup] Continuing in offline/local mode. Cloud sync and FCM will be disabled until Firebase initializes.',
    );
    return StartupStatus(
      firebaseInitialized: false,
      firebaseError: error.toString(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VillaBooks',
      theme: AppTheme.lightTheme,
      home: const StartupExperience(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StartupExperience extends ConsumerStatefulWidget {
  const StartupExperience({super.key});

  @override
  ConsumerState<StartupExperience> createState() =>
      _StartupExperienceState();
}

class _StartupExperienceState extends ConsumerState<StartupExperience> {
  Timer? _timer;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Start authentication while the brand animation is playing.
    ref.watch(authProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _showSplash
          ? const AnimatedSplashScreen(key: ValueKey('startup-splash'))
          : const AuthGate(key: ValueKey('auth-gate')),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authState.needsOrganizationSelection) {
      return const ChooseOrganizationScreen();
    }

    if (!authState.isLoggedIn) {
      return const LoginScreen();
    }

    if (authState.currentUser?.role == AppRoles.superAdmin) {
      return const SuperAdminDashboardScreen();
    }

    return const MainScreen();
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabProvider);
    final navItems = [
      const _NavItem(
        Icons.grid_view_rounded,
        Icons.grid_view_outlined,
        'Dashboard',
        DashboardScreen(),
      ),
      const _NavItem(
        Icons.home_rounded,
        Icons.home_outlined,
        'Villas',
        VillasScreen(),
      ),
      const _NavItem(
        Icons.arrow_circle_down_rounded,
        Icons.arrow_downward_rounded,
        'Income',
        IncomeScreen(),
      ),
      const _NavItem(
        Icons.arrow_circle_up_rounded,
        Icons.arrow_outward_rounded,
        'Expenses',
        ExpensesScreen(),
      ),
      if (ref.watch(authProvider).hasPermission(AppPermissions.viewReports))
        const _NavItem(
          Icons.bar_chart_rounded,
          Icons.bar_chart_outlined,
          'Reports',
          ReportsScreen(),
        ),
      const _NavItem(
        Icons.settings_rounded,
        Icons.settings_outlined,
        'Settings',
        SettingsScreen(),
      ),
    ];
    final safeIndex = selectedIndex >= navItems.length ? 0 : selectedIndex;

    if (safeIndex != selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedTabProvider.notifier).state = safeIndex;
      });
    }

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: safeIndex,
        children: navItems.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: _VillaBooksBottomNav(
        selectedIndex: safeIndex,
        items: navItems,
        onTap: (index) {
          ref.read(selectedTabProvider.notifier).state = index;
        },
      ),
    );
  }
}

class _VillaBooksBottomNav extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _VillaBooksBottomNav({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingBottomNav(
      selectedIndex: selectedIndex,
      items: [
        for (final item in items)
          FloatingBottomNavItem(
            activeIcon: item.activeIcon,
            icon: item.icon,
            label: item.label,
          ),
      ],
      onTap: onTap,
    );
  }
}

class _NavItem {
  final IconData activeIcon;
  final IconData icon;
  final String label;
  final Widget screen;

  const _NavItem(this.activeIcon, this.icon, this.label, this.screen);
}
