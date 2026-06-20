#include <stdio.h>
#include <signal.h>
#include <unistd.h>

int main(void)
{
   int i;
   const sigset_t trapped = sigmask(SIGINT);
   puts("The following is unbreakable");
   sleep(1);
   sigprocmask(SIG_BLOCK, &trapped, NULL);
   for (i = 0; i < 100; ++i) printf("1 %d\n", i);
   puts("The following may be broken out of");
   puts("(will break immediately if you hit ^C previously)");
   sleep(1);
   sigprocmask(SIG_UNBLOCK, &trapped, NULL);
   for (i = 0; i < 100; ++i) printf("2 %d\n", i);
   puts("Hey! You never hit ^C!  What kind of test is this?");
   return(0);
}
