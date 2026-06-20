
//
// Belegaufgabe
// ¯¯¯¯¯¯¯¯¯¯¯¯
// Auswertung eines arithmetischen Ausdruckes
// unter Verwendung mehrerer Stacks
//
// Zweites Verfahren:
//   Der Ausdruck wird schon beim Konvertieren berechnet !
//   (daher wird kein Postfix-Ausdruck ausgegeben)
//
// Programmiert von : Gerrit M. Albrecht
//                    Erich-Weinert-Straße 37
//                    06526 Sangerhausen
//                    Deutschland / Germany
// E-Mail an        : galbrech@mus.urz.uni-magdeburg.de
// Version          : 1.0
// letzte Änderung  : 15. Juni 1995
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
  TYP_KL_AUF,  TYP_KL_ZU,
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
    int  last_ot();
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

int stack::last_ot()
{
  int   t;
  float f;

  pop(&f, &t);
  push(f, t);

  return(t);
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
      // return(FALSE);
    }
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


// Konvertiere Infix-Ausdruck i in Stack s

BOOL parse(char *i, stack *s)
{
  stack t;
  float f;
  int   x;

  char *c = i;

  while (*c != '\0')
  {
    if (*c >= 'a' && *c <= 'z')        // Buchstaben auswerten
    {
      if (strncmp(c, "sin", 3) == 0)
      {
        t.push(0.0, TYP_OP_SIN);
        c+=3;
      }
      if (strncmp(c, "cos", 3) == 0)
      {
        t.push(0.0, TYP_OP_COS);
        c+=3;
      }
      if (strncmp(c, "tan", 3) == 0)
      {
        t.push(0.0, TYP_OP_TAN);
        c+=3;
      }
      if (strncmp(c, "cot", 3) == 0)
      {
        t.push(0.0, TYP_OP_COT);
        c+=3;
      }

      // Konstanten

      if (strncmp(c, "pi", 2) == 0)
      {
        t.push(3.141592654, TYP_ZAHL);
        c+=2;
      }
      if (strncmp(c, "e", 1) == 0)
      {
        t.push(2.718281828, TYP_ZAHL);
        c++;
      }
    }

    // Jetzt folgt erst die Routine zum Holen einer Zahl.
    // damit auch sowas geht: 'sin2.2' statt: 'sin 2.2'
    //                  oder: 'sinpi'  statt: 'sin pi'
    // alternativ ginge auch: c+=2 o.ä. (aber das ist nicht so schön)

    if (*c >= '0' && *c <= '9')
    {
      f = 0.0;
      while (*c >= '0' && *c <= '9')
      {
        f = 10 * f + (*c - '0');

        c++; // Nach Zahl kommt immer MIND. 1x ')' - NIE '\0' !
      }

      if (*c == '.')                   // Nachkommastellen auswerten
      {
        c++;

        float nks = 0.0;
        float pos = 1.0;

        while (*c >= '0' && *c <= '9')
        {
          pos = pos / 10;
          nks = nks + (*c - '0') * pos;

          c++; // Nach Zahl kommt immer MIND. 1x ')' - NIE '\0' !
        }

        f = f + nks;
      }

      t.push(f, TYP_ZAHL);
    }

    // Jetzt erst Klammern usw. auswerten.
    // *c steht nämlich auf nächstem Zeichen !
    // Ein 'sin' oder 'cos' kann nicht kommen, da nach einem solchen
    // Wort eine Zahl folgen muss !
    // Und die wäre schon abgearbeitet worden ...

    switch (*c)
    {
      case '(' : t.push(0.0, TYP_KL_AUF  ); break;
      case ')' : t.push(0.0, TYP_KL_ZU   ); break;
      case '+' : t.push(0.0, TYP_OP_PLUS ); break;
      case '-' : t.push(0.0, TYP_OP_MINUS); break;
      case '*' : t.push(0.0, TYP_OP_MAL  ); break;
      case '/' : t.push(0.0, TYP_OP_DIV  ); break;
      case '!' : t.push(0.0, TYP_OP_FAK  ); break;
    }
    c++;
  }

  // Stack "umdrehen"

  while (! t.empty())
  {
    t.pop(&f, &x);
    s->push(f, x);
  }

  // Fertig

  return(TRUE);
}


