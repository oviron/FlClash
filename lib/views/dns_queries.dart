import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class DnsQueriesView extends StatefulWidget {
  const DnsQueriesView({super.key});

  @override
  State<DnsQueriesView> createState() => _DnsQueriesViewState();
}

class _DnsQueriesViewState extends State<DnsQueriesView>
    with WidgetsBindingObserver, ActivePollingMixin<DnsQueriesView> {
  final ScrollController _scrollController = ScrollController();
  List<DnsQuery> _queries = const [];
  String _query = '';

  @override
  Duration get pollInterval => const Duration(seconds: 1);

  @override
  Future<void> poll() async {
    final queries = await coreController.getDnsQueries();
    if (!mounted) return;
    setState(() => _queries = queries);
  }

  Future<void> _clear() async {
    await coreController.clearDnsQueries();
    await poll();
  }

  List<DnsQuery> get _filtered {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _queries;
    return _queries
        .where(
          (q) =>
              q.domain.toLowerCase().contains(query) ||
              q.answers.any((a) => a.toLowerCase().contains(query)),
        )
        .toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queries = _filtered;
    return CommonScaffold(
      title: appLocalizations.dnsQueries,
      searchState: AppBarSearchState(
        onSearch: (value) => setState(() => _query = value),
      ),
      actions: [
        IconButton(
          onPressed: _clear,
          icon: const Icon(Icons.delete_sweep_outlined),
        ),
      ],
      body: queries.isEmpty
          ? NullStatus(
              label: appLocalizations.nullTip(appLocalizations.dnsQueries),
            )
          : SuperListView.separated(
              controller: _scrollController,
              itemCount: queries.length,
              separatorBuilder: (_, _) => const Divider(height: 0),
              itemBuilder: (_, index) => DnsQueryItem(query: queries[index]),
            ),
    );
  }
}

class DnsQueryItem extends StatelessWidget {
  final DnsQuery query;

  const DnsQueryItem({super.key, required this.query});

  String get _result {
    if (query.error.isNotEmpty) return query.error;
    if (query.answers.isNotEmpty) return query.answers.join(', ');
    return query.rcode;
  }

  @override
  Widget build(BuildContext context) {
    final failed =
        query.error.isNotEmpty ||
        (query.rcode.isNotEmpty && query.rcode != 'NOERROR');
    final secondary = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onSurface.opacity80,
    );
    return ListItem(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: SelectableText(query.domain, style: context.textTheme.bodyLarge),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          SelectableText(
            _result,
            style: context.textTheme.bodyMedium?.copyWith(
              color: failed ? context.colorScheme.error : null,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CommonChip(label: query.type),
              const SizedBox(width: 8),
              Text('${query.delay} ms', style: secondary),
              const Spacer(),
              Text(query.time.toLocal().showTime.trim(), style: secondary),
            ],
          ),
        ],
      ),
    );
  }
}
