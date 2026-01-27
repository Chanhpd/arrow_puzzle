import 'package:equatable/equatable.dart';
import 'cell_position.dart';
import 'complex_arrow.dart';

/// Cell trên board
class Cell extends Equatable {
  const Cell({this.occupied = false, this.arrowId});

  final bool occupied;
  final int? arrowId;

  Cell copyWith({bool? occupied, int? arrowId}) {
    return Cell(
      occupied: occupied ?? this.occupied,
      arrowId: arrowId ?? this.arrowId,
    );
  }

  @override
  List<Object?> get props => [occupied, arrowId];
}

/// Game board chứa grid và arrows
class GameBoard extends Equatable {
  const GameBoard({
    required this.rows,
    required this.cols,
    required this.grid,
    required this.arrows,
  });

  final int rows;
  final int cols;
  final List<List<Cell>> grid;
  final List<ComplexArrow> arrows;

  /// Create empty board
  factory GameBoard.empty({required int rows, required int cols}) {
    final grid = List.generate(
      rows,
      (row) => List.generate(cols, (col) => const Cell()),
    );
    return GameBoard(rows: rows, cols: cols, grid: grid, arrows: []);
  }

  /// Create board with arrows
  factory GameBoard.withArrows({
    required int rows,
    required int cols,
    required List<ComplexArrow> arrows,
  }) {
    // Khởi tạo grid rỗng
    final grid = List.generate(
      rows,
      (row) => List.generate(cols, (col) => const Cell()),
    );

    // Populate grid với arrows
    for (var arrow in arrows) {
      for (var pos in arrow.segments) {
        if (pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < cols) {
          grid[pos.row][pos.col] = Cell(occupied: true, arrowId: arrow.id);
        }
      }
    }

    return GameBoard(rows: rows, cols: cols, grid: grid, arrows: arrows);
  }

  /// Check if position is valid
  bool isValidPosition(CellPosition pos) {
    return pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < cols;
  }

  /// Check if cell is occupied
  bool isOccupied(CellPosition pos) {
    if (!isValidPosition(pos)) return true;
    return grid[pos.row][pos.col].occupied;
  }

  /// Get arrow at position
  ComplexArrow? getArrowAt(CellPosition pos) {
    if (!isValidPosition(pos)) return null;
    final arrowId = grid[pos.row][pos.col].arrowId;
    if (arrowId == null) return null;
    try {
      return arrows.firstWhere((a) => a.id == arrowId);
    } catch (_) {
      return null;
    }
  }

  /// Remove arrow from board
  GameBoard removeArrow(int arrowId) {
    final newArrows = arrows.where((a) => a.id != arrowId).toList();
    return GameBoard.withArrows(rows: rows, cols: cols, arrows: newArrows);
  }

  /// Update arrow on board
  GameBoard updateArrow(ComplexArrow arrow) {
    final newArrows = arrows.map((a) => a.id == arrow.id ? arrow : a).toList();
    return GameBoard.withArrows(rows: rows, cols: cols, arrows: newArrows);
  }

  /// Check if game is won (no arrows left)
  bool get isWon => arrows.isEmpty;

  @override
  List<Object?> get props => [rows, cols, grid, arrows];
}
