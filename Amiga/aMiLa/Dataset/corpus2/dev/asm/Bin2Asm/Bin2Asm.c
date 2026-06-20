/**************************************************************************/
/*                                                                        */
/*   Binary to Assembler sourse                               ver 1.0     */
/*                                                                        */
/*   By Obrezan Artem                                       17 june 1997  */
/*   (e-mail: artem@cdi.surbis.ru)                                        */
/*                                                                        */
/*                         This version are for AMiGA!                    */
/*                                                                        */
/**************************************************************************/

#include <stdio.h>
#include <string.h>

int endfile;
unsigned int t,c;
int line,counter,bwl;
FILE *infile,*outfile;

static char *mnemonics[3] = { "DC.B", "DC.W", "DC.L" };

unsigned char grabbyte()
{
  t=c;
  if (endfile) t=0;
  endfile = ((c=getc(infile))==EOF);
  return t;
}

unsigned int grabword()
{
  return ( grabbyte()<<8 | grabbyte() );
}

unsigned long grablong()
{
  return ( grabword()<<16 | grabword() );
}

int help()
{
 printf("Usage:\n");
 printf(" Bin2Asm <inputfile> <outputfile> [<b|w|l>] [<\%%d>] \n");
 printf("         b|w|l = byte|word|long \n");
 printf("         \%%d    = how much bytes|words|longs in line \n\n");
 printf("-> Artem Obrezan (e-mail: artem@cdi.surbis.ru)  17 june 1997 <-\n\n");

 exit();
 return 1; /* ;-) */
}

 
main(argc,argv)
int argc;
char *argv[];
{
  printf("\n*** Bin2Asm ***\n");

  if ((argc==2)&&(strcmp(argv[1],"/?")==0)) help();
  
  if (argc<3){
   printf("\n Usage: Bin2Asm <inputfile> <outputfile>");
   printf("\n Type /? for more info...\n\n");
   exit(1);
  }


  line=8; bwl=0; 

  if ( (infile = fopen(argv[1],"r")) == NULL) {
   printf("\n Couldn't open file for input.\n");
   exit(2);
  }
  if ( (outfile = fopen(argv[2],"w")) == NULL) {
   printf("\n Couldn't open file for output.\n");
   exit(3);
  }
 
  if ((argc=4)||(argc<5)){
   switch (*argv[3]){
    case 'b': 
    case 'B':
              bwl = 0;
 		    break;
    case 'w':
    case 'W':
              bwl = 1;
		    break;
    case 'l':
    case 'L':
		    bwl = 2;
		    break;
   }
  }
  if (argc<=5){
    sscanf(argv[4],"%d",&line);
    if(line<=0)line=1;
  }
  line--;  

  fprintf (outfile,"; %s \n\n",argv[1]);

  grabbyte();

  endfile = 0;
  counter = 0;

  /* =================================================================== */

  while (!endfile){
  
   if (counter == 0) {
    fprintf(outfile,"         %s ",mnemonics[bwl]);
   }
   switch(bwl){
    case 0: fprintf(outfile,"$%02x",grabbyte());
		  break;
    case 1: fprintf(outfile,"$%04x",grabword());
		  break;
    case 2: fprintf(outfile,"$%08x",grablong());
		  break;
   }
   if ( (++counter > line)||(endfile) ) 
    {
     counter =0;
     fprintf(outfile," \n");
    }
   else 
     fprintf(outfile,", "); 
  }

 /* ==================================================================== */

  printf("Done.\n");
  exit();
}










