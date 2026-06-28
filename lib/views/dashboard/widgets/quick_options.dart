import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/views/config/network.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VpnButton extends ConsumerWidget {
  const VpnButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enable = ref.watch(
      vpnSettingProvider.select((state) => state.enable),
    );
    return SizedBox(
      height: getWidgetHeight(1),
      child: CommonCard(
        onPressed: () {
          showSheet(
            context: context,
            builder: (_, type) {
              return AdaptiveSheetScaffold(
                type: type,
                body: generateListView(
                  generateSection(
                    items: [
                      const VPNItem(),
                      const VpnSystemProxyItem(),
                      const TunStackItem(),
                    ],
                  ),
                ),
                title: 'VPN',
              );
            },
          );
        },
        info: const Info(label: 'VPN', iconData: Icons.stacked_line_chart),
        child: ListItem.switchItem(
          title: Text(
            appLocalizations.options,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          delegate: SwitchDelegate(
            value: enable,
            onChanged: (value) {
              ref
                  .read(vpnSettingProvider.notifier)
                  .update((state) => state.copyWith(enable: value));
            },
          ),
        ),
      ),
    );
  }
}
