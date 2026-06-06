import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/navigation_provider.dart';
import '../../widgets/premium_widgets.dart';

class AccessDeniedScreen extends ConsumerWidget {
  const AccessDeniedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PremiumScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: PremiumCard(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE6E0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFFF04438),
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Access Denied',
                    style: TextStyle(
                      color: Color(0xFF060B26),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You do not have permission to view this section.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF646B7A),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: () {
                      ref.read(selectedTabProvider.notifier).state = 0;
                    },
                    icon: const Icon(Icons.dashboard_rounded),
                    label: const Text('Back to Dashboard'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
