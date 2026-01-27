import 'package:flutter/material.dart';
import 'game_screen.dart';

/// Màn hình chọn level - Classic Mode
class LevelSelectorScreen extends StatelessWidget {
  const LevelSelectorScreen({super.key});

  // Cấu hình sections
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
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '💡 ∞',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildProgressCard(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    for (final section in sections)
                      _buildSection(context, section),
                    const SizedBox(height: 16),
                    _buildRandomLevelButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    // TODO: Kết nối với game state để lấy progress thực
    final currentLevel = 1; // Tạm thời hardcode, sau sẽ lấy từ saved data
    final progress = (currentLevel / maxLevel * 100).toInt();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Progress:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Level $currentLevel / $maxLevel',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: currentLevel / maxLevel,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$progress%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, LevelSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(
                '${section.name} (${section.start}-${section.end})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.lock_open,
                size: 18,
                color: section.color,
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
            childAspectRatio: 1.0,
          ),
          itemCount: section.end - section.start + 1,
          itemBuilder: (context, index) {
            final level = section.start + index;
            return _buildLevelButton(context, level, section.color);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRandomLevelButton(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Random level từ 1-200
          final randomLevel = DateTime.now().millisecond % maxLevel + 1;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(initialLevel: randomLevel),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade600],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shuffle, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'RANDOM LEVEL',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, int level, Color sectionColor) {
    // Xác định grid size dựa trên level
    String gridSize;
    if (level <= 5) {
      gridSize = '10×10';
    } else if (level <= 10) {
      gridSize = '12×12';
    } else if (level <= 15) {
      gridSize = '14×14';
    } else {
      gridSize = '16×16';
    }

    // TODO: Kiểm tra completed status từ saved data
    final isCompleted = false; // Tạm thời false, sau sẽ load từ storage
    final stars = 0; // 0-3 stars earned

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(initialLevel: level),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color : sectionColor,
            borderRadius: BorderRadius.circular(8),
            border: isCompleted
                ? Border.all(color: Colors.yellow.shade700, width: 2)
                : null,
          ),
          child: Stack(
            children: [
              // Checkmark for completed levels

              // Level number and info
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$level',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      gridSize,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Model cho level section
class LevelSection {
  final String name;
  final int start;
  final int end;
  final MaterialColor color;

  const LevelSection({
    required this.name,
    required this.start,
    required this.end,
    required this.color,
  });
}
