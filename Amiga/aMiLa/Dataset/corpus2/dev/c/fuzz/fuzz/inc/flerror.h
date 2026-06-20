#ifndef FLERROR_H
#define FLERROR_H

extern void  FL_Seterror(int);
extern void  FL_SeterrorText(char *);
extern int   FL_Geterror(void);
extern char *FL_GeterrorText(void);
extern char *FL_GeterrorName(void);

#endif
