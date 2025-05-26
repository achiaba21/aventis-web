import 'package:flutter/foundation.dart';

void deboger(Object? object) {
  if (kDebugMode) {
    print(object);
  }
}

T? findByid<T>(List<T> items, bool Function(T) test) {
  try {
    return items.firstWhere(test);
  } catch (e) {
    return null;
  }
}
