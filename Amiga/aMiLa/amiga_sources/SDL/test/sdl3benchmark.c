/*

This is a simple SDL3 renderer benchmark tool. It test every active
renderer with available blend modes.

On AmigaOS, result may be affected by Workbench screen depth in case
pixel conversion takes place. For example compositing renderer works
best with 32-bit screen mode.

Some blend modes may not be supported for all renderers. These tests
will give failure.

TODO:
- command line arguments for things like window size, iterations...

*/

#include <stdlib.h>

#include <SDL3/SDL.h>

#define BENCHMARK_VERSION "1.2"

#define WIDTH 800
#define HEIGHT 600

#define RECTSIZE 100

#define DURATION 1.0
#define OBJECTS 100

#define SLEEP 0

#ifdef __amigaos4__
static const char stackCookie[] __attribute__((used)) = "$STACK:60000";
#endif

typedef struct {
    SDL_Renderer *renderer;
    SDL_Window *window;
    SDL_Texture *texture;
    SDL_Surface *surface;
    SDL_Surface *windowSurface;
    SDL_BlendMode mode;
    Sint32 width;
    Sint32 height;
    Uint32 rectsize;
    Uint32 texturewidth;
    Uint32 textureheight;
    Uint64 frequency;
    double duration;
    Uint32 objects;
    Uint32 sleep;
    Uint32 frames;
    Uint32 operations;
    Uint32 *buffer;
    bool running;
    const char* rendname;
    Uint64 bytes;
    Uint32 seed;
} Context;

typedef struct {
    const char *name;
    bool (*testfp)(Context *);
    bool usetexture;
    bool testBlendModes;
} Test;

typedef struct {
    const char *name;
    SDL_BlendMode mode;
} BlendMode;

/* Test function prototypes */
static bool testPoints(Context *);
static bool testLines(Context *);
static bool testFillRects(Context *);
static bool testRenderCopy(Context *);
static bool testRenderCopyEx(Context *);
static bool testColorModulation(Context *);
static bool testAlphaModulation(Context *);
static bool testUpdateTexture(Context *);
static bool testReadPixels(Context *);
static bool testBlitSurface(Context *);
static bool testBlitSurfaceScaledNearest(Context *);
static bool testBlitSurfaceScaledLinear(Context *);

/* Insert here new tests */
static const Test tests[] = {
    { "Points", testPoints, false, true },
    { "Lines", testLines, false, true },
    { "FillRects", testFillRects, false, true },
    { "RenderCopy", testRenderCopy, true, true },
    { "RenderCopyEx", testRenderCopyEx, true, true },
    { "Color modulation", testColorModulation, true, true },
    { "Alpha modulation", testAlphaModulation, true, true },
    { "UpdateTexture", testUpdateTexture, true, false },
    { "ReadPixels", testReadPixels, true, false }
};

static const Test framebufferTests[] = {
    { "BlitSurface", testBlitSurface, false, true },
    { "BlitSurfaceScaledNearest", testBlitSurfaceScaledNearest, false, true },
    { "BlitSurfaceScaledLinear", testBlitSurfaceScaledLinear, false, true }
};

static const BlendMode modes[] = {
    { "None", SDL_BLENDMODE_NONE },
    { "Blend", SDL_BLENDMODE_BLEND },
#if 0
    { "Add", SDL_BLENDMODE_ADD },
    { "Mod", SDL_BLENDMODE_MOD }
#endif
};

static const char *
getModeName(SDL_BlendMode mode)
{
    static const char *unknown = "Unknown";

    for (size_t i = 0; i < sizeof(modes) / sizeof(modes[0]); i++)
    {
        if (modes[i].mode == mode) {
            return modes[i].name;
        }
    }

    return unknown;
}

static void
printInfo(Context *ctx)
{
    const char* name = SDL_GetRendererName(ctx->renderer);

    SDL_Log("Starting to test renderer called [%s]\n", name);
}

static void
render(Context *ctx)
{
    if (ctx->windowSurface) {
        const bool result = SDL_UpdateWindowSurface(ctx->window);
        if (!result) {
            SDL_Log("[%s]Failed to update window surface: %s\n", __FUNCTION__, SDL_GetError());
        }
    } else {
        const bool result = SDL_RenderPresent(ctx->renderer);
        if (!result) {
            SDL_Log("[%s]Failed to render: %s\n", __FUNCTION__, SDL_GetError());
        }
    }

    ctx->frames++;
}

