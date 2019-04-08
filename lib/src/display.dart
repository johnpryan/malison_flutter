import 'package:malison/malison.dart';
import 'package:piecemeal/piecemeal.dart';

class Display {
  /// The current display state. The glyphs here mirror what has been rendered.
  final Array2D<Glyph> _glyphs;

  /// The glyphs that have been modified since the last call to [render].
  final Array2D<Glyph> _changedGlyphs;

  int get width => _glyphs.width;
  int get height => _glyphs.height;
  Vec get size => _glyphs.size;

  Display(int width, int height)
      : _glyphs = Array2D(width, height),
        _changedGlyphs = Array2D(width, height, Glyph.clear);

  /// Sets the cell at [x], [y], to [glyph].
  void setGlyph(int x, int y, Glyph glyph) {
    if (x < 0) return;
    if (x >= width) return;
    if (y < 0) return;
    if (y >= height) return;

    if (_glyphs.get(x, y) != glyph) {
      _changedGlyphs.set(x, y, glyph);
    } else {
      _changedGlyphs.set(x, y, null);
    }
  }

  /// Calls [renderGlyph] for every glyph that has changed since the last call
  /// to [render].
  void render(RenderGlyph renderGlyph) {
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        var glyph = _changedGlyphs.get(x, y);

        // Only draw glyphs that are different since the last call.
        if (glyph == null) continue;

        renderGlyph(x, y, glyph);

        // It's up to date now.
        _glyphs.set(x, y, glyph);
        _changedGlyphs.set(x, y, null);
      }
    }
  }
}
