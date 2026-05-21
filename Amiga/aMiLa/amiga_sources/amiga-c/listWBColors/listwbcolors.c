/* lists the Workbench Colors */

#include <proto/intuition.h>
#include <proto/graphics.h>

#include <stdio.h>

int main(void)
{
    struct Screen *screen;
    unsigned char screenName[] = "Workbench";
    unsigned long colorTable[256 * 3];

    struct ViewPort *viewPort;
    struct ColorMap *colorMap;

    int i;
    unsigned long r, g, b;

    screen = LockPubScreen(screenName);

    if (screen)
    {
        viewPort = &screen->ViewPort;
        colorMap = viewPort->ColorMap;

        GetRGB32(colorMap, 0, colorMap->Count, colorTable);

        UnlockPubScreen(NULL, screen);

        printf("---\n");
        printf("WB Screen has %d Colors\n", colorMap->Count);
        printf("---\n");

        if (colorMap->Count<=256){
            for (i = 0; i < colorMap->Count; i++)
            {
                r = colorTable[i * 3 + 0] >> 24;
                g = colorTable[i * 3 + 1] >> 24;
                b = colorTable[i * 3 + 2] >> 24;

                printf("Color: %d  red: %03d  green: %03d  blue: %03d\n", i, r, g, b);
            }
        }
    }

    return 0;
}