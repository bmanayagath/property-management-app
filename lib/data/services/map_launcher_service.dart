import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/villa_model.dart';

class MapLauncherService {
  Future<bool> openGoogleMaps(VillaModel villa) {
    return _launch(villa.googleMapsUrl);
  }

  Future<bool> openWaze(VillaModel villa) {
    return _launch(villa.wazeUrl);
  }

  Future<bool> _launch(String? url) async {
    if (url == null || url.isEmpty) return false;

    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
