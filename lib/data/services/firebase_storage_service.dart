import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../models/room_media.dart';

class FirebaseStorageService {
  FirebaseStorageService({FirebaseStorage? storage}) : _storage = storage;

  FirebaseStorage? _storage;

  FirebaseStorage? get _safeStorage {
    if (Firebase.apps.isEmpty) return null;
    return _storage ??= FirebaseStorage.instance;
  }

  String imagePath({
    required String villaId,
    required String roomId,
    required String mediaId,
  }) {
    return 'villas/$villaId/rooms/$roomId/media/$mediaId.jpg';
  }

  String videoPath({
    required String villaId,
    required String roomId,
    required String mediaId,
  }) {
    return 'villas/$villaId/rooms/$roomId/media/$mediaId.mp4';
  }

  Future<StorageUploadResult> uploadImage({
    required File file,
    required String villaId,
    required String roomId,
    required String mediaId,
    RoomMediaUploadController? uploadController,
    ValueChanged<double>? onProgress,
  }) async {
    final path = imagePath(villaId: villaId, roomId: roomId, mediaId: mediaId);
    return _uploadFile(
      file: file,
      path: path,
      contentType: 'image/jpeg',
      uploadController: uploadController,
      onProgress: onProgress,
    );
  }

  Future<StorageUploadResult> uploadVideo({
    required File file,
    required String villaId,
    required String roomId,
    required String mediaId,
    String extension = 'mp4',
    RoomMediaUploadController? uploadController,
    ValueChanged<double>? onProgress,
  }) async {
    final normalizedExtension =
        extension.toLowerCase() == 'mov' ? 'mov' : 'mp4';
    final path = normalizedExtension == 'mov'
        ? 'villas/$villaId/rooms/$roomId/media/$mediaId.mov'
        : videoPath(villaId: villaId, roomId: roomId, mediaId: mediaId);
    return _uploadFile(
      file: file,
      path: path,
      contentType:
          normalizedExtension == 'mov' ? 'video/quicktime' : 'video/mp4',
      uploadController: uploadController,
      onProgress: onProgress,
    );
  }

  Future<StorageUploadResult> _uploadFile({
    required File file,
    required String path,
    required String contentType,
    RoomMediaUploadController? uploadController,
    ValueChanged<double>? onProgress,
  }) async {
    final storage = _requireStorage();
    final ref = storage.ref(path);
    final task = ref.putFile(
      file,
      SettableMetadata(contentType: contentType),
    );
    uploadController?._attach(task);
    final subscription = task.snapshotEvents.listen((snapshot) {
      final totalBytes = snapshot.totalBytes;
      if (totalBytes <= 0) return;
      onProgress?.call(snapshot.bytesTransferred / totalBytes);
    });
    try {
      await task;
    } on FirebaseException catch (error) {
      if (uploadController?.isCancelled == true || error.code == 'canceled') {
        throw const RoomMediaUploadCancelled();
      }
      rethrow;
    } finally {
      await subscription.cancel();
      uploadController?._detach(task);
    }
    return StorageUploadResult(
      storagePath: path,
      downloadUrl: await ref.getDownloadURL(),
    );
  }

  Future<void> deleteMedia(RoomMedia media) async {
    final storage = _safeStorage;
    if (storage == null || media.storagePath.trim().isEmpty) return;
    await storage.ref(media.storagePath).delete();
  }

  Future<String?> generateThumbnail(RoomMedia media) async {
    if (media.isImage) return media.downloadUrl;
    return null;
  }

  FirebaseStorage _requireStorage() {
    final storage = _safeStorage;
    if (storage == null) {
      throw StateError('Firebase Storage is unavailable.');
    }
    return storage;
  }
}

class RoomMediaUploadController {
  UploadTask? _task;
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  Future<void> cancel() async {
    _isCancelled = true;
    await _task?.cancel();
  }

  void _attach(UploadTask task) {
    _isCancelled = false;
    _task = task;
  }

  void _detach(UploadTask task) {
    if (identical(_task, task)) {
      _task = null;
    }
  }
}

class RoomMediaUploadCancelled implements Exception {
  const RoomMediaUploadCancelled();
}

class StorageUploadResult {
  final String storagePath;
  final String downloadUrl;

  const StorageUploadResult({
    required this.storagePath,
    required this.downloadUrl,
  });
}
