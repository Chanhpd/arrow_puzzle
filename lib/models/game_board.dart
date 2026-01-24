import 'cell_position.dart';
import 'complex_arrow.dart';

/// Cell trên board
class Cell {
  bool occupied;
  int? arrowId;

  Cell({this.occupied = false, this.arrowId});

  Cell copyWith({bool? occupied, int? arrowId}) {
    return Cell(
      occupied: occupied ?? this.occupied,
      arrowId: arrowId ?? this.arrowId,
    );
  }
}

/// Game board chứa grid và arrows
class GameBoard {
  final int rows;
  final int cols;
  late List<List<Cell>> grid;
  List<ComplexArrow> arrows;

  GameBoard({
    required this.rows,
    required this.cols,
    List<ComplexArrow>? arrows,
  }) : arrows = arrows ?? [] {
    // Khởi tạo grid
    grid = List.generate(rows, (row) => List.generate(cols, (col) => Cell()));

    // Populate grid với arrows
    _populateGridFromArrows();
  }

  /// Populate grid từ danh sách arrows
  void _populateGridFromArrows() {
    // Reset grid
    for (var row in grid) {
      for (var cell in row) {
        cell.occupied = false;
        cell.arrowId = null;
      }
    }

    // Fill với arrows
    for (var arrow in arrows) {
      for (var pos in arrow.segments) {
        if (pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < cols) {
          grid[pos.row][pos.col].occupied = true;
          grid[pos.row][pos.col].arrowId = arrow.id;
        }
      }
    }
  }

  /// Lấy arrow tại vị trí
  ComplexArrow? getArrowAt(CellPosition pos) {
    if (pos.row < 0 || pos.row >= rows || pos.col < 0 || pos.col >= cols) {
      return null;
    }

    final arrowId = grid[pos.row][pos.col].arrowId;
    if (arrowId == null) return null;

    return arrows.firstWhere(
      (a) => a.id == arrowId,
      orElse: () => arrows.first,
    );
  }

  /// Xóa arrow khỏi board (by ID để tránh reference issues)
  void removeArrow(ComplexArrow arrow) {
    arrows.removeWhere((a) => a.id == arrow.id);
    _populateGridFromArrows();
  }

  /// Cập nhật arrow
  void updateArrow(ComplexArrow arrow) {
    final index = arrows.indexWhere((a) => a.id == arrow.id);
    if (index >= 0) {
      arrows[index] = arrow;
      _populateGridFromArrows();
    }
  }

  /// Kiểm tra cell có bị chiếm không
  bool isCellOccupied(CellPosition pos) {
    if (pos.row < 0 || pos.row >= rows || pos.col < 0 || pos.col >= cols) {
      return false;
    }
    return grid[pos.row][pos.col].occupied;
  }

  /// Kiểm tra cell có trong board không
  bool isInBounds(CellPosition pos) {
    return pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < cols;
  }

  /// Copy board
  GameBoard copyWith({List<ComplexArrow>? arrows}) {
    return GameBoard(
      rows: rows,
      cols: cols,
      arrows: arrows ?? List<ComplexArrow>.from(this.arrows),
    );
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() {
    return {
      'rows': rows,
      'cols': cols,
      'arrows': arrows.map((a) => a.toJson()).toList(),
    };
  }

  /// Tạo từ JSON
  factory GameBoard.fromJson(Map<String, dynamic> json) {
    return GameBoard(
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      arrows: (json['arrows'] as List)
          .map((a) => ComplexArrow.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}
