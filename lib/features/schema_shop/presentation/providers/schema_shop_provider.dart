import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:laminode_app/core/data/network_client.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/features/schema_shop/data/datasources/schema_shop_local_data_source.dart';
import 'package:laminode_app/features/schema_shop/data/datasources/schema_shop_remote_data_source.dart';
import 'package:laminode_app/features/schema_shop/data/repositories/schema_shop_repository_impl.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:laminode_app/features/schema_shop/domain/repositories/schema_shop_repository.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_state.dart';

export 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_state.dart';
export 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_filtering.dart';

final schemaShopRemoteDataSourceProvider = Provider<SchemaShopRemoteDataSource>(
  (ref) {
    return SchemaShopRemoteDataSourceImpl(ref.watch(dioProvider));
  },
);

final schemaShopLocalDataSourceProvider = Provider<SchemaShopLocalDataSource>((
  ref,
) {
  return SchemaShopLocalDataSourceImpl();
});

final schemaShopRepositoryProvider = Provider<SchemaShopRepository>((ref) {
  return SchemaShopRepositoryImpl(
    ref.watch(schemaShopRemoteDataSourceProvider),
    ref.watch(schemaShopLocalDataSourceProvider),
  );
});

class SchemaShopNotifier extends StateNotifier<SchemaShopState> {
  final SchemaShopRepository _repository;

  SchemaShopNotifier(this._repository) : super(SchemaShopState()) {
    refreshInstalled();
  }

  Future<void> fetchPlugins() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final plugins = await _repository.getAvailablePlugins();
      if (!mounted) return;
      state = state.copyWith(availablePlugins: plugins, isLoading: false);
    } catch (e) {
      if (!mounted) return;
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
    state = state.copyWith(isLoading: true);
    try {
      final plugins = await _repository.getInstalledPlugins();
      final ids = await _repository.getInstalledSchemaIds();
      if (!mounted) return;
      state = state.copyWith(
        installedPlugins: plugins,
        installedSchemaIds: ids,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> installPlugin(PluginManifest plugin, String schemaId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.installPlugin(plugin, schemaId);
      await refreshInstalled();
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (!mounted) return;
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
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> uninstallPlugin(String pluginId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.uninstallPlugin(pluginId);
      await refreshInstalled();
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadSchema(String schemaId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final schema = await _repository.loadInstalledSchema(schemaId);
      if (!mounted) return;
      state = state.copyWith(activeSchema: schema, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearActiveSchema() {
    state = state.copyWith(activeSchema: null);
  }
}

final schemaShopProvider =
    StateNotifierProvider<SchemaShopNotifier, SchemaShopState>((ref) {
      final notifier = SchemaShopNotifier(
        ref.watch(schemaShopRepositoryProvider),
      );

      return notifier;
    });

final installedApplicationsProvider = Provider<List<PluginManifest>>((ref) {
  final shopState = ref.watch(schemaShopProvider);
  return shopState.installedPlugins
      .where((plugin) => plugin.pluginType == 'application')
      .toList();
});

final installedSchemasForAppProvider = Provider.family<List<SchemaRef>, String>(
  (ref, pluginId) {
    final state = ref.watch(schemaShopProvider);
    final plugin = state.installedPlugins.cast<PluginManifest?>().firstWhere(
      (p) => p?.plugin.pluginID == pluginId,
      orElse: () => null,
    );

    if (plugin == null) return [];

    return plugin.schemas
        .where((s) => state.installedSchemaIds.contains(s.id))
        .toList();
  },
);

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
  final activeSchema = ref.watch(
    schemaShopProvider.select((s) => s.activeSchema),
  );
  return activeSchema?.categories ?? [];
});
