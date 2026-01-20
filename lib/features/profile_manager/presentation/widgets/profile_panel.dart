import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_panel.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';
import 'package:laminode_app/features/profile_manager/presentation/dialogs/create_profile_dialog.dart';
import 'package:laminode_app/features/profile_manager/presentation/dialogs/edit_profile_dialog.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';
import 'package:laminode_app/features/profile_manager/presentation/widgets/application_info_tile.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfilePanel extends ConsumerWidget {
  const ProfilePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileManagerProvider);
    final profile = state.currentProfile;

    return LamiPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          LamiPanelHeader(
            icon: LucideIcons.user,
            title: profile?.name ?? "No Profile Selected",
            trailing: profile != null
                ? LamiIcon(
                    icon: LucideIcons.logOut,
                    size: 16,
                    onPressed: () {
                      ref
                          .read(profileManagerProvider.notifier)
                          .setProfile(null);
                    },
                  )
                : null,
          ),
          if (profile != null) ...[
            ApplicationInfoTile(application: profile.application),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: LamiButton(
                    icon: LucideIcons.save,
                    label: "Save Profile",
                    onPressed: () {
                      // Save Profile logic
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: LamiButton(
                    icon: LucideIcons.edit3,
                    label: "Edit Profile",
                    onPressed: () {
                      showLamiDialog(
                        context: context,
                        model: const LamiDialogModel(
                          title: "Edit Profile",
                          content: EditProfileDialog(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ] else
            _buildEmptyState(context, ref),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            "Create or load a profile to get started.",
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            Expanded(
              child: LamiButton(
                icon: LucideIcons.plus,
                label: "Create",
                onPressed: () {
                  showLamiDialog(
                    context: context,
                    model: const LamiDialogModel(
                      title: "Create Profile",
                      content: CreateProfileDialog(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: LamiButton(
                icon: LucideIcons.folderOpen,
                label: "Load",
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['lmdp'],
                      );

                  if (result != null && result.files.single.path != null) {
                    try {
                      await ref
                          .read(profileManagerProvider.notifier)
                          .loadProfile(result.files.single.path!);
                    } on SchemaNotFoundException catch (e) {
                      if (!context.mounted) return;
                      showLamiDialog(
                        context: context,
                        model: LamiDialogModel(
                          title: "Schema Not Found",
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "The profile requires the schema \"${e.schemaId}\", but it is not installed locally. Please install the required plugin first.",
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: AppSpacing.l),
                              LamiButton(
                                label: "Quit",
                                icon: LucideIcons.x,
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
