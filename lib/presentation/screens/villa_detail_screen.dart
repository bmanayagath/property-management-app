import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_roles.dart';
import '../../core/constants/app_styles.dart';
import '../../core/constants/app_permissions.dart';
import '../../data/services/room_media_picker_service.dart';
import '../../data/services/tenant_contact_service.dart';
import '../../data/services/whatsapp_share_service.dart';
import '../../domain/models/income.dart';
import '../../domain/models/room.dart';
import '../../domain/models/villa_model.dart';
import '../../models/room_media.dart';
import '../widgets/currency_amount_text.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/database_provider.dart';
import '../providers/income_provider.dart';
import '../providers/room_media_provider.dart';
import '../providers/villa_provider.dart';
import '../providers/room_provider.dart';
import '../screens/room_media_screen.dart';
import '../screens/room_media_preview_screen.dart';
import '../screens/room_detail_screen.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/room_card.dart';
import 'add_edit_villa_screen.dart';
import 'add_edit_room_screen.dart';

class VillaDetailScreen extends ConsumerWidget {
  final String villaId;

  const VillaDetailScreen({
    Key? key,
    required this.villaId,
  }) : super(key: key);

  bool _hasVillaLocation(VillaModel villa) {
    return villa.latitude != null && villa.longitude != null;
  }

