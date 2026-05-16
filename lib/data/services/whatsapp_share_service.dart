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
    final lines = <String>[
      'Villa: ${villa.villaName}',
      if ((villa.mapAddress ?? '').isNotEmpty) 'Location: ${villa.mapAddress}',
      if ((villa.googleMapsUrl ?? '').isNotEmpty)
        'Google Maps: ${villa.googleMapsUrl}',
      if ((villa.wazeUrl ?? '').isNotEmpty) 'Waze: ${villa.wazeUrl}',
      'Available Rooms: $vacantRoomsCount',
      'Rent Range: QAR ${_formatRent(minRent)} - QAR ${_formatRent(maxRent)}',
    ];

    return lines.join('\n');
  }

  String _formatRent(double rent) {
    if (rent == rent.roundToDouble()) return rent.toStringAsFixed(0);
    return rent.toStringAsFixed(2);
  }
}
