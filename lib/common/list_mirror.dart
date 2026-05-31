import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/function.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/widgets.dart';

typedef StateListGetter<TState, TList> = TList Function(TState state);
typedef StateListSetter<TState, TList> =
    TState Function(TState state, TList list);

void scheduleThrottledListMirrorUpdate<TState, TList>({
  required FunctionTag tag,
  required bool Function() mounted,
  required TList source,
  required ValueNotifier<TState> notifier,
  required StateListGetter<TState, TList> currentList,
  required StateListSetter<TState, TList> updateList,
  required bool Function(TList a, TList b) equals,
  Duration duration = commonDuration,
}) {
  throttler.call(tag, () {
    if (!mounted()) {
      return;
    }
    if (equals(source, currentList(notifier.value))) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted()) {
        return;
      }
      notifier.value = updateList(notifier.value, source);
    });
  }, duration: duration);
}
