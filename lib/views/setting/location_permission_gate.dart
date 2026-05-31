import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/location_permission.dart';
import 'package:fl_clash/views/setting/widgets/location_permission_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

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
      if (context.mounted) await _ensureBackground(context, notifier);
      return true;

    case LocationPermissionState.serviceDisabled:
      if (!context.mounted) return false;
      await _showServiceDisabledDialog(context);
      return false;

    case LocationPermissionState.notDetermined:
    case LocationPermissionState.denied:
      if (!context.mounted) return false;
      final agreed = await LocationPermissionDialog.show(context);
      if (!agreed) return false;
      final result = await notifier.request();
      if (result == LocationPermissionState.serviceDisabled) {
        if (context.mounted) await _showServiceDisabledDialog(context);
        return false;
      }
      if (result != LocationPermissionState.granted) return false;
      if (context.mounted) await _ensureBackground(context, notifier);
      return true;

    case LocationPermissionState.permanentlyDenied:
      if (!context.mounted) return false;
      await _showOpenSettingsDialog(context);
      return false;
  }
}

// Foreground location is enough to read the SSID while the app is in use; the
// background grant only extends that to "UI closed, VPN service alive". So a
// declined background prompt never fails the gate, we ask once and move on.
Future<void> _ensureBackground(
  BuildContext context,
  LocationPermission notifier,
) async {
  if (await notifier.isBackgroundGranted()) return;
  if (!context.mounted) return;
  final agreed = await _showBackgroundRationaleDialog(context);
  if (!agreed) return;
  if (await notifier.requestBackground()) return;
  if (!context.mounted) return;
  // API 30+ does not grant background in-dialog: the user must pick
  // "Allow all the time" in system Settings.
  await openAppSettings();
}

Future<bool> _showBackgroundRationaleDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.permissionRequiredHint),
      content: Text(l10n.backgroundLocationRationale),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.permissionNotNow),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.permissionAllow),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<void> _showServiceDisabledDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.permissionRequiredHint),
      content: Text(l10n.locationServicesDisabled),
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
