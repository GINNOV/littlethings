		opt	a-,c-,d-,l+,ow-,p-,x-

* ---------------------------------------------------------------------------
* -----                        FileSelect V2.0                          -----
* -----                     ~~~~~~~~~~~~~~~~~~~~~                       -----
* ----- (c), (w) by André Wichmann of CLUSTER 01/09/1990 - 29/09/1990.  -----
* ---------------------------------------------------------------------------

*
* Either use blink to link 'FileSelect.o' to your program or append this
* source at the end of your source and delete the include-lines.
* If you want to change something, use the 'l+' option to make it linkable.
* You may change the incdir-line 'df0:source/' to the path where the
* 'FileSelect.i'-file is.
* Please link this section to CHIPMEM because it includes two images which
* have to be in CHIPMEM (Just do not change the 'SECTION'-line).
*

		incdir	ram:include/,df0:source/
		include	exec/exec_lib.i
		include	exec/memory.i
		include	intuition/intuition_lib.i
		include	intuition/intuition.i
		include	intuition/intuitionbase.i
		include	graphics/graphics_lib.i
		include	libraries/dos_lib.i
		include	libraries/dos.i
		include	libraries/dosextens.i

		include	FileSelect.i

		XDEF	FileSelect
		XREF	_IntuitionBase,_GfxBase,_DOSBase

		SECTION	"FileSelect_V2",CODE_C

* FileSelect start

FileSelect	movem.l	d2-d7/a2-a6,-(sp)
		lea	.Window(pc),a1
		move.w	NFS2_LeftEdge(a0),d0
		cmp.w	#NFS2_CENTREPOS,d0
		bne.s	.No_CentreX
		move.w	#160,d0
.No_CentreX	move.w	d0,nw_LeftEdge(a1)
		move.w	d0,.MDWindow+nw_LeftEdge
		move.w	d0,.RFWindow+nw_LeftEdge
		move.w	d0,.DELWindow+nw_LeftEdge
		move.w	NFS2_TopEdge(a0),d0
		cmp.w	#NFS2_CENTREPOS,d0
		bne.s	.No_CentreY
		move.w	#16,d0
.No_CentreY	move.w	d0,nw_TopEdge(a1)
		add.w	#40,d0
		move.w	d0,.MDWindow+nw_TopEdge
		move.w	d0,.RFWindow+nw_TopEdge
		move.w	d0,.DELWindow+nw_TopEdge
		cmp.l	#NFS2_DEFAULTTITLE,NFS2_WindowTitle(a0)
		beq.s	.DefaultTitle
		move.l	NFS2_WindowTitle(a0),nw_Title(a1)
.DefaultTitle	move.l	NFS2_Screenptr(a0),d0
		cmp.l	#NFS2_ACTIVESCREEN,d0
		bne.s	.OwnScreen
		move.l	_IntuitionBase,a2
		move.l	ib_ActiveScreen(a2),d0
.OwnScreen	move.l	d0,nw_Screen(a1)
		move.l	d0,.MDWindow+nw_Screen
		move.l	d0,.RFWindow+nw_Screen
		move.l	d0,.DELWindow+nw_Screen
		cmp.l	#NFS2_NODEFAULT,NFS2_DefaultPath(a0)
		beq.s	.NoDefPath
		move.l	NFS2_DefaultPath(a0),a1
		lea	.Path(pc),a2
.CopyDefPath	move.b	(a1)+,(a2)+
		cmp.b	#0,-1(a2)
		bne.s	.CopyDefPath
.NoDefPath	cmp.l	#NFS2_NODEFAULT,NFS2_DefaultFile(a0)
		beq.s	.NoDefFile
		move.l	NFS2_DefaultFile(a0),a1
		lea	.File(pc),a2
.CopyDefFile	move.b	(a1)+,(a2)+
		cmp.b	#0,-1(a2)
		bne.s	.CopyDefFile
.NoDefFile	move.b	NFS2_BackPen(a0),d0
		cmp.b	#NFS2_DEFAULTPEN,d0
		bne.s	.NoDefBackPen
		move.b	#1,d0
.NoDefBackPen	move.b	d0,.text0+1
		move.b	d0,.text12+1
		move.b	d0,.text13+1
		move.b	d0,.text14+1
		move.b	d0,.text15+1
		move.b	d0,.text16+1
		move.b	d0,.text17+1
		move.b	d0,.text18+1
		ext.w	d0
		ext.l	d0
		move.l	d0,.BackPen
		move.b	NFS2_FilePen(a0),d0
		cmp.b	#NFS2_DEFAULTPEN,d0
		bne.s	.NoDefFilePen
		move.b	#2,d0
.NoDefFilePen	ext.w	d0
		ext.l	d0
		move.l	d0,.FilePen
		move.b	NFS2_DirPen(a0),d0
		cmp.b	#NFS2_DEFAULTPEN,d0
		bne.s	.NoDefDirPen
		move.b	#3,d0
.NoDefDirPen	ext.w	d0
		ext.l	d0
		move.l	d0,.DirPen
		move.b	NFS2_GadgetPen(a0),d0
		cmp.b	#NFS2_DEFAULTPEN,d0
		bne.s	.NoDefGadPen
		move.b	#2,d0
.NoDefGadPen	move.b	d0,.text0
		move.b	d0,.border0+4
		move.b	d0,.text12
		move.b	d0,.border12+4
		move.b	d0,.text13
		move.b	d0,.border13+4
		move.b	d0,.text14
		move.b	d0,.text15
		move.b	d0,.text16
		move.b	d0,.text17
		move.b	d0,.text18
		ext.w	d0
		ext.l	d0
		move.l	d0,.GadgetPen
		move.w	NFS2_GadgetFlags(a0),.gadgetflags
		move.l	NFS2_FirstFilter(a0),.FirstFilter
		lea	.Window(pc),a0
		CALLINT OpenWindow
		tst.l	d0
		bne.s	.NoError_1
		movem.l	(sp)+,d2-d7/a2-a6
		lea	.Answerstruct(pc),a0
		move.w	#FS2_WINDOWERR,FS2_Status(a0)
		move.l	#FS2_NOPATH,FS2_Path(a0)
		move.l	#FS2_NOFILE,FS2_File(a0)
		move.l	#FS2_NOFULLNAME,FS2_FullName(a0)
		move.l	a0,d0
		rts
.NoError_1	move.l	d0,.Windowptr
		move.l	d0,a0
		move.l	wd_RPort(a0),.rp

