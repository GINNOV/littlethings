#include <stdio.h>
#include <proto/exec.h>
#include <graphics/gfxbase.h>
#include <exec/execbase.h>

struct GfxBase *GraphicsBase;
extern struct ExecBase *SysBase;

main()
{
    int isAGA = 0;

    // first AGA Amiga had V39
    // V37 is found in kickstart 2.04
    // V34 in kickstart 1.3
    int version = 39;

    printf("Kickstart v%d, ", SysBase->LibNode.lib_Version);

    GraphicsBase=(struct GfxBase *)OpenLibrary("graphics.library",version);

    if (GraphicsBase){
        printf("Graphics.library V%d OK \n",version);
        isAGA = (GraphicsBase->ChipRevBits0 & GFXF_AA_ALICE) > 0;
        printf("has AGA: %d \n",isAGA);
        CloseLibrary((struct Library *)GraphicsBase);
    }else{
        printf("No AGA \n");
        version = 37;
        GraphicsBase=(struct GfxBase *)OpenLibrary("graphics.library",version);
        if (GraphicsBase){
            printf("Graphics.library V%d OK \n",version);
            CloseLibrary((struct Library *)GraphicsBase);
        }else{
            printf("Graphics.library Version lower then 37 \n");
        }
    }

    return 0;

}