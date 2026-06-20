
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
// letzte Änderung  : 11. Juni 1995
// Compiler         : Maxon-C/C++ 1.11.6
//


// Includes

#include <stdio.h>
#include <iostream.h>
#include <string.h>
#include <math.h>


// Konstanten

#define BOOL  int                      // Datentyp Boolean beschreiben
#define TRUE  1
#define FALSE 0


// Datentypen

enum stack_ib                          // Stack-Inhalts-Beschreibung
{
  TYP_ZAHL,
  TYP_OP_PLUS, TYP_OP_MINUS, TYP_OP_MAL, TYP_OP_DIV,
  TYP_OP_SIN,  TYP_OP_COS,   TYP_OP_TAN, TYP_OP_COT,
  TYP_OP_FAK,
  TYP_ERROR
};

class stack
{
  typedef struct element               // Stackelement
  {
    float data;                        // Stack-Inhalt
    int typ;                           // Beschreibung von "data"
    struct element *next;
  } knoten;

  private:
    knoten *root;                      // Zeiger auf Stackbeginn

  protected:

  public:
    stack();                           // Konstruktor
   ~stack();                           // Destruktor
    void push(float, int);
    void pop(float *, int *);
    BOOL empty();
};


// Memberfunktionen von "stack"

stack::stack()
{
  root = NULL;
}

stack::~stack()
{
  float f; int t;

  while (! empty())
    pop(&f, &t);
}

BOOL stack::empty()
{
  if (root)
    return(FALSE);
  else
    return(TRUE);
}

void stack::push(float d, int t)
{
  knoten *p = new knoten;

  if (p)
  {
    p->data = d;
    p->typ  = t;
    p->next = root;
    root    = p;
  }
  else
    cout << "Speicher reicht nicht.\n";
}

void stack::pop(float *d, int *t)
{
  if (empty())
  {
    *t = TYP_ERROR;
  }
  else
  {
    knoten *p = root;

    *d = p->data;
    *t = p->typ;

    root = root->next;
    delete p;
  }
}


// UP für Fakultät

float fak(float f)
{
  int i;
  float x = 1.0;

  for(i=1; i <= (int) f; i++)
    x = x * i;

  return(x);
}


// UP für Kotangens

float cot(float f)
{
  return( 1/tan(f) );
}


// UP überprüft Ausdruck auf äußere Klammern
// Wenn Klammern vorhanden, dann TRUE, sonst FALSE

BOOL check_brackets(char *a)
{
  // Voraussetzungen, um sagen zu können, daß KEINE äußeren
  // Klammern vorhanden sind:
  // Wenn Klammern vorhanden, dann steht etwas
  // (Buchstaben, Ziffern, Operatoren) vor oder hinter Klammer

  char *cp    = a;
  int  kl_cnt = 1;     // eine '(' ist dann schon gefunden


  // ist überhaupt Klammer im Ausdruck ?

  while ((*cp != '\0') && (*cp != '('))
    cp++;

  if (*cp == '\0')                     // keine Klammer da
    return(FALSE);

  // öffnende Klammer da, also auch schließende


  // Operatoren vor der Klammer suchen; Abbruch, wenn '('

  cp = a;

  while (*cp != '(')
  {
    if ((*cp >= '0' && *cp <= '9') ||
        (*cp >= 'a' && *cp <= 'z')  )
      return(FALSE);
    cp++;
  }


  // Klammer überlesen

  kl_cnt = 1;
  cp++;

  while (! ((*cp == ')') && (kl_cnt == 1)) )
  {
    switch (*cp)
    {
      case '(': kl_cnt++; break;
      case ')': kl_cnt--; break;
    }
    cp++;
  }
  cp++;                                // schließende Klammer überlesen

  // Operatoren hinter der Klammer suchen; Abbruch, wenn EOS

  while (*cp != '\0')
  {
    if ((*cp >= '0' && *cp <= '9') ||
        (*cp >= 'a' && *cp <= 'z')  )
      return(FALSE);
    cp++;
  }

  return(TRUE);
}


// Ist Zeichenkette ein Ausdruck ?

