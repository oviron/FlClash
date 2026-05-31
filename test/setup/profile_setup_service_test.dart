import 'package:fl_clash/byedpi/model.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/services/profile_setup_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SetupState setupState({
    OverwriteType overwriteType = OverwriteType.standard,
    List<Rule> addedRules = const [],
    Script? script,
  }) {
    return SetupState(
      profileId: 7,
      profileLastUpdateDate: 1,
      overwriteType: overwriteType,
      addedRules: addedRules,
      script: script,
      overrideDns: false,
      dns: defaultDns,
      byeDpiSettings: const ByeDpiSettings(enabled: true),
      byeDpiHostList: const ['yt.test'],
    );
  }

  test(
    'builds standard profile inputs without WidgetRef or native core',
    () async {
      late MakeRealProfileState captured;
      final service = ProfileSetupService(
        loadRawProfile: (profileId) async => {
          'profileId': profileId,
          'rules': ['MATCH,DIRECT'],
        },
        evaluateScript: (_, rawConfig) async => rawConfig,
        loadScriptContent: (_) async => null,
        buildRealProfile: (state) async {
          captured = state;
          return {'built': true, 'profileId': state.profileId};
        },
      );

      final result = await service.buildConfig(
        ProfileSetupRequest(
          setupState: setupState(
            addedRules: const [Rule(id: 1, value: 'DOMAIN,test,DIRECT')],
          ),
          patchConfig: defaultClashConfig,
          routeMode: RouteMode.bypassPrivate,
          overrideDns: true,
          appendSystemDns: true,
          profilesPath: '/profiles',
          defaultUserAgent: 'FlClash-test',
        ),
      );

      expect(result, {'built': true, 'profileId': 7});
      expect(captured.profileId, 7);
      expect(captured.rawConfig['profileId'], 7);
      expect(captured.addedRules.single.value, 'DOMAIN,test,DIRECT');
      expect(captured.overrideDns, isTrue);
      expect(captured.appendSystemDns, isTrue);
      expect(captured.defaultUA, 'FlClash-test');
      expect(captured.byeDpiSettings.enabled, isTrue);
      expect(captured.byeDpiHostList, ['yt.test']);
      expect(captured.realPatchConfig.tun.routeAddress, isNotEmpty);
    },
  );

  test('evaluates script overwrite and does not pass standard rules', () async {
    late MakeRealProfileState captured;
    final service = ProfileSetupService(
      loadRawProfile: (_) async => {'mode': 'rule'},
      evaluateScript: (scriptContent, rawConfig) async => {
        ...rawConfig,
        'script': scriptContent,
      },
      loadScriptContent: (_) async => 'config.mode = "global";',
      buildRealProfile: (state) async {
        captured = state;
        return state.rawConfig;
      },
    );

    final result = await service.buildConfig(
      ProfileSetupRequest(
        setupState: setupState(
          overwriteType: OverwriteType.script,
          addedRules: const [Rule(id: 1, value: 'DOMAIN,test,DIRECT')],
          script: Script(
            id: 10,
            label: 'script',
            lastUpdateTime: DateTime.fromMillisecondsSinceEpoch(0),
          ),
        ),
        patchConfig: defaultClashConfig,
        routeMode: RouteMode.config,
        overrideDns: false,
        appendSystemDns: false,
        profilesPath: '/profiles',
        defaultUserAgent: 'ua',
      ),
    );

    expect(result['script'], 'config.mode = "global";');
    expect(captured.addedRules, isEmpty);
    expect(captured.realPatchConfig.tun.routeAddress, isEmpty);
  });

  test('returns empty config for null profile id', () async {
    final service = ProfileSetupService(
      loadRawProfile: (_) async => fail('raw profile must not be loaded'),
      evaluateScript: (_, rawConfig) async => rawConfig,
      loadScriptContent: (_) async => null,
      buildRealProfile: (_) async => fail('profile must not be built'),
    );

    final result = await service.buildConfig(
      ProfileSetupRequest(
        setupState: setupState().copyWith(profileId: null),
        patchConfig: defaultClashConfig,
        routeMode: RouteMode.config,
        overrideDns: false,
        appendSystemDns: false,
        profilesPath: '/profiles',
        defaultUserAgent: 'ua',
      ),
    );

    expect(result, isEmpty);
  });
}
