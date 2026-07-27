import 'dart:async';

import '../models/event.dart';
import '../models/video.dart';

/// Abstract interface for event and video storage operations.
///
/// This allows swapping the real Firestore implementation with a fake
/// for isolated unit testing.
abstract class FirestoreService {
  // ---- Events ----

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

  // ---- Videos ----

  /// Returns a stream of all videos, ordered by most recently added first.
  Stream<List<Video>> getVideos();

  /// Adds a new video with the given [title] and [youtubeId].
  /// Returns the document ID of the newly created video.
  Future<String> addVideo({
    required String title,
    required String youtubeId,
  });

  /// Updates an existing video's [title] and [youtubeId].
  Future<void> updateVideo({
    required String id,
    required String title,
    required String youtubeId,
  });

  /// Deletes the video with the given [id].
  Future<void> deleteVideo(String id);
}
