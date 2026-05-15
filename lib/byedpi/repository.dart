import 'package:fl_clash/byedpi/model.dart';
import 'package:fl_clash/byedpi/presets.dart';
import 'package:fl_clash/database/database.dart';

Future<List<BypassProfile>> currentBypassProfiles(Database db) async {
  final dao = db.bypassProfilesDao;
  final rows = await dao.watchAll().first;
  if (rows.isEmpty) {
    for (final preset in builtinBypassProfiles) {
      await dao.upsert(preset);
    }
    return dao.watchAll().first;
  }
  return rows;
}
