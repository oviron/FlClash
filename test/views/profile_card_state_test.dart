import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/profiles/profile_card_state.dart';
import 'package:flutter_test/flutter_test.dart';

SubscriptionInfo _info({int total = 0}) =>
    SubscriptionInfo(upload: 1, download: 2, total: total, expire: 0);

void main() {
  group('resolveProfileCardState', () {
    test('file profile is always localFile, even with stray info', () {
      expect(
        resolveProfileCardState(ProfileType.file, null),
        ProfileCardState.localFile,
      );
      expect(
        resolveProfileCardState(ProfileType.file, _info(total: 50)),
        ProfileCardState.localFile,
      );
    });

    test('url with a non-zero total quota is subscriptionQuota', () {
      expect(
        resolveProfileCardState(ProfileType.url, _info(total: 50)),
        ProfileCardState.subscriptionQuota,
      );
    });

    test('url without info is urlNoQuota', () {
      expect(
        resolveProfileCardState(ProfileType.url, null),
        ProfileCardState.urlNoQuota,
      );
    });

    test('url with zero-total info is urlNoQuota', () {
      expect(
        resolveProfileCardState(ProfileType.url, _info()),
        ProfileCardState.urlNoQuota,
      );
    });
  });
}
