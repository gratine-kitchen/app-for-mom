import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a shared event in the family calendar.
class Event {
  final String id;
  final String title;
  final DateTime date;
  final DateTime createdAt;

  const Event({
    required this.id,
    required this.title,
    required this.date,
    required this.createdAt,
  });

  /// Creates an [Event] from a Firestore [DocumentSnapshot].
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] as String,
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Converts this [Event] to a map suitable for Firestore writes.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a new [Event] with the given fields replaced.
  Event copyWith({
    String? id,
    String? title,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event &&
        other.id == id &&
        other.title == title &&
        other.date == date &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, title, date, createdAt);

  @override
  String toString() => 'Event(id: $id, title: $title, date: $date)';
}
