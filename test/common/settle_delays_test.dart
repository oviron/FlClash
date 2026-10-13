import 'package:fl_clash/common/compute.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const url = 'https://cp.cloudflare.com';

  test('the core answers every spinner it measured', () {
    final settled = settleDelays(
      pending: const [Delay(name: 'qde', url: url, value: 0)],
      results: const [Delay(name: 'qde', url: url, value: 140)],
    );

    expect(settled, const [Delay(name: 'qde', url: url, value: 140)]);
  });

  test('a spinner the core left unanswered falls to a timeout', () {
    final settled = settleDelays(
      pending: const [
        Delay(name: 'qde', url: url, value: 0),
        Delay(name: 'Blanc', url: url, value: 0),
      ],
      results: const [Delay(name: 'qde', url: url, value: 140)],
    );

    expect(settled, contains(const Delay(name: 'Blanc', url: url, value: -1)));
    expect(settled, hasLength(2));
  });

  test('the same node under another url is a different spinner', () {
    final settled = settleDelays(
      pending: const [Delay(name: 'qde', url: 'https://other', value: 0)],
      results: const [Delay(name: 'qde', url: url, value: 140)],
    );

    expect(
      settled,
      contains(const Delay(name: 'qde', url: 'https://other', value: -1)),
    );
  });

  test('a failed core call times every spinner out', () {
    final settled = settleDelays(
      pending: const [Delay(name: 'qde', url: url, value: 0)],
      results: const [],
    );

    expect(settled, const [Delay(name: 'qde', url: url, value: -1)]);
  });
}
