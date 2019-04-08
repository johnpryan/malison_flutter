# malison_flutter

EXPERIMENTAL implementation of `package:malison` for flutter

## Performance

The example app only runs a ~20 FPS. That's because this implementation uses a
CustomPainter, which requires rendering each character on every frame. More
investigation is needed here to determine how to re-use previous paints.

## Usage
see  Example/ directory
