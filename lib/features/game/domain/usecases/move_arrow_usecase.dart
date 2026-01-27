import 'package:injectable/injectable.dart';
import '../../../../core/types/result.dart';
import '../entities/entities.dart';
import '../repositories/repositories.dart';

@injectable
class MoveArrowUseCase {
  const MoveArrowUseCase(this._repository);

  final GameRepository _repository;

  Result<GameBoard> call({
    required GameBoard board,
    required ComplexArrow arrow,
  }) {
    return _repository.moveArrowToEscape(board: board, arrow: arrow);
  }
}
