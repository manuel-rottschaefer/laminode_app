import 'package:laminode_app/core/domain/entities/lami_profile.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';

abstract class ProfileEditorRepository {
  Future<LamiProfile<LamiLayerEntry>?> importProfile(String filePath);
  Future<void> exportProfile(
    LamiProfile<LamiLayerEntry> profile,
    String filePath,
  );
}
