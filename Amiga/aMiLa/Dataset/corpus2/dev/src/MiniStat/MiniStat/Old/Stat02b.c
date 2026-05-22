#define CLEAR 12
#include <stdio.h>

   int i,q,s,sr,max,min,disp,v[100],vr[99];
   float m,mr;

main(){

	printf("\tStat v.0.2b ©2000 by Encelo\n");

	printf("How many decimal values do you want to insert?(Max 100): ");
	scanf("%d",&q);
	for (i=1;i<=q;i++)
		{
		printf("\nValue No.%d:",i);
		scanf("%d",&v[i]);
		}

	printf("Ok, you have inserted all the %d values, now I'm calculating...\n",q);
	for (i=1;i<=q;i++)
		{
		s+=v[i];
		}
	m=(float)s/q;
	printf("This is the mean between the %d values: %f\n",q,m);

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
		if (v[i]-v[i+1]>=0)
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
		sr+=vr[i];
		}
	mr=(float)sr/q;
	printf("This is the mean between the %d rejectings: %f\n",q-1,mr);
}