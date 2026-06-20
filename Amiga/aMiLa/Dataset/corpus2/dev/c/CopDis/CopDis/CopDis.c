;/* Execute me to compile with GCC 2.7.2.1
stack 200000
gcc -pipe -o CopDis CopDis.c -noixemul -s -O3
quit
*/

void __chkabort(void) { return; } // disable Ctrl-C handling

#include <exec/exec.h>
#include <graphics/gfxbase.h>
#include <graphics/copper.h>
#include <graphics/view.h>

#include <clib/exec_protos.h>

// #define COP_DIS_NO_CTRL_C
#include "copdis.h"

struct GfxBase *GfxBase;

main()
{
  if ( GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",0) )
    {

      printf("LOFCprList:\n");
      if ( cop_dis(GfxBase->ActiView->LOFCprList->start) )
        {
          if (GfxBase->ActiView->Modes & LACE)
            {
              printf("\nSHFCprList:\n");
              cop_dis(GfxBase->ActiView->SHFCprList->start);
            }
        }

      CloseLibrary( (struct Library *)GfxBase );
    }
}

