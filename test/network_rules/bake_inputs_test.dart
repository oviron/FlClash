import 'dart:async';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/network_rules/model.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/network_rules.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _ruled = Profile(id: 1, label: 'Home', autoUpdateDuration: Duration.zero);
const _other = Profile(id: 2, label: 'Work', autoUpdateDuration: Duration.zero);

const _rule = NetworkRule(
  conditions: [],
  priority: 0,
  action: NetworkAction(vpn: NetworkVpnMode.turnOn, profileId: 1),
);

void main() {
  late StreamController<List<Profile>> profiles;
  late ProviderContainer container;

  setUp(() async {
    profiles = StreamController<List<Profile>>.broadcast();
    container = ProviderContainer(
      overrides: [
        networkRulesStreamProvider.overrideWithValue(const AsyncData([_rule])),
        profilesStreamProvider.overrideWith((_) => profiles.stream),
        scriptsProvider.overrideWithBuild((_, _) => Stream.value(const [])),
        addedRuleStreamProvider(1).overrideWith((_) => Stream.value(const [])),
      ],
    );
    container.listen(networkRulesBakeInputsProvider, (_, _) {});
    await _emit(profiles, const [_ruled, _other]);
  });

  tearDown(() {
    container.dispose();
    profiles.close();
  });

  Future<int> key() => container.read(networkRulesBakeInputsProvider.future);

  test('a settings change the baked config carries changes the key', () async {
    final before = await key();

    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mode: Mode.global));

    expect(await key(), isNot(before));
  });

  test('a re-downloaded ruled profile changes the key', () async {
    final before = await key();

    await _emit(profiles, [
      _ruled.copyWith(lastUpdateDate: DateTime(2026, 9, 27)),
      _other,
    ]);

    expect(await key(), isNot(before));
  });

  test('a proxy picked in the ruled profile changes the key', () async {
    final before = await key();

    await _emit(profiles, [
      _ruled.copyWith(selectedMap: {'Proxy': 'Tokyo'}),
      _other,
    ]);

    expect(await key(), isNot(before));
  });

  test('a change to a profile no rule names keeps the key', () async {
    final before = await key();

    await _emit(profiles, [
      _ruled,
      _other.copyWith(lastUpdateDate: DateTime(2026, 9, 27)),
    ]);

    expect(await key(), before);
  });
}

Future<void> _emit(
  StreamController<List<Profile>> profiles,
  List<Profile> value,
) async {
  profiles.add(value);
  await Future<void>.delayed(Duration.zero);
}
