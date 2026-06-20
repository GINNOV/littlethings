#include "uklad.h"
#include "macierz.h"
#include <math.h>
#include <stdio.h>
#include <time.h>

double UkladNO::Dokladnosc=10E-100;
char UkladNO::Czy_Zmieniac=1;
double mymax(double a, double b)
{  if(fabs(a)>fabs(b))
		return fabs(a);
	else
		return fabs(b);
}


UkladSt::UkladSt(Macierz &t,Wektor &z)
{  x=NULL;
	pamiec=0;
	clock_t sta,end;
	A=&t;
	ERR=0;
	LU=new Macierz(t);
	b=&z;
	Czas=0;
	Bledy=BEZ_BLEDU;
	if(LU)
	{  if(LU->Bledy)
			Bledy=BLEDNE_DANE|LU->Bledy;
		else
		{  Bledy=BEZ_BLEDU;
			sta=clock();
			if(!(LU->GaussToLU()))
				Bledy|=BLEDNE_OPERACJE;
			else
			{  if(!Rozwiaz())
					Bledy=ZLE_UWARUNKOWANIE;
			}
			end=clock();
			Czas=(double)(end-sta)/CLOCKS_PER_SEC;
		}
	}
	else
		Bledy=BRAK_PAMIECI;
}


UkladSt::~UkladSt()
{  if(x)
		delete x;
	x=NULL;
	if(LU)
		delete LU;
	LU=NULL;
	if(pamiec&&A)
		delete A;
	if(pamiec&&b)
		delete b;
}

int UkladSt::Rozwiaz()
{  if(LU->Bledy||Bledy)
	{  Bledy|=LU->Bledy;
		return 0;
	}
	else
	{  x=Rozwiazanie(*LU,*b);
		if(x)
		{  if(x->Bledy)
			{  Bledy|=BLEDNE_OPERACJE;
				return 0;
			}
			else
			{  ERR=SprERR();
				return 1;
			}
		}
		else
		{  Bledy|=BRAK_PAMIECI;
			return 0;
		}
	}

}

void UkladSt::Print(const char* nazwa)
{  FILE *plik;
	plik=fopen(nazwa,"w+");
	if(plik)
	{  fprintf(plik,"Macierz A:\n");
		A->Print(plik);
		fprintf(plik,"Wektor b:\n");
		b->Print(plik);
		fprintf(plik,"Rozwi±zanie:\n");
		x->Print(plik);
	}
	fclose(plik);
}


UkladNO::UkladNO()
{  Bledy=0;
	ERR=0;
	pamiec=0;
	x=NULL;
	A=NULL;
	b=NULL;
	I_K=NULL;
	Q=NULL;
	R=NULL;
	y=NULL;
	B=NULL;
	d=NULL;
	Czas=0;
}

UkladNO::UkladNO(Macierz &t,Wektor &z)
{  x=NULL;
	clock_t sta,end;
	Bledy=0;
	ERR=0;
	A=NULL;
	b=NULL;
	I_K=NULL;
	Q=NULL;
	R=NULL;
	y=NULL;
	B=NULL;
	d=NULL;
	Czas=0;
	A=&t;
	int i;
	pamiec=0;
	No0_K=A->Ile_Kolumn;
	Bledy=BEZ_BLEDU;
	b=&z;
	Q=new Macierz(t);
	R=new Macierz(Q->Ile_Kolumn,Q->Ile_Kolumn);
	y=new Wektor(Q->Ile_Kolumn);
	B=new Wektor(z);
	I_K=new unsigned int[A->Ile_Kolumn];
	if(B&&Q&&I_K)
	{  //A->Print();
		for(i=0;i<A->Ile_Kolumn;i++)
			I_K[i]=i;
		sta=clock();
		if((t.Bledy==BEZ_BLEDU)&&(z.Bledy==BEZ_BLEDU))
		{  if(!(OrtogonalizacjaGS()))
				Bledy|=ZLE_UWARUNKOWANIE;
			else
			{  ZnajdzB();
				if(!Rozwiaz())
					Bledy=ZLE_UWARUNKOWANIE;
			}
		}
		else
			Bledy|=BLEDNE_DANE;
		end=clock();
		Czas=(end-sta)/CLOCKS_PER_SEC;
	}
	else
		Bledy=BRAK_PAMIECI;
}

