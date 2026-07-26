import 'dart:async';

import '../models/event.dart';

/// Abstract interface for event storage operations.
///
/// This allows swapping the real Firestore implementation with a fake
/// for isolated unit testing.
abstract class FirestoreService {
  /// Returns a stream of upcoming events (date >= today), ordered by date
  /// ascending (nearest first).
  Stream<List<Event>> getUpcomingEvents();

  /// Adds a new event with the given [title] and [date].
  /// Returns the document ID of the newly created event.
  Future<String> addEvent({
    required String title,
    required DateTime date,
  });

  /// Deletes the event with the given [id].
  Future<void> deleteEvent(String id);
}
