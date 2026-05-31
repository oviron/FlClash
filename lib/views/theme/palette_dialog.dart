// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

class PaletteDialog extends StatefulWidget {
  const PaletteDialog({super.key});

  @override
  State<PaletteDialog> createState() => _PaletteDialogState();
}

class _PaletteDialogState extends State<PaletteDialog> {
  final _controller = ValueNotifier<ui.Color>(Colors.transparent);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.palette,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_controller.value.toARGB32());
          },
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            width: 250,
            height: 250,
            child: Palette(controller: _controller),
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (_, color, _) {
              return PrimaryColorBox(
                primaryColor: color,
                child: FilledButton(
                  onPressed: () {},
                  child: Text(_controller.value.hex),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
