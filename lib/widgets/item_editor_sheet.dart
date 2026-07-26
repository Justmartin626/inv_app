import 'package:flutter/material.dart';

import '../main.dart';
import '../models.dart';

Future<void> showItemEditor(
  BuildContext context, {
  required String categoryId,
  Item? item,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: _ItemEditor(categoryId: categoryId, item: item),
    ),
  );
}

class _ItemEditor extends StatefulWidget {
  const _ItemEditor({required this.categoryId, this.item});

  final String categoryId;
  final Item? item;

  @override
  State<_ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends State<_ItemEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.item?.name ?? '');
  late final TextEditingController _quantity = TextEditingController(
      text: widget.item == null ? '1' : formatQuantity(widget.item!.quantity));
  late final TextEditingController _unit =
      TextEditingController(text: widget.item?.unit ?? '');
  late final TextEditingController _threshold = TextEditingController(
      text: widget.item == null ? '' : formatQuantity(widget.item!.lowStockThreshold));
  late String _categoryId = widget.item?.categoryId ?? widget.categoryId;

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _unit.dispose();
    _threshold.dispose();
    super.dispose();
  }

  String? _validateNumber(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Required' : null;
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a number';
    if (parsed < 0) return 'Must be 0 or more';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final store = InventoryScope.of(context);
    final quantity = double.parse(_quantity.text.trim());
    final threshold = double.tryParse(_threshold.text.trim()) ?? 0;
    final existing = widget.item;
    if (existing == null) {
      await store.addItem(
        categoryId: _categoryId,
        name: _name.text,
        quantity: quantity,
        unit: _unit.text,
        lowStockThreshold: threshold,
      );
    } else {
      await store.updateItem(existing.copyWith(
        categoryId: _categoryId,
        name: _name.text.trim(),
        quantity: quantity,
        unit: _unit.text.trim(),
        lowStockThreshold: threshold,
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final store = InventoryScope.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.item == null ? 'Add item' : 'Edit item',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('item-name-field'),
                controller: _name,
                autofocus: widget.item == null,
                decoration: const InputDecoration(labelText: 'Item name'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('item-quantity-field'),
                      controller: _quantity,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      validator: _validateNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _unit,
                      decoration: const InputDecoration(
                          labelText: 'Unit', hintText: 'rolls, cans...'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _threshold,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Low stock alert at (optional)',
                ),
                validator: (value) => _validateNumber(value, required: false),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  for (final category in store.categories)
                    DropdownMenuItem(value: category.id, child: Text(category.name)),
                ],
                onChanged: (value) =>
                    setState(() => _categoryId = value ?? _categoryId),
              ),
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('save-item-button'),
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
