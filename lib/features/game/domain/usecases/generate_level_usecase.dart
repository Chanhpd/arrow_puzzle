import 'package:injectable/injectable.dart';
import '../../../../core/types/result.dart';
import '../entities/entities.dart';
import '../repositories/repositories.dart';

@injectable
class GenerateLevelUseCase {
  const GenerateLevelUseCase(this._repository);

  final GameRepository _repository;

  Future<Result<GameBoard>> call({required int level}) async {
    // Lấy cấu hình level dựa trên level number
    final config = _getLevelConfig(level);

    return await _repository.generateBoard(
      rows: config['rows'] as int,
      cols: config['cols'] as int,
      numArrows: config['numArrows'] as int,
      densityTarget: config['density'] as double,
    );
  }

  /// Lấy cấu hình level dựa trên level number
  Map<String, dynamic> _getLevelConfig(int level) {
    int rows, cols, numArrows;
    double density;

    if (level <= 5) {
      rows = cols = 10;
      numArrows = 10 + (level * 2);
      density = 0.55 + (level * 0.02);
    } else if (level <= 10) {
      rows = cols = 12;
      numArrows = 18 + ((level - 5) * 2);
      density = 0.60 + ((level - 5) * 0.01);
    } else if (level <= 15) {
      rows = cols = 14;
      numArrows = 22 + ((level - 10) * 2);
      density = 0.58 + ((level - 10) * 0.015);
    } else if (level <= 50) {
      rows = cols = 16;
      numArrows = 28 + ((level - 15) * 2);
      density = 0.60 + ((level - 15) * 0.005);
      if (density > 0.70) density = 0.70;
    } else if (level <= 100) {
      rows = cols = 16;
      numArrows = 35 + ((level - 50));
      density = 0.65 + ((level - 50) * 0.003);
      if (density > 0.75) density = 0.75;
    } else {
      rows = cols = 16;
      numArrows = 40 + ((level - 100));
      density = 0.70 + ((level - 100) * 0.001);
      if (density > 0.80) density = 0.80;
      if (numArrows > 100) numArrows = 100;
    }

    return {
      'rows': rows,
      'cols': cols,
      'numArrows': numArrows,
      'density': density,
    };
  }
}
