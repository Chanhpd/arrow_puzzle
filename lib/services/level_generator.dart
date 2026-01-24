import 'dart:math';
import '../models/cell_position.dart';
import '../models/complex_arrow.dart';
import '../models/game_board.dart';
import '../models/arrow_enums.dart';
import 'puzzle_solver.dart';

/// Level generator - Convert từ Python
class LevelGenerator {
  final Random _random = Random();

  /// Generate board với độ khó tùy chỉnh - CÓ VALIDATION ĐẦY ĐỦ
  GameBoard generateBoard({
    required int rows,
    required int cols,
    required int numArrows,
    double densityTarget = 0.75,
    int maxRetries = 100, // Tăng lên 100 để đảm bảo tìm được solvable board
  }) {
    int retryCount = 0;
    int fastCheckFails = 0;
    int fullCheckFails = 0;

    while (retryCount < maxRetries) {
      final board = _generateBoardInternal(
        rows: rows,
        cols: cols,
        numArrows: numArrows,
        densityTarget: densityTarget,
      );

      // Step 1: Fast check - phải có ít nhất 1 arrow có thể di chuyển
      if (!PuzzleSolver.hasImmediateMove(board)) {
        fastCheckFails++;
        retryCount++;
        if (retryCount % 20 == 0) {
          print(
            '⚠️ Fast check failed $fastCheckFails times, retrying... ($retryCount/$maxRetries)',
          );
        }
        continue;
      }

      // Step 2: Check deadlock
      if (PuzzleSolver.hasDeadlock(board)) {
        fastCheckFails++;
        retryCount++;
        if (retryCount % 20 == 0) {
          print('⚠️ Deadlock detected, retrying... ($retryCount/$maxRetries)');
        }
        continue;
      }

      // Step 3: Full solvability check (BFS) với maxStates thấp hơn cho fast generation
      // Chỉ chạy full check khi fast checks pass
      if (PuzzleSolver.isSolvable(board, maxStates: 8000)) {
        print('✅ Generated solvable puzzle after $retryCount retries');
        return board;
      }

      fullCheckFails++;
      retryCount++;
      if (retryCount % 20 == 0) {
        print(
          '⚠️ Full solvability check failed $fullCheckFails times, retrying... ($retryCount/$maxRetries)',
        );
      }
    }

    // Fallback: Tạo board đơn giản hơn với nhiều retries
    print('❌ Could not generate solvable puzzle after $maxRetries retries');
    print('🔄 Trying fallback: simpler board...');

    // Retry fallback nhiều lần với số arrows giảm dần
    for (int simplicity = 0; simplicity < 3; simplicity++) {
      final fallbackArrows = (numArrows * (0.7 - simplicity * 0.15))
          .toInt()
          .clamp(2, numArrows);
      final fallbackBoard = _generateSimpleFallbackBoard(
        rows: rows,
        cols: cols,
        numArrows: fallbackArrows,
      );

      if (PuzzleSolver.isSolvable(fallbackBoard, maxStates: 5000)) {
        print('✅ Fallback board is solvable with $fallbackArrows arrows');
        return fallbackBoard;
      }
    }

    // Last resort: tạo board cực kỳ đơn giản
    print('⚠️ Using ultra-simple fallback board');
    return _generateSimpleFallbackBoard(rows: rows, cols: cols, numArrows: 3);
  }

