import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/core/domain/entities/cam_relation.dart';

void main() {
  group('Relation Entities', () {
    test(
      'CamExpressionRelation should hold targetParamName and expression',
      () {
        final rel = CamExpressionRelation(
          targetParamName: 'target',
          expression: '1 + 1',
        );
        expect(rel.targetParamName, 'target');
        expect(rel.expression, '1 + 1');
      },
    );

    test(
      'CamHierarchyRelation should hold targetParamName and childParamName',
      () {
        final rel = CamHierarchyRelation(
          targetParamName: 'target',
          childParamName: 'child',
        );
        expect(rel.targetParamName, 'target');
        expect(rel.childParamName, 'child');
      },
    );
  });
}
