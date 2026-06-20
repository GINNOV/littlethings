#ifndef NULL
#define NULL 0
#endif
#ifndef _MACIERZ_H_
#define _MACIERZ_H_
#include <stdio.h>

#define BEZ_BLEDU 0
#define BRAK_PAMIECI 1
#define BLEDNE_OPERACJE 2
#define BLEDNE_DANE 4
#define ZLE_UWARUNKOWANIE 8
#define POZA_ZAKRESEM 16

class Algebra//obiekt wirtualny, prototyp Macierzy i wektorów
{  protected:
	char Pamiec;//1-dynamiczna,0-statyczna
	public:
	double *X;//dane
	public:
	unsigned int Ile_Kolumn;
	unsigned int Ile_Wierszy;
	char Bledy;//Flaga Bledu, flagi zdefiniowane powy¿ej
	virtual void Print(FILE *)=NULL;
};
class Macierz;
class Wektor : public Algebra
{  protected:
	unsigned int Skok;
	public:
	friend class Macierz;
	Wektor();
	Wektor(unsigned int);
	void Transponuj();
	Wektor(Wektor &);
	Wektor &operator=(const Wektor &);
	double operator*(Wektor &);
	Wektor operator*(double);
	double Norma();
	double Norma2();
	void Print(FILE *p=stdout);
	Wektor operator+(Wektor &);
	double &operator[](unsigned long int a)
	{  if(a<Ile_Kolumn+Ile_Wierszy)
			return X[a*Skok];
		else
		{  Bledy=POZA_ZAKRESEM;
			return X[0];
		}
			
	}
	~Wektor();
};

typedef Wektor *TabWsk;

Wektor *Rozwiazanie(Macierz &A,Wektor &b);

class Macierz : public Algebra
{  protected:
	unsigned int *I;//informacja o zamianach wierszy
	int ZamienWiersze(unsigned int,unsigned int);
	int Zamien(unsigned int);
	public:
	friend Wektor *Rozwiazanie(Macierz &A,Wektor &b);
	TabWsk *Kolumny;
	TabWsk *Wiersze;
	Macierz();
	Macierz(unsigned int, unsigned int);// Ile_Wierszy,ile_Kolumn
	Macierz(const Macierz &);
	//Macierz &operator=(const Macierz &);
	void Print(FILE *p=stdout);
	Wektor &operator[](unsigned int a)
	{  if(a<Ile_Wierszy)
			return *(Wiersze[a]);
		else
		{  Bledy=POZA_ZAKRESEM;
			return *(Wiersze[Ile_Kolumn-1]);
		}   
	}
	 ~Macierz();
	Macierz operator*(Macierz &);
	Wektor operator*(Wektor &);
	double War_Wlasna();
	int GaussToLU();
	Macierz *Odwrotna();
	Macierz *Transponuj();
	Macierz &operator=(const Macierz &);
};


#endif

