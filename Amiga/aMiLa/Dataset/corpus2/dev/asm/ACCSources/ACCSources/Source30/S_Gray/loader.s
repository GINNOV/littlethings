
;	           Loader  ©  STEVE GRAY
;                  ------     ----- ----

		incdir		sys:include/
		include		exec/exec_lib.i
		include		exec/exec.i
		include		libraries/dos_lib.i
		include		libraries/dos.i	
	
;--open Doslib	
		lea		dosname,a1		a1 -->lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary
		beq		error
		move.l		d0,_DOSBase
				
		bsr		Patch
		bsr		Fast
		bsr		Clock
		bsr		Font
		bsr		Map
		bsr		Logo
		bsr		Cinfo
		bsr		Cpath
		bra		error_no
;---------------------------------------------------------------------------
Patch		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#SPatch,d1		d1=addr of file
		moveq.l		#0,d2			
		move.l		d2,d3		
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		rts
;---------------------------------------------------------------------------
Fast		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#FFont,d1		d1=addr of file
		moveq.l		#0,d2		
		move.l		d2,d3
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		rts
;---------------------------------------------------------------------------
Clock		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#Time,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		rts
;---------------------------------------------------------------------------
Font		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#SFont,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		rts
;---------------------------------------------------------------------------
Map		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#KeyM,d1		d1=addr of file
		moveq.l		#0,d2			CLI input
		move.l		d2,d3			CLI output
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		rts
;---------------------------------------------------------------------------
Logo		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#Name,d1		d1=addr of file
		moveq.l		#0,d2			
		move.l		d2,d3			
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		rts
;---------------------------------------------------------------------------
Cinfo		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#RamCon,d1		d1=addr of file
		moveq.l		#0,d2		
		move.l		d2,d3			
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		rts
;---------------------------------------------------------------------------
Cpath		movem.l		d0-d7/a0-a7,-(sp)
		move.l		#Pth,d1			d1=addr of file
		moveq.l		#0,d2			
		move.l		d2,d3			
		CALLDOS		Execute			and run it		
		movem.l		(sp)+,d0-d7/a0-a7
		rts
;---------------------------------------------------------------------------
;--close dos	

error_no	move.l		_DOSBase,a1		error_no handle	
		CALLEXEC	CloseLibrary
error		rts			
					
;--DATA	
	
dosname		dc.b		'dos.library',0
_DOSBase	dc.l		0

SPatch		dc.b		'Dos:c/Setpatch -r',0
		even
FFont		dc.b		'Dos:c/FF',0
		even
Time		dc.b		'Dos:c/Setclock opt load',0
		even
SFont		dc.b		'Dos:c/Setfont pearl 8',0
		even
KeyM		dc.b		'Dos:c/Setmap Gb',0
		even
Name		dc.b		'Dos:c/Border',0
		even
RamCon		dc.b		'Dos:c/Copy ram.info ram:disk.info',0
		even
Pth		dc.b		'Dos:c/Path ram: c: sys:pdir add',0
		even
		
				