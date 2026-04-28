import 'package:hive_flutter/hive_flutter.dart';

import '../constants/hive_keys.dart';

class HiveBootstrap {
  const HiveBootstrap._();

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(HiveKeys.preferencesBox);
    await Hive.openBox<dynamic>(HiveKeys.aiCacheBox);
    await Hive.openBox<dynamic>(HiveKeys.feedPostsCacheBox);
  }

  static Box<dynamic> get preferencesBox {
    return Hive.box<dynamic>(HiveKeys.preferencesBox);
  }

  static Box<dynamic> get aiCacheBox {
    return Hive.box<dynamic>(HiveKeys.aiCacheBox);
  }

  static Box<dynamic> get feedPostsCacheBox {
    return Hive.box<dynamic>(HiveKeys.feedPostsCacheBox);
  }
}
