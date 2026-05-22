#ifndef VARS_H
#define VARS_H

/* <_us, _startup_time> should be a pretty good unique identifier of
   this process */
extern struct Process *_us;
extern long _stack_size;
extern long _startup_time;
extern int use_amiga_flags;

#endif
