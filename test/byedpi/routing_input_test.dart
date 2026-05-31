import 'package:fl_clash/byedpi/routing_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses routing hosts and removes excluded entries', () {
    final hosts = parseByeDpiRoutingHosts(
      hostListText: '''
youtube.com

# comment
googlevideo.com
ytimg.com
''',
      excludedHosts: {'googlevideo.com'},
    );

    expect(hosts, ['youtube.com', 'ytimg.com']);
  });
}
