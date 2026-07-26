import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_inventory/inventory_store.dart';
import 'package:home_inventory/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late InventoryStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = InventoryStore(prefs: await SharedPreferences.getInstance());
    await store.load();
  });

  testWidgets('add a category, add an item and change its quantity',
      (tester) async {
    await tester.pumpWidget(HomeInventoryApp(store: store));

    await tester.tap(find.byKey(const Key('add-category-fab')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Bathroom');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Bathroom'), findsOneWidget);

    await tester.tap(find.text('Bathroom'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-item-fab')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('item-name-field')), 'Toilet paper');
    await tester.enterText(find.byKey(const Key('item-quantity-field')), '4');
    await tester.tap(find.byKey(const Key('save-item-button')));
    await tester.pumpAndSettle();

    expect(find.text('Toilet paper'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);

    final itemId = store.items.single.id;
    await tester.tap(find.byKey(Key('increment-$itemId')));
    await tester.pumpAndSettle();
    expect(store.items.single.quantity, 5);

    await tester.tap(find.byKey(Key('decrement-$itemId')));
    await tester.pumpAndSettle();
    expect(store.items.single.quantity, 4);
  });

  testWidgets('low stock banner names the category each item belongs to',
      (tester) async {
    final category = await store.addCategory('Pantry');
    await store.addItem(
        categoryId: category.id,
        name: 'Salt',
        quantity: 1,
        unit: 'boxes',
        lowStockThreshold: 2);
    await tester.pumpWidget(HomeInventoryApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('Salt: 1 boxes — in Pantry'), findsOneWidget);
  });

  test('deleting a category removes its items', () async {
    final category = await store.addCategory('Kitchen');
    await store.addItem(categoryId: category.id, name: 'Rice', quantity: 2);
    await store.deleteCategory(category.id);
    expect(store.categories, isEmpty);
    expect(store.items, isEmpty);
  });

  test('quantity never drops below zero and low stock is flagged', () async {
    final category = await store.addCategory('Pantry');
    final item = await store.addItem(
        categoryId: category.id, name: 'Salt', quantity: 1, lowStockThreshold: 1);
    expect(store.lowStockItems.map((i) => i.id), contains(item.id));
    await store.adjustQuantity(item.id, -5);
    expect(store.items.single.quantity, 0);
  });

  test('data survives a reload', () async {
    final category = await store.addCategory('Cleaning');
    await store.addItem(
        categoryId: category.id, name: 'Detergent', quantity: 3, unit: 'bottles');
    final reloaded = InventoryStore(prefs: await SharedPreferences.getInstance());
    await reloaded.load();
    expect(reloaded.categories.single.name, 'Cleaning');
    expect(reloaded.items.single.unit, 'bottles');
  });
}
