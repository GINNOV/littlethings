#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


long ascii[128][25];
long message[20];
long mul_result;


void kill_time() {
   long a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z;
   long A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z;
   long abase,bbase;
   
   a=0;
   while(a<18) {
   b=0;
   while(b<17) {
   abase=b;
   c=0;
   while(c<9) {
   d=0;
   bbase=d;
   while(d<2) {
   e=0;
   A=e;
   while(e<2) {
   f=0;
   B=f;
   while(f<5) {
   g=0;
   if (f<7) {
      C=a;
   }
   else {
      C=17;
   }	  
   D=g;
   E=A+B;
   while(g<7) {
   h=0;
   E=e;
   while(h<4) {
   i=0;
   F=f;
   G=g;
   H=h;
   I=i;
   while(i<5) {
   j=0;
   J=abase+f+G+g;
   while(j<12) {
   k=0;
   K=14+n;
   while(k<5) {
   l=0;
   L=a+c+d;
   while(l<7) {
   m=0;
   M=65*93+g;
   while(m<4) {
   n=0;
   N=42;
   while(n<17) {
   o=0;
   O=abase+i+a+14;
   while(o<4) {
   p=0;
   P=17;
   Q=P+11;
   while(p<3) {
   q=0;
   R=a+b+c+d;
   while(q<3) {
   r=0;
   S=R;
   while(r<5) {
   s=0;
   while(s<4) {
   T=A*a+Q*q%2;
   t=0;
   while(t<12) {
   u=0;
   U=Q+Q+Q;
   while(u<12) {
   v=0;
   V=i+n+c+e;
   while(v<5) {
   w=0;
   W=e+a+v+e+r;
   while(w<10) {
   x=0;
   X=a+b+c+d+e+f+g+h+i+j+k+l+m+n+o+p;
   while(x<3) {
   Y=q*r*s*t*u*v*w*x;
   y=0;
   while(y<12) {
   z=0;
   while(z<5) {
   N=O+P+Q+R+S+T+U+V+W+X+Y+Z;
   Z=A+B+C+D+E*F+G+H+I+J+K+L+M+N;
      
    z=z+1;
   }
      y=y+1;
   }
      x=x+1;
   }
      w=w+2;
   }
      v=v+4;
   }
      u=u+6;
   }
     t=t+2;
     Q=Q+t;
   }
      s=s+2;
   }
      r=r+6;
   }
      q=q+45;
   }
      p=p+3;
   }
      o=o+6;
   }
      n=n+2;
   }
      m=m+1;
   }
      l=l+7;
   }
      k=k+3;
   }
      j=j+10;
   }
      i=i+8;
   }
      h=h+7;
   }
      g=g+4;
   }
      f=f+33;
   }
      e=e+4;
   }
      d=d+22;
   }
      c=c+3;
   }
      b=b+7;
   }
      a=a+3;
   }

   WriteLong(V);
   WriteLong(W);
   WriteLong(X);
   WriteLong(Y);
   WriteLine();
}

   