* Ausfüllen

		move.l	.rp,a1
		move.l	.GadgetPen,d0
		CALLGRAF SetAPen
		move.l	#0,d0
		move.l	#10,d1
		move.l	#319,d2
		move.l	#167,d3
		CALLGRAF RectFill
		move.l	.rp,a1
		move.l	.Backpen(pc),d0
		CALLGRAF SetAPen
		move.l	#1,d0
		move.l	#11,d1
		move.l	#318,d2
		move.l	#166,d3
		CALLGRAF RectFill
		move.l	.rp(pc),a1
		move.l	.GadgetPen,d0
		CALLGRAF SetAPen
		move.l	#0,d0
		move.l	#25,d1
		CALLGRAF Move
		move.l	#319,d0
		move.l	#25,d1
		CALLGRAF Draw
		move.l	.rp(pc),a1
		move.l	#0,d0
		move.l	#108,d1
		CALLGRAF Move
		move.l	#319,d0
		move.l	#108,d1
		CALLGRAF Draw
		lea	.gadget0(pc),a0
		move.l	.Windowptr(pc),a1
		sub.l	a2,a2
		CALLINT RefreshGadgets

* Gadgets an/aus

		lea	.gadget16(pc),a0
		move.l	.Windowptr(pc),a1
		sub.l	a2,a2
		CALLINT OnGadget
		move.w	.GadgetFlags,d0
		and.l	#NFS2_MAKEDIR,d0
		bne.s	.MakedirOn
		lea	.gadget16(pc),a0
		move.l	.Windowptr(pc),a1
		sub.l	a2,a2
		CALLINT OffGadget
.MakedirOn	lea	.gadget17(pc),a0
		move.l	.Windowptr(pc),a1
		sub.l	a2,a2
		CALLINT OnGadget
		move.w	.GadgetFlags,d0
		and.l	#NFS2_DELETE,d0
		bne.s	.DeleteOn
		lea	.gadget17(pc),a0
		move.l	.Windowptr(pc),a1
		sub.l	a2,a2
		CALLINT OffGadget
.DeleteOn	lea	.gadget18(pc),a0
		move.l	.Windowptr(pc),a1
		sub.l	a2,a2
		CALLINT OnGadget
		move.w	.GadgetFlags,d0
		and.l	#NFS2_RENAME,d0
		bne.s	.RenameOn
		lea	.gadget18(pc),a0
		move.l	.Windowptr(pc),a1
		sub.l	a2,a2
		CALLINT OffGadget
.RenameOn	move.l	.rp(pc),a1
		move.l	.Backpen(pc),d0
		CALLGRAF SetBPen

* Hauptschleife

.ReadPath	tst.l	.Lock
		beq.s	.NoFreeLock
		move.l	.Lock(pc),d1
		CALLDOS UnLock
.NoFreeLock	bsr	.FreeMem
		move.l	#0,.Files
		move.l	#0,.StartPrint
		bsr	.PrintFiles
		bsr	.CorrectProp
		clr.l	.ChangeFlag
		lea	.Path(pc),a0
		move.l	a0,d1
		move.l	#ACCESS_READ,d2
		CALLDOS Lock
		tst.l	d0
		beq	.Bad_Path
		move.l	d0,.Lock
		move.l	.Lock(pc),d1
		lea	.fib(pc),a0
		move.l	a0,d2
		CALLDOS Examine
		lea	.Mem(pc),a5
.ReadLoop	move.l	.Lock(pc),d1
		lea	.fib(pc),a0
		move.l	a0,d2
		CALLDOS ExNext
		tst.l	d0
		beq	.EndRead
		cmp.l	#NFS2_NOFILTER,.FirstFilter
		beq.s	.GetIt
		lea	.fib(pc),a0
		lea	fib_FileName(a0),a0
		move.l	.FirstFilter(pc),a1
		clr.l	d2
.CheckLength	cmp.b	#0,(a0)
		beq.s	.GotLength
		addq.l	#1,d2
		addq.l	#1,a0
		bra.s	.CheckLength
.GotLength
.CheckFilters	move.b	FS2F_FilterLength(a1),d1
		cmp.b	d1,d2
		blt.s	.NextFilter
		move.l	a0,a2
		move.l	FS2F_Filter(a1),a3
		ext.w	d1
		ext.l	d1
		sub.l	d1,a2
		subq	#1,d1
.CmpFilter	move.b	(a2)+,d0
		bsr	.Upcase
		move.b	d0,d3
		move.b	(a3)+,d0
		bsr	.Upcase
		cmp.b	d0,d3
		bne.s	.NextFilter
		dbra	d1,.CmpFilter
		bra.s	.EndOfEx
.NextFilter	move.l	FS2F_NextFilter(a1),a1
		cmp.l	#FS2F_LastFilter,a1
		bne.s	.CheckFilters
.GetIt		move.l	#42,d0
		move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
		CALLEXEC AllocMem
		tst.l	d0
		beq	.Wait_event
		addq.l	#1,.Files
		move.l	#1,.ChangeFlag
		move.l	d0,(a5)
		move.l	d0,a5
		lea	4(a5),a1
		lea	.fib+fib_FileName(pc),a2
.CopyFileName	cmp.b	#0,(a2)
		beq.s	.EndCopyFName
		move.b	(a2)+,(a1)+
		bra.s	.CopyFileName
.EndCopyFName	move.l	.fib+fib_Size(pc),38(a5)
		tst.l	.fib+fib_DirEntryType
		bmi.s	.fibFile
		move.b	#1,37(a5)
.fibFile	bsr	.PrintFiles
		bsr	.CorrectProp
.EndOfEx	move.l	.Windowptr(pc),a0
		move.l	wd_UserPort(a0),a0
		CALLEXEC GetMsg
		tst.l	d0
		beq	.ReadLoop
		move.l	d0,a1
		move.l	im_Class(a1),d6
		move.l	im_IAddress(a1),a4
		CALLEXEC ReplyMsg
		cmp.l	#GADGETUP,d6
		beq.s	.DoGadget1
		cmp.l	#GADGETDOWN,d6
		beq.s	.DoGadget1
		move.l	.Lock,d1
		CALLDOS UnLock
		move.l	#0,.Lock
		bra	.Devices

.DoGadget1	move.w	gg_GadgetID(a4),d0
		cmp.w	#0,d0
		beq	.ReadPath
		cmp.w	#8,d0
		ble.s	.R_File
		cmp.w	#9,d0
		beq.s	.R_prop
		cmp.w	#10,d0
		beq.s	.R_Up
		cmp.w	#11,d0
		beq.s	.R_Down
		cmp.w	#12,d0
		beq.s	.R_Okay
		cmp.w	#13,d0
		beq.s	.R_Okay
		cmp.w	#14,d0
		beq.s	.R_Parent
		cmp.w	#15,d0
		beq.s	.R_Cancel
		cmp.w	#16,d0
		beq	.R_Makedir
		cmp.w	#17,d0
		beq	.R_Delete
		cmp.w	#18,d0
		beq	.R_Rename
		bra	.ReadLoop

