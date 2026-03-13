import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/services/database_service.dart';

class DatabaseInspector extends StatelessWidget {
  const DatabaseInspector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Inspector')),
      body: FutureBuilder(
        future: DatabaseService().database,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection('Database Path', snapshot.data?.path ?? 'Unknown'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}