import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../core/constants/app_colors.dart';
import '../../data/services/firebase_storage_service.dart';
import '../../data/services/room_media_picker_service.dart';
import '../../models/room_media.dart';
import '../providers/auth_provider.dart';
import '../providers/room_media_provider.dart';
import '../providers/room_provider.dart';
import '../providers/villa_provider.dart';

class RoomMediaPreviewScreen extends ConsumerStatefulWidget {
  final String villaId;
  final String roomId;
  final List<PickedRoomMedia> initialMedia;
  final int existingPhotoCount;
  final int existingVideoCount;

  const RoomMediaPreviewScreen({
    super.key,
    required this.villaId,
    required this.roomId,
    required this.initialMedia,
    this.existingPhotoCount = 0,
    this.existingVideoCount = 0,
  });

  @override
  ConsumerState<RoomMediaPreviewScreen> createState() =>
      _RoomMediaPreviewScreenState();
}

class _RoomMediaPreviewScreenState
    extends ConsumerState<RoomMediaPreviewScreen> {
  final _pickerService = RoomMediaPickerService();
  final _captionController = TextEditingController();
  final List<PickedRoomMedia> _media = [];
  RoomMediaUploadController? _uploadController;
  bool _isUploading = false;
  double _uploadProgress = 0;
  int _uploadIndex = 0;
  bool _canRetry = false;

  @override
  void initState() {
    super.initState();
    _media.addAll(widget.initialMedia);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  int get _photoCount {
    return widget.existingPhotoCount +
        _media.where((item) => item.fileType == RoomMediaFileType.image).length;
  }

  int get _videoCount {
    return widget.existingVideoCount +
        _media.where((item) => item.fileType == RoomMediaFileType.video).length;
  }

  int get _totalUploads => _media.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Media'),
        actions: [
          TextButton(
            onPressed: _isUploading || _media.isEmpty ? null : _upload,
            child: _isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_canRetry ? 'Retry' : 'Upload'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isUploading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(value: _uploadProgress),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Uploading $_uploadIndex of $_totalUploads',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _cancelUpload,
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Caption',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              maxLength: 120,
            ),
          ),
          Expanded(
            child: _media.isEmpty
                ? Center(
                    child: Text(
                      'No media selected',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.92,
                    ),
                    itemCount: _media.length,
                    itemBuilder: (context, index) {
                      return _PreviewTile(
                        media: _media[index],
                        onRemove: () {
                          setState(() => _media.removeAt(index));
                        },
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isUploading ? null : _addPhoto,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(
                        'Add Photo ($_photoCount/${RoomMediaPickerService.maxPhotosPerRoom})',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isUploading ? null : _addVideo,
                      icon: const Icon(Icons.video_call_outlined),
                      label: Text(
                        'Add Video ($_videoCount/${RoomMediaPickerService.maxVideosPerRoom})',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addPhoto() async {
    if (_photoCount >= RoomMediaPickerService.maxPhotosPerRoom) {
      _showMessage('Maximum 10 photos allowed per room.');
      return;
    }
    final source = await _chooseSource();
    if (source == null) return;
    await _pick(
      () => _pickerService.pickPhoto(source: source),
    );
  }

  Future<void> _addVideo() async {
    if (_videoCount >= RoomMediaPickerService.maxVideosPerRoom) {
      _showMessage('Maximum 2 videos allowed per room.');
      return;
    }
    final source = await _chooseSource();
    if (source == null) return;
    await _pick(
      () => _pickerService.pickVideo(source: source),
    );
  }

  Future<void> _pick(Future<PickedRoomMedia?> Function() action) async {
    try {
      final picked = await action();
      if (picked == null || !mounted) return;
      if (_hasDuplicate(picked)) {
        _showMessage('This media file has already been selected.');
        return;
      }
      setState(() => _media.add(picked));
    } on RoomMediaPickerException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Unable to select media.');
    }
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

  Future<void> _upload() async {
    final validationMessage = await _validateBeforeUpload();
    if (validationMessage != null) {
      _showMessage(validationMessage);
      return;
    }

    final uploadController = RoomMediaUploadController();
    _uploadController = uploadController;
    setState(() {
      _isUploading = true;
      _canRetry = false;
      _uploadProgress = 0;
      _uploadIndex = 0;
    });
    final repository = ref.read(roomMediaRepositoryProvider);
    final userId = ref.read(authProvider).currentUser?.id;
    final caption = _captionController.text.trim();

    try {
      final uploadItems = List<PickedRoomMedia>.from(_media);
      for (var index = 0; index < uploadItems.length; index++) {
        final item = uploadItems[index];
        if (uploadController.isCancelled) {
          throw const RoomMediaUploadCancelled();
        }
        setState(() {
          _uploadIndex = index + 1;
          _uploadProgress = 0;
        });
        await repository.uploadAndSave(
          file: item.file,
          fileType: item.fileType,
          villaId: widget.villaId,
          roomId: widget.roomId,
          createdBy: userId,
          caption: caption,
          uploadController: uploadController,
          onProgress: (value) {
            if (!mounted) return;
            setState(() => _uploadProgress = value.clamp(0, 1));
          },
        );
      }
      ref.invalidate(
        roomMediaProvider(
          RoomMediaKey(villaId: widget.villaId, roomId: widget.roomId),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on RoomMediaUploadCancelled {
      _showMessage('Upload cancelled.');
    } catch (_) {
      _showMessage('Upload failed. Please try again.');
      if (mounted) {
        setState(() => _canRetry = true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0;
        });
      }
      if (identical(_uploadController, uploadController)) {
        _uploadController = null;
      }
    }
  }

  Future<String?> _validateBeforeUpload() async {
    final room = await ref.read(roomByIdProvider(widget.roomId).future);
    if (room == null || room.isDeleted) {
      return 'This room has been deleted. Media cannot be uploaded.';
    }
    final villa = await ref.read(villaByIdProvider(widget.villaId).future);
    if (villa == null || villa.isDeleted) {
      return 'This villa has been deleted. Media cannot be uploaded.';
    }
    if (_photoCount > RoomMediaPickerService.maxPhotosPerRoom) {
      return 'Maximum 10 photos allowed per room.';
    }
    if (_videoCount > RoomMediaPickerService.maxVideosPerRoom) {
      return 'Maximum 2 videos allowed per room.';
    }

    final seen = <String>{};
    for (final item in _media) {
      if (!seen.add(item.duplicateKey)) {
        return 'Duplicate media files are not allowed.';
      }
    }

    final existing = await ref.read(roomMediaRepositoryProvider).getRoomMedia(
          villaId: widget.villaId,
          roomId: widget.roomId,
        );
    final existingKeys = <String>{};
    final existingSizes = <String>{};
    for (final item in existing) {
      final localPath = item.localPath.trim();
      if (localPath.isEmpty) continue;
      final file = File(localPath);
      if (!await file.exists()) continue;
      final length = await file.length();
      existingKeys.add(
        '${item.fileType}:${file.uri.pathSegments.last.toLowerCase()}:$length',
      );
      existingSizes.add('${item.fileType}:$length');
    }
    for (final item in _media) {
      if (existingKeys.contains(item.duplicateKey) ||
          existingSizes.contains('${item.fileType}:${item.fileSize}')) {
        return 'This media file has already been uploaded.';
      }
    }

    return null;
  }

  bool _hasDuplicate(PickedRoomMedia media) {
    return _media.any((item) => item.duplicateKey == media.duplicateKey);
  }

  Future<void> _cancelUpload() async {
    await _uploadController?.cancel();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  final PickedRoomMedia media;
  final VoidCallback onRemove;

  const _PreviewTile({
    required this.media,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          media.fileType == RoomMediaFileType.image
              ? Image.file(media.file, fit: BoxFit.cover)
              : _LocalVideoPreview(file: media.file),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton.filled(
              onPressed: onRemove,
              icon: const Icon(Icons.close),
              tooltip: 'Remove',
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalVideoPreview extends StatefulWidget {
  final File file;

  const _LocalVideoPreview({required this.file});

  @override
  State<_LocalVideoPreview> createState() => _LocalVideoPreviewState();
}

class _LocalVideoPreviewState extends State<_LocalVideoPreview> {
  late final VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        if (mounted) setState(() => _ready = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const ColoredBox(
        color: Colors.black12,
        child: Center(child: Icon(Icons.play_circle_outline)),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
        const Center(
          child: Icon(
            Icons.play_circle_fill,
            color: Colors.white,
            size: 42,
          ),
        ),
      ],
    );
  }
}
