;****** Auto-Revision Header (do not edit) *******************************
;*
;* © Copyright by MMSoftware
;*
;* Filename         : NewList.i
;* Created on       : 28-Oct-93
;* Created by       : M.Meany
;* Current revision : V0.003
;*
;*
;* Purpose: Generic list handling routines, PC-Relative & small.
;*                                                    M.Meany (28-Oct-93)
;*          
;*
;* V0.003 : Magor bug fix. The mvml_Data field was not being set by ANY 
;*          of the node allocation routines. What am I?
;*                                                    M.Meany (16-Nov-93)
;*          
;* V0.002 : Extended FindNode() so only start of name is required for
;*          a match. Now 962 bytes when assembled.
;*                                                    M.Meany (29-Oct-90)
;*          
;* V0.001 : Fixed bad list header: was allocating LN_SIZE, not mvml_Size.
;*          Sorted alphabetic node addittion routines. --- 926 bytes :-)
;*                                                    M.Meany (29-Oct-90)
;*          
;* V0.000 : --- Initial release --- 930 bytes when assembled.
;*
;*************************************************************************

; Require following includes, uncomment to check!

;		incdir		sys:include2.0/
;		include		system.gs
;		include		exec/exec_lib.i
;		include		exec/lists.i
;		include		exec/nodes.i
;		include		exec/memory.i


; Node numbering starts at 1.

; ***** There are some string routines at the end of this file that are
; ***** required, but you may have already included.

; lishead=GetList()		creates and initialises a minlist header
;    d0

; result=AddNode( listhead, Data, Name, Size )	adds a node to list at tail
;   d0               a0      a1    a2    d0

; result=AddCNode( listhead, Data, Name, Size )	adds a node to list at tail
;   d0               a0      a1     a2    d0	always in CHIP memory

; result=AddNodeAlpha( listhead, Data, Name, Size ) adds a node to list at tail
;   d0                    a0      a1    a2    d0    always in CHIP memory

; result=AddCNodeAlpha( listhead, Data, Name, Size ) adds a node to list at tail
;   d0                     a0      a1    a2    d0    always in CHIP memory

; result=FreeNode( node )			remove a node
;   d0              a0

; result=ClearList( listhead )			frees all nodes, but keeps
;   d0                 a0			list head

; result=FreeList( listhead )			frees all nodes and head
;   d0                a0

; node=LocateNode( listhead, number )		find a node given it's pos'n
;  d0                 a0       d0

; node=FindNode( listhead, name )		find node given it's name.
;  d0               a0      a1			starts searching at NEXT node

ID_Extended	equ		253		node has data
ID_Normal	equ		254		node has name only

		rsreset
mvml_Node	rs.b		LN_SIZE		node structure
mvml_NLen	rs.l		1		size of this node
mvml_Data	rs.l		1		addr of nodes data
mvml_DataLen	rs.l		1		size of data held
mvml_Name	rs.b		0		name goes here (even always)
mvml_Size	rs.b		0		size of header

;--------------
;--------------	Creates and initialises a list header
;--------------

; Entry
; Exit
; Corrupt

GetList		PUSHALL

; Allocate memory for a minlist structure

		moveq.l		#MLH_SIZE,d0
		move.l		#MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		tst.l		d0
		beq.s		.done

; Initialise structure

		move.l		d0,a0
		NEWLIST		a0

.done		PULLALL
		rts

;--------------
;--------------	Creates a node and adds it to the tail of the list
;--------------

; Entry		a0->listhead as returned by GetList or your own!
;		a1->Data for this node, will be copied!
;		a2->Name for this node, NULL terminated.
;		d0=size of data to add to node.
; Exit		d0=address of node
; Corrupt	d0

; Node is added to tail of list.
; If d0=0 an ordinary node is created.
; Ordinary nodes have a type of ID_Normal, ones with data have ID_Extended

AddNode		PUSHALL

; Move parameters to safe place

		move.l		d0,d7
		move.l		a0,a5			a5->head
		move.l		a1,a4			a4->nodes data
		move.l		a2,a3			a3->nodes name

; Determine size of memory to allocate for this node and get it.

		moveq.l		#mvml_Size,d6		list structure
		
		move.l		a3,a0
		bsr		StrLen
		addq.w		#1,d0			ensure even length
		and.b		#$fe,d0
		move.l		d0,d4			save a copy!
		add.l		d0,d6			add length of name

		add.l		d7,d6			add size of data
		
		move.l		d6,d0
		move.l		#MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l		d0,d5			save pointer
		beq.s		.done			exit if no memory

		move.l		d5,a0			a0->node

