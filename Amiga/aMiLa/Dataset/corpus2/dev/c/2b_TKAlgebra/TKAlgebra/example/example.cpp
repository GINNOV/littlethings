#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include "macierz.h"
#include "uklad.h"

#ifdef AMIGA
#define clrscr(); printf("\f");
#else
#include <conio.h>
#endif



int Men1()
{  int i;
	clrscr();
	printf("\t1 - Metoda Gaussa\n");
	printf("\t2 - Ortogonalizacja Gramma Schmidta\n");
	printf("\t3 - Automatycznie\n");
	printf("\t4 - Odwracanie macierzy\n");
	printf("\t5 - Generuj nowa macierz\n");
	printf("\t6 - Wyjscie z programu\n\n");
	printf("\t\ttwoj wybor? ");
	scanf("%d",&i);
	return (i%6);
}
int Men2()
{  int i;
	clrscr();
	printf("\t1 - Metoda Gaussa\n");
	printf("\t2 - Ortogonalizacja Gramma Schmidta\n");
	printf("\t3 - Automatycznie\n");
	printf("\t4 - Generuj nowa macierz\n");
	printf("\t5 - Wyjscie z programu\n\n");
	printf("\t\ttwoj wybor? ");
	scanf("%d",&i);
	return (i+(i>3))%6;
}

int (*menu_glowne[2])()={Men1,Men2};


Macierz TworzM()
{  long int i,j;
	int r1,r2;
	do
	{  printf("Podaj ilo¶æ kolumn macierzy:");
		scanf("%d",&r1);
		printf("Podaj ilo¶æ wierszy macierzy:");
		scanf("%d",&r2);
	}
	while((r1<=0)||(r2<=0));
	i=time(NULL);
	srand(i);
	Macierz Ax(r2,r1);
	if(Ax.Bledy==BEZ_BLEDU)
	{  for(j=0;j<r2;j++)
		{  for(i=0;i<r1;i++)
				Ax[j][i]=((rand()%400));//-(rand()%800));//+(rand()/RAND_MAX));
		}
	}
	return Ax;
}

Wektor TworzW(Macierz &A)
{  long int i,j;
	i=time(NULL);
	double pom;
	srand(i);
	Wektor Bx(A.Ile_Wierszy);
	if(Bx.Bledy==BEZ_BLEDU)
	{  for(j=0;j<A.Ile_Wierszy;j++)
		{  pom=0;
			for(i=0;i<A.Ile_Kolumn;i++)
				pom+=A[j][i];
			Bx[j]=pom;//((rand()%4000));
		}
	}
	return Bx;
}

int main()
{  Macierz A,*C=new Macierz();
	Wektor B;
	Uklad *U=NULL;
	double WarPom;
	int war=5;
	do
	{  switch(war)
		{  case 1 : if(U)
							delete U;
						U=RozwiazanieUkladu(A,B,GAUSS_);
						break;
			case 2 : if(U)
							delete U;
						U=RozwiazanieUkladu(A,B,ORTOGONALIZACJAGS_);
						break;
			case 3 : if(U)
							delete U;
						U=RozwiazanieUkladu(A,B);
						break;
			case 4 : delete C;
						C=A.Odwrotna();
						break;
			case 5 : A=TworzM();
						if(A.Bledy==BEZ_BLEDU)
							B=TworzW(A);
						break;
			default: break;
		}
		if((war<4)&&U)
		{  if(U->Bledy==BEZ_BLEDU)
			{  printf("\nMaxymalny maxymalny b³±d rozwiazania ukladu %d równañ z %d niewiadomymi wynosi %g\n",A.Ile_Wierszy,A.Ile_Kolumn,U->ERR);
				printf("Sredni b³±d natomiast: %g \n",U->SrBlad);
				U->x->Print();
				printf("\nCzas obliczeñ: %f",U->Czas);
			}
			else
				printf("\n\apodczas obliczeñ wyst±pi³ b³±d nr: %d",U->Bledy);
			getchar();
			getchar();
		}
		if(war==4)
		{  if(C->Bledy==BEZ_BLEDU)
			{  WarPom=DokladnoscMO(*C,A);
				printf("\nMaxymalny b³±d przy odwracaniu macierzy rzêdu %d wynosi %f\n",A.Ile_Wierszy,WarPom);
				
			}
			else
				printf("\n\apodczas obliczeñ wyst±pi³ b³±d nr: %d",C->Bledy);
			getchar();
			getchar();
		}
		if((B.Bledy==A.Bledy)&&(A.Bledy==BEZ_BLEDU))
			war=menu_glowne[A.Ile_Kolumn!=A.Ile_Wierszy] ();
		else
			war=0;
	}
	while(war);
	delete C;
	if(U)
		delete U;
	return 0;
}

