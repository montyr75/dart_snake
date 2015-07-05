import 'dart:html';
import 'dart:collection';
import 'dart:math';

const int CELL_SIZE = 10;

void main() {
  new Game(querySelector('#canvas')..focus())..run();
}

class Game {
  static const int GAME_SPEED = 50;     // smaller numbers are faster

  final CanvasElement _canvas;
  CanvasRenderingContext2D _ctx;
  Random _random;
  num _lastTimestamp = 0;
  int _rightEdgeX;
  int _bottomEdgeY;

  Keyboard _keyboard = new Keyboard();

  Snake _snake;
  Point _food;

  Game(CanvasElement this._canvas) {
    _ctx = _canvas.getContext('2d');
    _rightEdgeX = _canvas.width ~/ CELL_SIZE;
    _bottomEdgeY = _canvas.height ~/ CELL_SIZE;

    init();
  }

  void init() {
    _random = new Random();
    _snake = new Snake();
    _food = _randomPoint();
  }

  void _clear() {
    _ctx..fillStyle = "white"
      ..fillRect(0, 0, _canvas.width, _canvas.height);
  }

  Point _randomPoint() {
    return new Point(_random.nextInt(_rightEdgeX), _random.nextInt(_bottomEdgeY));
  }

  void _checkForCollisions() {
    // check death conditions
    if (_snake.head.x <= -1 || _snake.head.x >= _rightEdgeX ||
      _snake.head.y <= -1 || _snake.head.y >= _bottomEdgeY ||
      _snake.checkForBodyCollision()) {
      init();
      return;
    }

    // check for collision with food
    if (_snake.head == _food) {
      _food = _randomPoint();
      _snake.grow();
    }
  }

  void run() {
    window.animationFrame.then(update);
  }

  void update(num delta) {
    final num diff = delta - _lastTimestamp;

    if (diff > GAME_SPEED) {
      _lastTimestamp = delta;
      _clear();
      drawCell(_ctx, _food, "blue");
      _snake.update(_ctx, _keyboard);
      _checkForCollisions();
    }

    // keep looping
    run();
  }
}

class Snake {
  static const Point RIGHT = const Point(1, 0);
  static const Point LEFT = const Point(-1, 0);
  static const Point UP = const Point(0, -1);
  static const Point DOWN = const Point(0, 1);

  static const int START_LENGTH = 6;

  List<Point> _body = [];   // coordinates of the body segments
  Point _dir = RIGHT;       // current travel direction

  Snake() {
    int i = START_LENGTH - 1;
    _body = new List<Point>.generate(START_LENGTH, (int index) => new Point(i--, 0));
  }

  void _draw(CanvasRenderingContext2D ctx) {
    // starting with the head, draw each body segment
    for (Point p in _body) {
      drawCell(ctx, p, "green");
    }
  }

  void _move() {
    // add a new head segment
    grow();

    // remove the tail segment
    _body.removeLast();
  }

  void _checkInput(Keyboard keyboard) {
    if (keyboard.isPressed(KeyCode.RIGHT) && _dir != LEFT) {
      _dir = RIGHT;
    }
    else if (keyboard.isPressed(KeyCode.LEFT) && _dir != RIGHT) {
      _dir = LEFT;
    }
    else if (keyboard.isPressed(KeyCode.UP) && _dir != DOWN) {
      _dir = UP;
    }
    else if (keyboard.isPressed(KeyCode.DOWN) && _dir != UP) {
      _dir = DOWN;
    }
  }

  bool checkForBodyCollision() {
    for (Point p in _body.skip(1)) {
      if (p == head) {
        return true;
      }
    }

    return false;
  }

  void grow() {
    // add new head based on current direction
    _body.insert(0, head + _dir);
  }

  void update(CanvasRenderingContext2D ctx, Keyboard keyboard) {
    _checkInput(keyboard);
    _move();
    _draw(ctx);
  }

  Point get head => _body.first;
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

void drawCell(CanvasRenderingContext2D ctx, Point coords, String color) {
  ctx..fillStyle = color
    ..strokeStyle = "white";

  final int x = coords.x * CELL_SIZE;
  final int y = coords.y * CELL_SIZE;

  ctx..fillRect(x, y, CELL_SIZE, CELL_SIZE)
    ..strokeRect(x, y, CELL_SIZE, CELL_SIZE);
}