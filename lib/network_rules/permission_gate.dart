// Centralized location-permission flow for Wi-Fi SSID reads, so the same
// branching (rationale dialog, system request, permanently-denied →
// Settings fallback) does not get copy-pasted into every widget that
// needs it.

import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/location_permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../views/setting/widgets/location_permission_dialog.dart';

/// Drives the location-permission flow needed to read Wi-Fi SSID.
///
/// Returns `true` only when the permission ends up granted. All other
/// outcomes (user dismissed the rationale, system denied, OS-permanently
/// denied) return `false`. Callers should disable name-rule features when
/// they get `false` so the user understands why nothing happened.
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
      // We do not refresh again here: the user has to leave the app to
      // change the setting. Whoever called us will see `false`, and the
      // next interaction will refresh and pick up the new state.
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
