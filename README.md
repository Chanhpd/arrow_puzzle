url game clone : https://play.google.com/store/apps/details?id=com.ecffri.arrows

![img.png](img.png)

# 🏹 Arrow Puzzle Escape (Flutter + Flame)

Một game puzzle 2D dạng **grid-based**, người chơi điều khiển các mũi tên di chuyển theo hướng cố định để thoát khỏi màn chơi.
Dự án được xây dựng bằng **Flutter + Flame Engine**.

---

## 📌 Tính năng chính

* 🎮 Gameplay puzzle theo dạng lưới (grid)
* ➡️ Mũi tên chỉ di chuyển theo hướng của chính nó
* 🎞️ Animation mượt khi di chuyển (slide / easing)
* 🧩 Nhiều level, độ khó tăng dần
* 📱 Hỗ trợ Android / iOS (có thể mở rộng Web)

---

## 🛠️ Công nghệ sử dụng

* **Flutter** (UI + đa nền tảng)
* **Flame Engine** (2D game engine cho Flutter)
* **Dart**
* **Sprite / Animation / Game Loop**

---

## 📂 Cấu trúc thư mục

```text
lib/
│── main.dart
│
├── game/
│   ├── arrow_game.dart        # Game chính (extends FlameGame)
│   ├── level_manager.dart     # Load & quản lý level
│
├── components/
│   ├── arrow_component.dart   # Arrow (SpriteComponent)
│   ├── tile_component.dart    # Ô trong grid
│
├── data/
│   ├── level_01.json
│   ├── level_02.json
│
├── utils/
│   ├── grid_helper.dart       # Tính toán vị trí grid
│   └── constants.dart
│
assets/
├── images/
│   ├── arrow_up.png
│   ├── arrow_down.png
│   └── tile.png
```

---

## 🚀 Cách chạy dự án

### 1️⃣ Cài dependencies

```bash
flutter pub get
```

### 2️⃣ Chạy app

```bash
flutter run
```

---

## 🎮 Cách hoạt động game

### 🔹 1. Grid-based Map

* Mỗi level là một **ma trận (2D array)**.
* Mỗi ô có thể là:

    * Empty
    * Wall
    * Arrow (Up / Down / Left / Right)
    * Exit

Ví dụ `level_01.json`:

```json
{
  "rows": 5,
  "cols": 5,
  "map": [
    ["E", "E", "E", "E", "X"],
    ["E", "R", "E", "D", "E"],
    ["E", "E", "E", "E", "E"],
    ["U", "E", "L", "E", "E"],
    ["E", "E", "E", "E", "E"]
  ]
}
```

---

### 🔹 2. Arrow Component

* Mỗi arrow là một `SpriteComponent`
* Có thuộc tính:

    * `direction`
    * `gridPosition`

```dart
class ArrowComponent extends SpriteComponent {
  final Direction direction;
  Point<int> gridPos;

  ArrowComponent({
    required this.direction,
    required this.gridPos,
  });
}
```

---

### 🔹 3. Logic di chuyển

* Khi player tap vào arrow:

    1. Xác định hướng di chuyển
    2. Tính ô tiếp theo
    3. Kiểm tra:

        * Có bị chặn không
        * Có ra khỏi map không
    4. Nếu hợp lệ → animate

```dart
void moveArrow() {
  final target = gridHelper.nextCell(gridPos, direction);

  add(
    MoveEffect.to(
      target.toVector2(),
      EffectController(
        duration: 0.25,
        curve: Curves.easeInOut,
      ),
    ),
  );

  gridPos = target;
}
```

---

### 🔹 4. Animation

* Sử dụng **Flame Effects**
* Không dùng setState → đảm bảo mượt & đúng game loop

Các hiệu ứng dùng:

* `MoveEffect`
* `ScaleEffect` (feedback khi chạm)
* `OpacityEffect` (thắng / thua)

---

### 🔹 5. Điều kiện thắng

* Arrow chạm vào ô `Exit`
* Hoặc toàn bộ arrow thoát khỏi map

```dart
bool checkWin() {
  return arrows.every((a) => a.isOut);
}
```

---

## 🧠 Kiến trúc

* **Game Logic** tách khỏi UI
* Không phụ thuộc Widget Tree
* Dễ mở rộng:

    * Thêm loại tile mới
    * Thêm trap / teleport
    * Thêm undo / hint

---

## 📈 Hướng mở rộng

* ⭐ Level editor
* 🔄 Undo / Replay
* 🧠 Hint system
* 🎵 Sound & vibration
* 🏆 Save progress / leaderboard

---

## 📦 Thư viện chính

```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.15.0
```

---

# arrow_puzzle
