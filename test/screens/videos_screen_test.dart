import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_for_mom/l10n/app_strings.dart';
import 'package:app_for_mom/models/event.dart';
import 'package:app_for_mom/models/video.dart';
import 'package:app_for_mom/screens/videos/videos_screen.dart';
import 'package:app_for_mom/services/firestore_service.dart';

/// A fake [FirestoreService] for VideosScreen tests.
class FakeFirestoreService implements FirestoreService {
  final StreamController<List<Video>> _videoController =
      StreamController<List<Video>>.broadcast();
  final List<Video> _videos = [];

  bool throwOnAdd = false;

  void emitVideos(List<Video> videos) {
    _videos.clear();
    _videos.addAll(videos);
    _videoController.add(List.unmodifiable(_videos));
  }

  void emitError(Object error) {
    _videoController.addError(error);
  }

  // ---- Videos ----

  @override
  Stream<List<Video>> getVideos() => _videoController.stream;

  @override
  Future<String> addVideo(
      {required String title, required String youtubeId}) async {
    if (throwOnAdd) throw Exception('Test error');
    final video = Video(
      id: 'v-${_videos.length}',
      title: title,
      youtubeId: youtubeId,
      addedAt: DateTime.now(),
    );
    _videos.insert(0, video);
    _videoController.add(List.unmodifiable(_videos));
    return video.id;
  }

  @override
  Future<void> updateVideo(
      {required String id,
      required String title,
      required String youtubeId}) async {}

  @override
  Future<void> deleteVideo(String id) async {
    _videos.removeWhere((v) => v.id == id);
    _videoController.add(List.unmodifiable(_videos));
  }

  // ---- Events (unused stubs) ----

  @override
  Stream<List<Event>> getUpcomingEvents() => Stream.value([]);

  @override
  Future<String> addEvent({required String title, required DateTime date}) async => '';

  @override
  Future<void> deleteEvent(String id) async {}
}

Widget buildTestApp(FakeFirestoreService service) {
  return MaterialApp(
    home: VideosScreen(firestoreService: service),
  );
}

void main() {
  late FakeFirestoreService fakeService;

  final testVideo1 = Video(
    id: 'v1',
    title: 'Tai Chi Tutorial',
    youtubeId: 'dQw4w9WgXcQ',
    addedAt: DateTime(2026, 7, 27),
  );
  final testVideo2 = Video(
    id: 'v2',
    title: 'Cooking Class',
    youtubeId: 'abcdef12345',
    addedAt: DateTime(2026, 7, 26),
  );

  setUp(() {
    fakeService = FakeFirestoreService();
  });

  group('VideosScreen', () {
    // -----------------------------------------------------------------------
    // Rendering
    // -----------------------------------------------------------------------
    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(buildTestApp(fakeService));
      fakeService.emitVideos([]);
      await tester.pump();

      // AppStrings.videosTitle contains "影片列表\nVideos"
      expect(find.text(AppStrings.videosTitle), findsOneWidget);
    });

    testWidgets('shows FAB to add video', (tester) async {
      await tester.pumpWidget(buildTestApp(fakeService));
      fakeService.emitVideos([]);
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // Empty state
    // -----------------------------------------------------------------------
    testWidgets('shows empty state when no videos exist', (tester) async {
      await tester.pumpWidget(buildTestApp(fakeService));
      fakeService.emitVideos([]);
      await tester.pump();

      // AppStrings.noVideos
      expect(find.text(AppStrings.noVideos), findsOneWidget);
      expect(find.byIcon(Icons.video_library_outlined), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // Video grid
    // -----------------------------------------------------------------------
    testWidgets('displays video thumbnails with titles', (tester) async {
      await tester.pumpWidget(buildTestApp(fakeService));
      fakeService.emitVideos([testVideo1, testVideo2]);
      await tester.pump();

      // Both video titles should be visible
      expect(find.text('Tai Chi Tutorial'), findsOneWidget);
      expect(find.text('Cooking Class'), findsOneWidget);

      // Play button overlays should be present (2 cards × 1 play icon each)
      expect(find.byIcon(Icons.play_arrow_rounded), findsNWidgets(2));
    });

    // -----------------------------------------------------------------------
    // Error state
    // -----------------------------------------------------------------------
    testWidgets('shows error state when stream fails', (tester) async {
      await tester.pumpWidget(buildTestApp(fakeService));
      fakeService.emitError(Exception('Stream error'));
      await tester.pump();

      // AppStrings.couldNotLoadVideos
      expect(find.text(AppStrings.couldNotLoadVideos), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // Loading state
    // -----------------------------------------------------------------------
    testWidgets('shows loading indicator while waiting for stream',
        (tester) async {
      // Don't emit anything — stream stays in waiting state.
      await tester.pumpWidget(buildTestApp(fakeService));
      // pump() without settle so connection stays waiting
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
