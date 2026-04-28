import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shellPageStorageBucketProvider = Provider<PageStorageBucket>((ref) {
  return PageStorageBucket();
});
