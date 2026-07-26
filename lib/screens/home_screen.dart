import 'package:flutter/material.dart';

import '../main.dart';
import '../models.dart';
import '../widgets/text_prompt_dialog.dart';
import 'category_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = InventoryScope.of(context);
    final categories = store.categories;
    final lowStock = store.lowStockItems;

    return Scaffold(
      appBar: AppBar(title: const Text('Home Inventory')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-category-fab'),
        onPressed: () async {
          final name = await promptForText(
            context,
            title: 'New category',
            label: 'Category name',
          );
          if (name != null && name.isNotEmpty) {
            await store.addCategory(name);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Category'),
      ),
      body: categories.isEmpty
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                if (lowStock.isNotEmpty) _LowStockBanner(items: lowStock),
                for (final category in categories)
                  _CategoryTile(
                    category: category,
                    itemCount: store.itemsInCategory(category.id).length,
                  ),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64),
            SizedBox(height: 16),
            Text(
              'No categories yet.\nTap "Category" to create your first one.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LowStockBanner extends StatelessWidget {
  const _LowStockBanner({required this.items});

  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.all(12),
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
                const SizedBox(width: 8),
                Text('Running low (${items.length})',
                    style: TextStyle(
                        color: scheme.onErrorContainer, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              items
                  .map((i) => '${i.name}: ${formatQuantity(i.quantity)} ${i.unit}'.trim())
                  .join(', '),
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.itemCount});

  final InventoryCategory category;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final store = InventoryScope.of(context);
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.category_outlined)),
      title: Text(category.name),
      subtitle: Text('$itemCount item${itemCount == 1 ? '' : 's'}'),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'rename') {
            final name = await promptForText(
              context,
              title: 'Rename category',
              label: 'Category name',
              initialValue: category.name,
            );
            if (name != null && name.isNotEmpty) {
              await store.renameCategory(category.id, name);
            }
          } else if (value == 'delete') {
            final confirmed = await _confirmDelete(context, category.name);
            if (confirmed) await store.deleteCategory(category.id);
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'rename', child: Text('Rename')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CategoryScreen(categoryId: category.id),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "$name"?'),
        content: const Text('All items in this category will also be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    return result ?? false;
  }
}
