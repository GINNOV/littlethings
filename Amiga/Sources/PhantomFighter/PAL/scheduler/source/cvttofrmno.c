/* Tester for make */

#include <math.h>
 
double MyAtan(dy,dx)
int dy,dx;
{
  double t,tdx,tdy;
  tdx=(double)dx;
  tdy=(double)dy;
  if(dx==0)
    {
    if(dy>=0)return 3.14159/2;
    return -3.14159/2;
    }
  if(tdy<0)tdy=-tdy;
  if(tdx<0)tdx=-tdx;
  t=atan(tdy/tdx);
  switch (2*(dy<0)+(dx<0))
    {
    case 0:
      return t;
    case 1:
      return (3.14159-t);
    case 2:
      return ((1.5707-t)-3.14159/2);
    case 3:
      return (t+3.14159);
    }
}

int CvtToFrmNo(dy,dx)
int dy,dx;
{
  int dir;
  dir=(int)(57.3*MyAtan(dy,dx));
  if(dir<0)dir+=360;
  return (7-(dir/45+5)&7);
}
