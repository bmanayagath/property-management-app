import 'package:flutter_test/flutter_test.dart';
import 'package:villabooks/data/services/firebase_storage_service.dart';
import 'package:villabooks/data/services/room_media_picker_service.dart';
import 'package:villabooks/models/room_media.dart';

void main() {
  test('Firestore payload does not include a local filesystem path', () {
    final media = RoomMedia(
      id: 'media-1',
      villaId: 'villa-1',
      roomId: 'room-1',
      fileType: RoomMediaFileType.image,
      localPath: r'C:\Users\BIJUMA~1\AppData\Local\Temp\photo.jpg',
      storagePath: 'villas/villa-1/rooms/room-1/media/media-1.jpg',
      downloadUrl: 'https://example.com/photo.jpg',
      thumbnailUrl: 'https://example.com/photo.jpg',
      caption: '',
      createdAt: DateTime(2026, 5, 30),
      syncStatus: RoomMediaSyncStatus.synced,
      uploadedAt: DateTime(2026, 5, 30),
    );

    expect(media.toJson()['localPath'], isNotEmpty);
    expect(media.toFirestoreJson().containsKey('localPath'), isFalse);
    expect(media.toFirestoreJson()['mediaId'], 'media-1');
    expect(media.toFirestoreJson()['type'], 'photo');
    expect(media.toFirestoreJson()['fileName'], 'media-1.jpg');
    expect(media.toFirestoreJson()['uploadedBy'], isNull);
  });

  test('Firestore aliases support the room media metadata schema', () {
    final uploadedAt = DateTime(2026, 6, 6);
    final media = RoomMedia.fromJson({
      'mediaId': 'media-2',
      'villaId': 'villa-1',
      'roomId': 'room-1',
      'type': 'video',
      'downloadUrl': 'https://example.com/video.mp4',
      'thumbnailUrl': '',
      'fileName': 'video.mp4',
      'uploadedBy': 'user-1',
      'uploadedAt': uploadedAt,
      'caption': 'Balcony view',
    });

    expect(media.id, 'media-2');
    expect(media.fileType, RoomMediaFileType.video);
    expect(media.createdBy, 'user-1');
    expect(media.createdAt, uploadedAt);
    expect(media.uploadedAt, uploadedAt);
  });

  test('Room media limits allow 20 photos and 10 videos', () {
    expect(RoomMediaPickerService.maxPhotosPerRoom, 20);
    expect(RoomMediaPickerService.maxVideosPerRoom, 10);
  });

  test('Firebase Storage paths use villa room media format', () {
    final service = FirebaseStorageService();

    expect(
      service.imagePath(
        villaId: 'villa123',
        roomId: 'room456',
        mediaId: 'media789',
      ),
      'villas/villa123/rooms/room456/media/media789.jpg',
    );
    expect(
      service.videoPath(
        villaId: 'villa123',
        roomId: 'room456',
        mediaId: 'media789',
      ),
      'villas/villa123/rooms/room456/media/media789.mp4',
    );
  });
}
