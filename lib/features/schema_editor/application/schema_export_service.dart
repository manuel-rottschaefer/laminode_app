import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:laminode_app/core/services/graph_debug_service.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_state.dart';
import 'package:laminode_app/features/schema_editor/data/models/cam_schema_entry_model.dart';
import 'package:laminode_app/features/schema_shop/data/models/schema_manifest_model.dart';

class SchemaExportService {
  static Map<String, dynamic> schemaToRawJson(SchemaEditorState state) {
    final manifestModel = SchemaManifestModel(
      schemaType: state.manifest.schemaType,
      schemaVersion: state.manifest.schemaVersion,
      schemaAuthors: state.manifest.schemaAuthors,
      lastUpdated: DateTime.now().toIso8601String(),
      targetAppName: state.manifest.targetAppName,
      targetAppVersion: state.manifest.targetAppVersion,
      targetAppSector: state.manifest.targetAppSector,
    );

    final schemaModel = CamSchemaEntryModel.fromEntity(state.schema);
    final schemaJson = schemaModel.toJson();

    return {'manifest': manifestModel.toJson(), ...schemaJson};
  }

  static Future<void> exportSchemaBundle(SchemaEditorState state) async {
    GraphDebugService.talker.info('Starting schema export bundle...');

    try {
      final appName = state.manifest.targetAppName ?? "Unknown App";
      final schemaId = state.manifest.schemaVersion;
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Schema Bundle',
        fileName: '${appName.replaceAll(' ', '_')}_$schemaId.zip',
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null) {
        GraphDebugService.talker.info('Schema export cancelled by user.');
        return;
      }

      final archive = Archive();
      final schemaJsonData = schemaToRawJson(state);
      final schemaJson = jsonEncode(schemaJsonData);
      final schemaBytes = utf8.encode(schemaJson);

      // Add schema to bundle structure: schemas/<id>.json
      archive.addFile(
        ArchiveFile('schemas/$schemaId.json', schemaBytes.length, schemaBytes),
      );

      // Add adapter code
      final adapterBytes = utf8.encode(state.adapterCode);
      archive.addFile(
        ArchiveFile('adapter.js', adapterBytes.length, adapterBytes),
      );

      // Create a basic plugin manifest for the bundle
      final appVersion = state.manifest.targetAppVersion ?? "1.0";
      final pluginId = appName.replaceAll(' ', '_').toLowerCase();
      final pluginManifest = {
        'pluginType': 'application',
        'displayName': appName,
        'description': 'Exported schema for $appName',
        'application': {
          'appName': appName,
          'appVersion': appVersion,
          'vendor': 'Laminode Editor',
          'website': '',
          'sector': state.manifest.targetAppSector ?? 'FDM',
        },
        'plugin': {
          'pluginID': pluginId,
          'pluginVersion': '1.0',
          'pluginAuthor': state.manifest.schemaAuthors.join(', '),
          'publishedDate': DateTime.now().toIso8601String().split('T')[0],
          'sector': state.manifest.targetAppSector ?? 'FDM',
        },
        'schemas': [
          {
            'id': schemaId,
            'version': schemaId.startsWith('v')
                ? schemaId.substring(1)
                : schemaId,
            'releaseDate': DateTime.now().toIso8601String().split('T')[0],
          },
        ],
      };

      final manifestBytes = utf8.encode(jsonEncode(pluginManifest));
      archive.addFile(
        ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
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
