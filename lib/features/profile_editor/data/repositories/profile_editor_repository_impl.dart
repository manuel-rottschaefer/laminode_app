import 'package:laminode_app/core/domain/entities/lami_profile.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/profile_editor/data/datasources/profile_local_data_source.dart';
import 'package:laminode_app/features/profile_editor/data/models/profile_model.dart';
import 'package:laminode_app/features/profile_editor/domain/repositories/profile_editor_repository.dart';

class ProfileEditorRepositoryImpl implements ProfileEditorRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileEditorRepositoryImpl(this.localDataSource);

  @override
  Future<void> exportProfile(
    LamiProfile<LamiLayerEntry> profile,
    String filePath,
  ) async {
    final model = ProfileModel.fromEntity(profile);
    await localDataSource.writeProfileToZip(model, filePath);
  }

  @override
  Future<LamiProfile<LamiLayerEntry>?> importProfile(String filePath) async {
    final model = await localDataSource.readProfileFromZip(filePath);
    return model?.toEntity();
  }
}
