import '../../../auth/domain/entities/app_user.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Stream<UserProfile?> watchUserProfile(String userId);

  Stream<List<UserProfile>> watchUsers({
    required String query,
    required int limit,
  });

  Stream<List<UserProfile>> watchRecentUsers({required int limit});

  Stream<List<UserProfile>> watchActiveUsers({
    required int postLimit,
    required int userLimit,
  });

  Future<void> ensureUserProfile(AppUser user);
}
