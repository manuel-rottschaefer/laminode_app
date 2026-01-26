import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_snapshot.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vendor': vendor,
      'version': version,
      if (logoUrl != null) 'logoUrl': logoUrl,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileApplication &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          vendor == other.vendor &&
          version == other.version &&
          logoUrl == other.logoUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      vendor.hashCode ^
      version.hashCode ^
      logoUrl.hashCode;
}

class ProfileSchemaManifest {
  final String id;
  final String version;
  final String updated;
  final String targetAppName;
  final String type; // 'application' or 'sector'

  const ProfileSchemaManifest({
    required this.id,
    required this.version,
    required this.updated,
    required this.targetAppName,
    required this.type,
  });

  factory ProfileSchemaManifest.fromJson(Map<String, dynamic> json) {
    return ProfileSchemaManifest(
      id: json['id'],
      version: json['version'],
      updated: json['updated'],
      targetAppName: json['targetAppName'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'updated': updated,
      'targetAppName': targetAppName,
      'type': type,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileSchemaManifest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          version == other.version &&
          updated == other.updated &&
          targetAppName == other.targetAppName &&
          type == other.type;

  @override
  int get hashCode =>
      id.hashCode ^
      version.hashCode ^
      updated.hashCode ^
      targetAppName.hashCode ^
      type.hashCode;
}

class ProfileEntity {
  final String name;
  final String? description;
  final ProfileApplication application;
  final String? path;
  final ProfileSchemaManifest? schema;
  final List<LamiLayerEntry> layers;
  final GraphSnapshot? graphSnapshot;

  const ProfileEntity({
    required this.name,
    this.description,
    required this.application,
    this.path,
    this.schema,
    this.layers = const [],
    this.graphSnapshot,
  });

  ProfileEntity copyWith({
    String? name,
    String? description,
    ProfileApplication? application,
    String? path,
    ProfileSchemaManifest? schema,
    bool clearSchema = false,
    List<LamiLayerEntry>? layers,
    GraphSnapshot? graphSnapshot,
  }) {
    return ProfileEntity(
      name: name ?? this.name,
      description: description ?? this.description,
      application: application ?? this.application,
      path: path ?? this.path,
      schema: clearSchema ? null : (schema ?? this.schema),
      layers: layers ?? this.layers,
      graphSnapshot: graphSnapshot ?? this.graphSnapshot,
    );
  }
}

class SchemaNotFoundException implements Exception {
  final ProfileSchemaManifest schema;
  SchemaNotFoundException(this.schema);

  @override
  String toString() =>
      'Schema "${schema.id}" (v${schema.version}) for ${schema.targetAppName} not found in local installations.';
}
