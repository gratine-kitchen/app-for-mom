import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event.dart';
import 'firestore_service.dart';

/// Real Firestore implementation of [FirestoreService].
class FirestoreServiceImpl implements FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreServiceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Event>> getUpcomingEvents() {
    final today = DateTime.now();
    // Normalize to start of day so today's events are included.
    final startOfToday = DateTime(today.year, today.month, today.day);

    return _firestore
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  @override
  Future<String> addEvent({
    required String title,
    required DateTime date,
  }) async {
    final docRef = await _firestore.collection('events').add({
      'title': title,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
    return docRef.id;
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _firestore.collection('events').doc(id).delete();
  }
}
