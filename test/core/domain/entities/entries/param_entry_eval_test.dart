import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';

void main() {
  final testCategory = CamCategoryEntry(
    categoryName: 'test',
    categoryTitle: 'Test',
    categoryColorName: 'blue',
  );

  group('CamParamEntry.evalDefault', () {
    test('should return 0 for numeric quantity when default is null', () {
      final param = CamParamEntry(
        paramName: 'test',
        paramTitle: 'Test',
        quantity: const ParamQuantity(
          quantityName: 'n',
          quantityUnit: 'u',
          quantitySymbol: 's',
          quantityType: QuantityType.numeric,
        ),
        category: testCategory,
        value: 10,
      );

      expect(param.evalDefault(), 0);
    });

    test('should return "" for choice quantity when default is null', () {
      final param = CamParamEntry(
        paramName: 'test',
        paramTitle: 'Test',
        quantity: const ParamQuantity(
          quantityName: 'n',
          quantityUnit: 'u',
          quantitySymbol: 's',
          quantityType: QuantityType.choice,
        ),
        category: testCategory,
        value: 'val',
      );

      expect(param.evalDefault(), '');
    });

    test('should return false for boolean quantity when default is null', () {
      final param = CamParamEntry(
        paramName: 'test',
        paramTitle: 'Test',
        quantity: const ParamQuantity(
          quantityName: 'n',
          quantityUnit: 'u',
          quantitySymbol: 's',
          quantityType: QuantityType.boolean,
        ),
        category: testCategory,
        value: true,
      );

      expect(param.evalDefault(), false);
    });
  });
}
