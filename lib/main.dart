import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/circle_app.dart';
import 'core/services/firebase_bootstrap.dart';
import 'core/services/hive_bootstrap.dart';
import 'core/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseBootstrap.initialize();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await HiveBootstrap.initialize();

  runApp(const ProviderScope(child: CircleApp()));
}
