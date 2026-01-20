import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';

class ProfileApplication {
  final String id;
  final String name;
  final String vendor;
  final String version;
  final String? logoUrl;

  const ProfileApplication({
    required this.id,
    required this.name,
    required this.vendor,
    required this.version,
    this.logoUrl,
  });

  factory ProfileApplication.fromManifest(PluginManifest manifest) {
    return ProfileApplication(
      id: manifest.plugin.pluginID,
      name: manifest.displayName,
      vendor: manifest.application?.vendor ?? "Unknown Vendor",
      version: manifest.plugin.pluginVersion,
      logoUrl: null, // Icon URL not available in manifest yet
    );
  }

  factory ProfileApplication.empty() {
    return const ProfileApplication(
      id: 'generic',
      name: 'Generic App',
      vendor: 'Generic Vendor',
      version: '1.0.0',
    );
  }
}

class ProfileEntity {
  final String name;
  final String? description;
  final ProfileApplication application;
  final String? path;
  final String? schemaId;
  final List<LamiLayerEntry> layers;

  const ProfileEntity({
    required this.name,
    this.description,
    required this.application,
    this.path,
    this.schemaId,
    this.layers = const [],
  });

  ProfileEntity copyWith({
    String? name,
    String? description,
    ProfileApplication? application,
    String? path,
    String? schemaId,
    bool clearSchema = false,
    List<LamiLayerEntry>? layers,
  }) {
    return ProfileEntity(
      name: name ?? this.name,
      description: description ?? this.description,
      application: application ?? this.application,
      path: path ?? this.path,
      schemaId: clearSchema ? null : (schemaId ?? this.schemaId),
      layers: layers ?? this.layers,
    );
  }
}

class SchemaNotFoundException implements Exception {
  final String schemaId;
  SchemaNotFoundException(this.schemaId);

  @override
  String toString() => 'Schema "$schemaId" not found in local installations.';
}