.R_File		bsr	.FileGadget
		cmp.b	#1,d0
		beq	.ReadLoop
		cmp.b	#2,d0
		beq	.End
		bra	.ReadPath
.R_prop		bsr	.sort
		bsr	.prop
		bra	.ReadLoop
.R_Up		bsr	.sort
		bsr	.up
		bra	.ReadLoop
.R_Down		bsr	.sort
		bsr	.down
		bra	.ReadLoop
.R_Okay		move.l	.Lock,d1
		CALLDOS UnLock
		move.l	#0,.Lock
		bra	.Okay
.R_Parent	bsr	.Parent
		bra	.ReadPath
.R_Cancel	move.l	.Lock,d1
		CALLDOS UnLock
		move.l	#0,.Lock
		bra	.Cancel
.R_Makedir	move.l	.Lock,d1
		CALLDOS UnLock
		move.l	#0,.Lock
		bsr	.Makedir
		bra	.ReadPath
.R_Delete	move.l	.Lock,d1
		CALLDOS UnLock
		move.l	#0,.Lock
		bsr	.Delete
		bra	.ReadPath
.R_Rename	move.l	.Lock,d1
		CALLDOS UnLock
		move.l	#0,.Lock
		bsr	.Rename
		bra	.ReadPath

.EndRead	move.l	.Lock,d1
		CALLDOS UnLock
		move.l	#0,.Lock

.Wait_event	move.l	.Windowptr(pc),a0
		move.l	wd_UserPort(a0),a0
		CALLEXEC GetMsg
		tst.l	d0
		beq.s	.Wait_event
		move.l	d0,a1
		move.l	im_Class(a1),d6
		move.l	im_IAddress(a1),a4
		CALLEXEC ReplyMsg
		cmp.l	#GADGETUP,d6
		beq.s	.DoGadget2
		cmp.l	#GADGETDOWN,d6
		beq.s	.DoGadget2
		bra	.Devices

.DoGadget2	move.w	gg_GadgetID(a4),d0
		cmp.w	#0,d0
		beq	.ReadPath
		cmp.w	#8,d0
		ble.s	.E_File
		cmp.w	#9,d0
		beq.s	.E_prop
		cmp.w	#10,d0
		beq.s	.E_Up
		cmp.w	#11,d0
		beq.s	.E_Down
		cmp.w	#12,d0
		beq.s	.E_Okay
		cmp.w	#13,d0
		beq.s	.E_Okay
		cmp.w	#14,d0
		beq.s	.E_Parent
		cmp.w	#15,d0
		beq.s	.E_Cancel
		cmp.w	#16,d0
		beq.s	.E_Makedir
		cmp.w	#17,d0
		beq.s	.E_Delete
		cmp.w	#18,d0
		beq.s	.E_Rename
		bra	.Wait_event

.E_File		bsr	.FileGadget
		cmp.b	#1,d0
		beq	.Wait_event
		cmp.b	#2,d0
		beq	.End
		bra	.ReadPath
.E_prop		bsr	.sort
		bsr	.prop
		bra	.Wait_event
.E_Up		bsr	.sort
		bsr	.up
		bra	.Wait_event
.E_Down		bsr	.sort
		bsr	.down
		bra	.Wait_event
.E_Okay		bra	.Okay
.E_Parent	bsr	.Parent
		bra	.ReadPath
.E_Cancel	bra	.Cancel
.E_Makedir	bsr	.Makedir
		bra	.ReadPath
.E_Delete	bsr	.Delete
		bra	.ReadPath
.E_Rename	bsr	.Rename
		bra	.ReadPath

.Bad_Path	move.l	.rp(pc),a1
		move.l	.Backpen(pc),d0
		CALLGRAF SetBPen
		move.l	.GadgetPen,d0
		CALLGRAF SetAPen
		move.l	#126,d0
		move.l	#64,d1
		CALLGRAF Move
		lea	.BadPath_text(pc),a0
		move.l	#10,d0
		CALLGRAF Text
		bra	.Wait_event

* Ende

.end		bsr	.FreeMem
		move.l	.Windowptr(pc),a0
		CALLINT CloseWindow
		movem.l	(sp)+,d2-d7/a2-a6
		lea	.Answerstruct(pc),a0
		move.l	a0,d0
		rts

* subroutines

.FileGadget	ext.l	d0
		subq.l	#1,d0
		add.l	.StartPrint(pc),d0
		cmp.l	.Files,d0
		blt.s	.FileOkay
		moveq	#1,d0
		rts
.FileOkay	move.l	.Mem(pc),a0
		tst.l	d0
		beq.s	.NoSkip_2
		subq.l	#1,d0
.Skip_2		move.l	(a0),a0
		dbra	d0,.Skip_2
.NoSkip_2	cmp.b	#0,37(a0)
		bne.s	.NoFile_2
		lea	.File(pc),a1
		lea	4(a0),a0
		move.b	#1,d2
.CopyFName_2	move.b	(a0),d0
		cmp.b	(a1),d0
		beq.s	.Equal
		move.b	#0,d2
.Equal		move.b	(a0)+,(a1)+
		cmp.b	#0,-1(a1)
		bne.s	.CopyFName_2
		lea	.gadget0(pc),a0
		move.l	.Windowptr(pc),a1
		sub.l	a2,a2
		CALLINT RefreshGadgets
		moveq	#1,d0
		add.b	d2,d0
		rts
.NoFile_2	cmp.b	#1,37(a0)
		bne.s	.NoDir_2
		lea	.Path(pc),a1
.Search_Zero	cmp.b	#0,(a1)+
		bne.s	.Search_Zero
		subq.l	#1,a1
		cmp.b	#"/",-1(a1)
		beq.s	.No_Pathline
		cmp.b	#":",-1(a1)
		beq.s	.No_Pathline
		move.b	#"/",(a1)+
.No_Pathline	lea	4(a0),a0
.CopyDName_2	move.b	(a0)+,(a1)+
		cmp.b	#0,-1(a1)
		bne.s	.CopyDName_2
		lea	.gadget0(pc),a0
		move.l	.Windowptr(pc),a1
		sub.l	a2,a2
		CALLINT RefreshGadgets
		moveq	#0,d0
		rts
.NoDir_2	lea	.Path(pc),a1
		lea	4(a0),a0
.CopyDevName_2	move.b	(a0)+,(a1)+
		cmp.b	#0,-1(a1)
		bne.s	.CopyDevName_2
		lea	.gadget0(pc),a0
		move.l	.Windowptr(pc),a1
		sub.l	a2,a2
		CALLINT RefreshGadgets
		moveq	#0,d0
		rts

