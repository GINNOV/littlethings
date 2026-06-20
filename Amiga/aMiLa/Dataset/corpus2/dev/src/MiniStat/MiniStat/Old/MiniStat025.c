#define CLEAR 12
#include <stdio.h>
#include <math.h>

   int i,q,a,ar,arm,asqrm,max,min,disp,v[100],vr[99];
   float m,mr,mrm,msqrm,vrm[100],vsqrm[100];

main(){

	printf("\tMiniStat v.0.2.5 ©2000 by Encelo\n");

	printf("\nHow many decimal values do you want to insert?(Max 100): ");
	scanf("%d",&q);
	for (i=1;i<=q;i++)
		{
		printf("Value No.%d:",i);
		scanf("%d",&v[i]);
		}

	printf("\nOk, you have inserted all the %d values, now I'm calculating...\n\n",q);
	for (i=1;i<=q;i++)
		{
		a+=v[i];
		}
	m=(float)s/q;
	printf("The mean between the %d values is: %f\n",q,m);

	max=0;
	for (i=1;i<=q;i++)
		{
		if (v[i]>max)
			{
				max=v[i];
			}
		}
	min=max;
	for (i=1;i<=q;i++)
		{
		if (v[i]<min)
			{
				min=v[i];
			}
		}
	disp=max-min;
	printf("Maximum value: %d\n",max);
	printf("Minimum value: %d\n",min);
	printf("The values dispersion is: %d\n",disp);

	for (i=1;i<=q-1;i++)
		{
		if (v[i]-v[i+1]>0)
			{
			vr[i]=v[i]-v[i+1];
			}
		else
			{
			vr[i]=v[i+1]-v[i];
			}
		}
	for (i=1;i<=q-1;i++)
		{
		ar+=vr[i];
		}
	mr=(float)sr/(q-1);
	printf("The mean between the %d rejectings between the values is: %f\n",q-1,mr);

	for (i=1;i<=q;i++)
		{
		if (v[i]-m>0)
			{
			vrm[i]=(float)v[i]-m;
			}
		else
			{
			vrm[i]=(float)m-v[i];
			}
		}
	for (i=1;i<=q;i++)
		{
		arm+=vrm[i];
		}
	mrm=(float)srm/q;
	printf("The mean between the %d rejectings from the global mean is: %f\n",q,mrm);

	for (i=1;i<=q;i++)
		{
		vsqrm[i]=vrm[i]*vrm[i];
		}
	for (i=1;i<=q;i++)
		{
		asqrm+=vsqrm[i];
		}
	msqrm=(float)ssqrm/q;
	printf("The variant is: %f\n",msqrm);

	printf("The standard deviation is: %f\n",sqrt(msqrm));
}