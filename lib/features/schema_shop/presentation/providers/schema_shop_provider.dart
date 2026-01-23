import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:laminode_app/core/data/network_client.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/features/schema_shop/data/datasources/schema_shop_local_data_source.dart';
import 'package:laminode_app/features/schema_shop/data/datasources/schema_shop_remote_data_source.dart';
import 'package:laminode_app/features/schema_shop/data/repositories/schema_shop_repository_impl.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:laminode_app/features/schema_shop/domain/repositories/schema_shop_repository.dart';
import 'package:laminode_app/core/utils/version_utils.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';

final schemaShopRemoteDataSourceProvider = Provider<SchemaShopRemoteDataSource>((ref) {
  return SchemaShopRemoteDataSourceImpl(ref.watch(dioProvider));
});

final schemaShopLocalDataSourceProvider = Provider<SchemaShopLocalDataSource>((ref) {
  return SchemaShopLocalDataSourceImpl();
});

final schemaShopRepositoryProvider = Provider<SchemaShopRepository>((ref) {
  return SchemaShopRepositoryImpl(
    ref.watch(schemaShopRemoteDataSourceProvider),
    ref.watch(schemaShopLocalDataSourceProvider),
  );
});

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
  bool get hasConnectionError => error?.contains("internet connection") ?? false;
  bool get isEmpty => availablePlugins.isEmpty;
  bool get hasError => error != null;
}

class SchemaShopNotifier extends StateNotifier<SchemaShopState> {
  final SchemaShopRepository _repository;

  SchemaShopNotifier(this._repository) : super(SchemaShopState()) {
    refreshInstalled();
  }

  Future<void> fetchPlugins() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final plugins = await _repository.getAvailablePlugins();
      state = state.copyWith(availablePlugins: plugins, isLoading: false);
    } catch (e) {
      String errorMessage = e.toString();
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError) {
          errorMessage = "Please check your internet connection";
        }
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> refreshInstalled() async {
    try {
      final plugins = await _repository.getInstalledPlugins();
      final ids = await _repository.getInstalledSchemaIds();
      state = state.copyWith(installedPlugins: plugins, installedSchemaIds: ids);
    } catch (_) {}
  }

  Future<void> installPlugin(PluginManifest plugin, String schemaId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.installPlugin(plugin, schemaId);
      await refreshInstalled();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      String errorMessage = e.toString();
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError) {
          errorMessage = "Please check your internet connection";
        }
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> installManualSchema(File file) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.installManualSchema(file);
      await refreshInstalled();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> uninstallPlugin(String pluginId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.uninstallPlugin(pluginId);
      await refreshInstalled();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadSchema(String schemaId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final schema = await _repository.loadInstalledSchema(schemaId);
      state = state.copyWith(activeSchema: schema, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearActiveSchema() {
    state = state.copyWith(activeSchema: null);
  }
}

final schemaShopProvider = StateNotifierProvider<SchemaShopNotifier, SchemaShopState>((ref) {
  final notifier = SchemaShopNotifier(ref.watch(schemaShopRepositoryProvider));

  // Synchronize active schema with profile selection
  ref.listen(profileManagerProvider.select((s) => s.currentProfile?.schemaId), (previous, next) {
    if (next != null) {
      notifier.loadSchema(next);
    } else {
      // Reset action
      notifier.clearActiveSchema();
    }
  });

  return notifier;
});

final installedApplicationsProvider = Provider<List<PluginManifest>>((ref) {
  final shopState = ref.watch(schemaShopProvider);
  return shopState.installedPlugins.where((plugin) => plugin.pluginType == 'application').toList();
});

final installedSchemasForAppProvider = Provider.family<List<SchemaRef>, String>((ref, pluginId) {
  final state = ref.watch(schemaShopProvider);
  final plugin = state.installedPlugins.cast<PluginManifest?>().firstWhere(
    (p) => p?.plugin.pluginID == pluginId,
    orElse: () => null,
  );

  if (plugin == null) return [];

  return plugin.schemas.where((s) => state.installedSchemaIds.contains(s.id)).toList();
});

final schemaByIdProvider = Provider.family<SchemaRef?, String>((ref, schemaId) {
  final state = ref.watch(schemaShopProvider);
  for (final plugin in state.installedPlugins) {
    for (final schema in plugin.schemas) {
      if (schema.id == schemaId) return schema;
    }
  }
  return null;
});

final activeSchemaCategoriesProvider = Provider<List<CamCategoryEntry>>((ref) {
  final activeSchema = ref.watch(schemaShopProvider.select((s) => s.activeSchema));
  return activeSchema?.categories ?? [];
});

final filteredAndGroupedPluginsProvider = Provider.family<List<dynamic>, String>((ref, query) {
  final state = ref.watch(schemaShopProvider);
  final plugins = state.availablePlugins;

  final filtered = plugins.where((p) {
    final lowerQuery = query.toLowerCase();
    return p.displayName.toLowerCase().contains(lowerQuery) ||
        p.description.toLowerCase().contains(lowerQuery) ||
        p.plugin.pluginAuthor.toLowerCase().contains(lowerQuery) ||
        (p.application?.vendor.toLowerCase().contains(lowerQuery) ?? false) ||
        (p.application?.appName.toLowerCase().contains(lowerQuery) ?? false);
  }).toList();

  final List<PluginManifest> sectors = filtered.where((p) => p.pluginType == 'sector').toList();
  final List<PluginManifest> apps = filtered.where((p) => p.pluginType == 'application').toList();

  final Map<String, List<PluginManifest>> groupedApps = {};
  for (final app in apps) {
    if (app.application == null) continue;
    final key = "${app.application!.appName}_${app.application!.vendor}";
    groupedApps.putIfAbsent(key, () => []).add(app);
  }

  final List<ApplicationGroup> appGroups = groupedApps.values.map((versions) {
    final Map<String, PluginManifest> latestByAppVer = {};
    for (final v in versions) {
      final appVer = v.application!.appVersion;
      if (!latestByAppVer.containsKey(appVer)) {
        latestByAppVer[appVer] = v;
      } else {
        if (compareVersions(v.plugin.pluginVersion, latestByAppVer[appVer]!.plugin.pluginVersion) > 0) {
          latestByAppVer[appVer] = v;
        }
      }
    }

    final sortedVersions = latestByAppVer.values.toList()
      ..sort((a, b) => compareVersions(b.application!.appVersion, a.application!.appVersion));

    return ApplicationGroup(
      appName: sortedVersions.first.application!.appName,
      vendor: sortedVersions.first.application!.vendor,
      sector: sortedVersions.first.application!.sector,
      appVersions: sortedVersions,
    );
  }).toList();

  return [...appGroups, ...sectors];
});
