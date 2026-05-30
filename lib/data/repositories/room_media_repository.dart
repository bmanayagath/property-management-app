import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../models/room_media.dart';
import '../services/firebase_storage_service.dart';

class RoomMediaRepository {
  RoomMediaRepository({
    FirebaseFirestore? firestore,
    FirebaseStorageService? storageService,
  })  : _firestore = firestore,
        _storageService = storageService ?? FirebaseStorageService();

  static const collectionName = 'room_media';

  FirebaseFirestore? _firestore;
  final FirebaseStorageService _storageService;
  final _uuid = const Uuid();

  FirebaseFirestore? get _safeFirestore {
    if (Firebase.apps.isEmpty) return null;
    return _firestore ??= FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>>? get _collection {
    return _safeFirestore?.collection(collectionName);
  }

  String createId() => _uuid.v4();

  Future<RoomMedia> saveMedia(RoomMedia media) async {
    final collection = _requireCollection();
    await collection.doc(media.id).set(media.toJson(), SetOptions(merge: true));
    return media;
  }

  Stream<List<RoomMedia>> watchRoomMedia({
    required String villaId,
    required String roomId,
  }) {
    final collection = _collection;
    if (collection == null) return Stream.value(const []);

    return collection
        .where('roomId', isEqualTo: roomId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final media = snapshot.docs
          .map((doc) => RoomMedia.fromJson({...doc.data(), 'id': doc.id}))
          .where((item) => !item.isDeleted)
          .toList();
      media.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return media;
    });
  }

  Future<List<RoomMedia>> getRoomMedia({
    required String villaId,
    required String roomId,
  }) async {
    final collection = _collection;
    if (collection == null) return const [];

    final snapshot = await collection
        .where('roomId', isEqualTo: roomId)
        .where('isDeleted', isEqualTo: false)
        .get();
    final media = snapshot.docs
        .map((doc) => RoomMedia.fromJson({...doc.data(), 'id': doc.id}))
        .where((item) => !item.isDeleted)
        .toList();
    media.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return media;
  }

  Future<void> updateMedia(RoomMedia media) async {
    await saveMedia(media);
  }

  Future<void> softDeleteMedia(RoomMedia media, {String? deletedBy}) async {
    final updated = media.copyWith(
      isDeleted: true,
      deletedAt: DateTime.now(),
      deletedBy: deletedBy,
      syncStatus: RoomMediaSyncStatus.pending,
    );
    await saveMedia(updated);
  }

  Future<RoomMedia> uploadAndSave({
    required File file,
    required String fileType,
    required String villaId,
    required String roomId,
    String? createdBy,
    String caption = '',
    RoomMediaUploadController? uploadController,
    ValueChanged<double>? onProgress,
  }) async {
    final id = createId();
    final createdAt = DateTime.now();
    final pendingMedia = RoomMedia(
      id: id,
      villaId: villaId,
      roomId: roomId,
      fileType: fileType,
      localPath: file.path,
      storagePath: '',
      downloadUrl: '',
      thumbnailUrl: '',
      caption: caption,
      createdAt: createdAt,
      createdBy: createdBy,
      syncStatus: RoomMediaSyncStatus.pending,
    );

    try {
      await _trySaveMedia(pendingMedia);
      await _trySaveMedia(
        pendingMedia.copyWith(syncStatus: RoomMediaSyncStatus.uploading),
      );
      final uploaded = await _uploadFile(
        file: file,
        fileType: fileType,
        villaId: villaId,
        roomId: roomId,
        mediaId: id,
        uploadController: uploadController,
        onProgress: onProgress,
      );
      final syncedMedia = pendingMedia.copyWith(
        storagePath: uploaded.storagePath,
        downloadUrl: uploaded.downloadUrl,
        thumbnailUrl:
            fileType == RoomMediaFileType.image ? uploaded.downloadUrl : '',
        syncStatus: RoomMediaSyncStatus.synced,
        uploadedAt: DateTime.now(),
      );
      return saveMedia(syncedMedia);
    } on RoomMediaUploadCancelled {
      await _trySaveMedia(pendingMedia);
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('[RoomMedia] upload deferred for $id: $error');
      debugPrintStack(stackTrace: stackTrace);
      final failedMedia = pendingMedia.copyWith(
        syncStatus: RoomMediaSyncStatus.failed,
      );
      await _trySaveMedia(failedMedia);
      return failedMedia;
    }
  }