void init_alphabet() {

     /* A */
   ascii[65][0]=3;
   ascii[65][1]=101;
   ascii[65][2]=3;
   ascii[65][3]=101;
   ascii[65][4]=101;
     /* B */
   ascii[66][0]=9902;
   ascii[66][1]=101;
   ascii[66][2]=9902;
   ascii[66][3]=101;
   ascii[66][4]=9902;
     /* C */
   ascii[67][0]=2;
   ascii[67][1]=9901;
   ascii[67][2]=9901;
   ascii[67][3]=9901;
   ascii[67][4]=2;
     /* D */
   ascii[68][0]=9902;
   ascii[68][1]=101;
   ascii[68][2]=101;
   ascii[68][3]=101;
   ascii[68][4]=9902;
     /* E */
   ascii[69][0]=2;
   ascii[69][1]=9901;
   ascii[69][2]=2;
   ascii[69][3]=9901;
   ascii[69][4]=2;
     /* F */
   ascii[70][0]=2;
   ascii[70][1]=9901;
   ascii[70][2]=2;
   ascii[70][3]=9901;
   ascii[70][4]=9901;
     /* G */
   ascii[71][0]=3;
   ascii[71][1]=9902;
   ascii[71][2]=101;
   ascii[71][3]=101;
   ascii[71][4]=3;
     /* H */
   ascii[72][0]= 101;
   ascii[72][1]= 101;
   ascii[72][2]= 3;
   ascii[72][3]= 101;
   ascii[72][4]= 101;
     /* I */
   ascii[73][0]=1;
   ascii[73][1]=1;
   ascii[73][2]=1;
   ascii[73][3]=1;
   ascii[73][4]=1;
     /* J */
   ascii[74][0]=199;
   ascii[74][1]=199;
   ascii[74][2]=199;
   ascii[74][3]=199;
   ascii[74][4]=2;
     /* K */
   ascii[75][0]=101;
   ascii[75][1]=101;
   ascii[75][2]=9902;
   ascii[75][3]=101;
   ascii[75][4]=101;
     /* L */
   ascii[76][0]=9901;
   ascii[76][1]=9901;
   ascii[76][2]=9901;
   ascii[76][3]=9901;
   ascii[76][4]=2;
     /* M */
   ascii[77][0]=5;
   ascii[77][1]=10101;
   ascii[77][2]=10101;
   ascii[77][3]=10101;
   ascii[77][4]=10101;
     /* N */
   ascii[78][0]=103;
   ascii[78][1]=10101;
   ascii[78][2]=10101;
   ascii[78][3]=10101;
   ascii[78][4]=301;
     /* O */
   ascii[79][0]=3;
   ascii[79][1]=101;
   ascii[79][2]=101;
   ascii[79][3]=101;
   ascii[79][4]=3;
     /* P */
   ascii[80][0]= 2;
   ascii[80][1]= 2;
   ascii[80][2]= 2;
   ascii[80][3]= 9901;
   ascii[80][4]= 9901;
     /* Q */
   ascii[81][0]= 4;
   ascii[81][1]= 19901;
   ascii[81][2]= 19901;
   ascii[81][3]= 201;
   ascii[81][4]= 4;
     /* R */
   ascii[82][0]= 4;
   ascii[82][1]= 19901;
   ascii[82][2]= 4;
   ascii[82][3]= 990101;
   ascii[82][4]=  19901;
     /* S */
   ascii[83][0]= 2;
   ascii[83][1]= 9901;
   ascii[83][2]= 2;
   ascii[83][3]= 199;
   ascii[83][4]= 2;
     /* T */
   ascii[84][0]= 3;
   ascii[84][1]= 990199;
   ascii[84][2]= 990199;
   ascii[84][3]= 990199;
   ascii[84][4]= 990199;
     /* U */
   ascii[85][0]= 101;
   ascii[85][1]= 101;
   ascii[85][2]= 101;
   ascii[85][3]= 101;
   ascii[85][4]= 3;
     /* V */
   ascii[86][0]= 101;
   ascii[86][1]= 101;
   ascii[86][2]= 101;
   ascii[86][3]= 101;
   ascii[86][4]= 9902;
     /* W */
   ascii[87][0]= 10101;
   ascii[87][1]= 10101;
   ascii[87][2]= 10101;
   ascii[87][3]= 10101;
   ascii[87][4]= 5;
     /* X */
   ascii[88][0]= 101;
   ascii[88][1]= 101;
   ascii[88][2]= 990199;
   ascii[88][3]= 101;
   ascii[88][4]= 101;
     /* Y */
   ascii[89][0]= 101;
   ascii[89][1]= 101;
   ascii[89][2]= 3;
   ascii[89][3]= 990199;
   ascii[89][4]= 990199;
     /* Z */
   ascii[90][0]= 2;
   ascii[90][1]= 199;
   ascii[90][2]= 2;
   ascii[90][3]= 9901;
   ascii[90][4]= 2;

     /* 0 */
   ascii[48][0]= 3;
   ascii[48][1]= 101;
   ascii[48][2]= 101;
   ascii[48][3]= 101;
   ascii[48][4]= 3;
     /* 1 */
   ascii[49][0]= 1;
   ascii[49][1]= 1;
   ascii[49][2]= 1;
   ascii[49][3]= 1;
   ascii[49][4]= 1;
     /* 2 */
   ascii[50][0]= 2;
   ascii[50][1]= 199;
   ascii[50][2]= 2;
   ascii[50][3]= 9901;
   ascii[50][4]= 2;
     /* 3 */
   ascii[51][0]= 2;
   ascii[51][1]= 199;
   ascii[51][2]= 2;
   ascii[51][3]= 199;
   ascii[51][4]= 2;
     /* 4 */
   ascii[52][0]= 2;
   ascii[52][1]= 2;
   ascii[52][2]= 2;
   ascii[52][3]= 199;
   ascii[52][4]= 199;
     /* 5 */
   ascii[53][0]= 2;
   ascii[53][1]= 9901;
   ascii[53][2]= 2;
   ascii[53][3]= 199;
   ascii[53][4]= 2;
     /* 6 */
   ascii[54][0]= 2;
   ascii[54][1]= 9901;
   ascii[54][2]= 2;
   ascii[54][3]= 2;
   ascii[54][4]= 2;
     /* 7 */
   ascii[55][0]= 2;
   ascii[55][1]= 199;
   ascii[55][2]= 199;
   ascii[55][3]= 199;
   ascii[55][4]= 199;
     /* 8 */
   ascii[56][0]= 3;
   ascii[56][1]= 101;
   ascii[56][2]= 3;
   ascii[56][3]= 101;
   ascii[56][4]= 3;
     /* 9 */
   ascii[57][0]= 2;
   ascii[57][1]= 2;
   ascii[57][2]= 2;
   ascii[57][3]= 199;
   ascii[57][4]= 2;

     /* ! */
   ascii[33][0]= 1;
   ascii[33][1]= 1;
   ascii[33][2]= 1;
   ascii[33][3]= 99;
   ascii[33][4]= 1;
     
     /* . */
   ascii[46][0]= 99;
   ascii[46][1]= 99;
   ascii[46][2]= 99;
   ascii[46][3]= 99;
   ascii[46][4]= 1;

    /* , */
   ascii[44][0]= 99;
   ascii[44][1]= 99;
   ascii[44][2]= 99;
   ascii[44][3]= 1;
   ascii[44][4]= 1;

}



