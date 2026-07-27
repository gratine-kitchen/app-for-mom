import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_for_mom/l10n/app_strings.dart';
import 'package:app_for_mom/models/event.dart';
import 'package:app_for_mom/models/video.dart';
import 'package:app_for_mom/screens/videos/add_edit_video_sheet.dart';
import 'package:app_for_mom/services/firestore_service.dart';

/// A minimal fake service for AddEditVideoSheet tests.
/// Uses a spy pattern to capture calls.
class FakeFirestoreService implements FirestoreService {
  String? lastTitle;
  String? lastYoutubeId;
  String? updatedId;
  String? updatedTitle;
  String? updatedYoutubeId;
  String? deletedId;
  bool shouldThrow = false;

  // ---- Videos ----

  @override
  Stream<List<Video>> getVideos() => Stream.value([]);

  @override
  Future<String> addVideo(
      {required String title, required String youtubeId}) async {
    if (shouldThrow) throw Exception('Test error');
    lastTitle = title;
    lastYoutubeId = youtubeId;
    return 'new-video-id';
  }

  @override
  Future<void> updateVideo(
      {required String id,
      required String title,
      required String youtubeId}) async {
    if (shouldThrow) throw Exception('Test error');
    updatedId = id;
    updatedTitle = title;
    updatedYoutubeId = youtubeId;
  }

  @override
  Future<void> deleteVideo(String id) async {
    deletedId = id;
  }

  // ---- Events (unused stubs) ----

  @override
  Stream<List<Event>> getUpcomingEvents() => Stream.value([]);

  @override
  Future<String> addEvent(
      {required String title, required DateTime date}) async {
    return '';
  }

  @override
  Future<void> deleteEvent(String id) async {}
}

/// Helper to open the add-edit sheet from a test app.
Future<void> openAddSheet(WidgetTester tester, FakeFirestoreService service,
    {Video? existingVideo}) async {
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: ElevatedButton(
          onPressed: () => AddEditVideoSheet.show(
            context,
            firestoreService: service,
            existingVideo: existingVideo,
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  late FakeFirestoreService fakeService;

  setUp(() {
    fakeService = FakeFirestoreService();
  });

  group('AddEditVideoSheet', () {
    // -----------------------------------------------------------------------
    // Rendering (add mode)
    // -----------------------------------------------------------------------
    testWidgets('renders title field and URL field in add mode',
        (tester) async {
      await openAddSheet(tester, fakeService);

      // Title field
      expect(find.byType(TextFormField), findsNWidgets(2));

      // AppStrings.addVideo — appears as both title and button label
      expect(find.text(AppStrings.addVideo), findsAtLeastNWidgets(1));

      // URL label
      expect(find.text(AppStrings.youtubeUrlLabel), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // Rendering (edit mode)
    // -----------------------------------------------------------------------
    testWidgets('renders pre-filled fields and delete button in edit mode',
        (tester) async {
      final existingVideo = Video(
        id: 'existing-id',
        title: 'Existing Video',
        youtubeId: 'abc123xyz00',
        addedAt: DateTime(2026, 7, 27),
      );

      await openAddSheet(tester, fakeService, existingVideo: existingVideo);

      // Title should be pre-filled
      expect(find.text('Existing Video'), findsOneWidget);

      // URL should contain the youtube ID
      expect(find.text('https://youtube.com/watch?v=abc123xyz00'), findsOneWidget);

      // AppStrings.editVideo
      expect(find.text(AppStrings.editVideo), findsOneWidget);

      // Delete button should be visible
      expect(find.text(AppStrings.deleteLabel), findsWidgets);
    });

    // -----------------------------------------------------------------------
    // Validation
    // -----------------------------------------------------------------------
    testWidgets('shows validation error when title is empty', (tester) async {
      await openAddSheet(tester, fakeService);

      // Tap save button (FilledButton with addVideoLabel text)
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.addVideoLabel));
      await tester.pumpAndSettle();

      // AppStrings.pleaseEnterTitle
      expect(find.text(AppStrings.pleaseEnterTitle), findsOneWidget);
      expect(fakeService.lastTitle, isNull); // Service was not called
    });

    testWidgets('shows validation error when URL is invalid', (tester) async {
      await openAddSheet(tester, fakeService);

      // Enter a title but an invalid URL
      await tester.enterText(
          find.byType(TextFormField).first, 'My Video');
      await tester.enterText(
          find.byType(TextFormField).last, 'not-a-valid-url');
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.addVideoLabel));
      await tester.pumpAndSettle();

      // AppStrings.invalidYoutubeUrl
      expect(find.text(AppStrings.invalidYoutubeUrl), findsOneWidget);
      expect(fakeService.lastTitle, isNull);
    });

    // -----------------------------------------------------------------------
    // Successful save (add mode)
    // -----------------------------------------------------------------------
    testWidgets('saves with valid title and YouTube URL in add mode',
        (tester) async {
      await openAddSheet(tester, fakeService);

      await tester.enterText(
          find.byType(TextFormField).first, 'Tai Chi Tutorial');
      await tester.enterText(
          find.byType(TextFormField).last, 'https://youtu.be/dQw4w9WgXcQ');
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.addVideoLabel));
      await tester.pumpAndSettle();

      expect(fakeService.lastTitle, 'Tai Chi Tutorial');
      expect(fakeService.lastYoutubeId, 'dQw4w9WgXcQ');
    });

    // -----------------------------------------------------------------------
    // Successful save (edit mode)
    // -----------------------------------------------------------------------
    testWidgets('updates existing video in edit mode', (tester) async {
      final existingVideo = Video(
        id: 'existing-id',
        title: 'Old Title',
        youtubeId: 'old12345678',
        addedAt: DateTime(2026, 7, 27),
      );

      await openAddSheet(tester, fakeService, existingVideo: existingVideo);

      // Clear and re-enter title
      await tester.enterText(find.byType(TextFormField).first, 'New Title');
      await tester.enterText(
          find.byType(TextFormField).last, 'https://youtu.be/new12345678');
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.updateVideo));
      await tester.pumpAndSettle();

      expect(fakeService.updatedId, 'existing-id');
      expect(fakeService.updatedTitle, 'New Title');
      expect(fakeService.updatedYoutubeId, 'new12345678');
    });

    // -----------------------------------------------------------------------
    // Delete
    // -----------------------------------------------------------------------
    testWidgets('delete confirmation calls deleteVideo', (tester) async {
      final existingVideo = Video(
        id: 'to-delete',
        title: 'Delete Me',
        youtubeId: 'del12345678',
        addedAt: DateTime(2026, 7, 27),
      );

      await openAddSheet(tester, fakeService, existingVideo: existingVideo);

      // Tap the delete button (OutlinedButton)
      await tester.tap(find.widgetWithText(OutlinedButton, AppStrings.deleteLabel));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text(AppStrings.deleteVideoConfirm), findsOneWidget);

      // Confirm deletion (tap Delete in the dialog)
      await tester.tap(find.widgetWithText(TextButton, AppStrings.deleteLabel));
      await tester.pumpAndSettle();

      expect(fakeService.deletedId, 'to-delete');
    });
  });
}
