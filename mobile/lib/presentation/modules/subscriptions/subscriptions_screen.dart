import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      drawer: const AppDrawer(currentRoute: '/subscriptions'),
      body: const Center(child: Text('Subscription Tracker - Coming Soon')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