void printMessage() {

   long count,line,temp_long,multiplier,output;

   line=0;   
   output=0;
   multiplier=1;

   while(line<5) {
   
      count=0;
      while(message[count]!=0) {
      
         temp_long=ascii[message[count]][line];

         while(temp_long!=0) {
              
            if (temp_long%100==1) {
               output=8;
            }
            if (temp_long%100==2) {
               output=88;
            }
            if (temp_long%100==3) {
               output=888;
            }
            if (temp_long%100==4) {
               output=8888;
            }
            if (temp_long%100==5) {
               output=88888;
            }
            if (temp_long%100==99) {
               multiplier=-1;
            }
            else {
               output=output*multiplier;
               WriteLong(output);
               multiplier=1;
            }

            temp_long=temp_long/100;

         }

         count=count+1;
      }
      line=line+1;
      WriteLine();
      multiplier=1;
   }
   WriteLine();
}



void fixed_point_mul(long x, long y) {
 
   long a;
   
   a=x*y;

   a=a/100000;
   mul_result=a;
}

void main() {
 
   
   long x,x2;
   long pi,constant;
   long pi2,pi4,temp_result;
   long j;
   long y,digits,output;
 
   pi=314159;
   
   constant=232;
   
   fixed_point_mul(pi,pi);
   pi2=mul_result;
   
   fixed_point_mul(pi2,pi2);
   pi4=mul_result;
      
    y=0;
    while(y<8) {
     
       x=-314159;
       while(x<314159) {

          x2=x;
          fixed_point_mul(4*pi4,x2);

          temp_result=mul_result;
      
          fixed_point_mul(x2,x);
          fixed_point_mul(mul_result,x);
          x2=mul_result;
          fixed_point_mul(mul_result,5*pi2);
          temp_result=temp_result+(-mul_result);
      
          fixed_point_mul(x2,x);
          fixed_point_mul(mul_result,x);
      
          temp_result=temp_result+mul_result;
      
          fixed_point_mul(temp_result,constant);
      

          digits=(mul_result+100000)/20000;
      
	  if (digits>10) {
	     digits=10;
	  }
	  
          output=1;
          j=digits;
          while(j>0) {
	     output=output*10;
	     j=j-1;
	  }
	  
          if (output!=1) {
	     output=output+1;
	  }
	  WriteLong(output);
      
          j=10-digits;
          output=1;
          while(j>0) {
	     output=output*10;
	     j=j-1;
	  }
	  
          if (output!=1) {
	     output=output+1;
	  }
	  
          WriteLong(output);

	  WriteLine();
          x=x+10000;
       }
       y=y+1;
   }
   
   
   init_alphabet();

   WriteLine();

  message[0]=83;
  message[1]=73;
  message[2]=78;
  message[3]=69;
  message[4]=0;

  printMessage();

  message[0]=66;
  message[1]=89;
  message[2]=0;

  printMessage();
  message[0]=86;
  message[1]=73;
  message[2]=78;
  message[3]=67;
  message[4]=69;
  message[5]=0;

  printMessage();

  WriteLine();
  kill_time();
}
