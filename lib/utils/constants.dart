// Game constants
const double cellSize = 60.0;
const double arrowSize = 50.0;
const double animationDuration = 0.25;
const int maxLives = 5;

// Cell types
enum CellType {
  empty('E'),
  wall('W'),
  exit('X'),
  arrowUp('U'),
  arrowDown('D'),
  arrowLeft('L'),
  arrowRight('R');

  const CellType(this.code);
  final String code;

  static CellType fromCode(String code) {
    return CellType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => CellType.empty,
    );
  }
}

// Arrow directions
enum Direction {
  up(0, -1),
  down(0, 1),
  left(-1, 0),
  right(1, 0);

  const Direction(this.dx, this.dy);
  final int dx;
  final int dy;

  static Direction fromCellType(CellType type) {
    switch (type) {
      case CellType.arrowUp:
        return Direction.up;
      case CellType.arrowDown:
        return Direction.down;
      case CellType.arrowLeft:
        return Direction.left;
      case CellType.arrowRight:
        return Direction.right;
      default:
        return Direction.up;
    }
  }
}
