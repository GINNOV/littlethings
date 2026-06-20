
*******	Routine to print an icons ImageData as a source file

; Entry		a0->DiskObject
;		pointer to filename on DStream

; Exit		None

; Corrupt	None

ImagePrint	PUSHALL
		move.l		a0,a5
		move.l		std_out,std_temp

; Bump filename and open file for writing

		addq.b		#1,ImageTmp
		move.l		#ImageTmp,d1
		move.l		#MODE_NEWFILE,d2
		CALLDOS		Open
		move.l		d0,std_out
		beq		.done

; Get pointer to Icons Image structure


		lea		do_Gadget(a5),a5	a5->icon gadget
		move.l		gg_GadgetRender(a5),a4	a4->Image struct

; Print image dimensions to file

		move.w		ig_Width(a4),DStream+4
		move.w		ig_Height(a4),DStream+6
		move.w		ig_Depth(a4),DStream+8
		lea		DetailsTmp,a0
		bsr		RDFPrint

; Dump Render Imagedata to file
		
		move.l		a4,a0
		bsr		ImDataSize
		bsr		DataPrint

; Dump Select ImageData to file

		tst.l		gg_SelectRender(a5)
		beq.s		.NoSelect
		
		lea		SelectText,a0
		bsr		DOSPrint
		move.l		gg_SelectRender(a5),a0
		bsr		ImDataSize
		bsr		DataPrint
		
; Close the file

.NoSelect	move.l		std_out,d1
		CALLDOS		Close
		
.done		move.l		std_temp,std_out
		PULLALL
		rts

std_temp	dc.l		0
old_dir		dc.l		0

ImageTmp	dc.b		'A'-1,'_ImageData.s',0
		even

DetailsTmp	dc.b		'; DumpIcon data file. Programmed by M.Meany',$0a
		dc.b		'; Icon ImageData for file "%s"',$0a,$0a
		dc.b		'; Width  =%d',$0a
		dc.b		'; Height =%d',$0a
		dc.b		'; Depth  =%d',$0a,$0a
		dc.b		';Render ImageData',$0a,$0a
		dc.b		'IconImageData',$0a,0
		even

SelectText	dc.b		$0a,'; Select ImageData',$0a,$0a,0
		even
*******	Returns pointer to ImageData and number of words of data

; Entry		a0->Image Structure

; Exit		a0->ImageData
;		d1=number of words in image

; Corrupt	d1,d0,a0

ImDataSize	moveq.l		#0,d1
		move.w		ig_Width(a0),d1
		moveq.l		#0,d0
		ror.l		#4,d1
		move.w		d1,d0
		swap		d1
		tst.w		d1
		beq.s		.Multiple
		addq.w		#1,d0

.Multiple	moveq.l		#0,d1
		move.w		ig_Height(a0),d1
		mulu		d1,d0
		
		move.w		ig_Depth(a0),d1
		mulu		d1,d0
		
		move.l		ig_ImageData(a0),a0
		rts
		
*******	Subroutine to print data from memory as dc.w statements to a file

; Entry		a0->Start of data
;		d0=number of words to save
;		std_out=file handle to save to

; Exit		same

; Corrupt	none

DataPrint	movem.l		d0-d7/a0-a6,-(sp)

		move.l		a0,a5
		move.l		d0,d5

.Loop		cmp.l		#8,d5
		blt		.LastLine
		
		lea		.Temp,a0		template
		move.l		a5,a1			data stream
		lea		.PutC,a2		PutChar routine
		lea		.Buffer,a3		buffer
		CALLEXEC	RawDoFmt		generate Text
		
		lea		.Buffer,a0		a0->text
		bsr		DOSPrint		print it to file

		addq.l		#8,a5			bump pointer
		addq.l		#8,a5
		subq.l		#8,d5			dec counter
		beq		.AllDone		exit if no data left
		bra		.Loop			else loop

.LastLine	move.l		d5,d0
		subq.w		#1,d0
		mulu		#6,d0
		add.w		#11,d0
		lea		.Temp,a4
		add.l		d0,a4
		move.b		#$0a,(a4)
		move.b		#0,1(a4)
		
		lea		.Temp,a0		template
		move.l		a5,a1			data stream
		lea		.PutC,a2		PutChar routine
		lea		.Buffer,a3		buffer
		CALLEXEC	RawDoFmt		generate Text
		
		lea		.Buffer,a0		a0->text
		bsr		DOSPrint		print it to file
		
		move.b		#',',(a4)		restore
		move.b		#'$',1(a4)		template
		
.AllDone	movem.l		(sp)+,d0-d7/a0-a6
		rts

.PutC		move.b		d0,(a3)+
		rts

.Temp	dc.b	$09,'dc.w',$09
	dc.b	'$%04x,$%04x,$%04x,$%04x,$%04x,$%04x,$%04x,$%04x',$0a,0
	even

.Buffer dc.b	' dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$00',0
	 even

	
	

