/* Type definitions */
#ifndef defsmat
#include <matrix.h>
#endif

#ifndef defs3d
#define defs3d 1
#define pi (355.0/113.0)

typedef struct
{
int points;
int lines;
double *pdat;
int  *ldat;
} object,*objectptr;

/* function prototypes */
int tran3(matrixptr m,double tx,double ty,double tz);
int scale3(matrixptr m,double sx,double sy,double sz);
int rot3(matrixptr m,double theta,int axis);
int genrot(double px,double py,double pz,double qx,double qy,double qz,\
           double gamma,matrixptr m);
double angle(double ax,double ay);
void p3mult(double *,matrixptr);
int objcop(objectptr s,objectptr d);
int init3d(void);
void objtran(objectptr o,matrixptr m);
void objprin(objectptr o);
void objdraw(struct RastPort *rp,objectptr o);
#endif