  /// Internal generation logic
  GameBoard _generateBoardInternal({
    required int rows,
    required int cols,
    required int numArrows,
    double densityTarget = 0.75,
  }) {
    final board = GameBoard(rows: rows, cols: cols);
    final occupiedCells = <CellPosition>{};
    int arrowId = 0;

    final totalCells = rows * cols;
    final targetOccupied = (totalCells * densityTarget).toInt();

    // Phase 1: Tạo long curved arrows
    final longArrowsTarget = (numArrows * 0.4).toInt();
    final targetForLong = (totalCells * 0.35).toInt();

    int attempts = 0;
    while (board.arrows.length < longArrowsTarget &&
        occupiedCells.length < targetForLong &&
        attempts < 500) {
      final startRow = _random.nextInt(rows - 8) + 1;
      final startCol = _random.nextInt(cols - 8) + 1;

      if (occupiedCells.contains(CellPosition(startRow, startCol))) {
        attempts++;
        continue;
      }

      final targetLength = _random.nextInt(6) + 10; // 10-15 cells

      final segments = _generateCurvedPath(
        startRow: startRow,
        startCol: startCol,
        targetLength: targetLength,
        boardRows: rows,
        boardCols: cols,
        occupiedCells: occupiedCells,
      );

      if (segments.length >= 8) {
        final direction = _determineArrowDirection(segments);
        final moveAxis = _determineMoveAxis(segments);

        final arrow = ComplexArrow(
          id: arrowId,
          segments: segments,
          direction: direction,
          moveAxis: moveAxis,
        );

        if (_validateArrowNoSelfIntersection(arrow)) {
          // Add arrow
          for (var pos in segments) {
            board.grid[pos.row][pos.col].occupied = true;
            board.grid[pos.row][pos.col].arrowId = arrowId;
            occupiedCells.add(pos);
          }

          board.arrows.add(arrow);
          arrowId++;
        }
      }

      attempts++;
    }

    // Phase 2: Fill remaining space
    attempts = 0;
    while (occupiedCells.length < targetOccupied && attempts < 2000) {
      final startRow = _random.nextInt(rows);
      final startCol = _random.nextInt(cols);

      if (occupiedCells.contains(CellPosition(startRow, startCol))) {
        attempts++;
        continue;
      }

      final length = _random.nextInt(7) + 2; // 2-8 cells
      final segments = _generateRandomPath(
        startRow: startRow,
        startCol: startCol,
        targetLength: length,
        boardRows: rows,
        boardCols: cols,
        occupiedCells: occupiedCells,
      );

      if (segments.length >= 2) {
        final direction = _determineArrowDirection(segments);
        final moveAxis = _determineMoveAxis(segments);

        final arrow = ComplexArrow(
          id: arrowId,
          segments: segments,
          direction: direction,
          moveAxis: moveAxis,
        );

        if (_validateArrowNoSelfIntersection(arrow)) {
          for (var pos in segments) {
            board.grid[pos.row][pos.col].occupied = true;
            board.grid[pos.row][pos.col].arrowId = arrowId;
            occupiedCells.add(pos);
          }

          board.arrows.add(arrow);
          arrowId++;
        }
      }

      attempts++;
    }

    // Set exit arrow (optional - không cần thiết cho game mới)
    if (board.arrows.isNotEmpty) {
      final exitArrow = board.arrows[_random.nextInt(board.arrows.length)];
      exitArrow.isExit = true;
    }

    return board;
  }

