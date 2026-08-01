import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Manager')),
      drawer: const AppDrawer(currentRoute: '/projects'),
      body: const Center(child: Text('Project Manager - Coming Soon')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
