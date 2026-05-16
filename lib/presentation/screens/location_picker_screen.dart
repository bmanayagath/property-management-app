import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_colors.dart';

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

  String get wazeUrl => 'https://waze.com/ul?ll=$latitude,$longitude&navigate=yes';
}

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
  }) : super(key: key);

  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const _fallbackPosition = LatLng(25.2854, 51.5310);

  late LatLng _selectedPosition;
  bool _isResolvingAddress = false;
  String? _address;

  @override
  void initState() {
    super.initState();
    _selectedPosition = LatLng(
      widget.initialLatitude ?? _fallbackPosition.latitude,
      widget.initialLongitude ?? _fallbackPosition.longitude,
    );
    _resolveAddress(_selectedPosition);
  }

  Future<void> _resolveAddress(LatLng position) async {
    setState(() => _isResolvingAddress = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      setState(() => _address = _formatPlacemark(placemarks.firstOrNull));
    } catch (_) {
      if (!mounted) return;
      setState(() => _address = null);
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

  void _selectPosition(LatLng position) {
    setState(() => _selectedPosition = position);
    _resolveAddress(position);
  }

  void _save() {
    Navigator.pop(
      context,
      PickedVillaLocation(
        latitude: _selectedPosition.latitude,
        longitude: _selectedPosition.longitude,
        mapAddress: _address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = {
      Marker(
        markerId: const MarkerId('selected-villa-location'),
        position: _selectedPosition,
      ),
    };

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
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: 15,
            ),
            markers: markers,
            myLocationButtonEnabled: false,
            myLocationEnabled: false,
            onTap: _selectPosition,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _isResolvingAddress
                      ? 'Finding address...'
                      : _address ?? 'Tap the map to choose a villa location',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
