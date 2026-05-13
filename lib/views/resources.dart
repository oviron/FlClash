import 'dart:io';
import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' hide context;

@immutable
class GeoItem {
  final String label;
  final String key;
  final String fileName;

  const GeoItem({
    required this.label,
    required this.key,
    required this.fileName,
  });

  String get updatingKey => 'geodata_$key';
}

const _geoItems = <GeoItem>[
  GeoItem(label: 'GEOIP', fileName: GEOIP, key: 'geoip'),
  GeoItem(label: 'GEOSITE', fileName: GEOSITE, key: 'geosite'),
  GeoItem(label: 'MMDB', fileName: MMDB, key: 'mmdb'),
  GeoItem(label: 'ASN', fileName: ASN, key: 'asn'),
];

Future<String> _updateGeoItem(GeoItem item) async {
  final message = await coreController.updateGeoData(
    UpdateGeoDataParams(geoName: item.fileName, geoType: item.label),
  );
  return message;
}

class ResourcesView extends ConsumerStatefulWidget {
  const ResourcesView({super.key});

  @override
  ConsumerState<ResourcesView> createState() => _ResourcesViewState();
}

class _ResourcesViewState extends ConsumerState<ResourcesView> {
  Future<void> _updateAllGeoData() async {
    final messages = <UpdatingMessage>[];
    final futures = _geoItems.map<Future<void>>((item) async {
      final updatingNotifier = ref.read(
        isUpdatingProvider(item.updatingKey).notifier,
      );
      if (updatingNotifier.value) return;
      updatingNotifier.value = true;
      try {
        final message = await _updateGeoItem(item);
        if (message.isNotEmpty) {
          messages.add(UpdatingMessage(label: item.label, message: message));
        }
      } catch (e) {
        messages.add(UpdatingMessage(label: item.label, message: e.toString()));
      } finally {
        updatingNotifier.value = false;
      }
    });
    await Future.wait(futures);
    if (messages.isNotEmpty) {
      unawaited(globalState.showAllUpdatingMessagesDialog(messages));
    } else if (mounted) {
      // mihomo's `update_geo.go:121` skips write when content hash matches the
      // existing file on disk, so a successful check often leaves file mtime
      // (and our "X ago" label) untouched. Без явного фидбэка juzер думает
      // что update ничего не сделал — показываем SnackBar чтобы отличать
      // "checked, up to date" от "не нажимал кнопку".
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(appLocalizations.resourcesUpToDate),
        duration: const Duration(seconds: 2),
      ));
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: appLocalizations.resources,
      actions: [
        IconButton(
          onPressed: _updateAllGeoData,
          icon: const Icon(Icons.sync),
        ),
      ],
      body: ListView.separated(
        itemBuilder: (_, index) {
          final geoItem = _geoItems[index];
          return GeoDataListItem(geoItem: geoItem);
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(height: 0);
        },
        itemCount: _geoItems.length,
      ),
    );
  }
}

class GeoDataListItem extends ConsumerStatefulWidget {
  final GeoItem geoItem;

  const GeoDataListItem({super.key, required this.geoItem});

  @override
  ConsumerState<GeoDataListItem> createState() => _GeoDataListItemState();
}

class _GeoDataListItemState extends ConsumerState<GeoDataListItem> {
  GeoItem get geoItem => widget.geoItem;

  Future<void> _updateUrl(String url) async {
    final defaultMap = defaultGeoXUrl.toJson();
    final newUrl = await globalState.showCommonDialog<String>(
      child: UpdateGeoUrlFormDialog(
        title: geoItem.label,
        url: url,
        defaultValue: defaultMap[geoItem.key],
      ),
    );
    if (newUrl != null && newUrl != url && mounted) {
      try {
        if (!newUrl.isUrl) {
          throw 'Invalid url';
        }
        ref.read(patchClashConfigProvider.notifier).update((state) {
          final map = state.geoXUrl.toJson();
          map[geoItem.key] = newUrl;
          return state.copyWith(geoXUrl: GeoXUrl.fromJson(map));
        });
      } catch (e) {
        unawaited(globalState.showMessage(
          title: geoItem.label,
          message: TextSpan(text: e.toString()),
        ));
      }
    }
  }

