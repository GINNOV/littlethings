/*

This is not an official SDL2 test. It's a collection of random tests
for doing ad-hoc testing related to AmigaOS 4 port.

*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <SDL3/SDL.h>
#include <SDL3/SDL_opengl.h>

#if SDL_BYTEORDER != SDL_BIG_ENDIAN
#warning "wrong endian?"
#endif

static void ToggleFullscreen(SDL_Window* w)
{
    static int t = 0;
    static Uint32 counter = 0;

    printf("Toggle fullscreen %d (counter %u)\n", t, counter++);
    SDL_SetWindowFullscreen(w, t ? SDL_WINDOW_FULLSCREEN : 0);

    t ^= 1;
}

static bool eventLoopInner(void)
{
    bool running = true;
    SDL_Event e;

    while(SDL_PollEvent(&e)) {
        switch (e.type) {
            case SDL_EVENT_QUIT:
                puts("Quit");
                running = false;
                break;
#if 0
            case SDL_WINDOWEVENT:
                {
                    SDL_WindowEvent * we = (SDL_WindowEvent *)&e;
                    printf("Window event %d window %d\n", we->type, we->windowID);
                }
                break;

	    case SDL_EVENT_SYSWM:
                printf("Sys WM event\n");
                break;
#endif
            case SDL_EVENT_KEY_DOWN:
                {
                    SDL_KeyboardEvent * ke = (SDL_KeyboardEvent *)&e;
                    printf("Key down scancode %d (%s), keycode %d (%s), mod %d\n",
                        ke->scancode, SDL_GetScancodeName(ke->scancode),
                        ke->key, SDL_GetKeyName(ke->key), ke->mod);

                    //if (ke->key == 13 && ke->mod == 256) {
                    //    SDL_Window * w = SDL_GetWindowFromID(ke->windowID);
                    //    ToggleFullscreen(w);
                    //}
                }
                break;

            case SDL_EVENT_KEY_UP:
                {
                    SDL_KeyboardEvent * ke = (SDL_KeyboardEvent *)&e;
                    printf("Key up %d\n", ke->scancode);
                }
                break;

            case SDL_EVENT_TEXT_EDITING:
                puts("Text editing");
                break;

            case SDL_EVENT_TEXT_INPUT:
                {
                    SDL_TextEditingEvent * te = (SDL_TextEditingEvent *)&e;
                    SDL_Window * w = SDL_GetWindowFromID(te->windowID);

                    printf("Text input '%s'\n", te->text);

                    if (strcmp("q", te->text) == 0) {
                        running = false;
                    } else if (strcmp("w", te->text) == 0) {
                        SDL_WarpMouseInWindow(w, 50, 50);
                    } else if (strcmp("f", te->text) == 0) {
                        ToggleFullscreen(w);
                    } else if (strcmp("t", te->text) == 0) {
                        puts("Change size...");
                        SDL_SetWindowSize(w, rand() % 1000, rand() % 1000);
                    } else if (strcmp("c", te->text) == 0) {
                        static int c = 1;
			if (c) {
                            SDL_ShowCursor();
			} else {
                            SDL_HideCursor();
			}
                        c ^= 1;
                    } else if (strcmp("l", te->text) == 0) {
                        puts("Flash");
                        SDL_FlashWindow(w, SDL_FLASH_BRIEFLY);
                    } else if (strcmp("x", te->text) == 0) {
                        puts("Maximize");
                        SDL_MaximizeWindow(w);
                    } else if (strcmp("r", te->text) == 0) {
                        puts("Restore");
                        SDL_RestoreWindow(w);
                    } else if (strcmp("b", te->text) == 0) {
                        static int b = 1;
                        SDL_SetWindowBordered(w, b);
                        b ^= 1;
                    }

                    int x, y;
                    SDL_GetWindowPosition(w, &x, &y);
                    printf("X %d, Y %d\n", x, y);
                }
                break;

            case SDL_EVENT_MOUSE_MOTION:
                {
                    SDL_MouseMotionEvent * me = (SDL_MouseMotionEvent *)&e;
                    printf("Mouse motion x=%f, y=%f, xrel=%f, yrel=%f\n", me->x, me->y, me->xrel, me->yrel);
                }
                break;

            case SDL_EVENT_MOUSE_BUTTON_DOWN:
                {
                    SDL_MouseButtonEvent * me = (SDL_MouseButtonEvent *)&me;
                    printf("Mouse button down %d, state %d\n", (int)me->button, (int)me->down);
                }
                break;

            case SDL_EVENT_MOUSE_BUTTON_UP:
                {
                    SDL_MouseButtonEvent * me = (SDL_MouseButtonEvent *)&me;
                    printf("Mouse button up %d, state %d\n", (int)me->button, (int)me->down);
                }
                break;

            case SDL_EVENT_MOUSE_WHEEL:
                {
                    SDL_MouseWheelEvent * me = (SDL_MouseWheelEvent *)&me;
                    printf("Mouse wheel x=%f, y=%f\n", me->x, me->y);
                }
                break;

            default:
                printf("Unhandled event %d\n", e.type);
                break;
        }
    }

    return running;
}

static void eventLoop()
{
    while (eventLoopInner()) {
        SDL_Delay(1);
        //SDL_WaitEvent(NULL);
    }
}

static void testPath(void)
{
    const char * bp = SDL_GetBasePath();
    printf("'%s'\n", bp);
    SDL_free((char*)bp);

    const char* pp = SDL_GetPrefPath("foo", "bar");
    printf("'%s'\n", pp);
    SDL_free((char*)pp);
}

static void testWindow()
{
    //SDL_Window * w = SDL_CreateWindow("blah", 100, 100, SDL_WINDOW_RESIZABLE);
    SDL_Window * w = SDL_CreateWindow("blah",
        100, 100,
        SDL_WINDOW_RESIZABLE |
        0
        //SDL_WINDOW_MINIMIZED
        //SDL_WINDOW_MAXIMIZED
        );

    if (w) {
        SDL_StartTextInput(w);
#if 0
        SDL_SetWindowMinimumSize(w, 50, 50);
        SDL_SetWindowMaximumSize(w, 200, 200);

        SDL_MinimizeWindow(w);
        SDL_Delay(1000);

        SDL_RestoreWindow(w);
        SDL_Delay(1000);

        SDL_MinimizeWindow(w);
        SDL_Delay(1000);

        SDL_SetWindowAlwaysOnTop(w, false);

        SDL_Delay(1000);

        SDL_SetWindowAlwaysOnTop(w, true);
#endif
        //SDL_FlashWindow(w, SDL_FLASH_UNTIL_FOCUSED);

        //SDL_Rect rect = { 10, 10, 80, 80 };
        //SDL_SetWindowMouseRect(w, &rect);
        //SDL_SetWindowMouseRect(w, NULL);

        SDL_SetWindowMinimumSize(w, 50, 50);
        SDL_SetWindowMaximumSize(w, 200, 200);

        //SDL_MaximizeWindow(w);
        //SDL_Delay(1000);
        //SDL_RestoreWindow(w);
        //SDL_Delay(1000);
        //SDL_MinimizeWindow(w);
        //SDL_Delay(1000);
        //SDL_RestoreWindow(w);

        eventLoop();

        SDL_DestroyWindow(w);
    }
}

static void testManyWindows()
{
    SDL_Window * w = SDL_CreateWindow("blah", 100, 100, 0);
    SDL_Window * w2 = SDL_CreateWindow("blah2", 100, 100, 0/*SDL_WINDOW_FULLSCREEN*/);

    if (w && w2) {
        SDL_StartTextInput(w);
        SDL_StartTextInput(w2);

        SDL_SetWindowMouseGrab(w, true);

        eventLoop();

        SDL_DestroyWindow(w);
        SDL_DestroyWindow(w2);
    }
}

