/***************************************************
 *             COPPER.C
 * Read the current view's copper list and send it to
 * a named file. This will eventually disassemble(?)
 * it.
 *
 * BK and BN 17-May-88
 */
#include <stdio.h>
#include <graphics/gfxbase.h>
#include <graphics/view.h>

#ifdef qwerty
void DisCopper(Name,List)
char *Name;
UWORD *List;
{
   FILE *fp;
   USHORT *PC;
   USHORT IR1,IR2,Line,Tmp[2];
   fp=fopen(Name,"w");
   if(fp!=NULL){      
      PC=(USHORT *)List;
      fprintf(fp,"LOF == $%-8lx\n",(long)PC);
      for(Line=IR1=IR2=0;(IR1!=0xffff || IR2!=0xfffe) && Line<255;Line++){
         IR1=*PC++;
         IR2=*PC++;         
      	 fprintf(fp,"%-3d: $%-4x $%-4x        ",(int)Line,(int)IR1,(int)IR2);
         switch(((IR1&1)<<1)+(IR2&1)){
            case 0:
            case 1:
               fprintf(fp,"MOVE $%-4x,$%-2x\n",(int)IR1,(int)IR2);
            break;
            case 2:
               fprintf(fp,"WAIT ($%-2x,$%-2x) ($%-2x,$%-2x) ",
                       (int)((IR1>>1)&0x7f),
                       (int)((IR2>>1)&0x7f),
                       (int)((IR1>>8)&0xff),
                       (int)((IR2>>8)&0x7f));
               fprintf(fp,"%c\n",(char)((IR2&0x8000)?' ':'B'));
            break;
            case 3:
               fprintf(fp,"SKIP ($%-2x,$%-2x) ($%-2x,$%-2x) ",
                       (int)((IR1>>1)&0x7f),
                       (int)((IR2>>1)&0x7f),
                       (int)((IR1>>8)&0xff),
                       (int)((IR2>>8)&0x7f));
               fprintf(fp,"%c\n",(char)((IR2&0x8000)?' ':'B'));
            break;
         }
      }
      fclose(fp);
   }
}
          
          
void DumpCopper(Name,View)
char *Name;
struct View *View;
{
   FILE *fp;
   USHORT *PC;
   USHORT IR1,IR2,Line,Tmp[2];
   fp=fopen(Name,"w");
   if(fp!=NULL){      
      fprintf(fp,"/* Copper Dump v1.00 */\n");
      fprintf(fp,"UWORD MyCopper[]={\n");
      PC=(USHORT *)(ULONG)View->LOFCprList->start;
      for(Line=IR1=IR2=0;(IR1!=0xffff || IR2!=0xfffe) && Line<255;Line++){
         IR1=*PC++;
         IR2=*PC++;
         fprintf(fp,"   0x%-4x,0x%-4x, /*",(int)IR1,(int)IR2);
      	 fprintf(fp," $%-4x $%-4x  ",(int)IR1,(int)IR2);
	 fprintf(fp,"%3d ",Line);
         switch(((IR1&1)<<1)+(IR2&1)){
            case 0:
            case 1:
               fprintf(fp,"MOVE $%-4x,$%-2x",(int)IR1,(int)IR2);
            break;
            case 2:
               fprintf(fp,"WAIT ($%-2x,$%-2x) ($%-2x,$%-2x) ",
                       (int)((IR1>>1)&0x7f),
                       (int)((IR2>>1)&0x7f),
                       (int)((IR1>>8)&0xff),
                       (int)((IR2>>8)&0x7f));
               fprintf(fp,"%c",(char)((IR2&0x8000)?' ':'B'));
            break;
            case 3:
               fprintf(fp,"SKIP ($%-2x,$%-2x) ($%-2x,$%-2x) ",
                       (int)((IR1>>1)&0x7f),
                       (int)((IR2>>1)&0x7f),
                       (int)((IR1>>8)&0xff),
                       (int)((IR2>>8)&0x7f));
               fprintf(fp,"%c",(char)((IR2&0x8000)?' ':'B'));
            break;
         }
         fprintf(fp,"   */\n");
      }
      fprintf(fp,"};\n");
      fclose(fp);
   }
}
          
#endif
extern void *AllocMem();

#include <hardware/dmabits.h>
UWORD INT_Sprite[]={0,0};

void SYS_UseCopper(Copper)
ULONG Copper;
{
   custom.cop1lc=(ULONG)Copper;
   custom.dmacon=BITSET|DMAF_COPPER|DMAF_BLITTER|DMAF_MASTER;
}
