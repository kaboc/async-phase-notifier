import 'package:flutter/foundation.dart';

import 'async_phase.dart';

class AsyncPhaseNotifier<T> extends ValueNotifier<AsyncPhase<T>> {
  AsyncPhaseNotifier(T value) : super(AsyncComplete(data: value));

  @override
  @protected
  set value(AsyncPhase<T> newValue) {
    if (newValue.data != null || newValue is AsyncComplete) {
      super.value = newValue;
    }
    if (newValue.isWaiting) {
      super.value = newValue.data == value.data
          ? newValue
          : AsyncWaiting(data: value.data);
    }
    if (newValue.isError) {
      super.value = newValue.data == value.data
          ? newValue
          : AsyncError(
              data: value.data,
              error: newValue.error,
              stackTrace: newValue.stackTrace,
            );
    }
  }

  void runAsync(Future<T> Function(T?) func) {
    value = AsyncWaiting(data: value.data);

    AsyncPhase.from<T>(
      () => func(value.data),
      fallbackData: value.data,
    ).then((result) => value = result);
  }
}
