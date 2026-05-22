#ifndef PROCESS_H

#ifndef IOLIB_H
#include "iolib.h"
#endif

#ifdef ANSIC

long wb_exec(char *filename, char *procname, char *toolname,
	     char *toolwindow, BPTR curdir, struct MsgPort *rport,
	     long stk, long pri, Child *child);
long	wbexec(char *name, long stk, long pri);
Child *wbAexec(char *name, long stk, long pri);
long wait_child(Child *wt);
long wait_children(void);
long signal_child(Child *child,unsigned long sig);
long kill(Child *child);
long kill_children(void);
long cliexec(char *cmd);
long exec(char *cmd);

#else

long wb_exec();
long wbexec();
Child *wbAexec();
long wait_child();
long wait_children();
long signal_child();
long kill();
long kill_children();
long cliexec();
long exec();

#endif

#endif


