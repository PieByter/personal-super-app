import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Tracker')),
      drawer: const AppDrawer(currentRoute: '/habits'),
      body: const Center(child: Text('Habit Tracker - Coming Soon')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
