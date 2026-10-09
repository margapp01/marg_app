import 'package:flutter/material.dart';

import '../../../../shared/design_system.dart';
import '../../domain/entities/temple_detail.dart';

/// Fullscreen, swipeable gallery with pinch-to-zoom and a page indicator.
class TempleGalleryViewer extends StatefulWidget {
  const TempleGalleryViewer({required this.images, this.initialIndex = 0, super.key});

  final List<TempleImage> images;
  final int initialIndex;

  static Future<void> open(BuildContext context, List<TempleImage> images, int index) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, _, _) => TempleGalleryViewer(images: images, initialIndex: index),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  State<TempleGalleryViewer> createState() => _TempleGalleryViewerState();
}

class _TempleGalleryViewerState extends State<TempleGalleryViewer> {
  late final PageController _controller = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Hero(
                    tag: 'temple-gallery-$i',
                    child: AppNetworkImage(url: widget.images[i].url, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: IconButton(
                icon: const Icon(AppIcons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              bottom: AppSpacing.xl,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < widget.images.length; i++)
                    AnimatedContainer(
                      duration: AppDurations.fast,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _index ? Colors.white : Colors.white38,
                        borderRadius: AppRadius.fullAll,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