; Save size of this node in mvml extension

		move.l		d6,mvml_NLen(a0)	set length
		move.l		d7,mvml_DataLen(a0)	set data length
		
; Set pointer to nodes name and copy name into buffer

		lea		mvml_Name(a0),a1	a1->space for name
		move.l		a1,LN_NAME(a0)		set pointer
		move.l		a3,a0			a0->Name
		bsr		StrCpy			Copy name

; Now set objects type, if no data then we are finished!

		move.l		d5,a0

		move.b		#ID_Normal,LN_TYPE(a0)	default type
		tst.l		d7
		beq.s		.SetNode
		
		move.b		#ID_Extended,LN_TYPE(a0) node has data

; Determine where data has to go, save pointer and copy it!

		lea		mvml_Name(a0,d4),a1	->start of data buff
		move.l		a4,a0
		move.l		d7,d0
		CALLSYS		CopyMem			copy the data

; Add this node to the end of the list

.SetNode	move.l		a5,a0			list head
		move.l		d5,a1			node
		ADDTAIL

; return address of this node

		move.l		d5,d0			get addr of node

.done		PULLALL
		rts

;--------------
;--------------	Creates a node in CHIP memory and adds it to tail of list
;--------------

; Entry		a0->listhead as returned by GetList or your own!
;		a1->Data for this node, will be copied!
;		a2->Name for this node, NULL terminated.
;		d0=size of data to add to node.
; Exit		d0=address of node
; Corrupt	d0

; CHIP memory is allocated for this node.
; Node is added to tail of list.
; If d0=0 an ordinary node is created.
; Ordinary nodes have a type of ID_Normal, ones with data have ID_Extended

AddCNode	PUSHALL

; Move parameters to safe place

		move.l		d0,d7
		move.l		a0,a5			a5->head
		move.l		a1,a4			a4->nodes data
		move.l		a2,a3			a3->nodes name

; Determine size of memory to allocate for this node and get it.

		moveq.l		#mvml_Size,d6		list structure
		
		move.l		a3,a0
		bsr		StrLen
		addq.w		#1,d0			ensure even length
		and.b		#$fe,d0
		move.l		d0,d4			save a copy!
		add.l		d0,d6			add length of name

		add.l		d7,d6			add size of data
		
		move.l		d6,d0
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l		d0,d5			save pointer
		beq.s		.done			exit if no memory

		move.l		d5,a0			a0->node

; Save size of this node in mvml extension

		move.l		d6,mvml_NLen(a0)	set length
		move.l		d7,mvml_DataLen(a0)	set data length
		
; Set pointer to nodes name and copy name into buffer

		lea		mvml_Name(a0),a1	a1->space for name
		move.l		a1,LN_NAME(a0)		set pointer
		move.l		a3,a0			a0->Name
		bsr		StrCpy			Copy name

; Now set objects type, if no data then we are finished!

		move.l		d5,a0

		move.b		#ID_Normal,LN_TYPE(a0)	default type
		tst.l		d7
		beq.s		.SetNode
		
		move.b		#ID_Extended,LN_TYPE(a0) node has data

; Determine where data has to go, save pointer and copy it!

		lea		mvml_Name(a0,d4),a1	->start of data buff
		move.l		a1,mvml_Data(a0)	save ->data 
		move.l		a4,a0
		move.l		d7,d0
		CALLSYS		CopyMem			copy the data

; Add this node to the end of the list

.SetNode	move.l		a5,a0			list head
		move.l		d5,a1			node
		ADDTAIL

; return address of this node

		move.l		d5,d0			get addr of node

.done		PULLALL
		rts


;--------------
;--------------	Creates a node and adds it to the list according to its name
;--------------

; Entry
; Exit
; Corrupt

; List is created in ascending order ....
; Name comparison is not case sensitive.
; Do not use for huge lists, comparisons always start at the beginning!

AddNodeAlpha	PUSHALL

; Move parameters to safe place

		move.l		d0,d7
		move.l		a0,a5			a5->head
		move.l		a1,a4			a4->nodes data
		move.l		a2,a3			a3->nodes name

