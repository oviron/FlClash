import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/material.dart';

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.locationPermissionTitle),
      content: Text(l10n.locationPermissionExplanation),
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
    );
  }

  /// Returns `true` if the user agreed to proceed with the system permission
  /// request, `false` if they dismissed or chose "Not now". Callers must not
  /// trust `null` from `showDialog` (back-button) and must default to `false`.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const LocationPermissionDialog(),
    );
    return result ?? false;
  }
}
