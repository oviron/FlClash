import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/quickstart_verification.dart';
import 'package:fl_clash/views/profiles/add.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Connect-time verification banner: pure on [status] so it can be widget-tested
// without a ProviderScope. [QuickStartVerifyOverlay] wires it to the provider.
class QuickStartVerifyCard extends StatelessWidget {
  final QuickStartVerifyStatus status;
  final VoidCallback onRetry;
  final VoidCallback onUseDifferent;

  const QuickStartVerifyCard({
    super.key,
    required this.status,
    required this.onRetry,
    required this.onUseDifferent,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    switch (status) {
      case QuickStartVerifyStatus.idle:
        return const SizedBox.shrink();
      case QuickStartVerifyStatus.verifying:
        return _Banner(
          leading: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          text: appLocalizations.quickStartVerifying,
        );
      case QuickStartVerifyStatus.verified:
        return _Banner(
          leading: Icon(Icons.check_circle, color: scheme.success),
          text: appLocalizations.quickStartVerified,
          textColor: scheme.success,
        );
      case QuickStartVerifyStatus.failed:
        return _FailCard(onRetry: onRetry, onUseDifferent: onUseDifferent);
    }
  }
}

class _Banner extends StatelessWidget {
  final Widget leading;
  final String text;
  final Color? textColor;

  const _Banner({required this.leading, required this.text, this.textColor});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      radius: 18,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: context.textTheme.titleSmall?.copyWith(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FailCard extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onUseDifferent;

  const _FailCard({required this.onRetry, required this.onUseDifferent});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return CommonCard(
      radius: 18,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: scheme.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appLocalizations.quickStartFailedTitle,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appLocalizations.quickStartFailedBody,
              style: context.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onUseDifferent,
                  child: Text(appLocalizations.quickStartUseDifferent),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onRetry,
                  child: Text(appLocalizations.quickStartTryAgain),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Mounts QuickStartVerifyCard against the provider: retries on demand and routes
// "use a different key" back through the paste on-ramp. Auto-dismiss lives in the
// notifier so it survives this widget being disposed.
class QuickStartVerifyOverlay extends ConsumerWidget {
  const QuickStartVerifyOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(quickStartVerificationProvider);
    return QuickStartVerifyCard(
      status: status,
      onRetry: ref.read(quickStartVerificationProvider.notifier).run,
      onUseDifferent: () {
        ref.read(quickStartVerificationProvider.notifier).dismiss();
        pasteKeyOnramp();
      },
    );
  }
}