.prop		cmp.l	#8,.Files
		ble.s	.NoRefresh
		lea	.Special9(pc),a0
		clr.l	d0
		clr.l	d1
		move.w	4(a0),d0
		move.l	.Files(pc),d1
		sub.l	#8,d1
		mulu	d1,d0
		divu	#$ffff,d0
		and.l	#$ffff,d0
		move.l	d0,.StartPrint
		bsr	.PrintFiles
		move.l	.Windowptr(pc),a0
		move.l	wd_UserPort(a0),a0
		CALLEXEC GetMsg
		tst.l	d0
		beq.s	.prop
		move.l	d0,a1
		CALLEXEC ReplyMsg
.NoRefresh	rts

.up		cmp.l	#8,.Files
		bls.s	.NoRefresh
		tst.l	.StartPrint
		beq.s	.NoRefresh
		subq.l	#1,.StartPrint
		bsr	.CorrectProp
		bsr	.PrintFiles
		move.l	.Windowptr(pc),a0
		move.l	wd_UserPort(a0),a0
		CALLEXEC GetMsg
		tst.l	d0
		beq.s	.up
		move.l	d0,a1
		CALLEXEC ReplyMsg
		rts

.down		cmp.l	#8,.Files
		bls.s	.NoRefresh
		move.l	.StartPrint,d0
		add.l	#8,d0
		move.l	.Files,d1
		cmp.l	d0,d1
		beq.s	.NoRefresh
		addq.l	#1,.StartPrint
		bsr	.CorrectProp
		bsr	.PrintFiles
		move.l	.Windowptr(pc),a0
		move.l	wd_UserPort(a0),a0
		CALLEXEC GetMsg
		tst.l	d0
		beq.s	.down
		move.l	d0,a1
		CALLEXEC ReplyMsg
		rts

.Okay		lea	.AnswerStruct(pc),a0
		move.w	#FS2_OKAY,FS2_Status(a0)
		lea	.Path(pc),a1
		move.l	a1,FS2_Path(a0)
		lea	.File(pc),a1
		move.l	a1,FS2_File(a0)
		lea	.FullName(pc),a2
		move.l	FS2_Path(a0),a1
		move.l	a1,a3
.CreatePath	cmp.b	#0,(a1)
		beq.s	.PathMade
		move.b	(a1)+,(a2)+
		bra.s	.CreatePath
.PathMade	cmp.l	a3,a1
		beq.s	.NoPathline
		cmp.b	#"/",-1(a2)
		beq.s	.NoPathline
		cmp.b	#":",-1(a2)
		beq.s	.NoPathline
		move.b	#"/",(a2)+
.NoPathline	move.l	FS2_File(a0),a1
.CreatePath_2	cmp.b	#0,(a1)
		beq.s	.PathMade_2
		move.b	(a1)+,(a2)+
		bra.s	.CreatePath_2
.PathMade_2	lea	.FullName(pc),a1
		move.l	a1,FS2_FullName(a0)
		bra	.End

.Parent		lea	.Path(pc),a0
.GetEnd		cmp.b	#0,(a0)
		beq.s	.GotEnd
		addq.l	#1,a0
		bra.s	.GetEnd
.GotEnd		lea	.Path(pc),a1
.SearchCD	cmp.l	a0,a1
		beq.s	.CDReturn
		cmp.b	#"/",(a0)
		beq.s	.FoundCD
		cmp.b	#":",(a0)
		beq.s	.Found2P
		subq.l	#1,a0
		bra.s	.SearchCD
.FoundCD	move.b	#0,(a0)
		bra.s	.CDReturn
.Found2P	move.b	#0,1(a0)
.CDReturn	lea	.gadget0(pc),a0
		move.l	.Windowptr(pc),a1
		sub.l	a2,a2
		CALLINT RefreshGadgets
		rts

.Cancel		lea	.AnswerStruct(pc),a0
		move.w	#FS2_CANCEL,FS2_Status(a0)
		move.l	#FS2_NOPATH,FS2_Path(a0)
		move.l	#FS2_NOFILE,FS2_File(a0)
		move.l	#FS2_NOFULLNAME,FS2_FullName(a0)
		bra	.End

.Makedir	lea	.Path(pc),a0
		lea	.MDPath(pc),a1
.CopyMDPath	move.b	(a0)+,(a1)+
		cmp.b	#0,-1(a1)
		bne.s	.CopyMDPath
		lea	.MDWindow(pc),a0
		CALLINT	OpenWindow
		tst.l	d0
		beq	.MDError
		move.l	d0,.Windowptr_2
		move.l	d0,a0
		move.l	wd_RPort(a0),.rp_2
		move.l	.rp_2,a1
		move.l	.GadgetPen(pc),d0
		CALLGRAF SetAPen
		move.l	.rp_2(pc),a1
		move.l	#0,d0
		move.l	#0,d1
		move.l	#319,d2
		move.l	#47,d3
		CALLGRAF RectFill
		move.l	.rp_2(pc),a1
		move.l	.BackPen(pc),d0
		CALLGRAF SetAPen
		move.l	.rp_2(pc),a1
		move.l	#1,d0
		move.l	#1,d1
		move.l	#318,d2
		move.l	#46,d3
		CALLGRAF RectFill
		move.l	.rp_2(pc),a1
		move.l	.GadgetPen(pc),d0
		CALLGRAF SetAPen
		move.l	.rp_2(pc),a1
		move.l	.BackPen(pc),d0
		CALLGRAF SetBPen
		move.l	.rp_2(pc),a1
		move.l	#88,d0
		move.l	#10,d1
		CALLGRAF Move
		lea	.MDText(pc),a0
		move.l	#18,d0
		CALLGRAF Text
		lea	.MDGadget0(pc),a0
		move.l	.Windowptr_2(pc),a1
		sub.l	a2,a2
		CALLINT RefreshGadgets
		lea	.MDGadget0(pc),a0
		move.l	.Windowptr_2(pc),a1
		sub.l	a2,a2
		CALLINT ActivateGadget

		bsr	.Event
		move.w	gg_GadgetID(a4),d0
		cmp.w	#2,d0
		beq.s	.NoMD
		move.l	#.MDPath,d1
		CALLDOS CreateDir
		tst.l	d0
		beq.s	.NoMD
		move.l	d0,d1
		CALLDOS UnLock

.NoMD		move.l	.Windowptr_2(pc),a0
		CALLINT CloseWindow
.MDError	rts

