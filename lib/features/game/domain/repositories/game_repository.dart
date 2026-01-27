import '../../../../core/types/result.dart';
import '../entities/entities.dart';

/// Repository interface for game operations
abstract class GameRepository {
  /// Generate a new game board
  Future<Result<GameBoard>> generateBoard({
    required int rows,
    required int cols,
    required int numArrows,
    double densityTarget = 0.75,
  });

  /// Calculate arrow escape path
  Result<List<CellPosition>> calculateEscapePath({
    required GameBoard board,
    required ComplexArrow arrow,
  });

  /// Move arrow to escape
  Result<GameBoard> moveArrowToEscape({
    required GameBoard board,
    required ComplexArrow arrow,
  });

  /// Check if puzzle is solvable
  Future<Result<bool>> checkSolvability(GameBoard board);
}
