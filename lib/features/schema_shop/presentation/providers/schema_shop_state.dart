import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';

class SchemaShopState {
  final List<PluginManifest> availablePlugins;
  final List<PluginManifest> installedPlugins;
  final List<String> installedSchemaIds;
  final CamSchemaEntry? activeSchema;
  final bool isLoading;
  final String? error;

  SchemaShopState({
    this.availablePlugins = const [],
    this.installedPlugins = const [],
    this.installedSchemaIds = const [],
    this.activeSchema,
    this.isLoading = false,
    this.error,
  });

  SchemaShopState copyWith({
    List<PluginManifest>? availablePlugins,
    List<PluginManifest>? installedPlugins,
    List<String>? installedSchemaIds,
    CamSchemaEntry? activeSchema,
    bool? isLoading,
    String? error,
  }) {
    return SchemaShopState(
      availablePlugins: availablePlugins ?? this.availablePlugins,
      installedPlugins: installedPlugins ?? this.installedPlugins,
      installedSchemaIds: installedSchemaIds ?? this.installedSchemaIds,
      activeSchema: activeSchema ?? this.activeSchema,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

extension SchemaShopStateX on SchemaShopState {
  bool get hasConnectionError =>
      error?.contains("internet connection") ?? false;
  bool get isEmpty => availablePlugins.isEmpty;
  bool get hasError => error != null;
}
