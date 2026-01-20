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

      final updated = profile.copyWith(name: 'New Name', schemaId: 'schema-1');

      expect(updated.name, 'New Name');
      expect(updated.schemaId, 'schema-1');
      expect(updated.application, application);
    });

    test('should clear schemaId when clearSchema is true', () {
      const profile = ProfileEntity(
        name: 'Test Profile',
        application: application,
        schemaId: 'schema-1',
      );

      final updated = profile.copyWith(clearSchema: true);

      expect(updated.schemaId, isNull);
    });
  });
}
