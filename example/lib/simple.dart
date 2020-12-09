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
    ui.push(SimpleScreen());
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

class SimpleScreen extends FlutterScreen<String> {
  SimpleScreen();

  void update() {
    dirty();
  }

  void render(Terminal terminal) {
    terminal.writeAt(0, 0, "Hello, World! ${math.Random().nextInt(1000)}");
  }
}

