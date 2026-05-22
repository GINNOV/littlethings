#include <stdio.h>
#include <stdlib.h>

int main(int argc,char *argv[])
{
int LastC,CurC;
FILE *InF,*OutF;
int InCommentNum;
int InCppCommentFlag;

puts("CppToC v1.1");
puts("Turns Cpp comments into C comments for the brain-dead GCC to handle.");
puts("Also removes nested comments.");

if ( argc != 3 )
  {
  puts("USAGE: CppToC <infile> <outfile>");
  exit(0);
  }

if ( ( InF = fopen(argv[1],"rb") ) == NULL )
  {
  puts("Failed to open infile!");
  exit(10);
  }

if ( ( OutF = fopen(argv[2],"wb") ) == NULL )
  {
  puts("Failed to open outfile!");
  fclose(InF);
  exit(10);
  }

InCommentNum = 0;
InCppCommentFlag = 0;
LastC = 0;
while ( ( CurC = fgetc(InF) ) != EOF )
  {
  if ( InCppCommentFlag )
    {
    if ( CurC == '\n' )
      {
      fputc('*',OutF);
      fputc('/',OutF);
      fputc('\n',OutF);
      InCppCommentFlag = 0;
      }
    else
      {
      fputc(CurC,OutF);
      }
    }
  else if ( InCommentNum > 0 )
    {
    if ( LastC == '/' && CurC == '/' )
      {
      fputc(' ',OutF);
      }
    else if ( LastC == '/' && CurC == '*' )
      {
      InCommentNum ++;
      fputc(' ',OutF);
      }
    else if ( LastC == '*' && CurC == '/' )
      {
      InCommentNum --;
      if ( InCommentNum != 0 ) fputc(' ',OutF);
      }
    fputc(CurC,OutF);
    }
  else
    {
    if ( LastC == '/' && CurC == '*' )
      {
      InCommentNum ++;
      fputc('*',OutF);
      }
    else if ( LastC == '/' && CurC == '/' )
      {
      InCppCommentFlag = 1;
      fputc('*',OutF);
      }
    else
      {
      fputc(CurC,OutF);
      }
    }
  LastC = CurC;
  }

fclose(InF);
fflush(OutF);
fclose(OutF);
}
