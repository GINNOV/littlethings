#include <stdio.h>
#define long long long
#define WriteLong(a) printf(" %lld", (long) (a) )
#define WriteLine() printf("\n" )
#define ReadLong(a) if (fscanf(stdin, "%lld", &(a)) != 1) (a) = 0;


const long g_snNum = 1165536;
const long g_spNum = -1165536;
long g_a[20];
long g_b, g_e;
long g_rand, g_ret;
struct g_q_{
  long a_a[2];
  struct w{
    long a;
    long b;
  }b_b;
}g_q,g_w;
struct a{
  long a[2];
  long b;
  long c;
}g_c,g_d;
struct pp{
  struct q{
    long a;
    long b;
    long c;
    long d;
    long e;
    long f;
    long g;
    long h;
  }pp[4096];
}g_p;
long g_m1[2048][2048];
long g_m2[2048][2048];
long g_m3[2048][2048];
long g_z;
void params(long aa,long ba,long ca,long da,long ea,
	long fa,long ga,long ha,long ia,long ja,
	long ka,long la,long ma,long na,long oa,
	long pa,long qa,long ra,long sa,long ta,
	long ua,long va,long wa,long xa,long ya,
	long za,long ab,long bb,long cb,long db,
	long eb,long fb,long gb,long hb,long ib,
	long jb,long kb,long lb,long mb,long nb,
	long ob,long pb,long qb,long rb,long sb,
	long tb,long ub,long vb,long wb,long xb,
	long yb,long zb)
{
  long sum;
  long part;
  long rem;
  sum =0;
  sum = sum + aa+3;
  sum = sum + ba-4;
  sum = sum + ca*5;
  sum = sum + da/6;
  sum = sum + ea%7;
  sum = sum + fa+8;
  sum = sum + ga-9;
  sum = sum + ha;
  sum = sum + ia;
  sum = sum + ja;
  sum = sum + ka;
  sum = sum + la;
  sum = sum + ma;
  sum = sum + na;
  sum = sum + oa;
  sum = sum * pa;
  sum = sum + qa;
  sum = sum - ra;
  sum = sum + sa;
  sum = sum + ta;
  sum = sum / ua;
  sum = sum + va;
  sum = sum + wa;
  sum = sum * xa;
  sum = sum + ya;
  sum = sum * za;
  sum = sum + ab;
  sum = sum + bb;
  sum = sum - cb;
  sum = sum + db;
  sum = sum + eb;
  sum = sum * fb;
  sum = sum + gb;
  sum = sum + hb;
  sum = sum + ib;
  sum = sum + jb;
  sum = sum * kb;
  sum = sum + lb;
  sum = sum + mb;
  sum = sum + nb;
  sum = sum + ob;
  sum = sum + pb;
  sum = sum + qb;
  sum = sum + rb;
  sum = sum + sb;
  sum = sum + tb;
  sum = sum + ub;
  sum = sum + vb;
  sum = sum + wb;
  sum = sum * xb;
  sum = sum + yb;
  sum = sum + zb;
  part = sum / 52;
  rem = sum % 52;
  WriteLong( part );
  WriteLine();
  rem =rem * 100 / 52;
  WriteLong(rem);
  WriteLine();
  WriteLong(g_e);
  WriteLine();
  WriteLine();
  if(g_e<10){
    g_e = g_e+1;
    params(ca, da, ea,
           fa, ga, ha, ia, ja,
           ka, la, ma, na, oa,
           pa, qa, ra, sa, ta,
           ua, va, wa, xa, ya,
           za, ab, bb, cb, db,
           eb, fb, gb, hb, ib,
           jb, kb, lb, mb, nb,
           ob, pb, qb, rb, sb,
           tb, ub, vb, wb, xb,
           yb, zb, aa *2, ba % 3);
  }

}
void messy(long q, long w, long e, long r,
	   long t, long y, long u,long i)
{
  WriteLong(q);
  WriteLong(w);
  WriteLong(e);
  WriteLong(r);
  WriteLong(t);
  WriteLong(y);
  WriteLong(u);
  WriteLong(i);
  WriteLine();

}
void interesting()
{
  long a[20];
  long b, i;
  i=0;
  g_b = g_b + 1;
  if(1==1){
    ReadLong(b);
    WriteLong(0);
    WriteLong(g_z);
    g_z=g_z+1;
    WriteLong(b);
    WriteLine();
    WriteLine();
    i=0;
    while(i<20){
      a[i]=i*i;
      i=i+1;
    }
    while(i<40){
      if (b+i < 20) {
        WriteLong(a[b+i]);
      }
      i = i+1;
    }
  }
}
void rand()
{
  long temp;
  temp = (11699 * g_rand+11743)%2551;
  g_rand=temp;
  g_ret=temp+1;
}
void initialize()
{
  struct qq{
    long a;
    long b;
    long c;
    long d;
    long e;
    long f;
    long g;
    long h;
  }l_qq;
  long i;
  ReadLong(l_qq.a);
  ReadLong(l_qq.b);
  ReadLong(l_qq.c);
  ReadLong(l_qq.d);
  ReadLong(l_qq.e);
  ReadLong(l_qq.f);
  ReadLong(l_qq.g);
  ReadLong(l_qq.h);
  WriteLong(l_qq.a);
  WriteLong(l_qq.b);
  WriteLong(l_qq.c);
  WriteLong(l_qq.d);
  WriteLong(l_qq.e);
  WriteLong(l_qq.f);
  WriteLong(l_qq.g);
  WriteLong(l_qq.h);
  i=0;
  while(i<2048){
    i=i+1;
    g_p.pp[i].a=l_qq.a;
    g_p.pp[i].b=l_qq.b;
    g_p.pp[i].c=l_qq.c;
    g_p.pp[i].d=l_qq.d;
    g_p.pp[i].e=l_qq.e;
    g_p.pp[i].f=l_qq.f;
    g_p.pp[i].g=l_qq.g;
    g_p.pp[i].h=l_qq.h;
  }
}
void munge(long iter)
{
  long a[1];
  long num[3];
  long i, j,k;
  if(iter>0){
    rand();
    num[0]=g_ret;
    rand();
    num[1]=g_ret;
    rand();
    num[2]=g_ret;
    i=0;
    j=0;
    k=0;
    while(j<1024){
      while (i<4096){
        g_p.pp[i].a=g_p.pp[i].a*num[(j+i)%3]+g_p.pp[i].a*num[(j+i+1)%3]+g_p.pp[i].a*num[(j+i+2)%3];
        g_p.pp[i].b=g_p.pp[i].b*num[(j+i+1)%3]+g_p.pp[i].b*num[(j+i+2)%3]+g_p.pp[i].b*num[(j+i)%3];
        g_p.pp[i].c=g_p.pp[i].c*num[(j+i+2)%3]+g_p.pp[i].c*num[(j+i)%3]+g_p.pp[i].c*num[(j+i+1)%3];
        g_p.pp[i].d=g_p.pp[i].d*num[(j+i)%3]+g_p.pp[i].d*num[(j+i+1)%3]+g_p.pp[i].d*num[(j+i+2)%3];
        g_p.pp[i].e=g_p.pp[i].e*num[(j+i+1)%3]+g_p.pp[i].e*num[(j+i+2)%3]+g_p.pp[i].e*num[(j+i)%3];
        g_p.pp[i].f=g_p.pp[i].f*num[(j+i+2)%3]+g_p.pp[i].f*num[(j+i)%3]+g_p.pp[i].f*num[(j+i+1)%3];
        g_p.pp[i].g=g_p.pp[i].g*num[(j+i)%3]+g_p.pp[i].g*num[(j+i+1)%3]+g_p.pp[i].g*num[(j+i+2)%3];
        g_p.pp[i].h=g_p.pp[i].h*num[(j+i+1)%3]+g_p.pp[i].h*num[(j+i+2)%3]+g_p.pp[i].h*num[(j+i)%3];
        i=i+1;
      }
      k=0;
      while(k<2048){
        g_m1[k][2*j]=g_m1[k][2*j]+g_p.pp[k].a;
        g_m1[k][1+2*j]=g_m1[k][1+2*j]+g_p.pp[k].b;
        g_m1[k][2*j]=g_m1[k][2*j]+g_p.pp[k].c;
        g_m1[k][1+2*j]=g_m1[k][1+2*j]+g_p.pp[k].d;
        k=k+1;
      }
      k = k - 1;
      while(k>=0){
        g_m1[k][2*j]=g_m1[k][2*j]+g_p.pp[k].e;
        g_m1[k][1+2*j]=g_m1[k][1+2*j]+g_p.pp[k].f;
        g_m1[k][2*j]=g_m1[k][2*j]+g_p.pp[k].g;
        g_m1[k][1+2*j]=g_m1[k][1+2*j]+g_p.pp[k].h;
        k=k-1;
      }
      j=j+1;
    }
    i=0;
    j=0;
    k=0;
    while(i<2048){
      while(j<2048){
        while(k<2048){
          g_m3[k][i]=(1+g_m2[i][j])*(1+g_m1[k][j]);
          k=k+1;
        }
        j=j+1;
      }
      i=i+1;
    }
    i=0;
    j=0;
    k=0;
    while(i<2048){
      while(j<2048){
        g_m3[i][j]=g_m3[i][j]+g_m2[i][j]-g_m1[i][j];
        j=j+1;
      }
      i=i+1;
    }
    i=0;
    j=0;
    k=0;
    while(i<2048){
      while(j<2048){
        k=k+g_m3[j][i];
        j=j+1;
      }
      i=i+1;
    }
    WriteLong(k);
    WriteLine();
  }
  if(iter>=0){
    munge(iter-1);
  }
}
void main()
{
	long a[52];
	long q,w,e,r,t,y,u,i,o,p;
	const long s = 2265536;
	const long d = -2265536;
	g_z=0;
	g_b=0;
	i=0;
        WriteLong(0);
	WriteLong(111111);
	WriteLine();
	while(i<52){
		ReadLong(a[i]);
                WriteLong(0);
		WriteLong(0);
		WriteLong(0);
		WriteLong(0);
		WriteLong(g_z);
		g_z=g_z+1;
		i=i+1;
	}
	params(a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],
		a[10],a[11],a[12],a[13],a[14],a[15],a[16],a[17],a[18],a[19],
		a[20],a[21],a[22],a[23],a[24],a[25],a[26],a[27],a[28],a[29],
		a[30],a[31],a[32],a[33],a[34],a[35],a[36],a[37],a[38],a[39],
		a[40],a[41],a[42],a[43],a[44],a[45],a[46],a[47],a[48],a[49],
		a[50],a[51]);
        WriteLine();
        WriteLong(0);
        WriteLong(01);
        WriteLine();
	ReadLong(q);
	g_z=g_z+1;
	ReadLong(w);
	g_z=g_z+1;
	ReadLong(e);
	g_z=g_z+1;
	ReadLong(r);
	g_z=g_z+1;
	ReadLong(t);
	g_z=g_z+1;
	ReadLong(y);
	g_z=g_z+1;
	ReadLong(u);
	g_z=g_z+1;
	ReadLong(i);
	g_z=g_z+1;
	ReadLong(o);
	g_z=g_z+1;
	ReadLong(p);
	g_z=g_z+1;
        WriteLong(0);
        WriteLong(g_z);
	messy(q%w*e/r-t,y,u/i,o%p, g_snNum, g_spNum, s, d);
	messy(s*d*g_snNum/g_spNum,
//	      r%t/(s+1)+1*34524325234-d,
	      r%t/(s+1)+1*3452432523-d,	      
	      0,
	      o%o%o+1*p*3%1+s,
	      d-d-d-d-d-d-d-d-d-d-d-d-d-d,
	      s+s+s*s,
	      p+p+p+p*p,
	      q);
	i=0;
	while(i<65){
	  WriteLine();
	  WriteLong(i);
	  WriteLine();
	  interesting();
	  i = i+1;
	}
	WriteLine();
	WriteLong(0);
	WriteLine();
        initialize();
        ReadLong(g_rand);
	munge(9);
}