  Future<void> _callTenant(BuildContext context, String phone) async {
    final didOpen = await TenantContactService().callTenant(phone);
    if (!context.mounted || didOpen) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open phone dialer.')),
    );
  }

  Future<void> _whatsappTenant(BuildContext context, String phone) async {
    final didOpen = await TenantContactService().whatsappTenant(phone: phone);
    if (!context.mounted || didOpen) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('WhatsApp is not installed.')),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Villa?'),
          content: const Text(
            'Deleting this villa will also remove all rooms, income, and expenses linked to it from active records. This action will sync to other devices. Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await ref.read(deleteVillaProvider(villaId).future);
                ref.invalidate(villasProvider);
                ref.invalidate(allRoomsProvider);
                ref.invalidate(dashboardSummaryProvider);
                if (!context.mounted) return;
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text(
                'Delete Villa',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final villaAsync = ref.watch(villaByIdProvider(villaId));
    final authState = ref.watch(authProvider);
    final canManageVillas =
        authState.hasPermission(AppPermissions.manageVillas);
    final canDeleteVillas = canManageVillas &&
        authState.hasPermission(AppPermissions.deleteRecords);
    final canManageRoomMedia = _canManageRoomMedia(authState);
    final canShareRoomMedia = _canShareRoomMedia(authState);

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text('Villa Details'),
        elevation: 0,
      ),
      body: villaAsync.when(
        data: (villa) {
          if (villa == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: 48,
                    color: AppColors.border,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Villa not found',
                    style: AppStyles.titleMedium,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: PremiumTokens.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card with Villa Name
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              villa.villaName,
                              style: AppStyles.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                villa.location,
                                style: AppStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Rooms Summary Card
                  _buildRoomsSummary(context, ref, villa.id),
                  const SizedBox(height: 24),

                  _buildLocationSection(context, ref, villa),
                  const SizedBox(height: 24),

                  // Rooms List
                  _buildRoomsList(
                    context,
                    ref,
                    villa.id,
                    canManageVillas,
                    canManageRoomMedia,
                    canShareRoomMedia,
                  ),
                  const SizedBox(height: 24),

                  if (canManageVillas) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddEditVillaScreen(villa: villa),
                            ),
                          ).then((_) {
                            ref.invalidate(villaByIdProvider);
                          });
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Villa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (canDeleteVillas)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showDeleteConfirmation(context, ref),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete Villa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.error.withValues(alpha: 0.1),
                          foregroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading villa',
                style: AppStyles.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildRoomsSummary(
      BuildContext context, WidgetRef ref, String villaId) {
    final roomsAsync = ref.watch(roomsByVillaProvider(villaId));

    return roomsAsync.when(
      data: (rooms) {
        final activeRooms = rooms
            .where((room) => room.villaId == villaId && !room.isDeleted)
            .toList();
        final occupiedCount = activeRooms.where((r) => r.isOccupied).length;
        final vacantCount = activeRooms.where((r) => r.isVacant).length;
        final occupancyRate = activeRooms.isEmpty
            ? 0.0
            : (occupiedCount / activeRooms.length) * 100;
        final totalRoomRent = activeRooms.fold<double>(
          0,
          (sum, room) => sum + room.monthlyRent,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room Summary',
              style: AppStyles.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Rooms',
                              style: AppStyles.labelSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activeRooms.length.toString(),
                              style: AppStyles.headlineSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Occupied',
                              style: AppStyles.labelSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              occupiedCount.toString(),
                              style: AppStyles.headlineSmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vacant',
                              style: AppStyles.labelSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              vacantCount.toString(),
                              style: AppStyles.headlineSmall.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Room Rent',
                              style: AppStyles.labelSmall,
                            ),
                            const SizedBox(height: 4),
                            CurrencyAmountText(
                              amount: totalRoomRent,
                              amountColor: AppColors.success,
                              amountFontSize: 12,
                              currencyFontSize: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: occupancyRate / 100,
                            minHeight: 9,
                            backgroundColor: const Color(0xFFE4E4E6),
                            valueColor:
                                AlwaysStoppedAnimation(AppColors.success),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${occupancyRate.toStringAsFixed(1)}%',
                        style: AppStyles.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error loading rooms: $error'),
    );
  }

  Widget _buildLocationSection(
    BuildContext context,
    WidgetRef ref,
    VillaModel villa,
  ) {
    final roomsAsync = ref.watch(roomsByVillaProvider(villa.id));
    final hasLocation = _hasVillaLocation(villa);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Villa Location',
          style: AppStyles.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: roomsAsync.when(
            data: (rooms) {
              final activeRooms = rooms
                  .where((room) => room.villaId == villa.id && !room.isDeleted)
                  .toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasLocation) ...[
                    Text(
                      villa.mapAddress ?? villa.location,
                      style: AppStyles.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _shareVilla(villa, activeRooms),
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: const Text('Share Villa on WhatsApp'),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Location not added',
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _shareVilla(villa, activeRooms),
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Share Villa on WhatsApp'),
                    ),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error loading rooms: $error'),
          ),
        ),
      ],
    );
  }

  Future<void> _shareVilla(VillaModel villa, List<Room> rooms) {
    final activeRooms = rooms.where((room) => !room.isDeleted).toList();
    final vacantRooms = activeRooms.where((room) => room.isVacant).toList();
    final rentValues = vacantRooms.map((room) => room.monthlyRent).toList();
    final minRent = rentValues.isEmpty
        ? 0.0
        : rentValues.reduce((value, rent) => value < rent ? value : rent);
    final maxRent = rentValues.isEmpty
        ? 0.0
        : rentValues.reduce((value, rent) => value > rent ? value : rent);

    return WhatsAppShareService().shareVilla(
      villa: villa,
      vacantRoomsCount: vacantRooms.length,
      minRent: minRent,
      maxRent: maxRent,
    );
  }

  Widget _buildRoomsList(
    BuildContext context,
    WidgetRef ref,
    String villaId,
    bool canManageVillas,
    bool canManageRoomMedia,
    bool canShareRoomMedia,
  ) {
    final roomsAsync = ref.watch(watchRoomsByVillaProvider(villaId));
    final incomes =
        ref.watch(incomeListProvider).valueOrNull ?? const <Income>[];
    final currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final rentReceivedByRoom = _rentReceivedByRoom(incomes, currentMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rooms',
              style: AppStyles.titleMedium,
            ),
            if (canManageVillas)
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditRoomScreen(villaId: villaId),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Room'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        roomsAsync.when(
          data: (rooms) {
            final activeRooms = rooms
                .where((room) => room.villaId == villaId && !room.isDeleted)
                .toList();

            if (activeRooms.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.meeting_room_outlined,
                        size: 48,
                        color: AppColors.border,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No rooms added yet',
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (canManageVillas) ...[
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddEditRoomScreen(villaId: villaId),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Room'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeRooms.length,
              itemBuilder: (context, index) {
                final room = activeRooms[index];
                final received = rentReceivedByRoom[room.id] ?? 0;
                final pending = room.isOccupied
                    ? (room.monthlyRent - received)
                        .clamp(0.0, double.infinity)
                        .toDouble()
                    : room.monthlyRent;
                final hasTenantPhone = room.tenantPhone.trim().isNotEmpty;
                return RoomCard(
                  room: room,
                  pendingRent: pending,
                  pendingRentLabel:
                      room.isOccupied ? 'Pending' : 'Potential Loss',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomDetailScreen(
                          room: room,
                          canManage: canManageVillas,
                        ),
                      ),
                    );
                  },
                  onAddPhoto: canManageRoomMedia
                      ? () => _pickAndPreviewRoomMedia(
                            context,
                            ref,
                            room,
                            RoomMediaFileType.image,
                          )
                      : null,
                  onAddVideo: canManageRoomMedia
                      ? () => _pickAndPreviewRoomMedia(
                            context,
                            ref,
                            room,
                            RoomMediaFileType.video,
                          )
                      : null,
                  onViewMedia: () => _openRoomMediaGallery(
                    context,
                    room,
                    canManageRoomMedia: canManageRoomMedia,
                    canShareRoomMedia: canShareRoomMedia,
                  ),
                  onShareMedia: canShareRoomMedia
                      ? () => _shareRoomMedia(context, ref, room)
                      : null,
                  onCallTenant: hasTenantPhone
                      ? () => _callTenant(context, room.tenantPhone)
                      : null,
                  onWhatsappTenant: hasTenantPhone
                      ? () => _whatsappTenant(context, room.tenantPhone)
                      : null,
                  onEdit: canManageVillas
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditRoomScreen(
                                  room: room, villaId: villaId),
                            ),
                          );
                        }
                      : null,
                  onDelete: canManageVillas
                      ? () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Room?'),
                              content: const Text(
                                'Deleting this room will also remove related income and expenses from active records. Continue?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await ref.read(
                                        deleteRoomProvider(room.id).future);
                                    ref.invalidate(villasProvider);
                                    ref.invalidate(roomListProvider);
                                    ref.invalidate(
                                        roomsByVillaProvider(villaId));
                                    ref.invalidate(
                                        watchRoomsByVillaProvider(villaId));
                                    ref.invalidate(dashboardSummaryProvider);
                                    await _logRoomDeleteCounts(
                                        ref, villaId, room.id);
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      : null,
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error loading rooms: $error'),
        ),
      ],
    );
  }

  bool _canManageRoomMedia(AuthState authState) {
    final role = authState.currentUser?.role;
    return role == AppRoles.admin || role == AppRoles.contributor;
  }

  bool _canShareRoomMedia(AuthState authState) {
    final role = authState.currentUser?.role;
    return role == AppRoles.admin ||
        role == AppRoles.contributor ||
        role == AppRoles.reader;
  }

  void _openRoomMediaGallery(
    BuildContext context,
    Room room, {
    required bool canManageRoomMedia,
    required bool canShareRoomMedia,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomMediaScreen(
          villaId: room.villaId,
          roomId: room.id,
          roomName: room.displayName,
          canUpload: canManageRoomMedia,
          canDelete: canManageRoomMedia,
          canShare: canShareRoomMedia,
        ),
      ),
    );
  }

  Future<void> _pickAndPreviewRoomMedia(
    BuildContext context,
    WidgetRef ref,
    Room room,
    String fileType,
  ) async {
    final currentRoom = await ref.read(roomByIdProvider(room.id).future);
    if (currentRoom == null || currentRoom.isDeleted) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('This room has been deleted. Media cannot be uploaded.'),
        ),
      );
      return;
    }
    final villa = await ref.read(villaByIdProvider(room.villaId).future);
    if (villa == null || villa.isDeleted) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('This villa has been deleted. Media cannot be uploaded.'),
        ),
      );
      return;
    }
    final existing = await ref.read(roomMediaRepositoryProvider).getRoomMedia(
          villaId: room.villaId,
          roomId: room.id,
        );
    final photos = existing.where((item) => item.isImage).length;
    final videos = existing.where((item) => item.isVideo).length;
    if (fileType == RoomMediaFileType.image &&
        photos >= RoomMediaPickerService.maxPhotosPerRoom) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 20 photos allowed for a room.'),
        ),
      );
      return;
    }
    if (fileType == RoomMediaFileType.video &&
        videos >= RoomMediaPickerService.maxVideosPerRoom) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 videos allowed for a room.'),
        ),
      );
      return;
    }

    final source = await _chooseMediaSource(context);
    if (source == null) return;

    try {
      final picker = RoomMediaPickerService();
      final picked = fileType == RoomMediaFileType.video
          ? await picker.pickVideo(source: source)
          : await picker.pickPhoto(source: source);
      if (picked == null || !context.mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomMediaPreviewScreen(
            villaId: room.villaId,
            roomId: room.id,
            initialMedia: [picked],
            existingPhotoCount: photos,
            existingVideoCount: videos,
          ),
        ),
      );
    } on RoomMediaPickerException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to select media.')),
      );
    }
  }

  Future<ImageSource?> _chooseMediaSource(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareRoomMedia(
    BuildContext context,
    WidgetRef ref,
    Room room,
  ) async {
    final media = await ref.read(roomMediaRepositoryProvider).getRoomMedia(
          villaId: room.villaId,
          roomId: room.id,
        );
    final files = <XFile>[];
    final urls = <String>[];

    for (final item in media) {
      final localPath = item.localPath.trim();
      if (localPath.isNotEmpty && await File(localPath).exists()) {
        files.add(XFile(localPath));
      } else if (item.downloadUrl.trim().isNotEmpty) {
        urls.add(item.downloadUrl.trim());
      }
    }

    if (files.isNotEmpty) {
      await SharePlus.instance.share(
        ShareParams(
          text: 'Hello',
          files: files,
        ),
      );
      return;
    }

    if (urls.isNotEmpty) {
      await SharePlus.instance.share(
        ShareParams(text: ['Hello', '', ...urls].join('\n')),
      );
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No room media is available to share.')),
    );
  }

  Future<void> _logRoomDeleteCounts(
    WidgetRef ref,
    String villaId,
    String roomId,
  ) async {
    final database = ref.read(databaseProvider);
    final activeCount = await database.getActiveRoomCountForVilla(villaId);
    final rawCount = await database.getRawRoomCountForVilla(villaId);
    debugPrint(
      '[VillaDetailScreen] deleted room id=$roomId, '
      'active rooms for villa=$activeCount, '
      'raw rooms for villa=$rawCount',
    );
  }

  Map<String, double> _rentReceivedByRoom(
      List<Income> incomes, DateTime month) {
    final totals = <String, double>{};
    for (final income in incomes.where(
      (income) =>
          income.incomeType.toLowerCase() == IncomeTypes.rent.toLowerCase() &&
          income.roomId.trim().isNotEmpty &&
          income.monthCovered.year == month.year &&
          income.monthCovered.month == month.month,
    )) {
      totals.update(
        income.roomId,
        (value) => value + income.amount,
        ifAbsent: () => income.amount,
      );
    }
    return totals;
  }
}
