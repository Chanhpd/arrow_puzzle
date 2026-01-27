import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../cubit/cubit.dart';
import '../widgets/board_widget.dart';

/// Main game page
class GamePage extends StatelessWidget {
  const GamePage({super.key, required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => get<GameCubit>()..generateLevel(level: level),
      child: const GameView(),
    );
  }
}

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<GameCubit, GameState>(
          builder: (context, state) {
            return Text('Level ${state.currentLevel}');
          },
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: 'Back to level selector',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: () {
              context.read<GameCubit>().restartLevel();
            },
            tooltip: 'Restart Level',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final level = context.read<GameCubit>().state.currentLevel;
              context.read<GameCubit>().generateLevel(level: level);
            },
            tooltip: 'Generate new puzzle',
          ),
        ],
      ),
      body: BlocConsumer<GameCubit, GameState>(
        listener: (context, state) {
          // Show error if any
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading || state.board == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              Column(
                children: [
                  _buildInfoPanel(state),
                  Expanded(
                    child: Center(
                      child: BoardWidget(
                        board: state.board!,
                        animatingArrow: state.animatingArrow,
                        animationPath: state.animationPath,
                        animationProgress: state.animationProgress,
                        onArrowTap: (arrow) {
                          context.read<GameCubit>().onArrowClicked(arrow);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              if (state.isGameWon) _buildWinOverlay(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoPanel(GameState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('Level', '${state.currentLevel}', Icons.layers),
          _buildInfoItem(
            'Arrows Left',
            '${state.board?.arrows.length ?? 0}',
            Icons.arrow_forward,
          ),
          _buildInfoItem('Moves', '${state.movesCount}', Icons.touch_app),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWinOverlay(BuildContext context, GameState state) {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.celebration, size: 64, color: Colors.amber),
                  const SizedBox(height: 16),
                  const Text(
                    '🎉 You Win! 🎉',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Level ${state.currentLevel} completed in ${state.movesCount} moves!',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<GameCubit>().restartLevel();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Restart'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<GameCubit>().nextLevel();
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next Level'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
