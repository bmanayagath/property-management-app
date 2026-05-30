import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../core/constants/app_colors.dart';
import '../../data/services/firebase_storage_service.dart';
import '../../data/services/room_media_picker_service.dart';
import '../../models/room_media.dart';
import '../providers/auth_provider.dart';
import '../providers/room_media_provider.dart';
import '../providers/room_provider.dart';
import '../providers/villa_provider.dart';
import '../screens/room_media_preview_screen.dart';

class RoomMediaGalleryWidget extends ConsumerStatefulWidget {
  final String villaId;
  final String roomId;
  final bool canUpload;
  final bool canDelete;
  final bool canShare;

  const RoomMediaGalleryWidget({
    super.key,
    required this.villaId,
    required this.roomId,
    required this.canUpload,
    required this.canDelete,
    required this.canShare,
  });

  @override
  ConsumerState<RoomMediaGalleryWidget> createState() =>
      _RoomMediaGalleryWidgetState();
}

class _RoomMediaGalleryWidgetState
    extends ConsumerState<RoomMediaGalleryWidget> {
  final _pickerService = RoomMediaPickerService();

  RoomMediaKey get _key => RoomMediaKey(
        villaId: widget.villaId,
        roomId: widget.roomId,
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncPendingIfActive();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaAsync = ref.watch(roomMediaProvider(_key));

    return mediaAsync.when(
      data: (items) {
        final photos = items.where((item) => item.isImage).toList();
        final videos = items.where((item) => item.isVideo).toList();

        return Column(
          children: [
            if (widget.canUpload || widget.canShare)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    if (widget.canUpload) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (photos.length >=
                                RoomMediaPickerService.maxPhotosPerRoom) {
                              _showMessage(
                                'Maximum 10 photos allowed per room.',
                              );
                              return;
                            }
                            _addMedia(
                              fileType: RoomMediaFileType.image,
                              existingPhotoCount: photos.length,
                              existingVideoCount: videos.length,
                            );
                          },
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: const Text('Add Photo'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (videos.length >=
                                RoomMediaPickerService.maxVideosPerRoom) {
                              _showMessage(
                                'Maximum 2 videos allowed per room.',
                              );
                              return;
                            }
                            _addMedia(
                              fileType: RoomMediaFileType.video,
                              existingPhotoCount: photos.length,
                              existingVideoCount: videos.length,
                            );
                          },
                          icon: const Icon(Icons.video_call_outlined),
                          label: const Text('Add Video'),
                        ),
                      ),
                    ],
                    if (widget.canShare) ...[
                      if (widget.canUpload) const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed:
                            items.isEmpty ? null : () => _shareMedia(items),
                        icon: const Icon(Icons.ios_share_outlined),
                        tooltip: 'Share all media',
                      ),
                    ],
                  ],
                ),
              ),
            Expanded(
              child: items.isEmpty
                  ? _EmptyGallery(canUpload: widget.canUpload)
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final media = items[index];
                        return _MediaTile(
                          media: media,
                          canDelete: widget.canDelete,
                          canShare: widget.canShare,
                          onTap: () => _openMedia(media),
                          onDelete: () => _deleteMedia(media),
                          onShare: () => _shareMedia([media]),
                          onRetry: () => _retryUpload(media),
                        );
                      },
                    ),
            ),
          ],
        );
      },
      error: (error, stack) => Center(
        child: Text('Unable to load media: $error'),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _addMedia({
    required String fileType,
    required int existingPhotoCount,
    required int existingVideoCount,
  }) async {
    final validationMessage = await _validateRoomAndVilla();
    if (validationMessage != null) {
      _showMessage(validationMessage);
      return;
    }
    final source = await _chooseSource();
    if (source == null) return;

    try {
      final picked = fileType == RoomMediaFileType.video
          ? await _pickerService.pickVideo(source: source)
          : await _pickerService.pickPhoto(source: source);
      if (picked == null || !mounted) return;
      final duplicateMessage = await _validateDuplicate(picked);
      if (duplicateMessage != null) {
        _showMessage(duplicateMessage);
        return;
      }
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomMediaPreviewScreen(
            villaId: widget.villaId,
            roomId: widget.roomId,
            initialMedia: [picked],
            existingPhotoCount: existingPhotoCount,
            existingVideoCount: existingVideoCount,
          ),
        ),
      );
    } on RoomMediaPickerException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Unable to select media.');
    }
  }

  Future<String?> _validateRoomAndVilla() async {
    final room = await ref.read(roomByIdProvider(widget.roomId).future);
    if (room == null || room.isDeleted) {
      return 'This room has been deleted. Media cannot be uploaded.';
    }
    final villa = await ref.read(villaByIdProvider(widget.villaId).future);
    if (villa == null || villa.isDeleted) {
      return 'This villa has been deleted. Media cannot be uploaded.';
    }
    return null;
  }

  Future<void> _syncPendingIfActive() async {
    final validationMessage = await _validateRoomAndVilla();
    if (validationMessage != null) return;
    await ref.read(roomMediaRepositoryProvider).syncPendingMedia(
          villaId: widget.villaId,
          roomId: widget.roomId,
        );
  }

  Future<String?> _validateDuplicate(PickedRoomMedia picked) async {
    final existing = await ref.read(roomMediaRepositoryProvider).getRoomMedia(
          villaId: widget.villaId,
          roomId: widget.roomId,
        );
    for (final item in existing) {
      final localPath = item.localPath.trim();
      if (localPath.isEmpty) continue;
      final file = File(localPath);
      if (!await file.exists()) continue;
      final length = await file.length();
      final key =
          '${item.fileType}:${file.uri.pathSegments.last.toLowerCase()}:$length';
      final sizeKey = '${item.fileType}:$length';
      if (key == picked.duplicateKey ||
          sizeKey == '${picked.fileType}:${picked.fileSize}') {
        return 'This media file has already been uploaded.';
      }
    }
    return null;
  }

  Future<ImageSource?> _chooseSource() {
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

  Future<void> _deleteMedia(RoomMedia media) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove media?'),
          content: const Text('This hides the media from the room gallery.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    final userId = ref.read(authProvider).currentUser?.id;
    await ref
        .read(roomMediaRepositoryProvider)
        .softDeleteMedia(media, deletedBy: userId);
    ref.invalidate(roomMediaProvider(_key));
  }

  Future<void> _retryUpload(RoomMedia media) async {
    final validationMessage = await _validateRoomAndVilla();
    if (validationMessage != null) {
      _showMessage(validationMessage);
      return;
    }
    final controller = RoomMediaUploadController();
    final progress = ValueNotifier<double>(0);
    if (!mounted) return;
    BuildContext? dialogContext;

    final dialogFuture = showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        dialogContext = context;
        return ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (context, value, _) {
            return AlertDialog(
                title: const Text('Retry Upload'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: value),
                    const SizedBox(height: 12),
                    Text('${(value * 100).round()}% uploaded'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: controller.cancel,
                    child: const Text('Cancel'),
                  ),
                ]);
          },
        );
      },
    );

    try {
      await ref.read(roomMediaRepositoryProvider).retryUpload(
        media,
        uploadController: controller,
        onProgress: (value) {
          progress.value = value.clamp(0, 1);
        },
      );
      ref.invalidate(roomMediaProvider(_key));
      _showMessage('Upload completed.');
    } on RoomMediaUploadCancelled {
      _showMessage('Upload cancelled.');
    } catch (_) {
      _showMessage('Upload failed. Please try again.');
    } finally {
      final activeDialogContext = dialogContext;
      if (activeDialogContext != null && activeDialogContext.mounted) {
        Navigator.pop(activeDialogContext);
      }
      await dialogFuture;
      progress.dispose();
    }
  }

  Future<void> _shareMedia(List<RoomMedia> media) async {
    final files = <XFile>[];
    final urls = <String>[];

    for (final item in media) {
      final localPath = item.localPath.trim();
      if (localPath.isNotEmpty && await File(localPath).exists()) {
        files.add(XFile(localPath));
      } else if (item.shareUrl.isNotEmpty) {
        urls.add(item.shareUrl);
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

    _showMessage('No shareable media is available yet.');
  }

  void _openMedia(RoomMedia media) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => media.isVideo
            ? _VideoViewer(media: media)
            : _ImageViewer(media: media),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _MediaTile extends StatelessWidget {
  final RoomMedia media;
  final bool canDelete;
  final bool canShare;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onRetry;

  const _MediaTile({
    required this.media,
    required this.canDelete,
    required this.canShare,
    required this.onTap,
    required this.onDelete,
    required this.onShare,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          InkWell(
            onTap: onTap,
            child: _MediaPreview(media: media),
          ),
          if (media.isVideo)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 36,
              ),
            ),
          if (media.syncStatus != RoomMediaSyncStatus.synced)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          if (canShare || canDelete)
            Positioned(
              top: 2,
              right: 2,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'share') onShare();
                  if (value == 'delete') onDelete();
                  if (value == 'retry') onRetry();
                },
                itemBuilder: (context) {
                  return [
                    if (media.syncStatus != RoomMediaSyncStatus.synced &&
                        media.localPath.trim().isNotEmpty)
                      const PopupMenuItem(
                        value: 'retry',
                        child: Row(
                          children: [
                            Icon(Icons.refresh_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Retry Upload'),
                          ],
                        ),
                      ),
                    if (canShare)
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.ios_share_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Share'),
                          ],
                        ),
                      ),
                    if (canDelete)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Remove', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ];
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _MediaPreview extends StatelessWidget {
  final RoomMedia media;

  const _MediaPreview({required this.media});

  @override
  Widget build(BuildContext context) {
    final localPath = media.localPath.trim();
    if (localPath.isNotEmpty && File(localPath).existsSync()) {
      if (media.isImage) {
        return Image.file(File(localPath), fit: BoxFit.cover);
      }
      return const ColoredBox(
        color: Color(0xFF111827),
        child: Icon(Icons.videocam_outlined, color: Colors.white),
      );
    }

    final imageUrl = media.thumbnailUrl.trim().isNotEmpty
        ? media.thumbnailUrl
        : media.downloadUrl;
    if (media.isImage && imageUrl.trim().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const ColoredBox(
          color: Color(0xFFE5E7EB),
        ),
        errorWidget: (context, url, error) => const ColoredBox(
          color: Color(0xFFE5E7EB),
          child: Icon(Icons.broken_image_outlined),
        ),
      );
    }

    return const ColoredBox(
      color: Color(0xFF111827),
      child: Icon(Icons.videocam_outlined, color: Colors.white),
    );
  }
}

class _ImageViewer extends StatelessWidget {
  final RoomMedia media;

  const _ImageViewer({required this.media});

  @override
  Widget build(BuildContext context) {
    final localPath = media.localPath.trim();
    final hasLocal = localPath.isNotEmpty && File(localPath).existsSync();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: InteractiveViewer(
          child: hasLocal
              ? Image.file(File(localPath))
              : CachedNetworkImage(imageUrl: media.downloadUrl),
        ),
      ),
    );
  }
}

class _VideoViewer extends StatefulWidget {
  final RoomMedia media;

  const _VideoViewer({required this.media});

  @override
  State<_VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<_VideoViewer> {
  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final localPath = widget.media.localPath.trim();
    final localFile = localPath.isNotEmpty ? File(localPath) : null;
    if (localFile != null && localFile.existsSync()) {
      _controller = VideoPlayerController.file(localFile);
    } else if (widget.media.downloadUrl.trim().isNotEmpty) {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.media.downloadUrl));
    }
    _controller?.initialize().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
      _controller?.play();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: controller == null
            ? const Text(
                'Video is not available yet.',
                style: TextStyle(color: Colors.white),
              )
            : !_ready
                ? const CircularProgressIndicator()
                : AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(controller),
                        IconButton.filled(
                          onPressed: () {
                            setState(() {
                              controller.value.isPlaying
                                  ? controller.pause()
                                  : controller.play();
                            });
                          },
                          icon: Icon(
                            controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  final bool canUpload;

  const _EmptyGallery({required this.canUpload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: AppColors.border,
            ),
            const SizedBox(height: 12),
            Text(
              canUpload ? 'Add room photos or videos' : 'No media yet',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
