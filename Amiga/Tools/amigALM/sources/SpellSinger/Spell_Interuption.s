





***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*	      S P E L L   S I N G E R	            *
*                      =========================	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                            Interuption                                  *
*                            -----------                                  *
*                                                                         *
*                                                                         *
***************************************************************************


* by ART & MAGIC


* Coding:	Yves Grolet
* Date:	25/12/1991
* Tab:            custom






***************************************************************************



* INTERRUPTION 3
* --------------


Int3
                  movem.l	d0-d7/a0-a6,-(sp)

                  lea	Custom,C
	lea	Rel_Start+32768,D




* 25 Hz GENERAL PHASE INCREMENTATION
* ----------------------------------


	addq	#1,Gen_25hz_Phase(D)



* INTERRUPTION 3 COPPER END
* -------------------------


Int3_End
	move	#%0000000000010000,Intreq(C)
                  movem.l	(sp)+,d0-d7/a0-a6
	rte






