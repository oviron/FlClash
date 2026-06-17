import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

/// How a profile card should render given the data it actually has.
enum ProfileCardState { subscriptionQuota, urlNoQuota, localFile }

/// Subscription URLs report quota only when [SubscriptionInfo.total] is set;
/// without it (or for a local file) the card degrades to a stat line. A `null`
/// or zero-total info on a URL profile is the common "no quota" case.
ProfileCardState resolveProfileCardState(
  ProfileType type,
  SubscriptionInfo? info,
) {
  if (type == ProfileType.file) return ProfileCardState.localFile;
  return info != null && info.total != 0
      ? ProfileCardState.subscriptionQuota
      : ProfileCardState.urlNoQuota;
}
