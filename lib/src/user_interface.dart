import 'package:malison/malison.dart';
import 'package:meta/meta.dart';
import 'package:piecemeal/piecemeal.dart';
import 'package:flutter/scheduler.dart';

class FlutterUserInterface<T> {
  final List<FlutterScreen<T>> _screens = [];
  final SchedulerBinding schedulerBinding;
  RenderableTerminal _terminal;

  bool _dirty = true;
  bool _running = false;

  FlutterUserInterface(
      {@required this.schedulerBinding, RenderableTerminal terminal})
      : _terminal = terminal;

  /// Whether or not the game loop is running and the UI is refreshing itself
  /// every frame.
  ///
  /// Initially off.
  ///
  /// If you want to manually refresh the UI yourself when you know it needs
  /// to be updated -- maybe your game is explicitly turn-based -- you can
  /// leave this off.
  bool get running => _running;

  set running(bool value) {
    if (value == _running) return;

    _running = value;
    if (_running) {
      schedulerBinding.scheduleFrameCallback(_tick);
    }
  }

  void setTerminal(RenderableTerminal terminal) {
    var resized = terminal != null &&
        (_terminal == null ||
            _terminal.width != terminal.width ||
            _terminal.height != terminal.height);

    _terminal = terminal;
    dirty();

    // If the terminal size changed, let the screens known.
    if (resized) {
      for (var screen in _screens) screen.resize(terminal.size);
    }
  }

  /// Pushes [screen] onto the top of the stack.
  void push(FlutterScreen<T> screen) {
    screen._bind(this);
    _screens.add(screen);
    _render();
  }

  /// Pops the top screen off the top of the stack.
  ///
  /// The next screen down is activated. If [result] is given, it is passed to
  /// the new active screen's [activate] method.
  void pop([Object result]) {
    var screen = _screens.removeLast();
    screen._unbind();
    _screens[_screens.length - 1].activate(screen, result);
    _render();
  }

  /// Switches the current top screen to [screen].
  ///
  /// This is equivalent to a [pop] followed by a [push].
  void goTo(FlutterScreen<T> screen) {
    var old = _screens.removeLast();
    old._unbind();

    screen._bind(this);
    _screens.add(screen);
    _render();
  }

  void dirty() {
    _dirty = true;
  }

  void refresh() {
    // Don't use a for-in loop here so that we don't run into concurrent
    // modification exceptions if a screen is added or removed during a call to
    // update().
    for (var i = 0; i < _screens.length; i++) {
      _screens[i].update();
    }
    if (_dirty) _render();
  }

  /// Called every animation frame while the UI's game loop is running.
  void _tick(Duration time) {
    refresh();

    if (_running) {
      schedulerBinding.scheduleFrameCallback(_tick);
    }
  }

  void _render() {
    // If the UI isn't currentl bound to a terminal, there's nothing to render.
    if (_terminal == null) return;

    _terminal.clear();

    // Skip past all of the covered screens.
    int i;
    for (i = _screens.length - 1; i >= 0; i--) {
      if (!_screens[i].isTransparent) break;
    }

    if (i < 0) i = 0;

    // Render the top opaque screen and any transparent ones above it.
    for (; i < _screens.length; i++) {
      _screens[i].render(_terminal);
    }

    _dirty = false;
    _terminal.render();
  }
}

class FlutterScreen<T> {
  FlutterUserInterface<T> _ui;

  bool get isTransparent => false;

  /// The [UserInterface] this screen is bound to.
  FlutterUserInterface<T> get ui => _ui;

  /// Binds this screen to [ui].
  void _bind(FlutterUserInterface<T> ui) {
    assert(_ui == null);
    _ui = ui;

    resize(ui._terminal.size);
  }

  /// Unbinds this screen from the [ui] that owns it.
  void _unbind() {
    assert(_ui != null);
    _ui = null;
  }

  /// Marks the user interface as needing to be rendered.
  ///
  /// Call this during [update] to indicate that a subsequent call to [render]
  /// is needed.
  void dirty() {
    // If we aren't bound (yet), just do nothing. The screen will be dirtied
    // when it gets bound.
    if (_ui == null) return;

    _ui.dirty();
  }

  /// If a keypress has a binding defined for it and is pressed, this will be
  /// called with the bound input when this screen is active.
  ///
  /// If this returns `false` (the default), then the lower-level [keyDown]
  /// method will be called.
  bool handleInput(T input) => false;

  bool keyDown(int keyCode, {bool shift, bool alt}) => false;

  bool keyUp(int keyCode, {bool shift, bool alt}) => false;

  /// Called when the screen above this one ([popped]) has been popped and this
  /// screen is now the top-most screen. If a value was passed to [pop()], it
  /// will be passed to this as [result].
  void activate(FlutterScreen<T> popped, Object result) {}

  void update() {}

  void render(Terminal terminal) {}

  /// Called when the [UserInterface] has been bound to a new terminal with a
  /// different size while this [Screen] is present.
  void resize(Vec size) {}
}
