import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/about.dart';
import 'package:fl_clash/views/access.dart';
import 'package:fl_clash/views/application_setting.dart';
import 'package:fl_clash/views/backup_and_restore.dart';
import 'package:fl_clash/views/config/config.dart';
import 'package:fl_clash/views/config/dns.dart';
import 'package:fl_clash/views/config/network.dart';
import 'package:fl_clash/views/config/rules.dart';
import 'package:fl_clash/views/config/scripts.dart';
import 'package:fl_clash/views/privacy.dart';
import 'package:fl_clash/views/setting/byedpi.dart';
import 'package:fl_clash/views/setting/logging.dart';
import 'package:fl_clash/views/setting/network_rules.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'developer.dart';
import 'theme.dart';

class ToolsView extends ConsumerStatefulWidget {
  const ToolsView({super.key});

  @override
  ConsumerState<ToolsView> createState() => _ToolViewState();
}

class _ToolViewState extends ConsumerState<ToolsView> {
  Widget _buildNavigationMenuItem(NavigationItem navigationItem) {
    return ListItem.open(
      leading: navigationItem.icon,
      title: Text(Intl.message(navigationItem.label.name)),
      subtitle: navigationItem.description != null
          ? Text(Intl.message(navigationItem.description!))
          : null,
      delegate: OpenDelegate(widget: navigationItem.builder(context)),
    );
  }

  Widget _buildNavigationMenu(List<NavigationItem> navigationItems) {
    return Column(
      children: [
        for (final navigationItem in navigationItems) ...[
          _buildNavigationMenuItem(navigationItem),
          navigationItems.last != navigationItem
              ? const Divider(height: 0)
              : Container(),
        ],
      ],
    );
  }

  List<Widget> _appearanceSection() {
    return generateSection(
      title: Intl.message('Appearance', name: 'appearance'),
      items: const [_ThemeItem(), _LocaleItem()],
    );
  }

  List<Widget> _connectionSection() {
    return generateSection(
      title: context.appLocalizations.connection,
      items: [
        const _VpnSettingsItem(),
        const _AccessItem(),
        const _NetworkRulesItem(),
        if (kByeDpiEnabled) const _ByeDpiItem(),
      ],
    );
  }

  List<Widget> _engineSection() {
    return generateSection(
      title: Intl.message('Engine', name: 'engine'),
      items: const [
        _CoreItem(),
        _DnsItem(),
        _RoutingRulesItem(),
        _ScriptsItem(),
      ],
    );
  }

  List<Widget> _applicationSection() {
    return generateSection(
      title: context.appLocalizations.application,
      items: const [_SettingItem(), _LoggingItem()],
    );
  }

  List<Widget> _privacySection() {
    return generateSection(
      title: Intl.message('Privacy & Security', name: 'privacyAndSecurity'),
      items: const [_PrivacyItem()],
    );
  }

  List<Widget> _backupSection() {
    return generateSection(
      title: context.appLocalizations.backupAndRestore,
      items: const [_BackupItem()],
    );
  }

  List<Widget> _aboutSection(bool enableDeveloperMode) {
    return generateSection(
      title: context.appLocalizations.about,
      items: [
        if (enableDeveloperMode) const _DeveloperItem(),
        const _InfoItem(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm2 = ref.watch(
      appSettingProvider.select(
        (state) => VM2(state.locale, state.developerMode),
      ),
    );
    final items = [
      Consumer(
        builder: (_, ref, _) {
          final state = ref.watch(moreToolsSelectorStateProvider);
          if (state.navigationItems.isEmpty) {
            return Container();
          }
          return Column(
            children: [
              ListHeader(title: context.appLocalizations.more),
              _buildNavigationMenu(state.navigationItems),
            ],
          );
        },
      ),
      ..._appearanceSection(),
      ..._connectionSection(),
      ..._engineSection(),
      ..._applicationSection(),
      ..._privacySection(),
      ..._backupSection(),
      ..._aboutSection(vm2.b),
    ];
    return CommonScaffold(
      title: context.appLocalizations.tools,
      body: ListView.builder(
        key: toolsStoreKey,
        itemCount: items.length,
        itemBuilder: (_, index) => items[index],
        padding: const EdgeInsets.only(bottom: 20),
      ),
    );
  }
}

class _LocaleItem extends ConsumerWidget {
  const _LocaleItem();

  String _getLocaleString(Locale? locale) {
    if (locale == null) return appLocalizations.defaultText;
    return Intl.message(locale.toString());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      appSettingProvider.select((state) => state.locale),
    );
    final subTitle = locale ?? context.appLocalizations.defaultText;
    final currentLocale = utils.getLocaleForString(locale);
    return ListItem<Locale?>.options(
      leading: const Icon(Icons.language_outlined),
      title: Text(context.appLocalizations.language),
      subtitle: Text(Intl.message(subTitle)),
      delegate: OptionsDelegate(
        title: context.appLocalizations.language,
        options: [null, ...AppLocalizations.delegate.supportedLocales],
        onChanged: (Locale? locale) {
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(locale: locale?.toString()));
        },
        textBuilder: (locale) => _getLocaleString(locale),
        value: currentLocale,
      ),
    );
  }
}

class _ThemeItem extends StatelessWidget {
  const _ThemeItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.style),
      title: Text(context.appLocalizations.theme),
      subtitle: Text(context.appLocalizations.themeDesc),
      delegate: const OpenDelegate(widget: ThemeView()),
    );
  }
}

