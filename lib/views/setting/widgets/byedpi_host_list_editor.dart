import 'package:fl_clash/byedpi/host_list.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ByeDpiHostListEditor extends StatefulWidget {
  const ByeDpiHostListEditor({super.key});

  @override
  State<ByeDpiHostListEditor> createState() => _ByeDpiHostListEditorState();
}

class _ByeDpiHostListEditorState extends State<ByeDpiHostListEditor> {
  late TextEditingController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    readHostList().then((text) {
      if (!mounted) return;
      setState(() {
        _controller.text = text;
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await writeHostList(_controller.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(appLocalizations.byedpiHostListSaved)),
    );
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(appLocalizations.byedpiHostListResetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(appLocalizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(appLocalizations.byedpiHostListReset),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await resetHostListToDefault();
    final text = await readHostList();
    if (!mounted) return;
    setState(() => _controller.text = text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(appLocalizations.byedpiHostListSaved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: appLocalizations.byedpiHostList,
      actions: [
        IconButton(
          icon: const Icon(Icons.save_outlined),
          onPressed: _loading ? null : _save,
          tooltip: appLocalizations.save,
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 13,
                      ),
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.restore),
                      label: Text(appLocalizations.byedpiHostListReset),
                      onPressed: _resetToDefaults,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
