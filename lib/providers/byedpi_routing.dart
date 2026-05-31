import 'package:fl_clash/byedpi/host_list.dart';
import 'package:fl_clash/byedpi/routing_input.dart';
import 'package:fl_clash/byedpi/test_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/byedpi_routing.g.dart';

@riverpod
Future<List<String>> byeDpiRoutingHostList(Ref ref) async {
  final hostListText = await readHostList();
  final exclude = await readExclude();
  return parseByeDpiRoutingHosts(
    hostListText: hostListText,
    excludedHosts: exclude,
  );
}
