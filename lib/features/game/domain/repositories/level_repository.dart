import '../../../../core/types/result.dart';

/// Repository interface for level progress
abstract class LevelRepository {
  /// Get current level
  Future<Result<int>> getCurrentLevel();

  /// Save current level
  Future<Result<void>> saveCurrentLevel(int level);

  /// Get best moves for a level
  Future<Result<int?>> getBestMoves(int level);

  /// Save best moves for a level
  Future<Result<void>> saveBestMoves(int level, int moves);

  /// Get highest level reached
  Future<Result<int>> getHighestLevel();

  /// Save highest level reached
  Future<Result<void>> saveHighestLevel(int level);
}
