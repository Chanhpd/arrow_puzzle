import 'package:equatable/equatable.dart';
import '../../domain/entities/entities.dart';

/// Game state
class GameState extends Equatable {
  const GameState({
    this.board,
    this.currentLevel = 1,
    this.movesCount = 0,
    this.isLoading = false,
    this.isAnimating = false,
    this.animatingArrow,
    this.animationPath,
    this.animationProgress = 0.0,
    this.error,
  });

  final GameBoard? board;
  final int currentLevel;
  final int movesCount;
  final bool isLoading;
  final bool isAnimating;
  final ComplexArrow? animatingArrow;
  final List<CellPosition>? animationPath;
  final double animationProgress;
  final String? error;

  bool get isGameWon => board != null && board!.arrows.isEmpty;

  GameState copyWith({
    GameBoard? board,
    int? currentLevel,
    int? movesCount,
    bool? isLoading,
    bool? isAnimating,
    ComplexArrow? animatingArrow,
    List<CellPosition>? animationPath,
    double? animationProgress,
    String? error,
  }) {
    return GameState(
      board: board ?? this.board,
      currentLevel: currentLevel ?? this.currentLevel,
      movesCount: movesCount ?? this.movesCount,
      isLoading: isLoading ?? this.isLoading,
      isAnimating: isAnimating ?? this.isAnimating,
      animatingArrow: animatingArrow ?? this.animatingArrow,
      animationPath: animationPath ?? this.animationPath,
      animationProgress: animationProgress ?? this.animationProgress,
      error: error,
    );
  }

  GameState clearError() {
    return copyWith(error: null);
  }

  @override
  List<Object?> get props => [
    board,
    currentLevel,
    movesCount,
    isLoading,
    isAnimating,
    animatingArrow,
    animationPath,
    animationProgress,
    error,
  ];
}