static void testRelativeMouse()
{
    SDL_Window * w = SDL_CreateWindow("relative", 100, 100, 0);

    if (w) {
        SDL_StartTextInput(w);
        //SDL_SetRelativeMouseMode(false);
        //SDL_SetRelativeMouseMode(true);

        eventLoop();

        SDL_DestroyWindow(w);
    }
}

static void testFullscreen()
{
    SDL_Window * w = SDL_CreateWindow("Fullscreen",
        640, 480,
        SDL_WINDOW_FULLSCREEN);

    if (w) {
        SDL_StartTextInput(w);
        //SDL_SetWindowSize(w, 1280, 960);
        //SDL_SetWindowSize(w, 640, 480);
        //SDL_SetWindowSize(w, 800, 600);

        //SDL_SetWindowFullscreen(w, SDL_WINDOW_FULLSCREEN);
        //SDL_SetWindowFullscreen(w, SDL_WINDOW_FULLSCREEN);
        //SDL_SetWindowFullscreen(w, 0);
        //SDL_SetWindowFullscreen(w, 0);

        //SDL_Delay(3000);

#if 0
        SDL_DisplayMode dm;
        dm.format = SDL_PIXELFORMAT_ARGB8888;
        dm.screen_w = 1280;
        dm.screen_h = 960;
        dm.refresh_rate = 0;
        dm.driverdata = NULL;

        SDL_SetWindowFullscreenMode(w, &dm);
        SDL_SetWindowFullscreen(w, SDL_WINDOW_FULLSCREEN);
#endif
        eventLoop();

        SDL_DestroyWindow(w);
    }
}

