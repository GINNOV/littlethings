#include <stdio.h>
#include "macierz.h"
#include <math.h>

int Macierz::Zamien(unsigned int b)
{  unsigned int k,j;
	Macierz *a=this;
	double x=fabs((*a)[b][b]);
	k=b;
	for(j=a->Ile_Wierszy-1;b<j;j--)
	{  if(x<fabs((*a)[j][b]))
		{  x=fabs((*a)[j][b]);
			k=j;
		}
	}
	if(k>b)
		a->ZamienWiersze(b,k);
	if(x)
		return 1;
	else
		return 0;
}

Wektor::Wektor()
{  X=NULL;
	Ile_Kolumn=1;
	Ile_Wierszy=1;
	Bledy=BEZ_BLEDU;
	Pamiec=0;
	Skok=1;
}

void Wektor::Transponuj()
{  if(Ile_Kolumn==1)
	{  Ile_Kolumn=Ile_Wierszy;
		Ile_Wierszy=1;
	}
	else
	{  Ile_Wierszy=Ile_Kolumn;
		Ile_Kolumn=1;
	}
}

Wektor::Wektor(Wektor &a)
{  Bledy=a.Bledy;
	if(a.Bledy==0)
	{  Ile_Kolumn=a.Ile_Kolumn;
		Ile_Wierszy=a.Ile_Wierszy;
		Skok=1;
		X=new double[Ile_Kolumn+Ile_Wierszy-1];
		if(X)
		{  int i;
			for(i=Ile_Kolumn+Ile_Wierszy-2;i>=0;i--)
			  X[i]=a[i];
			Pamiec=1;
		}
		else
		{  Pamiec=0;
			Bledy|=BRAK_PAMIECI;
		}
	}
	else
	{
		Pamiec=0;
		Ile_Kolumn=0;
		Ile_Wierszy=0;
		X=NULL;
		Skok=1;
	}
}

Wektor::Wektor(unsigned int a)
{  Ile_Kolumn=1;
	Ile_Wierszy=a;
	Skok=1;
	X=new double[a];
	if(X)
	{  Pamiec=1;
		Bledy=BEZ_BLEDU;
	}
	else
	{  Pamiec=0;
		Bledy=BRAK_PAMIECI;
	}
}

Wektor &Wektor::operator=(const Wektor &a)
{  if(Pamiec==1)
			delete []X;
	Ile_Kolumn=a.Ile_Kolumn;
	Ile_Wierszy=a.Ile_Wierszy;
	Skok=1;
	Bledy=a.Bledy;
	X=new double[Ile_Kolumn+Ile_Wierszy];
	Pamiec=1;
	if(X)
	{  unsigned int i;
		for(i=0;i<Ile_Kolumn+Ile_Wierszy-1;i++)
			X[i*Skok]=a.X[i*a.Skok];
	}
	else
	{  Bledy|=BRAK_PAMIECI;
		Pamiec=0;
	}
	return *this;
}

double Wektor::operator*(Wektor &a)
{  double z=0;
	int i;
	if(Ile_Kolumn==a.Ile_Wierszy)
	{  for(i=0;i<Ile_Kolumn;i++)
			z+=X[Skok*i]*a[i];
	}
	return z;
}
Wektor Wektor::operator*(double a)
{  unsigned int i;
	Wektor ret(Ile_Kolumn);
	if(ret.Bledy==BEZ_BLEDU)
	{  for(i=0;i<Ile_Kolumn;i++)
			ret.X[i]=a*X[i];
	}
	return ret;
}

Wektor Wektor::operator+(Wektor &a)
{  int i;
	Wektor Z;
	Z.Skok=1;
	if(Bledy||a.Bledy)
		Z.Bledy=BLEDNE_DANE|Bledy|a.Bledy;
	else
	{  if((Ile_Kolumn==a.Ile_Kolumn)&&(Ile_Kolumn>1))
		{  Z.Ile_Kolumn=Ile_Kolumn;
			Z.Ile_Wierszy=1;
			Z.X=new double[Ile_Kolumn];
			if(Z.X)
			{  Z.Pamiec=1;
				Z.Bledy=BEZ_BLEDU;
				for(i=0;i<Ile_Kolumn;i++)
					Z.X[i]=X[i*Skok]+a.X[i*a.Skok];
			}
			else
			{  Z.Pamiec=0;
				Z.Bledy=BRAK_PAMIECI;
			}
		}
		else
		{  if((Ile_Wierszy==a.Ile_Wierszy)&&(Ile_Wierszy>1))
			{  Z.Ile_Wierszy=Ile_Wierszy;
				Z.Ile_Kolumn=1;
				Z.X=new double[Ile_Wierszy];
				if(Z.X)
				{  Z.Pamiec=1;
					Z.Bledy=BEZ_BLEDU;
					for(i=0;i<Ile_Wierszy;i++)
						Z.X[i]=X[i*Skok]+a.X[i*a.Skok];
				}
				else
				{  Z.Pamiec=0;
					Z.Bledy=BRAK_PAMIECI;
				}
			}
			else
			{  Z.Pamiec=0;
				Z.Bledy=BLEDNE_OPERACJE;
			}
		}
	}
	return Z;
}

