import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'param_relation_list_item.dart';
import 'param_search_widget.dart';

class ParamConfHierarchySection extends ConsumerStatefulWidget {
  final CamParamEntry param;

  const ParamConfHierarchySection({super.key, required this.param});

  @override
  ConsumerState<ParamConfHierarchySection> createState() =>
      _ParamConfHierarchySectionState();
}

class _ParamConfHierarchySectionState
    extends ConsumerState<ParamConfHierarchySection> {
  CamParamEntry? _selectedAncestor;
  final GlobalKey<ParamSearchWidgetState> _searchKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(schemaEditorProvider);
    final allParams = state.schema.availableParameters;

    // Parameters that have the current param as a child
    final ancestors = allParams.where((p) {
      return p.children.any(
        (rel) => rel.childParamName == widget.param.paramName,
      );
    }).toList();

    // Parameters that are children of the current param
    final children = widget.param.children.map((rel) {
      return allParams
              .where((p) => p.paramName == rel.childParamName)
              .firstOrNull ??
          CamParamEntry(
            paramName: rel.childParamName,
            paramTitle: rel.childParamName,
            quantity: widget.param.quantity,
            category: widget.param.category,
            value: null,
          );
    }).toList();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ancestors.isEmpty && children.isEmpty)
          _buildEmptyText("No active relations for this parameter.")
        else ...[
          ...ancestors.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: ParamRelationListItem(
                parent: p,
                child: widget.param,
                onDelete: () {
                  ref
                      .read(schemaEditorProvider.notifier)
                      .removeChildRelation(p.paramName, widget.param.paramName);
                },
              ),
            ),
          ),
          ...children.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: ParamRelationListItem(
                parent: widget.param,
                child: p,
                onDelete: () {
                  ref
                      .read(schemaEditorProvider.notifier)
                      .removeChildRelation(widget.param.paramName, p.paramName);
                },
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.m),
        Text(
          "Create New Ancestor Relation",
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ParamSearchWidget(
                key: _searchKey,
                allParameters: allParams,
                hostParamName: widget.param.paramName,
                onSelected: (p) => setState(() => _selectedAncestor = p),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            LamiButton(
              label: "Add Relation",
              icon: LucideIcons.plus,
              onPressed: _selectedAncestor == null
                  ? null
                  : () {
                      ref
                          .read(schemaEditorProvider.notifier)
                          .addChildRelation(
                            _selectedAncestor!.paramName,
                            widget.param.paramName,
                          );
                      _searchKey.currentState?.clear();
                      setState(() => _selectedAncestor = null);
                    },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontStyle: FontStyle.italic,
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 11,
        ),
      ),
    );
  }
}
