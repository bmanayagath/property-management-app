import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/room_media_repository.dart';
import '../../data/services/firebase_storage_service.dart';
import '../../models/room_media.dart';

final roomMediaRepositoryProvider = Provider<RoomMediaRepository>((ref) {
  return RoomMediaRepository();
});

final roomMediaUploadProvider = Provider<RoomMediaUploadActions>((ref) {
  return RoomMediaUploadActions(ref.watch(roomMediaRepositoryProvider));
});

final roomMediaProvider = StreamProvider.family<List<RoomMedia>, RoomMediaKey>(
  (ref, key) {
    final repository = ref.watch(roomMediaRepositoryProvider);
    return repository.watchRoomMedia(
      villaId: key.villaId,
      roomId: key.roomId,
    );
  },
);

class RoomMediaKey {
  final String villaId;
  final String roomId;

  const RoomMediaKey({
    required this.villaId,
    required this.roomId,
  });

  @override
  bool operator ==(Object other) {
    return other is RoomMediaKey &&
        other.villaId == villaId &&
        other.roomId == roomId;
  }

  @override
  int get hashCode => Object.hash(villaId, roomId);
}

class RoomMediaUploadActions {
  final RoomMediaRepository _repository;

  const RoomMediaUploadActions(this._repository);

  Future<RoomMedia> uploadSingleRoomMedia(
    String mediaId, {
    RoomMediaUploadController? uploadController,
    ValueChanged<double>? onProgress,
  }) {
    return _repository.uploadSingleRoomMedia(
      mediaId,
      uploadController: uploadController,
      onProgress: onProgress,
    );
  }
}
