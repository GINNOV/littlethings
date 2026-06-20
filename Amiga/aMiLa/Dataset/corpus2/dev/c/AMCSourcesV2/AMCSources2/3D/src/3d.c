/* 3d graphics functions - requires matrix.obj */
/* Written by Nigel Salt */
#include <3d.h>
#include <matrix.h>
#include <stdio.h>
#include <math.h>
//#include <graph.h>
#include <intuition/intuition.h>
#include <clib/intuition_protos.h>
#include <graphics/gfxmacros.h>
#include <clib/layers_protos.h>
#include <clib/graphics_protos.h>
     
/* global data declarations */
static double p3dat[4]={0.0,0.0,0.0,1.0};
static matrix p3vec={4,1,&p3dat[0]};
static matrixptr pp3vec=&p3vec;

static double p3dat2[4]={0.0,0.0,0.0,1.0};
static matrix p3vec2={4,1,&p3dat2[0]};
static matrixptr pp3vec2=&p3vec2;


static double d2[4][4];
static matrix mat2={4,4,&d2[0][0]};
static matrixptr m2=&mat2;

static double d3[4][4];
static matrix mat3={4,4,&d3[0][0]};
static matrixptr m3=&mat3;

/* function definitions */
int tran3(m,tx,ty,tz)
matrixptr m;
double tx,ty,tz;
{
  if (m->rows!=4||m->cols!=4)
    {
    fprintf(stderr,"\ntran3 error - matrix must be 4 x 4");
    return 1;
    }
  mid(m);
  *(m->block+0*4+3)=tx;
  *(m->block+1*4+3)=ty;
  *(m->block+2*4+3)=tz;
  return 0;
}

int scale3(m,sx,sy,sz)
matrixptr m;
double sx,sy,sz;
{
  if (m->rows!=4||m->cols!=4)
    {
    fprintf(stderr,"\nscale3 error - matrix must be 4 x 4");
    return 1;
    }
  mid(m);
  *(m->block+0*4+0)=sx;
  *(m->block+1*4+1)=sy;
  *(m->block+2*4+2)=sz;
}

int rot3(m,theta,axis)
matrixptr m;
double theta;
int axis;
{
  int a1,a2;
  double ct,st;
  if (m->rows!=4||m->cols!=4)
    {
    fprintf(stderr,"\nscale3 error - matrix must be 4 x 4");
    return 1;
    }
  mid(m);
  if (axis>3||axis<0)
    axis=3;
  *(m->block+3*4+4)=1;
  *(m->block+axis*4+axis)=1;
  a1=(axis+1)%3;
  a2=(a1+1)%3;
  ct=cos(theta);
  st=sin(theta);
  *(m->block+a1*4+a1)=ct;
  *(m->block+a2*4+a2)=ct;
  *(m->block+a1*4+a2)=-st;
  *(m->block+a2*4+a1)=st;
  return 0;
}

int genrot(px,py,pz,qx,qy,qz,gamma,m)
double px,py,pz;
double qx,qy,qz;
double gamma;
matrixptr m;
{
  double alpha,beta,theta;
  mid(m);
  if (tran3(m2,-px,-py,-pz))
    return 1;
  mmult(m2,m,m3);
  mcopy(m3,m);
  
  theta=angle(qx,qy);
  alpha=theta;
  rot3(m2,-theta,3);
  mmult(m2,m,m3);
  mcopy(m3,m);
  
  theta=angle(qz,sqrt(qx*qx+qy*qy));
  beta=theta;
  rot3(m2,-theta,3);
  mmult(m2,m,m3);
  mcopy(m3,m);
  
  rot3(m2,gamma,3);
  mmult(m2,m,m3);
  mcopy(m3,m);
  
  rot3(m2,beta,2);
  mmult(m2,m,m3);
  mcopy(m3,m);
  
  rot3(m2,alpha,3);
  mmult(m2,m,m3);
  mcopy(m3,m);
  
  tran3(m2,px,py,pz);
  mmult(m2,m,m3);
  mcopy(m3,m);

  return 0;
}

double angle(ax,ay)
double ax,ay;
{
  double theta;
  if (fabs(ax)>.00001)
    {
    theta=atan(ay/ax);
    if (ax<0.0)
      theta=theta+pi;
    }
  else
    {
    theta=pi/2;
    if (ay<0.0)
      theta=theta+pi;
    if (fabs(ay)<.00001)
      theta=0;
    }
  return theta;
}

void p3mult(p,m)
double *p;
matrixptr m;
{
  int i;
  for (i=0;i<3;i++)
    *(pp3vec->block+i)=*(p+i);
  mmult(m,pp3vec,pp3vec2);
  for (i=0;i<3;i++)
    *(p+i)=*(pp3vec2->block+i);
}

void objtran(o,m)
objectptr o;
matrixptr m;
{
  int i,j;
  for (i=0;i<o->points;i++)
    p3mult((o->pdat+3*i),m);
}

void objprin(o)
objectptr o;
{
  int i,j;
  printf("\nPOINTS");
  for (i=0;i<o->points;i++)
    printf("\n%10.2lf%10.2lf%10.2lf",*(o->pdat+i*3),*(o->pdat+i*3+1),\
           *(o->pdat+i*3+2));
  printf("\nLINES");
  for (i=0;i<o->lines;i++)
    printf("\n%10d%10d",*(o->ldat+i*2),*(o->ldat+i*2+1));
}


void objdraw(struct RastPort *rp,objectptr o)
{
  int i;
  int x,y,pnum;
  for (i=0;i<o->lines;i++)
    {
    pnum=*(o->ldat+i*2);
//    fprintf(stderr,"\npnum %d",pnum);
    x=(int)*(o->pdat+3*pnum);
    y=(int)*(o->pdat+3*pnum+1);
    Move(rp,x+100,y+100);
    pnum=*(o->ldat+i*2+1);
    x=(int)*(o->pdat+3*pnum);
    y=(int)*(o->pdat+3*pnum+1);
    Draw(rp,x+100,y+100);
    }
}

int objcop(s,d)
objectptr s,d;
{
  int i,j;
  if (s->points!=d->points||s->lines!=d->lines)
    {
    fprintf(stderr,"\nobjcop error - objects must be same size");
    return 1;
    }
  for (i=0;i<s->points;i++)
    for (j=0;j<3;j++)
      *(d->pdat+3*i+j)=*(s->pdat+3*i+j);
  for (i=0;i<s->lines;i++)
    for (j=0;j<2;j++)
      *(d->ldat+2*i+j)=*(s->ldat+2*i+j);
  return 0;
}

int init3d()
{
/*  if (!(_setvideomode(_VRES16COLOR)))
    {
    fprintf(stderr,"\ninit3d error - VGA 16 color 640x480 not available");
    return 1;
    }
  _setlogorg(320,240);
*/  return 0;
}

