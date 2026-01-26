import 'dart:convert';
import 'dart:io';
import 'package:laminode_app/features/layer_panel/data/models/layer_entry_model.dart';
import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';
import 'package:laminode_app/features/profile_manager/domain/repositories/profile_repository.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_snapshot.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<void> saveProfile(ProfileEntity profile) async {
    if (profile.path == null) throw Exception("Profile path is not set");

    final file = File(profile.path!);
    final data = {
      'name': profile.name,
      'description': profile.description,
      'schema': profile.schema?.toJson(),
      'layers': profile.layers
          .map((l) => LayerEntryModel.fromEntity(l).toJson())
          .toList(),
      'graphSnapshot': profile.graphSnapshot?.toJson(),
      'application': {
        'id': profile.application.id,
        'name': profile.application.name,
        'vendor': profile.application.vendor,
        'version': profile.application.version,
        'logoUrl': profile.application.logoUrl,
      },
    };

    await file.writeAsString(jsonEncode(data));
  }

  @override
  Future<ProfileEntity> loadProfile(String path) async {
    final file = File(path);
    if (!await file.exists()) throw Exception("Profile file does not exist");

    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    final appData = data['application'] as Map<String, dynamic>;

    return ProfileEntity(
      name: data['name'],
      description: data['description'],
      path: path,
      schema: data['schema'] != null
          ? ProfileSchemaManifest.fromJson(data['schema'])
          : null,
      layers:
          (data['layers'] as List<dynamic>?)
              ?.map((l) => LayerEntryModel.fromJson(l).toEntity())
              .toList() ??
          [],
      graphSnapshot: GraphSnapshot.fromJsonNullable(
        data['graphSnapshot'] as Map<String, dynamic>?,
      ),
      application: ProfileApplication(
        id: appData['id'],
        name: appData['name'],
        vendor: appData['vendor'],
        version: appData['version'],
        logoUrl: appData['logoUrl'],
      ),
    );
  }
}
