================================================================================
SDL 3 requirements
================================================================================

AmigaOS 4.1 Final Edition
MiniGL (optional)
OpenGL ES 2.0 (optional)

================================================================================
Installation
================================================================================

There is an installer script that can be used to install shared objects, prefs
program and the SDK.

Installer script creates soft link from libSDL3.so to the latest libSDL3-x.y.so
file.

================================================================================
Building SDL 3 library
================================================================================

    # non-debug variant
    gmake -f Makefile.amigaos4

    # with serial debug prints
    gmake -f Makefile.amigaos4 debug

    At the moment configure script and CMake are not supported.

================================================================================
Using SDL 3 in your projects
================================================================================

    #include <SDL3/SDL.h>
    ...do magical SDL3 things...

    gcc helloworld.c -use-dynld -lSDL3

================================================================================
Setting REGAPP_Description
================================================================================

Set SDL_HINT_APP_NAME before SDL_Init():

    SDL_SetHint(SDL_HINT_APP_NAME, "Some description");

Or set SDL_PROP_APP_METADATA_NAME_STRING property before SDL_Init().

================================================================================
About SDL_Renderers
================================================================================

A renderer is a subsystem that can do 2D drawing. There are 3 renderers:
software, OpenGL ES 2.0 and compositing.

Software renderer is always available. Pixels are plotted by the CPU so this is
usually a slow option.

OpenGL ES 2.0 renderer uses ogles2.library (and Warp3D Nova).

Compositing renderer uses AmigaOS 4 graphics.library for accelerated drawing.
However, blended lines and points are not accelerated since compositing doesn't
support them. Compositing renderer supports only 32-bit bitmaps. If (Workbench)
screen mode is 16-bit, color format conversion can slow things down.

It's possible to select the preferred renderer before its creation, like this:

    SDL_SetHint(SDL_HINT_RENDER_DRIVER, name);

where name is "software", "opengles2" or "compositing".

It's possible to enable VSYNC with:

    SDL_SetHint(SDL_HINT_RENDER_VSYNC, "1");

There is a benchmark tool called sdl3benchmark which was written to test
available renderers.

================================================================================
About ENV variables
================================================================================

Advanced users may use ENV variables to control some things in SDL3. Some
variables supported by the SDL_Renderer subsystem:

Driver selection:

setenv SDL_RENDER_DRIVER "software"
setenv SDL_RENDER_DRIVER "compositing"
setenv SDL_RENDER_DRIVER "opengles2"

VSYNC:

setenv SDL_RENDER_VSYNC 1 # Enable
setenv SDL_RENDER_VSYNC 0 # Disable

It must be noted that these variables apply only to those applications that
actually use the SDL_Renderer subsystem, and not 3D games.

Screensaver control:

setenv SDL_VIDEO_ALLOW_SCREENSAVER 1 # Enable
setenv SDL_VIDEO_ALLOW_SCREENSAVER 0 # Disable

Please check also SDL3 preferences program.

================================================================================
About OpenGL
================================================================================

If you want to draw accelerated 3D graphics or use explicitly OpenGL functions,
you have to create an OpenGL context, instead of an SDL_Renderer.

If you would like to create an OpenGL ES 2.0 context, you need to specify the
version before window creation, for example:

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);

MiniGL context can be created using major version 1 and minor version 3. This is
also the default setup.

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 1);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);

================================================================================
About Joysticks
================================================================================

Joysticks that are compatible with AmigaInput can be used with SDL3. At the
moment game controller database contains the following entries:

- Speedlink Competition Pro
- Ewent Joypad EW3170
- PS2 Joystick (USB adaptor)
- SHARK 91230 Joystick
- MAGIC-NS
- Wireless Controller
- 8Bitdo SN30 Pro
- Thrustmaster dual analog 3.2
- XEOX Gamepad SL-6556-BK
- Strike2 Joystick
- GeeekPi_A gamepad
- Logitech Cordless RumblePad 2
- Logitech RumblePad 2 USB
- Logitech(R) Precision(TM) Gamepad
- Logitech Dual Action
- MAYFLASH Arcade Fightstick F300
- Game Controller for Android
- 2In1 USB Joystick
- DualSense Wireless Controller

Joysticks can be tested using testcontroller tool. New game controller mappings
can be generated using the same tool. Mappings can be then added to the game
controller database.

================================================================================
Buffered File I/O
================================================================================

File I/O is in unbuffered mode by default. To go into buffered mode, call

SDL_SetBooleanProperty(SDL_GetGlobalProperties(), SDL_PROP_IOSTREAM_AMIGAOS4_USE_BUFFERED, true);

before opening iostreams. Buffered mode uses FOpen() instead of Open().

================================================================================
WinUAE
================================================================================

Because WinUAE doesn't support hardware-accelerated compositing or 3D, you need
to install the following software:

- http://os4depot.net/index.php?function=showfile&file=graphics/misc/patchcompositetags.lha
- http://os4depot.net/index.php?function=showfile&file=library/graphics/wazp3d.lha

================================================================================
Tips
================================================================================

If you are already familiar with SDL 2, or porting SDL 2 code, it's worth
checking the migration guide at:

https://wiki.libsdl.org/SDL3/README/migration

Always check the return values of functions and in error case you can get more
information using SDL_GetError() function!

================================================================================
Limitations
================================================================================

Altivec support is disabled. It should be possible to enable in private builds
but it hasn't been tested so far.

Unsupported subsystems include Camera, GPU, Haptic, Pen, Power and Sensor. There
is no Vulkan backend for AmigaOS either.

"opengl" renderer doesn't exist anymore. This is due to missing features in
MiniGL.

Compositing renderer doesn't support triangle geometry API properly. Use
"software" or "opengles2" driver if you need it.

================================================================================
Project page and bug tracker
================================================================================

https://github.com/AmigaPorts/SDL
