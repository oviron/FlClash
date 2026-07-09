import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'item.dart';

class ConnectionsView extends ConsumerStatefulWidget {
  const ConnectionsView({super.key});

  @override
  ConsumerState<ConnectionsView> createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends ConsumerState<ConnectionsView> {
  final _connectionsStateNotifier = ValueNotifier<TrackerInfosState>(
    const TrackerInfosState(),
  );
  final ScrollController _scrollController = ScrollController();

  Timer? timer;

  Map<String, ({int upload, int download})> _prevBytes = {};
  DateTime? _lastUpdate;

  List<Widget> _buildActions() {
    return [
      _buildSortAction(),
      IconButton(
        onPressed: () async {
          coreController.closeAllConnections();
          await _updateConnections();
        },
        icon: const Icon(Icons.delete_sweep_outlined),
      ),
    ];
  }

  Widget _buildSortAction() {
    return PopupMenuButton<ConnectionsSortType>(
      icon: const Icon(Icons.sort),
      onSelected: (value) {
        _connectionsStateNotifier.value = _connectionsStateNotifier.value
            .copyWith(sortType: value);
      },
      itemBuilder: (_) => [
        for (final type in ConnectionsSortType.values)
          CheckedPopupMenuItem(
            value: type,
            checked: _connectionsStateNotifier.value.sortType == type,
            child: Text(_sortLabel(type)),
          ),
      ],
    );
  }

  String _sortLabel(ConnectionsSortType type) => switch (type) {
    ConnectionsSortType.none => appLocalizations.defaultText,
    ConnectionsSortType.traffic => appLocalizations.traffic,
    ConnectionsSortType.speed => appLocalizations.speed,
  };

  void _onSearch(String value) {
    _connectionsStateNotifier.value = _connectionsStateNotifier.value.copyWith(
      query: value,
    );
  }

  void _onKeywordsUpdate(List<String> keywords) {
    _connectionsStateNotifier.value = _connectionsStateNotifier.value.copyWith(
      keywords: keywords,
    );
  }

  Future<void> _updateConnectionsTask() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await _updateConnections();
        timer = Timer(const Duration(seconds: 1), () async {
          unawaited(_updateConnectionsTask());
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _updateConnectionsTask();
  }

  Future<void> _updateConnections() async {
    final raw = await coreController.getConnections();
    final now = DateTime.now();
    final interval = _lastUpdate == null
        ? 0.0
        : now.difference(_lastUpdate!).inMilliseconds / 1000.0;
    final withSpeed = computeConnectionSpeeds(raw, _prevBytes, interval);
    _prevBytes = {
      for (final info in raw)
        info.id: (upload: info.upload, download: info.download),
    };
    _lastUpdate = now;
    _connectionsStateNotifier.value = _connectionsStateNotifier.value.copyWith(
      trackerInfos: withSpeed,
    );
  }

  Future<void> _handleBlockConnection(String id) async {
    coreController.closeConnection(id);
    await _updateConnections();
  }

  @override
  void dispose() {
    timer?.cancel();
    _connectionsStateNotifier.dispose();
    _scrollController.dispose();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: appLocalizations.connections,
      onKeywordsUpdate: _onKeywordsUpdate,
      searchState: AppBarSearchState(onSearch: _onSearch),
      actions: _buildActions(),
      body: ValueListenableBuilder<TrackerInfosState>(
        valueListenable: _connectionsStateNotifier,
        builder: (context, state, _) {
          final connections = state.list;
          if (connections.isEmpty) {
            return NullStatus(
              label: appLocalizations.nullTip(appLocalizations.connections),
              illustration: const ConnectionEmptyIllustration(),
            );
          }
          final items = connections
              .map<Widget>(
                (trackerInfo) => TrackerInfoItem(
                  key: Key(trackerInfo.id),
                  trackerInfo: trackerInfo,
                  onClickKeyword: (value) {
                    context.commonScaffoldState?.addKeyword(value);
                  },
                  trailing: IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(minimumSize: Size.zero),
                    icon: const Icon(Icons.block),
                    onPressed: () {
                      _handleBlockConnection(trackerInfo.id);
                    },
                  ),
                  detailTitle: appLocalizations.details(
                    appLocalizations.connection,
                  ),
                ),
              )
              .separated(const Divider(height: 0))
              .toList();
          return SuperListView.builder(
            controller: _scrollController,
            itemBuilder: (context, index) {
              return items[index];
            },
            itemCount: connections.length,
          );
        },
      ),
    );
  }
}
