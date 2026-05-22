import 'package:url_launcher/url_launcher.dart';

class TenantContactService {
  Future<bool> callTenant(String phone) async {
    final phoneNumber = phone.trim();
    if (phoneNumber.isEmpty) {
      return false;
    }

    return launchUrl(Uri.parse('tel:$phoneNumber'));
  }

  Future<bool> whatsappTenant({
    required String phone,
  }) async {
    final phoneNumber = normalizePhoneNumber(phone);
    if (phoneNumber.isEmpty) {
      return false;
    }

    final message = Uri.encodeComponent('Hello');
    final appUri =
        Uri.parse('whatsapp://send?phone=$phoneNumber&text=$message');
    final webUri = Uri.parse('https://wa.me/$phoneNumber?text=$message');

    if (await canLaunchUrl(appUri)) {
      return launchUrl(appUri, mode: LaunchMode.externalApplication);
    }

    if (await canLaunchUrl(webUri)) {
      return launchUrl(webUri, mode: LaunchMode.externalApplication);
    }

    return false;
  }

  String normalizePhoneNumber(String phone) {
    final cleaned = phone
        .trim()
        .replaceAll(RegExp(r'[\s\-\(\)]'), '')
        .replaceFirst(RegExp(r'^\+'), '');

    if (RegExp(r'^\d{8}$').hasMatch(cleaned)) {
      return '974$cleaned';
    }

    return cleaned;
  }
}