UkladNO::~UkladNO()
{  if(Q)
		delete Q;
	if(R)
		delete R;
	if(y)
		delete y;
	if(I_K)
		delete []I_K;
	if(B)
		delete B;
	if(x)
		delete x;
	if(d)
		delete d;
	d=NULL;
	x=NULL;
	if(pamiec&&A)
		delete A;
	if(pamiec&&b)
		delete b;
}

int UkladNO::ZamienK(int ktora)
{  unsigned int i;
	int zk=ktora;
	Wektor *PX;
	double maxnorm,inf;
	PX=(Q->Kolumny[I_K[ktora]]);
	maxnorm=PX->Norma2();
	inf=maxnorm;
	double b;
	for(i=ktora+1;i<No0_K;i++)
	{  PX=(Q->Kolumny[I_K[i]]);
		b=PX->Norma2();
		if(maxnorm<b)
		{  maxnorm=b;
			zk=i;
		}
	}
	if(inf==0)
	{   No0_K--;
	}

	if(zk>ktora)
	{  i=I_K[ktora];
		I_K[ktora]=I_K[zk];
		I_K[zk]=i;
		return 1;
	}
	else
	{  if(maxnorm<Dokladnosc)
		{  if(ktora>0)
				No0_K=ktora-1;
			else
				No0_K=0;
			return 0;
		}
		else
			return 1;
	}
}


int UkladNO::OrtogonalizacjaGS()
{  int i,j,k;
	d=new Wektor(Q->Ile_Wierszy+1);
	if(R&&y)
	{  for(i=0;i<R->Ile_Wierszy;i++)
		{  for(j=0;j<i;j++)
				(*R)[i][j]=0;
			(*R)[i][i]=1;
		}
		for(k=1;k</*A->Ile_Kolumn*/No0_K+1;k++)
		{  if(Czy_Zmieniac==1)
				ZamienK(k-1);
			(*d)[k]=0;
			for(i=0;i<Q->Ile_Wierszy;i++)
				(*d)[k]+=((*Q)[i][I_K[k-1]]*(*Q)[i][I_K[k-1]]);
			if((*d)[k]==0)
			{  No0_K=i;
				return i;
			}
			for(j=k;j<No0_K;j++)
			{  (*R)[k-1][j]=0;
				for(i=0;i<Q->Ile_Wierszy;i++)
					(*R)[k-1][j]+=((*Q)[i][I_K[k-1]]*(*Q)[i][I_K[j]]);
				(*R)[k-1][j]=((*R)[k-1][j]/(*d)[k]);
				for(i=0;i<Q->Ile_Wierszy;i++)
					(*Q)[i][I_K[j]]-=((*R)[k-1][j]*(*Q)[i][I_K[k-1]]);
			}
			
		}
	}
	else
		return 0;
	return 1;
}

void UkladNO::ZnajdzB()
{  int i,k;
	for(k=1;k<No0_K+1;k++)
	{  (*y)[k-1]=0;
		for(i=0;i<Q->Ile_Wierszy;i++)
			(*y)[k-1]+=((*Q)[i][I_K[k-1]]*(*B)[i]);
		(*y)[k-1]/=(*d)[k];
		for(i=0;i<Q->Ile_Wierszy;i++)
			(*B)[i]-=((*R)[0][k-1]*(*Q)[i][I_K[k-1]]);
	}
}

int UkladNO::Rozwiaz()
{  int i,j;
	double pomoc;
	if(Q&&B)
	{  if((Q->Bledy==BEZ_BLEDU)&&(B->Bledy==BEZ_BLEDU))
		{  if((R->Bledy==BEZ_BLEDU)&&(y->Bledy==BEZ_BLEDU))
			{  x=new Wektor(R->Ile_Wierszy);
				if(x)
				{  if(x->Bledy==BEZ_BLEDU)
					{  for(i=No0_K;i<R->Ile_Kolumn;i++)
							(*x)[I_K[i]]=0;
						for(i=No0_K-1;i+1;i--)
						{  pomoc=0;
							for(j=/*R->Ile_Kolumn*/No0_K-1;j>i;j--)
								pomoc+=((*R)[i][j]*(*x)[I_K[j]]);
							(*x)[I_K[i]]=(*y)[i]-pomoc;
						}
					}
					else
						Bledy|=BRAK_PAMIECI;
				}
				else
					Bledy|=BRAK_PAMIECI;
			}
			else
				Bledy|=BLEDNE_OPERACJE;
		}
		else
			Bledy|=BLEDNE_DANE;
	}
	else
		Bledy|=BRAK_PAMIECI;
	if(Bledy==BEZ_BLEDU)
	{  ERR=SprERR();
		return 1;
	}
	else
		return 0;
}

