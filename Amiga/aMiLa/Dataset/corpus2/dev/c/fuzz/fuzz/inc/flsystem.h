#ifndef FLSYSTEM_H
#define FLSYSTEM_H

extern struct FL_system   *FL_System(char *);
extern struct FL_system   *FL_Clone_System(struct FL_system *);
extern int                 FL_System_Run(struct FL_system *);
extern int                 FL_System_XRun(struct FL_system *);
extern int                 FL_System_Reset(struct FL_system *);
extern int                 FL_Write_System(struct FL_system *, char *, int);
extern struct FL_system   *FL_Read_System(char *);
extern void                FL_Kill_System(struct FL_system *);

#endif
