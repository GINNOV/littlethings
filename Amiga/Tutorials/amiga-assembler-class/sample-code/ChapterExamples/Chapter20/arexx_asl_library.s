
        
; my reeentrant arexx_asl.library code 


	        include exec/types.i
        	include exec/libraries.i
        	include exec/initializers.i
		include exec/macros.i
        	include exec/resident.i
		include rexx/rxslib.i
		include rexx/storage.i
		include rexx/errors.i
		include libraries/asl.i
		include utility/tagitem.i
		
NULL		EQU	  0
CR		EQU	 13
LF		EQU      10
VERSION  	EQU	  1
REVISION 	EQU	  0             
PRIORITY	EQU	  0  
BUFFER_SIZEOF	EQU	256
FSTACK_SIZEOF	EQU	3*4
        
        	STRUCT	MyLibBase,LIB_SIZE
		ULONG	mlb_AslBase
		ULONG	mlb_DOSBase
        	ULONG	mlb_ExecBase
        	ULONG	mlb_SegList
        	LABEL	mlb_SIZEOF


		STRUCTURE LocalData,0
		ULONG	ld_FileRequest
		STRUCT	ld_Buffer,BUFFER_SIZEOF
		STRUCT	ld_FStack,FSTACK_SIZEOF
		LABEL	LocalData_SIZEOF
				
		
; entry block to prevent running by error...

        	moveq        #-1,d0
       	 	rts
 
resident_struct dc.w         RTC_MATCHWORD
        	dc.l         resident_struct
        	dc.l         library_end
        	dc.b         RTF_AUTOINIT
        	dc.b         VERSION
        	dc.b         NT_LIBRARY
        	dc.b         PRIORITY
        	dc.l         name		library name
        	dc.l         ID			library ID  
        	dc.l         init_table		initialisation table
                
name    	dc.b         'arexx_asl.library',NULL

ID      	dc.b         'arexx_asl 1.00 (24 May 1995)',CR,LF,NULL
       
        	ds.w         0			force word align
        
; initialisation table...

init_table   	dc.l         mlb_SIZEOF         
        	dc.l         functions		function table
        	dc.l         data_table                
        	dc.l         init_code		initialisation routine
  
        
; function table...

functions    	dc.l         open
        	dc.l         close
        	dc.l         expunge
        	dc.l         reserved
        	dc.l         query		ARexx query entry point
        	dc.l         -1			end of table
  
  
; data table in conventional macro form... 
       
data_table    	INITBYTE    LN_TYPE,NT_LIBRARY
        	INITLONG    LN_NAME,name
        	INITBYTE    LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
        	INITWORD    LIB_VERSION,VERSION
        	INITWORD    LIB_REVISION,REVISION
        	INITLONG    LIB_IDSTRING,ID
        	dc.l        0                   end of table
        
; ---------------------------------------------------------------------	

init_code    	movem.l	a5-a6,-(a7)		preserve contents	
		movea.l	d0,a5                   a5 = mylib base 
        	move.l	a6,mlb_ExecBase(a5)
        	move.l	a0,mlb_SegList(a5)

.open_asl	lea	asl_name,a1		library name
		moveq	#0,d0			any version
		JSRLIB	OpenLibrary
		move.l	d0,mlb_AslBase(a5)
		beq.s	.error_exit

.open_dos	lea	dos_name,a1		library name
		moveq	#0,d0			any version
		JSRLIB	OpenLibrary
		move.l	d0,mlb_DOSBase(a5)
		beq.s	.close_asl


.normal_exit	move.l	a5,d0			our library base in d0
		movem.l	(a7)+,a5-a6		restore registers
        	rts

.close_asl	move.l	mlb_AslBase(a5),a6
		JSRLIB	CloseLibrary
		moveq	#0,d0			indicate an error

.error_exit	movem.l	(a7)+,a5-a6		restore registers
        	rts

; ---------------------------------------------------------------------	

;Library functions follow...

