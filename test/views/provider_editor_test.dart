import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/profile_routing/provider_spec.dart';
import 'package:fl_clash/profile_routing/yaml_rules_io.dart';
import 'package:fl_clash/views/profiles/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderSpec _build({
  required bool isRule,
  required String type,
  String url = '',
  String path = '',
  String interval = '',
  String? behavior,
  String? format,
  bool healthEnabled = false,
  String healthUrl = '',
  String healthInterval = '',
  ProviderSpec? base,
}) => buildProviderSpec(
  base: base ?? ProviderSpec.create(type: type),
  isRule: isRule,
  type: type,
  url: url,
  path: path,
  interval: interval,
  behavior: behavior,
  format: format,
  healthEnabled: healthEnabled,
  healthUrl: healthUrl,
  healthInterval: healthInterval,
);

void main() {
  group('buildProviderSpec field mapping', () {
    test('http proxy-provider keeps url, drops path, sets health-check', () {
      final spec = _build(
        isRule: false,
        type: 'http',
        url: 'https://sub/x.yaml',
        path: 'should-be-dropped',
        interval: '3600',
        healthEnabled: true,
        healthUrl: 'http://g/generate_204',
        healthInterval: '60',
      );
      expect(spec.type, 'http');
      expect(spec.url, 'https://sub/x.yaml');
      expect(spec.path, isNull);
      expect(spec.interval, 3600);
      expect(spec.healthCheck, {
        'enable': true,
        'url': 'http://g/generate_204',
        'interval': 60,
      });
    });

    test('file source keeps path, drops url and interval', () {
      final spec = _build(
        isRule: false,
        type: 'file',
        url: 'https://sub/x.yaml',
        path: './local.yaml',
        interval: '999',
      );
      expect(spec.url, isNull);
      expect(spec.path, './local.yaml');
      expect(spec.interval, isNull);
    });

    test('rule-provider carries behavior/format and no health-check', () {
      final spec = _build(
        isRule: true,
        type: 'http',
        url: 'https://sub/ru.mrs',
        interval: '86400',
        behavior: 'domain',
        format: 'mrs',
        healthEnabled: true,
      );
      expect(spec.behavior, 'domain');
      expect(spec.format, 'mrs');
      expect(spec.healthCheck, isNull);
    });

    test('preserves unknown keys and unmanaged health-check keys', () {
      const base = ProviderSpec({
        'type': 'http',
        'url': 'https://old',
        'size-limit': 1024,
        'health-check': {'lazy': true, 'enable': false},
      });
      final spec = _build(
        isRule: false,
        type: 'http',
        url: 'https://new',
        healthEnabled: true,
        base: base,
      );
      expect(spec.raw['size-limit'], 1024);
      expect(spec.healthCheck!['lazy'], true);
      expect(spec.healthCheck!['enable'], true);
    });

    test('the produced spec round-trips into a valid config block', () {
      final spec = _build(
        isRule: false,
        type: 'http',
        url: 'https://sub/x.yaml',
        interval: '3600',
      );
      const raw = 'mixed-port: 7890\nrules: []\n';
      final out = const ProfileRulesDocument(
        raw,
      ).withProxyProviders({'govpn': spec});
      final reparsed = ProfileRulesDocument(out).proxyProviders;
      expect(reparsed.keys, ['govpn']);
      expect(reparsed['govpn']!.url, 'https://sub/x.yaml');
      expect(out.contains('mixed-port: 7890'), isTrue);
    });
  });

  testWidgets('source segment toggles url vs path field', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        locale: const Locale('en'),
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => ProviderEditor(
              type: SheetType.page,
              kind: ProviderKind.rule,
              initialName: 'ads',
              initial: ProviderSpec.create(type: 'http'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final en = AppLocalizations();
    expect(find.text(en.providerSubscriptionUrl), findsOneWidget);
    expect(find.text(en.providerPath), findsNothing);
    expect(find.text(en.providerBehavior.toUpperCase()), findsOneWidget);

    await tester.tap(find.text(en.providerSourceFile));
    await tester.pumpAndSettle();

    expect(find.text(en.providerSubscriptionUrl), findsNothing);
    expect(find.text(en.providerPath), findsOneWidget);
  });
}
