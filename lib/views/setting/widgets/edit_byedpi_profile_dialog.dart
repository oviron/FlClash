import 'package:fl_clash/byedpi/model.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

class EditByeDpiProfileDialog extends StatefulWidget {
  final BypassProfile? initial;

  const EditByeDpiProfileDialog({super.key, this.initial});

  static Future<BypassProfile?> show({
    required BuildContext context,
    BypassProfile? initial,
  }) {
    return showDialog<BypassProfile>(
      context: context,
      builder: (_) => EditByeDpiProfileDialog(initial: initial),
    );
  }

  @override
  State<EditByeDpiProfileDialog> createState() =>
      _EditByeDpiProfileDialogState();
}

class _EditByeDpiProfileDialogState extends State<EditByeDpiProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _domainsController;
  late final TextEditingController _appsController;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _nameController = TextEditingController(text: p?.name ?? '');
    _domainsController = TextEditingController(
      text: p?.domains.join('\n') ?? '',
    );
    _appsController = TextEditingController(
      text: p?.apps.join('\n') ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _domainsController.dispose();
    _appsController.dispose();
    super.dispose();
  }

  bool get _isValid => _nameController.text.trim().isNotEmpty;

  void _save() {
    if (!_isValid) return;
    final initial = widget.initial;
    final domains = _domainsController.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final apps = _appsController.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final result = BypassProfile(
      id: initial?.id ?? snowflake.id,
      name: _nameController.text.trim(),
      enabled: initial?.enabled ?? true,
      domains: domains,
      apps: apps,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initial == null
            ? appLocalizations.byedpiNewProfile
            : appLocalizations.byedpiEditProfile,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: appLocalizations.byedpiName,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _domainsController,
              decoration: InputDecoration(
                labelText: appLocalizations.byedpiDomains,
              ),
              maxLines: 5,
              minLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _appsController,
              decoration: InputDecoration(
                labelText: appLocalizations.byedpiApps,
              ),
              maxLines: 5,
              minLines: 3,
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        FilledButton(
          onPressed: _isValid ? _save : null,
          child: Text(appLocalizations.save),
        ),
      ],
    );
  }
}