class _BackupItem extends StatelessWidget {
  const _BackupItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.cloud_sync),
      title: Text(context.appLocalizations.backupAndRestore),
      subtitle: Text(context.appLocalizations.backupAndRestoreDesc),
      delegate: const OpenDelegate(widget: BackupAndRestore()),
    );
  }
}

class _AccessItem extends StatelessWidget {
  const _AccessItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.view_list),
      title: Text(context.appLocalizations.accessControl),
      subtitle: Text(context.appLocalizations.accessControlDesc),
      delegate: const OpenDelegate(widget: AccessView()),
    );
  }
}

class _VpnSettingsItem extends StatelessWidget {
  const _VpnSettingsItem();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ListItem.open(
      leading: const Icon(Icons.vpn_key),
      title: Text(appLocalizations.network),
      subtitle: Text(appLocalizations.networkDesc),
      delegate: OpenDelegate(
        blur: false,
        widget: BaseScaffold(
          title: appLocalizations.network,
          body: const NetworkListView(),
        ),
      ),
    );
  }
}

class _CoreItem extends StatelessWidget {
  const _CoreItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.edit),
      title: Text(context.appLocalizations.core),
      subtitle: Text(context.appLocalizations.basicConfigDesc),
      delegate: const OpenDelegate(widget: ConfigView()),
    );
  }
}

class _DnsItem extends ConsumerWidget {
  const _DnsItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return ListItem.open(
      leading: const Icon(Icons.dns),
      title: const Text('DNS'),
      subtitle: Text(appLocalizations.dnsDesc),
      delegate: OpenDelegate(
        blur: false,
        widget: BaseScaffold(
          title: 'DNS',
          actions: [
            Consumer(
              builder: (_, ref, _) {
                return IconButton(
                  onPressed: () async {
                    final res = await globalState.showMessage(
                      title: appLocalizations.reset,
                      message: TextSpan(text: appLocalizations.resetTip),
                    );
                    if (res != true) return;
                    ref
                        .read(patchClashConfigProvider.notifier)
                        .update((state) => state.copyWith(dns: defaultDns));
                  },
                  tooltip: appLocalizations.reset,
                  icon: const Icon(Icons.replay),
                );
              },
            ),
          ],
          body: const DnsListView(),
        ),
      ),
    );
  }
}

class _RoutingRulesItem extends StatelessWidget {
  const _RoutingRulesItem();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ListItem.open(
      leading: const Icon(Icons.library_books),
      title: Text(appLocalizations.addedRules),
      subtitle: Text(appLocalizations.controlGlobalAddedRules),
      delegate: const OpenDelegate(widget: AddedRulesView(), blur: false),
    );
  }
}

class _ScriptsItem extends StatelessWidget {
  const _ScriptsItem();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ListItem.open(
      leading: const Icon(Icons.rocket, fontWeight: FontWeight.w900),
      title: Text(appLocalizations.script),
      subtitle: Text(appLocalizations.overrideScript),
      delegate: const OpenDelegate(widget: ScriptsView(), blur: false),
    );
  }
}

class _LoggingItem extends StatelessWidget {
  const _LoggingItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.article_outlined),
      title: Text(context.appLocalizations.loggingTitle),
      subtitle: Text(context.appLocalizations.loggingDesc),
      delegate: const OpenDelegate(widget: LoggingView()),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.settings),
      title: Text(context.appLocalizations.application),
      subtitle: Text(context.appLocalizations.applicationDesc),
      delegate: const OpenDelegate(widget: ApplicationSettingView()),
    );
  }
}

class _ByeDpiItem extends StatelessWidget {
  const _ByeDpiItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.shield_outlined),
      title: Text(context.appLocalizations.byedpiTitle),
      subtitle: Text(context.appLocalizations.byedpiDesc),
      delegate: const OpenDelegate(widget: ByeDpiView()),
    );
  }
}

class _NetworkRulesItem extends StatelessWidget {
  const _NetworkRulesItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.rule),
      title: Text(context.appLocalizations.networkRulesTitle),
      delegate: const OpenDelegate(widget: NetworkRulesView()),
    );
  }
}

class _PrivacyItem extends StatelessWidget {
  const _PrivacyItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.shield),
      title: Text(Intl.message('Privacy & Security', name: 'privacyAndSecurity')),
      delegate: const OpenDelegate(widget: PrivacyView()),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.info),
      title: Text(context.appLocalizations.about),
      delegate: const OpenDelegate(widget: AboutView()),
    );
  }
}

class _DeveloperItem extends StatelessWidget {
  const _DeveloperItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      leading: const Icon(Icons.developer_board),
      title: Text(context.appLocalizations.developerMode),
      delegate: const OpenDelegate(widget: DeveloperView()),
    );
  }
}