// TODO: should load GL functions
// NOTE: will not work on OGLES2 (try testgles2.c instead of)
static void drawUsingFixedFunctionPipeline(SDL_Window *w)
{
    if (w) {
        SDL_GLContext c = SDL_GL_CreateContext(w);

        if (c) {

            //SDL_GL_SetSwapInterval(1);

            Uint32 start = SDL_GetTicks();
            Uint32 frames = 0;

            while (eventLoopInner()) {
                glMatrixMode(GL_PROJECTION);
                glLoadIdentity();

                glMatrixMode(GL_MODELVIEW);
                glLoadIdentity();

                glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
                glClear(GL_COLOR_BUFFER_BIT);

                glBegin(GL_TRIANGLES);

                glColor4f(1.0f, 0.0f, 0.0f, 1.0f);
                glVertex3f(-0.5f, -0.5f, 0.0f);

                glColor4f(0.0f, 1.0f, 0.0f, 1.0f);
                glVertex3f(0.5f, -0.5f, 0.0f);

                glColor4f(0.0f, 0.0f, 1.0f, 1.0f);
                glVertex3f(0.0f, 0.5f, 0.0f);

                glEnd();

                SDL_GL_SwapWindow(w);
                frames++;
            }

            Uint32 end = SDL_GetTicks();
            printf("%u frames in %u ms - %f\n", frames, end - start, 1000.f * frames / (end - start));


            SDL_GL_DestroyContext(c);
        }

        SDL_DestroyWindow(w);
    }

}

static SDL_Window* createWindow(const char *name)
{
    return SDL_CreateWindow(name,
        400,
        300,
        SDL_WINDOW_RESIZABLE | SDL_WINDOW_OPENGL);
}

static void testDeleteContext()
{
    SDL_Window* w = createWindow("Context deletion");
    if (w) {
        SDL_GLContext c = SDL_GL_CreateContext(w);

        if (c) {
            SDL_GL_DestroyContext(c);

            printf("Context after deletion: %p\n", SDL_GL_GetCurrentContext());

            SDL_SetWindowSize(w, 101, 101);

            c = SDL_GL_CreateContext(w);

            if (c) {
                SDL_GL_DestroyContext(c);
            }
        }
        SDL_DestroyWindow(w);
    }
}

static void testOpenGL()
{
    SDL_Window * w = createWindow("Centered & Resizable OpenGL window");

    drawUsingFixedFunctionPipeline(w);
}

static void testOpenGLES2()
{
    int mask, major, minor;

    SDL_GL_GetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, &mask);
    SDL_GL_GetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, &major);
    SDL_GL_GetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, &minor);

    printf("Current GL mask %d, major version %d, minor version %d\n", mask, major, minor);

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);

    SDL_Window * w = createWindow("Centered & Resizable OGLES2 window");

    if (w)
    {
        SDL_GLContext c = SDL_GL_CreateContext(w);

        if (c) {
            puts("OGLES2 context created, now exiting");
            SDL_GL_DestroyContext(c);
        } else {
            puts("Failed to create OGLES2 context");
        }

        SDL_DestroyWindow(w);
    } else {
        puts("Failed to create OGLES2 window");
    }

    // Restore flags
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, mask);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, major);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, minor);
}