open 		addq.w  #1,LIB_OPENCNT(a6)
        	bclr    #LIBB_DELEXP,LIB_FLAGS(a6)    
        	move.l  a6,d0
		rts

; ---------------------------------------------------------------------	

close   	moveq   #0,d0
        	subq.w  #1,LIB_OPENCNT(a6)
        	bne.s   .close_end
        	btst    #LIBB_DELEXP,LIB_FLAGS(a6)
        	beq.s   .close_end
        	bsr.s   expunge
.close_end      	rts

; ---------------------------------------------------------------------	

expunge 	movem.l d2/a5-a6,-(a7)
		movea.l a6,a5			a5 = my lib base        	
        	movea.l mlb_ExecBase(a5),a6
        	tst.w   LIB_OPENCNT(a5)
        	beq.s   .zero_count
        	bset    #LIBB_DELEXP,LIB_FLAGS(a5)
        	moveq   #0,d0
        	bra.s   .expunge_end
        
.zero_count      move.l	mlb_SegList(a5),d2
        	movea.l	a5,a1
        	JSRLIB	Remove

.close_libs	move.l	mlb_DOSBase(a5),a1
		JSRLIB	CloseLibrary

		move.l	mlb_AslBase(a5),a1
		JSRLIB	CloseLibrary
		
        	movea.l a5,a1
        	moveq   #0,d0
        	move.w  LIB_NEGSIZE(a5),d0
        	suba.l  d0,a1
        	add.w   LIB_POSSIZE(a5),d0
        	JSRLIB  FreeMem
        	move.l  d2,d0
.expunge_end     movem.l (a7)+,d2/a5-a6
        	rts

; ---------------------------------------------------------------------	

reserved	moveq	#0,d0
        	rts

; ---------------------------------------------------------------------	
; AllocFileReq() and FreeFileReq() 

; They expect...
; 		a5 to contain OUR library base
; 		a3 to contain the frame pointer for all local data
; 		a2 to hold my function stack pointer 

; On error this routine returns with zero flag set!

AllocFileReq	movem.l	a0/a1/a6/d0/d1,-(a7)	preserve regs
		move.l	mlb_AslBase(a5),a6	get asl library base
		moveq	#ASL_FileRequest,d0
		lea	requester_tags,a0
		JSRLIB	AllocAslRequest
		move.l	d0,ld_FileRequest(a3)	save returned pointer
		beq.s	.error
		move.l	#FreeFileReq,-(a2)	push deallocation routine address
.error		movem.l	(a7)+,a0/a1/a6/d0/d1	restore regs
		rts

FreeFileReq 	movem.l	a0/a1/a6/d0/d1,-(a7)	preserve regs
		movea.l	mlb_AslBase(a5),a6
		movea.l	ld_FileRequest(a3),a0	requester to close
		JSRLIB	FreeAslRequest
		movem.l	(a7)+,a0/a1/a6/d0/d1	restore regs
		rts

; ---------------------------------------------------------------------					
 
; Routine for querying function names. 

; On entry base of OUR library is in a6 
; Pointer to RexxMsg is in a0. 
; ARG0 field of RexxMsg is the function name! 
; a5 is used to store OUR library base
; a4 is used to hold ARexx library base (passed in argmessage)
; a3 is the frame pointer for all local data
; a2 is used to hold my function stack pointer 

query		link	a3,#-LocalData_SIZEOF
		movem.l	a2-a6,-(a7)

