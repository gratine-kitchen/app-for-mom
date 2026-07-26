import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:app_for_mom/models/event.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('Event model', () {
    final testDate = DateTime(2026, 7, 26);
    final testCreatedAt = DateTime(2026, 7, 25);
    final testEvent = Event(
      id: 'abc123',
      title: 'Family Dinner',
      date: testDate,
      createdAt: testCreatedAt,
    );

    test('toMap should produce correct Firestore-compatible map', () {
      final map = testEvent.toMap();

      expect(map['title'], 'Family Dinner');
      expect(map['date'], isA<Timestamp>());
      expect((map['date'] as Timestamp).toDate(), testDate);
      expect(map['createdAt'], isA<Timestamp>());
      expect((map['createdAt'] as Timestamp).toDate(), testCreatedAt);
    });

    test('fromFirestore should parse a DocumentSnapshot correctly', () async {
      // Write a document using fake Firestore, then read it back.
      final docRef = await fakeFirestore.collection('events').add({
        'title': 'Family Dinner',
        'date': Timestamp.fromDate(testDate),
        'createdAt': Timestamp.fromDate(testCreatedAt),
      });
      final snapshot = await docRef.get();

      final event = Event.fromFirestore(snapshot);

      expect(event.id, docRef.id);
      expect(event.title, 'Family Dinner');
      expect(event.date, testDate);
      expect(event.createdAt, testCreatedAt);
    });

    test('copyWith should produce correct partial updates', () {
      final updated = testEvent.copyWith(title: 'Movie Night');

      expect(updated.id, testEvent.id);
      expect(updated.title, 'Movie Night');
      expect(updated.date, testEvent.date);
      expect(updated.createdAt, testEvent.createdAt);
    });

    test('copyWith with all fields should create a new instance', () {
      final updated = testEvent.copyWith(
        id: 'new-id',
        title: 'New Title',
        date: DateTime(2026, 8, 1),
        createdAt: DateTime(2026, 7, 26),
      );

      expect(updated.id, 'new-id');
      expect(updated.title, 'New Title');
      expect(updated.date, DateTime(2026, 8, 1));
      expect(updated.createdAt, DateTime(2026, 7, 26));
    });

    test('events with same fields should be equal', () {
      final event1 = Event(
        id: '1',
        title: 'Test',
        date: testDate,
        createdAt: testCreatedAt,
      );
      final event2 = Event(
        id: '1',
        title: 'Test',
        date: testDate,
        createdAt: testCreatedAt,
      );

      expect(event1, equals(event2));
      expect(event1.hashCode, equals(event2.hashCode));
    });

    test('events with different fields should not be equal', () {
      final event1 = Event(
        id: '1',
        title: 'Test A',
        date: testDate,
        createdAt: testCreatedAt,
      );
      final event2 = Event(
        id: '1',
        title: 'Test B',
        date: testDate,
        createdAt: testCreatedAt,
      );

      expect(event1, isNot(equals(event2)));
    });

    test('toString should contain key fields', () {
      final str = testEvent.toString();

      expect(str, contains('abc123'));
      expect(str, contains('Family Dinner'));
      expect(str, contains('2026'));
    });
  });
}

