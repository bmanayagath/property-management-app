import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../domain/models/room.dart';
import '../../domain/models/villa_model.dart';
import '../providers/dashboard_provider.dart';
import '../providers/room_provider.dart';
import '../providers/villa_provider.dart';
import '../widgets/app_date_picker_field.dart';
import '../widgets/app_dropdown.dart';
import '../widgets/app_text_field.dart';
import '../widgets/room_card.dart';
import 'location_picker_screen.dart';

class AddEditVillaScreen extends ConsumerStatefulWidget {
  final VillaModel? villa;

  const AddEditVillaScreen({Key? key, this.villa}) : super(key: key);

  @override
  ConsumerState<AddEditVillaScreen> createState() => _AddEditVillaScreenState();
}

class _AddEditVillaScreenState extends ConsumerState<AddEditVillaScreen> {
  static const double _dohaLatitude = 25.2854;
  static const double _dohaLongitude = 51.5310;

  final _formKey = GlobalKey<FormState>();
  final _rooms = <Room>[];
  final _existingRoomIds = <String>{};
  final _deletedRoomIds = <String>{};

  late final TextEditingController _villaNameController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;

  bool _loadedExistingRooms = false;
  bool _isSaving = false;
  double? _latitude;
  double? _longitude;
  String? _mapAddress;
  String? _googleMapsUrl;
  String? _wazeUrl;

  bool get _isEditing => widget.villa != null;

  @override
  void initState() {
    super.initState();
    final villa = widget.villa;
    _villaNameController = TextEditingController(text: villa?.villaName ?? '');
    _locationController = TextEditingController(text: villa?.location ?? '');
    _notesController = TextEditingController(text: villa?.notes ?? '');
    _latitude = villa?.latitude;
    _longitude = villa?.longitude;
    _mapAddress = villa?.mapAddress;
    _googleMapsUrl = villa?.googleMapsUrl;
    _wazeUrl = villa?.wazeUrl;
  }

