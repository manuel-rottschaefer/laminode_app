import 'package:laminode_app/core/domain/entities/lami_profile.dart';

abstract class ProfileEditorRepository {
  Future<LamiProfile?> importProfile(String filePath);
  Future<void> exportProfile(LamiProfile profile, String filePath);
}
