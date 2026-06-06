import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../models/room_media.dart';

class RoomMediaPickerService {
  RoomMediaPickerService({ImagePicker? picker}) : _picker = picker;

  static const maxPhotosPerRoom = 20;
  static const maxVideosPerRoom = 10;
  static const maxImageWidth = 1200;
  static const maxImageBytes = 1024 * 1024;
  static const maxVideoBytes = 50 * 1024 * 1024;
  static const maxVideoDuration = Duration(seconds: 90);
  static const allowedImageExtensions = {'jpg', 'jpeg', 'png'};
  static const allowedVideoExtensions = {'mp4', 'mov'};

  final ImagePicker? _picker;

  ImagePicker get _safePicker => _picker ?? ImagePicker();

  Future<PickedRoomMedia?> pickPhoto({
    ImageSource source = ImageSource.gallery,
  }) async {
    final picked = await _safePicker.pickImage(source: source);
    if (picked == null) return null;
    final file = File(picked.path);
    _validateExtension(
      file,
      allowedImageExtensions,
      'Only JPG, JPEG, and PNG images are allowed.',
    );
    final compressed = await compressImage(file);
    final size = await compressed.length();
    if (size > maxImageBytes) {
      throw const RoomMediaPickerException(
        'Image must be 1 MB or less after compression.',
      );
    }
    return PickedRoomMedia(
      file: compressed,
      fileType: RoomMediaFileType.image,
      sourceName: path.basename(file.path),
      sourceSize: await file.length(),
    );
  }

  Future<PickedRoomMedia?> pickVideo({
    ImageSource source = ImageSource.gallery,
  }) async {
    final picked = await _safePicker.pickVideo(
      source: source,
      maxDuration: maxVideoDuration,
    );
    if (picked == null) return null;

    final file = File(picked.path);
    _validateExtension(
      file,
      allowedVideoExtensions,
      'Only MP4 and MOV videos are allowed.',
    );
    if (await file.length() > maxVideoBytes) {
      throw const RoomMediaPickerException(
        'Video size cannot exceed 50 MB.',
      );
    }
    final videoValidation = await validateVideo(file);
    if (!videoValidation.isValid) {
      throw RoomMediaPickerException(videoValidation.message);
    }

    return PickedRoomMedia(
      file: file,
      fileType: RoomMediaFileType.video,
      sourceName: path.basename(file.path),
      sourceSize: await file.length(),
    );
  }

  Future<File> compressImage(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return file;

    var width = decoded.width > maxImageWidth ? maxImageWidth : decoded.width;
    var resized =
        decoded.width > width ? img.copyResize(decoded, width: width) : decoded;
    var quality = 75;
    var encoded = img.encodeJpg(resized, quality: quality);

    while (encoded.length > maxImageBytes && quality > 45) {
      quality -= 10;
      encoded = img.encodeJpg(resized, quality: quality);
    }

    while (encoded.length > maxImageBytes && width > 640) {
      width = (width * 0.85).round();
      resized = img.copyResize(decoded, width: width);
      encoded = img.encodeJpg(resized, quality: quality);
    }

    final directory = await getTemporaryDirectory();
    final filename = 'room_media_${DateTime.now().microsecondsSinceEpoch}.jpg';
    final compressed = File(path.join(directory.path, filename));
    await compressed.writeAsBytes(encoded, flush: true);
    return compressed;
  }

  Future<RoomMediaValidationResult> validateVideo(File file) async {
    if (await file.length() > maxVideoBytes) {
      return const RoomMediaValidationResult.invalid(
        'Video size cannot exceed 50 MB.',
      );
    }
    if (kIsWeb) return const RoomMediaValidationResult.valid();
    final controller = VideoPlayerController.file(file);
    try {
      await controller.initialize();
      if (controller.value.duration > maxVideoDuration) {
        return const RoomMediaValidationResult.invalid(
          'Video must be 90 seconds or less.',
        );
      }
      return const RoomMediaValidationResult.valid();
    } finally {
      await controller.dispose();
    }
  }

  void _validateExtension(
    File file,
    Set<String> allowedExtensions,
    String message,
  ) {
    final extension =
        path.extension(file.path).replaceFirst('.', '').toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      throw RoomMediaPickerException(message);
    }
  }
}

class PickedRoomMedia {
  final File file;
  final String fileType;
  final int fileSize;
  final String sourceName;
  final int sourceSize;

  PickedRoomMedia({
    required this.file,
    required this.fileType,
    String? sourceName,
    int? sourceSize,
  })  : fileSize = file.existsSync() ? file.lengthSync() : 0,
        sourceName = sourceName ?? path.basename(file.path),
        sourceSize = sourceSize ?? (file.existsSync() ? file.lengthSync() : 0);

  String get duplicateKey =>
      '$fileType:${sourceName.toLowerCase()}:$sourceSize';
}

class RoomMediaPickerException implements Exception {
  final String message;

  const RoomMediaPickerException(this.message);

  @override
  String toString() => message;
}

class RoomMediaValidationResult {
  final bool isValid;
  final String message;

  const RoomMediaValidationResult.valid()
      : isValid = true,
        message = '';

  const RoomMediaValidationResult.invalid(this.message) : isValid = false;
}
