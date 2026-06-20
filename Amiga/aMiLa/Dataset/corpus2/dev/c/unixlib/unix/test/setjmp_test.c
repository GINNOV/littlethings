#include <stdio.h>
#include <setjmp.h>
#include <signal.h>
#include <alloca.h>

jmp_buf x;

void brk(int);
void breakme(void);

main()
{
   int r;
   signal(SIGINT, brk);

   r = setjmp(x); // returns 0 when called by main
   puts("\nArnie sez:  I'll be back...");

   if (r == 0)
      for (;;)
	breakme();

   printf("Broke and jumped, r = %d\n", r);
   return(0);
}
/* even though the brk call is supposed to return,
** we can longjmp out of it as well.
*/
void brk(int sig)
{
   longjmp(x, 23);
}
void breakme(void)
{
   alloca(1000000);
   puts("Break Me With ^C!");
}
