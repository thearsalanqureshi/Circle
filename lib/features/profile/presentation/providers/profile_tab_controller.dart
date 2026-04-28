import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ProfileTab { posts, saved }

final profileTabControllerProvider =
    NotifierProvider.autoDispose<ProfileTabController, ProfileTab>(
      ProfileTabController.new,
    );

class ProfileTabController extends Notifier<ProfileTab> {
  @override
  ProfileTab build() => ProfileTab.posts;

  void select(ProfileTab tab) {
    state = tab;
  }
}
