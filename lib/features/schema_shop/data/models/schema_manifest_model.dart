import 'package:laminode_app/features/schema_shop/domain/entities/schema_manifest.dart';

class SchemaManifestModel extends SchemaManifest {
  SchemaManifestModel({
    required super.schemaType,
    required super.schemaVersion,
    required super.schemaAuthors,
    required super.lastUpdated,
    super.targetAppName,
    super.targetAppVersion,
    super.targetAppSector,
  });

  factory SchemaManifestModel.fromJson(Map<String, dynamic> json) {
    return SchemaManifestModel(
      schemaType: json['schemaType'] ?? 'application',
      schemaVersion: json['schemaVersion'],
      schemaAuthors: List<String>.from(json['schemaAuthors']),
      lastUpdated: json['lastUpdated'],
      targetAppName: json['targetAppName'],
      targetAppVersion: json['targetAppVersion'],
      targetAppSector: json['targetAppSector'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaType': schemaType,
      'schemaVersion': schemaVersion,
      'schemaAuthors': schemaAuthors,
      'lastUpdated': lastUpdated,
      if (targetAppName != null) 'targetAppName': targetAppName,
      if (targetAppVersion != null) 'targetAppVersion': targetAppVersion,
      if (targetAppSector != null) 'targetAppSector': targetAppSector,
    };
  }
}
