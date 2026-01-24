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
    _drawDots(canvas);
    _drawArrows(canvas);
  }

  /// Vẽ lưới dots thay vì grid lines
  void _drawDots(Canvas canvas) {
    final dotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final dotRadius = cellSize * 0.06; // Dot nhỏ ~6% của cell size

    // Vẽ dots tại mỗi intersection point
    for (int row = 0; row <= board.rows; row++) {
      for (int col = 0; col <= board.cols; col++) {
        final center = Offset(col * cellSize, row * cellSize);
        canvas.drawCircle(center, dotRadius, dotPaint);
      }
    }
  }

  /// Vẽ tất cả arrows
  void _drawArrows(Canvas canvas) {
    for (var arrow in board.arrows) {
      _drawSingleArrow(canvas, arrow);
    }
  }

  /// Tất cả arrows đều màu đen
  Color _getArrowColor(ComplexArrow arrow) {
    return Colors.black;
  }

  /// Vẽ 1 arrow với smooth path chạy trên dots
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

    if (arrow.segments.isEmpty) return;

    // Tính animation offset cho head
    double animOffsetX = 0;
    double animOffsetY = 0;

    if (isAnimating && animationPath != null && animationPath!.isNotEmpty) {
      final delta = arrow.direction.delta;
      animOffsetX = delta.col * cellSize * animationProgress;
      animOffsetY = delta.row * cellSize * animationProgress;
    }

    // Tạo path nối các segments
    final path = Path();
    final List<Offset> points = [];

    for (int i = 0; i < arrow.segments.length; i++) {
      final pos = arrow.segments[i];
      double offsetX = 0;
      double offsetY = 0;

      // Chỉ head có animation offset
      if (isAnimating && i == arrow.segments.length - 1) {
        offsetX = animOffsetX;
        offsetY = animOffsetY;
      }

      points.add(
        Offset(pos.col * cellSize + offsetX, pos.row * cellSize + offsetY),
      );
    }

    // Vẽ đường path với shadow khi animate
    if (isAnimating) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.15 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.25
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final shadowPath = Path();
      if (points.isNotEmpty) {
        shadowPath.moveTo(points[0].dx + 2, points[0].dy + 2);
        for (int i = 1; i < points.length; i++) {
          shadowPath.lineTo(points[i].dx + 2, points[i].dy + 2);
        }
      }
      canvas.drawPath(shadowPath, shadowPaint);
    }

    // Vẽ border (outline trắng)
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.20
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }

    canvas.drawPath(path, borderPaint);

    // Vẽ body chính của arrow
    final bodyPaint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, bodyPaint);

    // Vẽ arrow head (triangle) tại head
    final head = arrow.getHead();
    final headCenter = Offset(
      head.col * cellSize + animOffsetX,
      head.row * cellSize + animOffsetY,
    );

    _drawArrowHead(canvas, headCenter, arrow.direction, arrowColor, opacity);
  }

  /// Vẽ arrow head dạng triangle
  void _drawArrowHead(
    Canvas canvas,
    Offset position,
    dynamic direction,
    Color color,
    double opacity,
  ) {
    final arrowSize = cellSize * 0.35; // Kích thước arrow head
    final arrowPath = Path();

    // Xác định hướng và vẽ triangle
    final delta = direction.delta;

    // Tính góc xoay dựa trên hướng
    double angle = 0;
    if (delta.col == 1 && delta.row == 0) {
      // Right
      angle = 0;
    } else if (delta.col == -1 && delta.row == 0) {
      // Left
      angle = 3.14159; // 180 degrees
    } else if (delta.col == 0 && delta.row == 1) {
      // Down
      angle = 3.14159 / 2; // 90 degrees
    } else if (delta.col == 0 && delta.row == -1) {
      // Up
      angle = -3.14159 / 2; // -90 degrees
    }

    // Vẽ triangle pointing theo hướng
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);

    // Triangle shape: pointing right khi angle = 0
    arrowPath.moveTo(arrowSize * 0.6, 0); // Tip
    arrowPath.lineTo(-arrowSize * 0.4, -arrowSize * 0.5); // Top corner
    arrowPath.lineTo(-arrowSize * 0.4, arrowSize * 0.5); // Bottom corner
    arrowPath.close();

    // Vẽ border trắng
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.05
      ..strokeJoin = StrokeJoin.miter;
    canvas.drawPath(arrowPath, borderPaint);

    // Vẽ fill
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, fillPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) {
    return board != oldDelegate.board ||
        selectedArrow != oldDelegate.selectedArrow ||
        animatingArrow != oldDelegate.animatingArrow ||
        animationProgress != oldDelegate.animationProgress;
  }
}
