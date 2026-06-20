
//
// Geometrische Figuren
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
// Programmierungstechnik
// Aufgabe 25 (objektorientierte Programmierung I)
//
// Programmautor   : G.M.A.
// letzte Änderung : 22. April 1995
// Compiler        : Maxon-C/C++ 1.11.6
// E-Mails an      : galbrech@csmd.cs.uni-magdeburg.de
// Bemerkung       : Beispiel zur Vererbung in C++
//


// Includes

#include <stdio.h>
#include <string.h>
#include <iostream.h>


// Datentypen

class punkt
{
  private:
    int x;
    int y;

  protected:
    void inp_x();
    void inp_y();

  public:
    punkt();
    void inp_punkt();
};

class linie : public punkt
{
  private:
    int a;
    int b;
    void inp_a();
    void inp_b();

  public:
    linie();
    void inp_linie();
};


// Methoden von Punkt

punkt::punkt()
{
  x = 0;
  y = 0;
}

void punkt::inp_x()
{
  cout << "Eingabe x: ";
  cin  >> x;
}

void punkt::inp_y()
{
  cout << "Eingabe y: ";
  cin  >> y;
}

void punkt::inp_punkt()
{
  inp_x();
  inp_y();
}


// Methoden von Linie

linie::linie()
{
  a = 0;
  b = 0;
}

void linie::inp_a()
{
  cout << "Eingabe a: ";
  cin  >> a;
}

void linie::inp_b()
{
  cout << "Eingabe b: ";
  cin  >> b;
}

void linie::inp_linie()
{
  inp_x();
  inp_y();
  inp_a();
  inp_b();
}


// Hauptprogramm

int main (void)
{
  punkt p;
  linie l;

  cout << "Geometrische Figuren.\n";

  cout << "\nPunkt.\n";
  p.inp_punkt();

  cout << "\nLinie.\n";
  l.inp_linie();

  return(0);
}

