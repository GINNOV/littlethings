
//
// Bruchrechnung
// ¯¯¯¯¯¯¯¯¯¯¯¯¯
// Programmautor   : G.M.A.
// letzte Änderung : 22. April 1995
// Compiler        : Maxon-C/C++ 1.11.6
// E-Mails an      : galbrech@csmd.cs.uni-magdeburg.de
// Bemerkung       : objektorientierte Version
//


// Includes

#include <stdio.h>
#include <string.h>
#include <iostream.h>


// Datentypen

class bruch
{
  private:                             // Default
    int zaehler;
    int nenner;

    void kuerzen();
    void gleichnamig(bruch *a, bruch *b);

  public:
    bruch();                           // Konstruktor
    void eingabe();
    void ausgabe();
    void berechne(bruch a, bruch b, char o);
};


// Methoden von bruch

bruch::bruch()                         // Initialisierung
{
  zaehler = 0;
  nenner  = 0;
}

void bruch::eingabe()
{
  cout << "Zähler: ";
  cin  >> zaehler;
  cout << "Nenner: ";
  cin  >> nenner;
}

void bruch::ausgabe()
{
  cout << "Zähler: " << zaehler << "\n";
  cout << "Nenner: " << nenner  << "\n";
}

void bruch::kuerzen()
{
  int ggT;

  {                                    // ggT ermitteln
    int i = zaehler;
    int j = nenner;

    while (i != j)
      if (i > j)
        i -= j;
      else
        j -= i;
    ggT = i;
  }

  zaehler /= ggT;
  nenner  /= ggT;
}

void bruch::berechne(bruch a, bruch b, char o)
{
  switch (o)
  {
    case '+': gleichnamig(&a, &b);
              zaehler = a.zaehler + b.zaehler;
              nenner  = a.nenner;
              break;
    case '-': gleichnamig(&a, &b);
              zaehler = a.zaehler - b.zaehler;
              nenner  = a.nenner;
              break;
    case '*': zaehler = a.zaehler * b.zaehler;
              nenner  = a.nenner  * b.nenner;
              break;
    case '/': zaehler = a.zaehler * b.nenner;
              nenner  = a.nenner  * b.zaehler;
              break;
    default : cout << "Fehler bei Berechnung !\n\n";
  }

  kuerzen();
}

void bruch::gleichnamig(bruch *a, bruch *b)
{
  a->zaehler *= b->nenner;
  b->zaehler *= a->nenner;
  a->nenner  *= b->nenner;
  b->nenner   = a->nenner;
}


// Hauptprogramm

int main (void)
{
  bruch a, b, c;
  char operation;

  cout << "Bruchrechnung.\n";

  // Brüche eingeben

  cout << "\nBruch A eingeben:\n";
  a.eingabe();
  cout << "\nBruch B eingeben:\n";
  b.eingabe();

  // Operation eingeben

  cout << "\nOperation eingeben: ";
  cin  >> operation;

  // Ergebnis berechnen und ausgeben

  cout << "\nErgebnis:\n";
  c.berechne(a, b, operation);
  c.ausgabe();

  return(0);
}

