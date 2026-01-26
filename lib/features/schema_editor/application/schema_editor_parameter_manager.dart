import 'package:laminode_app/features/schema_editor/application/schema_editor_state.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/cam_relation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

mixin SchemaEditorParameterManager on Notifier<SchemaEditorState> {
  void addParameter(CamParamEntry parameter) {
    final updatedParams = [...state.schema.availableParameters, parameter];
    state = state.copyWith(
      schema: CamSchemaEntry(
        schemaName: state.schema.schemaName,
        categories: state.schema.categories,
        availableParameters: updatedParams,
      ),
    );
  }

  void updateParameter(String oldName, CamParamEntry newParameter) {
    final updatedParams = state.schema.availableParameters.map((p) {
      return p.paramName == oldName ? newParameter : p;
    }).toList();

    state = state.copyWith(
      schema: CamSchemaEntry(
        schemaName: state.schema.schemaName,
        categories: state.schema.categories,
        availableParameters: updatedParams,
      ),
      selectedParameter: state.selectedParameter?.paramName == oldName
          ? newParameter
          : null,
    );
  }

  void deleteParameter(String name) {
    final updatedParams = state.schema.availableParameters
        .where((p) => p.paramName != name)
        .toList();
    state = state.copyWith(
      schema: CamSchemaEntry(
        schemaName: state.schema.schemaName,
        categories: state.schema.categories,
        availableParameters: updatedParams,
      ),
      clearSelectedParameter: state.selectedParameter?.paramName == name,
    );
  }

  void setParameterSearchQuery(String query) {
    state = state.copyWith(parameterSearchQuery: query);
  }

  void selectParameter(CamParamEntry? parameter) {
    state = state.copyWith(
      selectedParameter: parameter,
      clearSelectedParameter: parameter == null,
    );
  }

  void addChildRelation(String paramName, String childParamName) {
    final param = state.schema.availableParameters.firstWhere(
      (p) => p.paramName == paramName,
    );
    if (param.children.any((c) => c.childParamName == childParamName)) return;

    final newChild = CamHierarchyRelation(
      targetParamName: paramName,
      childParamName: childParamName,
    );
    final updatedParam = param.copyWith(
      children: [...param.children, newChild],
    );
    updateParameter(paramName, updatedParam);
  }

  void removeChildRelation(String paramName, String childParamName) {
    final param = state.schema.availableParameters.firstWhere(
      (p) => p.paramName == paramName,
    );
    final updatedParam = param.copyWith(
      children: param.children
          .where((c) => c.childParamName != childParamName)
          .toList(),
    );
    updateParameter(paramName, updatedParam);
  }
}
