import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wallpaper/services/image_service.dart';
import 'package:wallpaper/widgets/background_pic.dart';
import 'package:wallpaper/widgets/button_widget.dart';
import 'package:wallpaper/services/quote_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? timer;
  Timer? hideControlsTimer;
  final TextEditingController searchController = TextEditingController();

  late List<String> imageUrls = [];
  int currentIndex = 0;
  late String currentUrl = '';

  // Wallpaper controls
  bool isAutoPlay = true;
  double transitionDuration = 5.0;

  // UI visibility - starts hidden
  bool showControls = false;

  // Quote related
  String currentQuote = '';
  String currentAuthor = '';
  bool isLoadingQuote = true;

  @override
  void initState() {
    super.initState();
    imageUrls = imagine.values.toList();
    if (imageUrls.isNotEmpty) {
      currentUrl = imageUrls.first;
      startSlideshow();
    }
    // Load initial quote
    _loadRandomQuote();

    // Start with controls hidden
    showControls = false;
  }

  // Function to load random quotes
  Future<void> _loadRandomQuote() async {
    setState(() {
      isLoadingQuote = true;
    });

    final quoteData = await QuoteService.getRandomQuote();

    if (mounted) {
      setState(() {
        currentQuote = quoteData['quote'] ?? 'Stay inspired!';
        currentAuthor = quoteData['author'] ?? 'Unknown';
        isLoadingQuote = false;
      });
    }
  }

  // load new quote
  void _loadNewQuote() {
    _loadRandomQuote();
  }

  //start slide show
  void startSlideshow() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: transitionDuration.toInt()), (
      timer,
    ) {
      if (mounted && isAutoPlay) {
        setState(() {
          currentIndex = (currentIndex + 1) % imageUrls.length;
          currentUrl = imageUrls[currentIndex];
        });
        // Load new quote when image changes
        _loadNewQuote();
        // DO NOT reset hide timer here - keep controls hidden
      }
    });
  }

  // hide buttons until interacted with
  void _showControlsTemporarily() {
    hideControlsTimer?.cancel();
    // Show controls when user interacts
    if (mounted) {
      setState(() {
        showControls = true;
      });
    }
    // Hide after 3 seconds
    hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showControls = false;
        });
      }
    });
  }

  void _handleUserInteraction() {
    // Show controls temporarily when user interacts
    _showControlsTemporarily();
  }

  void nextImage() {
    setState(() {
      currentIndex = (currentIndex + 1) % imageUrls.length;
      currentUrl = imageUrls[currentIndex];
    });
    _loadNewQuote();
    if (isAutoPlay) startSlideshow();
    // Show controls temporarily when manually changing
    _showControlsTemporarily();
  }

  void previousImage() {
    setState(() {
      currentIndex = (currentIndex - 1 + imageUrls.length) % imageUrls.length;
      currentUrl = imageUrls[currentIndex];
    });
    _loadNewQuote();
    if (isAutoPlay) startSlideshow();
    // Show controls temporarily when manually changing
    _showControlsTemporarily();
  }

  void toggleAutoPlay() {
    setState(() {
      isAutoPlay = !isAutoPlay;
      if (isAutoPlay) {
        startSlideshow();
      } else {
        timer?.cancel();
      }
    });
    _showControlsTemporarily();
  }

  // change speed ... for progression button
  void changeSpeed(double speed) {
    setState(() {
      transitionDuration = speed;
      if (isAutoPlay) startSlideshow();
    });
    _showControlsTemporarily();
  }

  @override
  void dispose() {
    timer?.cancel();
    hideControlsTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleUserInteraction,
      onPanDown: (_) => _handleUserInteraction(),
      onLongPress: _handleUserInteraction,
      child: Stack(
        children: [
          // Background image
          BackgroundPic(
            image: NetworkImage(currentUrl),
            transitionDuration: Duration(
              milliseconds: (transitionDuration * 200).toInt(),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  spacing: 1.2,
                  textBaseline: TextBaseline.ideographic,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Quote Text with better styling
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: isLoadingQuote
                          ? const CircularProgressIndicator(
                              color: Colors.white70,
                              strokeWidth: 2,
                            )
                          : Column(
                              children: [
                                Text(
                                  '"$currentQuote"',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.italic,
                                    height: 1.5,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 15,
                                        color: Colors.black54,
                                        offset: Offset(2, 2),
                                      ),
                                      Shadow(
                                        blurRadius: 5,
                                        color: Colors.black38,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '— $currentAuthor',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10,
                                        color: Colors.black45,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 40),
                    // Buttons - only shown when controls are visible
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: showControls ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: !showControls,
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: ButtonWidget(
                            controller: searchController,
                            currentWallpaperUrl: currentUrl,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Wallpaper controls - only shown when controls are visible
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: showControls ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: !showControls,
                        child: _buildWallpaperControls(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Left navigation arrow
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: showControls ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !showControls,
                child: Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: previousImage,
                  ),
                ),
              ),
            ),
          ),
          // Right navigation arrow
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: showControls ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !showControls,
                child: Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: nextImage,
                  ),
                ),
              ),
            ),
          ),
          // Image counter
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: showControls ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !showControls,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${currentIndex + 1} / ${imageUrls.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWallpaperControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isAutoPlay ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: toggleAutoPlay,
          ),
          const SizedBox(width: 10),
          Row(
            children: [
              const Text('Speed:', style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: Slider(
                  value: transitionDuration,
                  min: 2,
                  max: 15,
                  divisions: 13,
                  onChanged: changeSpeed,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.white30,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Text(
            '${transitionDuration.toInt()}s',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
