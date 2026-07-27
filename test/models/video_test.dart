import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_for_mom/models/video.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  final testDate = DateTime(2026, 7, 27, 10, 0);
  final testVideo = Video(
    id: 'vid123',
    title: 'Tai Chi Tutorial',
    youtubeId: 'dQw4w9WgXcQ',
    addedAt: testDate,
  );

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('Video model', () {
    // -----------------------------------------------------------------------
    // extractYoutubeId
    // -----------------------------------------------------------------------
    group('extractYoutubeId', () {
      test('returns plain ID as-is', () {
        expect(Video.extractYoutubeId('dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
      });

      test('extracts from youtu.be short URL', () {
        expect(
          Video.extractYoutubeId('https://youtu.be/dQw4w9WgXcQ'),
          'dQw4w9WgXcQ',
        );
      });

      test('extracts from youtu.be without protocol', () {
        expect(
          Video.extractYoutubeId('youtu.be/dQw4w9WgXcQ'),
          'dQw4w9WgXcQ',
        );
      });

      test('extracts from youtube.com/watch URL', () {
        expect(
          Video.extractYoutubeId(
              'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
          'dQw4w9WgXcQ',
        );
      });

      test('extracts from youtube.com/embed URL', () {
        expect(
          Video.extractYoutubeId(
              'https://www.youtube.com/embed/dQw4w9WgXcQ'),
          'dQw4w9WgXcQ',
        );
      });

      test('extracts from youtube.com/shorts URL', () {
        expect(
          Video.extractYoutubeId(
              'https://www.youtube.com/shorts/dQw4w9WgXcQ'),
          'dQw4w9WgXcQ',
        );
      });

      test('extracts from URL without www', () {
        expect(
          Video.extractYoutubeId(
              'https://youtube.com/watch?v=dQw4w9WgXcQ'),
          'dQw4w9WgXcQ',
        );
      });

      test('returns null for invalid URL', () {
        expect(Video.extractYoutubeId('not-a-valid-url'), isNull);
      });

      test('returns null for empty string', () {
        expect(Video.extractYoutubeId(''), isNull);
      });

      test('handles URL with extra query params', () {
        final id = Video.extractYoutubeId(
            'https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=30s');
        expect(id, 'dQw4w9WgXcQ');
      });

      test('trims whitespace', () {
        expect(
          Video.extractYoutubeId('  dQw4w9WgXcQ  '),
          'dQw4w9WgXcQ',
        );
      });
    });

    // -----------------------------------------------------------------------
    // thumbnailUrl
    // -----------------------------------------------------------------------
    group('thumbnailUrl', () {
      test('returns correct thumbnail URL', () {
        expect(
          testVideo.thumbnailUrl,
          'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
        );
      });
    });

    // -----------------------------------------------------------------------
    // toMap
    // -----------------------------------------------------------------------
    test('toMap produces correct Firestore map', () {
      final map = testVideo.toMap();

      expect(map['title'], 'Tai Chi Tutorial');
      expect(map['youtubeId'], 'dQw4w9WgXcQ');
      expect(map['addedAt'], isA<Timestamp>());
      expect((map['addedAt'] as Timestamp).toDate(), testDate);
    });

    // -----------------------------------------------------------------------
    // fromFirestore
    // -----------------------------------------------------------------------
    test('fromFirestore parses DocumentSnapshot correctly', () async {
      // Write a video document to the fake Firestore.
      final docRef = await fakeFirestore.collection('videos').add({
        'title': 'Cooking Class',
        'youtubeId': 'abcdef12345',
        'addedAt': Timestamp.fromDate(testDate),
      });

      final snapshot = await docRef.get();
      final video = Video.fromFirestore(snapshot);

      expect(video.id, isNotEmpty);
      expect(video.title, 'Cooking Class');
      expect(video.youtubeId, 'abcdef12345');
      expect(video.addedAt, testDate);
    });

    // -----------------------------------------------------------------------
    // copyWith
    // -----------------------------------------------------------------------
    group('copyWith', () {
      test('returns new Video with only specified fields changed', () {
        final updated = testVideo.copyWith(title: 'New Title');

        expect(updated.title, 'New Title');
        expect(updated.id, testVideo.id);
        expect(updated.youtubeId, testVideo.youtubeId);
        expect(updated.addedAt, testVideo.addedAt);
      });

      test('replaces all fields when specified', () {
        final newDate = DateTime(2026, 8, 1);
        final updated = testVideo.copyWith(
          id: 'new-id',
          title: 'New Title',
          youtubeId: 'new12345678',
          addedAt: newDate,
        );

        expect(updated.id, 'new-id');
        expect(updated.title, 'New Title');
        expect(updated.youtubeId, 'new12345678');
        expect(updated.addedAt, newDate);
      });
    });

    // -----------------------------------------------------------------------
    // Equality
    // -----------------------------------------------------------------------
    group('equality', () {
      test('videos with same fields are equal', () {
        final a = Video(
          id: 'v1',
          title: 'Same',
          youtubeId: 'abc123xyz00',
          addedAt: testDate,
        );
        final b = Video(
          id: 'v1',
          title: 'Same',
          youtubeId: 'abc123xyz00',
          addedAt: testDate,
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('videos with different fields are not equal', () {
        final a = Video(
          id: 'v1',
          title: 'Same',
          youtubeId: 'abc123xyz00',
          addedAt: testDate,
        );
        final b = Video(
          id: 'v1',
          title: 'Different',
          youtubeId: 'abc123xyz00',
          addedAt: testDate,
        );

        expect(a, isNot(equals(b)));
      });
    });

    // -----------------------------------------------------------------------
    // toString
    // -----------------------------------------------------------------------
    test('toString contains key fields', () {
      final str = testVideo.toString();

      expect(str, contains('vid123'));
      expect(str, contains('Tai Chi Tutorial'));
      expect(str, contains('dQw4w9WgXcQ'));
    });
  });
}
