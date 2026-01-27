import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_state.dart';

void main() {
  group('SchemaShopState', () {
    test('copyWith should return updated state', () {
      final state = SchemaShopState(isLoading: false);
      final updated = state.copyWith(isLoading: true, error: 'error');

      expect(updated.isLoading, true);
      expect(updated.error, 'error');
    });

    test('hasError should return true when error is present', () {
      final state = SchemaShopState(error: 'Some error');
      expect(state.hasError, true);
    });

    test('isEmpty should return true when availablePlugins is empty', () {
      final state = SchemaShopState(availablePlugins: []);
      expect(state.isEmpty, true);
    });
  });
}
