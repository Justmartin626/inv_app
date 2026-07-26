import 'package:flutter/material.dart';

import 'inventory_store.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = InventoryStore();
  await store.load();
  runApp(HomeInventoryApp(store: store));
}

class HomeInventoryApp extends StatelessWidget {
  const HomeInventoryApp({super.key, required this.store});

  final InventoryStore store;

  @override
  Widget build(BuildContext context) {
    return InventoryScope(
      store: store,
      child: MaterialApp(
        title: 'Home Inventory',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.teal,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class InventoryScope extends InheritedNotifier<InventoryStore> {
  const InventoryScope({super.key, required InventoryStore store, required super.child})
      : super(notifier: store);

  static InventoryStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<InventoryScope>();
    assert(scope != null, 'InventoryScope not found in widget tree');
    return scope!.notifier!;
  }
}