; Determine size of memory to allocate for this node and get it.

		moveq.l		#mvml_Size,d6		list structure
		
		move.l		a3,a0
		bsr		StrLen
		addq.w		#1,d0			ensure even length
		and.b		#$fe,d0
		move.l		d0,d4			save a copy!
		add.l		d0,d6			add length of name

		add.l		d7,d6			add size of data
		
		move.l		d6,d0
		move.l		#MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l		d0,d5			save pointer
		beq.s		.done			exit if no memory

		move.l		d5,a0			a0->node

; Save size of this node in mvml extension

		move.l		d6,mvml_NLen(a0)	set length
		move.l		d7,mvml_DataLen(a0)	set data length
		
; Set pointer to nodes name and copy name into buffer

		lea		mvml_Name(a0),a1	a1->space for name
		move.l		a1,LN_NAME(a0)		set pointer
		move.l		a3,a0			a0->Name
		bsr		StrCpy			Copy name

; Now set objects type, if no data then we are finished!

		move.l		d5,a0

		move.b		#ID_Normal,LN_TYPE(a0)	default type
		tst.l		d7
		beq.s		.SetNode
		
		move.b		#ID_Extended,LN_TYPE(a0) node has data

; Determine where data has to go, save pointer and copy it!

		lea		mvml_Name(a0,d4),a1	->start of data buff
		move.l		a1,mvml_Data(a0)	save ->data 
		move.l		a4,a0
		move.l		d7,d0
		CALLSYS		CopyMem			copy the data

; Find node that we are less than

.SetNode	move.l		a5,a2
		cmp.l		MLH_TAILPRED(a2),a2	empty list?
		beq.s		.Found			yep, add now
		
.SearchLoop	TSTNODE		a2,a2			get next node
		beq.s		.AtEnd			exit if at Tail

		move.l		LN_NAME(a2),a0		a0->node name
		move.l		a3,a1			a1->Name
		bsr		StrCmp
		bmi.s		.SearchLoop		

.AtEnd		move.l		LN_PRED(a2),a2		step back one

; Add our node after the node -> a2

; Make nodes sucessor have us as a predecessor

.Found		move.l		(a2),a0
		move.l		d5,LN_PRED(a0)

; make nodes sucessor our sucessor

		move.l		d5,a1
		move.l		a0,(a1)

; make node our predecessor

		move.l		a2,LN_PRED(a1)

; make node have us a it's sucessor

		move.l		d5,(a2)

; return the address of this node

		move.l		d5,d0

.done		PULLALL
		rts


;--------------
;--------------	Creates a CHIP node,adds it to the list according to its name
;--------------

; Entry
; Exit
; Corrupt

; Node is created in CHIP memory
; List is created in ascending order ....
; Name comparison is not case sensitive.
; Do not use for huge lists, comparisons always start at the beginning!

AddCNodeAlpha	PUSHALL

; Move parameters to safe place

		move.l		d0,d7
		move.l		a0,a5			a5->head
		move.l		a1,a4			a4->nodes data
		move.l		a2,a3			a3->nodes name

; Determine size of memory to allocate for this node and get it.

		moveq.l		#mvml_Size,d6		list structure
		
		move.l		a3,a0
		bsr		StrLen
		addq.w		#1,d0			ensure even length
		and.b		#$fe,d0
		move.l		d0,d4			save a copy!
		add.l		d0,d6			add length of name

		add.l		d7,d6			add size of data
		
		move.l		d6,d0
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l		d0,d5			save pointer
		beq.s		.done			exit if no memory

		move.l		d5,a0			a0->node

; Save size of this node in mvml extension

		move.l		d6,mvml_NLen(a0)	set length
		move.l		d7,mvml_DataLen(a0)	set data length
		
; Set pointer to nodes name and copy name into buffer

		lea		mvml_Name(a0),a1	a1->space for name
		move.l		a1,LN_NAME(a0)		set pointer
		move.l		a3,a0			a0->Name
		bsr		StrCpy			Copy name

; Now set objects type, if no data then we are finished!

		move.l		d5,a0

		move.b		#ID_Normal,LN_TYPE(a0)	default type
		tst.l		d7
		beq.s		.SetNode
		
		move.b		#ID_Extended,LN_TYPE(a0) node has data

; Determine where data has to go, save pointer and copy it!

		lea		mvml_Name(a0,d4),a1	->start of data buff
		move.l		a1,mvml_Data(a0)	save ->data 
		move.l		a4,a0
		move.l		d7,d0
		CALLSYS		CopyMem			copy the data

; Find node that we are less than

