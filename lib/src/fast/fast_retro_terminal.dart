import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:malison/malison.dart';
import 'package:piecemeal/piecemeal.dart';

import '../../malison_flutter.dart';

class FastRetroTerminalController extends RenderableTerminal {
  final Font _font;
  final Display _display;
  StreamController<void> _renderController = StreamController<void>.broadcast();

  Stream<void> get onRender => _renderController.stream;

  factory FastRetroTerminalController(int width, int height, Font font) {
    var display = FlutterDisplay(width, height);
    return FastRetroTerminalController._(display, font);
  }

  FastRetroTerminalController._(Display display, this._font)
      : _display = display;

  Font get font => _font;

  double get scale => 1.4;

  void drawGlyph(int x, int y, Glyph glyph) {
    _display.setGlyph(x, y, glyph);
  }

  Vec pixelToChar(Vec pixel) =>
      Vec(pixel.x ~/ _font.charWidth, pixel.y ~/ _font.lineHeight);

  void render() {
    _renderController.add(null);
  }

  Vec get size => _display.size;

  int get width => _display.width;

  int get height => _display.height;

  void dispose() {
    _renderController.close();
  }
}

class FastRetroTerminal extends LeafRenderObjectWidget {
  final FastRetroTerminalController controller;

  FastRetroTerminal({
    @required this.controller,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return FastRetroTerminalRenderObject()..controller = controller;
  }

  void updateRenderObject(BuildContext context,
      covariant FastRetroTerminalRenderObject renderObject) {
    renderObject..controller = controller;
  }

  @override
  void didUnmountRenderObject(
      covariant FastRetroTerminalRenderObject renderObject) {
    renderObject.dispose();
  }
}

class FastRetroTerminalRenderObject extends RenderBox {
  FastRetroTerminalController _controller;
  StreamSubscription _subscription;

  set controller(FastRetroTerminalController controller) {
    if (_controller == controller) {
      return;
    }
    _controller = controller;
    _subscription?.cancel();
    _subscription = _controller.onRender.listen((_) {
      markNeedsPaint();
    });
    markNeedsPaint();
  }

  void paint(PaintingContext context, Offset offset) {
    _controller._display.render((x, y, glyph) {
      var char = glyph.char;
      var font = _controller.font;
      var style = ui.ParagraphStyle(
        fontFamily: font.family,
        fontWeight: FontWeight.w600,
      );
      var scale = _controller.scale;
      var sx = offset.dx + x * font.charWidth ;
      var sy = offset.dy + y * font.lineHeight ;
      var backColor =
          ui.Color.fromARGB(255, glyph.back.r, glyph.back.g, glyph.back.b);
      var paint = new Paint()
        ..color = backColor
        ..style = PaintingStyle.fill;
      var canvas = context.canvas;
      canvas.drawRect(
        ui.Rect.fromLTWH(
          sx,
          sy,
          font.charWidth.toDouble(),
          font.charWidth.toDouble(),
        ),
        paint,
      );
      // Don't bother drawing empty characters.
      if (char == 0 || char == CharCode.space) return;
      var paragraphBuilder = ui.ParagraphBuilder(style)
        ..pushStyle(
          ui.TextStyle(
            color: ui.Color.fromARGB(
                255, glyph.fore.r, glyph.fore.g, glyph.fore.b),
            fontSize: font.lineHeight.toDouble() * scale,
            fontFamily: font.family,
            textBaseline: TextBaseline.alphabetic,
          ),
        )
        ..addText(String.fromCharCode(glyph.char));

      var paragraph = paragraphBuilder.build()
        ..layout(
            ui.ParagraphConstraints(width: font.charWidth.toDouble() + font.x));
      var charOffset = ui.Offset(sx.toDouble() + font.x, sy.toDouble() + font.y);
      canvas.drawParagraph(paragraph, charOffset);
    });
  }

  void performLayout() {
    if (sizedByParent) return;
    size = Size(
        (_controller._display.width * _controller.font.charWidth).toDouble(),
        (_controller._display.height * _controller.font.lineHeight).toDouble());
  }

  void performResize() {
    if (!sizedByParent) return;
    size = constraints.smallest;
  }

  void dispose() {}
}
