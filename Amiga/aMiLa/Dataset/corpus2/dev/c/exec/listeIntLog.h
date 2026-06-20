// ListeIntLog: Lundi 19-Avr-93 par Gilles Dridi

#ifndef  EXEC_LISTEINTLOG_H
#define  EXEC_LISTEINTLOG_H

#ifndef  EXEC_LISTE_H
#include <exec/liste.h>
#endif  !EXEC_LISTE_H

#ifndef  EXEC_NOEUD_H
#include <exec/noeud.h>
#endif  !EXEC_NOEUD_H

classe ListeIntLog: public Liste {
   MOTN  Bourre;	// pour faire 16= 2^4 utilisé pour décalage (système)

public:
   ListeIntLog();
};

#endif
