/* authored by Bill Rogers of New Zealand */

#include <stdio.h>

int c,endfin;
FILE *fin;

int grabchar()
{
  int t;
  t=c; endfin = ((c=getc(fin))==EOF); return t;
}

int grabword()
{
  return ( grabchar()<<8 ) | grabchar();
}

int grabthree()
{
  return ( grabchar()<<16 ) | grabword();
}

int grablong()
{
  return ( grabword()<<16 ) | grabword();
}

dumpdata(n)
int n;
{
  int done=-1;
  while ((n--)>0) {
    if ( ++done % 4 ==0 ) printf("\n%4x: ",done);
    printf(" %08x",grablong());
    };
  printf("\n");
}

paddedstring(n)
int n;
{
  char ch;
  for (n=n<<2; n>0; n--)
    if ((ch=grabchar())!=0) printf("%c",ch);
}

int codesize, codeaddress;

nextcodeword()
{
  codeaddress +=2;
  return (--codesize)>=0 ? grabword() : 0;
}

dumpcode(n)
int n;
{
  codesize=n*2; codeaddress=0;
  while (codesize>0) decode(codeaddress);
}

dumpreloc(b)
int b;
{
  int n;
  printf("\nHunk_Reloc%d\n",b);
  while ((n=grablong())!=0) {
    printf("For hunk number %d",grablong());
    dumpdata(n);
    }
}

dumpsymboldata()
{
  int t,l;
  while (1) {
    t=grabchar();
    l=grabthree();
    if (t==0 & l==0) break;
    switch (t) {
      case 0:   printf("ext_symb");   break;
      case 1:   printf("ext_def");    break;
      case 2:   printf("ext_abs");    break;
      case 3:   printf("ext_res");    break;
      case 129: printf("ext_ref32");  break;
      case 130: printf("ext_common"); break;
      case 131: printf("ext_ref16");  break;
      case 132: printf("ext_ref8");   break;
      };
    printf(" '");
    paddedstring(l);
    printf("'");
    switch (t) {
      case 0: case 1: case 2: case 3:
        printf(" = %08x\n", grablong()); break;
      case 129: case 131: case 132:
        dumpdata(grablong()); break;
      case 130:
        printf(", size = %d", grablong());
        dumpdata(grablong()); break;
      }
    }
}

dumpitem()
{
  int l,f;
  switch (l=grablong()) {
    case 999:
      printf("\nHunk_Unit: '");
      paddedstring(grablong());
      printf("'\n");
      break;
    case 1000:
      printf("\nHunk_Name: '");
      paddedstring(grablong());
      printf("'\n");
      break;
    case 1001:
      printf("\nHunk_Code\n");
      dumpcode(grablong());
      break;
    case 1002:
      printf("\nHunk_Data");
      dumpdata(grablong());
      break;
    case 1003:
      printf("\nHunk_bss - size = %d\n",grablong());
      break;
    case 1004:
      dumpreloc(32);
      break;
    case 1005:
      dumpreloc(16);
      break;
    case 1006:
      dumpreloc(8);
      break;
    case 1007:
      printf("\nHunk_Ext\n");
      dumpsymboldata();
      break;
    case 1008:
      printf("\nHunk_Symbol\n");
      dumpsymboldata();
      break;
    case 1009:
      printf("\nHunk_Debug\n");
      dumpdata(grablong());
      break;
    case 1010:
      printf("\nHunk_End\n");
      break;
    case 1011:
      printf("\nHunk_Header\n");
      while ((l=grablong())!=0) {
        printf("Library: ");
        paddedstring(l);
        printf("\n");
        };
      printf("Table size = %d, using %d to %d\n",
                      grablong(),(f=grablong()),(l=grablong()));
      for (;f<=l;f++)
        printf("     Size = %08x\n",grablong());
      break;
    case 1013:
      printf("\nHunk_Overlay\n     Not Yet Implemented\n");
      endfin=1; break;
    case 1014:
      printf("\nHunk_Break\n"); break;
    case 1012:
    default:
      printf("Not a recognisable structure\n");
      endfin=1;
    }
}

main(argc,argv)
int argc;
char *argv[];
{
  if ( ( fin = fopen( argv[1] , "r" ) ) == NULL )
    printf("Couldn't open file >>%s<<\n",argv[1]);
  else {
    grabchar();
    while (endfin==0) dumpitem();
    }
}
