import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/library/model.dart';
import 'package:fl_clash/library/providers.dart';
import 'package:fl_clash/views/setting/library_version.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Only for a downloaded core: its version while it runs, an error card when
// another core answers instead or the selection failed to load. The bundled
// default needs no note.
class RunningCoreNote extends ConsumerWidget {
  const RunningCoreNote({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final running = ref.watch(runningCoreProvider).value;
    if (running == null) return const SizedBox.shrink();
    final scheme = context.colorScheme;
    final problem = runningCoreProblem(running);
    if (problem == null) {
      final selected = running.selectedDir;
      if (selected == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          appLocalizations.libCore(libVersionFromDir(selected)),
          style: context.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    }
    final bundled =
        (ref.watch(libraryBundledVersionsProvider).value ??
        const {})[kLibMihomo];
    final detailStyle = context.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: CommonCard(
        radius: 18,
        onPressed: () =>
            BaseNavigator.push(context, const LibraryVersionView()),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: scheme.error),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      problem.title,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${appLocalizations.libRunning}: '
                      '${runningCoreLabel(running, bundled)}',
                      style: detailStyle,
                    ),
                    if (problem.detail != null)
                      Text(
                        problem.detail!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: detailStyle,
                      ),
                  ],
                ),
              ),
              if (running.loadFailure != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => ref
                      .read(libraryControllerProvider.notifier)
                      .dismissLoadFailure(kLibMihomo),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
