import 'package:fl_clash/ingest/happ/happ_fetch.dart';
import 'package:fl_clash/ingest/happ/happ_resolver.dart';
import 'package:fl_clash/ingest/registry.dart';

// The entire Happ integration: one resolver (stage 0) plus one fetch strategy
// (stage 1). Remove this call from initIngest to disable Happ; the core then
// ingests every non-Happ format with a single honest fetch and no rewrite.
void registerHappModule(RawFetch rawFetch) {
  registerResolver(HappResolver());
  registerFetchStrategy(HappFetchStrategy(rawFetch: rawFetch));
}
