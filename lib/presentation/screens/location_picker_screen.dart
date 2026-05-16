import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';

class PickedVillaLocation {
  const PickedVillaLocation({
    required this.latitude,
    required this.longitude,
    this.mapAddress,
  });

  final double latitude;
  final double longitude;
  final String? mapAddress;

  String get googleMapsUrl =>
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

  String get wazeUrl =>
      'https://waze.com/ul?ll=$latitude,$longitude&navigate=yes';
}

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
  }) : super(key: key);

  static const double defaultLatitude = 25.2854;
  static const double defaultLongitude = 51.5310;

  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  bool _isResolvingAddress = false;
  String? _address;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final latitude =
        widget.initialLatitude ?? LocationPickerScreen.defaultLatitude;
    final longitude =
        widget.initialLongitude ?? LocationPickerScreen.defaultLongitude;

    _latitudeController = TextEditingController(text: latitude.toString());
    _longitudeController = TextEditingController(text: longitude.toString());
    _resolveAddress(latitude, longitude);
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _resolveAddress(double latitude, double longitude) async {
    if (!mounted) return;
    setState(() {
      _isResolvingAddress = true;
      _errorMessage = null;
    });

    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (!mounted) return;
      setState(() => _address = _formatPlacemark(
            placemarks.isEmpty ? null : placemarks.first,
          ));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _address = null;
        _errorMessage =
            'Address lookup is unavailable. The coordinates can still be saved.';
      });
    } finally {
      if (mounted) setState(() => _isResolvingAddress = false);
    }
  }

  String? _formatPlacemark(Placemark? placemark) {
    if (placemark == null) return null;
    final parts = [
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
      placemark.country,
    ].where((part) => part != null && part.trim().isNotEmpty).cast<String>();
    final address = parts.join(', ');
    return address.isEmpty ? null : address;
  }

  void _useDohaDefault() {
    _latitudeController.text = LocationPickerScreen.defaultLatitude.toString();
    _longitudeController.text =
        LocationPickerScreen.defaultLongitude.toString();
    _refreshAddress();
  }

  Future<void> _refreshAddress() async {
    final coordinates = _readCoordinates();
    if (coordinates == null) return;
    await _resolveAddress(coordinates.$1, coordinates.$2);
  }

  (double, double)? _readCoordinates() {
    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());

    if (latitude == null ||
        longitude == null ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      setState(() {
        _errorMessage = 'Enter valid latitude and longitude values.';
      });
      return null;
    }

    return (latitude, longitude);
  }

  void _save() {
    try {
      final coordinates = _readCoordinates();
      if (coordinates == null) return;
      Navigator.pop(
        context,
        PickedVillaLocation(
          latitude: coordinates.$1,
          longitude: coordinates.$2,
          mapAddress: _address,
        ),
      );
    } catch (_) {
      setState(() {
        _errorMessage =
            'Unable to save this location. Please check the coordinates.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressText = _isResolvingAddress
        ? 'Finding address...'
        : _address ?? 'No readable address found for these coordinates.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location Coordinates', style: AppStyles.titleMedium),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _refreshAddress,
                          icon: const Icon(Icons.search_outlined, size: 18),
                          label: const Text('Find Address'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _useDohaDefault,
                          icon: const Icon(Icons.location_city_outlined,
                              size: 18),
                          label: const Text('Use Doha Default'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(addressText, style: AppStyles.bodyMedium),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: AppStyles.bodySmall.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Use This Location'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
