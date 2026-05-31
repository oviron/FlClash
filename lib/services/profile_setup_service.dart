import 'package:fl_clash/common/task.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

typedef RawProfileLoader = Future<Map<String, dynamic>> Function(int profileId);
typedef ScriptEvaluator =
    Future<Map<String, dynamic>> Function(
      String scriptContent,
      Map<String, dynamic> rawConfig,
    );
typedef ScriptContentLoader = Future<String?> Function(Script script);
typedef RealProfileBuilder =
    Future<Map<String, dynamic>> Function(MakeRealProfileState state);

class ProfileSetupRequest {
  final SetupState setupState;
  final ClashConfig patchConfig;
  final RouteMode routeMode;
  final bool overrideDns;
  final bool appendSystemDns;
  final String profilesPath;
  final String defaultUserAgent;

  const ProfileSetupRequest({
    required this.setupState,
    required this.patchConfig,
    required this.routeMode,
    required this.overrideDns,
    required this.appendSystemDns,
    required this.profilesPath,
    required this.defaultUserAgent,
  });
}

class ProfileSetupService {
  final RawProfileLoader loadRawProfile;
  final ScriptEvaluator evaluateScript;
  final ScriptContentLoader loadScriptContent;
  final RealProfileBuilder buildRealProfile;

  const ProfileSetupService({
    required this.loadRawProfile,
    required this.evaluateScript,
    required this.loadScriptContent,
    this.buildRealProfile = makeRealProfileTask,
  });

  Future<Map<String, dynamic>> buildConfig(ProfileSetupRequest request) async {
    final setupState = request.setupState;
    final profileId = setupState.profileId;
    if (profileId == null) {
      return {};
    }

    final addedRules = <Rule>[];
    String? scriptContent;
    if (setupState.overwriteType == OverwriteType.script) {
      final script = setupState.script;
      if (script != null) {
        scriptContent = await loadScriptContent(script);
      }
    } else {
      addedRules.addAll(setupState.addedRules);
    }

    final realPatchConfig = request.patchConfig.copyWith(
      tun: request.patchConfig.tun.getRealTun(request.routeMode),
    );
    var rawConfig = await loadRawProfile(profileId);
    if (scriptContent?.isNotEmpty == true) {
      rawConfig = await evaluateScript(scriptContent!, rawConfig);
    }

    return buildRealProfile(
      MakeRealProfileState(
        profilesPath: request.profilesPath,
        profileId: profileId,
        rawConfig: rawConfig,
        realPatchConfig: realPatchConfig,
        overrideDns: request.overrideDns,
        appendSystemDns: request.appendSystemDns,
        addedRules: addedRules,
        defaultUA: request.defaultUserAgent,
        byeDpiSettings: setupState.byeDpiSettings,
        byeDpiHostList: setupState.byeDpiHostList,
      ),
    );
  }
}
