import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Shared by connections.dart and requests.dart: a PopupMenuButton offering
// "all" plus every process/app seen in the current list, mirroring the
// existing sort action's shape.
Widget buildProcessFilterAction(ValueNotifier<TrackerInfosState> notifier) {
  return PopupMenuButton<String>(
    icon: const Icon(Icons.filter_alt_outlined),
    onSelected: (value) {
      notifier.value = notifier.value.copyWith(processFilter: value);
    },
    itemBuilder: (_) {
      final state = notifier.value;
      final selected = state.resolvedProcessFilter;
      return [
        CheckedPopupMenuItem(
          value: '',
          checked: selected.isEmpty,
          child: Text(appLocalizations.allApplications),
        ),
        for (final process in state.availableProcesses)
          CheckedPopupMenuItem(
            value: process,
            checked: selected == process,
            child: Text(process),
          ),
      ];
    },
  );
}

class TrackerInfoItem extends ConsumerWidget {
  final TrackerInfo trackerInfo;
  final Function(String)? onClickKeyword;
  final Widget? trailing;
  final String detailTitle;

  const TrackerInfoItem({
    super.key,
    required this.trackerInfo,
    this.onClickKeyword,
    this.trailing,
    required this.detailTitle,
  });

  static double get subTitleHeight {
    return globalState.measure.bodySmallHeight + 20;
  }

  String _getSourceText(TrackerInfo trackerInfo) {
    final progress = trackerInfo.progressText.isNotEmpty
        ? '${trackerInfo.progressText} · '
        : '';
    final traffic = Traffic(up: trackerInfo.upload, down: trackerInfo.download);
    return '${trackerInfo.start.lastUpdateTimeDesc} · $progress${traffic.desc}';
  }

  @override
  Widget build(BuildContext context, ref) {
    final value = ref.watch(
      patchClashConfigProvider.select(
        (state) =>
            state.findProcessMode != FindProcessMode.off && system.isAndroid,
      ),
    );
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CountryFlag(ip: trackerInfo.metadata.destinationIP),
            Text(trackerInfo.desc, style: context.textTheme.bodyLarge),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _getSourceText(trackerInfo),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
    final subTitle = SizedBox(
      height: subTitleHeight,
      child: Row(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: ListView.separated(
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: trackerInfo.chains.length,
              itemBuilder: (_, index) {
                final chain = trackerInfo.chains[index];
                return CommonChip(
                  label: chain,
                  labelStyle: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    if (onClickKeyword == null) return;
                    onClickKeyword!(chain);
                  },
                );
              },
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
    final icon = value
        ? GestureDetector(
            onTap: () {
              if (onClickKeyword == null) return;
              final process = trackerInfo.metadata.process;
              if (process.isEmpty) return;
              onClickKeyword!(process);
            },
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              width: 42,
              height: 42,
              child: FutureBuilder<ImageProvider?>(
                future: app?.getPackageIcon(trackerInfo.metadata.process),
                builder: (_, snapshot) {
                  if (!snapshot.hasData && snapshot.data == null) {
                    return Container();
                  } else {
                    return Image(
                      image: snapshot.data!,
                      gaplessPlayback: true,
                      width: 42,
                      height: 42,
                    );
                  }
                },
              ),
            ),
          )
        : null;
    return ListItem(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () {
        showExtend(
          context,
          builder: (_, type) {
            return AdaptiveSheetScaffold(
              type: type,
              body: TrackerInfoDetailView(trackerInfo: trackerInfo),
              title: detailTitle,
            );
          },
        );
      },
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 12,
            children: [
              if (icon != null) icon,
              Flexible(child: title),
            ],
          ),
          const SizedBox(height: 8),
          subTitle,
        ],
      ),
    );
  }
}

class TrackerInfoDetailView extends StatelessWidget {
  final TrackerInfo trackerInfo;

  const TrackerInfoDetailView({super.key, required this.trackerInfo});

  String _getRuleText() {
    final rule = trackerInfo.rule;
    final rulePayload = trackerInfo.rulePayload;
    if (rulePayload.isNotEmpty) {
      return '$rule($rulePayload)';
    }
    return rule;
  }

  String _getProcessText() {
    final process = trackerInfo.metadata.process;
    final uid = trackerInfo.metadata.uid;
    if (uid != 0) {
      return '$process($uid)';
    }
    return process;
  }

  String _getSourceText() {
    final sourceIP = trackerInfo.metadata.sourceIP;
    if (sourceIP.isEmpty) {
      return '';
    }
    final sourcePort = trackerInfo.metadata.sourcePort;
    if (sourcePort.isNotEmpty) {
      return '$sourceIP:$sourcePort';
    }
    return sourceIP;
  }

