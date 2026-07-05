import 'dart:async';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/pages/scan.dart';
import 'package:fl_clash/services/quickstart_config_service.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// First-run on-ramp: if the clipboard already holds a recognizable artifact,
// import it in one tap; otherwise open the format-agnostic paste dialog.
Future<void> pasteKeyOnramp() async {
  final data = await Clipboard.getData(Clipboard.kTextPlain);
  final text = data?.text?.trim();
  if (text != null &&
      text.isNotEmpty &&
      classifyArtifact(text) != ArtifactKind.unknown) {
    unawaited(appController.addProfileFromText(text));
    return;
  }
  final value = await globalState.showCommonDialog<String>(
    child: InputDialog(
      autovalidateMode: AutovalidateMode.onUnfocus,
      title: appLocalizations.quickStartPasteKey,
      labelText: appLocalizations.quickStartPasteHint,
      value: '',
      validator: (v) => (v == null || v.isEmpty)
          ? appLocalizations.emptyTip('').trim()
          : null,
    ),
  );
  if (value != null) {
    unawaited(appController.addProfileFromText(value));
  }
}

class AddProfileView extends StatelessWidget {
  final BuildContext context;

  const AddProfileView({super.key, required this.context});

  Future<void> _handleAddProfileFormFile() async {
    unawaited(appController.addProfileFormFile());
  }

  Future<void> _handleAddProfileFromText(String text) async {
    unawaited(appController.addProfileFromText(text));
  }

  Future<void> _toScan() async {
    final url = await BaseNavigator.push(context, const ScanPage());
    if (url != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleAddProfileFromText(url);
      });
    }
  }

  Future<void> _toAdd() async {
    final url = await globalState.showCommonDialog<String>(
      child: InputDialog(
        autovalidateMode: AutovalidateMode.onUnfocus,
        title: appLocalizations.importFromURL,
        labelText: appLocalizations.url,
        value: '',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip('').trim();
          }
          // Accept anything addProfileFromText handles: a URL, share link, or
          // pasted clash/xray/base64 content, not just a bare URL.
          if (classifyArtifact(value) == ArtifactKind.unknown) {
            return appLocalizations.urlTip('').trim();
          }
          return null;
        },
      ),
    );
    if (url != null) {
      unawaited(_handleAddProfileFromText(url));
    }
  }

  @override
  Widget build(context) {
    return ListView(
      children: [
        ListItem(
          leading: const Icon(Icons.qr_code_sharp),
          title: Text(appLocalizations.qrcode),
          subtitle: Text(appLocalizations.qrcodeDesc),
          onTap: _toScan,
        ),
        ListItem(
          leading: const Icon(Icons.upload_file_sharp),
          title: Text(appLocalizations.file),
          subtitle: Text(appLocalizations.fileDesc),
          onTap: _handleAddProfileFormFile,
        ),
        ListItem(
          leading: const Icon(Icons.cloud_download_sharp),
          title: Text(appLocalizations.url),
          subtitle: Text(appLocalizations.urlDesc),
          onTap: _toAdd,
        ),
      ],
    );
  }
}
