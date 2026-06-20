/******************************************************************************

    MODUL
	tagbase.h

    DESCRIPTION
	Fuer jedes Object, welches Tags verwendet, hier den Base-Offset
	festlegen und eine ausreichende Anzahl von Tags reservieren.


******************************************************************************/

#ifndef TAGBASE_H
#define TAGBASE_H

/***************************************
		 Defines
***************************************/
#define SYS_TagBase	    0L			    /* 500 Tags */
#define CI_TagBase	    (SYS_TagBase+500)       /* 100 Tags */
#define Monitor_TagBase     (CI_TagBase+100)        /* 500 Tags */

#define SYS_MethodBase	    0L			    /* 1000 Methods */
#define CI_MethodBase	    (SYS_MethodBase+1000)   /* 20 Methods */

#endif /* TAGBASE_H */

/******************************************************************************
*****  ENDE tagbase.h
******************************************************************************/