static void testOpenGLSwitching()
{
    SDL_Window* w = createWindow("Centered & Resizable OpenGL window");

    if (w) {
        SDL_DestroyWindow(w);
    }

    // Switch to OGLES2
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);

    w = createWindow("Centered & Resizable OGLES2 window");

    if (w) {
        SDL_DestroyWindow(w);
    } else {
        printf("%s\n", SDL_GetError());
    }

    // Switch back to MiniGL
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, 0);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 1);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);

    w = createWindow("Centered & Resizable OpenGL window");

    drawUsingFixedFunctionPipeline(w);
}

static void testFullscreenOpenGL()
{
    SDL_Window * w = SDL_CreateWindow("Fullscreen",
        1200,
        900,
        SDL_WINDOW_FULLSCREEN | SDL_WINDOW_OPENGL);

    if (w) {
        SDL_StartTextInput(w);
        drawUsingFixedFunctionPipeline(w);
    }
}

static void testOpenGLVersion()
{
    int mask, major, minor;

    SDL_GL_GetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, &mask);
    SDL_GL_GetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, &major);
    SDL_GL_GetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, &minor);

    printf("Current GL mask %d, major version %d, minor version %d\n", mask, major, minor);
}

static void testRenderer()
{
    SDL_Window * r = SDL_CreateWindow("Red", 100, 100, SDL_WINDOW_RESIZABLE);
    SDL_Window * g = SDL_CreateWindow("Green", 100, 100, SDL_WINDOW_RESIZABLE);
    SDL_Window * b = SDL_CreateWindow("Blue", 100, 100, SDL_WINDOW_RESIZABLE);

    SDL_Renderer * rr = SDL_CreateRenderer(r, NULL);
    SDL_Renderer * gr = SDL_CreateRenderer(g, NULL);
    SDL_Renderer * br = SDL_CreateRenderer(b, NULL);

    //SDL_SetRenderLogicalSize(rr, 50, 50);
    //SDL_SetRenderLogicalSize(gr, 80, 80);
    //SDL_SetRenderLogicalSize(br, 90, 90);

    if (r && g && b && rr && gr && br) {
        SDL_StartTextInput(r);
        SDL_StartTextInput(g);
        SDL_StartTextInput(b);

        while (eventLoopInner()) {
            SDL_SetRenderDrawColor(rr, 255, 0, 0, 255);
            SDL_RenderClear(rr);
            SDL_RenderPresent(rr);

            SDL_SetRenderDrawColor(gr, 0, 255, 0, 255);
            SDL_RenderClear(gr);
            SDL_RenderPresent(gr);

            SDL_SetRenderDrawColor(br, 0, 0, 255, 255);
            SDL_RenderClear(br);
            SDL_RenderPresent(br);
        }

        SDL_DestroyRenderer(rr);
        SDL_DestroyRenderer(gr);
        SDL_DestroyRenderer(br);

        SDL_DestroyWindow(r);
        SDL_DestroyWindow(g);
        SDL_DestroyWindow(b);
    } else {
        printf("%s\n", SDL_GetError());
    }
}

static void testDraw()
{
    SDL_Window * w = SDL_CreateWindow("Draw", 200, 200, SDL_WINDOW_RESIZABLE);

    SDL_Renderer * r = SDL_CreateRenderer(w, NULL);

    if (w && r) {
        SDL_StartTextInput(w);

        while (eventLoopInner()) {
            SDL_FRect rect;

            SDL_SetRenderDrawColor(r, 100, 100, 100, 255);
            SDL_RenderClear(r);

            SDL_SetRenderDrawColor(r, 200, 200, 200, 255);

            rect.x = 10;
            rect.y = 10;
            rect.w = 100;
            rect.h = 100;

            SDL_RenderFillRect(r, &rect);

            SDL_RenderPresent(r);
        }

        SDL_DestroyRenderer(r);
        SDL_DestroyWindow(w);
    }
}

