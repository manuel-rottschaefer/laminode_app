import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/schema_manifest.dart';

enum SchemaEditorViewMode { schema, parameters }

class SchemaEditorState {
  final CamSchemaEntry schema;
  final SchemaManifest manifest;
  final String adapterCode;
  final CamParamEntry? selectedParameter;
  final CamCategoryEntry? selectedCategory;
  final SchemaEditorViewMode viewMode;
  final String parameterSearchQuery;
  final bool showHiddenParameters;

  SchemaEditorState({
    required this.schema,
    required this.manifest,
    this.adapterCode = '',
    this.selectedParameter,
    this.selectedCategory,
    this.viewMode = SchemaEditorViewMode.schema,
    this.parameterSearchQuery = '',
    this.showHiddenParameters = true,
  });

  SchemaEditorState copyWith({
    CamSchemaEntry? schema,
    SchemaManifest? manifest,
    String? adapterCode,
    CamParamEntry? selectedParameter,
    CamCategoryEntry? selectedCategory,
    SchemaEditorViewMode? viewMode,
    String? parameterSearchQuery,
    bool? showHiddenParameters,
    bool clearSelectedParameter = false,
    bool clearSelectedCategory = false,
  }) {
    return SchemaEditorState(
      schema: schema ?? this.schema,
      manifest: manifest ?? this.manifest,
      adapterCode: adapterCode ?? this.adapterCode,
      selectedParameter: clearSelectedParameter
          ? null
          : (selectedParameter ?? this.selectedParameter),
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      viewMode: viewMode ?? this.viewMode,
      parameterSearchQuery: parameterSearchQuery ?? this.parameterSearchQuery,
      showHiddenParameters: showHiddenParameters ?? this.showHiddenParameters,
    );
  }
}
