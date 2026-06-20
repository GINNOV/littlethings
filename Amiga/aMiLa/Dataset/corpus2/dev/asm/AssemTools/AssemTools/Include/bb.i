*
* Some definitions only needed when using the A68k
*
* vers. 1.1
* 

blo		macro
		ifnc	'\0',''
		bcs.\0	\1
		endc
		ifc	'\0',''
		bcs	\1
		endc
		endm

bhs		macro
		ifnc	'\0',''
		bcc.\0	\1
		endc
		ifc	'\0',''
		bcc	\1
		endc
		endm

slo		macro
		scs	\1
		endm

shs		macro
		scc	\1
		endm

dblo		macro
		dbcs	\1,\2
		endm

dbhs		macro
		dbcc	\1,\2
		endm


