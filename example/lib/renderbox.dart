import 'package:flutter/material.dart';

void main() {
  runApp(RenderBoxApp());
}

class RenderBoxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: MyCustomRenderObjectWidget(
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}

class MyCustomRenderObjectWidget extends LeafRenderObjectWidget {
  final Color color;

  MyCustomRenderObjectWidget({
    @required this.color,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MyCustomRenderObject()..color = color;
  }

  void updateRenderObject(
      BuildContext context, covariant MyCustomRenderObject renderObject) {
    renderObject..color = color;
  }

  @override
  void didUnmountRenderObject(covariant MyCustomRenderObject renderObject) {
    renderObject.dispose();
  }
}

class MyCustomRenderObject extends RenderBox {
  Color _color;

  set color(Color color) {
    if (_color == color) {
      return;
    }
    _color = color;
    markNeedsPaint();
  }

  void paint(PaintingContext context, Offset offset) {
    var paint = new Paint()
      ..color = _color
      ..style = PaintingStyle.fill;

    var canvas = context.canvas;
    canvas.drawRect(
      new Rect.fromLTWH(
        offset.dx,
        offset.dy,
        100,
        100,
      ),
      paint,
    );
  }

  void performLayout() {
    if (sizedByParent) return;
    size = Size(100, 100);
  }
  void performResize() {
    if (!sizedByParent) return;
    size = constraints.smallest;
  }

  void dispose() {}
}