.SetNode	move.l		a5,a2
		cmp.l		MLH_TAILPRED(a2),a2	empty list?
		beq.s		.Found			yep, add now
		
.SearchLoop	TSTNODE		a2,a2			get next node
		beq.s		.AtEnd			exit if at Tail

		move.l		LN_NAME(a2),a0		a0->node name
		move.l		a3,a1			a1->Name
		bsr		StrCmp
		bmi.s		.SearchLoop		

.AtEnd		move.l		LN_PRED(a2),a2		step back one

; Add our node after the node -> a2

; Make nodes sucessor have us as a predecessor

.Found		move.l		(a2),a0
		move.l		d5,LN_PRED(a0)

; make nodes sucessor our sucessor

		move.l		d5,a1
		move.l		a0,(a1)

; make node our predecessor

		move.l		a2,LN_PRED(a1)

; make node have us a it's sucessor

		move.l		d5,(a2)

; return the address of this node

		move.l		d5,d0

.done		PULLALL
		rts

;--------------
;--------------	Remove node from list and free it's memory
;--------------

; Entry		a0->node
; Exit		none
; Corrupt	d0

FreeNode	PUSHALL

; Move nodes pointer to safe address

		move.l		a0,a5

; Remove node from list

		move.l		a0,a1
		REMOVE

; Free memory for this node

		move.l		a5,a1			->this node
		move.l		mvml_NLen(a1),d0	size of this node
		CALLEXEC	FreeMem

; And exit

.done		PULLALL
		rts


;--------------
;--------------	Removes all nodes from a list, but keep list header
;--------------

; Entry		a0->List header
; Exit		none
; Corrupt	d0

ClearList	PUSHALL

		move.l		a0,a2

.Loop		TSTNODE		a2,a0
		beq.s		.done
		bsr.s		FreeNode
		bra.s		.Loop

.done		PULLALL
		rts

;--------------
;--------------	Removes all nodes from a list and frees list header
;--------------

; Entry		a0->List header
; Exit		none
; Corrupt	d0

FreeList	PUSHALL

; Remove nodes and free memory they occupy

		bsr.s		ClearList

; Now free the list header

		move.l		a0,a1
		moveq.l		#MLH_SIZE,d0
		CALLEXEC	FreeMem

.done		PULLALL
		rts

;--------------
;--------------	Find a node given its ordinal number
;--------------

; Entry		a0->listhead
;		d0=node number
; Exit		d0=address of this node, 0 if no that many nodes.
; Corrupt	d0

LocateNode	PUSHALL

; move parameters to a safe address

		move.l		d0,d5
		moveq.l		#0,d0			clear this

; Search for node, exit if tail reached!

		subq.l		#1,d5			dbra adjust

.Loop		TSTNODE		a0,a0			get next node
		beq.s		.done			exit 
		dbra		d5,.Loop
		
		move.l		a0,d0			return value

.done		PULLALL
		rts

;--------------
;--------------	Find a node given its name
;--------------

; Entry		a0->listhead
;		a1->name
; Exit		d0=address of node of NULL if an error occurred
; Corrupt	d0

; Starts searching from the node following that supplied!

FindNode	PUSHALL

; move parameters to a safe address

		move.l		a0,a5
		move.l		a1,a0			a0->Name
		moveq.l		#0,d7			clear this

; Search for node, exit if tail reached!

.Loop		TSTNODE		a5,a5			get next node
		beq.s		.done			exit 

; See if this is the name we want

		move.l		LN_NAME(a5),a1
		bsr.s		StrCmp1
		bne.s		.Loop
		
		move.l		a5,d7

.done		move.l		d7,d0
		PULLALL
		rts

;--------------
;--------------	
;--------------

; Entry		a0->listhead
; Exit		none
; Corrupt	d0

; Get real :-)

SortList	PUSHALL

.done		PULLALL
		rts

;--------------
;--------------	
;--------------

;--------------
;--------------	
;--------------

;--------------
;--------------	
;--------------

;--------------
;--------------	
;--------------

;--------------
;--------------	Determine length of NULL terminated string
;--------------

; Entry		a0->string
; Exit		d0=length of string including the NULL
; Corrupt	d0

StrLen		move.l		a0,-(sp)

		moveq.l		#0,d0		set = -1 to ignore the NULL

.loop		addq.w		#1,d0			bump counter
		tst.b		(a0)+
		bne.s		.loop

.done		move.l		(sp)+,a0
		rts

;--------------
;--------------	Copy A NULL Terminated string
;--------------