void UkladNO::Print(const char* nazwa)
{  FILE *plik;
	plik=fopen(nazwa,"w+");
	if(plik)
	{  fprintf(plik,"Macierz A:\n");
		A->Print(plik);
		fprintf(plik,"Wektor b:\n");
		b->Print(plik);
		fprintf(plik,"Rozwi±zanie:\n");
		x->Print(plik);
	}
	fclose(plik);
}

Uklad *RozwiazanieUkladu(Macierz &A, Wektor &b, char Flaga)
{  Uklad *U;
	Macierz *Z,*pom;
	Wektor *BB;
	int i;
	if((A.Bledy==BEZ_BLEDU)&&(b.Bledy==BEZ_BLEDU))
	{  if((A.Ile_Kolumn==A.Ile_Wierszy)&&(A.Ile_Wierszy==b.Ile_Wierszy))
		{  if((Flaga==AUTODETECT_)||(Flaga==GAUSS_))
				return new UkladSt(A,b);
			else
				return new UkladNO(A,b);
		}
		else
		{  if((A.Ile_Kolumn<A.Ile_Wierszy)&&(A.Ile_Wierszy==b.Ile_Wierszy))
			{  if((Flaga==AUTODETECT_)||(Flaga==ORTOGONALIZACJAGS_))
					return new UkladNO(A,b);
				else
				{  pom=A.Transponuj();
					if(pom)
					{  Z=new Macierz();
						BB=new Wektor();
						(*Z)=(*pom)*A;
						(*BB)=(*pom)*b;
						delete pom;
						if((BB->Bledy==Z->Bledy)&&(Z->Bledy==BEZ_BLEDU))
						{  U= new UkladSt(*Z,*BB);
							U->pamiec=1;
							return U;
						}
						else
							return NULL;
					}
					else
						return NULL;
				}
			}
			else
			{  if((A.Ile_Kolumn>A.Ile_Wierszy)&&(A.Ile_Wierszy==b.Ile_Wierszy))
				{  if((Flaga==AUTODETECT_)||(Flaga==ORTOGONALIZACJAGS_))
					{
						return new UkladPO(A,b);
					}
					else
						return NULL;
				}
				else
					return NULL;
			}
		}
	}
	else
	{  return NULL;
	}
}

double Uklad::SprERR()
{  double pom,ret=0;
	SrBlad=0;
	unsigned int i,j;
	if(x)
	{  if(x->Bledy==BEZ_BLEDU)
		{  for(i=0;i<A->Ile_Wierszy;i++)
			{  pom=0;
				for(j=0;j<A->Ile_Kolumn;j++)
					pom+=((*A)[i][j])*((*x)[j]);
				ret=mymax((pom-((*b)[i])),ret);
				SrBlad+=fabs(pom-(*b)[i]);
			}
			if(SrBlad>0)
				SrBlad=SrBlad/A->Ile_Wierszy;
		}
		else
			ret=257;
	}
	else
		ret=257;
	return ret;
}

double DokladnoscMO(Macierz &A,Macierz &W)
{  int i,j;
	Macierz I;
	double err=0;
	int xz;
	if((A.Bledy==BEZ_BLEDU)&&(W.Bledy==BEZ_BLEDU))
	{  I=A*W;
		if(I.Bledy==BEZ_BLEDU)
		{  for(i=0;i<I.Ile_Wierszy;i++)
			{  for(j=0;j<I.Ile_Kolumn;j++)
				{  if(i==j)
						err=mymax(err,((I[i][j])-1));
					else
						err=mymax(err,I[i][j]);
				}
			}
		
		}
		else
			err=256;
	}
	else
		err=257;
	return err;
}

