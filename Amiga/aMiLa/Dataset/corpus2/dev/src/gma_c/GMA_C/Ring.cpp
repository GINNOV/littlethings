
//
// Abzählreim
// ¯¯¯¯¯¯¯¯¯¯
// Programmierungstechnik
// Aufgabe 25 (objektorientierte Programmierung II)
//
// Programmautor   : G.M.A.
// letzte Änderung : 21. April 1995
// Compiler        : Maxon-C/C++ 1.11.6
// E-Mails an      : galbrech@csmd.cs.uni-magdeburg.de
// Bemerkung       : benutzt Ring als Datenstruktur
//


// Includes

#include <stdio.h>
#include <string.h>
#include <iostream.h>


// Datentypen

typedef struct element
{
  char s[100];
  struct element *next;
} knoten;

class ring
{
  private:                             // Default
    int     anz_knoten;
    knoten *akt_knoten;
  
  public:
    ring();                            // Konstruktor
    void  new_node(char *x);
    void  del_node();
    void  next_node();
    void  pred_node();
    int   anz_nodes();
    int   ring_empty();
    char *out_node();
};


// Methoden von ring

ring::ring()                           // Initialisierung
{
  anz_knoten = 0;
  akt_knoten = NULL;
}

void ring::new_node(char *x)
{
  knoten *neu = new knoten;

  strcpy(neu->s, x);

  if (akt_knoten == NULL) // Ring leer
  {
    akt_knoten = neu;
    akt_knoten->next = NULL;
  }
  else
  {
    if (akt_knoten->next) // mehr als 1 Knoten in Ring
    {
      knoten *hilf = akt_knoten->next;

      akt_knoten->next = neu;
      neu->next = hilf;
    }
    else
    {                    // genau 1 Knoten in Ring
      neu->next = akt_knoten;
      akt_knoten->next = neu;
    }

    akt_knoten = neu;
  }

  anz_knoten++;
}

void ring::del_node()
{
  if (akt_knoten) // Wenn Ring nicht leer
  {
    if (akt_knoten->next) // mehr als 1 Knoten im Ring
    {
      knoten *hilf = akt_knoten->next;

      // Vorgänger von akt_knoten ermitteln und
      // das NEXT auf hilf setzen

      if (akt_knoten->next->next == akt_knoten) // 2 Knoten
      {                    // Vorgängerproblem entfällt.
        hilf->next = NULL; // Es bleibt nur 1 Knoten
      }
      else
      {                 // mehr als 2 Knoten
        knoten *dummy = akt_knoten->next;

        while (akt_knoten != dummy->next)
          dummy = dummy->next; // in dummy steht nun der Vorgänger

        dummy->next = hilf;
      }

      delete akt_knoten;
      akt_knoten = hilf;
    }
    else
    {               // 1 Knoten im Ring
      delete akt_knoten;
      akt_knoten = NULL;
    }
    anz_knoten--;
  }
}

void ring::pred_node()
{
  knoten *dummy = akt_knoten->next;

  while (akt_knoten != dummy->next)
    dummy = dummy->next; // in dummy steht nun der Vorgänger

  akt_knoten = dummy;
}

char *ring::out_node()
{
  knoten *save = akt_knoten;

  next_node();

  return (save->s);
}

// Ring eine Position weiterdrehen.

void ring::next_node()
{
  if (akt_knoten->next)
    akt_knoten = akt_knoten->next;
}

int ring::anz_nodes()
{
  return anz_knoten;
}

int ring::ring_empty()
{
  if ((akt_knoten == NULL) && (anz_knoten == 0))
    return(1);
  else
    return(0);
}


// Hauptprogramm

int main (void)
{
  ring player;                         // 2 Ringe werden benutzt !
  ring silben;

  char string[100];

  cout << "Abzählreim.\n";

  // Daten eingeben

  cout << "Spieler eingeben (Abbruch mit 'ende').\n";

  strcpy(string, "");
  while (strcmp(string, "ende") != 0)
  {
    cin >> string;

    if (strcmp(string, "ende") != 0)
    {
      player.new_node(string);
    }
  }
  player.next_node(); // ersten Spieler aktuell

  cout << "Silben eingeben (Abbruch mit 'ende').\n";

  strcpy(string, "");
  while (strcmp(string, "ende") != 0)
  {
    cin >> string;

    if (strcmp(string, "ende") != 0)
    {
      silben.new_node(string);
    }
  }
  silben.next_node(); // erste Silbe aktuell

  // Simulation

  cout << "\nSimulation\n¯¯¯¯¯¯¯¯¯¯\n";
  cout << "Anzahl Spieler : " << player.anz_nodes() << "\n";
  cout << "Anzahl Silben  : " << silben.anz_nodes() << "\n";
  cout << "\n";

  while (player.anz_nodes() > 1) // solange mehr als 1 Spieler im Spiel
  {
    int i;                      // universal
    int a = silben.anz_nodes(); // Silbenanzahl

    for (i=0; i<a; i++) // Einmal Reim durchlaufen
    {
      cout << "Spieler '" << player.out_node() << "' -> '";
      cout << silben.out_node() << "'\n";
    }
    cout << "Tut mir leid, aber Du bist raus !\n";

    // VORGÄNGER rauswerfen !!!

    player.pred_node();
    player.del_node();
  }
  cout << "\nÜbrig bleibt Spieler '" << player.out_node();
  cout << "' !\n";

  // aufräumen

  while (player.ring_empty() != 1) player.del_node();
  while (silben.ring_empty() != 1) silben.del_node();

  return(0);
}

