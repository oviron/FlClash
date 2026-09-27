import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class IpQualityCheckState {
  const IpQualityCheckState();
}

class IpQualityIdle extends IpQualityCheckState {
  const IpQualityIdle();
}

class IpQualityChecking extends IpQualityCheckState {
  const IpQualityChecking();
}

class IpQualityChecked extends IpQualityCheckState {
  const IpQualityChecked(this.report);

  final IpQualityReport report;
}

// Scoped to the sheet that owns it (autoDispose): closing the sheet drops the
// state, so reopening it for a possibly different IP starts at idle again
// instead of showing a stale result.
typedef IpQualityLookup =
    Future<IpQualityReport> Function(String ip, {CancelToken? cancelToken});

final ipQualityLookupProvider = Provider<IpQualityLookup>(
  (_) => request.checkIpQuality,
);

class IpQualityCheck extends Notifier<IpQualityCheckState> {
  CancelToken? _cancelToken;

  @override
  IpQualityCheckState build() {
    ref.onDispose(() => _cancelToken?.cancel());
    return const IpQualityIdle();
  }

  Future<void> run(String ip) async {
    _cancelToken?.cancel();
    final token = CancelToken();
    _cancelToken = token;
    state = const IpQualityChecking();
    final lookup = ref.read(ipQualityLookupProvider);
    try {
      final report = await lookup(ip, cancelToken: token);
      if (token.isCancelled) return;
      state = IpQualityChecked(report);
    } catch (e) {
      if (token.isCancelled) return;
      commonPrint.log('IP quality check failed: ${e.runtimeType}');
      state = const IpQualityIdle();
    }
  }
}

final ipQualityCheckProvider =
    NotifierProvider.autoDispose<IpQualityCheck, IpQualityCheckState>(
      IpQualityCheck.new,
    );
