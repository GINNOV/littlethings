/* Objectheader

	Name:		extheader.c
	Version:	$VER: extheader.c 1.0 (22.12.1997)
	Description:	C header for xfd externals
	Author:		SDI
	Distribution:	PD

 1.0   22.12.97 : first version
*/

#include <libraries/xfdmaster.h>

/* To make this a extern Object module it is necessary to force this
structure to be the really first stuff in the file. */

extern struct xfdSlave FirstSlave;

struct xfdForeMan ForeMan =
{0x70FF4E75, XFDF_ID, XFDF_VERSION, 0, 0, 0, &FirstSlave};

