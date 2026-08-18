import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: appLocalizations.privacyAndSecurity,
      body: ListView(
        children: const [
          _HideFromRecentsItem(),
          Divider(height: 0),
          _DisclaimerActionItem(),
          Divider(height: 0),
          _DeveloperModeItem(),
          Divider(height: 0),
          _CrashReportingPlaceholder(),
        ],
      ),
    );
  }
}

class _HideFromRecentsItem extends ConsumerWidget {
  const _HideFromRecentsItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(
      appSettingProvider.select((state) => state.hidden),
    );
    return ListItem.switchItem(
      leading: const Icon(Icons.visibility_off_outlined),
      title: Text(appLocalizations.hideFromRecents),
      subtitle: Text(appLocalizations.hideFromRecentsDesc),
      delegate: SwitchDelegate(
        value: hidden,
        onChanged: (value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(hidden: value));
        },
      ),
    );
  }
}

class _DisclaimerActionItem extends StatelessWidget {
  const _DisclaimerActionItem();

  @override
  Widget build(BuildContext context) {
    return ListItem(
      leading: const Icon(Icons.gavel_outlined),
      title: Text(appLocalizations.legalAndDisclaimer),
      onTap: () async {
        await globalState.showMessage(
          title: context.appLocalizations.disclaimer,
          message: TextSpan(text: context.appLocalizations.disclaimerDesc),
          cancelable: false,
        );
      },
    );
  }
}

class _DeveloperModeItem extends ConsumerWidget {
  const _DeveloperModeItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      appSettingProvider.select((state) => state.developerMode),
    );
    return ListItem.switchItem(
      leading: const Icon(Icons.developer_mode_outlined),
      title: Text(context.appLocalizations.developerMode),
      subtitle: Text(appLocalizations.developerModeDesc),
      delegate: SwitchDelegate(
        value: enabled,
        onChanged: (value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(developerMode: value));
        },
      ),
    );
  }
}

class _CrashReportingPlaceholder extends StatelessWidget {
  const _CrashReportingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ListItem.switchItem(
      leading: const Icon(Icons.bug_report_outlined),
      title: Text(appLocalizations.crashReporting),
      subtitle: Text(appLocalizations.comingSoon),
      delegate: const SwitchDelegate(value: false, onChanged: null),
    );
  }
}
