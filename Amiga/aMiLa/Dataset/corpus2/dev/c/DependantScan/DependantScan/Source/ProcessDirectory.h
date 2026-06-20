#ifndef DEF_PROCESSDIRECTORY_H
#define DEF_PROCESSDIRECTORY_H

#define PD_PATHMAX 512														/* largest pathname we will deal with */

/* ProcessDirectory.c */
extern int process_directory(char *name, char *pattern, int (*filefunc)(struct AnchorPath *anchor, void *app_data), int (*dirfunc)(struct AnchorPath *anchor, void *app_data), void *app_data);
extern int process_directory_do_nothing(struct AnchorPath *anchor, void *app_data);
#endif
