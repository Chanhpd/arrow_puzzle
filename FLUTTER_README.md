# Arrow Puzzle Game - Flutter

Arrow puzzle game được convert từ Python sang Flutter/Dart với đầy đủ UI tương tác.

## 🎮 Game Mechanics

- **Click-to-escape**: Click vào arrow → arrow tự động di chuyển về hướng của nó
- **Escape animation**: Arrow di chuyển kiểu rắn (head moves first, tail follows)
- **Win condition**: Clear tất cả arrows khỏi board
- **Blocking logic**: Arrow chỉ escape nếu không bị block bởi arrow khác

## 🏗️ Architecture

### Models
- `CellPosition`: Immutable position class (row, col)
- `ArrowDirection`: Enum với 4 hướng (right/left/down/up)
- `MoveAxis`: Horizontal/vertical/both movement constraints
- `ComplexArrow`: Arrow entity với segments list
- `GameBoard`: Board state management

### Services
- `LevelGenerator`: Algorithm tạo level tự động
  - Phase 1: Tạo curved long arrows (L-shape, U-shape, zigzag)
  - Phase 2: Fill remaining space với short arrows
  - Validation: No self-intersection

### Controllers
- `GameController`: Game state management với Provider
  - Generate level
  - Handle arrow click
  - Check escape possibility
  - Animate escape with snake movement
  - Win condition check

### UI
- `BoardPainter`: CustomPainter vẽ grid và arrows
- `GameScreen`: Main game screen với gesture detection
- Animation: 50ms delay per step

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2  # State management
```

## 🚀 Run

```bash
flutter pub get
flutter run
```

## 🎨 Features

✅ Auto-generate puzzle levels
✅ Click-to-escape game mechanic  
✅ Snake animation (head → tail)
✅ Blocking detection
✅ Win dialog với move counter
✅ Reset/New game button
✅ Responsive UI (adapts to screen size)
✅ Color coding:
  - Blue: Normal arrows
  - Red: Exit arrow (hidden challenge)
  - Direction symbols: →←↓↑

## 📝 Algorithm Details

### Level Generation
1. Generate curved long arrows (40% của target)
2. Fill remaining space với short arrows
3. Validate no self-intersection
4. Ensure at least 1 exit arrow

### Escape Logic
1. User click arrow
2. Simulate movement để check if can escape
3. If blocked → stay in place
4. If can escape → animate snake movement
5. Remove arrow when fully escaped

### Move Axis Determination
- Horizontal moves > vertical * 1.5 → `vertical` axis (tên counterintuitive)
- Vertical moves > horizontal * 1.5 → `horizontal` axis
- Otherwise → `both`

## 🔄 Convert from Python

Original Python files:
- `docs/arrow_puzzle_generator_v2.py` (1200+ lines)
- `docs/arrow_puzzle_game_gui.py` (347 lines)

Flutter equivalent:
- Models: 4 files (~500 lines)
- Services: 1 file (~350 lines)
- Controllers: 1 file (~150 lines)
- UI: 2 files (~350 lines)
- **Total: ~1350 lines Dart code**
