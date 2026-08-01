import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Tracker')),
      drawer: const AppDrawer(currentRoute: '/jobs'),
      body: const Center(child: Text('Job Tracker - Coming Soon')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
