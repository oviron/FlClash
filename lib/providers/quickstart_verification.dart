import 'package:fl_clash/common/request.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum QuickStartVerifyStatus { idle, verifying, verified, failed }

// Verified only when a real page loaded: a null probe (nothing reachable) or a
// REJECT default route is an honest failure, never a false green.
QuickStartVerifyStatus decideVerifyStatus(Result<IpInfo?> probe) {
  final info = probe.data;
  if (probe.isError || info == null || info.isRejected) {
    return QuickStartVerifyStatus.failed;
  }
  return QuickStartVerifyStatus.verified;
}

// Connect-time honesty gate: after a quick-start key connects, probe the tunnel
// and report verifying -> verified / failed.
class QuickStartVerification extends Notifier<QuickStartVerifyStatus> {
  @override
  QuickStartVerifyStatus build() => QuickStartVerifyStatus.idle;

  Future<void> run() async {
    state = QuickStartVerifyStatus.verifying;
    final probe = await request.checkIp();
    // A newer run() or a dismiss() may have superseded this probe; only commit
    // if we are still the in-flight verification.
    if (state != QuickStartVerifyStatus.verifying) return;
    state = decideVerifyStatus(probe);
    if (state == QuickStartVerifyStatus.verified) {
      // Auto-dismiss from the notifier (not a widget ref) so a tab switch during
      // the window can't use a disposed ref.
      Future.delayed(const Duration(seconds: 2), () {
        if (state == QuickStartVerifyStatus.verified) dismiss();
      });
    }
  }

  void dismiss() => state = QuickStartVerifyStatus.idle;
}

final quickStartVerificationProvider =
    NotifierProvider<QuickStartVerification, QuickStartVerifyStatus>(
      QuickStartVerification.new,
    );
