import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/models/game_board.dart';
import 'package:puzzle/models/complex_arrow.dart';
import 'package:puzzle/models/cell_position.dart';
import 'package:puzzle/models/arrow_enums.dart';
import 'package:puzzle/services/puzzle_solver.dart';

void main() {
  test('Debug: Simple single arrow pointing right', () {
    // Tạo board 5x5 với 1 arrow pointing right tại row 2
    // Arrow: (2,0) -> (2,1) -> (2,2) pointing RIGHT
    final board = GameBoard(rows: 5, cols: 5);

    final arrow = ComplexArrow(
      id: 0,
      segments: [CellPosition(2, 0), CellPosition(2, 1), CellPosition(2, 2)],
      direction: ArrowDirection.right,
      moveAxis: MoveAxis.horizontal,
    );

    board.arrows.add(arrow);

    // Cập nhật grid
    for (var pos in arrow.segments) {
      board.grid[pos.row][pos.col].occupied = true;
      board.grid[pos.row][pos.col].arrowId = arrow.id;
    }

    print('\n=== Board State ===');
    print(
      'Arrow ${arrow.id}: segments=${arrow.segments}, direction=${arrow.direction}',
    );
    print('Head: ${arrow.getHead()}');

    // Test hasImmediateMove
    final hasMove = PuzzleSolver.hasImmediateMove(board);
    print('hasImmediateMove: $hasMove');

    // Test isSolvable
    final solvable = PuzzleSolver.isSolvable(board, maxStates: 100);
    print('isSolvable: $solvable');

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
      segments: [CellPosition(2, 0), CellPosition(2, 1)],
      direction: ArrowDirection.right,
      moveAxis: MoveAxis.horizontal,
    );

    board.arrows.add(arrow);
    for (var pos in arrow.segments) {
      board.grid[pos.row][pos.col].occupied = true;
      board.grid[pos.row][pos.col].arrowId = arrow.id;
    }

    print('\n=== Testing canEscape ===');
    print('Arrow head: ${arrow.getHead()}'); // Should be (2,1)
    print('Direction: ${arrow.direction}'); // Should be right
    print('Delta: ${arrow.direction.delta}'); // Should be (0,1)

    // Manually trace
    final delta = arrow.direction.delta;
    var testHead = arrow.getHead();
    print('Starting head: $testHead');

    for (int i = 0; i < 5; i++) {
      testHead = CellPosition(
        testHead.row + delta.row,
        testHead.col + delta.col,
      );
      print(
        'Step $i: testHead=$testHead, inBounds=${board.isInBounds(testHead)}',
      );
      if (!board.isInBounds(testHead)) {
        print('  -> Can escape!');
        break;
      }
    }
  });
}
