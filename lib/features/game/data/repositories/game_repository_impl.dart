import 'package:injectable/injectable.dart';
import '../../../../core/types/result.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../services/level_generator_service.dart';
import '../services/puzzle_solver_service.dart';

@LazySingleton(as: GameRepository)
class GameRepositoryImpl implements GameRepository {
  const GameRepositoryImpl(this._generatorService, this._solverService);

  final LevelGeneratorService _generatorService;
  final PuzzleSolverService _solverService;

  @override
  Future<Result<GameBoard>> generateBoard({
    required int rows,
    required int cols,
    required int numArrows,
    double densityTarget = 0.75,
  }) async {
    try {
      final board = _generatorService.generateBoard(
        rows: rows,
        cols: cols,
        numArrows: numArrows,
        densityTarget: densityTarget,
      );
      return Result.success(board);
    } catch (e) {
      return Result.failure('Failed to generate board: ${e.toString()}');
    }
  }

  @override
  Result<List<CellPosition>> calculateEscapePath({
    required GameBoard board,
    required ComplexArrow arrow,
  }) {
    try {
      final path = _solverService.calculateEscapePath(board, arrow);
      if (path.isEmpty) {
        return Result.failure('No escape path found for arrow ${arrow.id}');
      }
      return Result.success(path);
    } catch (e) {
      return Result.failure('Failed to calculate escape path: ${e.toString()}');
    }
  }

  @override
  Result<GameBoard> moveArrowToEscape({
    required GameBoard board,
    required ComplexArrow arrow,
  }) {
    try {
      // Check if arrow can escape
      if (!_solverService.canEscape(board, arrow)) {
        return Result.failure('Arrow ${arrow.id} cannot escape');
      }

      // Remove arrow from board
      final newBoard = board.removeArrow(arrow.id);
      return Result.success(newBoard);
    } catch (e) {
      return Result.failure('Failed to move arrow: ${e.toString()}');
    }
  }

  @override
  Future<Result<bool>> checkSolvability(GameBoard board) async {
    try {
      final isSolvable = _solverService.isSolvable(board);
      return Result.success(isSolvable);
    } catch (e) {
      return Result.failure('Failed to check solvability: ${e.toString()}');
    }
  }
}