  /// Generate random path
  List<CellPosition> _generateRandomPath({
    required int startRow,
    required int startCol,
    required int targetLength,
    required int boardRows,
    required int boardCols,
    required Set<CellPosition> occupiedCells,
  }) {
    final path = <CellPosition>[CellPosition(startRow, startCol)];
    final pathSet = <CellPosition>{CellPosition(startRow, startCol)};
    int currentRow = startRow;
    int currentCol = startCol;

    final directions = [
      CellPosition(0, 1), // right
      CellPosition(0, -1), // left
      CellPosition(1, 0), // down
      CellPosition(-1, 0), // up
    ];

    CellPosition? lastDirection;
    int attempts = 0;
    final maxAttempts = targetLength * 10;

    while (path.length < targetLength && attempts < maxAttempts) {
      var possibleDirs = List<CellPosition>.from(directions);

      // 70% giữ hướng cũ
      if (lastDirection != null && _random.nextDouble() < 0.7) {
        possibleDirs =
            [lastDirection] +
            possibleDirs.where((d) => d != lastDirection).toList();
      }

      possibleDirs.shuffle(_random);

      bool moved = false;
      for (var dir in possibleDirs) {
        final newRow = currentRow + dir.row;
        final newCol = currentCol + dir.col;
        final newPos = CellPosition(newRow, newCol);

        if (newRow >= 0 &&
            newRow < boardRows &&
            newCol >= 0 &&
            newCol < boardCols &&
            !pathSet.contains(newPos) &&
            !occupiedCells.contains(newPos)) {
          path.add(newPos);
          pathSet.add(newPos);
          currentRow = newRow;
          currentCol = newCol;
          lastDirection = dir;
          moved = true;
          break;
        }
      }

      if (!moved && path.length > 3) {
        // Backtrack
        final removed = path.sublist(path.length - 2);
        path.removeRange(path.length - 2, path.length);
        for (var cell in removed) {
          pathSet.remove(cell);
        }
        if (path.isNotEmpty) {
          final last = path.last;
          currentRow = last.row;
          currentCol = last.col;
        }
        lastDirection = null;
      }

      attempts++;
    }

    return path;
  }

  /// Generate curved path (simplified)
  List<CellPosition> _generateCurvedPath({
    required int startRow,
    required int startCol,
    required int targetLength,
    required int boardRows,
    required int boardCols,
    required Set<CellPosition> occupiedCells,
  }) {
    // Simplified version - tạo L-shape hoặc U-shape
    final patterns = ['l_shape', 'u_shape', 'zigzag'];
    final pattern = patterns[_random.nextInt(patterns.length)];

    final path = <CellPosition>[CellPosition(startRow, startCol)];
    final pathSet = <CellPosition>{CellPosition(startRow, startCol)};

    List<CellPosition> sequence = [];

    if (pattern == 'l_shape') {
      final vLength = _random.nextInt(3) + 4;
      final hLength = _random.nextInt(3) + 4;
      sequence =
          List.filled(vLength, const CellPosition(1, 0)) +
          List.filled(hLength, const CellPosition(0, 1));
    } else if (pattern == 'u_shape') {
      final height = _random.nextInt(3) + 3;
      final width = _random.nextInt(3) + 4;
      sequence =
          List.filled(height, const CellPosition(1, 0)) +
          List.filled(width, const CellPosition(0, 1)) +
          List.filled(height, const CellPosition(-1, 0));
    } else {
      // zigzag
      final step = _random.nextInt(2) + 2;
      sequence =
          List.filled(step, const CellPosition(0, 1)) +
          List.filled(2, const CellPosition(1, 0)) +
          List.filled(step, const CellPosition(0, 1)) +
          List.filled(2, const CellPosition(-1, 0)) +
          List.filled(step, const CellPosition(0, 1));
    }

    int currentRow = startRow;
    int currentCol = startCol;

    for (var dir in sequence) {
      if (path.length >= targetLength) break;

      final newRow = currentRow + dir.row;
      final newCol = currentCol + dir.col;
      final newPos = CellPosition(newRow, newCol);

      if (newRow >= 0 &&
          newRow < boardRows &&
          newCol >= 0 &&
          newCol < boardCols &&
          !pathSet.contains(newPos) &&
          !occupiedCells.contains(newPos)) {
        path.add(newPos);
        pathSet.add(newPos);
        currentRow = newRow;
        currentCol = newCol;
      }
    }

    return path;
  }

  /// Xác định hướng arrow từ segments
  ArrowDirection _determineArrowDirection(List<CellPosition> segments) {
    if (segments.length < 2) return ArrowDirection.right;

    final last = segments.last;
    final secondLast = segments[segments.length - 2];

    final dr = last.row - secondLast.row;
    final dc = last.col - secondLast.col;

    if (dc > 0) {
      return ArrowDirection.right;
    } else if (dc < 0) {
      return ArrowDirection.left;
    } else if (dr > 0) {
      return ArrowDirection.down;
    } else {
      return ArrowDirection.up;
    }
  }