  Future<FileInfo> _getGeoFileLastModified(String fileName) async {
    final homePath = await appPath.homeDirPath;
    final file = File(join(homePath, fileName));
    final lastModified = await file.lastModified();
    final size = await file.length();
    return FileInfo(size: size, lastModified: lastModified);
  }

  Future<void> _handleUpdateGeoDataItem() async {
    final updatingNotifier = ref.read(
      isUpdatingProvider(geoItem.updatingKey).notifier,
    );
    if (updatingNotifier.value) return;
    updatingNotifier.value = true;
    await appController.safeRun<void>(() async {
      final message = await _updateGeoItem(geoItem);
      if (message.isNotEmpty) throw message;
    }, silence: false);
    updatingNotifier.value = false;
    if (mounted) setState(() {});
  }

  Widget _buildSubtitle() {
    return Consumer(
      builder: (_, ref, _) {
        final url = ref.watch(
          patchClashConfigProvider.select(
            (state) => state.geoXUrl.toJson()[geoItem.key],
          ),
        );
        if (url == null) {
          return const SizedBox();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            FutureBuilder<FileInfo>(
              future: _getGeoFileLastModified(geoItem.fileName),
              builder: (_, snapshot) {
                final height = globalState.measure.bodyMediumHeight;
                return SizedBox(
                  height: height,
                  child: snapshot.data == null
                      ? SizedBox(width: height, height: height)
                      : Text(
                          snapshot.data!.desc,
                          style: context.textTheme.bodyMedium,
                        ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(url, style: context.textTheme.bodyMedium?.toLight),
            const SizedBox(height: 12),
            Wrap(
              runSpacing: 6,
              spacing: 12,
              runAlignment: WrapAlignment.center,
              children: [
                CommonChip(
                  avatar: const Icon(Icons.edit),
                  label: appLocalizations.edit,
                  onPressed: () {
                    _updateUrl(url);
                  },
                ),
                Consumer(
                  builder: (_, ref, _) {
                    final isUpdating = ref.watch(
                      isUpdatingProvider(geoItem.updatingKey),
                    );
                    return isUpdating
                        ? const SizedBox(
                            height: 30,
                            width: 30,
                            child: Padding(
                              padding: EdgeInsets.all(2),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : CommonChip(
                            avatar: const Icon(Icons.sync),
                            label: appLocalizations.sync,
                            onPressed: _handleUpdateGeoDataItem,
                          );
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListItem(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(geoItem.label),
      subtitle: _buildSubtitle(),
    );
  }
}

class UpdateGeoUrlFormDialog extends StatefulWidget {
  final String title;
  final String url;
  final String? defaultValue;

  const UpdateGeoUrlFormDialog({
    super.key,
    required this.title,
    required this.url,
    this.defaultValue,
  });

  @override
  State<UpdateGeoUrlFormDialog> createState() => _UpdateGeoUrlFormDialogState();
}

class _UpdateGeoUrlFormDialogState extends State<UpdateGeoUrlFormDialog> {
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.url);
  }

  Future<void> _handleReset() async {
    if (widget.defaultValue == null) {
      return;
    }
    Navigator.of(context).pop<String>(widget.defaultValue);
  }

  Future<void> _handleUpdate() async {
    final url = _urlController.value.text;
    if (url.isEmpty) return;
    Navigator.of(context).pop<String>(url);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: widget.title,
      actions: [
        if (widget.defaultValue != null &&
            _urlController.value.text != widget.defaultValue) ...[
          TextButton(
            onPressed: _handleReset,
            child: Text(appLocalizations.reset),
          ),
          const SizedBox(width: 4),
        ],
        TextButton(
          onPressed: _handleUpdate,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: Wrap(
        runSpacing: 16,
        children: [
          TextField(
            maxLines: 5,
            minLines: 1,
            controller: _urlController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}