static void testRenderVsync()
{
    SDL_Window * w = SDL_CreateWindow("Draw", 200, 200, SDL_WINDOW_RESIZABLE);

    SDL_SetHint(SDL_HINT_RENDER_VSYNC, "1");

    SDL_Renderer * r = SDL_CreateRenderer(w, NULL);

    if (w && r) {
        SDL_StartTextInput(w);

        while (eventLoopInner()) {
            SDL_FRect rect;

            SDL_SetRenderDrawColor(r, 100, 100, 100, 255);
            SDL_RenderClear(r);

            SDL_SetRenderDrawColor(r, 200, 200, 200, 255);

            rect.x = 10;
            rect.y = 10;
            rect.w = 100;
            rect.h = 100;

            SDL_RenderFillRect(r, &rect);

            SDL_RenderPresent(r);
        }

        SDL_DestroyRenderer(r);
        SDL_DestroyWindow(w);
    }
}

static void testBmp()
{
    SDL_Surface *s = SDL_LoadBMP("sample.bmp");

    if (s) {
        SDL_DestroySurface(s);
    } else {
        printf("%s\n", SDL_GetError());
    }
}

static void testMessageBox()
{
    int button = 0;
    int result;

    const SDL_MessageBoxButtonData buttons[] = {
        {0, 1, "button 1"}, // flags, id, text
        {0, 2, "button 2"} // flags, id, text
    };

    const SDL_MessageBoxData mb = {
        0, // flags
        0, // window
        "Title",
        "Message",
        SDL_arraysize(buttons), // numbuttons
        buttons,
        NULL
    };

    result = SDL_ShowMessageBox(&mb, &button);

    printf("MB returned %d, button %d\n", result, button);
}

static void testAltivec()
{
    printf("AltiVec: %d\n", SDL_HasAltiVec());
}

static void testPC()
{
    Uint64 pc1 = SDL_GetPerformanceCounter();

    SDL_Delay(1000);

    Uint64 pc2 = SDL_GetPerformanceCounter();

    Uint64 f = SDL_GetPerformanceFrequency();

    double result = (pc2 - pc1) / (double)f;

    printf("%f s\n", result);
}

static void testSystemCursors()
{
    SDL_Window * w = SDL_CreateWindow("blah", 100, 100, 0);

    if (w) {
        int c = 0;

        SDL_StartTextInput(w);

        while (eventLoopInner()) {

            char buf[32];
            snprintf(buf, sizeof(buf), "Cursor %d", c);

            SDL_SetWindowTitle(w, buf);

            SDL_SetCursor( SDL_CreateSystemCursor(c) );
            SDL_ShowCursor();

            SDL_Delay(1000);

            if (++c == SDL_SYSTEM_CURSOR_COUNT) {
                c = 0;
                SDL_HideCursor();
                SDL_SetWindowTitle(w, "Hidden");
                SDL_Delay(1000);
            }
        }

        SDL_DestroyWindow(w);
    }
}

static void testCustomCursor()
{
    int w = 64;
    int h = 64;

    SDL_Surface *surface = SDL_CreateSurface(w, h, SDL_PIXELFORMAT_ARGB8888);

    if (surface) {

        int x, y;

        //printf("pitch %d\n", surface->pitch);

        for (y = 0; y < h; y++) {

            Uint32 *p = (Uint32 *)((Uint8 *)surface->pixels + y * surface->pitch);

            Uint32 color = 0xFF000000 | rand();

            for (x = 0; x < w; x++) {
                p[x] = color;
            }
        }

        //SDL_FillRect(surface, NULL, 0xFFFFFFFF);

        SDL_Window * w = SDL_CreateWindow("Custom cursor", 100, 100, 0);

        if (w) {
            SDL_StartTextInput(w);
            SDL_SetCursor( SDL_CreateColorCursor(surface, 0, 0));

            while (eventLoopInner()) {

                SDL_Delay(1000);
            }

            SDL_DestroyWindow(w);
        }

        SDL_DestroySurface(surface);
    }
}


static void testHiddenCursor()
{
    //SDL_ShowCursor(0);

    SDL_Window * w = SDL_CreateWindow("Hidden cursor", 640, 480, SDL_WINDOW_FULLSCREEN);

    if (w) {
        SDL_StartTextInput(w);
        while (eventLoopInner()) {
            SDL_Delay(1000);
        }

        SDL_DestroyWindow(w);
    }
}


static void testClipboard()
{
    SDL_Window * w = SDL_CreateWindow("Clipboard", 100, 100, 0);

    if (w) {
        SDL_StartTextInput(w);

        while (eventLoopInner()) {

            if (SDL_HasClipboardText()) {
                printf("Text '%s' found\n", SDL_GetClipboardText());
            }

            SDL_Delay(1000);
        }

        SDL_DestroyWindow(w);
     }

    puts("Leaving message to clipboard");

    SDL_SetClipboardText("Amiga rules!");
}

