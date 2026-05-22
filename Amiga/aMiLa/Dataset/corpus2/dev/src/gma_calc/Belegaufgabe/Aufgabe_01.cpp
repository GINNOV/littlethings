
//
// Belegaufgabe
// ¯¯¯¯¯¯¯¯¯¯¯¯
// Auswertung eines arithmetischen Ausdruckes
// unter Verwendung mehrerer Stacks
//
// Programmiert von : Gerrit M. Albrecht
//                    Erich-Weinert-Straße 37
//                    06526 Sangerhausen
//                    Deutschland / Germany
// E-Mail an        : galbrech@mus.urz.uni-magdeburg.de
// Version          : 1.0
// letzte Änderung  : 25. Mai 1995
// Compiler         : Maxon-C/C++ 1.11.6
//


// Includes

#include <stdio.h>
#include <iostream.h>
#include <string.h>


// Konstanten

#define BOOL  int                      // Datentyp Boolean beschreiben
#define TRUE  1
#define FALSE 0


// Datentypen

class stack
{
  typedef struct element               // Stackelement
  {
    float data;
    struct element *next;
  } knoten;

  private:
    knoten *root;                      // Zeiger auf Stackbeginn

  protected:
    BOOL empty();

  public:
    stack();                           // Konstruktor
   ~stack();                           // Destruktor
    void push(float);
    float pop();
};


// Memberfunktionen von "stack"

stack::stack()
{
  root = NULL;
}

stack::~stack()
{
  while (! empty())
    pop();
}

BOOL stack::empty()
{
  if (root)
    return(FALSE);
  else
    return(TRUE);
}

void stack::push(float d)
{
  knoten *p = new knoten;

  if (p)
  {
    p->data = d;
    p->next = root;
    root    = p;
  }
  else
    cout << "Speicher reicht nicht.\n";
}

float stack::pop()
{
  if (empty())
    return(0);
  else
  {
    knoten *p = root;
    float   d = p->data;

    root = root->next;
    delete p;

    return(d);
  }
}


// Berechne Postfix-Ausdruck

BOOL calc_ausdruck(char *a, float *e)
{
  stack st;
  char *p = a;                         // akt. Zeichen im Ausdruck

  while (*p != '\0')
  {
    switch (*p)
    {
      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9': st.push( (float) ((int) *p) - ((int) '0') );
                break;

      case '+': st.push(st.pop() + st.pop());
                break;
      case '-': st.push(st.pop() - st.pop());
                break;
      case '*': st.push(st.pop() * st.pop());
                break;
      case '/': {
                  float x = st.pop();
                  float y = st.pop();

                  if (y != 0.0)        // könnte ein Problem werden
                    st.push(x / y);
                  else
                  {
                    cout << "Division durch Null !\n";
                    cout << "Ergebnis fehlerhaft !\n";
                    st.push(0.0);
                  }
                }
                break;
      default : cout << "Fehler, der NIE auftreten sollte ...\n";
    }
    p++;
  }

  *e = st.pop();

  return(TRUE);
}


// Hauptprogramm

int main()
{
  float ergebnis;

  cout << "\n"
       << "Auswertung eines algorithmischen Ausdruckes in Postfix-Notation.\n";

  if (calc_ausdruck("598+46**7+*", &ergebnis))
  {
    cout << "Ergebnis der Berechnung von 598+46**7+* :"
         << ergebnis << "\n";
  }

  return(0);
}