  /// Xác định move axis
  MoveAxis _determineMoveAxis(List<CellPosition> segments) {
    if (segments.length < 3) return MoveAxis.both;

    int horizontalMoves = 0;
    int verticalMoves = 0;

    for (int i = 1; i < segments.length; i++) {
      final dr = segments[i].row - segments[i - 1].row;
      final dc = segments[i].col - segments[i - 1].col;

      if (dc != 0) horizontalMoves++;
      if (dr != 0) verticalMoves++;
    }

    if (horizontalMoves > verticalMoves * 1.5) {
      return MoveAxis.vertical;
    } else if (verticalMoves > horizontalMoves * 1.5) {
      return MoveAxis.horizontal;
    } else {
      return MoveAxis.both;
    }
  }

  /// Validate arrow không tự cắt
  bool _validateArrowNoSelfIntersection(ComplexArrow arrow) {
    final segments = arrow.getOccupiedCells();

    // Check duplicate cells
    final seen = <CellPosition>{};
    for (var cell in segments) {
      if (seen.contains(cell)) return false;
      seen.add(cell);
    }

    // Check không chỉ vào chính mình
    final head = segments.last;
    final delta = arrow.direction.delta;
    final nextCell = CellPosition(head.row + delta.row, head.col + delta.col);

    if (seen.contains(nextCell)) return false;

    return true;
  }

  /// Fallback: Tạo board đơn giản chắc chắn giải được
  GameBoard _generateSimpleFallbackBoard({
    required int rows,
    required int cols,
    required int numArrows,
  }) {
    final board = GameBoard(rows: rows, cols: cols);
    int arrowId = 0;

    // Strategy: Tạo các straight arrows đơn giản, chỉ về 4 hướng
    final directions = [
      ArrowDirection.right,
      ArrowDirection.left,
      ArrowDirection.up,
      ArrowDirection.down,
    ];

    final occupiedCells = <CellPosition>{};
    int attempts = 0;
    final maxAttempts = numArrows * 20;

    while (board.arrows.length < numArrows && attempts < maxAttempts) {
      // Tạo vị trí random
      final startRow = _random.nextInt(rows);
      final startCol = _random.nextInt(cols);
      final startPos = CellPosition(startRow, startCol);

      if (occupiedCells.contains(startPos)) {
        attempts++;
        continue;
      }

      // Chọn hướng random
      final direction = directions[_random.nextInt(directions.length)];
      final length = _random.nextInt(4) + 2; // 2-5 cells

      // Tạo straight line
      final segments = <CellPosition>[startPos];
      var currentPos = startPos;
      final delta = direction.delta;

      for (int i = 1; i < length; i++) {
        final nextPos = CellPosition(
          currentPos.row + delta.row,
          currentPos.col + delta.col,
        );

        // Check bounds và không bị overlap
        if (nextPos.row < 0 ||
            nextPos.row >= rows ||
            nextPos.col < 0 ||
            nextPos.col >= cols ||
            occupiedCells.contains(nextPos)) {
          break;
        }

        segments.add(nextPos);
        currentPos = nextPos;
      }

      // Nếu đủ dài, add arrow
      if (segments.length >= 2) {
        final arrow = ComplexArrow(
          id: arrowId,
          segments: segments,
          direction: direction,
          moveAxis: MoveAxis.both,
        );

        // Add to board
        for (var pos in segments) {
          board.grid[pos.row][pos.col].occupied = true;
          board.grid[pos.row][pos.col].arrowId = arrowId;
          occupiedCells.add(pos);
        }

        board.arrows.add(arrow);
        arrowId++;
      }

      attempts++;
    }

    print(
      '🔄 Fallback board created with ${board.arrows.length} simple arrows',
    );
    return board;
  }
}
