import 'package:flutter/material.dart';

class WallpaperControls extends StatelessWidget {
  final bool isAutoPlay;
  final double transitionDuration;
  final VoidCallback onToggleAutoPlay;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final int currentIndex;
  final int totalImages;

  const WallpaperControls({
    super.key,
    required this.isAutoPlay,
    required this.transitionDuration,
    required this.onToggleAutoPlay,
    required this.onSpeedChanged,
    required this.onNext,
    required this.onPrevious,
    required this.currentIndex,
    required this.totalImages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: onPrevious,
              ),
              IconButton(
                icon: Icon(
                  isAutoPlay
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: onToggleAutoPlay,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: onNext,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Speed:', style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 10),
              SizedBox(
                width: 150,
                child: Slider(
                  value: transitionDuration,
                  min: 2,
                  max: 15,
                  divisions: 13,
                  onChanged: onSpeedChanged,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.white30,
                ),
              ),
              Text(
                '${transitionDuration.toInt()}s',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${currentIndex + 1}/$totalImages',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
