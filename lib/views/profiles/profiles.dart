import 'dart:async';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/quickstart_config_service.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/overwrite.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add.dart';
import 'edit.dart';
import 'reorderable_profiles_sheet.dart';

class ProfilesView extends StatefulWidget {
  const ProfilesView({super.key});

  @override
  State<ProfilesView> createState() => _ProfilesViewState();
}

class _ProfilesViewState extends State<ProfilesView> {
  Function? applyConfigDebounce;
  bool _isUpdating = false;

  void _handleShowAddExtendPage() {
    showExtend(
      globalState.navigatorKey.currentState!.context,
      builder: (_, type) {
        return AdaptiveSheetScaffold(
          type: type,
          body: AddProfileView(
            context: globalState.navigatorKey.currentState!.context,
          ),
          title: '${appLocalizations.add}${appLocalizations.profile}',
        );
      },
    );
  }

  // First-run on-ramp: if the clipboard already holds a recognizable artifact,
  // import it in one tap; otherwise open the format-agnostic paste dialog.
  Future<void> _handlePasteKey() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text != null &&
        text.isNotEmpty &&
        classifyArtifact(text) != ArtifactKind.unknown) {
      unawaited(appController.addProfileFromText(text));
      return;
    }
    final value = await globalState.showCommonDialog<String>(
      child: InputDialog(
        autovalidateMode: AutovalidateMode.onUnfocus,
        title: appLocalizations.quickStartPasteKey,
        labelText: appLocalizations.quickStartPasteHint,
        value: '',
        validator: (v) => (v == null || v.isEmpty)
            ? appLocalizations.emptyTip('').trim()
            : null,
      ),
    );
    if (value != null) {
      unawaited(appController.addProfileFromText(value));
    }
  }

  Future<void> _updateProfiles(List<Profile> profiles) async {
    if (_isUpdating == true) {
      return;
    }
    _isUpdating = true;
    final List<UpdatingMessage> messages = [];
    final updateProfiles = profiles.map<Future<void>>((profile) async {
      if (profile.type == ProfileType.file) return;
      try {
        await appController.updateProfile(profile, showLoading: true);
      } catch (e) {
        messages.add(
          UpdatingMessage(label: profile.realLabel, message: e.toString()),
        );
      }
    });
    await Future.wait(updateProfiles);
    if (messages.isNotEmpty) {
      unawaited(globalState.showAllUpdatingMessagesDialog(messages));
    }
    _isUpdating = false;
  }

  List<Widget> _buildActions(List<Profile> profiles) {
    return profiles.isNotEmpty
        ? [
            IconButton(
              onPressed: () {
                _updateProfiles(profiles);
              },
              icon: const Icon(Icons.sync),
            ),
            IconButton(
              onPressed: () {
                showSheet(
                  context: context,
                  builder: (_, type) {
                    return ReorderableProfilesSheet(
                      type: type,
                      profiles: profiles,
                    );
                  },
                );
              },
              icon: const Icon(Icons.sort),
              iconSize: 26,
            ),
          ]
        : [];
  }

  Widget _buildFAB() {
    return CommonFloatingActionButton(
      onPressed: _handleShowAddExtendPage,
      icon: const Icon(Icons.add),
      label: context.appLocalizations.addProfile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, _) {
        final isLoading = ref.watch(loadingProvider(LoadingTag.profiles));
        final state = ref.watch(profilesStateProvider);
        final spacing = 14.mAp;
        return CommonScaffold(
          isLoading: isLoading,
          title: appLocalizations.profiles,
          floatingActionButton: _buildFAB(),
          actions: _buildActions(state.profiles),
          body: state.profiles.isEmpty
              ? NullStatus(
                  label: appLocalizations.nullProfileDesc,
                  illustration: const ProfileEmptyIllustration(),
                  action: FilledButton.icon(
                    onPressed: _handlePasteKey,
                    icon: const Icon(Icons.content_paste),
                    label: Text(appLocalizations.quickStartPasteKey),
                  ),
                )
              : Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    key: profilesStoreKey,
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 88,
                    ),
                    child: Grid(
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      crossAxisCount: state.columns,
                      children: [
                        for (int i = 0; i < state.profiles.length; i++)
                          GridItem(
                            child: ProfileItem(
                              key: Key(state.profiles[i].id.toString()),
                              profile: state.profiles[i],
                              groupValue: state.currentProfileId,
                              onChanged: (profileId) {
                                final previousId = ref.read(
                                  currentProfileIdProvider,
                                );
                                final wasRunning =
                                    ref.read(runTimeProvider) != null;
                                ref
                                        .read(currentProfileIdProvider.notifier)
                                        .value =
                                    profileId;
                                if (wasRunning && profileId != previousId) {
                                  globalState.navigatorKey.currentContext
                                      ?.showSnackBar(
                                        appLocalizations.restartVpnToApply,
                                      );
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class ProfileItem extends StatelessWidget {
  final Profile profile;
  final int? groupValue;
  final void Function(int? value) onChanged;

  const ProfileItem({
    super.key,
    required this.profile,
    required this.groupValue,
    required this.onChanged,
  });

  Future<void> _handleDeleteProfile(BuildContext context) async {
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.profile),
      ),
    );
    if (res != true) {
      return;
    }
    await appController.deleteProfile(profile.id);
  }

  Future<void> _handlePreview(BuildContext context) async {
    final configMap = await appController.getProfileWithId(profile.id);
    final content = await encodeYamlTask(configMap);
    if (!context.mounted) {
      return;
    }

    final previewPage = EditorPage(title: profile.realLabel, content: content);
    unawaited(BaseNavigator.push<String>(context, previewPage));
  }

  Future<void> updateProfile() async {
    if (profile.type == ProfileType.file) return;
    try {} finally {}
    await appController.loadingRun(() async {
      await appController.updateProfile(profile, showLoading: true);
    }, tag: LoadingTag.profiles);
  }

  void _handleShowEditExtendPage(BuildContext context) {
    showExtend(
      context,
      builder: (_, type) {
        return AdaptiveSheetScaffold(
          type: type,
          body: EditProfileView(profile: profile, context: context),
          title: '${appLocalizations.edit} ${appLocalizations.profile}',
        );
      },
    );
  }

  List<Widget> _buildUrlProfileInfo(BuildContext context) {
    // A URL profile shows its quota bar only when the subscription reports a
    // non-zero total; otherwise it degrades to the stat line.
    final hasQuota = (profile.subscriptionInfo?.total ?? 0) != 0;
    final updated = Text(
      profile.lastUpdateDate?.lastUpdateTimeDesc ?? '',
      style: context.textTheme.labelMedium?.toLighter,
    );
    if (hasQuota) {
      return [
        const SizedBox(height: 8),
        SubscriptionInfoView(subscriptionInfo: profile.subscriptionInfo),
        updated,
      ];
    }
    return [
      const SizedBox(height: 8),
      updated,
      _ProfileStatLine(profileId: profile.id),
    ];
  }

  List<Widget> _buildFileProfileInfo(BuildContext context) {
    return [
      const SizedBox(height: 8),
      Text(
        profile.lastUpdateDate?.lastUpdateTimeDesc ?? '',
        style: context.textTheme.labelMedium?.toLight,
      ),
      _ProfileStatLine(profileId: profile.id),
    ];
  }

  Future<void> _handleCopyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: profile.url));
    if (context.mounted) {
      context.showNotifier(appLocalizations.copySuccess);
    }
  }

  Future<void> _handleExportFile(BuildContext context) async {
    final res = await appController.safeRun<bool>(() async {
      final mFile = await profile.file;
      final value = await picker.saveFile(
        profile.realLabel,
        mFile.readAsBytesSync(),
      );
      if (value == null) return false;
      return true;
    }, title: appLocalizations.tip);
    if (res == true && context.mounted) {
      context.showNotifier(appLocalizations.exportSuccess);
    }
  }

  void _handlePushGenProfilePage(BuildContext context, int id) {
    BaseNavigator.push(context, OverwriteView(profileId: id));
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      isSelected: profile.id == groupValue,
      onPressed: () {
        onChanged(profile.id);
      },
      child: ListItem(
        key: Key(profile.id.toString()),
        horizontalTitleGap: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        trailing: SizedBox(
          height: 40,
          width: 40,
          child: Consumer(
            builder: (_, ref, _) {
              final isUpdating = ref.watch(
                isUpdatingProvider(profile.updatingKey),
              );
              return FadeThroughBox(
                child: isUpdating
                    ? const Padding(
                        key: ValueKey('loading'),
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      )
                    : CommonPopupBox(
                        key: const ValueKey('menu'),
                        popup: CommonPopupMenu(
                          items: [
                            PopupMenuItemData(
                              icon: Icons.edit_outlined,
                              label: appLocalizations.edit,
                              onPressed: () {
                                _handleShowEditExtendPage(context);
                              },
                            ),
                            PopupMenuItemData(
                              icon: Icons.visibility_outlined,
                              label: appLocalizations.preview,
                              onPressed: () {
                                _handlePreview(context);
                              },
                            ),
                            if (profile.type == ProfileType.url) ...[
                              PopupMenuItemData(
                                icon: Icons.sync_alt_sharp,
                                label: appLocalizations.sync,
                                onPressed: () {
                                  updateProfile();
                                },
                              ),
                            ],
                            PopupMenuItemData(
                              icon: Icons.emergency_outlined,
                              label: appLocalizations.more,
                              subItems: [
                                PopupMenuItemData(
                                  icon: Icons.extension_outlined,
                                  label: appLocalizations.override,
                                  onPressed: () {
                                    _handlePushGenProfilePage(
                                      context,
                                      profile.id,
                                    );
                                  },
                                ),
                                if (profile.type == ProfileType.url) ...[
                                  PopupMenuItemData(
                                    icon: Icons.copy,
                                    label: appLocalizations.copyLink,
                                    onPressed: () {
                                      _handleCopyLink(context);
                                    },
                                  ),
                                ],
                                PopupMenuItemData(
                                  icon: Icons.file_copy_outlined,
                                  label: appLocalizations.exportFile,
                                  onPressed: () {
                                    _handleExportFile(context);
                                  },
                                ),
                              ],
                            ),
                            PopupMenuItemData(
                              danger: true,
                              icon: Icons.delete_outlined,
                              label: appLocalizations.delete,
                              onPressed: () {
                                _handleDeleteProfile(context);
                              },
                            ),
                          ],
                        ),
                        targetBuilder: (open) {
                          return IconButton(
                            onPressed: () {
                              open();
                            },
                            icon: const Icon(Icons.more_vert),
                          );
                        },
                      ),
              );
            },
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.realLabel,
                style: context.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...switch (profile.type) {
                    ProfileType.file => _buildFileProfileInfo(context),
                    ProfileType.url => _buildUrlProfileInfo(context),
                  },
                ],
              ),
            ],
          ),
        ),
        tileTitleAlignment: ListTileTitleAlignment.titleHeight,
      ),
    );
  }
}

