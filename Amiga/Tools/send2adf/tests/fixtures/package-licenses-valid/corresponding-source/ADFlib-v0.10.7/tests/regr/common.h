
#pragma once

#include <adf_vol.h>
#include <adf_dir.h>

void showDevInfo( struct AdfDevice * const dev );
void showVolInfo( struct AdfVolume * const vol );
void showEntryInfo( const struct AdfEntry * const  entry );

void showDirEntries( const struct AdfVolume * const  vol,
                     const ADF_SECTNUM               dirPtr );
