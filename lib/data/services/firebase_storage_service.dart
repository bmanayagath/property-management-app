import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../models/room_media.dart';

class FirebaseStorageService {
  FirebaseStorageService({FirebaseStorage? storage}) : _storage = storage;

  static const bucketUrl =
      'gs://investment-calculator-811fd.firebasestorage.app';

  FirebaseStorage? _storage;

  FirebaseStorage? get _safeStorage {
    if (Firebase.apps.isEmpty) return null;
    return _storage ??= FirebaseStorage.instanceFor(bucket: bucketUrl);
  }

  String imagePath({
    required String villaId,
    required String roomId,
    required String mediaId,
    String extension = 'jpg',
  }) {
    final normalizedExtension = _normalizeImageExtension(extension);
    return 'villas/$villaId/rooms/$roomId/media/$mediaId.$normalizedExtension';
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
    String extension = 'jpg',
    RoomMediaUploadController? uploadController,
    ValueChanged<double>? onProgress,
  }) async {
    final normalizedExtension = _normalizeImageExtension(extension);
    final path = imagePath(
      villaId: villaId,
      roomId: roomId,
      mediaId: mediaId,
      extension: normalizedExtension,
    );
    return _uploadFile(
      file: file,
      path: path,
      contentType: normalizedExtension == 'png' ? 'image/png' : 'image/jpeg',
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
    final user = FirebaseAuth.instance.currentUser;
    final exists = await file.exists();
    final size = exists ? await file.length() : 0;
    final extension = _extensionFromPath(path);

    debugPrint(
        '[RoomMediaStorage] Firebase apps count=${Firebase.apps.length}');
    debugPrint('[RoomMediaStorage] Firebase user uid=${user?.uid ?? 'none'}');
    debugPrint('[RoomMediaStorage] Firebase app=${storage.app.name}');
    debugPrint('[RoomMediaStorage] Firebase Storage bucket=${storage.bucket}');
    debugPrint(
      '[RoomMediaStorage] Firebase options bucket=${storage.app.options.storageBucket}',
    );
    debugPrint('[RoomMediaStorage] local file path=${file.path}');
    debugPrint('[RoomMediaStorage] local file exists=$exists');
    debugPrint('[RoomMediaStorage] local file size=$size bytes');
    debugPrint('[RoomMediaStorage] storage path=$path');

    if (user == null) {
      throw FirebaseException(
        plugin: 'firebase_storage',
        code: 'unauthenticated',
        message: 'No Firebase user is signed in for room media upload.',
      );
    }
    if (!exists) {
      throw StateError('Room media local file does not exist: ${file.path}');
    }
    if (size <= 0) {
      throw StateError('Room media local file is empty: ${file.path}');
    }
    if (extension.isEmpty) {
      throw StateError('Room media storage path has no file extension: $path');
    }

    final ref = storage.ref().child(path);
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
      debugPrint('[RoomMediaStorage] FirebaseException code=${error.code}');
      debugPrint(
        '[RoomMediaStorage] FirebaseException message=${error.message}',
      );
      if (uploadController?.isCancelled == true || error.code == 'canceled') {
        throw const RoomMediaUploadCancelled();
      }
      rethrow;
    } catch (error) {
      debugPrint('[RoomMediaStorage] upload failed: $error');
      rethrow;
    } finally {
      await subscription.cancel();
      uploadController?._detach(task);
    }
    debugPrint('[RoomMediaStorage] upload success path=$path');
    return StorageUploadResult(
      storagePath: path,
      downloadUrl: await ref.getDownloadURL(),
    );
  }

  Future<void> deleteMedia(RoomMedia media) async {
    await deleteFile(media.storagePath);
  }

  Future<void> deleteFile(String storagePath) async {
    final storage = _safeStorage;
    if (storage == null || storagePath.trim().isEmpty) return;
    await storage.ref(storagePath).delete();
  }

  Future<String> getDownloadUrl(String storagePath) async {
    final storage = _requireStorage();
    return storage.ref(storagePath).getDownloadURL();
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

  String _extensionFromPath(String value) {
    final index = value.lastIndexOf('.');
    if (index == -1 || index == value.length - 1) return '';
    return value.substring(index + 1).toLowerCase();
  }

  String _normalizeImageExtension(String value) {
    final extension = value.trim().toLowerCase().replaceFirst('.', '');
    if (extension == 'png') return 'png';
    if (extension == 'jpeg') return 'jpg';
    return 'jpg';
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
