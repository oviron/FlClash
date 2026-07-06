import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/provider_quota.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('quota key namespaces by profile and provider', () {
    expect(providerQuotaKey(3, 'happ-sub'), '3:happ-sub');
    expect(
      providerQuotaKey(3, 'happ-sub'),
      isNot(providerQuotaKey(4, 'happ-sub')),
    );
  });

  test('set/of round-trips per (profile, provider); others stay unset', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(providerQuotaProvider.notifier);

    const info = SubscriptionInfo(upload: 1, download: 2, total: 50, expire: 9);
    notifier.set(3, 'happ-sub', info);

    expect(notifier.of(3, 'happ-sub'), info);
    expect(notifier.of(3, 'other'), isNull);
    expect(notifier.of(4, 'happ-sub'), isNull);
  });
}
