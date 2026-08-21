import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBackground extends StatefulWidget {
  final String assetPath;
  final String? placeholderAsset;
  const VideoBackground({
    super.key,
    required this.assetPath,
    this.placeholderAsset,
  });

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
    _initializeController();
  }

  VideoPlayerController _createController() =>
      VideoPlayerController.asset(widget.assetPath);

  Future<void> _initializeController() async {
    final controller = _controller;
    try {
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.initialize();
      if (!mounted || !identical(_controller, controller)) return;
      setState(() {});
      await controller.play();
    } catch (_) {
      // Native video is unavailable in widget tests and on a few transient
      // lifecycle states. The thumbnail remains visible as the safe fallback.
    }
  }

  @override
  void didUpdateWidget(covariant VideoBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath == widget.assetPath) return;
    final previous = _controller;
    _controller = _createController();
    _initializeController();
    previous.dispose();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
      );
    } else {
      return widget.placeholderAsset == null
          ? Container(color: Colors.black)
          : Image.asset(widget.placeholderAsset!, fit: BoxFit.cover);
    }
  }
}