  @override
  void dispose() {
    _villaNameController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveVilla() async {
    if (!_formKey.currentState!.validate()) return;

    if (_rooms.isEmpty) {
      _showMessage('Add at least one room before saving the villa.');
      return;
    }

    final duplicateRoomName = _findDuplicateRoomName();
    if (duplicateRoomName != null) {
      _showMessage('Room name "$duplicateRoomName" is already added.');
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final villa = VillaModel(
      id: widget.villa?.id ?? now.microsecondsSinceEpoch.toString(),
      villaName: _villaNameController.text.trim(),
      villaNumber: '',
      location: _locationController.text.trim(),
      notes: _notesController.text.trim(),
      createdAt: widget.villa?.createdAt ?? now,
      updatedAt: now,
      latitude: _latitude,
      longitude: _longitude,
      mapAddress: _mapAddress,
      googleMapsUrl: _googleMapsUrl,
      wazeUrl: _wazeUrl,
    );

    try {
      final villaId = _isEditing
          ? villa.id
          : await ref.read(addVillaProvider(villa).future);

      if (_isEditing) {
        await ref.read(updateVillaProvider(villa).future);
      }

      for (final roomId in _deletedRoomIds) {
        await ref.read(deleteRoomProvider(roomId).future);
      }

      for (final room in _rooms) {
        final savedRoom = room.assignVilla(
          villaId: villaId,
          villaName: villa.villaName,
        );

        if (_existingRoomIds.contains(room.id)) {
          await ref.read(updateRoomProvider(savedRoom).future);
        } else {
          await ref.read(addRoomProvider(savedRoom).future);
        }
      }

      ref.invalidate(villasProvider);
      ref.invalidate(allRoomsProvider);
      ref.invalidate(dashboardSummaryProvider);

      if (!mounted) return;
      _showMessage(_isEditing
          ? 'Villa updated successfully!'
          : 'Villa added successfully!');
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      _showMessage('Error: $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _addRoom() async {
    final room = await _showRoomSheet();
    if (room == null) return;

    setState(() {
      _rooms.add(room);
    });
  }

  Future<void> _editRoom(int index) async {
    final room = await _showRoomSheet(room: _rooms[index], editIndex: index);
    if (room == null) return;

    setState(() {
      _rooms[index] = room;
    });
  }

  Future<void> _deleteRoom(int index) async {
    final room = _rooms[index];
    if (_existingRoomIds.contains(room.id)) {
      final shouldDelete = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Room?'),
              content: const Text(
                'Deleting this room will also remove related income and expenses from active records. Continue?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ) ??
          false;
      if (!shouldDelete) return;
    }

    setState(() {
      if (_existingRoomIds.contains(room.id)) {
        _deletedRoomIds.add(room.id);
      }
      _rooms.removeAt(index);
    });
  }

  Future<Room?> _showRoomSheet({Room? room, int? editIndex}) {
    return showModalBottomSheet<Room>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _RoomFormSheet(
        room: room,
        isRoomNameUnique: (roomName) {
          final normalized = roomName.trim().toLowerCase();
          return !_rooms.asMap().entries.any((entry) {
            if (entry.key == editIndex) return false;
            return entry.value.roomName.trim().toLowerCase() == normalized;
          });
        },
      ),
    );
  }

  String? _findDuplicateRoomName() {
    final seen = <String>{};
    for (final room in _rooms) {
      final normalized = room.roomName.trim().toLowerCase();
      if (seen.contains(normalized)) return room.roomName.trim();
      seen.add(normalized);
    }
    return null;
  }

  Future<void> _useCurrentLocation() async {
    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission) {
      await _setVillaLocation(_dohaLatitude, _dohaLongitude);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      await _setVillaLocation(position.latitude, position.longitude);
    } catch (_) {
      if (!mounted) return;
      await _setVillaLocation(_dohaLatitude, _dohaLongitude);
      if (!mounted) return;
      _showMessage('Current location unavailable. Doha default was selected.');
    }
  }

  Future<void> _pickLocationOnMap() async {
    try {
      final result = await Navigator.push<PickedVillaLocation>(
        context,
        MaterialPageRoute(
          builder: (context) => LocationPickerScreen(
            initialLatitude: _latitude ?? _dohaLatitude,
            initialLongitude: _longitude ?? _dohaLongitude,
          ),
        ),
      );
      if (result == null) return;

      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        _mapAddress = result.mapAddress;
        _googleMapsUrl = result.googleMapsUrl;
        _wazeUrl = result.wazeUrl;
      });
    } catch (_) {
      if (!mounted) return;
      _showMessage(
          'Unable to open map picker. Please try Use Current Location.');
    }
  }

  void _clearLocation() {
    setState(() {
      _latitude = null;
      _longitude = null;
      _mapAddress = null;
      _googleMapsUrl = null;
      _wazeUrl = null;
    });
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage('Location services are turned off.');
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _showMessage('Location permission was denied.');
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      _showMessage('Location permission is disabled in settings.');
      return false;
    }

    return true;
  }

  Future<void> _setVillaLocation(double latitude, double longitude) async {
    final address = await _reverseGeocode(latitude, longitude);
    if (!mounted) return;

    setState(() {
      _latitude = latitude;
      _longitude = longitude;
      _mapAddress = address;
      _googleMapsUrl = _buildGoogleMapsUrl(latitude, longitude);
      _wazeUrl = _buildWazeUrl(latitude, longitude);
    });
  }

