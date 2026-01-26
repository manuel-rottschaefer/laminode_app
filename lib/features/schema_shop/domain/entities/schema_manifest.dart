class SchemaManifest {
  final String schemaType; // 'sector' or 'application'
  final String schemaVersion;
  final List<String> schemaAuthors;
  final String lastUpdated;
  final String? targetAppName;
  final String? targetAppVersion;
  final String? targetAppSector;

  SchemaManifest({
    required this.schemaType,
    required this.schemaVersion,
    required this.schemaAuthors,
    required this.lastUpdated,
    this.targetAppName,
    this.targetAppVersion,
    this.targetAppSector,
  });
}
