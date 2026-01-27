import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/profile_manager/data/repositories/profile_repository_impl.dart';
import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';
import 'package:laminode_app/features/profile_manager/domain/repositories/profile_repository.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';

import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/profile_graph/application/providers/graph_providers.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

class ProfileManagerState {
  final ProfileEntity? currentProfile;
  final bool isLoading;
  final String? error;

  ProfileManagerState({
    this.currentProfile,
    this.isLoading = false,
    this.error,
  });

  ProfileManagerState copyWith({
    ProfileEntity? currentProfile,
    bool? isLoading,
    String? error,
    bool clearProfile = false,
  }) {
    return ProfileManagerState(
      currentProfile: clearProfile
          ? null
          : (currentProfile ?? this.currentProfile),
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProfileManagerNotifier extends StateNotifier<ProfileManagerState> {
  final ProfileRepository _repository;
  final Ref _ref;

  ProfileManagerNotifier(this._repository, this._ref)
    : super(ProfileManagerState());

  Future<void> createProfile(ProfileEntity profile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.saveProfile(profile);
      await setProfile(profile);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadProfile(String path) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repository.loadProfile(path);

      if (profile.schema != null) {
        final repo = _ref.read(schemaShopRepositoryProvider);
        final installedPlugins = await repo.getInstalledPlugins();

        bool found = false;
        for (final plugin in installedPlugins) {
          for (final schemaRef in plugin.schemas) {
            if (schemaRef.id == profile.schema!.id &&
                schemaRef.version == profile.schema!.version &&
                schemaRef.releaseDate == profile.schema!.updated &&
                plugin.displayName == profile.schema!.targetAppName &&
                plugin.pluginType == profile.schema!.type) {
              found = true;
              break;
            }
          }
          if (found) break;
        }

        if (!found) {
          throw SchemaNotFoundException(profile.schema!);
        }
      }

      await setProfile(profile);
      state = state.copyWith(isLoading: false);
    } on SchemaNotFoundException catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> setProfile(ProfileEntity? profile) async {
    if (profile == null) {
      state = state.copyWith(clearProfile: true);
      _ref.read(schemaShopProvider.notifier).clearActiveSchema();
      _ref.read(layerPanelProvider.notifier).setLayers([]);
    } else {
      state = state.copyWith(currentProfile: profile);
      // Ensure schema is loaded when profile is set
      if (profile.schema != null) {
        await _ref
            .read(schemaShopProvider.notifier)
            .loadSchema(profile.schema!.id);
      } else {
        _ref.read(schemaShopProvider.notifier).clearActiveSchema();
      }

      // Explicitly push layers to the layer panel
      _ref.read(layerPanelProvider.notifier).setLayers(profile.layers);

      // Apply graph snapshot if available
      if (profile.graphSnapshot != null) {
        _ref
            .read(profileGraphControllerProvider)
            .applySnapshot(profile.graphSnapshot!);
      }
    }
  }

  Future<void> saveCurrentProfile() async {
    if (state.currentProfile != null) {
      state = state.copyWith(isLoading: true, error: null);
      try {
        // Capture graph snapshot before saving
        final snapshot = _ref
            .read(profileGraphControllerProvider)
            .getSnapshot();
        final profileToSave = state.currentProfile!.copyWith(
          graphSnapshot: snapshot,
        );

        await _repository.saveProfile(profileToSave);
        state = state.copyWith(currentProfile: profileToSave, isLoading: false);
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  void setSchema(ProfileSchemaManifest? schema) {
    if (state.currentProfile != null) {
      state = state.copyWith(
        currentProfile: state.currentProfile!.copyWith(
          schema: schema,
          clearSchema: schema == null,
        ),
      );

      // Automatic assignment of the schema as the session active schema
      if (schema != null) {
        _ref.read(schemaShopProvider.notifier).loadSchema(schema.id);
      } else {
        _ref.read(schemaShopProvider.notifier).clearActiveSchema();
      }
    }
  }

  void updateLayers(List<LamiLayerEntry> layers) {
    if (state.currentProfile != null) {
      state = state.copyWith(
        currentProfile: state.currentProfile!.copyWith(layers: layers),
      );
    }
  }

  void updateProfileName(String name) {
    if (state.currentProfile != null) {
      state = state.copyWith(
        currentProfile: state.currentProfile!.copyWith(name: name),
      );
    }
  }

  void setApplication(ProfileApplication application) {
    if (state.currentProfile != null) {
      state = state.copyWith(
        currentProfile: state.currentProfile!.copyWith(
          application: application,
        ),
      );
    }
  }
}

final profileManagerProvider =
    StateNotifierProvider<ProfileManagerNotifier, ProfileManagerState>((ref) {
      final repository = ref.watch(profileRepositoryProvider);
      return ProfileManagerNotifier(repository, ref);
    });