Wektor::~Wektor()
{  if((Pamiec==1)&&X)
		delete []X;
}

double Wektor::Norma()
{  double a=0,b;
	int i;
	for(i=0;i<Ile_Wierszy+Ile_Kolumn;i++)
	{  b=fabs((*this)[i]);
		if(a<b)
			a=b;
	}
	return a;
}

double Wektor::Norma2()
{  double a=0,b;
	int i;
	a=0;
	for(i=0;i<Ile_Wierszy*Ile_Kolumn;i++)
	{  b=X[i*Skok];//(*this)[i];
		a+=b*b;
	}
	return sqrt(a);
}

void Wektor::Print(FILE *p)
{  int i;
	fprintf(p,"<");
	for(i=0;i<Ile_Wierszy*Ile_Kolumn-1;i++)
		fprintf(p,"%f, ",X[i*Skok]);
	fprintf(p,"%f>\n",X[i*Skok]);
}

Macierz::Macierz()
{  X=NULL;
	Ile_Kolumn=0;
	Ile_Wierszy=0;
	Bledy=BEZ_BLEDU;
	Pamiec=0;
	Kolumny=NULL;
	Wiersze=NULL;
	I=NULL;
}
Macierz::Macierz(const Macierz &a)
{  Bledy=a.Bledy;
	if(a.Bledy==BEZ_BLEDU)
	{  Ile_Kolumn=a.Ile_Kolumn;
		Ile_Wierszy=a.Ile_Wierszy;
		X=new double[Ile_Kolumn*Ile_Wierszy];
		if(X)
		{  unsigned int i,j;
			Kolumny= new TabWsk[Ile_Kolumn];
			Wiersze=new TabWsk[Ile_Wierszy];
			I=new unsigned int[Ile_Wierszy];
			for(i=0;i<(Ile_Kolumn*Ile_Wierszy);i++)
			{  X[i]=a.X[i];
			}
			for(i=0;i<Ile_Kolumn;i++)
			{  Kolumny[i]=new Wektor();
				Kolumny[i]->X=&(X[i]);
				Kolumny[i]->Pamiec=0;
				Kolumny[i]->Ile_Wierszy=Ile_Wierszy;
				Kolumny[i]->Skok=Ile_Kolumn;
				Kolumny[i]->Ile_Kolumn=1;
			}
			for(i=0;i<Ile_Wierszy;i++)
			{  Wiersze[i]=new Wektor();
				Wiersze[i]->X=&(X[i*Ile_Kolumn]);
				Wiersze[i]->Ile_Kolumn=Ile_Kolumn;
				Wiersze[i]->Pamiec=0;
				Wiersze[i]->Skok=1;
				Wiersze[i]->Ile_Wierszy=1;
				I[i]=i;
			}
			Pamiec=1;
		}
		else
		{  Pamiec=0;
			Bledy|=BRAK_PAMIECI;
		}
	}
	else
	{  Pamiec=0;
		Ile_Kolumn=0;
		Ile_Wierszy=0;
		//Bledy=a.Bledy;
		X=NULL;
	}
}
Macierz::Macierz(unsigned int a,unsigned int b)
{  Ile_Kolumn=b;
	Ile_Wierszy=a;
	Bledy=BEZ_BLEDU;
	X=new double[Ile_Kolumn*Ile_Wierszy];
	if(X)
	{  Pamiec=1;
		Kolumny = new TabWsk[Ile_Kolumn];
		Wiersze = new TabWsk[Ile_Wierszy];
		I=new unsigned int[Ile_Wierszy];
		if(I&&Kolumny&&Wiersze)
		{  int i;
			for(i=0;i<Ile_Kolumn;i++)
			{  Kolumny[i]=new Wektor();
				Kolumny[i]->Skok=Ile_Kolumn;
				Kolumny[i]->X=&(X[i]);
				Kolumny[i]->Ile_Wierszy=Ile_Wierszy;
				Kolumny[i]->Ile_Kolumn=1;
			}
			for(i=0;i<Ile_Wierszy;i++)
			{  Wiersze[i]=new Wektor();
				Wiersze[i]->X=&(X[i*Ile_Kolumn]);
				Wiersze[i]->Ile_Kolumn=Ile_Kolumn;
				Wiersze[i]->Ile_Wierszy=1;
				I[i]=i;
			}
		}
		else
		{  Bledy=BRAK_PAMIECI;
		}
	}
	else
	{  Bledy=BRAK_PAMIECI;
		Pamiec=0;
	}
}
Macierz::~Macierz()
{  int i;
	if(Kolumny)
	{  for(i=0;i<Ile_Kolumn;i++)
			delete Kolumny[i];
		delete []Kolumny;
	}
	if(Wiersze)
	{  for(i=0;i<Ile_Wierszy;i++)
			delete Wiersze[i];
		delete []Wiersze;
	}
	if((Pamiec==1)&&X)
		delete []X;
	if(I)
		delete []I;
}

