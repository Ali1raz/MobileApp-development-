import 'package:flutter/material.dart';
import 'package:mid_proj/core/routes/app_router.dart';
import 'package:mid_proj/features/multiplication/models/menu_item.dart';
import 'package:mid_proj/features/multiplication/widgets/home_menu_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiplication'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, AppRouter.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: MenuItem.items.map((item) => HomeMenuItem(item: item)).toList(),
        ),
      ),
    );
  }
} 