BOOL check_ausdruck(char *a)
{
  // Anzahl der Klammern testen

  {
    int count = 0;
    char *cp  = a;

    while (*cp != '\0')
    {
      if (*cp == '(') count++;
      if (*cp == ')') count--;
      cp++;
    }

    if (count != 0)
    {
      cout << "Anzahl von '(' ungleich Anzahl von ')' !\n";
      return(FALSE);
    }
  }

  // Anzahl Parameter und Anzahl Operatoren überprüfen

  {
    int cnt_zahlen = 0;
    int cnt_operat = 0;
    char *cp  = a;

    while (*cp != '\0')
    {
      // Zahlen

      if (*cp >= '0' && *cp <= '9')
      {
        while (*cp >= '0' && *cp <= '9')
          cp++;
        if (*cp == '.')
        {
          cp++;
          while (*cp >= '0' && *cp <= '9')
            cp++;
        }
        cnt_zahlen++;
      }

      if (*cp >= 'a' && *cp <= 'z')
      {
        if (strncmp(cp, "pi", 2) == 0)
        {
          cnt_zahlen++;
          cp+=2;
        }
        if (strncmp(cp, "e",  1) == 0)
        {
          cnt_zahlen++;
          cp++;
        }
      }

      // 1 stellige Operatoren ignorieren
      // (sin, cos, tan, cot, !, ...)

      // 2 stellige Operatoren

      if ( (*cp == '+') || (*cp == '-') ||
           (*cp == '*') || (*cp == '/')  ) cnt_operat++;

      cp++;
    }

    if (cnt_zahlen != cnt_operat+1)
    {
      cout << "Anzahl gegebener Ziffern und Operatoren stimmt nicht !\n";
      return(FALSE);
    }
  }

  if (! check_brackets(a))             // später entfernen
  {
    cout << "Keine äußere Klammer vorhanden !\n";
    return(FALSE);
  }

  // Alles ok

  return(TRUE);
}


// entfernt Leerzeichen

void format_string(char *s)
{
  register char *r, *w;                // Lesen, Schreiben

  for (w = r = s; *r != '\0'; r++)
    if (*r != ' ')
      *w++ = *r;

  *w = '\0';                           // Ende kennzeichnen
}


// entfernt äußere Klammer zwecks besserer Bearbeitung des Ausdruckes

void entferne_klammer(char *s)
{
  register char *r, *w;

  r = w = s;

  r++;
  while (*r != '\0')
    *w++ = *r++;

  *--w = '\0';
}


// bearbeitet den aufbereiteten Ausdruck
// Bekommt Ausdruck mit äußerer Klammer,
// Rückgabe vollständig geklammerter Ausdruck

char *klammern(char *q)                // Quell-Ausdruck
{
  static char z[100];                  // Rückgabe-Ausdruck

  char *cp          = q;               // Char-Pointer, universal

  char *op_pos[20];                    // Operator-Position
  int   op_typ[20];                    // Operator-Typ
  int   op_cnt      = 0;               // welcher Operator ?

  char *ausdr_s[20];                   // Start -> Zeiger auf '('
  char *ausdr_e[20];                   // Ende  -> Zeiger auf ')'
  int   ausdr_cnt   = 0;               // welcher Ausdruck ?

cout << "- Ausdr.bei Eintritt in klammern(): " << q << "\n";

  // Äußere Klammer entfernen

  entferne_klammer(q);


  // 1. Durchlauf, Arrays belegen

  while (*cp != '\0')
  {
    if (*cp == '(')                    // Ausdruck einlesen
    {
      int kl_cnt = 1;

      ausdr_cnt++;
      ausdr_s[ausdr_cnt] = cp;

      do
      {
        cp++;

        if (*cp == '(') kl_cnt++;
        if (*cp == ')') kl_cnt--;

      } while (kl_cnt > 0);

      ausdr_e[ausdr_cnt] = cp;
    }

    switch (*cp)
    {
      case '+': {
                  op_cnt++;            // noch (op_cnt < 20) testen !
                  op_pos[op_cnt] = cp;
                  op_typ[op_cnt] = TYP_OP_PLUS;
                }
                break;
      case '-': {
                  op_cnt++;
                  op_pos[op_cnt] = cp;
                  op_typ[op_cnt] = TYP_OP_MINUS;
                }
                break;
      case '*': {
                  op_cnt++;
                  op_pos[op_cnt] = cp;
                  op_typ[op_cnt] = TYP_OP_MAL;
                }
                break;
      case '/': {
                  op_cnt++;
                  op_pos[op_cnt] = cp;
                  op_typ[op_cnt] = TYP_OP_DIV;
                }
                break;
      case '!': {
                  op_cnt++;
                  op_pos[op_cnt] = cp;
                  op_typ[op_cnt] = TYP_OP_FAK;
                }
                break;
    }

    if (strncmp(cp, "sin", 3) == 0)
    {
      op_cnt++;
      op_pos[op_cnt] = cp;
      op_typ[op_cnt] = TYP_OP_SIN;
      cp += 2;
    }
    else if (strncmp(cp, "cos", 3) == 0)
    {
      op_cnt++;
      op_pos[op_cnt] = cp;
      op_typ[op_cnt] = TYP_OP_COS;
      cp += 2;
    }
    else if (strncmp(cp, "tan", 3) == 0)
    {
      op_cnt++;
      op_pos[op_cnt] = cp;
      op_typ[op_cnt] = TYP_OP_TAN;
      cp += 2;
    }
    else if (strncmp(cp, "cot", 3) == 0)
    {
      op_cnt++;
      op_pos[op_cnt] = cp;
      op_typ[op_cnt] = TYP_OP_COT;
      cp += 2;
    }

    cp++;
  }

cout << "- op_cnt   : " << op_cnt    << "\n";
cout << "- ausdr_cnt: " << ausdr_cnt << "\n";

  // 2. Durchlauf: alles ausgefüllt, nun auswerten (rekursiv)

  cp = q;

  if (op_cnt == 1)
  {
    strcpy(z, "(");
    strcat(z,  q );
    strcat(z, ")");

    return(z);
  }
  else if (op_cnt > 1)                 // Ausdruck muß geklammert werden
  {
    strcpy(z, "(");                    // erstmal löschen


    strcat(z, ")");

cout << "- Rückgabeausdruck: " << z << "\n";
    return(z);
  }
}


