/// Vị trí của một cell trên board (row, col)
class CellPosition {
  final int row;
  final int col;

  const CellPosition(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => '($row, $col)';

  /// Tạo từ JSON
  factory CellPosition.fromJson(List<dynamic> json) {
    return CellPosition(json[0] as int, json[1] as int);
  }

  /// Convert sang JSON
  List<int> toJson() => [row, col];
}