  String _getDestinationText() {
    final destinationIP = trackerInfo.metadata.destinationIP;
    if (destinationIP.isEmpty) {
      return '';
    }
    final destinationPort = trackerInfo.metadata.destinationPort;
    if (destinationPort.isNotEmpty) {
      return '$destinationIP:$destinationPort';
    }
    return destinationIP;
  }

  Widget _buildChains() {
    final chains = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        for (final chain in trackerInfo.chains)
          CommonChip(label: chain, onPressed: () {}),
      ],
    );
    return ListItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          Text(appLocalizations.proxyChains),
          Flexible(child: chains),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String title,
    required String desc,
    bool quickCopy = false,
  }) {
    return ListItem(
      title: Row(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 4,
            children: [
              Text(title),
              if (quickCopy)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.content_copy, size: 18),
                    onPressed: () {},
                  ),
                ),
            ],
          ),
          Flexible(child: Text(desc, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _buildItem(
        title: appLocalizations.creationTime,
        desc: trackerInfo.start.showFull,
      ),
      if (_getProcessText().isNotEmpty)
        _buildItem(title: appLocalizations.process, desc: _getProcessText()),
      _buildItem(
        title: appLocalizations.networkType,
        desc: trackerInfo.metadata.network,
      ),
      _buildItem(title: appLocalizations.rule, desc: _getRuleText()),
      if (trackerInfo.metadata.host.isNotEmpty)
        _buildItem(
          title: appLocalizations.host,
          desc: trackerInfo.metadata.host,
        ),
      if (_getSourceText().isNotEmpty)
        _buildItem(title: appLocalizations.source, desc: _getSourceText()),
      if (_getDestinationText().isNotEmpty)
        _buildItem(
          title: appLocalizations.destination,
          desc: _getDestinationText(),
        ),
      _buildItem(
        title: appLocalizations.upload,
        desc: trackerInfo.upload.traffic.show,
      ),
      _buildItem(
        title: appLocalizations.download,
        desc: trackerInfo.download.traffic.show,
      ),
      if (trackerInfo.metadata.destinationGeoIP.isNotEmpty)
        _buildItem(
          title: appLocalizations.destinationGeoIP,
          desc: trackerInfo.metadata.destinationGeoIP.join(' '),
        ),
      if (trackerInfo.metadata.destinationIPASN.isNotEmpty)
        _buildItem(
          title: appLocalizations.destinationIPASN,
          desc: trackerInfo.metadata.destinationIPASN,
        ),
      if (trackerInfo.metadata.dnsMode != null)
        _buildItem(
          title: appLocalizations.dnsMode,
          desc: trackerInfo.metadata.dnsMode!.name,
        ),
      if (trackerInfo.metadata.specialProxy.isNotEmpty)
        _buildItem(
          title: appLocalizations.specialProxy,
          desc: trackerInfo.metadata.specialProxy,
        ),
      if (trackerInfo.metadata.specialRules.isNotEmpty)
        _buildItem(
          title: appLocalizations.specialRules,
          desc: trackerInfo.metadata.specialRules,
        ),
      if (trackerInfo.metadata.remoteDestination.isNotEmpty)
        _buildItem(
          title: appLocalizations.remoteDestination,
          desc: trackerInfo.metadata.remoteDestination,
        ),
      _buildChains(),
    ];
    return SelectionArea(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: items.length,
        itemBuilder: (_, index) {
          return items[index];
        },
      ),
    );
  }
}

// Renders the destination's country flag once resolved, nothing before that
// or when it can't be (private/local address, domain with no IP, lookup
// error) — resolution goes through the shared, bounded [countryCodeCache].
class _CountryFlag extends StatefulWidget {
  const _CountryFlag({required this.ip});

  final String ip;

  @override
  State<_CountryFlag> createState() => _CountryFlagState();
}

class _CountryFlagState extends State<_CountryFlag> {
  String? _emoji;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _CountryFlag oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ip != widget.ip) {
      _emoji = null;
      _resolve();
    }
  }

  String? _emojiFor(IpInfo? info) =>
      info == null ? null : countryCodeToEmoji(info.countryCode);

  void _resolve() {
    if (!shouldLookUpCountryCode(widget.ip)) return;
    if (countryCodeCache.containsKey(widget.ip)) {
      _emoji = _emojiFor(countryCodeCache.peek(widget.ip));
      return;
    }
    countryCodeCache.resolve(widget.ip).then((info) {
      if (!mounted) return;
      final emoji = _emojiFor(info);
      if (emoji == null) return;
      setState(() => _emoji = emoji);
    });
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _emoji;
    if (emoji == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        emoji,
        style: context.textTheme.bodyLarge?.copyWith(
          fontFamily: FontFamily.twEmoji.value,
        ),
      ),
    );
  }
}
