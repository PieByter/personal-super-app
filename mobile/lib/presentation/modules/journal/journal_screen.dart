import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Developer Journal')),
      drawer: const AppDrawer(currentRoute: '/journal'),
      body: const Center(child: Text('Developer Journal - Coming Soon')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
