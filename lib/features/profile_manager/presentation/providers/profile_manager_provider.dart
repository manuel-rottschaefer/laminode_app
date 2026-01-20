import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/profile_manager/data/repositories/profile_repository_impl.dart';
import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';
import 'package:laminode_app/features/profile_manager/domain/repositories/profile_repository.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';

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
      state = state.copyWith(currentProfile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadProfile(String path) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repository.loadProfile(path);

      if (profile.schemaId != null) {
        final installedIds = _ref.read(schemaShopProvider).installedSchemaIds;
        if (!installedIds.contains(profile.schemaId)) {
          throw SchemaNotFoundException(profile.schemaId!);
        }
      }

      state = state.copyWith(currentProfile: profile, isLoading: false);
    } on SchemaNotFoundException catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void setProfile(ProfileEntity? profile) {
    if (profile == null) {
      state = state.copyWith(clearProfile: true);
    } else {
      state = state.copyWith(currentProfile: profile);
    }
  }

  void setSchema(String? schemaId) {
    if (state.currentProfile != null) {
      state = state.copyWith(
        currentProfile: state.currentProfile!.copyWith(
          schemaId: schemaId,
          clearSchema: schemaId == null,
        ),
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