static bool
clearDisplay(Context *ctx)
{
    if (ctx->windowSurface) {
        bool result = SDL_ClearSurface(ctx->windowSurface, 0.0f, 0.0f, 0.0f, 1.0f);
        if (!result) {
            SDL_Log("[%s]Failed to clear surface: %s\n", __FUNCTION__, SDL_GetError());
            return false;
        }
        result = SDL_UpdateWindowSurface(ctx->window);
        if (!result) {
            SDL_Log("[%s]Failed to update window surface: %s\n", __FUNCTION__, SDL_GetError());
            return false;
        }
        return true;
    }

    bool result;

    if (ctx->mode != SDL_BLENDMODE_MOD) {
        result = SDL_SetRenderDrawColor(ctx->renderer, 0, 0, 0, SDL_ALPHA_OPAQUE);
    } else {
        result = SDL_SetRenderDrawColor(ctx->renderer, 255, 255, 255, SDL_ALPHA_OPAQUE);
    }

    if (!result) {
        SDL_Log("[%s]Failed to set draw color: %s\n", __FUNCTION__, SDL_GetError());
        return false;
    }

    result = SDL_RenderClear(ctx->renderer);

    if (!result) {
        SDL_Log("[%s]Failed to clear: %s\n", __FUNCTION__, SDL_GetError());
        return false;
    }

    SDL_RenderPresent(ctx->renderer);

    return true;
}

/*
static float interpolate(float min, float max, float percentage)
{
    return min + percentage * (max - min);
}
*/

static Uint32
getRand(const Uint32 max)
{
    if (max == 0) {
        return 0;
    } else if (max > (SDL_MAX_SINT32 / 2)) {
        SDL_Log("Too large max value %u\n", max);
        return 0;
    }

    return rand() % max;
}

static void
makeRandomTexture(Context *ctx)
{
    SDL_memset(ctx->buffer, 0, ctx->texturewidth * ctx->textureheight * sizeof(Uint32));

    for (int i = 0; i < 100; i++) {
        ctx->buffer[
            getRand(ctx->texturewidth) +
            getRand(ctx->textureheight) * ctx->texturewidth] = 0xFFFFFFFF;
    }
}

static bool
prepareTexture(Context *ctx)
{
    bool result = SDL_SetSurfaceColorKey(ctx->surface, 1, 0);

    if (!result) {
        SDL_Log("[%s]Failed to set color key: %s\n", __FUNCTION__, SDL_GetError());
        return false;
    }

    if (ctx->texture) {
        SDL_Log("Old texture!\n");
    }

    ctx->texture = SDL_CreateTextureFromSurface(ctx->renderer, ctx->surface);

    if (!ctx->texture) {
        SDL_Log("[%s]Failed to create texture: %s\n", __FUNCTION__, SDL_GetError());
        return false;
    }

    result = SDL_SetTextureBlendMode(ctx->texture, ctx->mode);

    if (!result) {
        SDL_Log("[%s]Failed to set texture blend mode: %s\n", __FUNCTION__, SDL_GetError());
        SDL_DestroyTexture(ctx->texture);
        ctx->texture = NULL;
        return false;
    }

    result = SDL_SetTextureScaleMode(ctx->texture, SDL_SCALEMODE_NEAREST);

    if (!result) {
        SDL_Log("[%s]Failed to set texture scale mode: %s\n", __FUNCTION__, SDL_GetError());
        SDL_DestroyTexture(ctx->texture);
        ctx->texture = NULL;
        return false;
    }

    ctx->texturewidth = ctx->surface->w;
    ctx->textureheight = ctx->surface->h;

    ctx->buffer = SDL_malloc(ctx->texturewidth * ctx->textureheight * sizeof(Uint32));

    if (!ctx->buffer) {
        SDL_Log("[%s]Failed to allocate texture buffer: %s\n", __FUNCTION__, SDL_GetError());
        SDL_DestroyTexture(ctx->texture);
        ctx->texture = NULL;
        return false;
    }

    makeRandomTexture(ctx);

    return true;
}

static bool
prepareTest(Context *ctx, const Test *test)
{
    if (!clearDisplay(ctx)) {
        return false;
    }

    if (test->usetexture) {
        if (!prepareTexture(ctx)) {
            return false;
        }
    }

    ctx->frames = 0;
    ctx->operations = 0;
    ctx->bytes = 0;

    srand(ctx->seed);

    return true;
}

