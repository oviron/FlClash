import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/ip_quality.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showIpQualitySheet(BuildContext context, {required String ip}) {
  return showSheet<void>(
    context: context,
    props: const SheetProps(isScrollControlled: true),
    builder: (_, type) => IpQualitySheet(type: type, ip: ip),
  );
}

class IpQualitySheet extends ConsumerWidget {
  const IpQualitySheet({super.key, required this.type, required this.ip});

  final SheetType type;
  final String ip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ipQualityCheckProvider);
    void run() => ref.read(ipQualityCheckProvider.notifier).run(ip);
    return AdaptiveSheetScaffold(
      type: type,
      title: appLocalizations.ipQualityCheck,
      actions: [
        if (state is! IpQualityIdle)
          CommonMinIconButtonTheme(
            child: IconButton.filledTonal(
              tooltip: appLocalizations.ipQualityRetry,
              onPressed: state is IpQualityChecking ? null : run,
              icon: const Icon(Icons.refresh),
            ),
          ),
      ],
      body: switch (state) {
        IpQualityIdle() => _IntroBody(ip: ip, onCheck: run),
        IpQualityChecking() => const _LoadingBody(),
        IpQualityChecked(:final report) => _ResultBody(report: report),
      },
    );
  }
}

class _IntroBody extends StatelessWidget {
  const _IntroBody({required this.ip, required this.onCheck});

  final String ip;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appLocalizations.ipQualityIntro(ip),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          generateSectionV2(
            title: appLocalizations.ipQualitySources,
            items: [
              for (final source in IpQualitySource.values)
                ListItem(
                  leading: const Icon(Icons.dns_outlined),
                  title: Text(source.label),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCheck,
              child: Text(appLocalizations.ipQualityCheckAction),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: SizedBox(width: 28, height: 28, child: CommonCircleLoading()),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.report});

  final IpQualityReport report;

  @override
  Widget build(BuildContext context) {
    final verdict = report.verdict;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        if (verdict != null)
          generateSectionV2(
            title: appLocalizations.ipQualityResult,
            items: _verdictItems(context, verdict),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              appLocalizations.ipQualityFailed,
              style: TextStyle(color: context.colorScheme.error),
            ),
          ),
        const SizedBox(height: 12),
        generateSectionV2(
          title: appLocalizations.ipQualitySources,
          items: [
            for (final result in report.results)
              ListItem(
                title: Text(result.source.label),
                trailing: result.answer != null
                    ? Text(result.answer!.quality.type.label)
                    : Text(
                        result.failure!.label,
                        style: TextStyle(color: context.colorScheme.error),
                      ),
              ),
          ],
        ),
      ],
    );
  }

  List<Widget> _verdictItems(BuildContext context, IpQuality verdict) {
    final flags = [
      if (verdict.isTor) appLocalizations.ipFlagTor,
      if (verdict.isAbuser) appLocalizations.ipFlagAbuser,
      if (verdict.isVpn) appLocalizations.ipFlagVpn,
      if (verdict.isProxy) appLocalizations.ipFlagProxy,
    ];
    return [
      ListItem(
        title: Text(appLocalizations.ipAddress),
        trailing: Text(report.ip),
      ),
      ListItem(
        title: Text(appLocalizations.ipQualityLevel),
        trailing: Text(
          verdict.level.label,
          style: TextStyle(color: verdict.level.color(context)),
        ),
      ),
      ListItem(
        title: Text(appLocalizations.ipType),
        trailing: Text(verdict.type.label),
      ),
      if (verdict.organization case final organization?)
        ListItem(
          title: Text(appLocalizations.ipOrganization),
          trailing: Text(organization),
        ),
      if (verdict.asn case final asn?)
        ListItem(title: Text(appLocalizations.ipAsn), trailing: Text('AS$asn')),
      ListItem(
        title: Text(appLocalizations.ipFlags),
        trailing: flags.isEmpty
            ? Text(appLocalizations.none)
            : Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: [
                  for (final flag in flags)
                    CommonChip(label: flag, type: ChipType.tonal),
                ],
              ),
      ),
    ];
  }
}

extension _IpTypeLabel on IpType {
  String get label => switch (this) {
    IpType.residential => appLocalizations.ipTypeResidential,
    IpType.mobile => appLocalizations.ipTypeMobile,
    IpType.business => appLocalizations.ipTypeBusiness,
    IpType.hosting => appLocalizations.ipTypeHosting,
  };
}

extension _IpQualityLevelLabel on IpQualityLevel {
  String get label => switch (this) {
    IpQualityLevel.good => appLocalizations.ipQualityGood,
    IpQualityLevel.normal => appLocalizations.ipQualityNormal,
    IpQualityLevel.risky => appLocalizations.ipQualityRisky,
  };

  Color? color(BuildContext context) => switch (this) {
    IpQualityLevel.good => context.colorScheme.success,
    IpQualityLevel.normal => null,
    IpQualityLevel.risky => context.colorScheme.error,
  };
}

extension _IpQualitySourceStatusLabel on IpQualitySourceStatus {
  String get label => switch (this) {
    IpQualitySourceStatus.noType => appLocalizations.ipSourceNoType,
    IpQualitySourceStatus.timeout => appLocalizations.detectionTimeout,
    IpQualitySourceStatus.rateLimited => appLocalizations.ipSourceRateLimited,
    IpQualitySourceStatus.failed => appLocalizations.ipSourceFailed,
    IpQualitySourceStatus.ipMismatch => appLocalizations.ipSourceIpMismatch,
  };
}
