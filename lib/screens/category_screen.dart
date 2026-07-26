import 'package:flutter/material.dart';

import '../main.dart';
import '../models.dart';
import '../widgets/item_editor_sheet.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final store = InventoryScope.of(context);
    final category = store.categoryById(categoryId);
    if (category == null) {
      return const Scaffold(body: Center(child: Text('Category not found')));
    }
    final items = store.itemsInCategory(categoryId);

    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-item-fab'),
        onPressed: () => showItemEditor(context, categoryId: categoryId),
        icon: const Icon(Icons.add),
        label: const Text('Item'),
      ),
      body: items.isEmpty
          ? const Center(child: Text('No items yet. Tap "Item" to add one.'))
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) => _ItemTile(item: items[index]),
            ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final store = InventoryScope.of(context);
    final quantityLabel =
        '${formatQuantity(item.quantity)}${item.unit.isEmpty ? '' : ' ${item.unit}'}';

    return Dismissible(
      key: Key('item-${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => store.deleteItem(item.id),
      child: ListTile(
        title: Text(item.name),
        subtitle: Row(
          children: [
            Text(quantityLabel),
            if (item.isLowStock) ...[
              const SizedBox(width: 8),
              Icon(Icons.warning_amber_rounded,
                  size: 16, color: Theme.of(context).colorScheme.error),
              Text(' low',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: Key('decrement-${item.id}'),
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => store.adjustQuantity(item.id, -1),
            ),
            IconButton(
              key: Key('increment-${item.id}'),
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => store.adjustQuantity(item.id, 1),
            ),
          ],
        ),
        onTap: () => showItemEditor(context, categoryId: item.categoryId, item: item),
      ),
    );
  }
}
