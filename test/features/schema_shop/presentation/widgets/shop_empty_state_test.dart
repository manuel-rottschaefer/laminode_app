import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/widgets/shop_empty_state.dart';

void main() {
  testWidgets('ShopEmptyState should display message and icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShopEmptyState(
            isSearch: true,
            state: SchemaShopState(),
            onRetry: () {},
          ),
        ),
      ),
    );

    expect(find.text('No matching plugins found'), findsOneWidget);
    expect(find.byType(Icon), findsNWidgets(1));
  });
}
