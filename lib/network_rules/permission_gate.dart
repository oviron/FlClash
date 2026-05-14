import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/location_permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../views/setting/widgets/location_permission_dialog.dart';

Future<bool> ensureLocationPermissionForSsid(
  BuildContext context,
  WidgetRef ref,
) async {
  final notifier = ref.read(locationPermissionProvider.notifier);
  // Refresh first so a permission change made in system Settings while the
  // app was backgrounded is picked up before we decide what to do.
  await notifier.refresh();
  final current = ref.read(locationPermissionProvider);

  switch (current) {
    case LocationPermissionState.granted:
      return true;

    case LocationPermissionState.notDetermined:
    case LocationPermissionState.denied:
      if (!context.mounted) return false;
      final agreed = await LocationPermissionDialog.show(context);
      if (!agreed) return false;
      final result = await notifier.request();
      return result == LocationPermissionState.granted;

    case LocationPermissionState.permanentlyDenied:
      if (!context.mounted) return false;
      await _showOpenSettingsDialog(context);
      return false;
  }
}

Future<void> _showOpenSettingsDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.permissionRequiredHint),
      content: Text(l10n.locationPermissionExplanation),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.permissionNotNow),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(dialogContext).pop();
            await openAppSettings();
          },
          child: Text(l10n.openSettings),
        ),
      ],
    ),
  );
}
