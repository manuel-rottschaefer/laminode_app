import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_dialog_layout.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  const EditProfileDialog({super.key});

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileManagerProvider).currentProfile;
    _nameController = TextEditingController(text: profile?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LamiDialogLayout(
      actions: [
        LamiButton(
          icon: LucideIcons.x,
          label: "Cancel",
          onPressed: () => Navigator.of(context).pop(),
        ),
        LamiButton(
          icon: LucideIcons.check,
          label: "Save Changes",
          onPressed: () {
            ref
                .read(profileManagerProvider.notifier)
                .updateProfileName(_nameController.text);
            Navigator.of(context).pop();
          },
        ),
      ],
      children: [
        Text(
          "Update the profile name and settings.",
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        LamiDialogInput(
          label: "Profile Name",
          controller: _nameController,
          prefixIcon: const Icon(LucideIcons.tag, size: 18),
        ),
      ],
    );
  }
}
