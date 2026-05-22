#include <crbinc/inc.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

void strtolower(register char *str);
char * strichr(char *str,short c);
char * stristr(char *bigstr,char *substr);
char * strnchr(char *str,short c,int len);
void strins(char *to,char *fm);
char * strupr(char *str);
char * strrev(char *str);

char * strichr(char *str,short c)
{
register short oc;

if (isupper(c)) oc = tolower(c);
else oc = toupper(c);

while ( *str )
  {
  if ( *str == c || *str == oc) return(str);
  str++;
  }

return(NULL);
}

char * strnchr(char *str,short c,int len)
{
register char *donestr;

donestr=(char *)((int)str + len);

while (str < donestr)
  {
  if (*str == c) return(str);
  str++;
  }

return(NULL);
}

char * stristr(char *StrBase,char *SubBase)
{

while ( *StrBase )
  {
  if ( toupper(*StrBase) == toupper(*SubBase) )
    {
    register char * Str,* Sub;
    Str = StrBase + 1;
    Sub = SubBase + 1;
    while ( *Sub && toupper(*Sub) == toupper(*Str) )
      {
      Sub++; Str++;
      }
    if ( ! *Sub) return(StrBase);
    } 
  StrBase++;
  }

return(NULL);
}

void strtolower(register char *str)
{
while(*str)
  {
  *str = tolower(*str);
  str++;
  }
}

void strins(char *to,char *fm)
{
int tolen = strlen(to);
int fmlen = strlen(fm);
char *newto,*oldto;

newto = to+fmlen+tolen; oldto = to+tolen;
tolen++;
while(tolen--) *newto-- = *oldto--;

while(fmlen--) *to++ = *fm++;

}

char *strupr(register char *str)
{
char *strbase =str;
while(*str)
  {
  *str = toupper(*str);
  str++;
  }
return(strbase);
}

char * strrev(register char *str)
{
register char *endstr,swapper;
char *strbase =str;

endstr = str;
while(*endstr) endstr++;
endstr--;

while ( endstr > str )
  {
  swapper = *str;
  *str++ = *endstr;
  *endstr-- = swapper;
  }

return(strbase);
}
