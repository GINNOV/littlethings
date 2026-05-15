* DOS-2-DOS version and special messages.

	INCLUDE	"D2DMAC.ASM"

	XDEF	D2Dver.
	XDEF	CCS.

D2Dver.	DC.B	14,'Dos-2-Dos V3.2beta'
CCS.	DC.B	40,' Copyright ',$A9,' 1988 Central Coast Software'

	IFEQ	DEMO-2
	XDEF	EVAL.
EVAL.	DC.B	68,'***************  Evaluation version -- NOT FOR SALE  '
	DC.B	'***************'
	ENDC

	IFEQ	DEMO-1
	XDEF	DMO1.
	XDEF	DMO2.
	XDEF	DMO3.
	XDEF	DMO4.
	XDEF	DMO5.
	XDEF	DMO6.
DMO1.	DC.B 74,'**************************************************************************'
DMO2.	DC.B 74,'* This demonstration copy of Dos-2-Dos performs all Dos-2-Dos functions  *'
DMO3.	DC.B 74,'* except the COPY command.  You may freely duplicate and distribute this *'
DMO4.	DC.B 74,'* version.  For a full-featured version, contact your Amiga dealer, or   *'
DMO5.	DC.B 74,'* Central Coast Software, (303) 526-1030.  $55 plus $3 s/h.  VISA/MC/COD *'
DMO6.	DC.B 74,'**************************************************************************'
	ENDC

	END
