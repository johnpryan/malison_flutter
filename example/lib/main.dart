import 'dart:math' as math;
import 'package:flutter/material.dart' hide Color;
import 'package:flutter/scheduler.dart';
import 'package:malison_flutter/malison_flutter.dart';
import 'package:malison/malison.dart';

const width = 80;
const height = 30;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark,
      ),
      home: Example(),
    );
  }
}

class Example extends StatefulWidget {
  Example({Key key}) : super(key: key);
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  FlutterUserInterface<String>ui;
  RetroTerminalController terminalController;

  void initState() {
    var schedulerBinding = SchedulerBinding.instance;
    ui = FlutterUserInterface<String>(schedulerBinding: schedulerBinding);
    terminalController = RetroTerminalController(
        width, height, Font('Menlo', size: 12, w: 8, h: 14, x: 0, y: 0));
    ui.setTerminal(terminalController);
    ui.push(MainScreen());
    ui.running = true;
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RetroTerminal(terminalController),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends FlutterScreen<String> {
  final List<Ball> balls = [];

  MainScreen() {
    var colors = [
      Color.red,
      Color.orange,
      Color.gold,
      Color.yellow,
      Color.green,
      Color.aqua,
      Color.blue,
      Color.purple
    ];

    var random = math.Random();

    for (var char in "0123456789".codeUnits) {
      for (var color in colors) {
        balls.add(Ball(
            color,
            char,
            random.nextDouble() * Ball.pitWidth,
            random.nextDouble() * (Ball.pitHeight / 2.0),
            random.nextDouble() + 0.2,
            0.0));
      }
    }
  }

  void profile() {
    ui.running = true;
    for (var i = 0; i < 1000; i++) {
      update();
      ui.refresh();
    }
  }

  void update() {
    for (var ball in balls) {
      ball.update();
    }

    dirty();
  }

  void render(Terminal terminal) {
    terminal.clear();

    void colorBar(int y, String name, Color light, Color medium, Color dark) {
      terminal.writeAt(2, y, name, Color.gray);
      terminal.writeAt(10, y, "light", light);
      terminal.writeAt(16, y, "medium", medium);
      terminal.writeAt(23, y, "dark", dark);

      terminal.writeAt(28, y, " light ", Color.black, light);
      terminal.writeAt(35, y, " medium ", Color.black, medium);
      terminal.writeAt(43, y, " dark ", Color.black, dark);
    }

    terminal.writeAt(0, 0, "Predefined colors:");
    terminal.writeAt(59, 0, "switch terminal [tab]", Color.darkGray);
    terminal.writeAt(75, 0, "[tab]", Color.lightGray);
    colorBar(1, "gray", Color.lightGray, Color.gray, Color.darkGray);
    colorBar(2, "red", Color.lightRed, Color.red, Color.darkRed);
    colorBar(3, "orange", Color.lightOrange, Color.orange, Color.darkOrange);
    colorBar(4, "gold", Color.lightGold, Color.gold, Color.darkGold);
    colorBar(5, "yellow", Color.lightYellow, Color.yellow, Color.darkYellow);
    colorBar(6, "green", Color.lightGreen, Color.green, Color.darkGreen);
    colorBar(7, "aqua", Color.lightAqua, Color.aqua, Color.darkAqua);
    colorBar(8, "blue", Color.lightBlue, Color.blue, Color.darkBlue);
    colorBar(9, "purple", Color.lightPurple, Color.purple, Color.darkPurple);
    colorBar(10, "brown", Color.lightBrown, Color.brown, Color.darkBrown);

    terminal.writeAt(0, 12, "Code page 437:");
    var lines = [
      " ☺☻♥♦♣♠•◘○◙♂♀♪♫☼",
      "►◄↕‼¶§▬↨↑↓→←∟↔▲▼",
      " !\"#\$%&'()*+,-./",
      "0123456789:;<=>?",
      "@ABCDEFGHIJKLMNO",
      "PQRSTUVWXYZ[\\]^_",
      "`abcdefghijklmno",
      "pqrstuvwxyz{|}~⌂",
      "ÇüéâäàåçêëèïîìÄÅ",
      "ÉæÆôöòûùÿÖÜ¢£¥₧ƒ",
      "áíóúñÑªº¿⌐¬½¼¡«»",
      "░▒▓│┤╡╢╖╕╣║╗╝╜╛┐",
      "└┴┬├─┼╞╟╚╔╩╦╠═╬╧",
      "╨╤╥╙╘╒╓╫╪┘┌█▄▌▐▀",
      "αßΓπΣσµτΦΘΩδ∞φε∩",
      "≡±≥≤⌠⌡÷≈°∙·√ⁿ²■"
    ];

    var y = 13;
    for (var line in lines) {
      terminal.writeAt(3, y++, line, Color.lightGray);
    }

    terminal.writeAt(22, 12, "Simple game loop:");
    terminal.writeAt(66, 12, "toggle [space]", Color.darkGray);
    terminal.writeAt(73, 12, "[space]", Color.lightGray);

    for (var ball in balls) {
      ball.render(terminal);
    }
  }
}

class Ball {
  static const pitWidth = 56.0;
  static const pitHeight = 17.0;

  final Color color;
  final int charCode;

  double x, y, h, v;

  Ball(this.color, this.charCode, this.x, this.y, this.h, this.v);

  void update() {
    x += h;
    if (x < 0.0) {
      x = -x;
      h = -h;
    } else if (x > pitWidth) {
      x = pitWidth - x + pitWidth;
      h = -h;
    }

    v += 0.03;
    y += v;
    if (y > pitHeight) {
      y = pitHeight - y + pitHeight;
      v = -v;
    }
  }

  void render(Terminal terminal) {
    terminal.drawChar(24 + x.toInt(), 13 + y.toInt(), charCode, color);
  }
}
