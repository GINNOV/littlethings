
#include <math.h>
#include <GAP.h>
#define NSeeds 32
#define MaxLev 4
static int I24 = 24,J24 = 10,NSkip;static double Seeds[NSeeds],f9F=0.0,TwoM32,TwoM16;
static double RCarry(int);static void InitRanLux(const long int,const int);static double *RanLux(int);
void InitRand(const long int);unsigned long int Rnd(const long int);double InRand(const double,const double);
double GaussRand(const double,const double);double PoissonRand(const double);
int TossRand(const double);static unsigned long int Rand_Seed=660919+751030;void InitRand(const long int seed)
{Rand_Seed = seed;InitRanLux(seed,1);}unsigned long int Rnd(const long int Max)
{return((unsigned long int)(Rand_Seed=(Rand_Seed*0x41a7)%0x7ffffffe)%Max);}double InRand(const double o6S,const double To)
{double t1L=To-o6S;return(o6S + t1L * ((double)Rnd(0x7ffffffe)/(double)0x7ffffffd));
}double GaussRand(const double my,const double sigma){static int c2Yd=0;double r0,r1,p0;
static double p1;if(c2Yd==1) {c2Yd=0;return(p1*sigma+my);}r0 = *(RanLux(1));
 r1 = *(RanLux(1)); r0 = sqrt(-2*log(r0));r1 = 2*3.14159265*r1;p0 = r0*sin(r1);
p1 = r0*cos(r1);c2Yd=1;return(p0*sigma+my);}double PoissonRand(const double My)
{double lim,pi,poisson;lim = exp(-My);poisson = 0;pi = *(RanLux(1));while(pi>=lim) {
pi *= *(RanLux(1));poisson++;}return(poisson);}int TossRand(const double P) 
{if((*(RanLux(1)))<=P) {return(1);}return(0);}static void InitRanLux(const long int seed,const int Quality)
{unsigned long int ISeeds[NSeeds];const long int NDSkip[]={ 0, 24, 73, 199, 365};
unsigned long int JSeed = seed;long int i,K;NSkip = NDSkip[(Quality<=MaxLev && Quality>=0)?Quality:3];
for(i=0;i<NSeeds;i++) {K = JSeed / 53668;JSeed = 40014 * (JSeed - K * 53668) - K * 12211;
ISeeds[i] = JSeed;}TwoM32 = pow(2.0,-32.0);TwoM16 = pow(2.0,-16.0);for(i=0;
i!=NSeeds;i++) {Seeds[i] = (double)ISeeds[i] * TwoM32;}I24 = NSeeds - 1;J24 = 10;
f9F = (Seeds[NSeeds-1]==0.0)?TwoM32:0.0;}static double *RanLux(int j3L){static double RVec[25];
static long int In24=0;int i;for(i=0;i<j3L;i++) {RVec[i] = RCarry(1);In24++;
if (In24 == (NSeeds-1)) {In24=0;RCarry(NSkip);}}for(i=0;i!=j3L;i++) {if(RVec[i]<TwoM16) {
RVec[i] = RVec[i] + TwoM32 * Seeds[J24];}}for(i=0;i!=j3L;i++) {if(RVec[i]==0.0) {
RVec[i] = TwoM32 * TwoM32;}}return(RVec);}static double RCarry(int N){const int Next[]={31,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30};
double Uni=0.0;int i;for(i=0;i<N;i++) {Uni = Seeds[J24]-Seeds[I24]-f9F;if (Uni < 0.0) {
Uni += 1.0;f9F = TwoM32;} else {f9F = 0.0;}Seeds[I24] = Uni;I24 = Next[I24];
J24 = Next[J24];}return(Uni);}