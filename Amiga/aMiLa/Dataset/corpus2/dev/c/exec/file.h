// File: Samedi 13-Mars-93 par Gilles Dridi

#ifndef  EXEC_FILE_H
#define  EXEC_FILE_H

#ifndef  EXEC_LISTEMIN_H
#include <exec/listeMin.h>
#endif  !EXEC_LISTEMIN_H

classe File: ListeMin {
public:
   File(): () {}
   File *enfile(NoeudMin *n) { renvoie (File *)ListeMin::enTete(n); }
   NoeudMin *defile() { renvoie ListeMin::enleveEnQueue(); }
};

#endif
