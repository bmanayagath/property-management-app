import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../data/repositories/room_media_repository.dart';
import '../../data/services/firebase_storage_service.dart';
import '../../models/room_media.dart';
import 'active_org_provider.dart';

final roomMediaRepositoryProvider = Provider<RoomMediaRepository>((ref) {
  return RoomMediaRepository(orgId: ref.watch(activeOrgProvider));
});

final roomMediaUploadProvider = Provider<RoomMediaUploadActions>((ref) {
  return RoomMediaUploadActions(ref.watch(roomMediaRepositoryProvider));
});

final roomMediaAuthStateProvider = StreamProvider<firebase_auth.User?>((ref) {
  return firebase_auth.FirebaseAuth.instance.authStateChanges();
});

final roomMediaProvider = StreamProvider.family<List<RoomMedia>, RoomMediaKey>(
  (ref, key) {
    final authUser = ref.watch(roomMediaAuthStateProvider).valueOrNull;
    if (authUser == null) {
      debugPrint(
          '[RoomMediaProvider] user is logged out; media query skipped.');
      return Stream.value(const <RoomMedia>[]);
    }
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
