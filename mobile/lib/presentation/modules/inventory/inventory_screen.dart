import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Inventory')),
      drawer: const AppDrawer(currentRoute: '/inventory'),
      body: const Center(child: Text('Personal Inventory - Coming Soon')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
