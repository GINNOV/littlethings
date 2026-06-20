// MsgTerm: Dimanche 24-Jan-93 par Gilles Dridi

#ifndef  EXEC_MSGTERM_H
#define  EXEC_MSGTERM_H

#ifndef  EXEC_MESSAGE_H
#include <exec/message.h>
#endif  !EXEC_MESSAGE_H

classe MsgTerm: public Message {
protegee:
   Tache    *AdrExpediteur;

public:
   MsgTerm(Tache *exp, TEXTE *nom= NUL, OCTET pri= 0);
   Tache *adrExpediteur() { renvoie AdrExpediteur; }
   ~MsgTerm();
};

#endif

