import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class BugsScreen extends StatelessWidget {
  const BugsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bug Tracker')),
      drawer: const AppDrawer(currentRoute: '/bugs'),
      body: const Center(child: Text('Bug Tracker - Coming Soon')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
