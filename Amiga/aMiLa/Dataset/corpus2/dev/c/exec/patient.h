// Patient: Vendredi 02-Oct-92 par Gilles Dridi

#ifndef EXEC_PATIENT_H
#define EXEC_PATIENT_H

#ifndef  EXEC_NOEUDMIN_H
#include <exec/noeudMin.h>
#endif  !EXEC_NOEUDMIN_H

classe Patient: public NoeudMin {
protegee:
   TacMin *AdrPatient;

public:
   Patient();
   TacMin *adrPatient() { renvoie AdrPatient; }
};

#endif
