import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CloseConnectionsItem extends ConsumerWidget {
  const CloseConnectionsItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final closeConnections = ref.watch(
      appSettingProvider.select((state) => state.closeConnections),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.autoCloseConnections),
      subtitle: Text(appLocalizations.autoCloseConnectionsDesc),
      delegate: SwitchDelegate(
        value: closeConnections,
        onChanged: (value) async {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(closeConnections: value));
        },
      ),
    );
  }
}

class MinimizeItem extends ConsumerWidget {
  const MinimizeItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minimizeOnExit = ref.watch(
      appSettingProvider.select((state) => state.minimizeOnExit),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.minimizeOnExit),
      subtitle: Text(appLocalizations.minimizeOnExitDesc),
      delegate: SwitchDelegate(
        value: minimizeOnExit,
        onChanged: (bool value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(minimizeOnExit: value));
        },
      ),
    );
  }
}

class AutoLaunchItem extends ConsumerWidget {
  const AutoLaunchItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoLaunch = ref.watch(
      appSettingProvider.select((state) => state.autoLaunch),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.autoLaunch),
      subtitle: Text(appLocalizations.autoLaunchDesc),
      delegate: SwitchDelegate(
        value: autoLaunch,
        onChanged: (bool value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(autoLaunch: value));
        },
      ),
    );
  }
}

class AutoRunItem extends ConsumerWidget {
  const AutoRunItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoRun = ref.watch(
      appSettingProvider.select((state) => state.autoRun),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.autoRun),
      subtitle: Text(appLocalizations.autoRunDesc),
      delegate: SwitchDelegate(
        value: autoRun,
        onChanged: (bool value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(autoRun: value));
        },
      ),
    );
  }
}

class AnimateTabItem extends ConsumerWidget {
  const AnimateTabItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAnimateToPage = ref.watch(
      appSettingProvider.select((state) => state.isAnimateToPage),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.tabAnimation),
      subtitle: Text(appLocalizations.tabAnimationDesc),
      delegate: SwitchDelegate(
        value: isAnimateToPage,
        onChanged: (value) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(isAnimateToPage: value));
        },
      ),
    );
  }
}

class ClearDataItem extends ConsumerWidget {
  const ClearDataItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListItem(
      leading: const Icon(Icons.delete_forever_outlined),
      title: Text(context.appLocalizations.clearData),
      onTap: () async {
        final res = await globalState.showMessage(
          message: TextSpan(text: context.appLocalizations.confirmClearAllData),
        );
        if (res != true) return;
        await appController.handleClear();
      },
    );
  }
}

class ApplicationSettingView extends StatelessWidget {
  const ApplicationSettingView({super.key});

  String getLocaleString(Locale? locale) {
    if (locale == null) return appLocalizations.defaultText;
    return Intl.message(locale.toString());
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      ...generateSection(
        title: Intl.message('Launch & background', name: 'launchAndBackground'),
        items: const [AutoLaunchItem(), AutoRunItem(), MinimizeItem()],
      ),
      ...generateSection(
        title: Intl.message('Connection', name: 'connection'),
        items: const [CloseConnectionsItem()],
      ),
      ...generateSection(
        title: Intl.message('User interface', name: 'userInterface'),
        items: const [AnimateTabItem()],
      ),
      ...generateSection(
        title: Intl.message('Reset', name: 'resetSection'),
        items: const [ClearDataItem()],
      ),
    ];
    return BaseScaffold(
      title: Intl.message('General settings', name: 'generalSettings'),
      body: ListView.builder(
        itemBuilder: (_, index) => items[index],
        itemCount: items.length,
      ),
    );
  }
}
