import 'package:fl_clash/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String providerQuotaKey(int profileId, String provider) =>
    '$profileId:$provider';

/// In-memory per-(profile, provider) subscription quota parsed from each
/// provider's `subscription-userinfo` header. Refreshed on every prefetch (each
/// apply), so it is live data re-fetched on connect rather than persisted.
class ProviderQuota extends Notifier<Map<String, SubscriptionInfo>> {
  @override
  Map<String, SubscriptionInfo> build() => const {};

  void set(int profileId, String provider, SubscriptionInfo info) {
    state = {...state, providerQuotaKey(profileId, provider): info};
  }

  SubscriptionInfo? of(int profileId, String provider) =>
      state[providerQuotaKey(profileId, provider)];
}

final providerQuotaProvider =
    NotifierProvider<ProviderQuota, Map<String, SubscriptionInfo>>(
      ProviderQuota.new,
    );
