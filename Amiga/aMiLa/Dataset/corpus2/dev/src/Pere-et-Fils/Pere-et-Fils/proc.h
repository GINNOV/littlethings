/********************************************************************
 *
 *       proc.h     include general pour process
 *
 */

#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef  EXEC_NODES_H
#include <exec/nodes.h>
#endif

#ifndef  EXEC_MEMORY_H
#include <exec/memory.h>
#endif

#ifndef  EXEC_IO_H
#include <exec/io.h>
#endif

#ifndef  EXEC_PORTS_H
#include <exec/ports.h>
#endif

#ifndef  LIBRARIES_DOS_H
#include <libraries/dos.h>
#endif

#ifndef  LIBRARIES_DOSEXTENS_H
#include <libraries/dosextens.h>
#endif


/*--------------codes erreurs--------------*/

#define  NO_ERROR     0
#define  NO_MEMORY   -1
#define  NO_FILE     -2

/*---------------structures----------------*/

struct Pack {
   struct Message msg;
   struct MsgPort *FilsPort;
   int    cmd;
   int    id;
   UBYTE  bufread[258], *bufwrite;
   int    lenread,      lenwrite;
   int    result;
   int    reserv1, reserv2, reserv3, reserv4;
};

