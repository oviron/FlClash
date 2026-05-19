import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/views/config/general.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfigView extends StatelessWidget {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: appLocalizations.core,
      actions: [
        Consumer(
          builder: (_, ref, _) => ResetActionButton(
            onConfirm: () async {
              ref
                  .read(appSettingProvider.notifier)
                  .update((state) => state.copyWith(testUrl: defaultTestUrl));
              ref
                  .read(patchClashConfigProvider.notifier)
                  .update(
                    (state) => state.copyWith(
                      hosts: const {},
                      allowLan: false,
                      tcpConcurrent: true,
                      geodataLoader: GeodataLoader.memconservative,
                      findProcessMode: FindProcessMode.always,
                      mixedPort: defaultMixedPort,
                      port: 0,
                      socksPort: 0,
                      redirPort: 0,
                      tproxyPort: 0,
                    ),
                  );
            },
          ),
        ),
      ],
      body: generateListView(generalItems),
    );
  }
}
