#include <stdio.h>
#include <dos.h>

#define FACTOR 5

#define CALL(func,x) for(i=0; i<((x)*FACTOR); i++) (func)();

#define DELAY for(i=0; i<100*FACTOR; i++)

void Long_Name(void)
{
}

void This_Is_A_Really_Really_REALLY_Long_Name(void)
{
}

static void f100static(void)
{
   int i;
   DELAY;
}

void f100(void)
{
   //int i;
   //DELAY;
}

void f100b(void)
{
   int i;
   DELAY;
}

void f100c(void)
{
   int i;
   DELAY;
}

void f200(void)
{
   int i;
   DELAY;
}

void f300(void)
{
   int i;
   DELAY;
}

void f3x100(void)
{
   int i;
   CALL(f100b,100);
}

void f100x3(void)
{
   f100c();
   f100c();
   f100c();
}

void one(void){}
void two(void){}
void three(void){}
void four(void){}
void five(void){}
void six(void){}
void seven(void){}
void eight(void){}
void nine(void){}
void ten(void){}

#if !SMALLTEST
int main(int argc, char *argv[])
{
   int i;
   //for(i=0; i<argc; i++) printf("%s\n", argv[i]);
   //printf("Hit a character, then RETURN: ");
   //scanf("\n", &i);
   one(); 
   two(); 
   three();
   four();
   five();
   six();
   seven();
   eight();
   nine();
   ten();
   Long_Name();
   This_Is_A_Really_Really_REALLY_Long_Name();
   chkabort();
   CALL(f100static, 100);
   CALL(f100,100);
   CALL(f200,200);
   CALL(f300,300);
   CALL(f3x100,3);
   CALL(f100x3,100);
   return(0);
}

#else
int main(int argc, char *argv[])
{
   //int i;
   //for(i=0; i<argc; i++) printf("%s\n", argv[i]);
   one(); 
   two(); 
   three();
   four();
   five();
   six();
   seven();
   eight();
   nine();
   ten();
   f100();
   f200();
   f300();
   return 0;
}
#endif
