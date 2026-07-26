import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_for_mom/services/firestore_service.dart';
import 'package:app_for_mom/services/firestore_service_impl.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = FirestoreServiceImpl(firestore: fakeFirestore);
  });

  group('FirestoreService', () {
    test('addEvent should create a document with correct fields', () async {
      final date = DateTime(2026, 8, 1);
      final id = await service.addEvent(
        title: 'Birthday Party',
        date: date,
      );

      final doc = await fakeFirestore.collection('events').doc(id).get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['title'], 'Birthday Party');
      expect((doc.data()!['date'] as Timestamp).toDate(), date);
      expect(doc.data()!['createdAt'], isA<Timestamp>());
    });

    test('getUpcomingEvents should stream only future-dated events', () async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      final nextWeek = today.add(const Duration(days: 7));

      // Add events
      await service.addEvent(title: 'Tomorrow Event', date: tomorrow);
      await service.addEvent(title: 'Next Week Event', date: nextWeek);

      final events = await service.getUpcomingEvents().first;

      expect(events.length, greaterThanOrEqualTo(2));
      expect(events.map((e) => e.title), contains('Tomorrow Event'));
      expect(events.map((e) => e.title), contains('Next Week Event'));
    });

    test('getUpcomingEvents should exclude past-dated events', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      // Manually add a past event directly to fake Firestore
      // (since addEvent through service validates for future dates)
      await fakeFirestore.collection('events').add({
        'title': 'Past Event',
        'date': Timestamp.fromDate(yesterday),
        'createdAt': Timestamp.fromDate(yesterday),
      });

      await service.addEvent(title: 'Future Event', date: tomorrow);

      final events = await service.getUpcomingEvents().first;

      // Should only contain the future event, not the past one.
      expect(events.length, 1);
      expect(events.first.title, 'Future Event');
    });

    test('getUpcomingEvents should order events by date ascending', () async {
      final today = DateTime.now();
      final day3 = today.add(const Duration(days: 3));
      final day1 = today.add(const Duration(days: 1));
      final day5 = today.add(const Duration(days: 5));

      // Add in non-chronological order
      await service.addEvent(title: 'Day 3', date: day3);
      await service.addEvent(title: 'Day 1', date: day1);
      await service.addEvent(title: 'Day 5', date: day5);

      final events = await service.getUpcomingEvents().first;

      expect(events.length, 3);
      expect(events[0].title, 'Day 1');
      expect(events[1].title, 'Day 3');
      expect(events[2].title, 'Day 5');
    });

    test('deleteEvent should remove the correct document', () async {
      final id = await service.addEvent(
        title: 'To Delete',
        date: DateTime.now().add(const Duration(days: 1)),
      );

      // Verify it exists
      var doc = await fakeFirestore.collection('events').doc(id).get();
      expect(doc.exists, isTrue);

      // Delete it
      await service.deleteEvent(id);

      // Verify it's gone
      doc = await fakeFirestore.collection('events').doc(id).get();
      expect(doc.exists, isFalse);
    });

    test('addEvent should return a valid document ID', () async {
      final id = await service.addEvent(
        title: 'Test',
        date: DateTime.now().add(const Duration(days: 1)),
      );

      expect(id, isA<String>());
      expect(id.isNotEmpty, isTrue);
    });
  });
}

