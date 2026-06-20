 ifnd RESOURCES_MISC_I
RESOURCES_MISC_I set 1
*
*  resources/misc.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd EXEC_LIBRARIES_I
 include "exec/libraries.i"
 endc


MR_SERIALPORT	= 0
MR_SERIALBITS	= 1
MR_PARALLELPORT = 2
MR_PARALLELBITS = 3

 LIBINIT LIB_BASE
 LIBDEF  MR_ALLOCMISCRESOURCE
 LIBDEF  MR_FREEMISCRESOURCE

MISCNAME macro
 dc.b "misc.resource",0
 endm

 endc
