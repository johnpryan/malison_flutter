import 'dart:async';

import 'package:flutter/widgets.dart' hide Color;
import 'package:malison/malison.dart';
import 'package:malison_flutter/malison_flutter.dart';
import 'package:piecemeal/piecemeal.dart';

class RetroTerminalController extends RenderableTerminal {
  final Font _font;
  final Display _display;
  StreamController<void> _renderController = StreamController<void>.broadcast();
  Stream<void> get onRender => _renderController.stream;

  factory RetroTerminalController(int width, int height, Font font) {
    var display = FlutterDisplay(width, height);
    return RetroTerminalController._(display, font);
  }

  RetroTerminalController._(Display display, this._font) : _display = display;

  Font get font => _font;
  double get scale => 1.4;

  void drawGlyph(int x, int y, Glyph glyph) {
    _display.setGlyph(x, y, glyph);
  }

  Vec pixelToChar(Vec pixel) =>
      Vec(pixel.x ~/ _font.charWidth, pixel.y ~/ _font.lineHeight);

  void render() {
    _display.render((x, y, g) {});
    _renderController.add(null);
  }

  Vec get size => _display.size;
  int get width => _display.width;
  int get height => _display.height;

  void dispose() {
    _renderController.close();
  }
}

class RenderGlyphDisplay {
  final int x;
  final int y;
  final Glyph glyph;

  RenderGlyphDisplay(this.x, this.y, this.glyph);

  bool operator ==(Object other) {
    if (other is RenderGlyphDisplay) {
      return other.x == x && other.y == y && other.glyph == glyph;
    }
    return false;
  }

  int get hashCode =>
      x.hashCode * 123164 + y.hashCode * 342342 + glyph.hashCode;
}

class RetroTerminal extends StatefulWidget {
  final RetroTerminalController controller;

  RetroTerminal(this.controller);

  State<StatefulWidget> createState() {
    return RetroTerminalState();
  }
}

class RetroTerminalState extends State<RetroTerminal> {
  Display _display;

  void initState() {
    var controller = widget.controller;
    _display = controller._display;

    controller.onRender.listen((_) {
      setState(() {
      });
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    var c = widget.controller;
    var width = c.width * c.font.charWidth * c.scale;
    var height = c.height * c.font.lineHeight * c.scale;

    return ClipRect(
      child: CustomPaint(
        size: Size(width.toDouble(), height.toDouble()),
        painter: TerminalPainter(
          scale: widget.controller.scale,
          font: widget.controller.font,
          display: _display,
        ),
      ),
    );
  }
}

/// Describes a font used by [CanvasTerminal].
class Font {
  final String family;
  final int size;
  final int charWidth;
  final int lineHeight;
  final int x;
  final int y;

  Font(this.family, {this.size, int w, int h, this.x, this.y})
      : charWidth = w,
        lineHeight = h;
}

class FlutterDisplay implements Display {
  /// The current display state. The glyphs here mirror what has been rendered.
  final Array2D<Glyph> glyphs;

  /// The glyphs that have been modified since the last call to [render].
  final Array2D<Glyph> changedGlyphs;

  int get width => glyphs.width;
  int get height => glyphs.height;
  Vec get size => glyphs.size;

  FlutterDisplay(int width, int height)
      : glyphs = Array2D(width, height),
        changedGlyphs = Array2D(width, height, Glyph.clear);

  Iterable<RenderGlyphDisplay> get allGlyphs sync* {
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        yield RenderGlyphDisplay(x, y, glyphs.get(x, y));
      }
    }
  }

  /// Sets the cell at [x], [y], to [glyph].
  void setGlyph(int x, int y, Glyph glyph) {
    if (x < 0) return;
    if (x >= width) return;
    if (y < 0) return;
    if (y >= height) return;

    if (glyphs.get(x, y) != glyph) {
      changedGlyphs.set(x, y, glyph);
    } else {
      changedGlyphs.set(x, y, null);
    }
  }

  /// Calls [renderGlyph] for every glyph that has changed since the last call
  /// to [render].
  void render(RenderGlyph renderGlyph) {
    if (changedGlyphs.isEmpty) {
      _dirty = false;
      return;
    }
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        var glyph = changedGlyphs.get(x, y);

        // Only draw glyphs that are different since the last call.
        if (glyph == null) continue;

        renderGlyph(x, y, glyph);

        // It's up to date now.
        glyphs.set(x, y, glyph);
        changedGlyphs.set(x, y, null);
      }
    }
    _dirty = true;
  }

  bool _dirty = false;
  int get hashCode => _dirty.hashCode;
  bool operator ==(Object other) {
    return !_dirty;
  }
}
