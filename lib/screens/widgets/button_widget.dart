import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:html' as html; // For web download

class ButtonWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? currentWallpaperUrl;

  const ButtonWidget({
    super.key,
    required this.controller,
    this.currentWallpaperUrl,
  });

  // Search current wallpaper on Google
  Future<void> _searchWallpaperOnGoogle(BuildContext context) async {
    if (currentWallpaperUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No wallpaper to search'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Extract image name from URL
    final imageName = currentWallpaperUrl!.split('/').last.split('?').first;
    final searchQuery = 'wallpaper $imageName';

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await _searchOnGoogle(searchQuery);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _searchOnGoogle(String query) async {
    final Uri googleSearchUrl = Uri.parse(
      'https://www.google.com/search?q=${Uri.encodeComponent(query)}',
    );

    try {
      if (await canLaunchUrl(googleSearchUrl)) {
        await launchUrl(googleSearchUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $googleSearchUrl';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error launching Google: $e');
      }
    }
  }

  // Web download - uses browser download
  Future<void> _downloadWeb(String url, String filename) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes]);
        final anchor =
            html.AnchorElement(href: html.Url.createObjectUrlFromBlob(blob))
              ..setAttribute('download', filename)
              ..click();
        // Safely revoke the object URL
        final href = anchor.href;
        if (href != null && href.isNotEmpty) {
          html.Url.revokeObjectUrl(href);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Save wallpaper - works on all platforms
  Future<void> _saveWallpaper(BuildContext context) async {
    if (currentWallpaperUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No wallpaper to save'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Downloading wallpaper...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    try {
      final String fileName =
          'wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Check if running on web
      if (kIsWeb) {
        // Web download
        await _downloadWeb(currentWallpaperUrl!, fileName);

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wallpaper downloaded successfully! 🎉'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Mobile/Desktop download
      // Check and request permissions (only on Android/iOS)
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.storage.request();
        if (!status.isGranted && !Platform.isIOS) {
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permission denied to save wallpaper'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // Download the image
      final response = await http.get(Uri.parse(currentWallpaperUrl!));

      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }

      // Try to save to gallery first
      try {
        final result = await ImageGallerySaver.saveImage(
          response.bodyBytes,
          quality: 100,
          name: fileName,
        );

        if (context.mounted) {
          Navigator.pop(context);
        }

        if (result['isSuccess'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wallpaper saved to gallery successfully! 🎉'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
      } catch (e) {
        // If gallery save fails, save to local directory
        print('Gallery save failed, trying local directory: $e');
      }

      // Fallback: Save to local directory
      final directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fileName';
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wallpaper saved to: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving wallpaper: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Current Wallpaper Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(300, 55),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () => _searchWallpaperOnGoogle(context),
          icon: const Icon(Icons.image_search, color: Colors.white),
          label: const Text(
            'Search Current Wallpaper',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        // Wallpaper download button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(300, 50),
            backgroundColor: Colors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () => _saveWallpaper(context),
          icon: const Icon(Icons.download, color: Colors.white),
          label: Text(
            kIsWeb ? 'Download Wallpaper' : 'Save Current Wallpaper',
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
