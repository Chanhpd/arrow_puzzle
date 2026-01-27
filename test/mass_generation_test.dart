import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/core/utils/logger.dart';
import 'package:puzzle/services/level_generator.dart';
import 'package:puzzle/services/puzzle_solver.dart';

void main() {
  test('Generate 20 boards and verify ALL are solvable', () {
    final generator = LevelGenerator();
    int successCount = 0;
    int totalAttempts = 20;

    for (int i = 0; i < totalAttempts; i++) {
      logger.i(
          '\n========== Generating Board ${i + 1}/$totalAttempts =========='
      );

      final board = generator.generateBoard(
        rows: 10,
        cols: 10,
        numArrows: 12,
        densityTarget: 0.7,
        maxRetries: 100,
      );

      logger.d('Board ${i + 1}: ${board.arrows.length} arrows');

      // Verify solvable
      final solvable = PuzzleSolver.isSolvable(
        board,
        maxStates: 10000,
      );

      if (solvable) {
        logger.i('Solvable: true');
        successCount++;
      } else {
        logger.e('❌ FAIL: Board ${i + 1} is NOT solvable');

        logger.e('Arrows detail:');
        for (var arrow in board.arrows) {
          logger.e(
            'Arrow ${arrow.id}: '
                '${arrow.segments.length} segments, '
                'direction=${arrow.direction}',
          );
        }
      }
    }

    logger.i('\n========== RESULTS ==========');
    logger.i('Success: $successCount/$totalAttempts');
    logger.i(
      'Success rate: '
          '${(successCount / totalAttempts * 100).toStringAsFixed(1)}%',
    );

    expect(
      successCount,
      equals(totalAttempts),
      reason: 'All generated boards must be solvable',
    );
  });
}
