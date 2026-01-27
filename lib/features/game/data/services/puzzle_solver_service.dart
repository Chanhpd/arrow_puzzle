import 'dart:collection';
import 'package:injectable/injectable.dart';
import '../../domain/entities/entities.dart';

/// Solver để check xem puzzle có giải được không
@injectable
class PuzzleSolverService {
  /// Kiểm tra xem puzzle có thể giải được không (BFS approach)
  bool isSolvable(GameBoard board, {int maxStates = 15000}) {
    if (board.arrows.isEmpty) return true;

    // Quick pre-check: phải có ít nhất 1 arrow có thể move
    if (!hasImmediateMove(board)) return false;

    // BFS với state caching để tránh revisit
    final queue = Queue<GameBoard>();
    final visited = <String>{};

    queue.add(board);
    visited.add(_getBoardStateHash(board));

    int statesExplored = 0;

    while (queue.isNotEmpty && statesExplored < maxStates) {
      final currentBoard = queue.removeFirst();
      statesExplored++;

      // Base case: Không còn arrow nào = solved!
      if (currentBoard.arrows.isEmpty) {
        return true;
      }

      // Thử escape từng arrow có thể di chuyển được
      final movableArrows = getMovableArrows(currentBoard);

      // Nếu còn arrows nhưng không có move nào = unsolvable
      if (movableArrows.isEmpty) {
        continue;
      }

      for (var arrow in movableArrows) {
        // Remove arrow và tạo state mới
        final newBoard = currentBoard.removeArrow(arrow.id);

        // Check xem state này đã visit chưa
        final stateHash = _getBoardStateHash(newBoard);
        if (!visited.contains(stateHash)) {
          visited.add(stateHash);
          queue.add(newBoard);
        }
      }
    }

    return false;
  }

  /// Lấy danh sách arrows có thể escape
  List<ComplexArrow> getMovableArrows(GameBoard board) {
    final movable = <ComplexArrow>[];
    for (var arrow in board.arrows) {
      if (canEscape(board, arrow)) {
        movable.add(arrow);
      }
    }
    return movable;
  }

  /// Check xem arrow có thể escape không
  bool canEscape(GameBoard board, ComplexArrow arrow) {
    final delta = arrow.direction.delta;
    final occupiedByOthers = <CellPosition>{};

    // Lấy cells bị chiếm bởi arrows khác
    for (var other in board.arrows) {
      if (other.id != arrow.id) {
        occupiedByOthers.addAll(other.segments);
      }
    }

    // Simulate di chuyển
    var testHead = arrow.getHead();
    final maxSteps = board.rows + board.cols + 20;

    for (int step = 0; step < maxSteps; step++) {
      testHead = CellPosition(
        testHead.row + delta.row,
        testHead.col + delta.col,
      );

      // Nếu ra ngoài board = có thể escape
      if (!board.isValidPosition(testHead)) {
        return true;
      }

      // Nếu va chạm = không thể escape
      if (occupiedByOthers.contains(testHead)) {
        return false;
      }
    }

    return false;
  }

  /// Calculate escape path for an arrow
  List<CellPosition> calculateEscapePath(GameBoard board, ComplexArrow arrow) {
    final path = <CellPosition>[];
    final delta = arrow.direction.delta;
    final occupiedByOthers = <CellPosition>{};

    // Lấy cells bị chiếm bởi arrows khác
    for (var other in board.arrows) {
      if (other.id != arrow.id) {
        occupiedByOthers.addAll(other.segments);
      }
    }

    var testHead = arrow.getHead();
    final maxSteps = board.rows + board.cols + 20;

    for (int step = 0; step < maxSteps; step++) {
      testHead = CellPosition(
        testHead.row + delta.row,
        testHead.col + delta.col,
      );

      path.add(testHead);

      // Nếu ra ngoài board = escape thành công
      if (!board.isValidPosition(testHead)) {
        break;
      }

      // Nếu va chạm = không thể escape
      if (occupiedByOthers.contains(testHead)) {
        return [];
      }
    }

    return path;
  }

  /// Generate hash cho board state để detect duplicates
  String _getBoardStateHash(GameBoard board) {
    final sortedArrows = board.arrows.toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    final buffer = StringBuffer();
    for (var arrow in sortedArrows) {
      buffer.write('${arrow.id}:');
      for (var seg in arrow.segments) {
        buffer.write('${seg.row},${seg.col};');
      }
      buffer.write('|');
    }
    return buffer.toString();
  }

  /// Fast heuristic check - ít nhất 1 arrow phải có thể escape ngay
  bool hasImmediateMove(GameBoard board) {
    if (board.arrows.isEmpty) return true;
    return getMovableArrows(board).isNotEmpty;
  }

  /// Quick validation: check deadlock situations
  bool hasDeadlock(GameBoard board) {
    if (board.arrows.isEmpty) return false;

    // Check nếu không có arrow nào có thể di chuyển
    final movableArrows = getMovableArrows(board);
    if (movableArrows.isEmpty) return true;

    // Check circular dependencies
    for (var arrow in board.arrows) {
      final blockingArrows = _getBlockingArrows(board, arrow);

      // Nếu arrow bị block bởi quá nhiều arrows khác = potential deadlock
      if (blockingArrows.length >= board.arrows.length - 1) {
        return true;
      }
    }

    return false;
  }

  /// Get arrows that are blocking this arrow from escaping
  List<ComplexArrow> _getBlockingArrows(GameBoard board, ComplexArrow arrow) {
    final blocking = <ComplexArrow>[];
    final delta = arrow.direction.delta;
    var testHead = arrow.getHead();

    for (int step = 0; step < board.rows + board.cols; step++) {
      testHead = CellPosition(
        testHead.row + delta.row,
        testHead.col + delta.col,
      );

      if (!board.isValidPosition(testHead)) break;

      final arrowAtPos = board.getArrowAt(testHead);
      if (arrowAtPos != null && arrowAtPos.id != arrow.id) {
        if (!blocking.contains(arrowAtPos)) {
          blocking.add(arrowAtPos);
        }
      }
    }

    return blocking;
  }
}
