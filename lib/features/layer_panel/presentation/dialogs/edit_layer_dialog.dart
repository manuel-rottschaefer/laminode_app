import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_dialog_layout.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EditLayerDialog extends ConsumerStatefulWidget {
  final LamiLayerEntry entry;
  final int index;

  const EditLayerDialog({super.key, required this.entry, required this.index});

  @override
  ConsumerState<EditLayerDialog> createState() => _EditLayerDialogState();
}

class _EditLayerDialogState extends ConsumerState<EditLayerDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry.layerName);
    _descriptionController = TextEditingController(
      text: widget.entry.layerDescription,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(layerPanelProvider.notifier)
          .updateLayer(
            widget.index,
            name: _nameController.text,
            description: _descriptionController.text,
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: LamiDialogLayout(
        actions: [
          LamiButton(
            icon: LucideIcons.x,
            label: "Cancel",
            onPressed: () => Navigator.of(context).pop(),
          ),
          LamiButton(
            icon: LucideIcons.check,
            label: "Save Changes",
            onPressed: _submit,
          ),
        ],
        children: [
          LamiDialogInput(
            label: "Name",
            controller: _nameController,
            hintText: "Enter layer name",
            validator: (value) {
              if (value == null || value.isEmpty) return "Name is required";
              return null;
            },
          ),
          LamiDialogInput(
            label: "Description",
            controller: _descriptionController,
            hintText: "Enter layer description",
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
