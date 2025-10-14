import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/shopping_cart.dart';

void main() {
  group('Shopping Cart Operations Tests', () {
    testWidgets('Adding item increases count and updates total', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      expect(find.text('Cart is empty'), findsNothing);
      expect(find.text('Total Items: 1'), findsOneWidget);
      expect(find.text('Apple iPhone'), findsOneWidget);
      expect(find.text('Subtotal: \$999.99'), findsOneWidget);
    });

    testWidgets('Adding same item twice increments quantity', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add iPhone Again'));
      await tester.pump();

      expect(find.text('Total Items: 2'), findsOneWidget);
    });

    testWidgets('Adding different items creates separate entries', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add Galaxy'));
      await tester.pump();

      expect(find.text('Total Items: 2'), findsOneWidget);
      expect(find.text('Apple iPhone'), findsOneWidget);
      expect(find.text('Samsung Galaxy'), findsOneWidget);
    });

    testWidgets('Remove button deletes item from cart', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      expect(find.text('Apple iPhone'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(find.text('Cart is empty'), findsOneWidget);
    });

    testWidgets('Decrementing quantity updates count', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add iPhone Again'));
      await tester.pump();

      expect(find.text('Total Items: 2'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('Total Items: 1'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Clear cart empties all items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add Galaxy'));
      await tester.pump();
      await tester.tap(find.text('Add iPad'));
      await tester.pump();

      expect(find.text('Total Items: 3'), findsOneWidget);

      await tester.tap(find.text('Clear Cart'));
      await tester.pump();

      expect(find.text('Cart is empty'), findsOneWidget);
      expect(find.text('Total Items: 0'), findsOneWidget);
    });
  });

  group('Shopping Cart Calculation Tests', () {
    testWidgets('Subtotal calculates correctly without discount', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPad'));
      await tester.pump();

      expect(find.text('Subtotal: \$1099.99'), findsOneWidget);
      expect(find.text('Total Discount: \$0.00'), findsOneWidget);
      expect(find.text('Total Amount: \$1099.99'), findsOneWidget);
    });

    testWidgets('Discount calculates correctly (10% on iPhone)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      // Subtotal: 999.99
      // Discount: 999.99 * 0.1 = 99.999 ≈ 100.00
      // Total: 999.99 - 100.00 = 899.99
      expect(find.text('Subtotal: \$999.99'), findsOneWidget);
      expect(find.text('Total Discount: \$100.00'), findsOneWidget);
      expect(find.text('Total Amount: \$899.99'), findsOneWidget);
    });

    testWidgets('Multiple items with different discounts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      // Add iPhone (10% discount) and Galaxy (15% discount)
      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add Galaxy'));
      await tester.pump();

      // iPhone: 999.99, discount: 100.00
      // Galaxy: 899.99, discount: 135.00
      // Subtotal: 1899.98
      // Total Discount: 235.00 (approximately)
      // Total: 1664.98
      expect(find.text('Subtotal: \$1899.98'), findsOneWidget);
      expect(find.text('Total Discount: \$235.00'), findsOneWidget);
      expect(find.text('Total Amount: \$1664.98'), findsOneWidget);
    });
  });

  group('Shopping Cart Edge Cases Tests', () {
    testWidgets('Empty cart shows correct initial state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      expect(find.text('Cart is empty'), findsOneWidget);
      expect(find.text('Total Items: 0'), findsOneWidget);
      expect(find.text('Subtotal: \$0.00'), findsOneWidget);
      expect(find.text('Total Discount: \$0.00'), findsOneWidget);
      expect(find.text('Total Amount: \$0.00'), findsOneWidget);
    });

    testWidgets('Item with no discount calculates correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShoppingCart())),
      );

      await tester.tap(find.text('Add iPad'));
      await tester.pump();

      expect(find.text('Discount:'), findsNothing);
      expect(find.text('Total Discount: \$0.00'), findsOneWidget);
      expect(find.text('Total Amount: \$1099.99'), findsOneWidget);
    });
  });
}