Macierz Macierz::operator*(Macierz &a)
{  int i,j=0;
	if(a.Bledy||Bledy)
		j=a.Bledy|Bledy|BLEDNE_DANE;
	else
	{  if(Ile_Kolumn==a.Ile_Wierszy)
		{  Macierz z(a.Ile_Kolumn,Ile_Wierszy);
			if(z.Bledy==BEZ_BLEDU)
			{  for(i=0;i<a.Ile_Kolumn;i++)
				{  for(j=0;j<Ile_Wierszy;j++)
					{  z[j][i]=(*Wiersze[I[j]])*(*a.Kolumny[i]);

					}
				}
			}
			return z;
		}
		else
			j=BLEDNE_DANE;
	}
	Macierz w;
	w.Bledy|=j;
	return w;
}

int Macierz::ZamienWiersze(unsigned int a,unsigned int b)
{  unsigned int ret=0;
	if((a<Ile_Wierszy)&&(b<Ile_Wierszy))
	{  Wektor *pom;
		pom=Wiersze[a];
		Wiersze[a]=Wiersze[b];
		Wiersze[b]=pom;
		ret=I[a];
		I[a]=I[b];
		I[b]=ret;
		ret=1;
	}
	else
		ret=0;
	return (int)ret;
}
int Macierz::GaussToLU()
{  int spr=1;
	Macierz *a=this;
	if(a->Ile_Kolumn==a->Ile_Wierszy)
	{  unsigned int i,j,k,Rozmiar=a->Ile_Kolumn;
		for(i=0;(i<Rozmiar)&&spr;i++)
		{  spr=Zamien(i);
			if(spr)
			{  for(j=i+1;j<Rozmiar;j++)
				{  (*a)[j][i]=((*a)[j][i])/((*a)[i][i]);
					for(k=i+1;k<Rozmiar;k++)
						(*a)[j][k]=((*a)[j][k])-(((*a)[j][i])*((*a)[i][k]));
				}
			}
		}
	}
	else
		spr=0;
	return spr;
}

Wektor *Rozwiazanie(Macierz &A,Wektor &b)
{  int i,j;
	Wektor *ret=new Wektor(A.Ile_Kolumn);
	if(ret)
	{  if((!A.Bledy)&&(!b.Bledy)&&(!ret->Bledy))
		{  double *bb=new double[A.Ile_Wierszy];
			for(i=0;i<A.Ile_Wierszy;i++)
			{  bb[i]=0;
				for(j=0;j<i;j++)
					bb[i]=bb[i]+(A[i][j]*bb[j]);
				bb[i]=b[A.I[i]]-bb[i];
			}
			for(i=A.Ile_Wierszy-1;i>=0;i--)
			{  (*ret)[i]=0;
				for(j=A.Ile_Wierszy-1;j>i;j--)
					(*ret)[i]=(*ret)[i]+(A[i][j]*(*ret)[j]);
				(*ret)[i]=(bb[i]-(*ret)[i])/A[i][i];
			}
			delete []bb;
		}
		else
			ret->Bledy=ret->Bledy|A.Bledy|b.Bledy;
		return ret;
	}
	else
		return new Wektor();
}

Macierz *Macierz::Odwrotna()
{  if(Ile_Wierszy==Ile_Kolumn)
	{  Macierz *ret=new Macierz(Ile_Wierszy,Ile_Kolumn);
		Macierz temp(*this);
		Wektor Z(Ile_Kolumn);
		Wektor *px;
		int i,j;
		if(temp.GaussToLU())
		{  for(i=0;i<Ile_Wierszy;i++)
			{  for(j=0;j<Ile_Wierszy;j++)
				{  if(i!=j)
						Z[j]=0.0;
					else
						Z[j]=1.0;
				}
				px=Rozwiazanie(temp,Z);
				if(px&&(!px->Bledy))
				{  for(j=0;j<Ile_Wierszy;j++)
						(*ret)[j][i]=(*px)[j];
					delete px;
				}
				else
				{  ret->Bledy|=BLEDNE_OPERACJE;
					i=Ile_Wierszy;
				}

			}
		}
		return ret;
	}
	else
		return new Macierz();
}