  Future<RoomMedia> retryUpload(
    RoomMedia media, {
    RoomMediaUploadController? uploadController,
    ValueChanged<double>? onProgress,
  }) async {
    final file = File(media.localPath);
    if (!await file.exists()) {
      throw StateError('Original media file is no longer available.');
    }
    await updateMedia(
        media.copyWith(syncStatus: RoomMediaSyncStatus.uploading));
    try {
      final uploaded = await _uploadFile(
        file: file,
        fileType: media.fileType,
        villaId: media.villaId,
        roomId: media.roomId,
        mediaId: media.id,
        uploadController: uploadController,
        onProgress: onProgress,
      );
      final updated = media.copyWith(
        storagePath: uploaded.storagePath,
        downloadUrl: uploaded.downloadUrl,
        thumbnailUrl: media.isImage ? uploaded.downloadUrl : '',
        syncStatus: RoomMediaSyncStatus.synced,
        uploadedAt: DateTime.now(),
      );
      return saveMedia(updated);
    } catch (error) {
      if (error is! RoomMediaUploadCancelled) {
        await _trySaveMedia(
          media.copyWith(
            syncStatus: RoomMediaSyncStatus.failed,
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> syncPendingMedia({
    required String villaId,
    required String roomId,
  }) {
    return uploadPendingRoomMedia(villaId: villaId, roomId: roomId);
  }

  Future<void> uploadPendingRoomMedia({
    required String villaId,
    required String roomId,
  }) async {
    final pending = await getRoomMedia(villaId: villaId, roomId: roomId);
    for (final media in pending.where(
      (item) =>
          item.syncStatus != RoomMediaSyncStatus.synced &&
          item.localPath.trim().isNotEmpty &&
          item.downloadUrl.trim().isEmpty,
    )) {
      final file = File(media.localPath);
      if (!await file.exists()) continue;
      try {
        await updateMedia(
          media.copyWith(syncStatus: RoomMediaSyncStatus.uploading),
        );
        final uploaded = await _uploadFile(
          file: file,
          fileType: media.fileType,
          villaId: media.villaId,
          roomId: media.roomId,
          mediaId: media.id,
        );
        await updateMedia(
          media.copyWith(
            storagePath: uploaded.storagePath,
            downloadUrl: uploaded.downloadUrl,
            thumbnailUrl: media.isImage ? uploaded.downloadUrl : '',
            syncStatus: RoomMediaSyncStatus.synced,
            uploadedAt: DateTime.now(),
          ),
        );
      } catch (error) {
        debugPrint('[RoomMedia] pending upload still unavailable: $error');
        await updateMedia(
          media.copyWith(
            syncStatus: RoomMediaSyncStatus.failed,
          ),
        );
      }
    }
  }

  Future<StorageUploadResult> _uploadFile({
    required File file,
    required String fileType,
    required String villaId,
    required String roomId,
    required String mediaId,
    RoomMediaUploadController? uploadController,
    ValueChanged<double>? onProgress,
  }) {
    if (fileType == RoomMediaFileType.video) {
      return _storageService.uploadVideo(
        file: file,
        villaId: villaId,
        roomId: roomId,
        mediaId: mediaId,
        extension: path.extension(file.path).replaceFirst('.', ''),
        uploadController: uploadController,
        onProgress: onProgress,
      );
    }
    return _storageService.uploadImage(
      file: file,
      villaId: villaId,
      roomId: roomId,
      mediaId: mediaId,
      uploadController: uploadController,
      onProgress: onProgress,
    );
  }

  CollectionReference<Map<String, dynamic>> _requireCollection() {
    final collection = _collection;
    if (collection == null) {
      throw StateError('Firestore is unavailable.');
    }
    return collection;
  }

  Future<bool> _trySaveMedia(RoomMedia media) async {
    try {
      await saveMedia(media);
      return true;
    } catch (error) {
      debugPrint('[RoomMedia] metadata save deferred: $error');
      return false;
    }
  }
}
