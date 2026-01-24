import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_state.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/schema_manifest.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_category_manager.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_parameter_manager.dart';

class SchemaEditorNotifier extends Notifier<SchemaEditorState>
    with SchemaEditorCategoryManager, SchemaEditorParameterManager {
  @override
  SchemaEditorState build() {
    return SchemaEditorState(
      schema: CamSchemaEntry(
        schemaName: 'New Schema',
        categories: [
          CamCategoryEntry(
            categoryName: 'default',
            categoryTitle: 'Default',
            categoryColorName: 'blue',
          ),
        ],
        availableParameters: [],
      ),
      manifest: SchemaManifest(
        schemaType: 'application',
        schemaVersion: '1.0.0',
        schemaAuthors: [],
        lastUpdated: DateTime.now().toIso8601String(),
        targetAppName: 'New Schema',
        targetAppSector: 'FDM',
      ),
      adapterCode:
          '// Adapter Logic\n\nfunction exportProfile(profile) {\n  return "G1 X0 Y0";\n}\n',
    );
  }

  void loadSchema(
    CamSchemaEntry schema,
    SchemaManifest manifest, {
    String? adapterCode,
  }) {
    state = state.copyWith(
      schema: schema,
      manifest: manifest,
      adapterCode: adapterCode ?? state.adapterCode,
      viewMode: SchemaEditorViewMode.schema,
      clearSelectedParameter: true,
      clearSelectedCategory: true,
    );
  }

  void updateManifest({
    String? schemaVersion,
    List<String>? schemaAuthors,
    String? targetAppName,
    String? targetAppSector,
  }) {
    final current = state.manifest;
    state = state.copyWith(
      manifest: SchemaManifest(
        schemaType: current.schemaType,
        schemaVersion: schemaVersion ?? current.schemaVersion,
        schemaAuthors: schemaAuthors ?? current.schemaAuthors,
        lastUpdated: DateTime.now().toIso8601String(),
        targetAppName: targetAppName ?? current.targetAppName,
        targetAppSector: targetAppSector ?? current.targetAppSector,
      ),
    );

    // Sync schemaName with targetAppName if changed
    if (targetAppName != null && targetAppName != state.schema.schemaName) {
      state = state.copyWith(
        schema: CamSchemaEntry(
          schemaName: targetAppName,
          categories: state.schema.categories,
          availableParameters: state.schema.availableParameters,
        ),
      );
    }
  }

  void setViewMode(SchemaEditorViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void updateAdapterCode(String code) {
    state = state.copyWith(adapterCode: code);
  }

  Future<void> exportSchema() async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Schema Bundle',
      fileName: '${state.schema.schemaName.replaceAll(' ', '_')}.zip',
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null) return;

    final encoder = ZipEncoder();
    final archive = Archive();

    // Create schema JSON
    final schemaJson = jsonEncode({
      'schemaName': state.schema.schemaName,
      'categories': state.schema.categories
          .map(
            (c) => {
              'categoryName': c.categoryName,
              'categoryTitle': c.categoryTitle,
              'categoryColorName': c.categoryColorName,
            },
          )
          .toList(),
      'availableParameters': state.schema.availableParameters
          .map(
            (p) => {
              'paramName': p.paramName,
              'paramTitle': p.paramTitle,
              'paramDescription': p.paramDescription,
              'isVisible': p.isVisible,
              'quantity': {
                'quantityName': p.quantity.quantityName,
                'quantityUnit': p.quantity.quantityUnit,
                'quantityType': p.quantity.quantityType.name,
              },
              'category': {'categoryName': p.category.categoryName},
              'children': p.children
                  .map(
                    (r) => {
                      'targetParamName': r.targetParamName,
                      'childParamName': r.childParamName,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    });
    archive.addFile(
      ArchiveFile('schema.json', schemaJson.length, utf8.encode(schemaJson)),
    );

    // Create manifest JSON
    final manifestJson = jsonEncode({
      'schemaType': state.manifest.schemaType,
      'schemaVersion': state.manifest.schemaVersion,
      'schemaAuthors': state.manifest.schemaAuthors,
      'lastUpdated': state.manifest.lastUpdated,
      'targetAppName': state.manifest.targetAppName,
      'targetAppSector': state.manifest.targetAppSector,
    });
    archive.addFile(
      ArchiveFile(
        'manifest.json',
        manifestJson.length,
        utf8.encode(manifestJson),
      ),
    );

    // Create adapter code
    archive.addFile(
      ArchiveFile(
        'adapter.js',
        state.adapterCode.length,
        utf8.encode(state.adapterCode),
      ),
    );

    final zipData = encoder.encode(archive);
    final file = File(result);
    await file.writeAsBytes(zipData);
  }
}

final schemaEditorProvider =
    NotifierProvider<SchemaEditorNotifier, SchemaEditorState>(
      SchemaEditorNotifier.new,
    );
