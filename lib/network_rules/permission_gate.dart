// Network Rules v1: orchestration layer between UI and the location
// permission provider.
//
// Whenever a user action depends on reading the Wi-Fi SSID (creating a
// "by name" rule, viewing the live snapshot in the editor, etc.) the UI
// calls [ensureLocationPermissionForSsid] and switches on the boolean
// result. The function itself owns:
//
//   * checking the cached state in [locationPermissionProvider]
//   * showing the explanation dialog before the system prompt
//   * triggering the system request via the notifier
//   * the special-case fallback for `permanentlyDenied` (system Settings)
//
// Keeping all of this here rather than inside widgets means the same flow
// can be triggered from anywhere — settings tile tap, FAB tap, even from
// a deep-link in the future — without copy-pasting the branching logic.

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
