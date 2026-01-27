import 'dart:math';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/entities.dart';
import 'puzzle_solver_service.dart';

/// Level generator service - Generate solvable puzzle boards
@injectable
class LevelGeneratorService {
  LevelGeneratorService(this._solverService);

  final PuzzleSolverService _solverService;
  final Random _random = Random();

  /// Generate board với độ khó tùy chỉnh - CÓ VALIDATION ĐẦY ĐỦ
  GameBoard generateBoard({
    required int rows,
    required int cols,
    required int numArrows,
    double densityTarget = 0.75,
    int maxRetries = 150,
  }) {
    int retryCount = 0;
    int fastCheckFails = 0;
    int fullCheckFails = 0;

    // Điều chỉnh maxStates dựa trên độ phức tạp
    final complexity = (rows * cols * numArrows) ~/ 100;
    final maxStates = (10000 + complexity * 500).clamp(8000, 20000);

    while (retryCount < maxRetries) {
      final board = _generateBoardInternal(
        rows: rows,
        cols: cols,
        numArrows: numArrows,
        densityTarget: densityTarget,
      );

      // Step 1: Fast check - phải có ít nhất 1 arrow có thể di chuyển
      if (!_solverService.hasImmediateMove(board)) {
        fastCheckFails++;
        retryCount++;
        if (retryCount % 30 == 0) {
          logger.w(
            '⚠️ Fast check failed $fastCheckFails times, retrying... ($retryCount/$maxRetries)',
          );
        }
        continue;
      }

      // Step 2: Check deadlock
      if (_solverService.hasDeadlock(board)) {
        fastCheckFails++;
        retryCount++;
        if (retryCount % 30 == 0) {
          logger.w('⚠️ Deadlock detected, retrying... ($retryCount/$maxRetries)');
        }
        continue;
      }

      // Step 3: Full solvability check (BFS) với maxStates động
      if (_solverService.isSolvable(board, maxStates: maxStates)) {
        logger.i(
          '✅ Generated solvable puzzle after $retryCount retries (maxStates: $maxStates)',
        );
        return board;
      }

      fullCheckFails++;
      retryCount++;
      if (retryCount % 30 == 0) {
        logger.w(
          '⚠️ Full solvability check failed $fullCheckFails times, retrying... ($retryCount/$maxRetries)',
        );
      }
    }

    // Fallback: Tạo board đơn giản hơn với nhiều retries
    logger.e('❌ Could not generate solvable puzzle after $maxRetries retries');
    logger.i('🔄 Trying fallback: simpler board...');

    for (int simplicity = 0; simplicity < 3; simplicity++) {
      final fallbackArrows = (numArrows * (0.7 - simplicity * 0.15))
          .toInt()
          .clamp(2, numArrows);
      final fallbackBoard = _generateSimpleFallbackBoard(
        rows: rows,
        cols: cols,
        numArrows: fallbackArrows,
      );

      if (_solverService.isSolvable(fallbackBoard, maxStates: 5000)) {
        logger.i('✅ Fallback board is solvable with $fallbackArrows arrows');
        return fallbackBoard;
      }
    }

    // Last resort
    logger.w('⚠️ Using ultra-simple fallback board');
    return _generateSimpleFallbackBoard(rows: rows, cols: cols, numArrows: 3);
  }

  GameBoard _generateBoardInternal({
    required int rows,
    required int cols,
    required int numArrows,
    double densityTarget = 0.75,
  }) {
    final occupiedCells = <CellPosition>{};
    final arrows = <ComplexArrow>[];
    int arrowId = 0;

    final totalCells = rows * cols;
    final targetOccupied = (totalCells * densityTarget).toInt();

    // Phase 1: Tạo long curved arrows
    final longArrowsTarget = (numArrows * 0.4).toInt();
    final targetForLong = (totalCells * 0.35).toInt();

    int attempts = 0;
    while (arrows.length < longArrowsTarget &&
        occupiedCells.length < targetForLong &&
        attempts < 500) {
      final startRow = _random.nextInt(rows - 8) + 1;
      final startCol = _random.nextInt(cols - 8) + 1;

      if (occupiedCells.contains(CellPosition(startRow, startCol))) {
        attempts++;
        continue;
      }

      final targetLength = _random.nextInt(6) + 10;

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
          occupiedCells.addAll(segments);
          arrows.add(arrow);
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

      final length = _random.nextInt(7) + 2;
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
          occupiedCells.addAll(segments);
          arrows.add(arrow);
          arrowId++;
        }
      }

