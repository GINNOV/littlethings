// ErrES: Dimanche 21-Fév-93 par Gilles Dridi

#ifndef  EXEC_ERRES_H
#define  EXEC_ERRES_H

enum Type_Erreur {
   ERRES_OUVERTUREECHOUE=  -1, // l'ouverture du périphérique a échoué
   ERRES_CMDAVORTE=        -2, // le périphérique avorte la requête
   ERRES_CMDINCONNUE=      -3, // commande inconnue
   ERRES_LONGUEURINVALIDE= -4  // longueur non valide
};

#endif
