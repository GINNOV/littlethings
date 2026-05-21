#include <proto/all.h>
#include <stdio.h>
#include <graphics/gfxbase.h>

int main(void){
    struct Screen *screen;
    struct GfxBase *gfxBase;
    struct ViewPort *viewPort;
    struct ColorMap *colorMap;
    

    unsigned char screenName[] = "Workbench";
    
    int count;
    LONG penIdex;
    UWORD version;

    const unsigned short targetColor[] = {204,0,0};
    screen = LockPubScreen(screenName);
    if (screen){

        gfxBase = (struct GfxBase *)OpenLibrary ("graphics.library",  0);
        if (gfxBase){
            version = (gfxBase->LibNode).lib_Version;
            if (version>=39){
                // we have at least version 39 with the features we need
                viewPort = &screen->ViewPort;
                colorMap = viewPort->ColorMap;
                count = colorMap->Count;
                printf("WB Screen has %d Colors\n", count);

                if (count>4){
                    // check if we can set pen 4 (or use -1 to use any available pen)
                    penIdex = ObtainPen(colorMap,4,
                    targetColor[0] << 24,
                    targetColor[1] << 24,
                    targetColor[2] << 24,
                    PEN_EXCLUSIVE);

                    if (penIdex < 0){
                        puts("---\nCould not set pen 4");
                        // you can still change it anyway with SetRGB4 or SetRGB32, but that would not be nice.
                    }else{
                        puts("---\nPen was changed");
                    }
                    ReleasePen(colorMap, 4);
                }
            }else{
                printf("Sorry, I need at least V39 of graphics.library, your version is %d",version);
            }
        }else{
		    puts("graphics.library could not be opened");
	    }

        if (gfxBase) CloseLibrary((struct Library *)gfxBase);
        UnlockPubScreen(NULL, screen);
    }
    return 0;
}
