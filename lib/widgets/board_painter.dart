import 'package:flutter/material.dart';
import '../models/game_board.dart';
import '../models/complex_arrow.dart';
import '../models/cell_position.dart';

/// CustomPainter để vẽ game board
class BoardPainter extends CustomPainter {
  final GameBoard board;
  final double cellSize;
  final ComplexArrow? selectedArrow;
  final ComplexArrow? animatingArrow;
  final List<CellPosition>? animationPath;
  final double animationProgress;

  BoardPainter({
    required this.board,
    required this.cellSize,
    this.selectedArrow,
    this.animatingArrow,
    this.animationPath,
    this.animationProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas);
    _drawArrows(canvas);
  }

  /// Vẽ lưới
  void _drawGrid(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int row = 0; row <= board.rows; row++) {
      canvas.drawLine(
        Offset(0, row * cellSize),
        Offset(board.cols * cellSize, row * cellSize),
        paint,
      );
    }

    for (int col = 0; col <= board.cols; col++) {
      canvas.drawLine(
        Offset(col * cellSize, 0),
        Offset(col * cellSize, board.rows * cellSize),
        paint,
      );
    }
  }

  /// Vẽ tất cả arrows
  void _drawArrows(Canvas canvas) {
    for (var arrow in board.arrows) {
      _drawSingleArrow(canvas, arrow);
    }
  }

  /// Generate màu unique cho mỗi arrow
  Color _getArrowColor(ComplexArrow arrow) {
    if (arrow.isExit) {
      return Colors.red.shade400; // Exit arrow vẫn màu đỏ
    }

    // Danh sách màu đẹp và dễ phân biệt
    final colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.purple.shade400,
      Colors.orange.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
      Colors.indigo.shade400,
      Colors.amber.shade600,
      Colors.cyan.shade400,
      Colors.lime.shade600,
      Colors.deepOrange.shade400,
      Colors.lightGreen.shade500,
      Colors.deepPurple.shade400,
      Colors.brown.shade400,
      Colors.blueGrey.shade400,
    ];

    // Dùng arrow ID để chọn màu (consistent)
    return colors[arrow.id % colors.length];
  }

  /// Vẽ 1 arrow với smooth animation
  void _drawSingleArrow(
    Canvas canvas,
    ComplexArrow arrow, {
    double opacity = 1.0,
  }) {
    final isSelected = arrow.id == selectedArrow?.id;
    final isAnimating = arrow.id == animatingArrow?.id;

    // Màu arrow - mỗi arrow có màu riêng
    Color arrowColor = _getArrowColor(arrow);

    // Làm sáng hơn khi select/animate
    if (isSelected || isAnimating) {
      arrowColor = Color.lerp(arrowColor, Colors.white, 0.3)!;
    }

    // Apply opacity cho fade animation
    arrowColor = arrowColor.withOpacity(opacity);

    // Vẽ body của arrow với animation offset
    final bodyPaint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.fill;

    // Border để phân biệt rõ hơn
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < arrow.segments.length; i++) {
      final pos = arrow.segments[i];
      double offsetX = 0;
      double offsetY = 0;

      // Nếu đang animate và là head, apply movement offset
      if (isAnimating &&
          i == arrow.segments.length - 1 &&
          animationPath != null &&
          animationPath!.isNotEmpty) {
        final delta = arrow.direction.delta;
        offsetX = delta.col * cellSize * animationProgress;
        offsetY = delta.row * cellSize * animationProgress;
      }

      final rect = Rect.fromLTWH(
        pos.col * cellSize + 2 + offsetX,
        pos.row * cellSize + 2 + offsetY,
        cellSize - 4,
        cellSize - 4,
      );

      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

      // Thêm shadow effect khi animate
      if (isAnimating) {
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.2 * opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect.shift(const Offset(2, 2)),
            const Radius.circular(4),
          ),
          shadowPaint,
        );
      }

      // Vẽ body
      canvas.drawRRect(rrect, bodyPaint);

      // Vẽ border trắng để phân biệt
      canvas.drawRRect(rrect, borderPaint);
    }

    // Vẽ ký hiệu direction ở head
    final head = arrow.getHead();
    double headOffsetX = 0;
    double headOffsetY = 0;

    if (isAnimating && animationPath != null && animationPath!.isNotEmpty) {
      final delta = arrow.direction.delta;
      headOffsetX = delta.col * cellSize * animationProgress;
      headOffsetY = delta.row * cellSize * animationProgress;
    }

    final symbolCenter = Offset(
      head.col * cellSize + cellSize / 2 + headOffsetX,
      head.row * cellSize + cellSize / 2 + headOffsetY,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: arrow.direction.symbol,
        style: TextStyle(
          fontSize: cellSize * 0.6,
          color: Colors.white.withOpacity(opacity),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        symbolCenter.dx - textPainter.width / 2,
        symbolCenter.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) {
    return board != oldDelegate.board ||
        selectedArrow != oldDelegate.selectedArrow ||
        animatingArrow != oldDelegate.animatingArrow ||
        animationProgress != oldDelegate.animationProgress;
  }
}
