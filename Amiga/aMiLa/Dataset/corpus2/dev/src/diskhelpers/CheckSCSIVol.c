/****h* CheckSCSIVolPPC/CheckSCSIVol.c [1.0] ******************************
*
* NAME
*    CheckSCSIVol.c
*
* SYNOPSIS
*    int rval = CheckSCSIVolPPC envVariableName volumeName
*
* DESCRIPTION 
*    Read a SCSI Environment string & determine if the given volume is part
*    of the environment variable.  The name of each environmental
*    variable written by our companion program SetSCSIEnvPPC is as follows:
*      SCSIENV_10 (which is SCSI (UnitNumber - 1) * 10 + LUN = 10)
*    Each Environmental variable is written to ENVARC: AND ENV: by
*    SetSCSIEnvPPC
*
* RETURNS
*    5 (RETURN_WARN) if the volume name is part of the environment 
*    string.  10 (RETURN_ERROR) or 20 (RETURN_FAIL) otherwise.
*
* HISTORY
*    16-Nov-2004 - Ported to AmigaOS4 & gcc.
*
*    21-Mar-1996 - Created.
****************************************************************************
*
*/

#include <stdio.h>

#include <proto/exec.h>

#include <AmigaDOSErrs.h>

#ifdef __amigaos4__

# define __USE_INLINE__

# include <proto/dos.h>

IMPORT struct Library  *DOSBase;
IMPORT struct DOSIFace *IDOS;

PRIVATE UBYTE v[] = "\0$VER: CheckSCSIVolPPC 2.0 " __DATE__ " by J.T. Steichen";

#else

PRIVATE UBYTE v[] = "\0$VER: CheckSCSIVolPPC 2.0 " __AMIGADATE__ " by J.T. Steichen";

#endif

PRIVATE int MatchVolume( char *env, char *volume )
{
   int i, j, k;

   if (!env)
      return( RETURN_ERROR ); // Short circuit the NULL pointer!

   if (strlen( volume ) < 1)
      return( RETURN_ERROR ); // Short circuit argv[2] being wrong size.
   
   for (i = 0; env[i] != '\0'; i++)
      {
      for (j = i, k = 0; volume[k] == env[j]; k++, j++)
         {
         if (!volume[k + 1])
            return( RETURN_WARN );
	 }
      }

   return( RETURN_ERROR );
}

#ifdef __amigaos4__

# define BUFFER_SIZE  32

PRIVATE UBYTE envBuffer[ BUFFER_SIZE ] = "";

#endif

PRIVATE int MatchEnvVolume( char *envvar, char *volume )
{
   char *envstr = NULL;
   int   rval   = RETURN_OK;

#  ifndef __amigaos4__

   envstr = getenv( envvar );

#  else

   if ((rval = GetVar( envvar, envBuffer, BUFFER_SIZE, GVF_GLOBAL_ONLY )) < 1)
      {
      rval = RETURN_ERROR;
      
      goto exitMatchEnvVolume;
      }
   else
      {
      rval = RETURN_OK;

      envstr = &envBuffer[0];
      }

#  endif

   rval = MatchVolume( envstr, volume );

#  ifdef __SASC
   free( envstr );
#  endif

exitMatchEnvVolume:

   return( rval );
}

PUBLIC int main( int argc, char **argv )
{
   int  rval = RETURN_FAIL;
   
   if (argc == 3)
      rval = MatchEnvVolume( argv[1], argv[2] );

   return( rval );
}

/* ------------------- END of CheckSCSIVol.c file! ------------------- */
