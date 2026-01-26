import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';
import '../../../../helpers/test_models.dart';

void main() {
  group('ProfileEntity', () {
    const application = TestModels.tProfileApplication;

    test('should copy with new values', () {
      const profile = ProfileEntity(
        name: 'Initial Name',
        application: application,
      );

      final updated = profile.copyWith(
        name: 'New Name',
        schema: TestModels.tProfileSchemaManifest,
      );

      expect(updated.name, 'New Name');
      expect(updated.schema, TestModels.tProfileSchemaManifest);
      expect(updated.application, application);
    });

    test('should clear schema when clearSchema is true', () {
      const profile = ProfileEntity(
        name: 'Test Profile',
        application: application,
        schema: TestModels.tProfileSchemaManifest,
      );

      final updated = profile.copyWith(clearSchema: true);

      expect(updated.schema, isNull);
    });
  });
}
