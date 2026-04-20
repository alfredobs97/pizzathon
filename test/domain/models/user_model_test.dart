import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pizzathon/domain/models/user_model.dart';

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  late MockDocumentSnapshot mockSnapshot;

  setUp(() {
    mockSnapshot = MockDocumentSnapshot();
  });

  group('UserModel.fromDocument', () {
    test('should map data correctly including isBanned when present', () {
      final now = Timestamp.now();
      when(() => mockSnapshot.id).thenReturn('user123');
      when(() => mockSnapshot.data()).thenReturn({
        'displayName': 'John Doe',
        'email': 'john@example.com',
        'photoUrl': 'https://example.com/photo.jpg',
        'score': 100,
        'createdAt': now,
        'banned': true,
      });

      final user = UserModel.fromDocument(mockSnapshot);

      expect(user.uid, 'user123');
      expect(user.displayName, 'John Doe');
      expect(user.isBanned, true);
    });

    test('should default isBanned to false when not present in the document', () {
      final now = Timestamp.now();
      when(() => mockSnapshot.id).thenReturn('user123');
      when(() => mockSnapshot.data()).thenReturn({
        'displayName': 'John Doe',
        'email': 'john@example.com',
        'photoUrl': 'https://example.com/photo.jpg',
        'score': 100,
        'createdAt': now,
        // 'banned' field is missing
      });

      final user = UserModel.fromDocument(mockSnapshot);

      expect(user.uid, 'user123');
      expect(user.isBanned, false);
    });

    test('should handle null banned field by defaulting to false', () {
      final now = Timestamp.now();
      when(() => mockSnapshot.id).thenReturn('user123');
      when(() => mockSnapshot.data()).thenReturn({
        'displayName': 'John Doe',
        'email': 'john@example.com',
        'photoUrl': 'https://example.com/photo.jpg',
        'score': 100,
        'createdAt': now,
        'banned': null,
      });

      final user = UserModel.fromDocument(mockSnapshot);

      expect(user.uid, 'user123');
      expect(user.isBanned, false);
    });
  });
}
