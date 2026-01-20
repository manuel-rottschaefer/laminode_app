class PluginManifest {
  final String pluginType; // 'application' or 'sector'
  final String displayName;
  final String description;
  final ApplicationInfo? application;
  final PluginInfo plugin;
  final List<SchemaRef> schemas;

  PluginManifest({
    required this.pluginType,
    required this.displayName,
    required this.description,
    this.application,
    required this.plugin,
    required this.schemas,
  });

  bool get isBasePlugin => pluginType == 'sector';
}

class ApplicationGroup {
  final String appName;
  final String vendor;
  final String sector;
  final List<PluginManifest> appVersions;

  ApplicationGroup({
    required this.appName,
    required this.vendor,
    required this.sector,
    required this.appVersions,
  });
}

class SchemaRef {
  final String id;
  final String version;
  final String releaseDate;

  SchemaRef({
    required this.id,
    required this.version,
    required this.releaseDate,
  });
}

class ApplicationInfo {
  final String appName;
  final String appVersion;
  final String vendor;
  final String website;
  final String sector;

  ApplicationInfo({
    required this.appName,
    required this.appVersion,
    required this.vendor,
    required this.website,
    required this.sector,
  });
}

class PluginInfo {
  final String pluginID;
  final String pluginVersion;
  final String pluginAuthor;
  final String publishedDate;
  final TargetAppVersionRange? targetAppVersionRange;
  final String sector;
  final FileTypes? fileTypes;

  PluginInfo({
    required this.pluginID,
    required this.pluginVersion,
    required this.pluginAuthor,
    required this.publishedDate,
    this.targetAppVersionRange,
    required this.sector,
    this.fileTypes,
  });
}

class TargetAppVersionRange {
  final String minVersion;
  final String maxVersion;

  TargetAppVersionRange({required this.minVersion, required this.maxVersion});
}

class FileTypes {
  final String profileImportBucket;
  final String gcodeExportBucket;

  FileTypes({
    required this.profileImportBucket,
    required this.gcodeExportBucket,
  });
}
