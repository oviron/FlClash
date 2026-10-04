import 'package:fl_clash/common/compute.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _url = 'https://test.example/generate_204';

List<String> _sortedNames(List<String> names, Map<String, int?> delays) {
  final group = Group(
    type: GroupType.Selector,
    name: 'G',
    all: [for (final name in names) Proxy(name: name, type: 'Vless')],
  );
  final sorted = computeSort(
    groups: [group],
    sortType: ProxiesSortType.delay,
    delayMap: {_url: delays},
    selectedMap: const {},
    defaultTestUrl: _url,
  );
  return sorted.single.all.map((proxy) => proxy.name).toList();
}

void main() {
  test('tested first by delay, then pending, then failed', () {
    expect(
      _sortedNames(
        ['a', 'b', 'c', 'd', 'e'],
        {'a': -1, 'b': 0, 'c': 120, 'd': 40},
      ),
      ['d', 'c', 'b', 'e', 'a'],
    );
  });

  // A running delay test re-sorts many times; untested and failed nodes must
  // keep their order between passes instead of reshuffling on every result.
  test('keeps input order among equal delays in a large group', () {
    final names = [for (var i = 0; i < 80; i++) 'n$i'];
    final delays = <String, int?>{'n50': 30, 'n10': 90, 'n70': -1, 'n5': -1};
    final pending = [
      for (final name in names)
        if (!delays.containsKey(name)) name,
    ];
    expect(_sortedNames(names, delays), [
      'n50',
      'n10',
      ...pending,
      'n5',
      'n70',
    ]);
  });
}
