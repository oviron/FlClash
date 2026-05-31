part of '../controller.dart';

extension LogsControllerExt on AppController {
  void addLog(Log log) {
    _ref.read(logsProvider).add(log);
  }

  Future<bool> exportLogs() async {
    final logString = await encodeLogsTask(_ref.read(logsProvider).list);
    final tempFilePath = await appPath.tempFilePath;
    final file = File(tempFilePath);
    await file.safeWriteAsString(logString);
    return await picker.saveFileWithPath(utils.logFile, tempFilePath) != null;
  }
}
