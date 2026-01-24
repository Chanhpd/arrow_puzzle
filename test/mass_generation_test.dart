import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/services/level_generator.dart';
import 'package:puzzle/services/puzzle_solver.dart';

void main() {
  test('Generate 20 boards and verify ALL are solvable', () {
    final generator = LevelGenerator();
    int successCount = 0;
    int totalAttempts = 20;

    for (int i = 0; i < totalAttempts; i++) {
      print('\n========== Generating Board ${i + 1}/$totalAttempts ==========');

      final board = generator.generateBoard(
        rows: 10,
        cols: 10,
        numArrows: 12,
        densityTarget: 0.7,
        maxRetries: 100,
      );

      print('Board ${i + 1}: ${board.arrows.length} arrows');

      // Verify solvable
      final solvable = PuzzleSolver.isSolvable(board, maxStates: 10000);
      print('Solvable: $solvable');

      if (solvable) {
        successCount++;
      } else {
        print('❌ FAIL: Board ${i + 1} is NOT solvable!');
        print('Arrows:');
        for (var arrow in board.arrows) {
          print(
            '  Arrow ${arrow.id}: ${arrow.segments.length} segments, direction=${arrow.direction}',
          );
        }
      }
    }

    print('\n========== RESULTS ==========');
    print('Success: $successCount/$totalAttempts');
    print(
      'Success rate: ${(successCount / totalAttempts * 100).toStringAsFixed(1)}%',
    );

    expect(
      successCount,
      equals(totalAttempts),
      reason: 'All generated boards must be solvable',
    );
  });
}
