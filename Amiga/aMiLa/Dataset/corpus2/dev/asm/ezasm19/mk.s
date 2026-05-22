

*	Make for EZAsm Version 1.9

*	Support for include path:

*		Mk [-iPathToIncludes] [path]file




CLEAR_PUBLIC	equ	$10001


	ARGS


LONG	Nm Cdays Flock Flock1 Comb
LONG	Fhandle Rbuf PtrSave WinSv
BYTE	MkSw FIB[260] Tbuf[12] Buf[127]
  

	Flock1 = Lock( "ezasm" -2 )
	Flock1 != 0 {	;CD'd?

		a0 = &Path
		(a0) = 0

	} else {	;ASSIGN?

		a3 = FindTask( 0 )

		WinSv = 184(a3)		;pr_WindowPtr
		184(a3) = -1 l		;stop error

		Flock1 = Lock( "EZASM:" -2 )		

		184(a3) = WinSv		;restore

		Flock1 = 0 Quit
	}

*   Get current time

	a0 = DateStamp( &Tbuf )

	Cdays = (a0)	;ds_Days

	d0 = 4(a0)	;ds_Minute
	swap	d0
	d0 |= 8(a0)	;ds_Tick

	Comb = d0	;save for compare

*   Adjust CLI args for an include path..

	Nm = Args

	strrchr( Args $20 )	; -i arg?
	d0 != 0 {
		d0 ++
		Nm = d0
	}

	qsprint( &Buf "%s.mak" Nm )

	Fhandle = Open( &Buf 1005 )
	beq	Cont

	MkSw = 1

	Rbuf = AllocMem( 1000 #CLEAR_PUBLIC )		
	beq	Quit

	PtrSave = d0

	Read( Fhandle d0 1000 ) 
	bmi	Quit

Cont


	print( "--------------------\n" )

	MkSw = 1 {
		bsr	LoadNext
	} else {
		qsprint( &Buf "%sezasm %s.s\n" &Path Nm )
	}

	Execute( &Buf 0 OutHandle )

	print( "--------------------\n" )

	qsprint( &Buf "%s.asm" Nm )	;name to Lock()
	bsr	Check

	MkSw = 1 {
		bsr	LoadNext
	} else {
		qsprint( &Buf "%sa68k %s.asm\n" &Path Args )
	}

	Execute( &Buf 0 OutHandle )

	print( "--------------------\n" )

	qsprint( &Buf "%s.o" Nm )
	bsr Check

	MkSw = 1 {
		bsr	LoadNext
	} else {
		qsprint( &Buf "%sblink from %s.o lib %sez.lib\n" &Path Nm &Path )
	}

	Execute( &Buf 0 OutHandle )

	bra	Quit




Check


	Flock = Lock( &Buf -2 )  	
	beq	Quit

*   It's here, but is it more recent than current values?

	Examine( d0 &FIB )
	beq	Quit

	a0 = &FIB
	d0 = 132(a0)		;fib_Date.ds_Days
	d0 < Cdays  Quit

	d0 = 136(a0)		;fib_Date.ds_Minute
	swap	d0
	d0 |= 140(a0)		;fib_Date.ds_Tick

	d0 < Comb Quit

	UnLock( Flock )
	Flock = 0

	rts


*   Locate next line to Execute(), load into Buf..

LoadNext


	a0 = PtrSave

Again
	isalpha( * ) {
		a0 = PtrSave 
		a1 = &Buf

Nxt		(a1)+ = (a0)+ b
		-1(a1) != $0a Nxt

		(a1) = 0 b
		PtrSave = a0	;( byte after $0a )

		rts
	}

	a0 = PtrSave
Inc	(a0)+ = $0a {
		PtrSave = a0
		bra	Again
	}
	bra	Inc


Quit

	Fhandle != 0 {
		Close( Fhandle )
	}

	Rbuf != 0 {
		FreeMem( Rbuf 1000 )
	}

	Flock1 != 0 {
		UnLock( Flock1 )
	}

	Flock != 0 {
		UnLock( Flock )
	}


	END


		ds.w	0
Path	dc.b	"EZASM:",0

