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
import 'package:laminode_app/core/services/graph_debug_service.dart';
import 'package:laminode_app/features/schema_editor/data/models/cam_schema_entry_model.dart';
import 'package:laminode_app/features/schema_shop/data/models/schema_manifest_model.dart';

import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';

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

  Future<void> validate() async {
    final appName = state.manifest.targetAppName;
    final version = state.manifest.schemaVersion;

    if (appName == null || appName.isEmpty) {
      state = state.copyWith(appExists: false, isChecking: false);
      return;
    }

    state = state.copyWith(isChecking: true);

    try {
      final repo = ref.read(schemaShopRepositoryProvider);
      final appExists = await repo.applicationExists(appName);
      final versionExists = await repo.schemaExists(version);

      state = state.copyWith(
        appExists: appExists,
        versionExists: versionExists,
        isChecking: false,
      );
    } catch (e) {
      GraphDebugService.talker.error('Validation error: $e');
      state = state.copyWith(isChecking: false);
    }
  }

  void loadSchema(
    CamSchemaEntry schema,
    SchemaManifest manifest, {
    String? adapterCode,
  }) {
    GraphDebugService.talker.info('Loading schema: ${schema.schemaName}');
    state = state.copyWith(
      schema: schema,
      manifest: manifest,
      adapterCode: adapterCode ?? state.adapterCode,
      viewMode: SchemaEditorViewMode.schema,
      clearSelectedParameter: true,
      clearSelectedCategory: true,
    );
    validate();
  }

  void updateManifest({
    String? schemaVersion,
    List<String>? schemaAuthors,
    String? targetAppName,
    String? targetAppSector,
  }) {
    final current = state.manifest;
    GraphDebugService.talker.debug('Updating schema manifest');
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
      GraphDebugService.talker.debug(
        'Syncing schema name with target app name: $targetAppName',
      );
      state = state.copyWith(
        schema: CamSchemaEntry(
          schemaName: targetAppName,
          categories: state.schema.categories,
          availableParameters: state.schema.availableParameters,
        ),
      );
    }
    validate();
  }

  void setViewMode(SchemaEditorViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void updateAdapterCode(String code) {
    GraphDebugService.talker.debug(
      'Updating adapter code (${code.length} chars)',
    );
    state = state.copyWith(adapterCode: code);
  }

  Future<void> saveSchema() async {
    if (!state.canSave) {
      throw Exception('Saving is not allowed in current state');
    }

    final repo = ref.read(schemaShopRepositoryProvider);
    final schemaJson = _schemaToRawJson(state);
    final appName = state.manifest.targetAppName!;
    final schemaId = state.manifest.schemaVersion;

    await repo.saveSchema(appName, schemaId, schemaJson, state.adapterCode);
    ref.invalidate(schemaShopProvider);
    validate(); // Refresh version check
  }

  Future<void> saveAndUseSchema() async {
    await saveSchema();
    final schemaId = state.manifest.schemaVersion;
    ref.read(profileManagerProvider.notifier).setSchema(schemaId);
  }

  Map<String, dynamic> _schemaToRawJson(SchemaEditorState state) {
    final manifestModel = SchemaManifestModel(
      schemaType: state.manifest.schemaType,
      schemaVersion: state.manifest.schemaVersion,
      schemaAuthors: state.manifest.schemaAuthors,
      lastUpdated: DateTime.now().toIso8601String(),
      targetAppName: state.manifest.targetAppName,
      targetAppSector: state.manifest.targetAppSector,
    );

    return {
      'manifest': manifestModel.toJson(),
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
                'quantitySymbol': p.quantity.quantitySymbol,
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
    };
  }

  Future<void> exportSchema() async {
    GraphDebugService.talker.info('Starting schema export bundle...');

    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Schema Bundle',
        fileName: '${state.schema.schemaName.replaceAll(' ', '_')}.zip',
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null) {
        GraphDebugService.talker.info('Schema export cancelled by user.');
        return;
      }

      final archive = Archive();

      // Create schema JSON using model
      final schemaModel = CamSchemaEntryModel.fromEntity(state.schema);
      final schemaJson = jsonEncode(schemaModel.toJson());
      final schemaBytes = utf8.encode(schemaJson);
      archive.addFile(
        ArchiveFile('schema.json', schemaBytes.length, schemaBytes),
      );

      // Create manifest JSON using model
      final manifestModel = SchemaManifestModel(
        schemaType: state.manifest.schemaType,
        schemaVersion: state.manifest.schemaVersion,
        schemaAuthors: state.manifest.schemaAuthors,
        lastUpdated: state.manifest.lastUpdated,
        targetAppName: state.manifest.targetAppName,
        targetAppSector: state.manifest.targetAppSector,
      );
      final manifestJson = jsonEncode(manifestModel.toJson());
      final manifestBytes = utf8.encode(manifestJson);
      archive.addFile(
        ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
      );

      // Create adapter code
      final adapterBytes = utf8.encode(state.adapterCode);
      archive.addFile(
        ArchiveFile('adapter.js', adapterBytes.length, adapterBytes),
      );

      GraphDebugService.talker.debug(
        'Archive created with ${archive.length} files. Encoding to ZIP...',
      );

      final zipData = ZipEncoder().encode(archive);

      final file = File(result);
      await file.writeAsBytes(zipData, flush: true);

      GraphDebugService.talker.info(
        'Schema bundle exported successfully to $result (${zipData.length} bytes)',
      );
    } catch (e, st) {
      GraphDebugService.talker.handle(e, st, 'Error exporting schema bundle');
    }
  }
}

final schemaEditorProvider =
    NotifierProvider<SchemaEditorNotifier, SchemaEditorState>(
      SchemaEditorNotifier.new,
    );