static void testHint()
{
    char *result1 = (char *)SDL_GetHint(SDL_HINT_VIDEO_MINIMIZE_ON_FOCUS_LOSS);
    char *result2 = (char *)SDL_GetHint("SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS");

    printf("%s, %s\n", result1, result2);
}

static void testGlobalMouseState()
{
    SDL_Window * w = SDL_CreateWindow("Global Mouse State", 100, 100, 0);

    if (w) {
        SDL_StartTextInput(w);

        while (eventLoopInner()) {

            float x = 0;
            float y = 0;

            printf("State 0x%x (%f, %f)\n", SDL_GetGlobalMouseState(&x, &y), x, y);
            SDL_Delay(1000);
        }

        SDL_DestroyWindow(w);
     }
}

static void testGlobalMouseWarp()
{
    SDL_Window * w = SDL_CreateWindow("Global Mouse Warp", 100, 100, 0);

    if (w) {
        SDL_StartTextInput(w);

        while (eventLoopInner()) {

            float x = rand() % 800;
            float y = rand() % 600;

            printf("Warping to %f, %f\n", x, y);
            SDL_WarpMouseGlobal(x, y);

            SDL_Delay(1000);
        }

        SDL_DestroyWindow(w);
     }
}

static void testOpaqueWindow()
{
    SDL_Window * w = SDL_CreateWindow("Opaque window", 100, 100, 0);

    if (w) {
        SDL_StartTextInput(w);

        while (eventLoopInner()) {
            float opacity = 0.0f;

            while (opacity <= 1.1f) {
                printf("Opacity %f\n", opacity);
                SDL_SetWindowOpacity(w, opacity);
                opacity += 0.1f;
                SDL_Delay(100);
            }
        }

        SDL_DestroyWindow(w);
     }
}

static void testWindowBordersSize()
{
    SDL_Window * w = SDL_CreateWindow("BorderSizes window", 100, 100, SDL_WINDOW_RESIZABLE);

    if (w) {
        SDL_StartTextInput(w);

        int top, left, bottom, right;

        SDL_GetWindowBordersSize(w, &top, &left, &bottom, &right);

        printf("top %d, left %d, bottom %d, right %d\n", top, left, bottom, right);

        while (eventLoopInner()) {
            SDL_Delay(1000);
        }

        SDL_DestroyWindow(w);
     }
}

static void testHiddenWindow()
{
    SDL_Window * w = SDL_CreateWindow("Hidden window", 100, 100, SDL_WINDOW_HIDDEN);

    if (w) {
        int i = 0;

        SDL_StartTextInput(w);

        while (eventLoopInner()) {

            SDL_Delay(1000);

            ((i++ % 2) == 0) ? SDL_ShowWindow(w) : SDL_HideWindow(w);
        }

        SDL_DestroyWindow(w);
     }
}

int main(void)
{
    if (SDL_Init(SDL_INIT_VIDEO/*|SDL_INIT_TIMER*/)) {
        if (0) testPath();
        if (0) testWindow();
        if (0) testManyWindows();
        if (1) testFullscreen();
        if (0) testFullscreenOpenGL();
        if (0) testDeleteContext();
        if (0) testOpenGL();
        if (0) testOpenGLES2();
        if (0) testOpenGLSwitching();
        if (0) testOpenGLVersion();
        if (0) testRenderer();
        if (0) testDraw();
        if (0) testMessageBox();
        if (0) testBmp();
        if (0) testAltivec();
        if (0) testRenderVsync();
        if (0) testPC();
        if (0) testPC();
        if (0) testSystemCursors();
        if (0) testCustomCursor();
        if (0) testHiddenCursor();
        if (0) testClipboard();
        if (0) testHint();
        if (0) testGlobalMouseState();
        if (0) testGlobalMouseWarp();
        if (0) testOpaqueWindow();
        if (0) testWindowBordersSize();
        if (0) testHiddenWindow();
        if (0) testRelativeMouse();
    } else {
        printf("%s\n", SDL_GetError());
    }

    SDL_Quit();

    return 0;
}
