import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../firebase_options.dart';
import '../constants/app_strings.dart';
import '../providers/firebase_providers.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    debugPrint('FCM background message: ${message.messageId}');
  }
}

class NotificationSetupState {
  const NotificationSetupState({
    required this.isInitialized,
    required this.permissionGranted,
    required this.token,
    required this.errorMessage,
  });

  const NotificationSetupState.initial()
    : isInitialized = false,
      permissionGranted = false,
      token = null,
      errorMessage = null;

  final bool isInitialized;
  final bool permissionGranted;
  final String? token;
  final String? errorMessage;
}

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, NotificationSetupState>(
      NotificationController.new,
    );

class NotificationController extends AsyncNotifier<NotificationSetupState> {
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;

  @override
  FutureOr<NotificationSetupState> build() {
    ref.onDispose(() {
      _foregroundSubscription?.cancel();
      _openedSubscription?.cancel();
    });
    return const NotificationSetupState.initial();
  }

  Future<void> initialize() async {
    if (state.asData?.value.isInitialized == true) {
      return;
    }

    final messaging = ref.read(firebaseMessagingProvider);
    try {
      final settings = await messaging.requestPermission();
      final isGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!isGranted) {
        state = const AsyncData(
          NotificationSetupState(
            isInitialized: true,
            permissionGranted: false,
            token: null,
            errorMessage: AppStrings.notificationsPermissionDenied,
          ),
        );
        debugPrint('FCM permission denied.');
        return;
      }

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      final token = await messaging.getToken();
      if (kDebugMode) {
        debugPrint('FCM token: $token');
      }

      _foregroundSubscription ??= FirebaseMessaging.onMessage.listen((message) {
        debugPrint(
          'FCM foreground message: id=${message.messageId}, '
          'type=${message.data['type']}',
        );
      });
      _openedSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen((
        message,
      ) {
        debugPrint(
          'FCM opened message: id=${message.messageId}, '
          'type=${message.data['type']}',
        );
      });

      state = AsyncData(
        NotificationSetupState(
          isInitialized: true,
          permissionGranted: true,
          token: token,
          errorMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('FCM initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace, label: 'FCM init stack');
      state = AsyncError(error, stackTrace);
    }
  }
}
