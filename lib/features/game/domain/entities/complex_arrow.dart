import 'package:equatable/equatable.dart';
import 'cell_position.dart';
import 'arrow_enums.dart';

/// Mũi tên phức tạp với nhiều segments
class ComplexArrow extends Equatable {
  const ComplexArrow({
    required this.id,
    required this.segments,
    required this.direction,
    this.isExit = false,
    this.moveAxis = MoveAxis.both,
  });

  final int id;
  final List<CellPosition> segments;
  final ArrowDirection direction;
  final bool isExit;
  final MoveAxis moveAxis;

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

  @override
  List<Object?> get props => [id, segments, direction, isExit, moveAxis];

  @override
  String toString() {
    return 'Arrow($id: ${segments.length} cells, dir=$direction, exit=$isExit)';
  }
}