.Delete		lea	.DELWindow(pc),a0
		CALLINT	OpenWindow
		tst.l	d0
		beq	.DELError
		move.l	d0,.Windowptr_2
		move.l	d0,a0
		move.l	wd_RPort(a0),.rp_2
		move.l	.rp_2,a1
		move.l	.GadgetPen(pc),d0
		CALLGRAF SetAPen
		move.l	.rp_2(pc),a1
		move.l	#0,d0
		move.l	#0,d1
		move.l	#319,d2
		move.l	#35,d3
		CALLGRAF RectFill
		move.l	.rp_2(pc),a1
		move.l	.BackPen(pc),d0
		CALLGRAF SetAPen
		move.l	.rp_2(pc),a1
		move.l	#1,d0
		move.l	#1,d1
		move.l	#318,d2
		move.l	#34,d3
		CALLGRAF RectFill
		move.l	.rp_2(pc),a1
		move.l	.GadgetPen(pc),d0
		CALLGRAF SetAPen
		move.l	.rp_2(pc),a1
		move.l	.BackPen(pc),d0
		CALLGRAF SetBPen
		move.l	.rp_2(pc),a1
		move.l	#104,d0
		move.l	#10,d1
		CALLGRAF Move
		lea	.DELText(pc),a0
		move.l	#14,d0
		CALLGRAF Text
		lea	.DELGadget0(pc),a0
		move.l	.Windowptr_2(pc),a1
		sub.l	a2,a2
		CALLINT RefreshGadgets

		bsr	.Event
		move.w	gg_GadgetID(a4),d0
		cmp.w	#1,d0
		beq.s	.NoDEL
		lea	.Path(pc),a0
		lea	.RFPath(pc),a1
		move.l	a1,a2
.CopyDELPath	move.b	(a0)+,(a1)+
		cmp.b	#0,-1(a1)
		bne.s	.CopyDELPath
		subq.l	#1,a1
		cmp.l	a1,a2
		beq.s	.DELNoCD
		cmp.b	#"/",-1(a1)
		beq.s	.DELNoCD
		cmp.b	#":",-1(a1)
		beq.s	.DELNoCD
		move.b	#"/",(a1)+
.DELNoCD	lea	.File(pc),a0
		cmp.b	#0,(a0)
		bne.s	.CopyDELName
		cmp.b	#"/",-1(a1)
		bne.s	.CopyDELName
		subq.l	#1,a1
.CopyDELName	move.b	(a0)+,(a1)+
		cmp.b	#0,-1(a1)
		bne.s	.CopyDELName
		move.l	#.RFPath,d1
		CALLDOS DeleteFile

.NoDEL		move.l	.Windowptr_2(pc),a0
		CALLINT CloseWindow
.DELError	rts

.Rename		lea	.Path(pc),a0
		lea	.RFPath(pc),a1
		move.l	a1,a2
.CopyRFPath	move.b	(a0)+,(a1)+
		cmp.b	#0,-1(a1)
		bne.s	.CopyRFPath
		subq.l	#1,a1
		cmp.l	a1,a2
		beq.s	.RFNoCD
		cmp.b	#"/",-1(a1)
		beq.s	.RFNoCD
		cmp.b	#":",-1(a1)
		beq.s	.RFNoCD
		move.b	#"/",(a1)+
.RFNoCD		lea	.File(pc),a0
		cmp.b	#0,(a0)
		beq	.RFError
.CopyRFName	move.b	(a0)+,(a1)+
		cmp.b	#0,-1(a1)
		bne.s	.CopyRFName
		lea	.RFPath(pc),a0
		lea	.FullName(pc),a1
.SaveOldName	move.b	(a0)+,(a1)+
		cmp.b	#0,-1(a1)
		bne.s	.SaveOldName
		lea	.RFWindow(pc),a0
		CALLINT	OpenWindow
		tst.l	d0
		beq	.RFError
		move.l	d0,.Windowptr_2
		move.l	d0,a0
		move.l	wd_RPort(a0),.rp_2
		move.l	.rp_2,a1
		move.l	.GadgetPen(pc),d0
		CALLGRAF SetAPen
		move.l	.rp_2(pc),a1
		move.l	#0,d0
		move.l	#0,d1
		move.l	#319,d2
		move.l	#47,d3
		CALLGRAF RectFill
		move.l	.rp_2(pc),a1
		move.l	.BackPen(pc),d0
		CALLGRAF SetAPen
		move.l	.rp_2(pc),a1
		move.l	#1,d0
		move.l	#1,d1
		move.l	#318,d2
		move.l	#46,d3
		CALLGRAF RectFill
		move.l	.rp_2(pc),a1
		move.l	.GadgetPen(pc),d0
		CALLGRAF SetAPen
		move.l	.rp_2(pc),a1
		move.l	.BackPen(pc),d0
		CALLGRAF SetBPen
		move.l	.rp_2(pc),a1
		move.l	#72,d0
		move.l	#10,d1
		CALLGRAF Move
		lea	.RFText(pc),a0
		move.l	#22,d0
		CALLGRAF Text
		lea	.RFGadget0(pc),a0
		move.l	.Windowptr_2(pc),a1
		sub.l	a2,a2
		CALLINT RefreshGadgets
		lea	.RFGadget0(pc),a0
		move.l	.Windowptr_2(pc),a1
		sub.l	a2,a2
		CALLINT ActivateGadget

		bsr	.Event
		move.w	gg_GadgetID(a4),d0
		cmp.w	#2,d0
		beq.s	.NoRF
		move.l	#.FullName,d1
		move.l	#.RFPath,d2
		CALLDOS Rename

.NoRF		move.l	.Windowptr_2(pc),a0
		CALLINT CloseWindow
.RFError	rts

.Event		move.l	.Windowptr_2(pc),a0
		move.l	wd_UserPort(a0),a0
		CALLEXEC GetMsg
		tst.l	d0
		beq.s	.Event
		move.l	d0,a1
		move.l	im_Class(a1),d6
		move.l	im_IAddress(a1),a4
		CALLEXEC ReplyMsg
		rts

* The routine to get the device-names was taken from the source of the
* Filerequest from 'FileMaster' by Roger Fischlin.It was changed by me
* to fit in this program.Thanks Roger !

.Devices	bsr	.FreeMem
		clr.l	.Files
		clr.l	.Mem
		clr.l	.StartPrint
		move.l	_DosBase,a2
		move.l	dl_Root(a2),a2
		move.l	rn_Info(a2),a2
		add.l	a2,a2
		add.l	a2,a2
		move.l	di_DevInfo(a2),a2
		add.l	a2,a2
		add.l	a2,a2
		lea	.Mem(pc),a5
.Devs1		cmp.l	#DLT_DEVICE,dl_Type(a2)
		bne.s	.Devs2
		tst.l	dl_Task(a2)
		beq.s	.Devs2	
		movem.l	d1-d7/a0-a6,-(sp)
		move.l	#42,d0
		move.l	#0,d1
		CALLEXEC AllocMem
		movem.l	(sp)+,d1-d7/a0-a6
		addq.l	#1,.Files
		move.l	d0,(a5)
		move.l	d0,a5
		move.l	d0,a0
		clr.l	(a0)+
		clr.l	d0
		move.l	dl_Name(a2),a1
		add.l	a1,a1
		add.l	a1,a1
		move.b	(a1)+,d0
		subq.l	#1,d0
