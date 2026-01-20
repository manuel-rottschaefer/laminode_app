import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<void> saveProfile(ProfileEntity profile);
  Future<ProfileEntity> loadProfile(String path);
}