UkladPO::UkladPO(Macierz &t,Wektor &z)
{  x=NULL;
	Bledy=0;
	clock_t sta,end;
	ERR=0;
	A=NULL;
	b=NULL;
	I_K=NULL;
	Q=NULL;
	R=NULL;
	y=NULL;
	B=NULL;
	d=NULL;
	RT1=NULL;
	Czas=0;
	A=&t;
	int i;
	char tmp;
	pamiec=0;
	Bledy=BEZ_BLEDU;
	b=&z;
	Q=t.Transponuj();
	No0_K=Q->Ile_Kolumn;
	R=new Macierz(Q->Ile_Kolumn,Q->Ile_Kolumn);
	y=new Wektor(Q->Ile_Wierszy);
	B=new Wektor(Q->Ile_Kolumn);
	I_K=new unsigned int[Q->Ile_Kolumn];
	if(B&&Q&&I_K)
	{  for(i=0;i<Q->Ile_Kolumn;i++)
			I_K[i]=i;
		sta=clock();
		if((t.Bledy==BEZ_BLEDU)&&(z.Bledy==BEZ_BLEDU))
		{  tmp=Czy_Zmieniac;
			Czy_Zmieniac=0;
			if(!(OrtogonalizacjaGS()))
				Bledy|=ZLE_UWARUNKOWANIE;
			else
			{  ZnajdzB();
				if(!Rozwiaz())
					Bledy=ZLE_UWARUNKOWANIE;
			}
			Czy_Zmieniac=tmp;
		}
		else
			Bledy|=BLEDNE_DANE;
		end=clock();
		Czas=(end-sta)/CLOCKS_PER_SEC;
	}
	else
		Bledy=BRAK_PAMIECI;
}

UkladPO::~UkladPO()
{  if(Q)
		delete Q;
	Q=NULL;
	if(R)
		delete R;
	R=NULL;

	if(y)
		delete y;
	y=NULL;
	if(I_K)
		delete []I_K;
	I_K=NULL;
	if(B)
		delete B;
	B=NULL;
	if(x)
		delete x;
	if(RT1)
		delete RT1;
	x=NULL;
	if(pamiec&&A)
		delete A;
	if(pamiec&&b)
		delete b;
}
void UkladPO::ZnajdzB()
{
	OdwrocR();
	int i,j;
	double pom;
	for(i=0;i<No0_K;i++)
	{  pom=0;
		for(j=0;j<No0_K;j++)
			pom+=(*RT1)[i][j]*(*b)[I_K[j]];
		(*B)[i]=pom/(*d)[i+1];
	}
	for(i=b->Ile_Wierszy-1;i>=0;i--)
	{   pom=0;
		for(j=i+1;j<b->Ile_Wierszy;j++)
			pom+=(*R)[i][j]*(*y)[j];
		(*y)[i]=(*B)[i]-pom;
	}
}


int UkladPO::Rozwiaz()
{  int i,j;
	double pomoc;
	if(Q&&B)
	{  if((Q->Bledy==BEZ_BLEDU)&&(B->Bledy==BEZ_BLEDU))
		{  if((R->Bledy==BEZ_BLEDU)&&(y->Bledy==BEZ_BLEDU))
			{  x=new Wektor(Q->Ile_Wierszy);
				if(x)
				{  if(x->Bledy==BEZ_BLEDU)
					{  for(i=0;i<No0_K;i++)
						{  pomoc=0;
							for(j=0;j<No0_K;j++)
								pomoc+=(*R)[i][j]*(*y)[j];
							(*B)[i]=pomoc;
						}
						for(i=0;i<Q->Ile_Wierszy;i++)
						 {  pomoc=0;
							 for(j=0;j<No0_K;j++)
								pomoc+=(*Q)[i][j]*(*B)[j];
							 (*x)[i]=pomoc;
						}
					}
					else
						Bledy|=BRAK_PAMIECI;
				}
				else
					Bledy|=BRAK_PAMIECI;
			}
			else
				Bledy|=BLEDNE_OPERACJE;
		}
		else
			Bledy|=BLEDNE_DANE;
	}
	else
		Bledy|=BRAK_PAMIECI;
	if(Bledy==BEZ_BLEDU)
	{  ERR=SprERR();
		return 1;
	}
	else
		return 0;
}



void UkladPO::OdwrocR()
{  Macierz *Pom;
	double pomx;
	Pom=R->Transponuj();
	RT1=Pom->Odwrotna();
	delete Pom;
}



