import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      drawer: const AppDrawer(currentRoute: '/bookmarks'),
      body: const Center(child: Text('Bookmark Manager - Coming Soon')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
