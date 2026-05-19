import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';

/// AppBar action that asks for confirmation, then runs [onConfirm].
class ResetActionButton extends StatelessWidget {
  final Future<void> Function() onConfirm;

  const ResetActionButton({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final res = await globalState.showMessage(
          title: appLocalizations.reset,
          message: TextSpan(text: appLocalizations.resetTip),
        );
        if (res != true) return;
        await onConfirm();
      },
      tooltip: appLocalizations.reset,
      icon: const Icon(Icons.replay),
    );
  }
}
