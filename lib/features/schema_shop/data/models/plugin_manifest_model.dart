import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';

class PluginManifestModel extends PluginManifest {
  PluginManifestModel({
    required super.pluginType,
    required super.displayName,
    required super.description,
    super.application,
    required super.plugin,
    required super.schemas,
  });

  factory PluginManifestModel.fromJson(Map<String, dynamic> json) {
    return PluginManifestModel(
      pluginType: json['pluginType'],
      displayName: json['displayName'],
      description: json['description'],
      application: json['application'] != null
          ? ApplicationInfoModel.fromJson(json['application'])
          : null,
      plugin: PluginInfoModel.fromJson(json['plugin']),
      schemas: (json['schemas'] as List<dynamic>)
          .map((e) => SchemaRefModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pluginType': pluginType,
      'displayName': displayName,
      'description': description,
      if (application != null)
        'application': (application as ApplicationInfoModel).toJson(),
      'plugin': (plugin as PluginInfoModel).toJson(),
      'schemas': schemas.map((e) => (e as SchemaRefModel).toJson()).toList(),
    };
  }
}

class SchemaRefModel extends SchemaRef {
  SchemaRefModel({
    required super.id,
    required super.version,
    required super.releaseDate,
  });

  factory SchemaRefModel.fromJson(Map<String, dynamic> json) {
    return SchemaRefModel(
      id: json['id'],
      version: json['version'],
      releaseDate: json['releaseDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'version': version, 'releaseDate': releaseDate};
  }
}

class ApplicationInfoModel extends ApplicationInfo {
  ApplicationInfoModel({
    required super.appName,
    required super.appVersion,
    required super.vendor,
    required super.website,
    required super.sector,
  });

  factory ApplicationInfoModel.fromJson(Map<String, dynamic> json) {
    return ApplicationInfoModel(
      appName: json['appName'],
      appVersion: json['appVersion'],
      vendor: json['vendor'],
      website: json['website'],
      sector: json['sector'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'vendor': vendor,
      'website': website,
      'sector': sector,
    };
  }
}

class PluginInfoModel extends PluginInfo {
  PluginInfoModel({
    required super.pluginID,
    required super.pluginVersion,
    required super.pluginAuthor,
    required super.publishedDate,
    super.targetAppVersionRange,
    required super.sector,
    super.fileTypes,
  });

  factory PluginInfoModel.fromJson(Map<String, dynamic> json) {
    return PluginInfoModel(
      pluginID: json['pluginID'],
      pluginVersion: json['pluginVersion'],
      pluginAuthor: json['pluginAuthor'],
      publishedDate: json['publishedDate'],
      targetAppVersionRange: json['targetAppVersionRange'] != null
          ? TargetAppVersionRangeModel.fromJson(json['targetAppVersionRange'])
          : null,
      sector: json['sector'],
      fileTypes: json['fileTypes'] != null
          ? FileTypesModel.fromJson(json['fileTypes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pluginID': pluginID,
      'pluginVersion': pluginVersion,
      'pluginAuthor': pluginAuthor,
      'publishedDate': publishedDate,
      if (targetAppVersionRange != null)
        'targetAppVersionRange':
            (targetAppVersionRange as TargetAppVersionRangeModel).toJson(),
      'sector': sector,
      if (fileTypes != null)
        'fileTypes': (fileTypes as FileTypesModel).toJson(),
    };
  }
}

class TargetAppVersionRangeModel extends TargetAppVersionRange {
  TargetAppVersionRangeModel({
    required super.minVersion,
    required super.maxVersion,
  });

  factory TargetAppVersionRangeModel.fromJson(Map<String, dynamic> json) {
    return TargetAppVersionRangeModel(
      minVersion: json['minVersion'],
      maxVersion: json['maxVersion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'minVersion': minVersion, 'maxVersion': maxVersion};
  }
}

class FileTypesModel extends FileTypes {
  FileTypesModel({
    required super.profileImportBucket,
    required super.gcodeExportBucket,
  });

  factory FileTypesModel.fromJson(Map<String, dynamic> json) {
    return FileTypesModel(
      profileImportBucket: json['profileImportBucket'],
      gcodeExportBucket: json['gcodeExportBucket'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileImportBucket': profileImportBucket,
      'gcodeExportBucket': gcodeExportBucket,
    };
  }
}
