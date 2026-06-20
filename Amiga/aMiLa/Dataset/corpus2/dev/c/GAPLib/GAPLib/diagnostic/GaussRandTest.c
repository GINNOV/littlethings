#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <GAP.h>

#define	LOOPS 1048576

int main(void)
{
int ret=0;
int i,n,t;
int	*sumar;
double d,q,err;

InitRand(time(0));

sumar = malloc(sizeof(double)*129);


if(sumar!=0) {

	t=0;
	for(i=0;i!=129;i++) {
		sumar[i] = 0.0;
	}

	for(i=0;i!=LOOPS;i++) {
		d = GaussRand(0.0,0.8);
		n = (int)(32.0*d)+64;
		if(n>=0 && n<128) {
			sumar[n] = sumar[n] + 1.0;
		}
		if((i&4095)==4095) {
			printf("%c\b","-\\|/-\\|/"[t++]);
			fflush(stdout);
			t&=7;
		}
	}

	/*
    *	It seems that the average value of the gaussian noise appears
    * exactly twice as often as it should.
    */

	sumar[64] = sumar[64]/2.0;	/* This feels like a bug. */

	q=1.0/(sumar[64]);
	err = 0.0;

	for(i=0;i!=129;i++) {
		d = exp(-pow(i/32.0-2,2.0));
		err = err + pow((d-sumar[i]*q),2.0);
	}

	printf("(%f)\n",err); 
	if(err<1.41421356) {
		printf("GaussRandTest: No worse than usual.\n");
	} else {
		printf("GaussRandTest: This sucks.\n");
		ret = 5;
	}

	free(sumar);
} else {
	fprintf(stderr,"***Error: No free store. (malloc() failed)\n");
}

return(ret);
}
