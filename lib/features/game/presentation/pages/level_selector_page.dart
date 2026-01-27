import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Level selector page
class LevelSelectorPage extends StatelessWidget {
  const LevelSelectorPage({super.key});

  static const int maxLevel = 200;
  static const List<LevelSection> sections = [
    LevelSection(name: 'BEGINNER', start: 1, end: 20, color: Colors.green),
    LevelSection(name: 'EASY', start: 21, end: 50, color: Colors.blue),
    LevelSection(name: 'MEDIUM', start: 51, end: 100, color: Colors.orange),
    LevelSection(name: 'HARD', start: 101, end: 200, color: Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classic Mode'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('💡 ∞', style: TextStyle(fontSize: 18))),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.blue.shade100],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              for (final section in sections) _buildSection(context, section),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, LevelSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: section.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                section.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: section.color,
                ),
              ),
              const Spacer(),
              Text(
                'Levels ${section.start}-${section.end}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: section.end - section.start + 1,
          itemBuilder: (context, index) {
            final level = section.start + index;
            return _buildLevelButton(context, level, section.color);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLevelButton(BuildContext context, int level, Color color) {
    return InkWell(
      onTap: () {
        context.pushNamed('game', extra: level);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$level',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class LevelSection {
  final String name;
  final int start;
  final int end;
  final Color color;

  const LevelSection({
    required this.name,
    required this.start,
    required this.end,
    required this.color,
  });
}
