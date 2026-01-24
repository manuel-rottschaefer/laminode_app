import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_state.dart';
import 'package:laminode_app/core/domain/entities/cam_relation.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/cam_param_expression_input.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/param_conf_hierarchy_section.dart';

enum RelationView { expressions, hierarchy }

class ParamConfExpressionSection extends ConsumerStatefulWidget {
  const ParamConfExpressionSection({super.key});

  @override
  ConsumerState<ParamConfExpressionSection> createState() =>
      _ParamConfExpressionSectionState();
}

class _ParamConfExpressionSectionState
    extends ConsumerState<ParamConfExpressionSection> {
  RelationView _currentView = RelationView.expressions;

  void _updateRelation(CamParamEntry param, String field, String expression) {
    final relation = CamExpressionRelation(
      targetParamName: param.paramName,
      expression: expression,
    );

    late CamParamEntry newParam;
    switch (field) {
      case 'default':
        newParam = param.copyWith(defaultValue: relation);
        break;
      case 'suggested':
        newParam = param.copyWith(suggestedValue: relation);
        break;
      case 'min':
        newParam = param.copyWith(minThreshold: relation);
        break;
      case 'max':
        newParam = param.copyWith(maxThreshold: relation);
        break;
      default:
        return;
    }

    ref
        .read(schemaEditorProvider.notifier)
        .updateParameter(param.paramName, newParam);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(schemaEditorProvider);
    final param = state.selectedParameter!;

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RELATION CONFIGURATION',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              LamiTextSegmentedControl<RelationView>(
                isCompact: true,
                options: const {
                  RelationView.expressions: 'Values',
                  RelationView.hierarchy: 'Hierarchy',
                },
                selected: _currentView,
                onSelected: (val) => setState(() => _currentView = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        LamiBox(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _currentView == RelationView.expressions
                ? _buildValuesView(param, state)
                : ParamConfHierarchySection(param: param),
          ),
        ),
      ],
    );
  }

  Widget _buildValuesView(CamParamEntry param, SchemaEditorState state) {
    return Column(
      key: const ValueKey('expressions'),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CamParamExpressionInput(
                label: 'Default Value',
                expression: param.defaultValue.expression,
                schema: state.schema,
                onChanged: (val) => _updateRelation(param, 'default', val),
              ),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: CamParamExpressionInput(
                label: 'Suggested Value',
                expression: param.suggestedValue.expression,
                schema: state.schema,
                onChanged: (val) => _updateRelation(param, 'suggested', val),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CamParamExpressionInput(
                label: 'Minimum Threshold',
                expression: param.minThreshold.expression,
                schema: state.schema,
                onChanged: (val) => _updateRelation(param, 'min', val),
              ),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: CamParamExpressionInput(
                label: 'Maximum Threshold',
                expression: param.maxThreshold.expression,
                schema: state.schema,
                onChanged: (val) => _updateRelation(param, 'max', val),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
