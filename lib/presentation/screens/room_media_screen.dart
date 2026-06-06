import 'package:flutter/material.dart';

import '../widgets/premium_widgets.dart';
import '../widgets/room_media_gallery_widget.dart';

class RoomMediaScreen extends StatelessWidget {
  final String villaId;
  final String roomId;
  final String roomName;
  final bool canUpload;
  final bool canDelete;
  final bool canShare;

  const RoomMediaScreen({
    super.key,
    required this.villaId,
    required this.roomId,
    required this.roomName,
    required this.canUpload,
    required this.canDelete,
    required this.canShare,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      appBar: AppBar(
        title: Text('$roomName Media'),
      ),
      body: RoomMediaGalleryWidget(
        villaId: villaId,
        roomId: roomId,
        roomName: roomName,
        canUpload: canUpload,
        canDelete: canDelete,
        canShare: canShare,
      ),
    );
  }
}
