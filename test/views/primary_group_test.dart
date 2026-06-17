import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/views/proxies/node_selector_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

Group _g(String name, GroupType type, {bool? hidden}) =>
    Group(name: name, type: type, hidden: hidden);

void main() {
  test('prefers the first visible selector over a non-selectable group', () {
    final g = primaryGroup([
      _g('relay', GroupType.Relay),
      _g('vpn', GroupType.Selector),
    ]);
    expect(g?.name, 'vpn');
  });

  test('url-test and fallback count as selectable', () {
    expect(primaryGroup([_g('auto', GroupType.URLTest)])?.name, 'auto');
    expect(primaryGroup([_g('fb', GroupType.Fallback)])?.name, 'fb');
  });

  test('falls back to the first visible group when none is selectable', () {
    final g = primaryGroup([
      _g('relay', GroupType.Relay),
      _g('lb', GroupType.LoadBalance),
    ]);
    expect(g?.name, 'relay');
  });

  test('skips hidden groups', () {
    final g = primaryGroup([
      _g('hidden', GroupType.Selector, hidden: true),
      _g('relay', GroupType.Relay),
    ]);
    expect(g?.name, 'relay');
  });

  test('null when empty or every group is hidden', () {
    expect(primaryGroup([]), isNull);
    expect(primaryGroup([_g('h', GroupType.Selector, hidden: true)]), isNull);
  });
}
