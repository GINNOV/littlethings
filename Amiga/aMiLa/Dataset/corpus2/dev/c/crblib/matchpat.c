/**

todo : <> : more work on RenameByPat

**/

#include <stdlib.h>
#include <string.h>
#include <crbinc/inc.h>
#include <crbinc/strutil.h>

/****

Pattern Spec :

A Pattern consists of alternating Tokens and Wilds

A Wild, '*' or '#?' matches any number of any character

All Tokens must be matched.

A Token consists of:

    raw characters
or  ranges of characters: [x-y] matches x,y,and all values between
or  lists of characters:  [a,b,c] matchs a or b or c

Tokens may be preceeded by a boolean-not '~'

Tokens may be OR-ed by listing options as (x|y|z)

Does not support #x functionality except for #?

--------------------

Reserved characters:

*

?
(
|
)
[
]
~

--------------------

occasionally deeply recursive

can makes heavy use of the stack when multiple * or (||) branches are
involved.

--------------------

****/

bool IsWild(char *Str)
{

if ( strchr(Str,'*') ||
     strchr(Str,'~') ||
     strchr(Str,'?') ||
   ( strchr(Str,'[') && strchr(Str,']') && ( strchr(Str,'-') || strchr(Str,',') ) ) ||
   ( strchr(Str,'(') && strchr(Str,'|') && strchr(Str,')') ) )
    return(1);

return(0);
}

bool MatchPattern(char *VsStr,char *PatStr)
{

while(1)
  {
  switch( *PatStr )
    {
    case '?': /* match any */
      PatStr++;
      if ( *VsStr == 0 ) return(0);
      VsStr++;
      break;
  
    case '[': /* match several */
      PatStr++;
      if ( PatStr[1] == '-' ) /* range */
        {
        if ( *VsStr < PatStr[0] || *VsStr > PatStr[2] )
          return(0);
        VsStr++;
        PatStr += 3;
        }
      else /* list */
        {
        while ( *PatStr++ != *VsStr )
          {
          if ( *PatStr == ']' ) return(0);
          PatStr++; /* pass , */
          }
        VsStr++;
        }
      while( *PatStr != ']' ) PatStr++;
      PatStr++;
      break;
    
    case '|': /* leftover from OR */
      while ( *PatStr != ')' ) PatStr++;
      PatStr++;
      break;
    
    case ')': /* leftover from OR */
      PatStr++;
      break;
  
    case '~': /* NOT */
      PatStr++;
      return( ! MatchPattern(VsStr,PatStr) );
  
    case '#':
      if ( PatStr[1] != '?' )
        {
        if ( *VsStr++ != '#' ) return(0);
        break;
        }
      PatStr++;
      /* fallthrough */

    case '*': /* WILD */
      PatStr++;
      if ( *PatStr == 0 ) return(1);

      while(*VsStr)
        {
        if ( MatchPattern(VsStr,PatStr) ) return(1);
        VsStr++;
        }
      return( MatchPattern(VsStr,PatStr) );
  
    case '(' : /* OR */
      do
        {
        PatStr++;
        if ( MatchPattern(VsStr,PatStr) ) return(1);
        while ( *PatStr != '|' && *PatStr != ')' ) PatStr++;
        } while( *PatStr != ')' );
      return(0);
      break;
  
    default: /* raw character */
      if ( *VsStr != *PatStr ) return(0);
      if ( *VsStr == 0 && *PatStr == 0 ) return(1);
      VsStr++; PatStr++;
      break;
    }
  }

return(0);
}

bool MatchPatternNoCase(char *VsStr,char *PatStr)
{
char * TempVsStr;
bool Ret;

if ( (TempVsStr = malloc(strlen(VsStr)+1)) )
  {
  strcpy(TempVsStr,VsStr);
  strupr(TempVsStr);
  strupr(PatStr);
  Ret = MatchPattern(TempVsStr,PatStr);
  free(TempVsStr);
  }
else
  Ret = MatchPattern(TempVsStr,PatStr);

return(Ret);
}


/**

given the first three, fill in the last

**/

bool RenameByPat(char *FmPat,char *FmStr,char *ToPat,char *ToStr)
{
char *GotPat;

if ( !IsWild(ToPat) )
  {
  strcpy(ToStr,ToPat);
  return(1);
  }

/* easy case : just one '*' or '#?' in FmPat */
GotPat = strchr(FmPat,'*');
if ( ! GotPat ) 
  {
  GotPat = strchr(FmPat,'#');
  if ( GotPat[1] != '?' ) GotPat = NULL;
  }

/** <> todo : easy :
  copy in FmPat and ToPat
  turn all #? to *
  count *s in each
  count other pat types
  if # of *s is same and 0 other pat types, do:

  while(*ToPat)
    {
    while(*ToPat != ' *' && *ToPat)
      *ToStr++ = *ToPat++;

    if ( *ToPat == '*' && *FmPat == '*' )
      {
      FmPat++;
      while ( ! MatchPat(FmPat,FmStr) )
        *ToStr++ = *FmStr++;
      }
    else
      {
      while(*FmPat && *FmPat!='*')
        { FmPat++; FmStr++; }
      }
    }

  so that *b* -> *c* works

  or *b*q -> *c*z
**/

if ( GotPat && !strchr(GotPat+1,'*') && !strchr(GotPat+2,'?') )
  {
  char *PatPartStart,*PatPartEnd;
  char *FmPatEnd,*GotPatEnd;

/* ( *.jpg,a.jpg,*.i,a.i) */
/* ( a*b , aqqb, *c, qqc) */

  if ( *GotPat == '#' ) GotPatEnd = GotPat+1;
  else GotPatEnd = GotPat;

  PatPartStart = FmStr;
  while(FmPat++<GotPat)
    PatPartStart++;

  FmPatEnd = FmPat + strlen(FmPat) - 1;
  PatPartEnd = FmStr + strlen(FmStr) - 1;
  while(FmPatEnd-- > GotPatEnd)
    PatPartEnd--;

  while( ! ( *ToPat == '*' || ( *ToPat == '#' && ToPat[1] == '?' ) ) )
    {
    *ToStr++ = *ToPat++;
    if ( ! *ToPat )
      { *ToStr++ = 0; return(1); }
    }

  if ( *ToPat == '#' ) ToPat++;
  ToPat++;

  while( PatPartStart <= PatPartEnd )
    *ToStr++ = *PatPartStart++;

  while( *ToPat )
    *ToStr++ = *ToPat++;

  *ToStr++ = 0;
  return(1);
  }

/** Hard stuff here, not supported right now **/
/* (~*.jpg, a.bmp, *.iff, a.iff) : difficult */

strcpy(ToStr,FmStr);

return(0);
}
