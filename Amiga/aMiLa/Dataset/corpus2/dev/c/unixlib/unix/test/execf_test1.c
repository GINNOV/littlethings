/* Example program to test execf() */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <errno.h>

typedef unsigned char bool;

#define FALSE 0
#define TRUE  1

static char *program = "child_fun";

static char msgbuf[512];

void
LogFatal(char *x0, char *x1)
{
	extern char *sys_errlist[];
	static bool entered = FALSE;

	if (entered)
		return;
	entered = TRUE;

	fprintf(stderr, "%s: ", program);
	if (errno)
		fprintf(stderr, "%s: ", sys_errlist[ errno ]);
	fprintf(stderr, x0,x1);
	fprintf(stderr, "  Stop.\n");
	exit(20);
}

void
LogFatalI(char *s, int i)
{
	/*NOSTRICT*/
	LogFatal(s, (char *)i);
}


int process1(void *data)
{
   FILE *out;
   char buff[256];
   int ret;
   
   out = fopen("CON:10/120/520/80/New Process 1", "r+");
   if (out == NULL)
      return -1;

   fprintf(out, "I got \"%s\"\n", data);
   fprintf(out, "Hit Return to Close Window\n");
   fflush(out);

   if (!fgets(buff, sizeof(buff), out)) {
      strcpy(msgbuf, "fgets() failed!");
      fclose(out);
      return -1;
   }

   fclose(out);

   if (strcmp(buff, "\n") == 0) {
      strcpy(msgbuf, "I'm returning 0 to you");
      ret = 0;
   } else {
      buff[strlen(buff)-1] = 0;
      sprintf(msgbuf, "You doesn't simply hit return, but wrote: \"%s\"\n", buff);
      strcat(msgbuf, "so I'm returning the number of characters you wrote");
      ret = strlen(buff);
   }

   return ret;
}


main(int argc, char **argv)
{
   int pid;
   int status;
   int rc;
   char *msg;
   
   if (argc >= 2)
       msg = argv[1];
   else
       msg = "Hello out there!";
   /* Start process 1 */
   printf("Starting process 1\n");
   pid = execf(process1, msg, -1, -1, NULL, -1);
   if (pid < 0)
       LogFatal("Cannot exec %s.", program);
   /* Simply wait child completion */
   printf("Waiting for process1 to finish\n");
   rc =  wait(&status);
   printf("Return from child is %d\n", WEXITSTATUS(status));
   printf("Message from child is:\n%s\n", msgbuf);
   if (rc > 0) {
      if (WIFSIGNALED(status))
      	LogFatalI("Signal %d.", WTERMSIG(status));
      if (WIFEXITED(status) && WEXITSTATUS(status))
      	LogFatalI("Exit code %d.", WEXITSTATUS(status));
   }
   

   return(0);
}
