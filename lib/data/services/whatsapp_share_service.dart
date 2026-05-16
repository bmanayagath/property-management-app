import 'package:share_plus/share_plus.dart';

import '../../domain/models/villa_model.dart';

class WhatsAppShareService {
  Future<void> shareVilla({
    required VillaModel villa,
    required int vacantRoomsCount,
    required double minRent,
    required double maxRent,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        text: buildVillaMessage(
          villa: villa,
          vacantRoomsCount: vacantRoomsCount,
          minRent: minRent,
          maxRent: maxRent,
        ),
      ),
    );
  }

  String buildVillaMessage({
    required VillaModel villa,
    required int vacantRoomsCount,
    required double minRent,
    required double maxRent,
  }) {
    final hasLocation = villa.latitude != null && villa.longitude != null;
    final address = (villa.mapAddress ?? '').trim().isNotEmpty
        ? villa.mapAddress!.trim()
        : 'Lat: ${villa.latitude}, Lng: ${villa.longitude}';
    final lines = <String>[
      if (hasLocation) 'Location: $address',
      if (hasLocation && (villa.googleMapsUrl ?? '').isNotEmpty) ...[
        '',
        '📍 Google Maps:',
        villa.googleMapsUrl!,
      ],
      if (hasLocation && (villa.wazeUrl ?? '').isNotEmpty) ...[
        '',
        '🚗 Waze:',
        villa.wazeUrl!,
      ],
    ];

    return lines.join('\n');
  }
}
