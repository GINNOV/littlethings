#ifndef PPC_C2P_H
#define PPC_C2P_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

IMPORT RGB15_TO_HAM6_NI(UWORD *RGB15, ULONG **Planes,
                        ULONG Width, ULONG Height);

IMPORT C2P_NI(UBYTE *Chunky, ULONG **Planes,
              ULONG Width, ULONG Height);

#endif /* AMIGA_C2P_PPC_H */