.CopyDevsname	move.b	(a1)+,(a0)+
		dbra	d0,.CopyDevsname
		move.b	#":",(a0)+
		clr.b	(a0)
		move.b	#2,37(a5)
		move.l	#0,38(a5)
.Devs2		move.l	(a2),a2
		add.l	a2,a2
		add.l	a2,a2
		cmp.l	#0,a2
		bne.s	.Devs1
		bsr	.CorrectProp
		bsr.s	.Sort
		bsr	.PrintFiles
		bra	.Wait_Event

.Sort		tst.l	.ChangeFlag
		bne.s	.DoSort
		rts
.DoSort		clr.l	.ChangeFlag
		cmp.l	#1,.Files
		bls	.NoSort
		move.l	.Mem(pc),a0
.Sort_1		move.l	(a0),a1
		cmp.l	#0,a1
		beq.s	.SortFinished
.Sort_2		lea	4(a0),a2
		lea	4(a1),a3
.Compare_1	cmp.b	#0,(a3)
		beq.s	.NoSwap_1
		move.b	(a3)+,d0
		bsr	.Upcase
		move.b	d0,d1
		move.b	(a2)+,d0
		bsr	.Upcase
		cmp.b	d0,d1
		beq.s	.Compare_1
		blt.s	.NoSwap_1
		lea	4(a0),a2
		lea	4(a1),a3
		moveq	#37,d0
.Swap_1		move.b	(a3),d1
		move.b	(a2),(a3)+
		move.b	d1,(a2)+
		dbra	d0,.Swap_1
.NoSwap_1	move.l	(a1),a1
		cmp.l	#0,a1
		bne.s	.Sort_2
		move.l	(a0),a0
		cmp.l	#0,a0
		bne.s	.Sort_1
.SortFinished	move.l	.Mem(pc),a0
.Sort_3		move.l	(a0),a1
		cmp.l	#0,a1
		beq.s	.SortFinished_2
.Sort_4		move.b	37(a0),d0
		move.b	37(a1),d1
		cmp.b	d1,d0
		blt.s	.NoSwap_2
		lea	4(a0),a2
		lea	4(a1),a3
		moveq	#37,d0
.Swap_2		move.b	(a3),d1
		move.b	(a2),(a3)+
		move.b	d1,(a2)+
		dbra	d0,.Swap_2
.NoSwap_2	move.l	(a1),a1
		cmp.l	#0,a1
		bne.s	.Sort_4
		move.l	(a0),a0
		cmp.l	#0,a0
		bne.s	.Sort_3
.SortFinished_2	bsr.s	.PrintFiles
.NoSort		rts

.FreeMem	tst.l	.Files
		beq.s	.EndFree
		move.l	.Mem(pc),a5
.FreeElement	move.l	a5,a1
		move.l	(a5),a5
		move.l	#42,d0
		CALLEXEC FreeMem
		cmp.l	#0,a5
		bne.s	.FreeElement
		move.l	#0,.Files
		move.l	#0,.Mem
.EndFree	rts

.Upcase		cmp.b	#"a",d0
		blt.s	.NoUpcase
		cmp.b	#"z",d0
		bgt.s	.NoUpcase
		sub.b	#32,d0
.NoUpcase	rts

.PrintFiles	move.l	.Mem(pc),a4
		move.l	.StartPrint(pc),d0
		beq.s	.NoSkip
		subq.l	#1,d0
.Skip		move.l	(a4),a4
		dbra	d0,.Skip
.NoSkip		move.l	#34,d7
		moveq	#7,d6
.Printloop	cmp.l	#0,a4
		beq	.EndPrint
		lea	.PrintBuffer(pc),a0
		lea	4(a4),a1
		moveq	#28,d2
.CopyName	cmp.b	#0,(a1)
		beq.s	.EndNCopy
		move.b	(a1)+,(a0)+
		dbra	d2,.CopyName
		bra.s	.NoBlankFill
.EndNCopy	move.b	#" ",(a0)+
		dbra	d2,.EndNCopy
.NoBlankFill	move.b	#" ",(a0)+
		cmp.b	#0,37(a4)
		bne.s	.NoFile
		tst.l	38(a4)
		bne.s	.NotEmpty
		move.b	#" ",(a0)+
		move.b	#"E",(a0)+
		move.b	#"M",(a0)+
		move.b	#"P",(a0)+
		move.b	#"T",(a0)+
		move.b	#"Y",(a0)+
		move.b	#" ",(a0)+
		bra.s	.FileCol
.NotEmpty	move.b	#" ",(a0)+
		move.l	38(a4),d2
		moveq	#0,d3
		moveq	#5,d0
		lea	.pot(pc),a1
.next		moveq	#"0",d1
.dec		addq	#1,d1
		sub.l	(a1),d2
		bcc.s	.dec
		subq	#1,d1
		add.l	(a1),d2
		tst.b	d3
		bne.s	.ZeroSet
		cmp.b	#"0",d1
		bne.s	.ZeroSet
		move.b	#" ",d1
.ZeroSet	move.b	d1,(a0)+
		cmp.b	#" ",d1
		beq.s	.Space
		moveq	#1,d3
.Space		lea	4(a1),a1
		dbra	d0,.next
.FileCol	move.l	.rp(pc),a1
		move.l	.Filepen,d0
		CALLGRAF SetAPen
		bra.s	.Out
.NoFile		cmp.b	#1,37(a4)
		bne.s	.NoDir
		move.b	#"»",(a0)+
		move.b	#" ",(a0)+
		move.b	#"D",(a0)+
		move.b	#"I",(a0)+
		move.b	#"R",(a0)+
		move.b	#" ",(a0)+
		move.b	#"«",(a0)+
		move.l	.rp(pc),a1
		move.l	.DirPen,d0
		CALLGRAF SetAPen
		bra.s	.Out
.NoDir		move.b	#"»",(a0)+
		move.b	#" ",(a0)+
		move.b	#"D",(a0)+
		move.b	#"E",(a0)+
		move.b	#"V",(a0)+
		move.b	#" ",(a0)+
		move.b	#"«",(a0)+
		move.l	.rp(pc),a1
		move.l	.DirPen,d0
		CALLGRAF SetAPen
.Out		move.l	#22,d0
		move.l	d7,d1
		CALLGRAF Move
		lea	.PrintBuffer(pc),a0
		move.l	#37,d0
		CALLGRAF Text
		add.l	#10,d7
		move.l	(a4),a4
		dbra	d6,.PrintLoop
		rts
