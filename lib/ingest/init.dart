import 'package:fl_clash/common/request.dart';
import 'package:fl_clash/ingest/happ/happ_module.dart';
import 'package:fl_clash/ingest/registry.dart';

// The raw honest GET both strategies build on. Flattens dio's multi-value
// headers to lowercased single values for the pipeline's meta lookup.
Future<FetchResult> requestRawFetch(
  String url, {
  Map<String, String>? headers,
}) async {
  final resp = await request.getTextResponseForUrl(url, headers: headers);
  final flat = <String, String>{};
  resp.headers.forEach((k, v) {
    if (v.isNotEmpty) flat[k.toLowerCase()] = v.first;
  });
  return (body: resp.data ?? '', headers: flat);
}

// Call once at startup. The registerHappModule line is the module's only on/off
// switch: drop it and every non-Happ format still ingests through the core.
void initIngest() {
  registerFetchStrategy(const CoreFetchStrategy(requestRawFetch));
  registerHappModule(requestRawFetch);
}
