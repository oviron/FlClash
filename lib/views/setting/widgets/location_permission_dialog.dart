import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CommonDialog(
      title: l10n.locationPermissionTitle,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.permissionNotNow),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.permissionAllow),
        ),
      ],
      child: Text(l10n.locationPermissionExplanation),
    );
  }

  // Returns true if user agreed to proceed, false otherwise.
  static Future<bool> show(BuildContext context) async {
    final result = await globalState.showCommonDialog<bool>(
      child: const LocationPermissionDialog(),
    );
    return result ?? false;
  }
}
