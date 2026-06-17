import 'package:fl_clash/common/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const dark = ColorScheme.dark();
  const light = ColorScheme.light();

  group('delayColor', () {
    test('null is neutral', () {
      expect(delayColor(dark, null), dark.onSurfaceVariant);
    });

    test('timeout (<= 0) is error', () {
      expect(delayColor(dark, 0), dark.error);
      expect(delayColor(dark, -1), dark.error);
    });

    test('good / medium / slow tiers', () {
      expect(delayColor(dark, 120), dark.success);
      expect(delayColor(dark, 500), dark.warning);
      expect(delayColor(dark, 1200), dark.error);
    });

    test('brightness flips the palette', () {
      expect(dark.success, isNot(light.success));
      expect(delayColor(light, 120), light.success);
    });
  });

  group('quotaColor', () {
    test('below warn is primary', () {
      expect(quotaColor(dark, 0.3), dark.primary);
    });

    test('past warn threshold is warning', () {
      expect(quotaColor(dark, 0.7), dark.warning);
    });

    test('at or over full is error', () {
      expect(quotaColor(dark, 1.0), dark.error);
      expect(quotaColor(dark, 1.4), dark.error);
    });

    test('custom warn threshold', () {
      expect(quotaColor(dark, 0.5, warnAt: 0.8), dark.primary);
      expect(quotaColor(dark, 0.85, warnAt: 0.8), dark.warning);
    });
  });
}