Macierz &Macierz::operator=(const Macierz &a)
{  unsigned int i,j;
	if(Pamiec==1)
	{  if(X)
			delete []X;
		if(Kolumny)
		{  for(i=0;i<Ile_Kolumn;i++)
				delete Kolumny[i];
			delete []Kolumny;
		}
		if(Wiersze)
		{  for(i=0;i<Ile_Wierszy;i++)
				delete Wiersze[i];
			delete []Wiersze;
		}
		if(I)
			delete []I;
	}
	Ile_Kolumn=a.Ile_Kolumn;
	Ile_Wierszy=a.Ile_Wierszy;
	Bledy=a.Bledy;
	if(!Bledy)
	{  X=new double[Ile_Kolumn*Ile_Wierszy];
		if(X)
		{  Pamiec=1;
			for(i=0;i<Ile_Wierszy;i++)
			{  for(j=0;j<Ile_Kolumn;j++)
					X[i*Ile_Kolumn+j]=a.X[i*Ile_Kolumn+j];
			}
			Kolumny = new TabWsk[Ile_Kolumn];
			Wiersze = new TabWsk[Ile_Wierszy];
			I=new unsigned int[Ile_Wierszy];
			if(I&&Kolumny&&Wiersze)
			{  for(i=0;i<Ile_Wierszy;i++)
					I[i]=a.I[i];
				for(i=0;i<Ile_Kolumn;i++)
				{  Kolumny[i]=new Wektor();
					Kolumny[i]->Skok=Ile_Kolumn;
					Kolumny[i]->X=&(X[i]);
					Kolumny[i]->Ile_Wierszy=Ile_Wierszy;
				}
				for(i=0;i<Ile_Wierszy;i++)
				{  Wiersze[I[i]]=new Wektor();
					Wiersze[I[i]]->X=&(X[i*Ile_Kolumn]);
					Wiersze[I[i]]->Ile_Kolumn=Ile_Kolumn;
					Wiersze[I[i]]->Skok=1;
				}
			}
			else
				Bledy|=BRAK_PAMIECI;
		}
		else
		{  Bledy|=BRAK_PAMIECI;
			Pamiec=0;
		}

	}
	return *this;
}

Wektor Macierz::operator*(Wektor &a)
{  Wektor ret(a.Ile_Wierszy);
	int i,j;
	if((a.Ile_Wierszy>1)&&(a.Ile_Wierszy==Ile_Kolumn))
	{  if(ret.Bledy==BEZ_BLEDU)
		{  for(i=0;i<Ile_Wierszy;i++)
			{  ret[i]=0;
				for(j=0;j<Ile_Kolumn;j++)
					ret[i]+=((*this)[i][j]*a[j]);
				ret.Transponuj();
			}
		}
	}
	else
		ret.Bledy|=BLEDNE_OPERACJE;
	return ret;
}


double Macierz::War_Wlasna()
{  Wektor W(Ile_Wierszy);
	Wektor pom(Ile_Wierszy);
	int war=1;
	int ITER=50;
	double eps=0.0000000001;
	int i;
	for(i=0;i<Ile_Wierszy;i++)
		W[i]=0.01*i;
	double p=1,w2=100,w1=1,r;
	W.Transponuj();
	for(i=0;(i<ITER)&&war;(i++))
	{  pom=((*this)*W);
		if(pom.Bledy==BEZ_BLEDU)
		{  r=pom.Norma();
			if(r>eps)
			{  w1=r/p;
				p=r;
				W=pom;
				if(eps>fabs(w1-w2))
					war=0;
				w2=w1;
			}
			else
				i=ITER+1;
		}
		else
		{  i=ITER+1;
		}
	}
	if(i>=ITER)
	{  Bledy|=ZLE_UWARUNKOWANIE;
		w1=0;
	}
	return w1;
}

Macierz *Macierz::Transponuj()
{  Macierz *M=new Macierz(Ile_Kolumn,Ile_Wierszy);
	unsigned int i,j;
	if(M)
	{  if(M->Bledy==BEZ_BLEDU)
		{  for(i=0;i<Ile_Wierszy;i++)
			{  for(j=0;j<Ile_Kolumn;j++)
					(*M)[j][i]=(*this)[i][j];
			}
		}
		return M;
	}
	return NULL;
}

void Macierz::Print(FILE *p)
{  int i;
	for(i=0;i<Ile_Wierszy;i++)
		(Wiersze[i])->Print(p);
}
