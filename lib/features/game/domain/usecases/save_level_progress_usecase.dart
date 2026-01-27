import 'package:injectable/injectable.dart';
import '../../../../core/types/result.dart';
import '../repositories/repositories.dart';

@injectable
class SaveLevelProgressUseCase {
  const SaveLevelProgressUseCase(this._repository);

  final LevelRepository _repository;

  Future<Result<void>> call({required int level, required int moves}) async {
    // Save current level
    final levelResult = await _repository.saveCurrentLevel(level);
    if (levelResult.isFailure) return levelResult;

    // Save best moves
    final bestMovesResult = await _repository.getBestMoves(level);
    final currentBest = bestMovesResult.dataOrNull;

    if (currentBest == null || moves < currentBest) {
      await _repository.saveBestMoves(level, moves);
    }

    // Update highest level
    final highestResult = await _repository.getHighestLevel();
    final currentHighest = highestResult.dataOrNull ?? 1;

    if (level > currentHighest) {
      await _repository.saveHighestLevel(level);
    }

    return Result.success(null);
  }
}
