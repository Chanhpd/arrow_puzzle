import 'package:injectable/injectable.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/types/result.dart';
import '../../domain/repositories/repositories.dart';

@LazySingleton(as: LevelRepository)
class LevelRepositoryImpl implements LevelRepository {
  const LevelRepositoryImpl(this._storage);

  final LocalStorageService _storage;

  @override
  Future<Result<int>> getCurrentLevel() async {
    try {
      final level = _storage.getInt(StorageKeys.currentLevel) ?? 1;
      return Result.success(level);
    } catch (e) {
      return Result.failure('Failed to get current level: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> saveCurrentLevel(int level) async {
    try {
      await _storage.saveInt(StorageKeys.currentLevel, level);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to save current level: ${e.toString()}');
    }
  }

  @override
  Future<Result<int?>> getBestMoves(int level) async {
    try {
      final moves = _storage.getInt('${StorageKeys.bestMoves}$level');
      return Result.success(moves);
    } catch (e) {
      return Result.failure('Failed to get best moves: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> saveBestMoves(int level, int moves) async {
    try {
      await _storage.saveInt('${StorageKeys.bestMoves}$level', moves);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to save best moves: ${e.toString()}');
    }
  }

  @override
  Future<Result<int>> getHighestLevel() async {
    try {
      final level = _storage.getInt(StorageKeys.highestLevel) ?? 1;
      return Result.success(level);
    } catch (e) {
      return Result.failure('Failed to get highest level: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> saveHighestLevel(int level) async {
    try {
      await _storage.saveInt(StorageKeys.highestLevel, level);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to save highest level: ${e.toString()}');
    }
  }
}
