
#include <proto/intuition.h>
#include "FreeDB.h"

/***********************************************************************/

void
request(struct global *g,char *format,...)
{
    register struct EasyStruct es;

    es.es_StructSize   = sizeof(struct EasyStruct);
    es.es_TextFormat   = format;
    es.es_Title        = "FreeDB";
    es.es_GadgetFormat = "OK";

    EasyRequestArgs(NULL,&es,NULL,(APTR)(&format+1));
}

/***********************************************************************/
