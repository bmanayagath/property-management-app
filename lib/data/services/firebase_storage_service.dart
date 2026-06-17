import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../models/room_media.dart';
import 'logger_service.dart';

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
    required String orgId,
    required String villaId,
    required String roomId,
    required String mediaId,
    String extension = 'jpg',
  }) {
    final normalizedExtension = _normalizeImageExtension(extension);
    return 'organizations/$orgId/villas/$villaId/rooms/$roomId/media/$mediaId.$normalizedExtension';
  }

  String videoPath({
    required String orgId,
    required String villaId,
    required String roomId,
    required String mediaId,
  }) {
    return 'organizations/$orgId/villas/$villaId/rooms/$roomId/media/$mediaId.mp4';
  }

  Future<StorageUploadResult> uploadImage({
    required File file,
    required String orgId,
    required String villaId,
    required String roomId,
    required String mediaId,
    String extension = 'jpg',
    RoomMediaUploadController? uploadController,
    ValueChanged<double>? onProgress,
  }) async {
    _validatePathSegment('orgId', orgId);
    _validatePathSegment('villaId', villaId);
    _validatePathSegment('roomId', roomId);
    _validatePathSegment('mediaId', mediaId);
    final normalizedExtension = _normalizeImageExtension(extension);
    final path = imagePath(
      villaId: villaId,
      orgId: orgId,
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
    required String orgId,
    required String villaId,
    required String roomId,
    required String mediaId,
    String extension = 'mp4',
    RoomMediaUploadController? uploadController,
    ValueChanged<double>? onProgress,
  }) async {
    _validatePathSegment('orgId', orgId);
    _validatePathSegment('villaId', villaId);
    _validatePathSegment('roomId', roomId);
    _validatePathSegment('mediaId', mediaId);
    final normalizedExtension =
        extension.toLowerCase() == 'mov' ? 'mov' : 'mp4';
    final path = normalizedExtension == 'mov'
        ? 'organizations/$orgId/villas/$villaId/rooms/$roomId/media/$mediaId.mov'
        : videoPath(
            orgId: orgId,
            villaId: villaId,
            roomId: roomId,
            mediaId: mediaId,
          );
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
    final currentUser = FirebaseAuth.instance.currentUser;
    final exists = await file.exists();
    final size = exists ? await file.length() : 0;
    final extension = _extensionFromPath(path);

    debugPrint(
        '[RoomMediaStorage] Firebase apps count=${Firebase.apps.length}');
    debugPrint(
        '[RoomMediaStorage] Firebase user uid=${currentUser?.uid ?? 'none'}');
    debugPrint('[RoomMediaStorage] Firebase app=${storage.app.name}');
    debugPrint('[RoomMediaStorage] Firebase Storage bucket=${storage.bucket}');
    debugPrint(
      '[RoomMediaStorage] Firebase options bucket=${storage.app.options.storageBucket}',
    );
    debugPrint('Upload user uid: ${currentUser?.uid}');
    debugPrint('Upload local path: ${file.path}');
    debugPrint('File exists: $exists');
    debugPrint('File size: $size');
    debugPrint('Storage path: $path');
    final logDetails = _uploadDetails(
      path: path,
      filePath: file.path,
      fileSize: size,
      bucketName: storage.bucket,
    );

    if (currentUser == null) {
      throw FirebaseException(
        plugin: 'firebase_storage',
        code: 'unauthenticated',
        message: 'No Firebase user is signed in for room media upload.',
      );
    }
    if (!exists) {
      throw RoomMediaLocalFileMissingException(file.path);
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
      final url = await ref.getDownloadURL();
      debugPrint('Upload success URL: $url');
      debugPrint('[RoomMediaStorage] upload success path=$path');
      await LoggerService.logUpload(
        screenName: 'FirebaseStorageService',
        operation: 'RoomMediaUpload',
        message: 'Room media upload succeeded',
        details: '$logDetails\nDownloadUrl: $url',
      );
      return StorageUploadResult(
        storagePath: path,
        downloadUrl: url,
      );
    } on FirebaseException catch (error, stackTrace) {
      if (uploadController?.isCancelled == true || error.code == 'canceled') {
        throw const RoomMediaUploadCancelled();
      }
      debugPrint('Firebase Storage upload failed');
      debugPrint('Code: ${error.code}');
      debugPrint('Message: ${error.message}');
      debugPrint('Plugin: ${error.plugin}');
      debugPrint('Stack: $stackTrace');
      await LoggerService.logUpload(
        screenName: 'FirebaseStorageService',
        operation: 'RoomMediaUpload',
        message: 'Firebase Storage upload failed',
        details:
            '$logDetails\nCode: ${error.code}\nMessage: ${error.message}\nPlugin: ${error.plugin}',
        stackTrace: stackTrace.toString(),
        level: 'ERROR',
      );
      await LoggerService.logFirebase(
        screenName: 'FirebaseStorageService',
        operation: 'RoomMediaUpload',
        message: 'Firebase Storage upload failed',
        details: '${error.code}: ${error.message}',
        stackTrace: stackTrace.toString(),
      );
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('Unknown upload error: $error');
      debugPrint('Stack: $stackTrace');
      await LoggerService.logUpload(
        screenName: 'FirebaseStorageService',
        operation: 'RoomMediaUpload',
        message: 'Room media upload failed',
        details: '$logDetails\n$error',
        stackTrace: stackTrace.toString(),
        level: 'ERROR',
      );
      rethrow;
    } finally {
      await subscription.cancel();
      uploadController?._detach(task);
    }
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

  void _validatePathSegment(String name, String value) {
    if (value.trim().isEmpty) {
      throw StateError('Room media storage path has an empty $name.');
    }
  }

  String _uploadDetails({
    required String path,
    required String filePath,
    required int fileSize,
    required String bucketName,
  }) {
    final segments = path.split('/');
    final orgId = segments.length > 1 ? segments[1] : '';
    final villaId = segments.length > 3 ? segments[3] : '';
    final roomId = segments.length > 5 ? segments[5] : '';
    final fileName = segments.isNotEmpty ? segments.last : '';
    final mediaId = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;
    return [
      'OrgId: $orgId',
      'VillaId: $villaId',
      'RoomId: $roomId',
      'MediaId: $mediaId',
      'FilePath: $filePath',
      'FileSize: $fileSize',
      'StoragePath: $path',
      'BucketName: $bucketName',
    ].join('\n');
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

class RoomMediaLocalFileMissingException implements Exception {
  final String path;

  const RoomMediaLocalFileMissingException(this.path);

  String get message => 'Selected media file is no longer available.';

  @override
  String toString() => '$message Path: $path';
}

class StorageUploadResult {
  final String storagePath;
  final String downloadUrl;

  const StorageUploadResult({
    required this.storagePath,
    required this.downloadUrl,
  });
}
