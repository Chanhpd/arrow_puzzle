import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/core/utils/logger.dart';
import 'package:puzzle/models/game_board.dart';
import 'package:puzzle/models/complex_arrow.dart';
import 'package:puzzle/models/cell_position.dart';
import 'package:puzzle/models/arrow_enums.dart';
import 'package:puzzle/services/puzzle_solver.dart';

void main() {
  test('Debug: Simple single arrow pointing right', () {
    final board = GameBoard(rows: 5, cols: 5);

    final arrow = ComplexArrow(
      id: 0,
      segments: [
        CellPosition(2, 0),
        CellPosition(2, 1),
        CellPosition(2, 2),
      ],
      direction: ArrowDirection.right,
      moveAxis: MoveAxis.horizontal,
    );

    board.arrows.add(arrow);

    for (var pos in arrow.segments) {
      board.grid[pos.row][pos.col].occupied = true;
      board.grid[pos.row][pos.col].arrowId = arrow.id;
    }

    logger.i('\n=== Board State ===');
    logger.d(
      'Arrow ${arrow.id}: '
          'segments=${arrow.segments}, '
          'direction=${arrow.direction}',
    );
    logger.d('Head: ${arrow.getHead()}');

    final hasMove = PuzzleSolver.hasImmediateMove(board);
    logger.i('hasImmediateMove: $hasMove');

    final solvable = PuzzleSolver.isSolvable(board, maxStates: 100);
    logger.i('isSolvable: $solvable');

    expect(hasMove, isTrue, reason: 'Arrow should be able to move right');
    expect(
      solvable,
      isTrue,
      reason: 'Single arrow pointing right should be solvable',
    );
  });

  test('Debug: Check canEscape logic', () {
    final board = GameBoard(rows: 5, cols: 5);

    final arrow = ComplexArrow(
      id: 0,
      segments: [
        CellPosition(2, 0),
        CellPosition(2, 1),
      ],
      direction: ArrowDirection.right,
      moveAxis: MoveAxis.horizontal,
    );

    board.arrows.add(arrow);
    for (var pos in arrow.segments) {
      board.grid[pos.row][pos.col].occupied = true;
      board.grid[pos.row][pos.col].arrowId = arrow.id;
    }

    logger.i('\n=== Testing canEscape ===');
    logger.d('Arrow head: ${arrow.getHead()}'); // expected (2,1)
    logger.d('Direction: ${arrow.direction}');
    logger.d('Delta: ${arrow.direction.delta}');

    final delta = arrow.direction.delta;
    var testHead = arrow.getHead();
    logger.d('Starting head: $testHead');

    for (int i = 0; i < 5; i++) {
      testHead = CellPosition(
        testHead.row + delta.row,
        testHead.col + delta.col,
      );

      logger.d(
        'Step $i: '
            'testHead=$testHead, '
            'inBounds=${board.isInBounds(testHead)}',
      );

      if (!board.isInBounds(testHead)) {
        logger.i('-> Can escape!');
        break;
      }
    }
  });
}