; Entry		a0->Source string
;		a1->Copy Buffer
; Exit		none
; Corrupt	none

StrCpy		move.l		a0,-(sp)
		move.l		a1,-(sp)
		
.loop		move.b		(a0)+,(a1)+
		bne.s		.loop
		
		move.l		(sp)+,a1
		move.l		(sp)+,a0
		rts

;--------------	
;--------------	Compare two strings ignoring case of alphabetic characters
;--------------

; Compares two NULL terminated text strings and returns a value in d0
;that specifies the priority of one relative to the other.

; Entry 	a0->start of first word
;		a1->start of second word

; Exit		d0=0  if words the same or 1st word is start of 2nd word
;		d0=-1 if first word < second word
;		d0=1  if first word > second word

; Corrupt 	d0

StrCmp1		movem.l		d1-d4/a0-a2,-(sp)

		move.l		a0,a2		copy of Src
		moveq.l		#0,d0		clear
		move.l		d0,d1

.len1		addq.l		#1,d0		get length of src
		tst.b		(a2)+
		bne.s		.len1

		move.l		a1,a2		get length of dest
.len2		addq.l		#1,d1
		tst.b		(a2)+
		bne.s		.len2

; Check length of strings and set default return so shortest string is
;classed < largest string. Need this incase largest string is just an
;extension of shortest one, eg. 'Mark' and 'Marker'!!! Also moves the
;shortest length into d0 ready for loop.

		moveq.l		#0,d2		clear return value
		cmp.l		d0,d1		check lengths
		bge.s		.ok		skip if same
		move.l		d1,d0		d0=shortest length
.ok		bra.s		SC_Entry1	get on with comparison

;--------------	
;--------------	Compare two strings ignoring case of alphabetic characters
;--------------

; Compares two NULL terminated text strings and returns a value in d0
;that specifies the priority of one relative to the other.

; Entry 	a0->start of first word
;		a1->start of second word

; Exit		d0=0  if words the same
;		d0=-1 if first word < second word
;		d0=1  if first word > second word

; Corrupt 	d0

StrCmp		movem.l		d1-d4/a0-a2,-(sp)

		move.l		a0,a2		copy of Src
		moveq.l		#0,d0		clear
		move.l		d0,d1

.len1		addq.l		#1,d0		get length of src
		tst.b		(a2)+
		bne.s		.len1

		move.l		a1,a2		get length of dest
.len2		addq.l		#1,d1
		tst.b		(a2)+
		bne.s		.len2

; Check length of strings and set default return so shortest string is
;classed < largest string. Need this incase largest string is just an
;extension of shortest one, eg. 'Mark' and 'Marker'!!! Also moves the
;shortest length into d0 ready for loop.

		moveq.l		#0,d2		clear return value
		cmp.l		d0,d1		check lengths
		beq.s		.ok		skip if same
		blt.s		.ok1		jump if dest < src
		moveq.l		#-1,d2		default return = -1
		bra.s		.ok		get on with it
.ok1		moveq.l		#1,d2		default return = 1
		move.l		d1,d0		d0=shortest length

; Compare chars in the string

.ok		

; Added a second entry point to reduce repeating all this code ...

SC_Entry1	subq.l		#2,d0		adjust counter

; Heres the loop. Get a char from each string and convert both to Upper Case

.loop		move.b		(a0)+,d3	get char

		cmp.b		#'a',d3
		blt.s		.IsUpper1	not lower case char, skip it
		cmp.b		#'z',d3
		bgt.s		.IsUpper1	not lower case char, skip it
		sub.b		#'a'-'A',d3	convert to upper case

; Get char from second string

.IsUpper1	move.b		(a1)+,d4	get char

		cmp.b		#'a',d4
		blt.s		.IsUpper2	not lower case char, skip it
		cmp.b		#'z',d4
		bgt.s		.IsUpper2	not lower case char, skip it
		sub.b		#'a'-'A',d4	convert to upper case

; Now compare the characters

.IsUpper2	cmp.b		d3,d4		check chars
		dbne		d0,.loop	loop if same
		bgt.s		.first		else branch according to
		blt.s		.second		priority
		move.l		d2,d0		must be same, use default
		bra.s		.done		and exit
		
.first		moveq.l		#-1,d0		Src < Dest
		bra.s		.done		and exit
		
.second		moveq.l		#1,d0		Src > Dest

.done		movem.l		(sp)+,d1-d4/a0-a2
		rts

