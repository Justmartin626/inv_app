class InventoryCategory {
  InventoryCategory({required this.id, required this.name});

  final String id;
  final String name;

  InventoryCategory copyWith({String? name}) => InventoryCategory(id: id, name: name ?? this.name);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory InventoryCategory.fromJson(Map<String, dynamic> json) =>
      InventoryCategory(id: json['id'] as String, name: json['name'] as String);
}

class Item {
  Item({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.quantity,
    this.unit = '',
    this.lowStockThreshold = 0,
  });

  final String id;
  final String categoryId;
  final String name;
  final double quantity;
  final String unit;
  final double lowStockThreshold;

  bool get isLowStock => lowStockThreshold > 0 && quantity <= lowStockThreshold;

  Item copyWith({
    String? categoryId,
    String? name,
    double? quantity,
    String? unit,
    double? lowStockThreshold,
  }) =>
      Item(
        id: id,
        categoryId: categoryId ?? this.categoryId,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'lowStockThreshold': lowStockThreshold,
      };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as String,
        categoryId: json['categoryId'] as String,
        name: json['name'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'] as String? ?? '',
        lowStockThreshold: (json['lowStockThreshold'] as num?)?.toDouble() ?? 0,
      );
}

String formatQuantity(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}
