#ifndef FLMEMFUNC_H
#define FLMEMFUNC_H

struct FL_memfunc       *FL_Memfunc(char *);
struct FL_memfunc       *FL_Clone_Memfunc(struct FL_memfunc *);
struct FL_memfunc       *FL_Clone_Memfuncs(struct FL_memfunc *, int);
struct FL_memfunc       *FL_Get_Memfunc(struct FL_system *, char *);
int                      FL_Add_Memfunc(struct FL_system *, char *);
int                      FL_Add_Memfuncs(struct FL_system *, ...);
struct FL_memfunc       *FL_Get_Memfunc(struct FL_system *, char *);
void                     FL_Write_Memfunc(FILE *, struct FL_memfunc *, int);
int                      FL_Read_Memfunc(FILE *, struct FL_memfunc *);
void                     FL_Kill_Memfunc(struct FL_memfunc *);

#endif
