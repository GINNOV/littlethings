#include "macierz.h"
#ifndef _UKLAD_H_
#define _UKLAD_H_


#define AUTODETECT_ 0
#define GAUSS_ 1
#define ORTOGONALIZACJAGS_ 2

class Uklad;

Uklad *RozwiazanieUkladu(Macierz &A, Wektor &b, char Flaga=0);

class Uklad
{  protected:
	double SprERR();
	virtual int Rozwiaz()=NULL;
	int pamiec;
	public:
	friend Uklad *RozwiazanieUkladu(Macierz &A, Wektor &b, char Flaga);
	Wektor *x;
	double Czas;
	Macierz *A;
	Wektor *b;
	double ERR;
	double SrBlad;
	int Bledy;
	virtual void Print(const char*)=NULL;
	virtual ~Uklad()
	{}

};
class UkladSt: public Uklad
{  protected:
	Macierz *LU;
	int Rozwiaz();
	public:
	void Print(const char*);
	UkladSt(Macierz &,Wektor &);
	~UkladSt();

};

class UkladNO : public Uklad
{  protected:
	int ZamienK(int);
	unsigned int *I_K;//informacja o kolejno¶ci kolumn
	int No0_K;//informacja o ilo¶ci kolumn niezerowych
	Macierz *Q;
	Macierz *R;
	Wektor *y;
	Wektor *B;
	Wektor *d;
	virtual void ZnajdzB();
	int Rozwiaz();
	int OrtogonalizacjaGS();
	public:
	static double Dokladnosc;
	static char Czy_Zmieniac;//0-nie, 1-tak;
	UkladNO(Macierz &,Wektor &);
	UkladNO();
	~UkladNO();
	void Print(const char*);
};

class UkladPO : public UkladNO
{  protected:
	void OdwrocR();
	void ZnajdzB();
	int Rozwiaz();
	Macierz *RT1;
	public:
	UkladPO(Macierz &,Wektor &);
	~UkladPO();
};
double DokladnoscMO(Macierz &,Macierz &);
#endif

