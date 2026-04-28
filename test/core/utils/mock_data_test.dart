import 'package:circle/core/utils/mock_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockData', () {
    test('provides Phase 2 UI data for each main surface', () {
      expect(MockData.posts, isNotEmpty);
      expect(MockData.users, isNotEmpty);
      expect(MockData.notifications, isNotEmpty);
      expect(MockData.aiTools, hasLength(4));
    });

    test('keeps post routes addressable with stable ids', () {
      for (final post in MockData.posts) {
        expect(post.id, isNotEmpty);
        expect(post.userId, isNotEmpty);
      }
    });
  });
}
