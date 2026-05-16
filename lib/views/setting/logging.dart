import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/views/logs.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoggingView extends ConsumerStatefulWidget {
  const LoggingView({super.key});

  @override
  ConsumerState<LoggingView> createState() => _LoggingViewState();
}

class _LoggingViewState extends ConsumerState<LoggingView> {
  String? _logDirectory;

  @override
  void initState() {
    super.initState();
    _resolveLogDirectory();
  }

  Future<void> _resolveLogDirectory() async {
    final dir = await app?.getLogDirectory();
    if (!mounted) return;
    setState(() => _logDirectory = dir);
  }

  @override
  Widget build(BuildContext context) {
    final logcatLevel = ref.watch(
      appSettingProvider.select((s) => s.logcatLevel),
    );
    final fileLevel = ref.watch(
      appSettingProvider.select((s) => s.fileLogLevel),
    );
    final fileEnabled = ref.watch(
      appSettingProvider.select((s) => s.fileLogEnabled),
    );
    final inAppEnabled = ref.watch(
      appSettingProvider.select((s) => s.inAppLogsEnabled),
    );
    final sourceLevel = ref.watch(
      patchClashConfigProvider.select((c) => c.logLevel),
    );

    return BaseScaffold(
      title: appLocalizations.loggingTitle,
      body: ListView(
        children: [
          _section(appLocalizations.loggingSourceSection),
          _levelTile(
            icon: Icons.input,
            title: appLocalizations.loggingSourceLevel,
            description: appLocalizations.loggingSourceLevelDesc,
            value: sourceLevel,
            onChanged: (v) {
              if (v == null) return;
              ref
                  .read(patchClashConfigProvider.notifier)
                  .update((c) => c.copyWith(logLevel: v));
            },
          ),
          const Divider(height: 0),
          _section(appLocalizations.loggingLogcatSection),
          _levelTile(
            icon: Icons.terminal,
            title: appLocalizations.loggingLogcatLevel,
            description: appLocalizations.loggingLogcatLevelDesc,
            value: logcatLevel,
            onChanged: (v) {
              if (v == null) return;
              ref
                  .read(appSettingProvider.notifier)
                  .update((s) => s.copyWith(logcatLevel: v));
            },
          ),
          const Divider(height: 0),
          _section(appLocalizations.loggingFileSection),
          ListItem.switchItem(
            leading: const Icon(Icons.save_outlined),
            title: Text(appLocalizations.loggingFileEnabled),
            subtitle: Text(appLocalizations.loggingFileEnabledDesc),
            delegate: SwitchDelegate(
              value: fileEnabled,
              onChanged: (v) {
                ref
                    .read(appSettingProvider.notifier)
                    .update((s) => s.copyWith(fileLogEnabled: v));
              },
            ),
          ),
          _levelTile(
            icon: Icons.tune,
            title: appLocalizations.loggingFileLevel,
            description: appLocalizations.loggingFileLevelDesc,
            value: fileLevel,
            onChanged: (v) {
              if (v == null) return;
              ref
                  .read(appSettingProvider.notifier)
                  .update((s) => s.copyWith(fileLogLevel: v));
            },
          ),
          ListItem(
            leading: const Icon(Icons.folder_outlined),
            title: Text(appLocalizations.loggingFilePathLabel),
            subtitle: SelectableText(
              _logDirectory == null
                  ? '…'
                  : '$_logDirectory/debug.log',
              style: context.textTheme.bodySmall,
            ),
          ),
          ListItem(
            leading: const Icon(Icons.refresh),
            title: Text(appLocalizations.loggingFileRotationHint),
          ),
          const Divider(height: 0),
          _section(appLocalizations.loggingInAppSection),
          ListItem.switchItem(
            leading: const Icon(Icons.history),
            title: Text(appLocalizations.inAppLogBuffer),
            subtitle: Text(appLocalizations.inAppLogBufferDesc),
            delegate: SwitchDelegate(
              value: inAppEnabled,
              onChanged: (v) {
                ref
                    .read(appSettingProvider.notifier)
                    .update((s) => s.copyWith(inAppLogsEnabled: v));
              },
            ),
          ),
          ListItem.open(
            leading: const Icon(Icons.list_alt),
            title: Text(appLocalizations.loggingOpenViewer),
            delegate: const OpenDelegate(widget: LogsView()),
          ),
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: SelectableText(
              appLocalizations.loggingHintAdb,
              style: context.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          label,
          style: context.textTheme.titleSmall?.copyWith(
            color: context.colorScheme.primary,
          ),
        ),
      );

  Widget _levelTile({
    required IconData icon,
    required String title,
    required String description,
    required LogLevel value,
    required ValueChanged<LogLevel?> onChanged,
  }) {
    return ListItem<LogLevel>.options(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text('${value.name} — $description'),
      delegate: OptionsDelegate<LogLevel>(
        title: title,
        options: LogLevel.values,
        onChanged: onChanged,
        textBuilder: (l) => l.name,
        value: value,
      ),
    );
  }
}