// Konvertiere Infix-Ausdruck i in Postfix-Ausdruck p
// und einen Postfix-Ausdrucks-Stack s

BOOL cnv_ausdruck(char *i, char *p, stack *s)
{
  stack op;                            // für Operatoren
  stack ausdr;                         // Postfix-Ausdruck
  float f = 0.0;
  int   x;

  char *c = i;

  strncpy(p, "", 99);                  // !!!

  while (*c != '\0')
  {
    if (*c >= 'a' && *c <= 'z')        // Buchstaben auswerten
    {
      if (strncmp(c, "sin", 3) == 0)
      {
        op.push(0.0, TYP_OP_SIN);
        c+=3;
      }
      if (strncmp(c, "cos", 3) == 0)
      {
        op.push(0.0, TYP_OP_COS);
        c+=3;
      }
      if (strncmp(c, "tan", 3) == 0)
      {
        op.push(0.0, TYP_OP_TAN);
        c+=3;
      }
      if (strncmp(c, "cot", 3) == 0)
      {
        op.push(0.0, TYP_OP_COT);
        c+=3;
      }

      // Konstanten

      if (strncmp(c, "pi", 2) == 0)
      {
        ausdr.push(3.141592654, TYP_ZAHL);
        strcat(p, "[pi]");
        c+=2;
      }
      if (strncmp(c, "e", 1) == 0)
      {
        ausdr.push(2.718281828, TYP_ZAHL);
        strcat(p, "[e]");
        c++;
      }
    }

    // Jetzt folgt erst die Routine zum Holen einer Zahl.
    // damit auch sowas geht: 'sin2.2' statt: 'sin 2.2'
    //                  oder: 'sinpi'  statt: 'sin pi'
    // alternativ ginge auch: c+=2 o.ä. (aber nicht so gut)

    if (*c >= '0' && *c <= '9')
    {
      strcat(p, "[");

      f = 0.0;
      while (*c >= '0' && *c <= '9')
      {
        f = 10 * f + (*c - '0');

        strncat(p, c, 1);

        c++; // Nach Zahl kommt immer MIND. 1x ')' - NIE '\0' !
      }

      if (*c == '.')                   // Nachkommastellen auswerten
      {
        c++;

        float nks = 0.0;
        float pos = 1.0;

        strcat(p, ".");

        while (*c >= '0' && *c <= '9')
        {
          pos = pos / 10;
          nks = nks + (*c - '0') * pos;

          strncat(p, c, 1);

          c++; // Nach Zahl kommt immer MIND. 1x ')' - NIE '\0' !
        }

        f = f + nks;
      }

      ausdr.push(f, TYP_ZAHL);

      strcat(p, "]");
    }

    // Jetzt erst Klammern usw. auswerten.
    // *c steht nämlich auf nächstem Zeichen !
    // Ein 'sin' oder 'cos' kann nicht kommen, da nach einem solchen
    // Wort eine Zahl folgen muss !
    // Und die wäre alse schon abgearbeitet worden ...

    switch (*c)
    {
      case ')' : {
                   if (op.empty())
                     cout << "Operatoren-Stack leer !\n";
                   else
                   {
                     op.pop(&f, &x);
                     ausdr.push(0.0, x);
                     switch (x)
                     {
                       case TYP_OP_PLUS  : strcat(p, "+"  ); break;
                       case TYP_OP_MINUS : strcat(p, "-"  ); break;
                       case TYP_OP_MAL   : strcat(p, "*"  ); break;
                       case TYP_OP_DIV   : strcat(p, "/"  ); break;
                       case TYP_OP_FAK   : strcat(p, "!"  ); break;
                       case TYP_OP_SIN   : strcat(p, "sin"); break;
                       case TYP_OP_COS   : strcat(p, "cos"); break;
                       case TYP_OP_TAN   : strcat(p, "tan"); break;
                       case TYP_OP_COT   : strcat(p, "cot"); break;
                     }
                   }
                 }
                 break;
      case '+' : op.push(0.0, TYP_OP_PLUS ); break;
      case '-' : op.push(0.0, TYP_OP_MINUS); break;
      case '*' : op.push(0.0, TYP_OP_MAL  ); break;
      case '/' : op.push(0.0, TYP_OP_DIV  ); break;
      case '!' : op.push(0.0, TYP_OP_FAK  ); break;
    }
    c++;
  }

  // Stack "umdrehen"

  while (! ausdr.empty())
  {
    ausdr.pop(&f, &x);
    s->push(f, x);
  }

  // Fertig

  return(TRUE);
}


