import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/room_media.dart';

class RoomMediaFullscreenViewer extends StatefulWidget {
  final List<RoomMedia> media;
  final int initialIndex;
  final String roomName;

  const RoomMediaFullscreenViewer({
    super.key,
    required this.media,
    required this.initialIndex,
    required this.roomName,
  });

  @override
  State<RoomMediaFullscreenViewer> createState() =>
      _RoomMediaFullscreenViewerState();
}

class _RoomMediaFullscreenViewerState extends State<RoomMediaFullscreenViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.media.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaCount = widget.media.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: mediaCount,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final item = widget.media[index];
              if (item.isVideo) {
                return _VideoMediaPage(
                  media: item,
                  isActive: index == _currentIndex,
                );
              }
              return _ImageMediaPage(media: item);
            },
          ),
          _TopOverlay(
            roomName: widget.roomName,
            counter: '${_currentIndex + 1} / $mediaCount',
            onBack: () => Navigator.pop(context),
          ),
          if (mediaCount > 1) ...[
            _ArrowButton(
              alignment: Alignment.centerLeft,
              icon: Icons.chevron_left,
              enabled: _currentIndex > 0,
              onPressed: _previous,
            ),
            _ArrowButton(
              alignment: Alignment.centerRight,
              icon: Icons.chevron_right,
              enabled: _currentIndex < mediaCount - 1,
              onPressed: _next,
            ),
          ],
        ],
      ),
    );
  }

  void _previous() {
    if (_currentIndex == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _next() {
    if (_currentIndex >= widget.media.length - 1) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }
}

class _TopOverlay extends StatelessWidget {
  final String roomName;
  final String counter;
  final VoidCallback onBack;

  const _TopOverlay({
    required this.roomName,
    required this.counter,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.82),
              Colors.black.withValues(alpha: 0.0),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 12, 28),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  tooltip: 'Back',
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    roomName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  counter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final Alignment alignment;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _ArrowButton({
    required this.alignment,
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: IconButton.filled(
            onPressed: enabled ? onPressed : null,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.46),
              disabledBackgroundColor: Colors.black.withValues(alpha: 0.16),
            ),
            icon: Icon(icon, color: enabled ? Colors.white : Colors.white38),
            tooltip: icon == Icons.chevron_left ? 'Previous' : 'Next',
          ),
        ),
      ),
    );
  }
}

class _ImageMediaPage extends StatelessWidget {
  final RoomMedia media;

  const _ImageMediaPage({required this.media});

  @override
  Widget build(BuildContext context) {
    final localPath = media.localPath.trim();
    final localFile = localPath.isNotEmpty ? File(localPath) : null;
    final hasLocal = localFile != null && localFile.existsSync();
    final downloadUrl = media.downloadUrl.trim();

    return Center(
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: hasLocal
            ? Image.file(
                localFile,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const _UnableToLoadMedia(),
              )
            : downloadUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: downloadUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) =>
                        const _UnableToLoadMedia(),
                  )
                : const _UnableToLoadMedia(),
      ),
    );
  }
}

class _VideoMediaPage extends StatefulWidget {
  final RoomMedia media;
  final bool isActive;

  const _VideoMediaPage({
    required this.media,
    required this.isActive,
  });

  @override
  State<_VideoMediaPage> createState() => _VideoMediaPageState();
}

class _VideoMediaPageState extends State<_VideoMediaPage> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant _VideoMediaPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isActive) {
      _controller?.pause();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_failed || controller == null) {
      return const Center(child: _UnableToLoadMedia());
    }
    if (!_ready) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(controller),
            IconButton.filled(
              onPressed: _togglePlayback,
              icon: Icon(
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              tooltip: controller.value.isPlaying ? 'Pause' : 'Play',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initialize() async {
    final localPath = widget.media.localPath.trim();
    final localFile = localPath.isNotEmpty ? File(localPath) : null;
    if (localFile != null && localFile.existsSync()) {
      _controller = VideoPlayerController.file(localFile);
    } else if (widget.media.downloadUrl.trim().isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.media.downloadUrl.trim()),
      );
    } else {
      setState(() => _failed = true);
      return;
    }

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _ready = true);
      if (widget.isActive) {
        await _controller!.play();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null) return;
    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }
}

class _UnableToLoadMedia extends StatelessWidget {
  const _UnableToLoadMedia();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Unable to load media',
      style: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }
}
