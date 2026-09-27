import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:fl_clash/services/routing_model.dart';

// Upstream chen08209/FlClash presets, adapted: REJECT for REJECT-DROP, no
// desktop PROCESS-NAME-REGEX, LAN as this fork's GEOIP,private idiom.
enum RulePreset {
  blockQuicStunDot,
  lanDirect,
  systemServicesDirect,
  bittorrentDirect,
}

extension RulePresetRules on RulePreset {
  List<ScenarioRule> get rules => switch (this) {
    RulePreset.blockQuicStunDot => const [
      LogicRule(
        op: RuleAction.AND,
        clauses: [
          LogicalClause(action: RuleAction.NETWORK, params: 'UDP'),
          LogicalClause(action: RuleAction.DST_PORT, params: '443'),
        ],
        dest: toBlock,
      ),
      LogicRule(
        op: RuleAction.AND,
        clauses: [
          LogicalClause(action: RuleAction.NETWORK, params: 'UDP'),
          LogicalClause(action: RuleAction.DST_PORT, params: '3478/19302'),
        ],
        dest: toBlock,
      ),
      MatchRule(action: RuleAction.DST_PORT, value: '853', dest: toBlock),
    ],
    RulePreset.lanDirect => const [
      CountryRule(countryCode: 'private', dest: toBypass, noResolve: true),
    ],
    RulePreset.systemServicesDirect => const [
      MatchRule(action: RuleAction.GEOSITE, value: 'apple', dest: toBypass),
      MatchRule(action: RuleAction.GEOSITE, value: 'microsoft', dest: toBypass),
    ],
    RulePreset.bittorrentDirect => const [
      MatchRule(
        action: RuleAction.GEOSITE,
        value: 'category-public-tracker',
        dest: toBypass,
      ),
      MatchRule(
        action: RuleAction.GEOSITE,
        value: 'category-pt',
        dest: toBypass,
      ),
    ],
  };

  String label(AppLocalizations appLocalizations) => switch (this) {
    RulePreset.blockQuicStunDot =>
      appLocalizations.routingPresetBlockQuicStunDot,
    RulePreset.lanDirect => appLocalizations.routingPresetLanDirect,
    RulePreset.systemServicesDirect =>
      appLocalizations.routingPresetSystemServicesDirect,
    RulePreset.bittorrentDirect =>
      appLocalizations.routingPresetBittorrentDirect,
  };
}

// Appends only the rules of [preset] that [existing] does not already contain,
// so re-adding a preset (once its equality-aware rules are already in place)
// never duplicates entries.
List<ScenarioRule> addRulePreset(
  List<ScenarioRule> existing,
  RulePreset preset,
) {
  final result = List<ScenarioRule>.of(existing);
  for (final rule in preset.rules) {
    if (!result.contains(rule)) result.add(rule);
  }
  return result;
}
