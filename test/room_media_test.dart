import 'package:flutter_test/flutter_test.dart';
import 'package:villabooks/data/services/firebase_storage_service.dart';
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