static void
afterTest(Context *ctx)
{
    if (ctx->texture) {
        SDL_DestroyTexture(ctx->texture);
        ctx->texture = NULL;
    }

    if (ctx->buffer) {
        SDL_free(ctx->buffer);
        ctx->buffer = NULL;
    }

    if (ctx->sleep) {
        SDL_Delay(ctx->sleep);
    }
}

static bool
runTest(Context *ctx, const Test *test)
{
    Uint64 start, finish;
    double duration, fps, ops, bps;

    if (!prepareTest(ctx, test)) {
        return false;
    }

    start = SDL_GetPerformanceCounter();

    do {
        if (!test->testfp(ctx)) {
            afterTest(ctx);
            return false;
        }

        finish = SDL_GetPerformanceCounter();

        duration = (finish - start) / (double)ctx->frequency;
    } while (duration < ctx->duration);

    if (duration == 0.0) {
        SDL_Log("Division by zero!\n");
        afterTest(ctx);
        return false;
    }

    fps = (double)ctx->frames / duration;
    ops = (double)ctx->operations / duration;
    bps = (double)ctx->bytes / duration / 1000000;

    if (fps == ops) {
        SDL_Log("%s [mode: %s]...%d frames drawn in %.3f seconds => %.1f frames/s\n",
            test->name, getModeName(ctx->mode), ctx->frames, duration, fps);
    } else {
        if (fps > 0.0f) {
            SDL_Log("%s [mode: %s]...%d frames drawn in %.3f seconds => %.1f frames/s, %.1f operations/s, %.1f megabytes/s\n",
                test->name, getModeName(ctx->mode), ctx->frames, duration, fps, ops, bps);
        } else {
            SDL_Log("%s [mode: %s]...%.1f operations/s, %.1f megabytes/s\n",
                test->name, getModeName(ctx->mode), ops, bps);
        }
    }

    afterTest(ctx);

    return true;
}

static bool
setRandomColor(Context *ctx)
{
    const bool result = SDL_SetRenderDrawColor(ctx->renderer,
        getRand(256), getRand(256), getRand(256), getRand(256));

    if (!result) {
        SDL_Log("[%s]Failed to set color: %s\n", __FUNCTION__, SDL_GetError());
        return false;
    }

    return true;
}

static bool testPointsInner(Context *ctx, bool linemode)
{
    bool result = SDL_SetRenderDrawBlendMode(ctx->renderer, ctx->mode);

    if (!result) {
        SDL_Log("[%s]Failed to set blend mode: %s\n", __FUNCTION__, SDL_GetError());
        return false;
    }

    SDL_FPoint points[ctx->objects];

    if (!setRandomColor(ctx)) {
        return false;
    }

    for (size_t object = 0; object < ctx->objects; object++) {
        points[object].x = getRand(ctx->width);
        points[object].y = getRand(ctx->height);
    }

    result = linemode ?
        SDL_RenderLines(ctx->renderer, points, ctx->objects) :
        SDL_RenderPoints(ctx->renderer, points, ctx->objects);

    ctx->operations++;

    if (!result) {
        SDL_Log("[%s]Failed to draw lines/points: %s\n", __FUNCTION__, SDL_GetError());
        return false;
    }

    render(ctx);

    return true;
}

static bool
testPoints(Context *ctx)
{
    return testPointsInner(ctx, false);
}

static bool
testLines(Context *ctx)
{
    return testPointsInner(ctx, true);
}

static bool
testFillRects(Context *ctx)
{
    bool result = SDL_SetRenderDrawBlendMode(ctx->renderer, ctx->mode);

    if (!result) {
        SDL_Log("[%s]Failed to set blend mode: %s\n", __FUNCTION__, SDL_GetError());
        return false;
    }

    SDL_FRect rects[ctx->objects];

    if (!setRandomColor(ctx)) {
        return false;
    }

    const int rectsize = ctx->rectsize + getRand(100); // + iteration

    for (size_t object = 0; object < ctx->objects; object++) {
        rects[object].x = getRand(SDL_max(ctx->width - rectsize, 0));
        rects[object].y = getRand(SDL_max(ctx->height - rectsize, 0));
        rects[object].w = rectsize;
        rects[object].h = rectsize;
    }

    result = SDL_RenderFillRects(ctx->renderer, rects, ctx->objects);

    if (!result) {
        SDL_Log("[%s]Failed to draw filled rectangles: %s\n", __FUNCTION__, SDL_GetError());
        return false;
    }

    ctx->operations++;

    render(ctx);

    return true;
}

