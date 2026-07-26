# Home Inventory

A Flutter app for tracking home supplies: create categories, add items, and track how much of each you have.

## Features

- Create, rename and delete categories (deleting a category removes its items)
- Add items with a name, quantity, optional unit (rolls, cans, ...) and an optional low-stock threshold
- Increment/decrement quantities from the list, or edit an item to set an exact amount
- Move an item between categories from the item editor
- Swipe an item left to delete it
- "Running low" banner on the home screen for items at/below their threshold
- Data is stored locally on the device with `shared_preferences` (survives restarts)

## Running

```bash
flutter pub get
flutter run            # connected device / emulator
flutter run -d chrome  # web
```

## Tests

```bash
flutter analyze
flutter test
```

## Project layout

- `lib/models.dart` — `InventoryCategory` and `Item` models
- `lib/inventory_store.dart` — `ChangeNotifier` store with JSON persistence
- `lib/screens/` — home (categories) and category (items) screens
- `lib/widgets/` — item editor bottom sheet, text prompt dialog