// Berechnet einen Schritt

BOOL one_step(stack *od, stack *ot)
{
  float f, x, y;
  int   t;

  ot->pop(&f, &t);

  switch(t)
  {
    case TYP_OP_PLUS  : od->pop(&x, &t); od->pop(&y, &t);
                        od->push(x + y, TYP_ZAHL);
                        break;
    case TYP_OP_MINUS : od->pop(&x, &t); od->pop(&y, &t);
                        od->push(y - x, TYP_ZAHL);
                        break;
    case TYP_OP_MAL   : od->pop(&x, &t); od->pop(&y, &t);
                        od->push(x * y, TYP_ZAHL);
                        break;
    case TYP_OP_DIV   : {
                          od->pop(&y, &t);
                          od->pop(&x, &t);

                          if (y != 0.0)
                            od->push(x / y, TYP_ZAHL);
                          else
                          {
                            cout << "Division durch Null !\n";
                            cout << "Ergebnis fehlerhaft !\n";
                            return(FALSE);
                          }
                        }
                        break;
    case TYP_OP_FAK   : od->pop(&x, &t);
                        od->push(fak(x), TYP_ZAHL);
                        break;
    case TYP_OP_SIN   : od->pop(&x, &t);
                        od->push(sin(x), TYP_ZAHL);
                        break;
    case TYP_OP_COS   : od->pop(&x, &t);
                        od->push(cos(x), TYP_ZAHL);
                        break;
    case TYP_OP_TAN   : od->pop(&x, &t);
                        od->push(tan(x), TYP_ZAHL);
                        break;
    case TYP_OP_COT   : od->pop(&x, &t);
                        od->push(cot(x), TYP_ZAHL);
                        break;
    default           : cout << "Dieser Fehler dürfte nie auftreten !\n";
  }

  return(TRUE);
}


// Berechne Postfix-Ausdruck

