import 'package:fl_clash/ingest/registry.dart';

// Rewrites Happ's two wrapper forms to a concrete subscription URL. Scope is the
// web launcher only; encrypted happ://crypt* deep links are out of scope.
class HappResolver implements Resolver {
  @override
  String? resolve(String input) {
    final t = input.trim();

    // happ://add/<url> (the url may be percent-encoded).
    if (t.startsWith('happ://add/')) {
      var rest = t.substring('happ://add/'.length);
      try {
        rest = Uri.decodeComponent(rest);
      } catch (_) {
        // Malformed escape: fall back to the raw tail.
      }
      return rest.contains('://') ? rest : null;
    }

    final uri = Uri.tryParse(t);
    if (uri == null) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    // Rewrite only the exact web-launcher path, and only when it carries the
    // subscription token, so a normal /sub/... path is never touched.
    if (uri.path != '/happ') return null;
    if (!uri.queryParameters.containsKey('token') &&
        !uri.queryParameters.containsKey('id')) {
      return null;
    }
    return uri.replace(path: '/api/sub').toString();
  }
}
