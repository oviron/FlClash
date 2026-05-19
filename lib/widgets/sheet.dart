import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

import 'scaffold.dart';

@immutable
class SheetProps {
  final bool isScrollControlled;
  final bool useSafeArea;

  const SheetProps({this.useSafeArea = true, this.isScrollControlled = false});
}

enum SheetType { page, bottomSheet }

typedef SheetBuilder = Widget Function(BuildContext context, SheetType type);

Future<T?> showSheet<T>({
  required BuildContext context,
  required SheetBuilder builder,
  SheetProps props = const SheetProps(),
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: props.isScrollControlled,
    builder: (_) {
      return builder(context, SheetType.bottomSheet);
    },
    showDragHandle: false,
    useSafeArea: props.useSafeArea,
  );
}

Future<T?> showExtend<T>(
  BuildContext context, {
  required SheetBuilder builder,
}) {
  return BaseNavigator.push(context, builder(context, SheetType.page));
}

class AdaptiveSheetScaffold extends StatefulWidget {
  final SheetType type;
  final Widget body;
  final String title;
  final bool? centerTitle;
  final List<Widget> actions;

  const AdaptiveSheetScaffold({
    super.key,
    required this.type,
    required this.body,
    required this.title,
    this.centerTitle,
    this.actions = const [],
  });

  @override
  State<AdaptiveSheetScaffold> createState() => _AdaptiveSheetScaffoldState();
}

class _AdaptiveSheetScaffoldState extends State<AdaptiveSheetScaffold> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.colorScheme.surface;
    final bottomSheet = widget.type == SheetType.bottomSheet;
    final appBar = AppBar(
      forceMaterialTransparency: bottomSheet,
      automaticallyImplyLeading: !bottomSheet,
      centerTitle:
          widget.centerTitle ?? (bottomSheet && widget.actions.isEmpty),
      backgroundColor: backgroundColor,
      title: Text(widget.title),
      actions: genActions(widget.actions),
    );
    if (bottomSheet) {
      const handleSize = Size(32, 4);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              alignment: Alignment.center,
              height: handleSize.height,
              width: handleSize.width,
              decoration: ShapeDecoration(
                color: context.colorScheme.onSurfaceVariant,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(handleSize.height / 2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: appBar,
          ),
          Flexible(flex: 1, child: widget.body),
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      );
    }
    return CommonScaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      body: widget.body,
    );
  }
}
