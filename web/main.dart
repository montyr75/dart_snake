import 'dart:html';

const int CELL_SIZE = 10;

enum Direction {
  right,
  left,
  up,
  down
}

CanvasElement canvas;
CanvasRenderingContext2D ctx;

Snake snake;

void main() {
  init();
}

void init() {
  // set up canvas
  canvas = querySelector('#canvas');
  ctx = canvas.getContext('2d');

  // create snake
  snake = new Snake();

  // start game loop
  window.animationFrame.then(update);
}

void clear() {
  ctx.fillStyle = "white";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
}

void update(num delta) {
//  snake.move();
  snake.draw();

  // keep looping
  window.animationFrame.then(update);
}

class Snake {
  int length = 5;         // length of the snake's body (not counting the head)
  List<Point> body = [];  // coordinates of the body segments
  Direction dir = Direction.right;

  Snake() {
    int i = length;
    body = new List<Point>.generate(length + 1, (int index) => new Point(i--, 0));
//    for (int i = length; i >= 0; i--) {
//      body.add(new Point(i, 0));
//    }

    print(body);
  }

  void draw() {
    ctx.fillStyle = "green";
    ctx.strokeStyle = "white";

    // starting with the head, draw each body segment
    for (Point p in body) {
      int x = p.x * CELL_SIZE;
      int y = p.y * CELL_SIZE;

      ctx.fillRect(x, y, CELL_SIZE, CELL_SIZE);
      ctx.strokeRect(x, y, CELL_SIZE, CELL_SIZE);
    }
  }

  void move() {
    // calculate a new head position based on current direction
    Point head = body.first;
    Point newHead;

    switch (dir) {
      case Direction.right: newHead = new Point(head.x + 1, head.y); break;
      case Direction.left: newHead = new Point(head.x - 1, head.y); break;
      case Direction.up: newHead = new Point(head.x, head.y - 1); break;
      case Direction.down: newHead = new Point(head.x, head.y + 1); break;
    }

    // remove the tail segment
    body.removeLast();

    // add the head at the new position
    body.insert(0, newHead);
  }
}