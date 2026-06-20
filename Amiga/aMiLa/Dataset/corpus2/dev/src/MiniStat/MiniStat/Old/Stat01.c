#define CLEAR 12
#include <stdio.h>

   int i,q,s,max,min,disp,v[100];
   float m;

main(){

	printf("\tStat v.0.1 ©2000 by Encelo\n");
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
}