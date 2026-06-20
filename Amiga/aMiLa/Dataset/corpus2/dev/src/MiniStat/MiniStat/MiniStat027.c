/*Very simple statistical program by Angelo Theodorou ©2000*/

#define CLEAR 12              /*0x12 cleans the screen on many terminals*/
#include <stdio.h>
#include <math.h>             /*Included for the sqrt() function*/

/*I is the counter for the FOR cycle*/

/*Q is the number of the value inserted by the user*/

/*A represent always an adding, so A is the basic adding of the values, */
/*AR is the adding of the rejectings, ARM is the adding between the values of global mean minus the rejectings, */
/*while ASQRM is the adding between the squared rejectings*/

/*M represent always a mean, so M is the mean between the values, */
/*MR is the mean between the rejectings, MRM is the mean between the values of global mean minus the rejectings, */
/*while MSQRM is the mean between the squared rejectings*/

/*V represent always an array of Max 100 values, so V[100] are the values inserted by the user, */
/*VR[100] contains the rejectings, VRM[100] contains the values of global mean minus the rejectings, */
/*while VSQRM[100] are the squared rejectings*/

/*MAX and MIN are the maximum and minimum value inserted*/

   int i,q,a,ar,arm,asqrm,max,min,v[100],vr[99];
   float m,mr,mrm,msqrm,vrm[100],vsqrm[100];

void ReadData();
void	Mean();
void	MaxMin();
void	RejMean();
void	SimMedRej();
void	Deviation();


main(){

	printf("\t®MiniStat v 0.2.7 ©2000 by Encelo\n");

     ReadData();
	Mean();
	MaxMin();
	RejMean();
	SimMedRej();
	Deviation();
}

void ReadData(){		/*Reads the values to compute on*/
	printf("\nHow many decimal values do you want to insert?(Max 100, 0 to quit): ");
	scanf("%d",&q);
	if (q==0) {
		     printf("Quitting...\n"); /*If you insert 0 the program quits*/
		     exit(21);
		     };
	for (i=1;i<=q;i++)
		{
		printf("Value No.%d:",i);
		scanf("%d",&v[i]);
		}

	printf("\nOk, you have inserted all the %d values, now I'm calculating...\n\n",q);
}

void Mean(){		    /*Calculates the mean between the values*/
	for (i=1;i<=q;i++)
		{
		a+=v[i];
		}
	m=(float)a/q;
	printf("The mean between the %d values is: %f\n",q,m);
}

void MaxMin(){         /*Determines the Max and Min value*/
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
	printf("Maximum value: %d\n",max);
	printf("Minimum value: %d\n",min);
	printf("The values dispersion is: %d\n",max-min);
}

void RejMean(){        /*The mean between the rejectings*/
	for (i=1;i<=q-1;i++)
		{
		if (v[i]-v[i+1]>0)         /*This*/
			{                     /*is*/
			vr[i]=v[i]-v[i+1];    /*done*/
			}                     /*to*/
		else                       /*calculate*/
			{                     /*the*/
			vr[i]=v[i+1]-v[i];    /*absolute*/
			}                     /*value*/
		}
	for (i=1;i<=q-1;i++)
		{
		ar+=vr[i];
		}
	mr=(float)ar/(q-1);
	printf("The mean between the %d rejectings among the values is: %f\n",q-1,mr);
}

void SimMedRej(){   /*The mean among the values of global mean minus the rejectings*/
	for (i=1;i<=q;i++)
		{
		if (v[i]-m>0)              /*This*/
			{                     /*is*/
			vrm[i]=(float)v[i]-m; /*done*/
			}                     /*to*/
		else                       /*calculate*/
			{                     /*the*/
			vrm[i]=(float)m-v[i]; /*absolute*/
			}                     /*value*/
		}
	for (i=1;i<=q;i++)
		{
		arm+=vrm[i];
		}
	mrm=(float)arm/q;
	printf("The simple medium rejecting is: %f\n",mrm);
}

void Deviation(){      /*It's like the SimMedRej, but it operates on the squared values*/
	for (i=1;i<=q;i++)
		{
		vsqrm[i]=vrm[i]*vrm[i];
		}
	for (i=1;i<=q;i++)
		{
		asqrm+=vsqrm[i];
		}
	msqrm=(float)asqrm/q;
	printf("The variant is: %f\n",msqrm);
	printf("The standard deviation is: %f\n",sqrt(msqrm));
}
