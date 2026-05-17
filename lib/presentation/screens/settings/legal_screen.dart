import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _supportEmail = 'villabooksapp@gmail.com';
const _supportSubject = 'VillaBooks Support Request';
const _privacyPolicyUrl =
    'https://bmanayagath.github.io/property-management-app/privacy.html';
const _termsOfUseUrl =
    'https://bmanayagath.github.io/property-management-app/terms.html';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  Future<void> _openExternalLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!didLaunch && context.mounted) {
      _showLaunchError(context);
    }
  }

  Future<void> _contactSupport(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {'subject': _supportSubject},
    );
    final didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!didLaunch && context.mounted) {
      _showLaunchError(context);
    }
  }

  void _showLaunchError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open this link right now.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFD),
      appBar: AppBar(
        title: const Text('Terms & Privacy'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _LegalSection(
            title: 'Terms of Use',
            body:
                'VillaBooks is provided for rental bookkeeping and reporting. '
                'Users are responsible for entering accurate villa, room, '
                'income, and expense records and for reviewing synced data '
                'before making financial decisions.',
          ),
          const SizedBox(height: 12),
          _LegalSection(
            title: 'Privacy Policy',
            body:
                'VillaBooks stores account profile, role, villa, room, income, '
                'expense, and sync metadata in Firebase and on this device for '
                'offline access. The app uses this data only to provide rental '
                'management, reporting, authentication, and synchronization.',
          ),
          const SizedBox(height: 12),
          const _LegalSection(
            title: 'Data Retention',
            body:
                'Deleted business records are archived with soft-delete flags '
                'so they can sync safely across devices and remain excluded '
                'from active calculations.',
          ),
          const SizedBox(height: 16),
          _ActionTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Open Privacy Policy',
            subtitle: 'Privacy Policy',
            onTap: () => _openExternalLink(context, _privacyPolicyUrl),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.description_outlined,
            title: 'Open Terms of Use',
            subtitle: 'Terms of Use',
            onTap: () => _openExternalLink(context, _termsOfUseUrl),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.mail_outline,
            title: 'Contact Support',
            subtitle: _supportEmail,
            onTap: () => _contactSupport(context),
          ),
          const SizedBox(height: 16),
          _LegalSection(
            title: 'Support',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  label: 'Support Email',
                  child: _InlineLink(
                    label: _supportEmail,
                    onTap: () => _contactSupport(context),
                  ),
                ),
                _InfoRow(
                  label: 'Privacy Policy',
                  child: _InlineLink(
                    label: 'Privacy Policy',
                    onTap: () => _openExternalLink(context, _privacyPolicyUrl),
                  ),
                ),
                _InfoRow(
                  label: 'Terms of Use',
                  child: _InlineLink(
                    label: 'Terms of Use',
                    onTap: () => _openExternalLink(context, _termsOfUseUrl),
                  ),
                ),
                const _InfoRow(
                  label: 'Support Hours',
                  value: 'Sunday - Thursday\n9:00 AM - 6:00 PM (Qatar Time)',
                ),
                const _InfoRow(
                  label: 'Response Time',
                  value: 'Usually within 24-48 hours',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  final String title;
  final String? body;
  final Widget? child;

  const _LegalSection({
    required this.title,
    this.body,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF060B26),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          if (child != null)
            child!
          else
            Text(
              body ?? '',
              style: const TextStyle(
                color: Color(0xFF646B7A),
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8EAF0)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF060B26),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF646B7A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.open_in_new,
                color: Color(0xFF2563EB),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? child;

  const _InfoRow({
    required this.label,
    this.value,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: Color(0xFF060B26),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          child ??
              Text(
                value ?? '',
                style: const TextStyle(
                  color: Color(0xFF646B7A),
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
        ],
      ),
    );
  }
}

class _InlineLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _InlineLink({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.open_in_new,
              color: Color(0xFF2563EB),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
