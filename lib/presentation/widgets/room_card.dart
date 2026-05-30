import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/room.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCallTenant;
  final VoidCallback? onWhatsappTenant;
  final VoidCallback? onAddPhoto;
  final VoidCallback? onAddVideo;
  final VoidCallback? onViewMedia;
  final VoidCallback? onShareMedia;
  final String? pendingRent;
  final String pendingRentLabel;

  const RoomCard({
    Key? key,
    required this.room,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onCallTenant,
    this.onWhatsappTenant,
    this.onAddPhoto,
    this.onAddVideo,
    this.onViewMedia,
    this.onShareMedia,
    this.pendingRent,
    this.pendingRentLabel = 'Pending',
  }) : super(key: key);

  Color _getStatusColor(bool isOccupied) {
    return isOccupied ? AppColors.success : AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        _getStatusColor(room.isOccupied).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    room.isOccupied
                        ? Icons.meeting_room_outlined
                        : Icons.sensor_door_outlined,
                    color: _getStatusColor(room.isOccupied),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.displayName,
                        style: const TextStyle(
                          color: Color(0xFF060B26),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(
                  label: room.isOccupied ? 'Occupied' : 'Vacant',
                  color: _getStatusColor(room.isOccupied),
                ),
                if (onCallTenant != null) ...[
                  const SizedBox(width: 6),
                  _TenantActionButton(
                    tooltip: 'Call tenant',
                    icon: Icons.phone_rounded,
                    backgroundColor: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF2563EB),
                    onPressed: onCallTenant!,
                  ),
                ],
                if (onWhatsappTenant != null) ...[
                  const SizedBox(width: 6),
                  _TenantActionButton(
                    tooltip: 'WhatsApp tenant',
                    icon: Icons.chat_rounded,
                    backgroundColor: const Color(0xFFEAFBF0),
                    iconColor: const Color(0xFF25D366),
                    onPressed: onWhatsappTenant!,
                  ),
                ],
                if (onEdit != null ||
                    onDelete != null ||
                    onAddPhoto != null ||
                    onAddVideo != null ||
                    onViewMedia != null ||
                    onShareMedia != null)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!();
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      } else if (value == 'add_photo' && onAddPhoto != null) {
                        onAddPhoto!();
                      } else if (value == 'add_video' && onAddVideo != null) {
                        onAddVideo!();
                      } else if (value == 'view_media' && onViewMedia != null) {
                        onViewMedia!();
                      } else if (value == 'share_media' &&
                          onShareMedia != null) {
                        onShareMedia!();
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        if (onAddPhoto != null)
                          const PopupMenuItem(
                            value: 'add_photo',
                            child: Row(
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 18),
                                SizedBox(width: 8),
                                Text('Add Photo'),
                              ],
                            ),
                          ),
                        if (onAddVideo != null)
                          const PopupMenuItem(
                            value: 'add_video',
                            child: Row(
                              children: [
                                Icon(Icons.video_call_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Add Video'),
                              ],
                            ),
                          ),
                        if (onViewMedia != null)
                          const PopupMenuItem(
                            value: 'view_media',
                            child: Row(
                              children: [
                                Icon(Icons.photo_library_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('View Media'),
                              ],
                            ),
                          ),
                        if (onShareMedia != null)
                          const PopupMenuItem(
                            value: 'share_media',
                            child: Row(
                              children: [
                                Icon(Icons.ios_share_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Share Media'),
                              ],
                            ),
                          ),
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                      ];
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Rent',
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(room.monthlyRent),
                        style: const TextStyle(
                          color: Color(0xFF060B26),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tenant',
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        room.tenantName.isEmpty ? 'Vacant' : room.tenantName,
                        style: const TextStyle(
                          color: Color(0xFF060B26),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Day',
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${room.paymentDueDay}',
                        style: const TextStyle(
                          color: Color(0xFF060B26),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (pendingRent != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pendingRentLabel,
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pendingRent ?? '',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TenantActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onPressed;

  const _TenantActionButton({
    required this.tooltip,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),
      ),
    );
  }
}