.EndPrint	lea	.PrintBuffer(pc),a0
		moveq	#36,d0
.FillBlanks	move.b	#" ",(a0)+
		dbra	d0,.FillBlanks
.ClearRest	move.l	.rp(pc),a1
		move.l	#22,d0
		move.l	d7,d1
		CALLGRAF Move
		lea	.PrintBuffer(pc),a0
		move.l	#37,d0
		CALLGRAF Text
		add.l	#10,d7
		dbra	d6,.ClearRest
		rts

.CorrectProp	lea	.gadget9(pc),a0
		move.l	.Windowptr(pc),a1
		sub.l	a2,a2
		move.l	#AUTOKNOB!FREEVERT,d0
		clr.l	d1
		clr.l	d3
		move.l	.Files(pc),d2
		cmp.l	#8,d2
		bgt.s	.More8
		moveq.l	#1,d2
.More8		move.l	#$ffff*8,d4
		divu	d2,d4
		and.l	#$ffff,d4
		move.l	.Files(pc),d5
		subq.l	#8,d5
		tst.l	d5
		bmi.s	.Less8
		bne.s	.More8_2
.Less8		moveq.l	#1,d5
.More8_2	move.l	#$ffff,d2
		divu	d5,d2
		and.l	#$ffff,d2
		move.l	.StartPrint(pc),d5
		mulu	d2,d5
		move.l	d5,d2
		CALLINT	ModifyProp
		rts

* structs

.Window		dc.w	0,0,320,168
		dc.b	-1,-1
		dc.l	GADGETUP!GADGETDOWN!MENUVERIFY
		dc.l	WINDOWDRAG!SMART_REFRESH!ACTIVATE
		dc.l	.gadget0
		dc.l	0
		dc.l	.Windowtitle
		dc.l	0
		dc.l	0
		dc.w	0,0,0,0
		dc.w	CUSTOMSCREEN

* Path gadget

.gadget0	dc.l	.gadget1
		dc.w	49,14,264,8
		dc.w	GADGHCOMP,RELVERIFY,STRGADGET
		dc.l	.border0,0,.text0,0,.info0
		dc.w	0
		dc.l	0
.border0	dc.w	0,0
		dc.b	2,0,RP_JAM1,5
		dc.l	.dots0,0
.dots0		dc.w	-1,-1
		dc.w	264,-1
		dc.w	264,8
		dc.w	-1,8
		dc.w	-1,-1
.text0		dc.b	2,1,RP_JAM1,0
		dc.w	-44,0
		dc.l	0,.string0,0
.string0	dc.b	"Path:",0
		even
.info0		dc.l	.Path,0
		dc.w	0,255,0,0,0,0,0,0
		dc.l	0,0,0
.Path		ds.b	256

* Filegadgets

.gadget1	dc.l	.gadget2
		dc.w	22,27,296,10
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	0,0,0,0,0
		dc.w	1
		dc.l	0
.gadget2	dc.l	.gadget3
		dc.w	22,37,296,10
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	0,0,0,0,0
		dc.w	2
		dc.l	0
.gadget3	dc.l	.gadget4
		dc.w	22,47,296,10
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	0,0,0,0,0
		dc.w	3
		dc.l	0
.gadget4	dc.l	.gadget5
		dc.w	22,57,296,10
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	0,0,0,0,0
		dc.w	4
		dc.l	0
.gadget5	dc.l	.gadget6
		dc.w	22,67,296,10
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	0,0,0,0,0
		dc.w	5
		dc.l	0
.gadget6	dc.l	.gadget7
		dc.w	22,77,296,10
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	0,0,0,0,0
		dc.w	6
		dc.l	0
.gadget7	dc.l	.gadget8
		dc.w	22,87,296,10
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	0,0,0,0,0
		dc.w	7
		dc.l	0
.gadget8	dc.l	.gadget9
		dc.w	22,97,296,10
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	0,0,0,0,0
		dc.w	8
		dc.l	0

* Prop-gadget

.gadget9	dc.l	.gadget10
		dc.w	2,35,20,64
		dc.w	GADGHCOMP,RELVERIFY!GADGIMMEDIATE,PROPGADGET
		dc.l	.SpecialBuf9,0,0,0,.Special9
		dc.w	9
		dc.l	0
.SpecialBuf9	dc.w	0,0,0,0
.Special9	dc.w	AUTOKNOB!FREEVERT
		dc.w	0,0,0,$ffff,0,0,0,0,0,0

* Gadgets up'n'down

.gadget10	dc.l	.gadget11
		dc.w	4,27,16,8
		dc.w	GADGHCOMP!GADGIMAGE,RELVERIFY!GADGIMMEDIATE,BOOLGADGET
		dc.l	.image10,0,0,0,0
		dc.w	10
		dc.l	0
.image10	dc.w	0,0,16,8,1
		dc.l	.body10
		dc.b	1,0
		dc.l	0

.gadget11	dc.l	.gadget12
		dc.w	4,99,16,8
		dc.w	GADGHCOMP!GADGIMAGE,RELVERIFY!GADGIMMEDIATE,BOOLGADGET
		dc.l	.image11,0,0,0,0
		dc.w	11
		dc.l	0
.image11	dc.w	0,0,16,8,1
		dc.l	.body11
		dc.b	1,0
		dc.l	0

* File gadget

.gadget12	dc.l	.gadget13
		dc.w	51,112,264,8
		dc.w	GADGHCOMP,RELVERIFY,STRGADGET
		dc.l	.border12,0,.text12,0,.info12
		dc.w	12
		dc.l	0
.border12	dc.w	0,0
		dc.b	2,0,RP_JAM1,5
		dc.l	.dots12,0
.dots12		dc.w	-1,-1
		dc.w	264,-1
		dc.w	264,8
		dc.w	-1,8
		dc.w	-1,-1
.text12		dc.b	2,1,RP_JAM1,0
		dc.w	-44,0
		dc.l	0,.string12,0
.string12	dc.b	"File:",0
		even
.info12		dc.l	.File,0
		dc.w	0,34,0,0,0,0,0,0
		dc.l	0,0,0
.File		ds.b	34

* Boolgadgets

.gadget13	dc.l	.gadget14
		dc.w	32,125,64,16
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	.border13,0,.text13,0,0
		dc.w	13
		dc.l	0
.border13	dc.w	0,0
		dc.b	2,0,RP_JAM1,5
		dc.l	.dots13,0
.dots13		dc.w	0,0
		dc.w	63,0
		dc.w	63,16
		dc.w	0,16
		dc.w	0,0
.text13		dc.b	2,1,RP_JAM1,0
		dc.w	8,5
		dc.l	0,.string13,0
