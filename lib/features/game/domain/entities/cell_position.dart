import 'package:equatable/equatable.dart';

/// Vị trí của một cell trên board (row, col)
class CellPosition extends Equatable {
  const CellPosition(this.row, this.col);

  final int row;
  final int col;

  @override
  List<Object?> get props => [row, col];

  @override
  String toString() => '($row, $col)';
}