static bool
testRenderCopyInner(Context *ctx, bool ex)
{
    bool result;

    //int object;
    //const float scale = interpolate(0.5f, 2.0f, (float)ctx->iteration / ctx->iterations);
    const float scale = (getRand(4) + 1) / 2.0f;

    const int w = SDL_lround(ctx->texturewidth * scale);
    const int h = SDL_lround(ctx->textureheight * scale);

    //for (object = 0; object < ctx->objects; object++) {
        SDL_FRect rect;

        rect.x = getRand(SDL_max(ctx->width - w, 0));
        rect.y = getRand(SDL_max(ctx->height - h, 0));
        rect.w = w;
        rect.h = h;

        if (!ex) {
            result = SDL_RenderTexture(ctx->renderer, ctx->texture, NULL, &rect);
        } else {
            result = SDL_RenderTextureRotated(
                ctx->renderer,
                ctx->texture,
                NULL,
                &rect,
                getRand(360),
                NULL,
                SDL_FLIP_NONE);
        }

        if (!result) {
            SDL_Log("[%s]Failed to draw texture: %s\n", __FUNCTION__, SDL_GetError());
            return false;
        }

        ctx->operations++;
    //}

    render(ctx);

    return true;
}

static bool
testRenderCopy(Context *ctx)
{
    return testRenderCopyInner(ctx, false);
}

static bool
testRenderCopyEx(Context *ctx)
{
    return testRenderCopyInner(ctx, true);
}

static const SDL_Color colors[] = {
    { 255, 0, 0, 255 },
    { 0, 255, 0, 255 },
    { 0, 0, 255, 255 },
    { 127, 127, 127, 255 }
};

static const size_t count = sizeof(colors) / sizeof(colors[0]);

static bool
testColorModulation(Context *ctx)
{
    static int i = 0;

    const int c = i++ % count;

    if (!SDL_SetTextureColorMod(ctx->texture, colors[c].r, colors[c].g, colors[c].b)) {
        SDL_Log("[%s]Failed to set color modulation: %s\n", __FUNCTION__, SDL_GetError());
        return false;
    }

    return testRenderCopyInner(ctx, false);
}

static bool
testAlphaModulation(Context *ctx)
{
    if (!SDL_SetTextureAlphaMod(ctx->texture, 127)) {
        SDL_Log("[%s]Failed to set alpha modulation: %s\n", __FUNCTION__, SDL_GetError());
        return false;
    }

    return testRenderCopyInner(ctx, false);
}

static bool
testUpdateTexture(Context *ctx)
{
    if (!SDL_UpdateTexture(ctx->texture, NULL, ctx->buffer, ctx->texturewidth * sizeof(Uint32))) {
        SDL_Log("[%s]Failed to update texture: %s\n", __FUNCTION__, SDL_GetError());
        return false;
    }

    ctx->operations++;
    ctx->bytes += ctx->texturewidth * ctx->textureheight * sizeof(Uint32);

    return true;
}

static bool
testReadPixels(Context *ctx)
{
    bool result = true;

    SDL_Rect rect;
    rect.x = getRand(SDL_max(ctx->width - ctx->texturewidth, 0));
    rect.y = getRand(SDL_max(ctx->height - ctx->textureheight, 0));
    rect.w = ctx->texturewidth;
    rect.h = ctx->textureheight;

    SDL_Surface *s = SDL_RenderReadPixels(ctx->renderer, &rect);

    if (s) {
        SDL_DestroySurface(s);
    } else {
        SDL_Log("[%s]Failed to read pixels: %s\n", __FUNCTION__, SDL_GetError());
        result = false;
    }

    ctx->operations++;
    ctx->bytes += rect.w * rect.h * sizeof(Uint32);

    return result;
}