.setup_fstack	move.l	a3,a2			top of my fstack	
		move.l	#NULL,-(a2)		push fstack top identifier

		lea 	-LocalData_SIZEOF(a3),a3 frame pointer to bottom ?

		movea.l	a6,a5			a5 = mylib base
		movea.l	rm_LibBase(a0),a4	ARexx sys lib base
		movea.l	ARG0(a0),a0		a0 now points to argstring
		move.w  -4(a0),d0		ARG0 string length
		lea	select_file,a1
		movea.l	a4,a6
		jsr	_LVOStrcmpN(a6)
		bne.s	.error_exit

		jsr	AllocFileReq
		beq.s	.error_exit

		
		movea.l	mlb_AslBase(a5),a6
		move.w	#NULL,a1		no tag changes	
		movea.l	ld_FileRequest(a3),a0
		JSRLIB	AslRequest
		
		; should check that above call was OK!

		jsr	BuildFileName		
				
		movea.l	a4,a6			ARexx sys lib base
		lea	ld_Buffer(a3),a0	local bufer start
		jsr	_LVOStrlen(a6)
		jsr	_LVOCreateArgstring(a6)
		move.l	d0,a1			needed in a1 for ARexx		
		beq.s	.error

		BRA	.normal_exit
				 
.deallocate	move.l	(a2)+,d0		retrieve function pointer
		beq.s	.normal_exit
		move.l	d0,a0
		jsr	(a0)			and execute routine if it exists!
		bra.s	.deallocate


.normal_exit	moveq	#RC_OK,d0
		movem.l	(a7)+,a2-a6
		unlk	a3
		rts

.error		move.l	(a2)+,d0		retrieve function pointer
		beq.s	.error_exit
		move.l	d0,a0
		jsr	(a0)			and execute routine if it exists!
		bra.s	.error

.error_exit	moveq	#ERR10_001,d0   
		movem.l	(a7)+,a2-a6
		unlk	a3
        	rts 

; ---------------------------------------------------------------------					

; This routine builds the file name from asl data. 

; It expects...
; 		a5 to contain OUR library base
; 		a3 to contain the frame pointer for all local data
; 		a2 to hold my function stack pointer 

; and it destroys scratch registers!

BuildFileName	movem.l	a6/d2-d3,-(a7)		preserve registers

		; notice clear loop stops when first NULL is found)...

.clear_buffer	move.l	#BUFFER_SIZEOF-1,d0	filename buffer size less 1
		lea	ld_Buffer(a3),a0	local bufer start
.clear_loop	move.b	#NULL,(a0)+		
		tst.b	(a0)			have we reached a NULL?
		dbeq	d0,.clear_loop
				

		; now copy the ASL requester directory 
		; entry to our file name buffer...

		move.l	#BUFFER_SIZEOF-1,d0	filename buffer size less 1
		movea.l	ld_FileRequest(a3),a0	ASL requester address
		movea.l	rf_Dir(a0),a0		get start of directory entry
		lea	ld_Buffer(a3),a1	our filename buffer
.copy_loop	move.b	(a0)+,(a1)+		
		tst.b	(a0)			have we reached a NULL?
		dbeq	d0,.copy_loop
		move.b	#NULL,(a1)		write terminal NULL
		
		; finally add the filename to buffer...
		lea	ld_Buffer(a3),a0
		move.l	a0,d1			local buffer start
		movea.l	ld_FileRequest(a3),a0	ASL requester address
		move.l	rf_File(a0),d2		ASL filename entry
		move.l	#BUFFER_SIZEOF,d3	filename buffer size
		movea.l	mlb_DOSBase(a5),a6

		JSRLIB	AddPart
		
		movem.l	(a7)+,a6/d2-d3		restore registers
		rts				error exit
				
; ---------------------------------------------------------------------

requester_tags	dc.l ASLFR_TitleText,requester_text
		dc.l ASLFR_InitialLeftEdge,150
		dc.l ASLFR_InitialTopEdge,100
		dc.l ASLFR_InitialHeight,250
		dc.l ASLFR_InitialWidth,330
		dc.l TAG_DONE,NULL
		
requester_text	dc.b 'AREXX_ASL LIB - SELECT FILE',NULL

asl_name	dc.b 'asl.library',NULL

dos_name	dc.b 'dos.library',NULL

select_file	dc.b 'SELECTFILE',NULL

library_end

; ---------------------------------------------------------------------


