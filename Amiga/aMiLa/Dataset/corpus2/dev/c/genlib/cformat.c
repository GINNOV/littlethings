
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include <crbinc/inc.h>
#include <crbinc/fileutil.h>

/*exit-freed globals*/
FILE * InFP = NULL;
FILE * OutFP = NULL;

char * Array1 = NULL;
char * Array2 = NULL;

void ExitFunc(void);
void CleanUp(char * ExitMess);

void main(int argc, char *argv[])
{
int InFileLen,A1Len,A2Len;
char *A1Ptr,*A2Ptr;
char *PtrDone;
int InComs,Indents,i,j;
bool GotC;

bool Indent_Spaces;
int IndentSize,Indent_Base=0;
bool CloseParenLastLine,NotInFunc,EOLLastLine;

fprintf(stderr,"CFormat v2.0 copyright (c) 1996 Charles Bloom\n");

if ( argc != 4 )
  {
  fprintf(stderr,"Usage: CFormat <infile> <outfile> <indentsize>");
  fprintf(stderr," use <indentsize> = 0 to indent a tab");
  fprintf(stderr," else indents <indentsize> spaces");
  exit(10);
  }

if ( atexit(ExitFunc) )
  CleanUp("Couldn't install exit trap!");

if ( (InFP = fopen(argv[1],"rb")) == NULL )
  CleanUp("Error opening input file");

if ( (OutFP = fopen(argv[2],"wb")) == NULL )
  CleanUp("Error creating output file");

IndentSize = atoi(argv[3]);
if ( IndentSize == 0 ) Indent_Spaces = TRUE;

fseek(InFP,0,SEEK_END);
InFileLen = ftell(InFP);
fseek(InFP,0,SEEK_SET);

if ( (Array1 = malloc(InFileLen*2)) == NULL )
  CleanUp("AllocMem failed!");

if ( (Array2 = malloc(InFileLen*2)) == NULL )
  CleanUp("AllocMem failed!");

FRead(InFP,Array1,InFileLen);
fclose(InFP); InFP = NULL;

/** pass 1 , do simple filter */

A1Len = InFileLen;
A1Ptr = Array1;
PtrDone = A1Ptr + A1Len;
A2Ptr = Array2;

InComs=0;
GotC=0;

while(A1Ptr<PtrDone)
  {
  if ( *A1Ptr == '\r' ) A1Ptr++;

  if ( A1Ptr[0] == '/' && A1Ptr[1] == '*' )
    {
    InComs++;
    *A2Ptr++ = *A1Ptr++;
    *A2Ptr++ = *A1Ptr++;
    }

  if ( A1Ptr[0] == '/' && A1Ptr[1] == '/' )
    {
    while(*A1Ptr != '\n') *A2Ptr++ = *A1Ptr++;
    *A2Ptr++ = *A1Ptr++;
    while( *A1Ptr == ' ' || *A1Ptr == '\t' || *A1Ptr == '\r' ) A1Ptr++;
    }

  if ( InComs )
    {
    if ( A1Ptr[0] == '*' && A1Ptr[1] == '/' )
      {
      InComs--;
      *A2Ptr++ = *A1Ptr++;
      *A2Ptr++ = *A1Ptr++;
      if ( InComs == 0 )
        {
        while( *A1Ptr == ' ' || *A1Ptr == '\t' || *A1Ptr == '\r' ) A1Ptr++;
        }
      }
    else
      {
      if ( *A1Ptr == '\r' ) A1Ptr++;
      else *A2Ptr++ = *A1Ptr++;
      }
    }
  else
    {
    switch( *A1Ptr )
      {
      case 'f':
        if ( !GotC && memcmp(A1Ptr,"for",3) == 0 )
          {
          *A2Ptr++ = *A1Ptr++;
          *A2Ptr++ = *A1Ptr++;
          *A2Ptr++ = *A1Ptr++;

          goto Case_Branch;
          }
        else
          {
          *A2Ptr++ = *A1Ptr++;
          }
        GotC = 1;
        break;

      case 'i':
        if ( !GotC && memcmp(A1Ptr,"if",2) == 0 )
          {
          *A2Ptr++ = *A1Ptr++;
          *A2Ptr++ = *A1Ptr++;

          goto Case_Branch;
          }
        else
          {
          *A2Ptr++ = *A1Ptr++;
          }
        GotC = 1;
        break;

      case 'w':
        if ( !GotC && memcmp(A1Ptr,"while",5) == 0 )
          {
          *A2Ptr++ = *A1Ptr++;
          *A2Ptr++ = *A1Ptr++;
          *A2Ptr++ = *A1Ptr++;
          *A2Ptr++ = *A1Ptr++;
          *A2Ptr++ = *A1Ptr++;

          /*** ****/
      
          Case_Branch: /* for, if, while */

          if ( ! isalnum(*A1Ptr) ) /* don't be fooled by 'whilegoing' */
            {
            int NumParens=0;
  
            while( *A1Ptr == ' ' || *A1Ptr == '\t' ||
              *A1Ptr == '\r' || *A1Ptr == '\n' ) A1Ptr++;
  
            if ( *A1Ptr == '(' ) { NumParens++; *A2Ptr++ = *A1Ptr++; }
            while(NumParens>0)
              {
              if ( *A1Ptr == '(' ) NumParens++;
              else if ( *A1Ptr == ')' ) NumParens--;
              *A2Ptr++ = *A1Ptr++;
              }
  
            while( *A1Ptr == ' ' || *A1Ptr == '\t' ||
              *A1Ptr == '\r' || *A1Ptr == '\n' ) A1Ptr++;
            }
          /*** ****/
          }
        else
          {
          *A2Ptr++ = *A1Ptr++;
          }
        GotC = 1;
        break;

      case 'd':
        if ( !GotC && memcmp(A1Ptr,"do",2) == 0 )
          {
          *A2Ptr++ = *A1Ptr++;
          *A2Ptr++ = *A1Ptr++;

          while( *A1Ptr == ' ' || *A1Ptr == '\t' ||
            *A1Ptr == '\r' || *A1Ptr == '\n' ) A1Ptr++;
          }
        else
          {
          *A2Ptr++ = *A1Ptr++;
          }
        GotC = 1;
        break;

      case '\n':
        A1Ptr++;
        while( *A1Ptr == ' ' || *A1Ptr == '\t' || *A1Ptr == '\r' ) A1Ptr++;
        if ( *A1Ptr == ')' )
          {
          *A2Ptr++ = ' ';
          *A2Ptr++ = *A1Ptr++;
          while( *A1Ptr == ' ' || *A1Ptr == '\t' || *A1Ptr == '\r' || *A1Ptr == '\n' ) A1Ptr++;
          }
        *A2Ptr++ = '\n'; GotC = 0;
        break;
      case '\t':
        A1Ptr++;
        break;
      case ' ':
        if ( A1Ptr[1] != ' ' && A1Ptr[1] != '\t' && A1Ptr[1] != ';' )
          *A2Ptr++ = *A1Ptr++;
        else
          A1Ptr++;
        break;
      case '{':
      case '}':
        if ( GotC )
          *A2Ptr++ = '\n';
        *A2Ptr++ = *A1Ptr++;

        while( *A1Ptr == ' ' || *A1Ptr == '\t' || *A1Ptr == '\r' ) A1Ptr++;
        if ( *A1Ptr == '\n' )
          {
          A1Ptr++;
          while( *A1Ptr == ' ' || *A1Ptr == '\t' || *A1Ptr == '\r' ) A1Ptr++;
          }
        if ( *A1Ptr == ';' ) *A2Ptr++ = *A1Ptr++;
        if ( memcmp(A1Ptr,"while",5) == 0 )
          {
          int i=5;
          *A2Ptr++ = ' ';
          while(i--) *A2Ptr++ = *A1Ptr++; 
          GotC=1;
          }
        else
          {
          *A2Ptr++ = '\n';
          GotC = 0;
          }
        break;
      case ';':
        *A2Ptr++ = *A1Ptr++;

        while( *A1Ptr == ' ' || *A1Ptr == '\t' || *A1Ptr == '\r' ) A1Ptr++;

        if ( A1Ptr[0] == '/' && A1Ptr[1] == '*' )
          {
          InComs++;
          *A2Ptr++ = *A1Ptr++;
          *A2Ptr++ = *A1Ptr++;

          while ( InComs )
            {
            if ( *A1Ptr == '\r' ) A1Ptr++;
            if ( A1Ptr[0] == '*' && A1Ptr[1] == '/' )
              {
              InComs--;
              *A2Ptr++ = *A1Ptr++;
              *A2Ptr++ = *A1Ptr++;
              }
            else if ( A1Ptr[0] == '/' && A1Ptr[1] == '*' )
              {
              InComs++;
              *A2Ptr++ = *A1Ptr++;
              *A2Ptr++ = *A1Ptr++;
              }
            else
              {
              *A2Ptr++ = *A1Ptr++;
              }
            }

          while( *A1Ptr == ' ' || *A1Ptr == '\t' || *A1Ptr == '\r' ) A1Ptr++;
          }
        if ( A1Ptr[0] == '/' && A1Ptr[1] == '/' )
          {
          while(*A1Ptr != '\n') *A2Ptr++ = *A1Ptr++;
          }

        if ( *A1Ptr == '\n' ) A1Ptr++;
        *A2Ptr++ = '\n';

        GotC = 0;
        while( *A1Ptr == ' ' || *A1Ptr == '\t' || *A1Ptr == '\r' ) A1Ptr++;
        break;

      default:
        GotC = 1;
        *A2Ptr++ = *A1Ptr++;
        break;
      }
    }
  }
*A2Ptr++ = '\n';

/****** PASS 2 : do indents ********/

A2Len = A2Ptr - Array2;
PtrDone = A2Ptr;
A2Ptr = Array2;

A1Ptr = Array1;

InComs=0;
Indents= Indent_Base;

NotInFunc = 1; CloseParenLastLine = 0; EOLLastLine=0;

while(A2Ptr<PtrDone)
  {

  /* process line by line */

  if ( CloseParenLastLine && !EOLLastLine )
    {
    if ( *A2Ptr == '\n' )
      A2Ptr++;
    }
  EOLLastLine = 0;

  /* do indents */

  if ( ! InComs )
    {
    if ( *A2Ptr == '{' )
      {
      EOLLastLine = 1;

      if ( Indents == 0 && (CloseParenLastLine && NotInFunc) )
        NotInFunc=0;
      else
        Indents++;
      }
  
    if ( *A2Ptr != '#' )
      {
      for(i=0;i<Indents;i++)
        {
        if ( Indent_Spaces )
          {
          for(j=0;j<IndentSize;j++)
            *A1Ptr++ = ' ';
          }
        else
          *A1Ptr++ = '\t';
        }
      }
    else /* # */
      {
      bool InMacro=1;
      bool MacroIndent=0;
      int CurCol;

      while(InMacro)
        {
        CurCol=0;

        if (MacroIndent)
          {
          if ( Indent_Spaces )
            {
            for(j=0;j<IndentSize;j++)
              *A1Ptr++ = ' ';
            CurCol += IndentSize;
            }
          else
            {
            *A1Ptr++ = '\t';
            CurCol += 4; /* ! */
            }
          }
  
        while( *A2Ptr != '\n' && !(A2Ptr[0] == '\\' && A2Ptr[1] == '\n') )
          { *A1Ptr++ = *A2Ptr++; CurCol++; }

        if ( *A2Ptr == '\\' )
          {
          while(CurCol<75) { *A1Ptr++ = ' '; }
          *A1Ptr++ = *A2Ptr++; /* \\*/
          MacroIndent=1;
          }
        else
          {
          InMacro=0;
          }
        *A1Ptr++ = *A2Ptr++; /* \n*/
        }
      }

    if ( *A2Ptr == '}' )
      {
      Indents--;
      if ( Indents == -1 )
        {
        NotInFunc = 1;
        Indents = 0;
        }
      }
    }

  CloseParenLastLine=0;

  while(*A2Ptr != '\n')
    {
    if ( A2Ptr[0] == '/' && A2Ptr[1] == '*' )
      {
      InComs++;
      *A1Ptr++ = *A2Ptr++;
      *A1Ptr++ = *A2Ptr++;
      }
    else if ( A2Ptr[0] == '*' && A2Ptr[1] == '/' )
      {
      InComs--;
      *A1Ptr++ = *A2Ptr++;
      *A1Ptr++ = *A2Ptr++;
      }
    else
      {
      if ( *A2Ptr == ')' )
        CloseParenLastLine=1;
      else if ( *A2Ptr == ';' )
        EOLLastLine = 1;
      *A1Ptr++ = *A2Ptr++;
      }
    }
  *A1Ptr++ = *A2Ptr++;
  }

A1Len = A1Ptr - Array1;

FWrite(OutFP,Array1,A1Len);

printf("Wrote output, %d bytes\n",A1Len);

CleanUp(NULL);
}

void CleanUp(char * ExitMess)
{
if ( ExitMess )
  {
  fprintf(stderr,"%s\n",ExitMess);
  exit(10);
  }
else
  {
  fprintf(stderr,"Standard Exit.\n");
  exit(0);
  }
}

void ExitFunc(void)
{
fprintf(stderr,"Performing custom exit handler.\n");

smartfree(Array1);
smartfree(Array2);
if ( InFP  ) fclose(InFP);
if ( OutFP ) fclose(OutFP);

}
