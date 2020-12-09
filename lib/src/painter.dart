import 'dart:ui';

import 'package:flutter/material.dart' hide TextStyle;
import 'package:flutter/rendering.dart' hide TextStyle;
import 'package:malison/malison.dart' hide Color, RenderGlyph;
import 'package:malison_flutter/malison_flutter.dart';

class TerminalPainter extends CustomPainter {
  double scale;
  Font font;
  FlutterDisplay display;
  List<Paragraph> _paragraphs = [];

  int paintCount = 0;

  TerminalPainter({
    @required this.scale,
    @required this.font,
    @required this.display,
  });

  paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.black, BlendMode.color);

    for (var renderGlyph in display.allGlyphs) {
      var glyph = renderGlyph.glyph;
      var char = glyph.char;
      var font = this.font;
      var style = ParagraphStyle(
        fontFamily: font.family,
        fontWeight: FontWeight.w600,
      );

      var scale = this.scale;
      var x = (renderGlyph.x * font.charWidth + font.x) * scale;
      var y = (renderGlyph.y * font.lineHeight + font.y) * scale;
      var backColor =
          Color.fromARGB(255, glyph.back.r, glyph.back.g, glyph.back.b);

      var paint = new Paint()
        ..color = backColor
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        new Rect.fromLTWH(
          x,
          y,
          font.charWidth.toDouble() * scale,
          font.lineHeight.toDouble() * scale,
        ),
        paint,
      );

      // Don't bother drawing empty characters.
      if (char == 0 || char == CharCode.space) continue;

      var paragraphBuilder = ParagraphBuilder(style)
        ..pushStyle(
          TextStyle(
            color:
                Color.fromARGB(255, glyph.fore.r, glyph.fore.g, glyph.fore.b),
            fontSize: font.lineHeight.toDouble() * scale,
            fontFamily: font.family,
            textBaseline: TextBaseline.alphabetic,
          ),
        )
        ..addText(String.fromCharCode(glyph.char));

      var paragraph = paragraphBuilder.build()
        ..layout(
            ParagraphConstraints(width: font.charWidth.toDouble() + font.x));
      var offset = Offset(x, y);
      canvas.drawParagraph(paragraph, offset);
      _paragraphs.add(paragraph);
    }
    paintCount++;
  }

  bool shouldRepaint(TerminalPainter old) =>
      old.display != display;
}