static bool
testBlitSurface(Context *ctx)
{
    bool result = SDL_SetSurfaceBlendMode(ctx->surface, ctx->mode);

    if (!result) {
        SDL_Log("[%s]Failed to set blend mode: %s\n", __FUNCTION__, SDL_GetError());
        return false;
    }

    SDL_Rect rect;
    rect.x = getRand(SDL_max(ctx->width - ctx->texturewidth, 0));
    rect.y = getRand(SDL_max(ctx->height - ctx->textureheight, 0));
    rect.w = ctx->texturewidth;
    rect.h = ctx->textureheight;

    result = SDL_BlitSurface(ctx->surface, NULL, ctx->windowSurface, &rect);

    if (!result) {
        SDL_Log("[%s]Failed to blit surface: %s\n", __FUNCTION__, SDL_GetError());
    }

    ctx->operations++;
    render(ctx);

    return result;
}

static bool
testBlitSurfaceScaled(Context *ctx, SDL_ScaleMode scaleMode)
{
    bool result = SDL_SetSurfaceBlendMode(ctx->surface, ctx->mode);

    if (!result) {
        SDL_Log("[%s]Failed to set blend mode: %s\n", __FUNCTION__, SDL_GetError());
        return false;
    }

    const float scale = (getRand(4) + 1) / 2.0f;

    const int w = SDL_lround(ctx->texturewidth * scale);
    const int h = SDL_lround(ctx->textureheight * scale);

    SDL_Rect rect;
    rect.x = getRand(SDL_max(ctx->width - w, 0));
    rect.y = getRand(SDL_max(ctx->height - h, 0));
    rect.w = w;
    rect.h = h;

    result = SDL_BlitSurfaceScaled(ctx->surface, NULL, ctx->windowSurface, &rect, scaleMode);

    if (!result) {
        SDL_Log("[%s]Failed to blit surface scaled: %s\n", __FUNCTION__, SDL_GetError());
    }

    ctx->operations++;
    render(ctx);

    return result;
}

static bool
testBlitSurfaceScaledNearest(Context *ctx)
{
    return testBlitSurfaceScaled(ctx, SDL_SCALEMODE_NEAREST);
}

static bool
testBlitSurfaceScaledLinear(Context *ctx)
{
    return testBlitSurfaceScaled(ctx, SDL_SCALEMODE_LINEAR);
}

static void
checkEvents(Context *ctx)
{
    SDL_Event e;

    while (SDL_PollEvent(&e)) {
        if (e.type == SDL_EVENT_KEY_DOWN) {
            SDL_KeyboardEvent *ke = (SDL_KeyboardEvent *)&e;

            if (ke->key == SDLK_ESCAPE) {
                SDL_Log("Quitting...\n");
                ctx->running = false;
            }
        }
        if (e.type == SDL_EVENT_QUIT) {
            SDL_Log("Quitting...\n");
            ctx->running = false;
        }
    }
}

static void
runTestSuite(Context *ctx)
{
    for (size_t t = 0; t < sizeof(tests) / sizeof(tests[0]); t++) {
        for (size_t m = 0; m < sizeof(modes) / sizeof(modes[0]); m++) {
            ctx->mode = modes[m].mode;

            runTest(ctx, &tests[t]);

            checkEvents(ctx);

            if (!ctx->running) {
                return;
            }

            if (!tests[t].testBlendModes) {
                break; // Skip the rest
            }
        }
    }
}

static void
runFramebufferTestSuite(Context *ctx)
{
    for (size_t t = 0; t < sizeof(framebufferTests) / sizeof(framebufferTests[0]); t++) {
        for (size_t m = 0; m < sizeof(modes) / sizeof(modes[0]); m++) {
            ctx->mode = modes[m].mode;

            runTest(ctx, &framebufferTests[t]);

            checkEvents(ctx);

            if (!ctx->running) {
                return;
            }
        }
    }
}

/* TODO: need proper handling */
static void
checkParameters(Context *ctx, int argc, char **argv)
{
    if (argc > 3) {
        ctx->sleep = atoi(argv[3]);
    }

    if (argc > 2) {
        ctx->duration = atof(argv[2]);
    }

    if (argc > 1) {
        ctx->rendname = argv[1];
    }
}

static void
initContext(Context *ctx, int argc, char **argv)
{
    SDL_memset(ctx, 0, sizeof(Context));

    ctx->frequency = SDL_GetPerformanceFrequency();

    ctx->width = WIDTH;
    ctx->height = HEIGHT;
    ctx->rectsize = RECTSIZE;
    ctx->duration = DURATION;
    ctx->objects = OBJECTS;
    ctx->sleep = SLEEP;
    ctx->running = true;
    ctx->seed = 0xA5F05A0F;
    ctx->windowSurface = NULL;

    checkParameters(ctx, argc, argv);

    SDL_Log("Parameters: width %d, height %d, renderer name '%s', duration %.3f s, objects %u, sleep %u, seed 0x%X\n",
        ctx->width, ctx->height, ctx->rendname, ctx->duration, ctx->objects, ctx->sleep, ctx->seed);
}