BOOL calc_ausdruck(stack *a, float *e)
{
  stack od;                            // Operanden
  stack ot;                            // Operatoren
  float f, x, y;
  int   t;

  int   kl_cnt = 0;
  int   anz_ops[20];                   // 20 Klammern möglich

  anz_ops[kl_cnt] = 0;                 // kein Operator im Stack

  while (! a->empty())
  {
    a->pop(&f, &t);                    // 1 Argument holen

    switch (t)
    {
      case TYP_KL_AUF   : {
                            kl_cnt++;
                            anz_ops[kl_cnt] = 0;
                          }
                          break;
      case TYP_KL_ZU    : {
                            for (; anz_ops[kl_cnt] != 0;)
                            {
                              one_step(&od, &ot);
                              anz_ops[kl_cnt]--;
                            }

                            kl_cnt--;
                          }
                          break;
      case TYP_ZAHL     : od.push(f, TYP_ZAHL);
                          break;
      case TYP_OP_PLUS  : if (anz_ops[kl_cnt] == 0) // ot.empty()
                          {
                            ot.push(0.0, TYP_OP_PLUS);
                            anz_ops[kl_cnt]++;
                          }
                          else
                          {
                            // Hat last_ot() höhere oder gleiche
                            // Priorität, dann last_ot() ausführen
                            // sonst: Es gibt keine niedrigere Priorität

                            one_step(&od, &ot);
                            anz_ops[kl_cnt]--;

                            a->push(0.0, t); // später nochmal testen !
                          }
                          break;
      case TYP_OP_MINUS : if (anz_ops[kl_cnt] == 0) // ot.empty()
                          {
                            ot.push(0.0, TYP_OP_MINUS);
                            anz_ops[kl_cnt]++;
                          }
                          else
                          {
                            // Hat last_ot() höhere oder gleiche
                            // Priorität, dann last_ot() ausführen
                            // sonst: Es gibt keine niedrigere Priorität

                            one_step(&od, &ot);
                            anz_ops[kl_cnt]--;

                            a->push(0.0, t); // später nochmal testen !
                          }
                          break;
      case TYP_OP_MAL   : if (anz_ops[kl_cnt] == 0) // ot.empty()
                          {
                            ot.push(0.0, TYP_OP_MAL);
                            anz_ops[kl_cnt]++;
                          }
                          else
                          {
                            // Hat last_ot() höhere oder gleiche
                            // Priorität, dann last_ot() ausführen
                            // sonst: ablegen auf OT-Stack

                            switch (ot.last_ot())
                            {
                              case TYP_OP_PLUS  :
                              case TYP_OP_MINUS : ot.push(0.0, TYP_OP_MAL);
                                                  anz_ops[kl_cnt]++;
                                                  break;
                              default           : one_step(&od, &ot);
                                                  anz_ops[kl_cnt]--;
                                                  a->push(0.0, t);
                            }
                          }
                          break;
      case TYP_OP_DIV   : if (anz_ops[kl_cnt] == 0) // ot.empty()
                          {
                            ot.push(0.0, TYP_OP_DIV);
                            anz_ops[kl_cnt]++;
                          }
                          else
                          {
                            // Hat last_ot() höhere oder gleiche
                            // Priorität, dann last_ot() ausführen
                            // sonst: ablegen auf OT-Stack

                            switch (ot.last_ot())
                            {
                              case TYP_OP_PLUS  :
                              case TYP_OP_MINUS : ot.push(0.0, TYP_OP_DIV);
                                                  anz_ops[kl_cnt]++;
                                                  break;
                              default           : one_step(&od, &ot);
                                                  anz_ops[kl_cnt]--;
                                                  a->push(0.0, t);
                            }
                          }
                          break;
      case TYP_OP_FAK   : if (anz_ops[kl_cnt] == 0) // ot.empty()
                          {
                            ot.push(0.0, TYP_OP_FAK);
                            anz_ops[kl_cnt]++;
                          }
                          else
                          {
                            // Hat last_ot() höhere oder gleiche
                            // Priorität, dann last_ot() ausführen
                            // sonst: ablegen auf OT-Stack

                            switch (ot.last_ot())
                            {
                              case TYP_OP_PLUS  :
                              case TYP_OP_MINUS :
                              case TYP_OP_MAL   :
                              case TYP_OP_DIV   : ot.push(0.0, TYP_OP_FAK);
                                                  anz_ops[kl_cnt]++;
                                                  break;
                              default           : one_step(&od, &ot);
                                                  anz_ops[kl_cnt]--;
                                                  a->push(0.0, t);
                            }
                          }
                          break;
      case TYP_OP_SIN   : if (anz_ops[kl_cnt] == 0) // ot.empty()
                          {
                            ot.push(0.0, TYP_OP_SIN);
                            anz_ops[kl_cnt]++;
                          }
                          else
                          {
                            // Hat last_ot() höhere oder gleiche
                            // Priorität, dann last_ot() ausführen
                            // sonst: ablegen auf OT-Stack

                            switch (ot.last_ot())
                            {
                              case TYP_OP_PLUS  :
                              case TYP_OP_MINUS :
                              case TYP_OP_MAL   :
                              case TYP_OP_DIV   : ot.push(0.0, TYP_OP_SIN);
                                                  anz_ops[kl_cnt]++;
                                                  break;
                              default           : one_step(&od, &ot);
                                                  anz_ops[kl_cnt]--;
                                                  a->push(0.0, t);
                            }
                          }
                          break;
      case TYP_OP_COS   : if (anz_ops[kl_cnt] == 0) // ot.empty()
                          {
                            ot.push(0.0, TYP_OP_COS);
                            anz_ops[kl_cnt]++;
                          }
                          else
                          {
                            // Hat last_ot() höhere oder gleiche
                            // Priorität, dann last_ot() ausführen
                            // sonst: ablegen auf OT-Stack

                            switch (ot.last_ot())
                            {
                              case TYP_OP_PLUS  :
                              case TYP_OP_MINUS :
                              case TYP_OP_MAL   :
                              case TYP_OP_DIV   : ot.push(0.0, TYP_OP_COS);
                                                  anz_ops[kl_cnt]++;
                                                  break;
                              default           : one_step(&od, &ot);
                                                  anz_ops[kl_cnt]--;
                                                  a->push(0.0, t);
                            }
                          }
                          break;
      case TYP_OP_TAN   : if (anz_ops[kl_cnt] == 0) // ot.empty()
                          {
                            ot.push(0.0, TYP_OP_TAN);
                            anz_ops[kl_cnt]++;
                          }
                          else
                          {
                            // Hat last_ot() höhere oder gleiche
                            // Priorität, dann last_ot() ausführen
                            // sonst: ablegen auf OT-Stack

                            switch (ot.last_ot())
                            {
                              case TYP_OP_PLUS  :
                              case TYP_OP_MINUS :
                              case TYP_OP_MAL   :
                              case TYP_OP_DIV   : ot.push(0.0, TYP_OP_TAN);
                                                  anz_ops[kl_cnt]++;
                                                  break;
                              default           : one_step(&od, &ot);
                                                  anz_ops[kl_cnt]--;
                                                  a->push(0.0, t);
                            }
                          }
                          break;
      case TYP_OP_COT   : if (anz_ops[kl_cnt] == 0) // ot.empty()
                          {
                            ot.push(0.0, TYP_OP_COT);
                            anz_ops[kl_cnt]++;
                          }
                          else
                          {
                            // Hat last_ot() höhere oder gleiche
                            // Priorität, dann last_ot() ausführen
                            // sonst: ablegen auf OT-Stack

                            switch (ot.last_ot())
                            {
                              case TYP_OP_PLUS  :
                              case TYP_OP_MINUS :
                              case TYP_OP_MAL   :
                              case TYP_OP_DIV   : ot.push(0.0, TYP_OP_COT);
                                                  anz_ops[kl_cnt]++;
                                                  break;
                              default           : one_step(&od, &ot);
                                                  anz_ops[kl_cnt]--;
                                                  a->push(0.0, t);
                            }
                          }
                          break;
      default           : cout << "Arg-Stack fehlerhaft !\n";
    }
  }

  while (! ot.empty())                 // Rest berechnen
    one_step(&od, &ot);

  od.pop(e, &t);                       // Ergebnis zurückgeben

  return(TRUE);
}


// Hauptprogramm

int main()
{
  char  ausdruck[100];                 // Infix
  stack arg;                           // aufbereiteter Ausdruck
  float ergebnis;

  cout << "\n"
       << "Auswertung eines algorithmischen Ausdruckes.\n"
       << "¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\n";

  cout << "Ausdruck in Infix-Notation eingeben : ";
  cin.getline(ausdruck, 100);

  if (check_ausdruck(ausdruck))
  {
    format_string(ausdruck);

    if (check_brackets(ausdruck))
      entferne_klammer(ausdruck);

    if (parse(ausdruck, &arg))
    {
      if (calc_ausdruck(&arg, &ergebnis))
      {
        cout << "Ergebnis der Berechnung             :"
             << ergebnis << "\n";
      }
      else
        cout << "Fehler bei Berechnung. Abbruch.\n";
    }
    else
      cout << "Fehler in Ausdruck. Abbruch.\n";
  }
  else
    cout << "Kein gültiger Ausdruck. Abbruch.\n";

  return(0);
}


