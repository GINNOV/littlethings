#include <proto/all.h>
#include <stdio.h>
#include <graphics/gfxbase.h>

struct GfxBase *gfxBase;

int main(void){
    UWORD version;
    UWORD revision;
    gfxBase = (struct GfxBase *)OpenLibrary ("graphics.library",  0);
    if (gfxBase){
        version = (gfxBase->LibNode).lib_Version;
        revision = (gfxBase->LibNode).lib_Revision;
		printf("graphics.library: %d.%d\n",version,revision);
	}else{
		puts("graphics.library could not be opened");
	}

    if (gfxBase) CloseLibrary((struct Library *)gfxBase);
    return 0;
}