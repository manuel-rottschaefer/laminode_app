import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/profile_manager/data/repositories/profile_repository_impl.dart';
import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';

void main() {
  late ProfileRepositoryImpl repository;
  late Directory tempDir;

  setUp(() async {
    repository = ProfileRepositoryImpl();
    tempDir = await Directory.systemTemp.createTemp('laminode_test');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('ProfileRepositoryImpl', () {
    const application = ProfileApplication(
      id: 'test-id',
      name: 'Test App',
      vendor: 'Test Vendor',
      version: '1.0.0',
    );

    test('should save and load profile correctly', () async {
      final path = '${tempDir.path}/test.lmdp';
      final profile = ProfileEntity(
        name: 'Test Profile',
        description: 'Test Description',
        application: application,
        path: path,
        schemaId: 'test-schema',
      );

      // Save
      await repository.saveProfile(profile);

      final file = File(path);
      expect(file.existsSync(), isTrue);

      // Load
      final loadedProfile = await repository.loadProfile(path);

      expect(loadedProfile.name, profile.name);
      expect(loadedProfile.description, profile.description);
      expect(loadedProfile.schemaId, 'test-schema');
      expect(loadedProfile.application.id, profile.application.id);
      expect(loadedProfile.path, path);
    });

    test('should throw exception when loading non-existent file', () async {
      expect(
        () => repository.loadProfile('${tempDir.path}/non_existent.lmdp'),
        throwsException,
      );
    });
  });
}
