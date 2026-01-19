import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog_widgets.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';

class CreateLayerDialog extends ConsumerStatefulWidget {
  const CreateLayerDialog({super.key});

  @override
  ConsumerState<CreateLayerDialog> createState() => _CreateLayerDialogState();
}

class _CreateLayerDialogState extends ConsumerState<CreateLayerDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(layerPanelProvider.notifier).addEmptyLayer();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const LamiDialogHeader(title: "New Profile Layer"),

          LamiDialogForm(
            children: [
              // Name Field
              LamiDialogInput(
                label: "Name",
                controller: _nameController,
                hintText: "Enter layer name",
                autofocus: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Name is required";
                  return null;
                },
              ),

              // Description Field
              LamiDialogInput(
                label: "Description",
                controller: _descriptionController,
                hintText: "Enter layer description",
                maxLines: 3,
              ),

              // Placeholder for Category Selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Category",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "Category Selector Placeholder",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          LamiDialogActions(
            actions: [
              LamiButton(
                icon: Icons.cancel_rounded,
                label: "Cancel",
                onPressed: () => Navigator.of(context).pop(),
              ),
              LamiButton(
                icon: Icons.check_rounded,
                label: "Create",
                onPressed: _submit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