/// Group/node stats for a card without a profile-level quota.
class _ProfileStatLine extends StatefulWidget {
  final int profileId;

  const _ProfileStatLine({required this.profileId});

  @override
  State<_ProfileStatLine> createState() => _ProfileStatLineState();
}

class _ProfileStatLineState extends State<_ProfileStatLine> {
  // Read once per profileId: a profile switch rebuilds the whole grid, so a
  // per-build future would re-read every card's file on every switch.
  late Future<({int groups, int nodes, int providers})> _stats = appController
      .readProfileStats(widget.profileId);

  @override
  void didUpdateWidget(_ProfileStatLine old) {
    super.didUpdateWidget(old);
    if (old.profileId != widget.profileId) {
      _stats = appController.readProfileStats(widget.profileId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<({int groups, int nodes, int providers})>(
      future: _stats,
      builder: (context, snapshot) {
        final stats = snapshot.data;
        if (stats == null || (stats.groups == 0 && stats.nodes == 0)) {
          return const SizedBox.shrink();
        }
        final labelStyle = context.textTheme.labelMedium?.toLight;
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lan_outlined,
                    size: 15,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    appLocalizations.profileGroupCount(stats.groups),
                    style: labelStyle,
                  ),
                  const SizedBox(width: 14),
                  Icon(
                    Icons.dns_outlined,
                    size: 15,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    appLocalizations.profileNodeCount(stats.nodes),
                    style: labelStyle,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
