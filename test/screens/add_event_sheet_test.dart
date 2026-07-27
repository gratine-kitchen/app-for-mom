import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:app_for_mom/l10n/app_strings.dart';
import 'package:app_for_mom/models/event.dart';
import 'package:app_for_mom/screens/add_event_sheet.dart';
import 'package:app_for_mom/services/firestore_service.dart';

/// Minimal fake service for AddEventSheet tests.
class FakeFirestoreService implements FirestoreService {
  String? lastTitle;
  DateTime? lastDate;
  bool shouldThrow = false;

  @override
  Stream<List<Event>> getUpcomingEvents() =>
      Stream.value([]);

  @override
  Future<String> addEvent(
      {required String title, required DateTime date}) async {
    if (shouldThrow) {
      throw Exception('Test error');
    }
    lastTitle = title;
    lastDate = date;
    return 'test-id';
  }

  @override
  Future<void> deleteEvent(String id) async {}
}

Widget buildTestApp(FakeFirestoreService service) {
  return MaterialApp(
    home: Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            AddEventSheet.show(
              _MockNavigatorContext.currentContext!,
              firestoreService: service,
            ),
        child: const Icon(Icons.add),
      ),
    ),
  );
}

/// A helper to capture the BuildContext from the MaterialApp for showing
/// the bottom sheet.
class _MockNavigatorContext {
  static BuildContext? currentContext;
}

void main() {
  late FakeFirestoreService fakeService;

  setUpAll(() async {
    await initializeDateFormatting('zh_TW', null);
  });

  setUp(() {
    fakeService = FakeFirestoreService();
  });

  /// Helper: open the bottom sheet and pump until settled.
  Future<void> openSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            _MockNavigatorContext.currentContext = context;
            return Scaffold(
              body: const SizedBox.expand(),
              floatingActionButton: FloatingActionButton(
                onPressed: () => AddEventSheet.show(
                  context,
                  firestoreService: fakeService,
                ),
                child: const Icon(Icons.add),
              ),
            );
          },
        ),
      ),
    );

    // Tap the FAB to open the sheet
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
  }

  group('AddEventSheet', () {
    testWidgets('should render title field and date picker trigger',
        (tester) async {
      await openSheet(tester);

      expect(find.text(AppStrings.newEvent), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text(AppStrings.dateLabel), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('should show validation error for empty title',
        (tester) async {
      await openSheet(tester);

      // Tap save without entering a title
      await tester.tap(find.text(AppStrings.saveEvent));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.pleaseEnterTitle), findsOneWidget);
      expect(fakeService.lastTitle, isNull); // Should not have saved
    });

    testWidgets('should save successfully with valid title', (tester) async {
      await openSheet(tester);

      // Enter a title
      await tester.enterText(find.byType(TextFormField), 'Family Dinner');
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.text(AppStrings.saveEvent));
      await tester.pumpAndSettle();

      // The sheet should be dismissed, and the service should have been called
      expect(fakeService.lastTitle, 'Family Dinner');
      expect(fakeService.lastDate, isNotNull);
    });

    testWidgets('should show error when save fails', (tester) async {
      fakeService.shouldThrow = true;

      await openSheet(tester);

      await tester.enterText(find.byType(TextFormField), 'Test Event');
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.saveEvent));
      await tester.pumpAndSettle();

      // Should show an error snackbar
      expect(find.textContaining(AppStrings.failedToSave), findsOneWidget);
    });
  });
}

