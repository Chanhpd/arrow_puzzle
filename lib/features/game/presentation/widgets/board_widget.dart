import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';
import 'board_painter.dart';

/// Board widget with gesture detection
class BoardWidget extends StatelessWidget {
  const BoardWidget({
    super.key,
    required this.board,
    this.animatingArrow,
    this.animationPath,
    this.animationProgress = 0.0,
    required this.onArrowTap,
  });

  final GameBoard board;
  final ComplexArrow? animatingArrow;
  final List<CellPosition>? animationPath;
  final double animationProgress;
  final Function(ComplexArrow) onArrowTap;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxSize = screenSize.width < screenSize.height
        ? screenSize.width * 0.95
        : screenSize.height * 0.7;

    final cellSize = maxSize / board.cols;
    final boardWidth = board.cols * cellSize;
    final boardHeight = board.rows * cellSize;

    return GestureDetector(
      onTapUp: (details) => _handleTap(details, cellSize),
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
            animatingArrow: animatingArrow,
            animationPath: animationPath,
            animationProgress: animationProgress,
          ),
        ),
      ),
    );
  }

  void _handleTap(TapUpDetails details, double cellSize) {
    final localPosition = details.localPosition;
    final row = (localPosition.dy / cellSize).floor();
    final col = (localPosition.dx / cellSize).floor();
    final tappedPos = CellPosition(row, col);

    final arrow = board.getArrowAt(tappedPos);
    if (arrow != null) {
      onArrowTap(arrow);
    }
  }
}
