import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/cell_position.dart';
import '../widgets/board_painter.dart';

/// Main game screen
class GameScreen extends StatefulWidget {
  final int? initialLevel;

  const GameScreen({super.key, this.initialLevel});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Tạo level với level number được truyền vào
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameController>().generateLevel(level: widget.initialLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<GameController>(
          builder: (context, controller, child) {
            return Text('Level ${controller.currentLevel}');
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          tooltip: 'Quay lại chọn level',
        ),
        actions: [
          // Debug button - check solvability
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () {
              final board = context.read<GameController>().board;
              if (board != null) {
                // final hasMove = PuzzleSolver.hasImmediateMove(board);
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text(
                //       hasMove
                //           ? '✓ Có arrow có thể escape!'
                //           : '✗ KHÔNG có arrow nào escape được - STUCK!',
                //     ),
                //     backgroundColor: hasMove ? Colors.green : Colors.red,
                //     duration: const Duration(seconds: 2),
                //   ),
                // );
              }
            },
            tooltip: 'Check Solvability',
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: () {
              context.read<GameController>().restartLevel();
            },
            tooltip: 'Restart Level',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GameController>().generateLevel(
                level: widget.initialLevel,
              );
            },
            tooltip: 'Generate lại level này',
          ),
        ],
      ),
      body: Consumer<GameController>(
        builder: (context, controller, child) {
          final board = controller.board;

          if (board == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              Column(
                children: [
                  // Game info panel
                  _buildInfoPanel(controller),

                  // Game board
                  Expanded(
                    child: Center(child: _buildGameBoard(controller, board)),
                  ),
                ],
              ),

              // Win dialog overlay
              if (controller.isGameWon) _buildWinOverlay(),
            ],
          );
        },
      ),
    );
  }

  /// Info panel
  Widget _buildInfoPanel(GameController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('Level', '${controller.currentLevel}', Icons.layers),
          _buildInfoItem(
            'Arrows Left',
            '${controller.board?.arrows.length ?? 0}',
            Icons.arrow_forward,
          ),
          _buildInfoItem('Moves', '${controller.movesCount}', Icons.touch_app),
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

  /// Game board với gesture detection
  Widget _buildGameBoard(GameController controller, board) {
    final screenSize = MediaQuery.of(context).size;
    final maxSize = screenSize.width < screenSize.height
        ? screenSize.width * 0.95
        : screenSize.height * 0.7;

    final cellSize = maxSize / board.cols;
    final boardWidth = board.cols * cellSize;
    final boardHeight = board.rows * cellSize;

    return GestureDetector(
      onTapUp: (details) => _handleTap(controller, details, cellSize),
      child: Container(
        width: boardWidth,
        height: boardHeight,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 2),
          color: Colors.white,
        ),
        child: CustomPaint(
          painter: BoardPainter(
            board: board,
            cellSize: cellSize,
            animatingArrow: controller.animatingArrow,
            animationPath: controller.animationPath,
            animationProgress: controller.animationProgress,
          ),
        ),
      ),
    );
  }

  /// Handle tap
  void _handleTap(
    GameController controller,
    TapUpDetails details,
    double cellSize,
  ) {
    if (controller.isAnimating) return;

    final localPosition = details.localPosition;
    final row = (localPosition.dy / cellSize).floor();
    final col = (localPosition.dx / cellSize).floor();
    final tappedPos = CellPosition(row, col);

    final arrow = controller.board?.getArrowAt(tappedPos);
    if (arrow != null) {
      controller.onArrowClicked(arrow);
    }
  }

  /// Win overlay
  Widget _buildWinOverlay() {
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
                    'Level ${context.read<GameController>().currentLevel} completed in ${context.read<GameController>().movesCount} moves!',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<GameController>().restartLevel();
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
                          context.read<GameController>().nextLevel();
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
