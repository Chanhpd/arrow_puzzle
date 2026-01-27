import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/entities.dart';
import '../../domain/usecases/usecases.dart';
import 'game_state.dart';

@injectable
class GameCubit extends Cubit<GameState> {
  GameCubit(
    this._generateLevelUseCase,
    this._moveArrowUseCase,
    this._getCurrentLevelUseCase,
    this._saveLevelProgressUseCase,
  ) : super(const GameState());

  final GenerateLevelUseCase _generateLevelUseCase;
  final MoveArrowUseCase _moveArrowUseCase;
  final GetCurrentLevelUseCase _getCurrentLevelUseCase;
  final SaveLevelProgressUseCase _saveLevelProgressUseCase;

  /// Load current level from storage
  Future<void> loadCurrentLevel() async {
    final result = await _getCurrentLevelUseCase();
    result.when(
      success: (level) {
        emit(state.copyWith(currentLevel: level));
      },
      failure: (message, _) {
        logger.e('Failed to load current level: $message');
        emit(state.copyWith(currentLevel: 1));
      },
    );
  }

  /// Generate new level
  Future<void> generateLevel({int? level}) async {
    if (state.isAnimating) return;

    final targetLevel = level ?? state.currentLevel;
    emit(
      state.copyWith(isLoading: true, error: null, currentLevel: targetLevel),
    );

    try {
      final result = await _generateLevelUseCase(level: targetLevel);

      result.when(
        success: (board) {
          logger.i(
            'Generated level $targetLevel with ${board.arrows.length} arrows',
          );
          emit(state.copyWith(board: board, movesCount: 0, isLoading: false));
        },
        failure: (message, exception) {
          logger.e('Failed to generate level $message');
          emit(state.copyWith(isLoading: false, error: message));
        },
      );
    } catch (e) {
      logger.e('Error generating level $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Handle arrow click to escape
  Future<void> onArrowClicked(ComplexArrow arrow) async {
    if (state.board == null || state.isAnimating) return;

    emit(state.copyWith(isAnimating: true));

    try {
      // Move arrow to escape
      final result = _moveArrowUseCase(board: state.board!, arrow: arrow);

      result.when(
        success: (newBoard) async {
          logger.i('Arrow ${arrow.id} escaped successfully');

          // Animate escape
          await _animateArrowEscape(arrow, newBoard);

          // Update moves count and check if won
          final newMovesCount = state.movesCount + 1;
          emit(
            state.copyWith(
              board: newBoard,
              movesCount: newMovesCount,
              isAnimating: false,
              animatingArrow: null,
              animationPath: null,
              animationProgress: 0.0,
            ),
          );

          // If game won, save progress
          if (newBoard.arrows.isEmpty) {
            logger.i(
              'Level ${state.currentLevel} completed in $newMovesCount moves!',
            );
            await _saveLevelProgressUseCase(
              level: state.currentLevel,
              moves: newMovesCount,
            );
          }
        },
        failure: (message, _) {
          logger.w('Arrow ${arrow.id} cannot escape: $message');
          emit(
            state.copyWith(isAnimating: false, error: 'This arrow is blocked!'),
          );
        },
      );
    } catch (e) {
      logger.e('Error moving arrow  $e');
      emit(state.copyWith(isAnimating: false, error: e.toString()));
    }
  }

  /// Animate arrow escape
  Future<void> _animateArrowEscape(
    ComplexArrow arrow,
    GameBoard finalBoard,
  ) async {
    final delta = arrow.direction.delta;
    emit(
      state.copyWith(
        animatingArrow: arrow,
        animationPath: List<CellPosition>.from(arrow.segments),
      ),
    );

    var currentSegments = List<CellPosition>.from(arrow.segments);

    // Animate snake-like movement
    while (currentSegments.isNotEmpty) {
      final head = currentSegments.last;
      final newHead = CellPosition(head.row + delta.row, head.col + delta.col);

      // Smooth progress animation
      for (double progress = 0.0; progress <= 1.0; progress += 0.1) {
        emit(state.copyWith(animationProgress: progress));
        await Future.delayed(const Duration(milliseconds: 5));
      }

      // Move snake: remove tail
      currentSegments.removeAt(0);

      // Add new head only if current head is still in bounds
      if (state.board!.isValidPosition(head)) {
        currentSegments.add(newHead);
      }

      emit(
        state.copyWith(
          animationPath: List<CellPosition>.from(currentSegments),
          animationProgress: 0.0,
        ),
      );

      if (currentSegments.isEmpty) break;
    }
  }

  /// Next level
  Future<void> nextLevel() async {
    await generateLevel(level: state.currentLevel + 1);
  }

  /// Restart current level
  Future<void> restartLevel() async {
    await generateLevel(level: state.currentLevel);
  }

  /// Reset to level 1
  Future<void> resetGame() async {
    await generateLevel(level: 1);
  }
}
