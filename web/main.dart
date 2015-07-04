import 'dart:html';
import 'dart:collection';

const int CELL_SIZE = 10;

void main() {
  new Game(querySelector('#canvas')..focus())..run();
}

class Game {
  final CanvasElement _canvas;
  CanvasRenderingContext2D _ctx;
  num _lastTimestamp = 0;

  Keyboard _keyboard = new Keyboard();

  Snake snake;

  Game(CanvasElement this._canvas) {
    _ctx = _canvas.getContext('2d');
    init();
  }

  void init() {
    snake = new Snake();
  }

  void run() {
    window.animationFrame.then(update);
  }

  void clear() {
    _ctx..fillStyle = "white"
      ..fillRect(0, 0, _canvas.width, _canvas.height);
  }

  void update(num delta) {
    final num diff = delta - _lastTimestamp;

    if (diff > 50) {
      _lastTimestamp = delta;
      clear();
      snake.update(_ctx, _keyboard);
    }

    // keep looping
    run();
  }
}

class Snake {
  static const Point DIR_RIGHT = const Point(1, 0);
  static const Point DIR_LEFT = const Point(-1, 0);
  static const Point DIR_UP = const Point(0, -1);
  static const Point DIR_DOWN = const Point(0, 1);

  int length = 5;         // length of the snake's body (not counting the head)
  List<Point> body = [];  // coordinates of the body segments
  Point dir = DIR_RIGHT;

  Snake() {
    int i = length;
    body = new List<Point>.generate(length + 1, (int index) => new Point(i--, 0));
  }

  void _draw(CanvasRenderingContext2D ctx) {
    ctx..fillStyle = "green"
      ..strokeStyle = "white";

    // starting with the head, draw each body segment
    for (Point p in body) {
      final int x = p.x * CELL_SIZE;
      final int y = p.y * CELL_SIZE;

      ctx..fillRect(x, y, CELL_SIZE, CELL_SIZE)
        ..strokeRect(x, y, CELL_SIZE, CELL_SIZE);
    }
  }

  void _move() {
    // calculate a new head position based on current direction
    final Point newHead = body.first + dir;

    // remove the tail segment
    body.removeLast();

    // add the head at the new position
    body.insert(0, newHead);
  }

  void _checkInput(Keyboard keyboard) {
    if (keyboard.isPressed(KeyCode.RIGHT) && dir != DIR_LEFT) {
      dir = DIR_RIGHT;
    }
    else if (keyboard.isPressed(KeyCode.LEFT) && dir != DIR_RIGHT) {
      dir = DIR_LEFT;
    }
    else if (keyboard.isPressed(KeyCode.UP) && dir != DIR_DOWN) {
      dir = DIR_UP;
    }
    else if (keyboard.isPressed(KeyCode.DOWN) && dir != DIR_UP) {
      dir = DIR_DOWN;
    }
  }

  void update(CanvasRenderingContext2D ctx, Keyboard keyboard) {
    _checkInput(keyboard);
    _move();
    _draw(ctx);
  }
}

class Keyboard {
  HashMap<int, int> _keys = new HashMap<int, int>();

  Keyboard() {
    window.onKeyDown.listen((KeyboardEvent event) {
      if (!_keys.containsKey(event.keyCode)) {
        _keys[event.keyCode] = event.timeStamp;
      }
    });

    window.onKeyUp.listen((KeyboardEvent event) {
      _keys.remove(event.keyCode);
    });
  }

  bool isPressed(int keyCode) => _keys.containsKey(keyCode);
}