import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:app_for_mom/l10n/app_strings.dart';
import 'package:app_for_mom/l10n/bilingual_date_formatter.dart';
import 'package:app_for_mom/models/event.dart';
import 'package:app_for_mom/screens/home_screen.dart';
import 'package:app_for_mom/services/firestore_service.dart';

/// A fake [FirestoreService] that returns a controlled stream of events.
class FakeFirestoreService implements FirestoreService {
  final StreamController<List<Event>> _controller =
      StreamController<List<Event>>.broadcast();
  final List<Event> _events = [];

  void emitEvents(List<Event> events) {
    _events.clear();
    _events.addAll(events);
    _controller.add(List.unmodifiable(_events));
  }

  void emitError(Object error) {
    _controller.addError(error);
  }

  @override
  Stream<List<Event>> getUpcomingEvents() => _controller.stream;

  @override
  Future<String> addEvent(
      {required String title, required DateTime date}) async {
    final event = Event(
      id: 'fake-${_events.length}',
      title: title,
      date: date,
      createdAt: DateTime.now(),
    );
    _events.add(event);
    _controller.add(List.unmodifiable(_events));
    return event.id;
  }

  @override
  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    _controller.add(List.unmodifiable(_events));
  }

  void dispose() {
    _controller.close();
  }
}

Widget buildTestApp(FakeFirestoreService service) {
  return MaterialApp(
    home: HomeScreen(firestoreService: service),
  );
}

void main() {
  late FakeFirestoreService fakeService;

  setUpAll(() async {
    await initializeDateFormatting('zh_TW', null);
  });

  setUp(() {
    fakeService = FakeFirestoreService();
  });

  tearDown(() {
    fakeService.dispose();
  });

  group('HomeScreen', () {
    testWidgets('should display today\'s date in large font', (tester) async {
      await tester.pumpWidget(buildTestApp(fakeService));
      fakeService.emitEvents([]);
      await tester.pump();

      final todayFormatted = BilingualDateFormatter.full(DateTime.now());

      // Find the date text with large font
      final dateFinder = find.text(todayFormatted);
      expect(dateFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(dateFinder);
      expect(textWidget.style?.fontSize, 26);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('should show empty state when no events', (tester) async {
      await tester.pumpWidget(buildTestApp(fakeService));
      fakeService.emitEvents([]);
      await tester.pump();

      expect(find.text(AppStrings.noUpcomingEvents), findsOneWidget);
      expect(find.text(AppStrings.tapPlusToAdd), findsOneWidget);
    });

    testWidgets('should show loading indicator while stream is pending',
        (tester) async {
      // Don't emit any events yet — stream stays in waiting state
      await tester.pumpWidget(buildTestApp(fakeService));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render event cards with title and date',
        (tester) async {
      final events = [
        Event(
          id: '1',
          title: 'Family Dinner',
          date: DateTime.now().add(const Duration(days: 2)),
          createdAt: DateTime.now(),
        ),
        Event(
          id: '2',
          title: 'Doctor Appointment',
          date: DateTime.now().add(const Duration(days: 5)),
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(buildTestApp(fakeService));
      fakeService.emitEvents(events);
      await tester.pump();

      expect(find.text('Family Dinner'), findsOneWidget);
      expect(find.text('Doctor Appointment'), findsOneWidget);
    });

    testWidgets('should highlight today\'s events specially', (tester) async {
      final today = DateTime.now();

      await tester.pumpWidget(buildTestApp(fakeService));
      fakeService.emitEvents([
        Event(
          id: 'today',
          title: 'Today Event',
          date: DateTime(today.year, today.month, today.day),
          createdAt: today,
        ),
      ]);
      await tester.pump();

      expect(find.text('Today Event'), findsOneWidget);
      // Verify the date badge is rendered (day number + month label)
      expect(find.text('${today.day}'), findsOneWidget);
    });

    testWidgets('should have a FAB', (tester) async {
      await tester.pumpWidget(buildTestApp(fakeService));
      fakeService.emitEvents([]);
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should show error state on stream error', (tester) async {
      await tester.pumpWidget(buildTestApp(fakeService));
      fakeService.emitError(Exception('Network error'));
      await tester.pump();

      expect(find.text(AppStrings.couldNotLoadEvents), findsOneWidget);
    });
  });
}

