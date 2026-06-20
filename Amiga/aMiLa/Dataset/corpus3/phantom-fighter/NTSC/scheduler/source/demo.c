#include <hardware/cia.h>
#include <graphics/gfxbase.h>

struct GfxBase *GfxBase;

extern void *OpenLibrary();

void main()
{
   int i;

   GfxBase=OpenLibrary("graphics.library",0);
   ciaa.ciatalo=0xff;
   ciaa.ciatahi=0xff;
   ciaa.ciatblo=0xff;
   ciaa.ciatbhi=0xff;
   
   ciaa.ciacra =CIACRAF_START|		/* Start timer */
                CIACRAF_LOAD;		/* Load with prescaler */

   ciaa.ciacrb =CIACRBF_START|		/* Start Timer */
                CIACRBF_LOAD|		/* Load prescaler */
                CIACRBF_IN_TA;		/* Count timer a underflows */
                
   for(i=0;i<1000;++i) WaitTOF();
   ciaa.ciacra =0;			/* Stop Timer A */
   ciaa.ciacrb = CIACRBF_IN_TA;		/* Stop B */

   printf("ffffffff\n");
   
   printf("%02x%02x%02x%02x\n",ciaa.ciatbhi,
   			   ciaa.ciatblo,
                           ciaa.ciatahi,
                           ciaa.ciatalo);
   CloseLibrary(GfxBase);
}
