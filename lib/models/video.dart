import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a YouTube video in the family video library.
class Video {
  final String id;
  final String title;
  final String youtubeId;
  final DateTime addedAt;

  const Video({
    required this.id,
    required this.title,
    required this.youtubeId,
    required this.addedAt,
  });

  /// Extracts a YouTube video ID from various URL formats.
  ///
  /// Supports:
  /// - Plain 11-character IDs: `dQw4w9WgXcQ`
  /// - Short URLs: `https://youtu.be/dQw4w9WgXcQ`
  /// - Watch URLs: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
  /// - Embed URLs: `https://www.youtube.com/embed/dQw4w9WgXcQ`
  /// - Shorts URLs: `https://www.youtube.com/shorts/dQw4w9WgXcQ`
  ///
  /// Returns `null` if no valid YouTube ID is found.
  static String? extractYoutubeId(String urlOrId) {
    final trimmed = urlOrId.trim();

    // Already a plain YouTube ID (11 chars: alphanumeric + _ -)
    final plainId = RegExp(r'^[a-zA-Z0-9_-]{11}$');
    if (plainId.hasMatch(trimmed)) return trimmed;

    // youtu.be/VIDEO_ID
    final youtuBe = RegExp(r'(?:https?://)?youtu\.be/([a-zA-Z0-9_-]{11})');
    final match1 = youtuBe.firstMatch(trimmed);
    if (match1 != null) return match1.group(1);

    // youtube.com/watch?v=VIDEO_ID
    // youtube.com/embed/VIDEO_ID
    // youtube.com/shorts/VIDEO_ID
    final youtubeCom = RegExp(
      r'(?:https?://)?(?:www\.)?youtube\.com/(?:watch\?v=|embed/|shorts/)([a-zA-Z0-9_-]{11})',
    );
    final match2 = youtubeCom.firstMatch(trimmed);
    if (match2 != null) return match2.group(1);

    return null;
  }

  /// High-quality YouTube thumbnail URL.
  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';

  /// Creates a [Video] from a Firestore [DocumentSnapshot].
  factory Video.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Video(
      id: doc.id,
      title: data['title'] as String,
      youtubeId: data['youtubeId'] as String,
      addedAt: (data['addedAt'] as Timestamp).toDate(),
    );
  }

  /// Converts this [Video] to a map suitable for Firestore writes.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'youtubeId': youtubeId,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  /// Creates a new [Video] with the given fields replaced.
  Video copyWith({
    String? id,
    String? title,
    String? youtubeId,
    DateTime? addedAt,
  }) {
    return Video(
      id: id ?? this.id,
      title: title ?? this.title,
      youtubeId: youtubeId ?? this.youtubeId,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Video &&
        other.id == id &&
        other.title == title &&
        other.youtubeId == youtubeId &&
        other.addedAt == addedAt;
  }

  @override
  int get hashCode => Object.hash(id, title, youtubeId, addedAt);

  @override
  String toString() => 'Video(id: $id, title: $title, youtubeId: $youtubeId)';
}
