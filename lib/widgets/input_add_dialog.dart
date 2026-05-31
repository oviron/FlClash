import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:flutter/material.dart';

class AddDialog extends StatefulWidget {
  final String title;
  final Field? keyField;
  final Field valueField;

  const AddDialog({
    super.key,
    required this.title,
    this.keyField,
    required this.valueField,
  });

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  TextEditingController? _keyController;
  late TextEditingController _valueController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Field? get keyField => widget.keyField;

  Field get valueField => widget.valueField;

  @override
  void initState() {
    super.initState();
    if (keyField != null) {
      _keyController = TextEditingController(text: keyField!.value);
    }
    _valueController = TextEditingController(text: valueField.value);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (keyField != null) {
      Navigator.of(context).pop<MapEntry<String, String>>(
        MapEntry(_keyController!.text, _valueController.text),
      );
    } else {
      Navigator.of(context).pop<String>(_valueController.text);
    }
  }

  @override
  void dispose() {
    _keyController?.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: widget.title,
      actions: [
        TextButton(onPressed: _submit, child: Text(appLocalizations.confirm)),
      ],
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: [
            if (keyField != null)
              TextFormField(
                maxLines: 3,
                minLines: 1,
                controller: _keyController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: keyField!.label,
                ),
                validator: (String? value) {
                  String? res;
                  if (keyField!.validator != null) {
                    res = keyField!.validator!(value);
                  }
                  if (res != null) {
                    return res;
                  }
                  if (value == null || value.isEmpty) {
                    return appLocalizations.emptyTip(appLocalizations.key);
                  }
                  return null;
                },
              ),
            TextFormField(
              maxLines: 3,
              minLines: 1,
              keyboardType: TextInputType.text,
              controller: _valueController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: valueField.label,
              ),
              onFieldSubmitted: (_) {
                _submit();
              },
              validator: (String? value) {
                String? res;
                if (valueField.validator != null) {
                  res = valueField.validator!(value);
                }
                if (res != null) {
                  return res;
                }
                if (value == null || value.isEmpty) {
                  return appLocalizations.emptyTip(appLocalizations.value);
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
