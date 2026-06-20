
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <crbinc/inc.h>
#include <crbinc/crbeqlib.h>
#include <crbinc/crbconv.h>
#include <crbinc/equtil.h>

/** <> Amy **/
#include <dos.h>
const char __stdiowin[]="CON:10/10/600/100/Calc";
const char __stdiov37[]="/CLOSE";
/** <> Amy **/

int main(int argc,char *argv[])
{
struct EqData *d;
char EQ[100],OutStr[100];
double result;
int i;
bool Ok;
int Precision = 6;
bool Debug = 0;

puts("---------------------------------------------");
puts("Calc v1.1 copyright (c) 1996 by Charles Bloom");
puts("---------------------------------------------");
puts(" Remember ^ is POW and ~ is XOR");

for(i=1;i<argc;i++)
  {
  if ( argv[i][0] == '-' || argv[i][0] == '/' )
    {
    char c = toupper(argv[i][1]);

    if ( c == 'D' ) Debug = 1;
    else if ( c == 'P' )
      Precision = atoi(argv[i]+2);
    }
  }

for(;;)
  {
  gets(EQ);

  while ( EQ[0] == '-' || EQ[0] == '/' )
    {
    char c = toupper(EQ[1]);

    if ( c == 'D' )
      {
      Debug ^= 1;
      if ( Debug ) puts("Debug On");
      else puts("Debug Off");
      }
    else if ( c == 'P' )
      {
      Precision = atoi(EQ+2);
      printf("Precision = %d\n",Precision);
      }
    gets(EQ);
    }

  i=0; Ok=0;
  for(i=0;EQ[i]&&i<1000;i++)
    { if ( EQ[i] > 32 ) Ok=1; }

  if ( !Ok )
    {
    puts("Done");
    exit(0);
    }

  if ( Debug )
    {
    d=MakeCRBEQ(EQ,OPTIMIZE|DEBUG);

    for(i=0;d->DebugMess[i];i++)
      puts(d->DebugMess[i]);
    }
  else
    {
    d=MakeCRBEQ(EQ,OPTIMIZE);
    }

  if ( d )
    {
    if (d->ParseError)
      {
      puts("Make Error!");
      puts(d->ErrorMess);
      }
    else
      {
      result=ValCRBEQ(d);
  
      if (d->ParseError) { puts("Val Error!"); puts(d->ErrorMess); }

      MakeResult(OutStr,result,Precision);
      puts(OutStr);
      }
  
    FreeCRBEQ(d);
    }
  else
    {
    puts("No EQ");
    }

  }

}
