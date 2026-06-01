import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PortDialog extends ConsumerStatefulWidget {
  const PortDialog({super.key});

  @override
  ConsumerState<PortDialog> createState() => _PortDialogState();
}

class _PortDialogState extends ConsumerState<PortDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isMore = false;

  late final TextEditingController _mixedPortController;
  late final TextEditingController _portController;
  late final TextEditingController _socksPortController;
  late final TextEditingController _redirPortController;
  late final TextEditingController _tProxyPortController;

  @override
  void initState() {
    super.initState();
    final vm5 = ref.read(
      patchClashConfigProvider.select((state) {
        return VM5(
          state.mixedPort,
          state.port,
          state.socksPort,
          state.redirPort,
          state.tproxyPort,
        );
      }),
    );
    _mixedPortController = TextEditingController(text: vm5.a.toString());
    _portController = TextEditingController(text: vm5.b.toString());
    _socksPortController = TextEditingController(text: vm5.c.toString());
    _redirPortController = TextEditingController(text: vm5.d.toString());
    _tProxyPortController = TextEditingController(text: vm5.e.toString());
  }

  String? _validatePort({
    required String? value,
    required String label,
    required bool allowZero,
    required List<TextEditingController> otherControllers,
  }) {
    if (value == null || value.isEmpty) {
      return appLocalizations.emptyTip(label);
    }
    final port = int.tryParse(value);
    if (port == null) {
      return appLocalizations.numberTip(label);
    }
    if (allowZero && port == 0) {
      return null;
    }
    if (port < 1024 || port > 49151) {
      return appLocalizations.portTip(label);
    }
    final ports = otherControllers.map((item) => item.text.trim());
    if (ports.contains(value.trim())) {
      return appLocalizations.portConflictTip;
    }
    return null;
  }

  Widget _buildPortField({
    required TextEditingController controller,
    required String label,
    required List<TextEditingController> otherControllers,
    bool allowZero = true,
  }) {
    return TextFormField(
      keyboardType: TextInputType.url,
      maxLines: 1,
      minLines: 1,
      controller: controller,
      onFieldSubmitted: (_) {
        _handleUpdate();
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
      ),
      validator: (value) => _validatePort(
        value: value,
        label: label,
        allowZero: allowZero,
        otherControllers: otherControllers,
      ),
    );
  }

  Future<void> _handleReset() async {
    final res = await globalState.showMessage(
      message: TextSpan(text: appLocalizations.resetTip),
    );
    if (res != true) {
      return;
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) => state.copyWith(
            mixedPort: 7890,
            port: 0,
            socksPort: 0,
            redirPort: 0,
            tproxyPort: 0,
          ),
        );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleUpdate() {
    if (_formKey.currentState?.validate() == false) return;
    final ports = [
      int.tryParse(_mixedPortController.text),
      int.tryParse(_portController.text),
      int.tryParse(_socksPortController.text),
      int.tryParse(_redirPortController.text),
      int.tryParse(_tProxyPortController.text),
    ];
    // Collapsed advanced fields aren't in the Form tree, so validate() can't
    // catch them; reveal the section rather than crash on int.parse.
    if (ports.contains(null)) {
      if (!_isMore) setState(() => _isMore = true);
      return;
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) => state.copyWith(
            mixedPort: ports[0]!,
            port: ports[1]!,
            socksPort: ports[2]!,
            redirPort: ports[3]!,
            tproxyPort: ports[4]!,
          ),
        );
    Navigator.of(context).pop();
  }

  void _handleMore() {
    setState(() {
      _isMore = !_isMore;
    });
  }

  @override
  void dispose() {
    _mixedPortController.dispose();
    _portController.dispose();
    _socksPortController.dispose();
    _redirPortController.dispose();
    _tProxyPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.port,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              onPressed: _handleMore,
              icon: CommonExpandIcon(expand: _isMore),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: _handleReset,
                  child: Text(appLocalizations.reset),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: _handleUpdate,
                  child: Text(appLocalizations.submit),
                ),
              ],
            ),
          ],
        ),
      ],
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: AnimatedSize(
            duration: midDuration,
            curve: Curves.easeOutQuad,
            alignment: Alignment.topCenter,
            child: Column(
              spacing: 24,
              children: [
                _buildPortField(
                  controller: _mixedPortController,
                  label: appLocalizations.mixedPort,
                  allowZero: false,
                  otherControllers: [
                    _portController,
                    _socksPortController,
                    _tProxyPortController,
                    _redirPortController,
                  ],
                ),
                if (_isMore) ...[
                  _buildPortField(
                    controller: _portController,
                    label: appLocalizations.port,
                    otherControllers: [
                      _mixedPortController,
                      _socksPortController,
                      _tProxyPortController,
                      _redirPortController,
                    ],
                  ),
                  _buildPortField(
                    controller: _socksPortController,
                    label: appLocalizations.socksPort,
                    otherControllers: [
                      _portController,
                      _mixedPortController,
                      _tProxyPortController,
                      _redirPortController,
                    ],
                  ),
                  _buildPortField(
                    controller: _redirPortController,
                    label: appLocalizations.redirPort,
                    otherControllers: [
                      _portController,
                      _socksPortController,
                      _tProxyPortController,
                      _mixedPortController,
                    ],
                  ),
                  _buildPortField(
                    controller: _tProxyPortController,
                    label: appLocalizations.tproxyPort,
                    otherControllers: [
                      _portController,
                      _socksPortController,
                      _mixedPortController,
                      _redirPortController,
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