// Berechne Postfix-Ausdruck

BOOL calc_ausdruck(stack *a, float *e)
{
  stack st;
  float d, x, y;
  int   t;

  while (! a->empty())
  {
    a->pop(&d, &t);

    switch (t)
    {
      case TYP_ZAHL     : st.push(d, t);
                          break;
      case TYP_OP_PLUS  : st.pop(&x, &t); st.pop(&y, &t);
                          st.push(x + y, TYP_ZAHL);
                          break;
      case TYP_OP_MINUS : st.pop(&x, &t); st.pop(&y, &t);
                          st.push(y - x, TYP_ZAHL);
                          break;
      case TYP_OP_MAL   : st.pop(&x, &t); st.pop(&y, &t);
                          st.push(x * y, TYP_ZAHL);
                          break;
      case TYP_OP_DIV   : {
                            st.pop(&y, &t);
                            st.pop(&x, &t);

                            if (y != 0.0)
                              st.push(x / y, TYP_ZAHL);
                            else
                            {
                              cout << "Division durch Null !\n";
                              cout << "Ergebnis fehlerhaft !\n";
                              return(FALSE);
                            }
                          }
                          break;
      case TYP_OP_FAK   : st.pop(&x, &t);
                          st.push(fak(x), TYP_ZAHL);
                          break;
      case TYP_OP_SIN   : st.pop(&x, &t);
                          st.push(sin(x), TYP_ZAHL);
                          break;
      case TYP_OP_COS   : st.pop(&x, &t);
                          st.push(cos(x), TYP_ZAHL);
                          break;
      case TYP_OP_TAN   : st.pop(&x, &t);
                          st.push(tan(x), TYP_ZAHL);
                          break;
      case TYP_OP_COT   : st.pop(&x, &t);
                          st.push(cot(x), TYP_ZAHL);
                          break;
      default : cout << "PF-A-Stack fehlerhaft !\n";
    }
  }

  st.pop(e, &t);

  return(TRUE);
}


// Hauptprogramm

int main()
{
  char  ausdruck_i[100];               // Infix
  char  ausdruck_f[100];               // Infix, formatiert
  char  ausdruck_p[100];               // Postfix
  stack ausdr_p;                       // Postfix, Stack
  float ergebnis;

  cout << "\n"
       << "Auswertung eines algorithmischen Ausdruckes.\n"
       << "¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\n";

  cout << "Ausdruck in Infix-Notation eingeben : ";
  cin.getline(ausdruck_i, 100);

  if (check_ausdruck(ausdruck_i))
  {
    format_string(ausdruck_i);
    strcpy(ausdruck_f, klammern(ausdruck_i));

    cout << "Formatierter Ausdruck               : "
         << ausdruck_f << "\n";

    if (cnv_ausdruck(ausdruck_f, ausdruck_p, &ausdr_p))
    {
      cout << "Ausdruck in Postfix-Notation        : "
           << ausdruck_p << "\n";

      if (calc_ausdruck(&ausdr_p, &ergebnis))
      {
        cout << "Ergebnis der Berechnung             :"
             << ergebnis << "\n";
      }
      else
        cout << "Abbruch.\n";
    }
    else
      cout << "Fehler beim Konvertieren aufgetreten !\n";
  }
  else
    cout << "Kein gültiger Ausdruck !\n";

  return(0);
}


