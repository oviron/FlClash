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
    if (info == null || info.total == 0) {
      return Container();
    }
    final use = info.upload + info.download;
    final expireShow = info.expire != 0
        ? DateTime.fromMillisecondsSinceEpoch(info.expire * 1000).show
        : appLocalizations.infiniteTime;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: QuotaBar(
        value: use / info.total,
        label: '${use.traffic.show} / ${info.total.traffic.show} · $expireShow',
      ),
    );
  }
}
