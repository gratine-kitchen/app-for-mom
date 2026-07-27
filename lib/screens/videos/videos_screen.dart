import 'package:flutter/material.dart';

import '../../l10n/app_strings.dart';
import '../../models/video.dart';
import '../../services/firestore_service.dart';
import 'add_edit_video_sheet.dart';
import 'video_player_screen.dart';

/// Full-page grid of YouTube video thumbnails.
///
/// Long-pressing a thumbnail opens the edit/delete sheet. Tapping navigates
/// to the fullscreen player.
class VideosScreen extends StatelessWidget {
  final FirestoreService firestoreService;

  const VideosScreen({super.key, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.videosTitle),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddEditVideoSheet.show(
          context,
          firestoreService: firestoreService,
        ),
        tooltip: AppStrings.addVideoTooltip,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Video>>(
        stream: firestoreService.getVideos(),
        builder: (context, snapshot) {
          // ---- Loading ----
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ---- Error ----
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.couldNotLoadVideos,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final videos = snapshot.data ?? [];

          // ---- Empty State ----
          if (videos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.video_library_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.noVideos,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // ---- Video Grid ----
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) => _VideoThumbnailCard(
              video: videos[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        VideoPlayerScreen(video: videos[index]),
                  ),
                );
              },
              onLongPress: () {
                AddEditVideoSheet.show(
                  context,
                  firestoreService: firestoreService,
                  existingVideo: videos[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// A single video thumbnail card with a play button overlay.
class _VideoThumbnailCard extends StatelessWidget {
  final Video video;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _VideoThumbnailCard({
    required this.video,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail with play button overlay
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 36,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                      );
                    },
                  ),
                  // Play button overlay
                  Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