.string13	dc.b	" OKAY ",0
		even

.gadget14	dc.l	.gadget15
		dc.w	128,125,64,16
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	.border13,0,.text14,0,0
		dc.w	14
		dc.l	0
.text14		dc.b	2,1,RP_JAM1,0
		dc.w	8,5
		dc.l	0,.string14,0
.string14	dc.b	"PARENT",0
		even

.gadget15	dc.l	.gadget16
		dc.w	226,125,64,16
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	.border13,0,.text15,0,0
		dc.w	15
		dc.l	0
.text15		dc.b	2,1,RP_JAM1,0
		dc.w	8,5
		dc.l	0,.string15,0
.string15	dc.b	"CANCEL",0
		even

.gadget16	dc.l	.gadget17
		dc.w	32,146,64,16
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	.border13,0,.text16,0,0
		dc.w	16
		dc.l	0
.text16		dc.b	2,1,RP_JAM1,0
		dc.w	4,5
		dc.l	0,.string16,0
.string16	dc.b	"MAKEDIR",0
		even

.gadget17	dc.l	.gadget18
		dc.w	128,146,64,16
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	.border13,0,.text17,0,0
		dc.w	17
		dc.l	0
.text17		dc.b	2,1,RP_JAM1,0
		dc.w	8,5
		dc.l	0,.string17,0
.string17	dc.b	"DELETE",0
		even

.gadget18	dc.l	0
		dc.w	226,146,64,16
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	.border13,0,.text18,0,0
		dc.w	18
		dc.l	0
.text18		dc.b	2,1,RP_JAM1,0
		dc.w	8,5
		dc.l	0,.string18,0
.string18	dc.b	"RENAME",0
		even

* Makedir window

.MDWindow	dc.w	0,0,320,48
		dc.b	-1,-1
		dc.l	GADGETUP!GADGETDOWN
		dc.l	SMART_REFRESH!ACTIVATE!BORDERLESS
		dc.l	.MDgadget0
		dc.l	0,0,0,0
		dc.w	0,0,0,0
		dc.w	CUSTOMSCREEN

* Makedir gadget

.MDgadget0	dc.l	.MDgadget1
		dc.w	49,16,264,8
		dc.w	GADGHCOMP,RELVERIFY,STRGADGET
		dc.l	.border0,0,.text0,0,.MDInfo0
		dc.w	0
		dc.l	0
.MDinfo0	dc.l	.MDPath,0
		dc.w	0,255,0,0,0,0,0,0
		dc.l	0,0,0
.MDPath		ds.b	256

* Okay & Cancel gadget

.MDgadget1	dc.l	.MDgadget2
		dc.w	48,28,64,16
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	.border13,0,.text13,0,0
		dc.w	1
		dc.l	0

.MDgadget2	dc.l	0
		dc.w	210,28,64,16
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	.border13,0,.text15,0,0
		dc.w	2
		dc.l	0

* Rename window

.RFWindow	dc.w	0,0,320,48
		dc.b	-1,-1
		dc.l	GADGETUP!GADGETDOWN
		dc.l	SMART_REFRESH!ACTIVATE!BORDERLESS
		dc.l	.RFgadget0
		dc.l	0,0,0,0
		dc.w	0,0,0,0
		dc.w	CUSTOMSCREEN

* New name gadget

.RFgadget0	dc.l	.RFgadget1
		dc.w	49,16,264,8
		dc.w	GADGHCOMP,RELVERIFY,STRGADGET
		dc.l	.border12,0,.text12,0,.RFInfo0
		dc.w	0
		dc.l	0
.RFinfo0	dc.l	.RFPath,0
		dc.w	0,33,0,0,0,0,0,0
		dc.l	0,0,0
.RFPath		ds.b	512

* Okay & Cancel gadget

.RFgadget1	dc.l	.RFgadget2
		dc.w	48,28,64,16
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	.border13,0,.text13,0,0
		dc.w	1
		dc.l	0

.RFgadget2	dc.l	0
		dc.w	210,28,64,16
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	.border13,0,.text15,0,0
		dc.w	2
		dc.l	0

* Delete window

.DELWindow	dc.w	0,0,320,36
		dc.b	-1,-1
		dc.l	GADGETUP!GADGETDOWN
		dc.l	SMART_REFRESH!ACTIVATE!BORDERLESS
		dc.l	.DELgadget0
		dc.l	0,0,0,0
		dc.w	0,0,0,0
		dc.w	CUSTOMSCREEN

* Okay & Cancel gadget

.DELgadget0	dc.l	.DELgadget1
		dc.w	48,16,64,16
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	.border13,0,.text13,0,0
		dc.w	0
		dc.l	0

.DELgadget1	dc.l	0
		dc.w	210,16,64,16
		dc.w	GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	.border13,0,.text15,0,0
		dc.w	1
		dc.l	0

* strings

.Windowtitle	dc.b	"FileSelect V2.0 © by A.Wichmann/CLUSTER",0
		even
.BadPath_text	dc.b	"Bad Path !"
		even
.MDText		dc.b	"Please enter path:"
		even
.RFText		dc.b	"Please enter new name:"
		even
.DELText	dc.b	"Are you sure ?"
		even

* Tabellen

.pot		dc.l	100000
		dc.l	10000
		dc.l	1000
		dc.l	100
		dc.l	10
		dc.l	1

* vars

.Windowptr	ds.l	1
.rp		ds.l	1
.GadgetFlags	ds.w	1
.StartPrint	ds.l	1
.Files		ds.l	1
.Mem		ds.l	1
.Lock		ds.l	1
		cnop	0,4
.fib		ds.b	260
.PrintBuffer	ds.b	38
.ChangeFlag	ds.l	1
.Backpen	ds.l	1
.Filepen	ds.l	1
.Dirpen		ds.l	1
.Gadgetpen	ds.l	1
.FirstFilter	ds.l	1
.FullName	ds.b	512
.AnswerStruct	ds.b	FS2_SIZEOF
.Windowptr_2	ds.l	1
.rp_2		ds.l	1

* CHIPMEM-Images

.body10		dc.w	%0000000000000000
		dc.w	%0000000110000000
		dc.w	%0000001111000000
		dc.w	%0000011111100000
		dc.w	%0000111111110000
		dc.w	%0001111111111000
		dc.w	%0011111111111100
		dc.w	%0000000000000000

.body11		dc.w	%0000000000000000
		dc.w	%0011111111111100
		dc.w	%0001111111111000
		dc.w	%0000111111110000
		dc.w	%0000011111100000
		dc.w	%0000001111000000
		dc.w	%0000000110000000
		dc.w	%0000000000000000

*
* Aragorn/CLUSTER rules...
*

