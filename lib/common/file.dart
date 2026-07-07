import 'dart:io';

int _atomicWriteSeq = 0;

extension FileExt on File {
  Future<void> safeCopy(String newPath) async {
    if (!await exists()) {
      await create(recursive: true);
      return;
    }
    final targetFile = File(newPath);
    if (!await targetFile.exists()) {
      await targetFile.create(recursive: true);
    }
    await copy(newPath);
  }

  Future<File> safeWriteAsString(String str) async {
    if (!await exists()) {
      await create(recursive: true);
    }
    return await writeAsString(str);
  }

  // Atomic write: a reader never observes a torn/partial file. Writes to a
  // per-call temp then renames over the target; concurrent writers each land a
  // complete payload and the last rename wins.
  Future<File> safeWriteAsStringAtomic(String str) async {
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }
    final tmp = File('$path.${_atomicWriteSeq++}.tmp');
    try {
      await tmp.writeAsString(str, flush: true);
      try {
        await tmp.rename(path);
      } on FileSystemException {
        await tmp.copy(path);
        await tmp.delete();
      }
      return this;
    } catch (_) {
      await tmp.safeDelete();
      rethrow;
    }
  }

  Future<File> safeWriteAsBytes(List<int> bytes) async {
    if (!await exists()) {
      await create(recursive: true);
    }
    return await writeAsBytes(bytes);
  }
}

extension FileSystemEntityExt on FileSystemEntity {
  Future<void> safeDelete({bool recursive = false}) async {
    if (!await exists()) {
      return;
    }
    await delete(recursive: recursive);
  }
}
