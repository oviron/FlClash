import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/quota_bar.dart';
import 'package:flutter/material.dart';

class SubscriptionInfoView extends StatelessWidget {
  final SubscriptionInfo? subscriptionInfo;

  const SubscriptionInfoView({super.key, this.subscriptionInfo});

  @override
  Widget build(BuildContext context) {
    final info = subscriptionInfo;
    // Render while either quota or expiry is set; hide only when both are unset.
    if (info == null || (info.total == 0 && info.expire == 0)) {
      return const SizedBox.shrink();
    }
    final hasQuota = info.total > 0;
    final ratio = hasQuota ? info.used / info.total : 0.0;

    final meta = <String>[
      '↑ ${info.upload.traffic.show}',
      '↓ ${info.download.traffic.show}',
      if (info.expire != 0)
        DateTime.fromMillisecondsSinceEpoch(info.expire * 1000).expiresInDesc
      else
        appLocalizations.infiniteTime,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasQuota)
            QuotaBar(
              value: ratio,
              label:
                  '${info.used.traffic.show} / ${info.total.traffic.show}'
                  '  ·  ${(ratio.clamp(0.0, 1.0) * 100).round()}%'
                  '  ·  ${appLocalizations.subRemaining(info.remaining.traffic.show)}',
            ),
          Padding(
            padding: EdgeInsets.only(top: hasQuota ? 4 : 0),
            child: Text(
              meta.join('   ·   '),
              style: context.textTheme.labelSmall?.toLight,
            ),
          ),
        ],
      ),
    );
  }
}
