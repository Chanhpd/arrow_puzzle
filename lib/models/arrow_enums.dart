import 'cell_position.dart';

/// Hướng di chuyển của mũi tên
enum ArrowDirection {
  right,
  left,
  down,
  up;

  String get displayName {
    switch (this) {
      case ArrowDirection.right:
        return 'RIGHT';
      case ArrowDirection.left:
        return 'LEFT';
      case ArrowDirection.down:
        return 'DOWN';
      case ArrowDirection.up:
        return 'UP';
    }
  }

  /// Arrow symbol để hiển thị
  String get symbol {
    switch (this) {
      case ArrowDirection.right:
        return '→';
      case ArrowDirection.left:
        return '←';
      case ArrowDirection.down:
        return '↓';
      case ArrowDirection.up:
        return '↑';
    }
  }

  /// Delta (dr, dc) cho direction
  CellPosition get delta {
    switch (this) {
      case ArrowDirection.right:
        return const CellPosition(0, 1);
      case ArrowDirection.left:
        return const CellPosition(0, -1);
      case ArrowDirection.down:
        return const CellPosition(1, 0);
      case ArrowDirection.up:
        return const CellPosition(-1, 0);
    }
  }

  static ArrowDirection fromString(String str) {
    switch (str.toUpperCase()) {
      case 'RIGHT':
        return ArrowDirection.right;
      case 'LEFT':
        return ArrowDirection.left;
      case 'DOWN':
        return ArrowDirection.down;
      case 'UP':
        return ArrowDirection.up;
      default:
        return ArrowDirection.right;
    }
  }
}

/// Trục di chuyển của mũi tên
enum MoveAxis {
  horizontal,
  vertical,
  both;

  String get displayName {
    switch (this) {
      case MoveAxis.horizontal:
        return 'horizontal';
      case MoveAxis.vertical:
        return 'vertical';
      case MoveAxis.both:
        return 'both';
    }
  }

  static MoveAxis fromString(String str) {
    switch (str.toLowerCase()) {
      case 'horizontal':
        return MoveAxis.horizontal;
      case 'vertical':
        return MoveAxis.vertical;
      case 'both':
        return MoveAxis.both;
      default:
        return MoveAxis.both;
    }
  }
}
