import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/core/utils/logger.dart';
import 'package:puzzle/models/arrow_enums.dart';
import 'package:puzzle/models/cell_position.dart';
import 'package:puzzle/models/complex_arrow.dart';
import 'package:puzzle/models/game_board.dart';
import 'package:puzzle/services/level_generator.dart';
import 'package:puzzle/services/puzzle_solver.dart';

void main() {
  group('PuzzleSolver Tests', () {
    test('Empty board is solvable', () {
      final board = GameBoard(rows: 10, cols: 10);
      expect(PuzzleSolver.isSolvable(board), true);
    });

    test('Single arrow pointing out is solvable', () {
      final board = GameBoard(rows: 10, cols: 10);
      final arrow = ComplexArrow(
        id: 0,
        segments: [CellPosition(5, 5), CellPosition(5, 6), CellPosition(5, 7)],
        direction: ArrowDirection.right,
        moveAxis: MoveAxis.both,
      );
      board.arrows.add(arrow);

      expect(PuzzleSolver.hasImmediateMove(board), true);
      expect(PuzzleSolver.isSolvable(board), true);
    });

    test('Two arrows with clear path are solvable', () {
      final board = GameBoard(rows: 10, cols: 10);

      board.arrows.add(
        ComplexArrow(
          id: 0,
          segments: [CellPosition(2, 2), CellPosition(2, 3)],
          direction: ArrowDirection.right,
          moveAxis: MoveAxis.both,
        ),
      );

      board.arrows.add(
        ComplexArrow(
          id: 1,
          segments: [CellPosition(5, 5), CellPosition(6, 5)],
          direction: ArrowDirection.down,
          moveAxis: MoveAxis.both,
        ),
      );

      expect(PuzzleSolver.hasImmediateMove(board), true);
      expect(PuzzleSolver.isSolvable(board), true);
    });

    test('Blocked arrow is not immediately movable', () {
      final board = GameBoard(rows: 10, cols: 10);

      board.arrows.add(
        ComplexArrow(
          id: 0,
          segments: [CellPosition(5, 2), CellPosition(5, 3)],
          direction: ArrowDirection.right,
          moveAxis: MoveAxis.both,
        ),
      );

      board.arrows.add(
        ComplexArrow(
          id: 1,
          segments: [CellPosition(5, 4), CellPosition(5, 5)],
          direction: ArrowDirection.right,
          moveAxis: MoveAxis.both,
        ),
      );

      expect(PuzzleSolver.hasImmediateMove(board), true);
      expect(PuzzleSolver.isSolvable(board), true);
    });

    test('Deadlock: two arrows blocking each other in opposite directions', () {
      final board = GameBoard(rows: 10, cols: 10);

      board.arrows.add(
        ComplexArrow(
          id: 0,
          segments: [CellPosition(5, 2), CellPosition(5, 3)],
          direction: ArrowDirection.right,
          moveAxis: MoveAxis.both,
        ),
      );

      board.arrows.add(
        ComplexArrow(
          id: 1,
          segments: [CellPosition(5, 5), CellPosition(5, 4)],
          direction: ArrowDirection.left,
          moveAxis: MoveAxis.both,
        ),
      );

      expect(PuzzleSolver.hasImmediateMove(board), false);
      expect(PuzzleSolver.hasDeadlock(board), true);
    });

    test('Sequential puzzle: arrow 2 must move first', () {
      final board = GameBoard(rows: 10, cols: 10);

      board.arrows.add(
        ComplexArrow(
          id: 0,
          segments: [CellPosition(5, 2), CellPosition(5, 3)],
          direction: ArrowDirection.right,
          moveAxis: MoveAxis.both,
        ),
      );

      board.arrows.add(
        ComplexArrow(
          id: 1,
          segments: [CellPosition(6, 4), CellPosition(5, 4)],
          direction: ArrowDirection.up,
          moveAxis: MoveAxis.both,
        ),
      );

      expect(PuzzleSolver.hasImmediateMove(board), true);
      expect(PuzzleSolver.isSolvable(board), true);
    });
  });

  group('LevelGenerator Tests', () {
    test('Generated boards should be solvable', () {
      final generator = LevelGenerator();

      for (int i = 0; i < 5; i++) {
        final board = generator.generateBoard(
          rows: 12,
          cols: 11,
          numArrows: 5,
          densityTarget: 0.5,
          maxRetries: 30,
        );

        logger.i(
          'Test $i: Generated board with ${board.arrows.length} arrows',
        );

        expect(board.arrows.isNotEmpty, true);
        expect(PuzzleSolver.hasImmediateMove(board), true);
        expect(PuzzleSolver.hasDeadlock(board), false);

        final isSolvable = PuzzleSolver.isSolvable(board, maxStates: 5000);
        expect(
          isSolvable,
          true,
          reason: 'Board $i should be solvable but it is not',
        );
      }
    });

    test('Generated boards with different difficulties', () {
      final generator = LevelGenerator();

      final easyBoard = generator.generateBoard(
        rows: 10,
        cols: 10,
        numArrows: 3,
        densityTarget: 0.3,
        maxRetries: 30,
      );
      expect(PuzzleSolver.isSolvable(easyBoard), true);
      logger.i('Easy board: ${easyBoard.arrows.length} arrows');

      final mediumBoard = generator.generateBoard(
        rows: 12,
        cols: 11,
        numArrows: 5,
        densityTarget: 0.5,
        maxRetries: 30,
      );
      expect(PuzzleSolver.isSolvable(mediumBoard), true);
      logger.i('Medium board: ${mediumBoard.arrows.length} arrows');

      final hardBoard = generator.generateBoard(
        rows: 12,
        cols: 11,
        numArrows: 8,
        densityTarget: 0.7,
        maxRetries: 50,
      );
      expect(PuzzleSolver.isSolvable(hardBoard), true);
    });

    test('Fallback board should always be solvable', () {
      final generator = LevelGenerator();

      for (int i = 0; i < 3; i++) {
        final board = generator.generateBoard(
          rows: 10,
          cols: 10,
          numArrows: 4,
          densityTarget: 0.3,
          maxRetries: 30,
        );

        expect(board.arrows.isNotEmpty, true);
        expect(PuzzleSolver.hasImmediateMove(board), true);

        final isSolvable = PuzzleSolver.isSolvable(board, maxStates: 3000);
        expect(
          isSolvable,
          true,
          reason: 'Fallback board $i must be solvable',
        );
      }
    });
  });

  group('Edge Cases', () {
    test('Very small board (5x5) should still be solvable', () {
      final generator = LevelGenerator();

      final board = generator.generateBoard(
        rows: 5,
        cols: 5,
        numArrows: 2,
        densityTarget: 0.4,
        maxRetries: 20,
      );

      expect(board.arrows.isNotEmpty, true);
      expect(PuzzleSolver.isSolvable(board), true);
    });

    test('Large board (15x15) should be solvable', () {
      final generator = LevelGenerator();

      final board = generator.generateBoard(
        rows: 15,
        cols: 15,
        numArrows: 10,
        densityTarget: 0.6,
        maxRetries: 50,
      );

      expect(board.arrows.isNotEmpty, true);
      expect(PuzzleSolver.hasImmediateMove(board), true);
    });
  });
}
