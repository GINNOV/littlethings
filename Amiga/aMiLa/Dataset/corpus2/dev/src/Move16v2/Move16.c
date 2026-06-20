#include <proto/exec.h>
#include <exec/execbase.h>
#include <exec/memory.h>
#include <proto/dos.h>
#include <stdio.h>
#include <stdlib.h>
#define MEMSIZE (1024000L)

void __regargs MoveMem(ULONG *,ULONG *,ULONG);
void __regargs MoveMem16(ULONG *,ULONG *,ULONG);
void main(void);
 struct   tt {
      long  days;
      long  minutes;
      long  ticks;
   }  tt,tt2;


void main()
{
 unsigned long cpu68040;
 register unsigned int i;
 ULONG *src1,*src2;
 ULONG *org1,*org2,*tptr1,*tptr2;
 ULONG tlong;
 double q,q2;
 double q3,q4;
 struct ExecBase **execbaseptr=(struct ExecBase **)4;
 struct ExecBase *execbase;

 execbase = *execbaseptr;
 cpu68040 = execbase->AttnFlags;
 if (cpu68040 & AFF_68040)
  cpu68040 = 0xffL;
 else
  cpu68040 = 0L;
 if (!cpu68040)
  {
   printf("You need a 68040 system\n");
   exit(0);
  }
 execbase = *execbaseptr;
 cpu68040 = execbase->AttnFlags;
 if (cpu68040 & AFF_FPU40)
  cpu68040 = 0xffL;
 else
  cpu68040 = 0L;
 if (!cpu68040)
  {
   printf("You need a 68040 system With a Math Chip Builtin\n");
   exit(0);
  }
 if (!(org1 = src1 = (ULONG *)AllocMem(MEMSIZE+16,MEMF_FAST)))
  {
   printf("No FAST mem\n");
   exit(0);
  }
 tlong = (ULONG)src1;
 tlong &= 0xfffffff0L;
 tlong += 0x10L;
 src1 = (ULONG *)tlong;
 if (!(org2 = src2 = (ULONG *)AllocMem(MEMSIZE+16,MEMF_FAST)))
  {
   FreeMem(org1,MEMSIZE+16);
   printf("No Fast mem\n");
   exit(0);
  }
 tlong = (ULONG)src2;
 tlong &= 0xfffffff0L;
 tlong += 0x10L;
 src2 = (ULONG *)tlong;

 Forbid();

 DateStamp((struct DateStamp *)&tt);
 for(i=0;i<10;i++)
  MoveMem(src1,src2,(MEMSIZE/16));
 DateStamp((struct DateStamp *)&tt2);
 q = ( (double)(tt.ticks + (tt.minutes * 60L * 50L)))/50.0;
 q2 = ( (double)(tt2.ticks + (tt2.minutes * 60L * 50L)))/50.0;
 q = q2 - q;

 DateStamp((struct DateStamp *)&tt);
 for(i=0;i<10;i++)
  MoveMem16(src1,src2,(MEMSIZE/16));
 DateStamp((struct DateStamp *)&tt2);
 q3 = ( (double)(tt.ticks + (tt.minutes * 60L * 50L)))/50.0;
 q4 = ( (double)(tt2.ticks + (tt2.minutes * 60L * 50L)))/50.0;
 q3 = q4 - q3;

 Permit();
 FreeMem((char *)org1,MEMSIZE+16);
 FreeMem((char *)org2,MEMSIZE+16);
 printf("**FAST TO FAST**\n");
 printf("MoveMem   = %3.4lf secs\n",q);
 printf("MoveMem16 = %3.4lf secs\n",q3);


 if (!(org1 = src1 = (ULONG *)AllocMem(MEMSIZE+16,MEMF_FAST)))
  {
   printf("No FAST mem\n");
   exit(0);
  }
 tlong = (ULONG)src1;
 tlong &= 0xfffffff0L;
 tlong += 0x10L;
 src1 = (ULONG *)tlong;
 if (!(org2 = src2 = (ULONG *)AllocMem(MEMSIZE+16,MEMF_CHIP)))
  {
   FreeMem(org1,MEMSIZE+16);
   printf("No CHIP mem\n");
   exit(0);
  }
 tlong = (ULONG)src2;
 tlong &= 0xfffffff0L;
 tlong += 0x10L;
 src2 = (ULONG *)tlong;

 Forbid();

 DateStamp((struct DateStamp *)&tt);
 for(i=0;i<10;i++)
  MoveMem(src1,src2,(MEMSIZE/16));
 DateStamp((struct DateStamp *)&tt2);
 q = ( (double)(tt.ticks + (tt.minutes * 60L * 50L)))/50.0;
 q2 = ( (double)(tt2.ticks + (tt2.minutes * 60L * 50L)))/50.0;
 q = q2 - q;

 DateStamp((struct DateStamp *)&tt);
 for(i=0;i<10;i++)
  MoveMem16(src1,src2,(MEMSIZE/16));
 DateStamp((struct DateStamp *)&tt2);
 q3 = ( (double)(tt.ticks + (tt.minutes * 60L * 50L)))/50.0;
 q4 = ( (double)(tt2.ticks + (tt2.minutes * 60L * 50L)))/50.0;
 q3 = q4 - q3;

 Permit();
 printf("**Fast to CHIP**\n");
 printf("MoveMem   = %3.4lf secs\n",q);
 printf("MoveMem16 = %3.4lf secs\n",q3);


 Forbid();

 DateStamp((struct DateStamp *)&tt);
 for(i=0;i<10;i++)
  MoveMem(src2,src1,(MEMSIZE/16));
 DateStamp((struct DateStamp *)&tt2);
 q = ( (double)(tt.ticks + (tt.minutes * 60L * 50L)))/50.0;
 q2 = ( (double)(tt2.ticks + (tt2.minutes * 60L * 50L)))/50.0;
 q = q2 - q;

 DateStamp((struct DateStamp *)&tt);
 for(i=0;i<10;i++)
  MoveMem16(src2,src1,(MEMSIZE/16));
 DateStamp((struct DateStamp *)&tt2);
 q3 = ( (double)(tt.ticks + (tt.minutes * 60L * 50L)))/50.0;
 q4 = ( (double)(tt2.ticks + (tt2.minutes * 60L * 50L)))/50.0;
 q3 = q4 - q3;

 Permit();
 printf("**CHIP to Fast**\n");
 printf("MoveMem   = %3.4lf secs\n",q);
 printf("MoveMem16 = %3.4lf secs\n",q3);

 Forbid();

 tptr1 = src2;
 tlong = (ULONG)src2;
 tlong += (MEMSIZE/2);
 tptr2 = (ULONG *)tlong;
 DateStamp((struct DateStamp *)&tt);
 for(i=0;i<20;i++)
  MoveMem(tptr1,tptr2,(MEMSIZE/32));
 DateStamp((struct DateStamp *)&tt2);
 q = ( (double)(tt.ticks + (tt.minutes * 60L * 50L)))/50.0;
 q2 = ( (double)(tt2.ticks + (tt2.minutes * 60L * 50L)))/50.0;
 q = q2 - q;

 DateStamp((struct DateStamp *)&tt);
 for(i=0;i<20;i++)
  MoveMem16(tptr1,tptr2,(MEMSIZE/32));
 DateStamp((struct DateStamp *)&tt2);
 q3 = ( (double)(tt.ticks + (tt.minutes * 60L * 50L)))/50.0;
 q4 = ( (double)(tt2.ticks + (tt2.minutes * 60L * 50L)))/50.0;
 q3 = q4 - q3;

 Permit();
 printf("**CHIP to CHIP**\n");
 printf("MoveMem   = %3.4lf secs\n",q);
 printf("MoveMem16 = %3.4lf secs\n",q3);

 FreeMem((char *)org1,MEMSIZE+16);
 FreeMem((char *)org2,MEMSIZE+16);
}
