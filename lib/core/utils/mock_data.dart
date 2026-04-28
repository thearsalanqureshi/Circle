import 'package:flutter/material.dart';

class MockData {
  const MockData._();

  static const users = [
    MockUser(
      id: 'u-maya',
      name: 'Maya Chen',
      handle: '@maya',
      bio: 'UX writer, coffee notes, weekend city walks.',
      followers: '12.4K',
      posts: '148',
      accentIcon: Icons.palette_outlined,
    ),
    MockUser(
      id: 'u-omar',
      name: 'Omar Ali',
      handle: '@omar',
      bio: 'Product builder sharing tiny lessons from big launches.',
      followers: '8.2K',
      posts: '91',
      accentIcon: Icons.rocket_launch_outlined,
    ),
    MockUser(
      id: 'u-nina',
      name: 'Nina Park',
      handle: '@nina',
      bio: 'Photography, motion, and everyday visual systems.',
      followers: '21K',
      posts: '230',
      accentIcon: Icons.camera_alt_outlined,
    ),
    MockUser(
      id: 'u-zain',
      name: 'Zain Malik',
      handle: '@zain',
      bio: 'Flutter engineer documenting clean UI patterns.',
      followers: '6.7K',
      posts: '76',
      accentIcon: Icons.code_outlined,
    ),
  ];

  static const posts = [
    MockPost(
      id: 'p-001',
      userId: 'u-maya',
      username: 'Maya Chen',
      handle: '@maya',
      text:
          'A quiet interface wins when every repeated action feels predictable.',
      minutesAgo: '12m',
      likes: '248',
      comments: '34',
      shares: '12',
      hasImage: true,
      imageTitle: 'Design notes',
      imageIcon: Icons.dashboard_customize_outlined,
    ),
    MockPost(
      id: 'p-002',
      userId: 'u-omar',
      username: 'Omar Ali',
      handle: '@omar',
      text:
          'Shipping small improvements every day still compounds faster than a perfect redesign that never lands.',
      minutesAgo: '28m',
      likes: '531',
      comments: '72',
      shares: '25',
      hasImage: false,
      imageTitle: '',
      imageIcon: Icons.rocket_launch_outlined,
    ),
    MockPost(
      id: 'p-003',
      userId: 'u-nina',
      username: 'Nina Park',
      handle: '@nina',
      text:
          'Golden hour is less about light and more about waiting long enough for the city to soften.',
      minutesAgo: '1h',
      likes: '1.8K',
      comments: '116',
      shares: '80',
      hasImage: true,
      imageTitle: 'City glow',
      imageIcon: Icons.photo_camera_outlined,
    ),
    MockPost(
      id: 'p-004',
      userId: 'u-zain',
      username: 'Zain Malik',
      handle: '@zain',
      text:
          'Clean Architecture pays off when a screen can change shape without dragging business logic with it.',
      minutesAgo: '2h',
      likes: '409',
      comments: '41',
      shares: '18',
      hasImage: false,
      imageTitle: '',
      imageIcon: Icons.code_outlined,
    ),
  ];

  static const notifications = [
    MockNotification(
      id: 'n-001',
      icon: Icons.favorite_border,
      title: 'Maya liked your post',
      body: 'Your note about focused design is getting attention.',
      time: '4m',
      unread: true,
    ),
    MockNotification(
      id: 'n-002',
      icon: Icons.mode_comment_outlined,
      title: 'Omar commented',
      body: 'Small improvements compound. This one landed well.',
      time: '18m',
      unread: true,
    ),
    MockNotification(
      id: 'n-003',
      icon: Icons.person_add_alt_outlined,
      title: 'Nina followed you',
      body: 'You are now connected in Circle.',
      time: '1h',
      unread: false,
    ),
    MockNotification(
      id: 'n-004',
      icon: Icons.ios_share_outlined,
      title: 'Zain shared your post',
      body: 'Your architecture checklist was shared with builders.',
      time: '3h',
      unread: false,
    ),
  ];

  static const aiTools = [
    MockAiTool(
      title: 'Tone Transformer',
      body: 'Rewrite a draft into professional, funny, or emotional tones.',
      icon: Icons.tune_outlined,
    ),
    MockAiTool(
      title: 'Mood-to-Post',
      body: 'Turn a mood into a polished post idea and hashtags.',
      icon: Icons.mood_outlined,
    ),
    MockAiTool(
      title: 'Smart Reply',
      body: 'Preview contextual reply chips for comment threads.',
      icon: Icons.quickreply_outlined,
    ),
    MockAiTool(
      title: 'Feed Summarizer',
      body: 'See a UI placeholder for concise feed recaps.',
      icon: Icons.summarize_outlined,
    ),
  ];
}

class MockUser {
  const MockUser({
    required this.id,
    required this.name,
    required this.handle,
    required this.bio,
    required this.followers,
    required this.posts,
    required this.accentIcon,
  });

  final String id;
  final String name;
  final String handle;
  final String bio;
  final String followers;
  final String posts;
  final IconData accentIcon;
}

class MockPost {
  const MockPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.handle,
    required this.text,
    required this.minutesAgo,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.hasImage,
    required this.imageTitle,
    required this.imageIcon,
  });

  final String id;
  final String userId;
  final String username;
  final String handle;
  final String text;
  final String minutesAgo;
  final String likes;
  final String comments;
  final String shares;
  final bool hasImage;
  final String imageTitle;
  final IconData imageIcon;
}

class MockNotification {
  const MockNotification({
    required this.id,
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
  });

  final String id;
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final bool unread;
}

class MockAiTool {
  const MockAiTool({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}
