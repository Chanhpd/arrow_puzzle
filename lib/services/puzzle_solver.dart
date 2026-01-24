import 'dart:collection';
import '../models/game_board.dart';
import '../models/complex_arrow.dart';
import '../models/cell_position.dart';

/// Solver để check xem puzzle có giải được không
class PuzzleSolver {
  /// Kiểm tra xem puzzle có thể giải được không (BFS approach)
  /// Returns: true nếu có thể clear toàn bộ arrows
  static bool isSolvable(GameBoard board, {int maxStates = 15000}) {
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
      final movableArrows = _getMovableArrows(currentBoard);

      // Nếu còn arrows nhưng không có move nào = unsolvable
      if (movableArrows.isEmpty) {
        continue; // Skip state này
      }

      for (var arrow in movableArrows) {
        // Clone board và remove arrow
        final newBoard = _cloneBoard(currentBoard);
        newBoard.removeArrow(arrow);

        // Check xem state này đã visit chưa
        final stateHash = _getBoardStateHash(newBoard);
        if (!visited.contains(stateHash)) {
          visited.add(stateHash);
          queue.add(newBoard);
        }
      }
    }

    // Nếu explore hết states mà không tìm thấy solution
    return false;
  }

  /// Lấy danh sách arrows có thể escape
  static List<ComplexArrow> _getMovableArrows(GameBoard board) {
    final movable = <ComplexArrow>[];
    for (var arrow in board.arrows) {
      if (_canEscape(board, arrow)) {
        movable.add(arrow);
      }
    }
    return movable;
  }

  /// Check xem arrow có thể escape không
  static bool _canEscape(GameBoard board, ComplexArrow arrow) {
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
      if (!board.isInBounds(testHead)) {
        return true;
      }

      // Nếu va chạm = không thể escape
      if (occupiedByOthers.contains(testHead)) {
        return false;
      }
    }

    return false;
  }

  /// Clone board để test
  static GameBoard _cloneBoard(GameBoard board) {
    final clonedArrows = <ComplexArrow>[];

    for (var arrow in board.arrows) {
      final clonedArrow = ComplexArrow(
        id: arrow.id,
        segments: List.from(arrow.segments),
        direction: arrow.direction,
        moveAxis: arrow.moveAxis,
        isExit: arrow.isExit,
      );
      clonedArrows.add(clonedArrow);
    }

    return GameBoard(rows: board.rows, cols: board.cols, arrows: clonedArrows);
  }

  /// Generate hash cho board state để detect duplicates
  static String _getBoardStateHash(GameBoard board) {
    // Sort arrows by ID để consistent hash
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
  static bool hasImmediateMove(GameBoard board) {
    if (board.arrows.isEmpty) return true;
    return _getMovableArrows(board).isNotEmpty;
  }

  /// Quick validation: check deadlock situations
  static bool hasDeadlock(GameBoard board) {
    // Nếu không có arrow nào có thể di chuyển = deadlock
    if (board.arrows.isNotEmpty && !hasImmediateMove(board)) {
      return true;
    }

    // Check circular dependencies (all arrows blocking each other)
    final blockingMap = <int, Set<int>>{};

    for (var arrow in board.arrows) {
      final blockedBy = _getBlockingArrows(board, arrow);
      if (blockedBy.isNotEmpty) {
        blockingMap[arrow.id] = blockedBy;
      }
    }

    // Nếu tất cả arrows đều bị block và không có ai thoát được = deadlock
    if (blockingMap.length == board.arrows.length) {
      return true;
    }

    // Check circular blocking (A blocks B, B blocks C, C blocks A)
    if (_hasCyclicDependency(blockingMap)) {
      return true;
    }

    return false;
  }

  /// Detect cyclic dependencies in blocking map
  static bool _hasCyclicDependency(Map<int, Set<int>> blockingMap) {
    // DFS để tìm cycle
    final visited = <int>{};
    final recursionStack = <int>{};

    bool hasCycle(int arrowId) {
      if (recursionStack.contains(arrowId)) return true;
      if (visited.contains(arrowId)) return false;

      visited.add(arrowId);
      recursionStack.add(arrowId);

      if (blockingMap.containsKey(arrowId)) {
        for (var blockerId in blockingMap[arrowId]!) {
          if (hasCycle(blockerId)) return true;
        }
      }

      recursionStack.remove(arrowId);
      return false;
    }

    for (var arrowId in blockingMap.keys) {
      if (hasCycle(arrowId)) return true;
    }

    return false;
  }

  /// Lấy danh sách arrow IDs đang block arrow này
  static Set<int> _getBlockingArrows(GameBoard board, ComplexArrow arrow) {
    final blocking = <int>{};
    final delta = arrow.direction.delta;
    var testHead = arrow.getHead();
    final maxSteps = board.rows + board.cols + 20;

    for (int step = 0; step < maxSteps; step++) {
      testHead = CellPosition(
        testHead.row + delta.row,
        testHead.col + delta.col,
      );

      if (!board.isInBounds(testHead)) {
        break; // Có thể escape
      }

      // Check nếu có arrow khác ở đây
      final arrowId = board.grid[testHead.row][testHead.col].arrowId;
      if (arrowId != null && arrowId != arrow.id) {
        blocking.add(arrowId);
        break;
      }
    }

    return blocking;
  }
}