      attempts++;
    }

    // Phase 3: Add more short arrows if needed
    while (arrows.length < numArrows && attempts < 3000) {
      final startRow = _random.nextInt(rows);
      final startCol = _random.nextInt(cols);

      if (occupiedCells.contains(CellPosition(startRow, startCol))) {
        attempts++;
        continue;
      }

      final length = _random.nextInt(4) + 2;
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
          occupiedCells.addAll(segments);
          arrows.add(arrow);
          arrowId++;
        }
      }

      attempts++;
    }

    return GameBoard.withArrows(rows: rows, cols: cols, arrows: arrows);
  }

  GameBoard _generateSimpleFallbackBoard({
    required int rows,
    required int cols,
    required int numArrows,
  }) {
    final arrows = <ComplexArrow>[];
    final occupiedCells = <CellPosition>{};

    for (int i = 0; i < numArrows; i++) {
      int attempts = 0;
      while (attempts < 100) {
        final row = _random.nextInt(rows);
        final col = _random.nextInt(cols);
        final pos = CellPosition(row, col);

        if (!occupiedCells.contains(pos)) {
          final direction = ArrowDirection.values[_random.nextInt(4)];
          final length = _random.nextInt(2) + 2;

          final segments = <CellPosition>[pos];
          var current = pos;

          for (int j = 1; j < length; j++) {
            final next = CellPosition(
              current.row + direction.delta.row,
              current.col + direction.delta.col,
            );

            if (next.row >= 0 &&
                next.row < rows &&
                next.col >= 0 &&
                next.col < cols &&
                !occupiedCells.contains(next)) {
              segments.add(next);
              current = next;
            } else {
              break;
            }
          }

          if (segments.length >= 2) {
            arrows.add(
              ComplexArrow(id: i, segments: segments, direction: direction),
            );
            occupiedCells.addAll(segments);
            break;
          }
        }
        attempts++;
      }
    }

    return GameBoard.withArrows(rows: rows, cols: cols, arrows: arrows);
  }

  List<CellPosition> _generateCurvedPath({
    required int startRow,
    required int startCol,
    required int targetLength,
    required int boardRows,
    required int boardCols,
    required Set<CellPosition> occupiedCells,
  }) {
    final segments = <CellPosition>[CellPosition(startRow, startCol)];
    var currentRow = startRow;
    var currentCol = startCol;

    final directions = [
      CellPosition(0, 1),
      CellPosition(0, -1),
      CellPosition(1, 0),
      CellPosition(-1, 0),
    ];

    int consecutiveSameDir = 0;
    CellPosition? lastDir;

    while (segments.length < targetLength) {
      final possibleDirs = <CellPosition>[];

      for (var dir in directions) {
        final newRow = currentRow + dir.row;
        final newCol = currentCol + dir.col;

        if (newRow >= 0 &&
            newRow < boardRows &&
            newCol >= 0 &&
            newCol < boardCols) {
          final newPos = CellPosition(newRow, newCol);
          if (!occupiedCells.contains(newPos) && !segments.contains(newPos)) {
            possibleDirs.add(dir);
          }
        }
      }

      if (possibleDirs.isEmpty) break;

      CellPosition chosenDir;
      if (consecutiveSameDir < 4 &&
          lastDir != null &&
          possibleDirs.contains(lastDir)) {
        chosenDir = _random.nextDouble() < 0.7
            ? lastDir
            : possibleDirs[_random.nextInt(possibleDirs.length)];
      } else {
        chosenDir = possibleDirs[_random.nextInt(possibleDirs.length)];
      }

      if (chosenDir == lastDir) {
        consecutiveSameDir++;
      } else {
        consecutiveSameDir = 1;
        lastDir = chosenDir;
      }

      currentRow += chosenDir.row;
      currentCol += chosenDir.col;
      segments.add(CellPosition(currentRow, currentCol));
    }

    return segments;
  }

  List<CellPosition> _generateRandomPath({
    required int startRow,
    required int startCol,
    required int targetLength,
    required int boardRows,
    required int boardCols,
    required Set<CellPosition> occupiedCells,
  }) {
    final segments = <CellPosition>[CellPosition(startRow, startCol)];
    var currentRow = startRow;
    var currentCol = startCol;

    final directions = [
      CellPosition(0, 1),
      CellPosition(0, -1),
      CellPosition(1, 0),
      CellPosition(-1, 0),
    ];

    while (segments.length < targetLength) {
      final possibleDirs = <CellPosition>[];

      for (var dir in directions) {
        final newRow = currentRow + dir.row;
        final newCol = currentCol + dir.col;

        if (newRow >= 0 &&
            newRow < boardRows &&
            newCol >= 0 &&
            newCol < boardCols) {
          final newPos = CellPosition(newRow, newCol);
          if (!occupiedCells.contains(newPos) && !segments.contains(newPos)) {
            possibleDirs.add(dir);
          }
        }
      }

      if (possibleDirs.isEmpty) break;

      final chosenDir = possibleDirs[_random.nextInt(possibleDirs.length)];
      currentRow += chosenDir.row;
      currentCol += chosenDir.col;
      segments.add(CellPosition(currentRow, currentCol));
    }

    return segments;
  }

  ArrowDirection _determineArrowDirection(List<CellPosition> segments) {
    if (segments.length < 2) return ArrowDirection.right;

    final head = segments.last;
    final beforeHead = segments[segments.length - 2];

    if (head.col > beforeHead.col) return ArrowDirection.right;
    if (head.col < beforeHead.col) return ArrowDirection.left;
    if (head.row > beforeHead.row) return ArrowDirection.down;
    return ArrowDirection.up;
  }

  MoveAxis _determineMoveAxis(List<CellPosition> segments) {
    if (segments.length < 2) return MoveAxis.both;

    bool hasHorizontal = false;
    bool hasVertical = false;

    for (int i = 1; i < segments.length; i++) {
      if (segments[i].row != segments[i - 1].row) hasVertical = true;
      if (segments[i].col != segments[i - 1].col) hasHorizontal = true;
    }

    if (hasHorizontal && hasVertical) return MoveAxis.both;
    if (hasHorizontal) return MoveAxis.horizontal;
    if (hasVertical) return MoveAxis.vertical;
    return MoveAxis.both;
  }

  bool _validateArrowNoSelfIntersection(ComplexArrow arrow) {
    final seen = <CellPosition>{};
    for (var pos in arrow.segments) {
      if (seen.contains(pos)) return false;
      seen.add(pos);
    }
    return true;
  }
}
