import 'cell_position.dart';
import 'arrow_enums.dart';

/// Mũi tên phức tạp với nhiều segments
class ComplexArrow {
  final int id;
  List<CellPosition> segments;
  final ArrowDirection direction;
  bool isExit;
  MoveAxis moveAxis;

  ComplexArrow({
    required this.id,
    required this.segments,
    required this.direction,
    this.isExit = false,
    this.moveAxis = MoveAxis.both,
  });

  /// Lấy tất cả cells mà arrow chiếm
  List<CellPosition> getOccupiedCells() {
    return List<CellPosition>.from(segments);
  }

  /// Lấy cell đầu (head) của arrow
  CellPosition getHead() {
    return segments.last;
  }

  /// Lấy cell đuôi (tail) của arrow
  CellPosition getTail() {
    return segments.first;
  }

  /// Copy arrow với segments mới
  ComplexArrow copyWith({
    List<CellPosition>? segments,
    ArrowDirection? direction,
    bool? isExit,
    MoveAxis? moveAxis,
  }) {
    return ComplexArrow(
      id: id,
      segments: segments ?? this.segments,
      direction: direction ?? this.direction,
      isExit: isExit ?? this.isExit,
      moveAxis: moveAxis ?? this.moveAxis,
    );
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'segments': segments.map((s) => s.toJson()).toList(),
      'direction': direction.displayName,
      'isExit': isExit,
      'moveAxis': moveAxis.displayName,
    };
  }

  /// Tạo từ JSON
  factory ComplexArrow.fromJson(Map<String, dynamic> json) {
    return ComplexArrow(
      id: json['id'] as int,
      segments: (json['segments'] as List)
          .map((s) => CellPosition.fromJson(s as List))
          .toList(),
      direction: ArrowDirection.fromString(json['direction'] as String),
      isExit: json['isExit'] as bool? ?? false,
      moveAxis: MoveAxis.fromString(json['moveAxis'] as String? ?? 'both'),
    );
  }

  @override
  String toString() {
    return 'Arrow($id: ${segments.length} cells, dir=$direction, exit=$isExit)';
  }
}
