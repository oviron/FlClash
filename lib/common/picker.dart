import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/ingest/normalize.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Picker {
  Future<PlatformFile?> pickerFile({bool withData = true}) async {
    final filePickerResult = await FilePicker.pickFiles(
      withData: withData,
      allowMultiple: false,
      initialDirectory: await appPath.downloadDirPath,
    );
    return filePickerResult?.files.first;
  }

  Future<String?> saveFile(String fileName, Uint8List bytes) async {
    final path = await FilePicker.saveFile(
      fileName: fileName,
      initialDirectory: await appPath.downloadDirPath,
      bytes: bytes,
    );
    if (!system.isAndroid && path != null) {
      final file = File(path);
      await file.safeWriteAsBytes(bytes);
    }
    return path;
  }

  Future<String?> saveFileWithPath(String fileName, String localPath) async {
    final localFile = File(localPath);
    if (!await localFile.exists()) {
      await localFile.create(recursive: true);
    }
    final bytes = Platform.isAndroid ? await localFile.readAsBytes() : null;
    final path = await FilePicker.saveFile(
      fileName: fileName,
      initialDirectory: await appPath.downloadDirPath,
      bytes: bytes,
    );
    if (path != null && bytes == null) {
      await localFile.copy(path);
    }
    await localFile.safeDelete();
    return path;
  }

  Future<String?> pickerConfigQRCode() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xFile == null) {
      return null;
    }
    final controller = MobileScannerController();
    final BarcodeCapture? capture;
    try {
      capture = await controller.analyzeImage(
        xFile.path,
        formats: [BarcodeFormat.qrCode],
      );
    } finally {
      unawaited(controller.dispose());
    }
    // ML Kit reports "nothing decoded" as an empty list, so the two failures
    // are distinct and get distinct messages: unreadable image vs. a payload
    // this app cannot import.
    final values = capture?.barcodes.map((b) => b.rawValue).toList();
    if (values == null || values.isEmpty) {
      throw appLocalizations.qrNotRecognized;
    }
    final payload = firstIngestable(values);
    if (payload == null) {
      throw appLocalizations.qrNotImportable;
    }
    return payload;
  }
}

final picker = Picker();
