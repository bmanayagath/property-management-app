import 'package:flutter/material.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

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
        children: const [
          _LegalSection(
            title: 'Terms of Use',
            body:
                'VillaBooks is provided for rental bookkeeping and reporting. '
                'Users are responsible for entering accurate villa, room, '
                'income, and expense records and for reviewing synced data '
                'before making financial decisions.',
          ),
          SizedBox(height: 12),
          _LegalSection(
            title: 'Privacy Policy',
            body:
                'VillaBooks stores account profile, role, villa, room, income, '
                'expense, and sync metadata in Firebase and on this device for '
                'offline access. The app uses this data only to provide rental '
                'management, reporting, authentication, and synchronization.',
          ),
          SizedBox(height: 12),
          _LegalSection(
            title: 'Data Retention',
            body:
                'Deleted business records are archived with soft-delete flags '
                'so they can sync safely across devices and remain excluded '
                'from active calculations.',
          ),
          SizedBox(height: 12),
          _LegalSection(
            title: 'Support',
            body:
                'For production release, replace this text with your official '
                'support email, support URL, terms URL, and privacy policy URL.',
          ),
        ],
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  final String title;
  final String body;

  const _LegalSection({
    required this.title,
    required this.body,
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
          Text(
            body,
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
