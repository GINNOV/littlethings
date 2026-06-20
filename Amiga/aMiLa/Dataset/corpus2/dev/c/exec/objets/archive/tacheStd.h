// TâcheStd: Mercredi 20-Jan-93 par Gilles Dridi
// La structure de tâche, la pile "en dur" et le pointeur sur la tâche
// parente sont réservés sur la pile de la tâche parente quand l'objet
// est automatique.

#ifndef  EXEC_TACHESTD_H
#define  EXEC_TACHESTD_H

#ifndef  EXEC_TACHE_H
#include <exec/tache.h>
#endif  !EXEC_TACHE_H

#ifndef  EXEC_PILE_H
#include <exec/pile.h>
#endif  !EXEC_PILE_H

#ifndef  EXEC_MSGTERM_H
#include <exec/msgTerm.h>
#endif  !EXEC_MSGTERM_H

#ifndef  EXEC_PORTSTD_H
#include <exec/portStd.h>
#endif  !EXEC_PORTSTD_H

classe TacheStd: public Tache {
   Pile     PileTache;
   MsgTerm  MessageTerm;
   PortStd  *AdrPortTerm;

   amie NEANT CodeTerminal();
public:
   TacheStd(Procedure code, PortStd *PortTerm,
            TEXTE *nom= NUL, OCTET pri= 0);
   MsgTerm &msgTerm() { renvoie MessageTerm; }
   ~TacheStd();
};

#endif
