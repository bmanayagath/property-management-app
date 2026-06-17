import 'package:cloud_firestore/cloud_firestore.dart';

class RoomMedia {
  final String id;
  final String orgId;
  final String villaId;
  final String roomId;
  final String fileType;
  final String localPath;
  final String storagePath;
  final String downloadUrl;
  final String thumbnailUrl;
  final String caption;
  final DateTime createdAt;
  final String? createdBy;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? deletedBy;
  final String syncStatus;
  final DateTime? uploadedAt;

  const RoomMedia({
    required this.id,
    this.orgId = 'default_org',
    required this.villaId,
    required this.roomId,
    required this.fileType,
    required this.localPath,
    required this.storagePath,
    required this.downloadUrl,
    required this.thumbnailUrl,
    required this.caption,
    required this.createdAt,
    this.createdBy,
    this.isDeleted = false,
    this.deletedAt,
    this.deletedBy,
    this.syncStatus = RoomMediaSyncStatus.pending,
    this.uploadedAt,
  });

  bool get isImage => fileType == RoomMediaFileType.image;

  bool get isVideo => fileType == RoomMediaFileType.video;

  bool get hasCloudFile => downloadUrl.trim().isNotEmpty;

  bool get hasLocalFile => localPath.trim().isNotEmpty;

  String get shareUrl => downloadUrl.trim();

  String get fileName {
    final source = storagePath.trim().isNotEmpty ? storagePath : localPath;
    if (source.trim().isEmpty) return '';
    final normalized = source.replaceAll(r'\', '/');
    return normalized.split('/').last;
  }

  RoomMedia copyWith({
    String? id,
    String? orgId,
    String? villaId,
    String? roomId,
    String? fileType,
    String? localPath,
    String? storagePath,
    String? downloadUrl,
    String? thumbnailUrl,
    String? caption,
    DateTime? createdAt,
    String? createdBy,
    bool clearCreatedBy = false,
    bool? isDeleted,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    String? deletedBy,
    bool clearDeletedBy = false,
    String? syncStatus,
    DateTime? uploadedAt,
    bool clearUploadedAt = false,
  }) {
    return RoomMedia(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      villaId: villaId ?? this.villaId,
      roomId: roomId ?? this.roomId,
      fileType: fileType ?? this.fileType,
      localPath: localPath ?? this.localPath,
      storagePath: storagePath ?? this.storagePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      createdBy: clearCreatedBy ? null : createdBy ?? this.createdBy,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      deletedBy: clearDeletedBy ? null : deletedBy ?? this.deletedBy,
      syncStatus: syncStatus ?? this.syncStatus,
      uploadedAt: clearUploadedAt ? null : uploadedAt ?? this.uploadedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mediaId': id,
      'orgId': orgId,
      'villaId': villaId,
      'roomId': roomId,
      'fileType': fileType,
      'type': fileType == RoomMediaFileType.image ? 'photo' : fileType,
      'localPath': localPath,
      'storagePath': storagePath,
      'downloadUrl': downloadUrl,
      'thumbnailUrl': thumbnailUrl,
      'fileName': fileName,
      'caption': caption,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'uploadedBy': createdBy,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt == null ? null : Timestamp.fromDate(deletedAt!),
      'deletedBy': deletedBy,
      'syncStatus': syncStatus,
      'uploadedAt': uploadedAt == null ? null : Timestamp.fromDate(uploadedAt!),
    };
  }

  Map<String, dynamic> toFirestoreJson() {
    final data = toJson();
    data.remove('localPath');
    return data;
  }

  factory RoomMedia.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['mediaId'] as String? ?? '';
    final rawType =
        json['fileType'] as String? ?? json['type'] as String? ?? '';
    final fileType = rawType == 'photo'
        ? RoomMediaFileType.image
        : rawType == RoomMediaFileType.video
            ? RoomMediaFileType.video
            : RoomMediaFileType.image;
    final uploadedAt = _dateFromJson(json['uploadedAt']);
    return RoomMedia(
      id: id,
      orgId: json['orgId'] as String? ?? 'default_org',
      villaId: json['villaId'] as String? ?? '',
      roomId: json['roomId'] as String? ?? '',
      fileType: fileType,
      localPath: json['localPath'] as String? ?? '',
      storagePath: json['storagePath'] as String? ?? '',
      downloadUrl: json['downloadUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      createdAt:
          _dateFromJson(json['createdAt']) ?? uploadedAt ?? DateTime.now(),
      createdBy: json['createdBy'] as String? ?? json['uploadedBy'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: _dateFromJson(json['deletedAt']),
      deletedBy: json['deletedBy'] as String?,
      syncStatus: json['syncStatus'] as String? ?? RoomMediaSyncStatus.synced,
      uploadedAt: uploadedAt,
    );
  }

  static DateTime? _dateFromJson(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class RoomMediaFileType {
  RoomMediaFileType._();

  static const image = 'image';
  static const video = 'video';
}

class RoomMediaSyncStatus {
  RoomMediaSyncStatus._();

  static const pending = 'pending';
  static const uploading = 'uploading';
  static const synced = 'synced';
  static const failed = 'failed';
}
