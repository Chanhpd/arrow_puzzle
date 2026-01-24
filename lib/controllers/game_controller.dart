import 'package:flutter/foundation.dart';
import '../models/game_board.dart';
import '../models/complex_arrow.dart';
import '../models/cell_position.dart';
import '../services/level_generator.dart';

/// Game controller - quản lý state và logic
class GameController extends ChangeNotifier {
  GameBoard? _board;
  int _movesCount = 0;
  bool _isAnimating = false;
  ComplexArrow? _animatingArrow;
  List<CellPosition>? _animationPath;
  double _animationProgress = 0.0;
  int _currentLevel = 1;

  GameBoard? get board => _board;
  int get movesCount => _movesCount;
  bool get isAnimating => _isAnimating;
  bool get isGameWon => _board != null && _board!.arrows.isEmpty;
  ComplexArrow? get animatingArrow => _animatingArrow;
  List<CellPosition>? get animationPath => _animationPath;
  double get animationProgress => _animationProgress;
  int get currentLevel => _currentLevel;

  /// Lấy cấu hình level dựa trên level number
  Map<String, dynamic> _getLevelConfig(int level) {
    // Level 1-5: 10x10 grid
    // Level 6-10: 12x12 grid
    // Level 11-15: 14x14 grid
    // Level 16+: 16x16 grid

    int rows, cols, numArrows;
    double density;

    if (level <= 5) {
      rows = cols = 10;
      numArrows = 10 + (level * 2); // 12, 14, 16, 18, 20
      density = 0.60 + (level * 0.02); // 0.62 - 0.70
    } else if (level <= 10) {
      rows = cols = 12;
      numArrows = 18 + ((level - 5) * 2); // 20, 22, 24, 26, 28
      density = 0.65 + ((level - 5) * 0.02); // 0.67 - 0.75
    } else if (level <= 15) {
      rows = cols = 14;
      numArrows = 24 + ((level - 10) * 3); // 27, 30, 33, 36, 39
      density = 0.68 + ((level - 10) * 0.02); // 0.70 - 0.78
    } else {
      rows = cols = 16;
      numArrows = 35 + ((level - 15) * 3); // 38, 41, 44...
      density = 0.70 + ((level - 15) * 0.01); // 0.71+
      if (density > 0.85) density = 0.85; // Cap at 85%
    }

    return {
      'rows': rows,
      'cols': cols,
      'numArrows': numArrows,
      'density': density,
    };
  }

  /// Tạo level mới
  Future<void> generateLevel({int? level}) async {
    if (level != null) {
      _currentLevel = level;
    }

    final config = _getLevelConfig(_currentLevel);
    final generator = LevelGenerator();

    _board = generator.generateBoard(
      rows: config['rows'],
      cols: config['cols'],
      numArrows: config['numArrows'],
      densityTarget: config['density'],
    );
    _movesCount = 0;
    notifyListeners();
  }

  /// Click vào arrow để escape
  Future<void> onArrowClicked(ComplexArrow arrow) async {
    if (_board == null || _isAnimating) return;

    _isAnimating = true;
    notifyListeners();

    final canEscape = await _checkIfCanEscape(arrow);

    if (!canEscape) {
      debugPrint('Arrow ${arrow.id} BLOCKED - cannot escape!');
      _isAnimating = false;
      notifyListeners();
      return;
    }

    // Escape with animation
    await _animateArrowEscape(arrow);

    _movesCount++;
    _isAnimating = false;
    notifyListeners();
  }

  /// Kiểm tra arrow có thể escape không
  Future<bool> _checkIfCanEscape(ComplexArrow arrow) async {
    final delta = arrow.direction.delta;
    final occupiedByOthers = <CellPosition>{};

    // Lấy cells bị chiếm bởi arrows khác
    for (var other in _board!.arrows) {
      if (other.id != arrow.id) {
        occupiedByOthers.addAll(other.segments);
      }
    }

    // Simulate di chuyển
    var testHead = arrow.getHead();
    final maxSteps = _board!.rows + _board!.cols + 20;

    for (int step = 0; step < maxSteps; step++) {
      testHead = CellPosition(
        testHead.row + delta.row,
        testHead.col + delta.col,
      );

      // Nếu ra ngoài board = có thể escape
      if (!_board!.isInBounds(testHead)) {
        return true;
      }

      // Nếu va chạm = không thể escape
      if (occupiedByOthers.contains(testHead)) {
        return false;
      }
    }

    return false;
  }

  /// Animate arrow escape (kiểu rắn) với smooth animation
  Future<void> _animateArrowEscape(ComplexArrow arrow) async {
    final delta = arrow.direction.delta;
    _animatingArrow = arrow;
    _animationPath = List<CellPosition>.from(arrow.segments);

    // Phase 1: Di chuyển cho đến khi head chạm edge
    while (arrow.segments.isNotEmpty) {
      final head = arrow.getHead();
      final newHead = CellPosition(head.row + delta.row, head.col + delta.col);

      // Nếu head ra ngoài board - bắt đầu escape animation
      if (!_board!.isInBounds(newHead)) {
        break;
      }

      // Animate smooth movement
      for (double progress = 0.0; progress <= 1.0; progress += 0.1) {
        _animationProgress = progress;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 5));
      }

      // Di chuyển kiểu rắn: xóa đuôi, thêm head mới
      final newSegments = List<CellPosition>.from(arrow.segments);
      newSegments.removeAt(0); // Xóa đuôi
      newSegments.add(newHead); // Thêm head mới

      arrow.segments = newSegments;
      _animationPath = newSegments;
      _board!.updateArrow(arrow);
      _animationProgress = 0.0;
      notifyListeners();
    }

    // Phase 2: Từng cell biến mất từ đuôi
    while (arrow.segments.isNotEmpty) {
      // Fade out animation
      for (double progress = 0.0; progress <= 1.0; progress += 0.1) {
        _animationProgress = progress;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 3));
      }

      arrow.segments.removeAt(0);
      _animationPath = List<CellPosition>.from(arrow.segments);
      _board!.updateArrow(arrow);
      _animationProgress = 0.0;
      notifyListeners();
    }

    // Xóa arrow hoàn toàn
    _board!.removeArrow(arrow);
    _animatingArrow = null;
    _animationPath = null;
    _animationProgress = 0.0;
    notifyListeners();

    if (arrow.isExit) {
      debugPrint('✓ EXIT arrow escaped!');
    }
  }

  /// Next level
  Future<void> nextLevel() async {
    _currentLevel++;
    await generateLevel();
  }

  /// Restart current level
  Future<void> restartLevel() async {
    await generateLevel();
  }

  /// Reset về level 1
  Future<void> resetGame() async {
    _currentLevel = 1;
    await generateLevel();
  }
}
