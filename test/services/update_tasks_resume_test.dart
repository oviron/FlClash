import 'package:fake_async/fake_async.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter_test/flutter_test.dart';

// Characterizes the 1s UI update loop: stopped on pause, it must be
// restartable with the tasks it already carries — that is what the resume
// path relies on to unfreeze traffic and run time.
void main() {
  tearDown(() {
    globalState.stopUpdateTasks();
    globalState.tasks = [];
  });

  test('startUpdateTasks with no args resumes the stored tasks', () {
    fakeAsync((async) {
      var runs = 0;
      globalState.startUpdateTasks([() => runs++]);
      async.elapse(const Duration(milliseconds: 2500));
      expect(runs, 3, reason: 'immediate run + one per second');

      globalState.stopUpdateTasks();
      async.elapse(const Duration(seconds: 5));
      expect(runs, 3, reason: 'stopped loop must not tick');

      globalState.startUpdateTasks();
      async.elapse(const Duration(milliseconds: 1500));
      expect(runs, 5, reason: 'no-arg restart reuses the stored tasks');
    });
  });

  test('startUpdateTasks is idempotent while the loop is live', () {
    fakeAsync((async) {
      var runs = 0;
      globalState.startUpdateTasks([() => runs++]);
      async.elapse(const Duration(milliseconds: 100));
      globalState.startUpdateTasks();
      globalState.startUpdateTasks();
      async.elapse(const Duration(milliseconds: 1000));
      expect(runs, 2, reason: 'double start must not double the cadence');
    });
  });
}