  Future<String?> _reverseGeocode(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;
      final placemark = placemarks.first;
      final parts = [
        placemark.street,
        placemark.subLocality,
        placemark.locality,
        placemark.administrativeArea,
        placemark.country,
      ].where((part) => part != null && part.trim().isNotEmpty).cast<String>();
      final address = parts.join(', ');
      return address.isEmpty ? null : address;
    } catch (_) {
      return null;
    }
  }

  String _buildGoogleMapsUrl(double latitude, double longitude) {
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }

  String _buildWazeUrl(double latitude, double longitude) {
    return 'https://waze.com/ul?ll=$latitude,$longitude&navigate=yes';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildFormCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ...List.generate(
            children.length,
            (index) => Column(
              children: [
                children[index],
                if (index < children.length - 1) const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync =
        _isEditing ? ref.watch(roomsByVillaProvider(widget.villa!.id)) : null;

    if (_isEditing) {
      roomsAsync?.whenData((rooms) {
        if (_loadedExistingRooms) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _loadedExistingRooms) return;
          setState(() {
            _rooms
              ..clear()
              ..addAll(rooms);
            _existingRoomIds
              ..clear()
              ..addAll(rooms.map((room) => room.id));
            _loadedExistingRooms = true;
          });
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Villa' : 'Add New Villa'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Villa Details', Icons.home_outlined),
                _buildFormCard(
                  children: [
                    AppTextField(
                      controller: _villaNameController,
                      label: 'Villa Name *',
                      hint: 'e.g., Sunset Villa',
                      prefixIcon: Icons.label_outlined,
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Villa name is required';
                        }
                        return null;
                      },
                    ),
                    AppTextField(
                      controller: _locationController,
                      label: 'Location',
                      hint: 'e.g., Downtown, District',
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    AppTextField(
                      controller: _notesController,
                      label: 'Notes',
                      hint: 'Optional notes',
                      prefixIcon: Icons.notes_outlined,
                      maxLines: 3,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Villa Location',
                  Icons.map_outlined,
                ),
                _buildLocationCard(),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Rooms',
                  Icons.meeting_room_outlined,
                  trailing: TextButton.icon(
                    onPressed: _addRoom,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Room'),
                  ),
                ),
                if (_isEditing && !_loadedExistingRooms)
                  roomsAsync!.when(
                    data: (_) => const SizedBox.shrink(),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stackTrace) => Text('Error: $error'),
                  )
                else if (_rooms.isEmpty)
                  _buildEmptyRoomsCard()
                else
                  ..._rooms.asMap().entries.map(
                        (entry) => RoomCard(
                          room: entry.value,
                          onTap: () => _editRoom(entry.key),
                          onEdit: () => _editRoom(entry.key),
                          onDelete: () => _deleteRoom(entry.key),
                        ),
                      ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _isSaving ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveVilla,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isEditing ? 'Save Villa' : 'Add Villa',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyRoomsCard() {
    return InkWell(
      onTap: _addRoom,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_home_work_outlined,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No rooms added yet',
              style: AppStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap Add Room to create the first room.',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    final hasLocation = _latitude != null && _longitude != null;

    return Container(
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
          Text(
            hasLocation
                ? _mapAddress ?? 'Lat: $_latitude, Lng: $_longitude'
                : 'Location is optional.',
            style: AppStyles.bodyMedium.copyWith(
              color:
                  hasLocation ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _useCurrentLocation,
                icon: const Icon(Icons.my_location_outlined, size: 18),
                label: const Text('Use Current Location'),
              ),
              OutlinedButton.icon(
                onPressed: _pickLocationOnMap,
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Pick Location on Map'),
              ),
              OutlinedButton.icon(
                onPressed: hasLocation ? _clearLocation : null,
                icon: const Icon(Icons.clear_outlined, size: 18),
                label: const Text('Clear Location'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoomFormSheet extends StatefulWidget {
  final Room? room;
  final bool Function(String roomName) isRoomNameUnique;

  const _RoomFormSheet({
    this.room,
    required this.isRoomNameUnique,
  });

  @override
  State<_RoomFormSheet> createState() => _RoomFormSheetState();
}

class _RoomFormSheetState extends State<_RoomFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _roomNameController;
  late final TextEditingController _tenantNameController;
  late final TextEditingController _tenantPhoneController;
  late final TextEditingController _monthlyRentController;
  late final TextEditingController _paymentDueDayController;

  late DateTime _contractStartDate;
  late DateTime _contractEndDate;
  late String _status;

  bool get _isEditing => widget.room != null;
  bool get _isTenantRequired => _status == RoomStatuses.occupied;

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    _roomNameController = TextEditingController(text: room?.roomName ?? '');
    _tenantNameController = TextEditingController(text: room?.tenantName ?? '');
    _tenantPhoneController =
        TextEditingController(text: room?.tenantPhone ?? '');
    _monthlyRentController = TextEditingController(
      text: room == null || room.monthlyRent == 0
          ? ''
          : room.monthlyRent.toString(),
    );
    _paymentDueDayController = TextEditingController(
      text: (room?.paymentDueDay ?? 1).toString(),
    );
    _contractStartDate = room?.contractStartDate ?? DateTime.now();
    _contractEndDate =
        room?.contractEndDate ?? DateTime.now().add(const Duration(days: 365));
    _status = room?.status ?? RoomStatuses.vacant;
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _tenantNameController.dispose();
    _tenantPhoneController.dispose();
    _monthlyRentController.dispose();
    _paymentDueDayController.dispose();
    super.dispose();
  }

  void _saveRoom() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final room = Room(
      id: widget.room?.id ?? now.microsecondsSinceEpoch.toString(),
      villaId: widget.room?.villaId ?? '',
      villaName: widget.room?.villaName ?? '',
      roomName: _roomNameController.text.trim(),
      roomNumber: '',
      tenantName: _tenantNameController.text.trim(),
      tenantPhone: _tenantPhoneController.text.trim(),
      monthlyRent: double.parse(_monthlyRentController.text.trim()),
      paymentDueDay: int.parse(_paymentDueDayController.text.trim()),
      status: _status,
      contractStartDate: _isTenantRequired ? _contractStartDate : null,
      contractEndDate: _isTenantRequired ? _contractEndDate : null,
      createdAt: widget.room?.createdAt ?? now,
      updatedAt: _isEditing ? now : null,
    );

    Navigator.pop(context, room);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? 'Edit Room' : 'Add Room',
                      style: AppStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppDropdown<String>(
                label: 'Status',
                value: _status,
                items: RoomStatuses.values,
                itemLabel: (status) => status,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _status = value);
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _roomNameController,
                label: 'Room Name *',
                hint: 'e.g., Room 101',
                prefixIcon: Icons.label_outlined,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Room name is required';
                  }
                  if (!widget.isRoomNameUnique(value!.trim())) {
                    return 'Room name must be unique inside this villa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _monthlyRentController,
                label: 'Monthly Rent *',
                hint: '0.00',
                prefixIcon: Icons.attach_money_outlined,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final rent = double.tryParse(value?.trim() ?? '');
                  if (rent == null) return 'Enter a valid monthly rent';
                  if (rent <= 0) {
                    return 'Monthly rent must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _paymentDueDayController,
                label: 'Payment Due Day *',
                hint: '1 to 31',
                prefixIcon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final day = int.tryParse(value?.trim() ?? '');
                  if (day == null) return 'Enter a valid due day';
                  if (day < 1 || day > 31) {
                    return 'Payment due day must be 1 to 31';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _tenantNameController,
                label: _isTenantRequired ? 'Tenant Name *' : 'Tenant Name',
                hint: _isTenantRequired ? 'Full name' : 'Optional',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (_isTenantRequired && (value?.trim().isEmpty ?? true)) {
                    return 'Tenant name is required for occupied rooms';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _tenantPhoneController,
                label: _isTenantRequired ? 'Tenant Phone *' : 'Tenant Phone',
                hint: _isTenantRequired ? '+974 1234 5678' : 'Optional',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (_isTenantRequired && (value?.trim().isEmpty ?? true)) {
                    return 'Tenant phone is required for occupied rooms';
                  }
                  return null;
                },
              ),
              if (_isTenantRequired) ...[
                const SizedBox(height: 16),
                AppDatePickerField(
                  label: 'Contract Start Date',
                  value: _contractStartDate,
                  onChanged: (date) {
                    setState(() => _contractStartDate = date);
                  },
                ),
                const SizedBox(height: 16),
                AppDatePickerField(
                  label: 'Contract End Date',
                  value: _contractEndDate,
                  onChanged: (date) {
                    setState(() => _contractEndDate = date);
                  },
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _saveRoom,
                  icon: Icon(_isEditing ? Icons.save : Icons.add),
                  label: Text(_isEditing ? 'Update Room' : 'Add Room'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
