import 'package:injectable/injectable.dart';
import '../../../../core/types/result.dart';
import '../repositories/repositories.dart';

@injectable
class GetCurrentLevelUseCase {
  const GetCurrentLevelUseCase(this._repository);

  final LevelRepository _repository;

  Future<Result<int>> call() async {
    return await _repository.getCurrentLevel();
  }
}
