import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'models.dart';

const _categoriesKey = 'categories';
const _itemsKey = 'items';

class InventoryStore extends ChangeNotifier {
  InventoryStore({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;
  final _uuid = const Uuid();

  final List<InventoryCategory> _categories = [];
  final List<Item> _items = [];
  bool _loaded = false;

  List<InventoryCategory> get categories => List.unmodifiable(_categories);
  List<Item> get items => List.unmodifiable(_items);
  bool get isLoaded => _loaded;

  List<Item> itemsInCategory(String categoryId) =>
      _items.where((item) => item.categoryId == categoryId).toList();

  List<Item> get lowStockItems => _items.where((item) => item.isLowStock).toList();

  InventoryCategory? categoryById(String id) {
    for (final category in _categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  Future<void> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final rawCategories = _prefs!.getString(_categoriesKey);
    final rawItems = _prefs!.getString(_itemsKey);
    _categories
      ..clear()
      ..addAll(_decode(rawCategories).map(InventoryCategory.fromJson));
    _items
      ..clear()
      ..addAll(_decode(rawItems).map(Item.fromJson));
    _loaded = true;
    notifyListeners();
  }

  List<Map<String, dynamic>> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> _persist() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(
        _categoriesKey, jsonEncode(_categories.map((c) => c.toJson()).toList()));
    await _prefs!
        .setString(_itemsKey, jsonEncode(_items.map((i) => i.toJson()).toList()));
  }

  Future<InventoryCategory> addCategory(String name) async {
    final category = InventoryCategory(id: _uuid.v4(), name: name.trim());
    _categories.add(category);
    notifyListeners();
    await _persist();
    return category;
  }

  Future<void> renameCategory(String id, String name) async {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return;
    _categories[index] = _categories[index].copyWith(name: name.trim());
    notifyListeners();
    await _persist();
  }

  /// Removes a category along with every item it contains.
  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    _items.removeWhere((item) => item.categoryId == id);
    notifyListeners();
    await _persist();
  }

  Future<Item> addItem({
    required String categoryId,
    required String name,
    required double quantity,
    String unit = '',
    double lowStockThreshold = 0,
  }) async {
    final item = Item(
      id: _uuid.v4(),
      categoryId: categoryId,
      name: name.trim(),
      quantity: quantity,
      unit: unit.trim(),
      lowStockThreshold: lowStockThreshold,
    );
    _items.add(item);
    notifyListeners();
    await _persist();
    return item;
  }

  Future<void> updateItem(Item item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index == -1) return;
    _items[index] = item;
    notifyListeners();
    await _persist();
  }

  Future<void> adjustQuantity(String id, double delta) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    final next = (_items[index].quantity + delta).clamp(0.0, double.infinity);
    _items[index] = _items[index].copyWith(quantity: next.toDouble());
    notifyListeners();
    await _persist();
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
    await _persist();
  }
}