static void
checkPixelFormat(Context *ctx)
{
    const Uint32 pf = SDL_GetWindowPixelFormat(ctx->window);

    SDL_Log("Pixel format 0x%X (%s)\n", pf, SDL_GetPixelFormatName(pf));

    if (pf != SDL_PIXELFORMAT_ARGB8888 && pf != SDL_PIXELFORMAT_XRGB8888) {
        SDL_Log("NOTE: window's pixel format not ARGB8888 - possible bitmap conversion can slow down\n");
    }
}

static void
testRenderer(Context *ctx)
{
    if (ctx->renderer) {
        printInfo(ctx);

        runTestSuite(ctx);

        SDL_DestroyRenderer(ctx->renderer);
    } else {
        SDL_Log("Failed to create renderer: %s\n", SDL_GetError());
    }
}

static void
testSpecificRenderer(Context *ctx)
{
    SDL_SetHint(SDL_HINT_RENDER_DRIVER, ctx->rendname);

    ctx->renderer = SDL_CreateRenderer(ctx->window, NULL);

    testRenderer(ctx);
}

static void
testAllRenderers(Context *ctx)
{
    for (int r = 0; r < SDL_GetNumRenderDrivers(); r++) {
        ctx->renderer = SDL_CreateRenderer(ctx->window, SDL_GetRenderDriver(r));

        testRenderer(ctx);

        if (!ctx->running) {
            break;
        }
    }
}

static void
testFramebuffer(Context *ctx)
{
    SDL_Log("SDL_HINT_FRAMEBUFFER_ACCELERATION value %s\n", SDL_GetHint(SDL_HINT_FRAMEBUFFER_ACCELERATION));

    ctx->windowSurface = SDL_GetWindowSurface(ctx->window);
    if (!ctx->windowSurface) {
        SDL_Log("Failed to get window surface: %s\n", SDL_GetError());
        return;
    }

    SDL_Surface* converted = SDL_ConvertSurface(ctx->surface, ctx->windowSurface->format);
    if (!converted) {
        SDL_Log("Failed to convert surface: %s\n", SDL_GetError());
        return;
    }

    SDL_DestroySurface(ctx->surface);
    ctx->surface = converted;

    runFramebufferTestSuite(ctx);
}

int
main(int argc, char **argv)
{
    Context ctx;

    if (!SDL_Init(SDL_INIT_VIDEO)) {
        SDL_Log("Init failed: %s\n", SDL_GetError());
        return -1;
    }

    const int version = SDL_GetVersion();

    SDL_Log("SDL3 renderer benchmark v. " BENCHMARK_VERSION " (SDL version %d.%d.%d)\n",
        SDL_VERSIONNUM_MAJOR(version), SDL_VERSIONNUM_MINOR(version), SDL_VERSIONNUM_MICRO(version));

    SDL_Log("This tool measures the speed of various 2D drawing features\n");
    SDL_Log("Press ESC key to quit\n");

    initContext(&ctx, argc, argv);

    ctx.surface = SDL_LoadPNG("sample.png");

    if (ctx.surface) {
        SDL_Log("Image size %d*%d\n", ctx.surface->w, ctx.surface->h);

        ctx.window = SDL_CreateWindow(
            "SDL3 benchmark",
            ctx.width,
            ctx.height,
            0 /*SDL_WINDOW_FULLSCREEN*/);

        if (ctx.window) {
            checkPixelFormat(&ctx);

            if (ctx.rendname) {
                testSpecificRenderer(&ctx);
            } else {
                testAllRenderers(&ctx);
            }

            testFramebuffer(&ctx);

            SDL_DestroyWindow(ctx.window);
        } else {
            SDL_Log("Failed to create window: %s\n", SDL_GetError());
        }

        SDL_DestroySurface(ctx.surface);

    } else {
        SDL_Log("Failed do load image: %s\n", SDL_GetError());
    }

    SDL_Log("Bye bye\n");

    SDL_Quit();

    return 0;
}
