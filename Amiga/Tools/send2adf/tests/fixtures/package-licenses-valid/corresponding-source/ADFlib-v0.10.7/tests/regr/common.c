
#include "common.h"

#include "log.h"

#include <adflib.h>
#include <stdio.h>
#include <stdlib.h>


static inline void showInfo( char * const info )
{
    log_info( "%s", info );
    free( info );
}

void showDevInfo( struct AdfDevice * const dev )
{
    showInfo( adfDevGetInfo( dev ) );
}

void showVolInfo( struct AdfVolume * const vol )
{
    showInfo( adfVolGetInfo( vol ) );
}

void showEntryInfo( const struct AdfEntry * const  entry )
{
    showInfo( adfEntryGetInfo( entry ) );
}



void showDirEntries( const struct AdfVolume * const  vol,
                     const ADF_SECTNUM               dirPtr )
{
    struct AdfList *list, *cell;

    cell = list = adfGetDirEnt( vol, dirPtr );
    while ( cell ) {
        showEntryInfo( cell->content );
        cell = cell->next;
    }
    adfFreeDirList( list );
}

/* version 2 - without using adfFreeDirList */
/*
void showDirEntries2( const struct AdfVolume * const  vol,
                      const ADF_SECTNUM               dirPtr )
{
    struct AdfList *list, *cell;

    cell = list = adfGetDirEnt( vol, vol->curDirPtr );
    while ( cell ) {
        showEntryInfo( cell->content );
        adfFreeEntry( cell->content );
        cell = cell->next;
    }
    adfListFree( list );
}
*/
