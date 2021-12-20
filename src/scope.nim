import atomics
import sdl2_nim/sdl
import dsp/frame


const
  Title = "Scope"
  ScreenW = 640 # Window width
  ScreenH = 480 # Window height
  WindowFlags = WINDOW_ALLOW_HIGHDPI # or WINDOW_MOUSE_CAPTURE or WINDOW_OPENGL or WINDOW_METAL or WINDOW_RESIZABLE or WINDOW_FULLSCREEN or WINDOW_FULLSCREEN_DESKTOP
  RendererFlags = sdl.RendererAccelerated or sdl.RendererPresentVsync


type
  Scope* = ref ScopeObj
  ScopeObj = object
    window*: sdl.Window # Window pointer
    renderer*: sdl.Renderer # Rendering state pointer
    monitor*: ptr Monitor


# Initialization sequence
proc init(app: Scope): bool =
  # Init SDL
  if sdl.init(sdl.InitVideo) != 0:
    echo "ERROR: Can't initialize SDL: ", sdl.getError()
    return false

  # Create window
  app.window = sdl.createWindow(
    Title,
    sdl.WindowPosUndefined,
    sdl.WindowPosUndefined,
    ScreenW,
    ScreenH,
    WindowFlags)
  if app.window == nil:
    echo "ERROR: Can't create window: ", sdl.getError()
    return false

  # Create renderer
  app.renderer = sdl.createRenderer(app.window, -1, RendererFlags)
  if app.renderer == nil:
    echo "ERROR: Can't create renderer: ", sdl.getError()
    return false

  # Set draw color
  if app.renderer.setRenderDrawColor(0xFF, 0xFF, 0xFF, 0xFF) != 0:
    echo "ERROR: Can't set draw color: ", sdl.getError()
    return false

  echo "SDL initialized successfully"
  return true


# Shutdown sequence
proc exit*(app: Scope) =
  app.renderer.destroyRenderer()
  app.window.destroyWindow()
  sdl.quit()
  echo "SDL shutdown completed"

# Event handling
# Return true on app shutdown request, otherwise return false
proc events(): bool =
  result = false
  var e: sdl.Event

  while sdl.pollEvent(addr(e)) != 0:

    # Quit requested
    if e.kind == sdl.Quit:
      return true

    # Key pressed
    elif e.kind == sdl.KeyDown:
      # Show what key was pressed
      sdl.logInfo(sdl.LogCategoryApplication, "Pressed %s", $e.key.keysym.sym)

      # Exit on Escape key press
      if e.key.keysym.sym == sdl.K_Escape:
        return true

const DPI_FACTOR = 2

proc start*(app: Scope) =
  var done = false
  var buffer = newSeq[array[0x10, int]](ScreenW * DPI_FACTOR)

  if init(app):

    var x = 0
    while not done:
      # Clear screen with draw color
      discard app.renderer.setRenderDrawColor(0xFF, 0xFF, 0xFF, 0xFF)
      if app.renderer.renderClear() != 0:
        sdl.logWarn(sdl.LogCategoryVideo,
                    "Can't clear screen: %s",
                    sdl.getError())

      for i, a in app.monitor[].mpairs:
        let y = a.load.project(-1.0, 1.0, (ScreenH * DPI_FACTOR).toFloat, 0.0).to_int
        buffer[x][i] = y

      for x in 0..<buffer.high:
        for i, y in buffer[x]:
          discard app.renderer.setRenderDrawColor((0x10 * i).uint8, 0x00, 0x00, 0xFF)
          discard app.renderer.renderDrawLine(x, y, x+1, buffer[x+1][i])

      # Update renderer
      app.renderer.renderPresent()

      x = (x + 1) mod (ScreenW * DPI_FACTOR)

      # Event handling
      done = events()
