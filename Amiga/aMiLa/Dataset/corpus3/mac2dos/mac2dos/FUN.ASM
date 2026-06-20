*********************************************************
*							*
* 	MAC-2-DOS UTILITY FUNCTIONS.			*
*							*
*	Copyright (c) 1989 Central Coast Software	*
*							*
*********************************************************

;	INCLUDE	"VD0:MACROS.ASM"
;	INCLUDE "MAC.I"
	INCLUDE "PRE.OBJ"

        XDEF    LEN..,CMP..,SCAN..,MOVE..,CLIP..,STRIP_LB..,STRIP_TB..
        XDEF    STG_Z..,Z_STG..,STR..,LEFT..,RIGHT..
        XDEF    APPEND..,StripAppend
	XDEF	ACHAR..,STRING..,UCASE..,GTLCHAR..
        XDEF    MOVE_CHARS
	XDEF	DISP_ERR,DISP_REQ,DISP_MSG,DISP_CENT,DISP_CURRENT
	XDEF	DISP_YN,DISP_RETRY
	XDEF	DISP_RMSG
	XDEF	OpenRequester,CloseRequester
	XDEF	WaitRequester,CancelRequester
	XDEF	DISP_IMAGE
	XDEF	ClearBox,CLEAR_BOX,CLEAR_RBOX
	XDEF	AddGadgets,RemoveGadgets
	XDEF	ClearWindow,RefreshWindow
	XDEF	GadgetColor
;	XDEF	ReplaceDup
	XDEF	MoveInsert..
	XDEF	ReqOkay
	XDEF	DISP_RBAR,DISP_WBAR
	XDEF	FILE_ERR

	XREF	SysBase,DosBase,IntuitionBase,GraphicsBase
	XREF	WINDOW
	XREF	WINI,IDATA,WINDSIZE
	XREF	RefreshRoutine
	XREF	TMP.,TMP2.
	XREF	ERRTXT,OKTXT,DT_TXT,IDATA
	XREF	POSTXT,NEGTXT,TRYTXT
	XREF	REQUEST,REQTXT,ReqYes,REQGAD
	XREF	GAD_PTR
	XREF	RQTxtBuf0.,RQTxtBuf1.,RQTxtBuf2.,RQText
	XREF	ReqOKgad

IPEN		EQU	15		;OFFSET TO PEN IN IMAGE
ReqLayer	EQU	32
LayerRP		EQU	12

* Returns length in D0 of null-terminated string pointed to be A0.
* Does not change A0.  Length does NOT include the null termination char.

LEN..:	MOVEQ	#-1,D0
1$:	INCL	D0
	TST.B	0(A0,D0.W)
	BNE.S	1$
	RTS

* COMPARES TWO STRINGS.  SOURCE STRING PTR IN A0, DEST PTR IN A1.  
* RETURNS Z-BIT SET ON STRINGS EQUAL, CLEAR IF NOT.  Handles null strings.
* This routine is NOT case sensitive.

CMP..:	PUSH	D0-D2
	BSR	LEN..		;get length of source stg
2$:	MOVE.B	(A0)+,D1
	IFLTIB	D1,#'a',3$
	IFGTIB	D1,#'z',3$
	BCLR	#5,D1
3$:	MOVE.B	(A1)+,D2
	IFLTIB	D2,#'a',4$
	IFGTIB	D2,#'z',4$
	BCLR	#5,D2
4$:	CMP.B	D1,D2		;DO THE COMPARISON..including null bytes
	BNE.S	1$		;NO MATCH
	DBF	D0,2$		;LOOP FOR ALL BYTES
1$:	POP	D0-D2
	RTS

* SCANS A TOKEN FROM THE SOURCE STRING (A0) INTO THE DEST
* STRING (A1).

SCAN..:	PUSH	A0-A1		;save string ptr
	BSR	STRIP_LB..	;get rid of any leading blanks
	POP	A0-A1
	MOVE.L	A0,D0		;save ptr to start of source
2$:	MOVE.B	(A0),(A1)	;move token to dest
	BEQ.S	1$		;end of source, token terminated
	CMPI.B	#' ',(A0)	;was it BLANK?
	BEQ.S	3$		;YES...STOP HERE
	CMPI.B	#10,(A0)	;was it LF?
	BEQ.S	3$		;yes...treat same as blank
	INCL	A1
5$:	INCL	A0		;POINT TO NEXT TEXT BYTE
	BRA.S	2$		;loop till null or blank

1$:	MOVE.L	D0,A0
	CLR.B	(A0)		;SOURCE STG NOW EMPTY
	BRA.S	9$

3$:	CLR.B	(A1)		;change blank to null in token
	MOVE.L	D0,A1
4$:	MOVE.B	(A0)+,(A1)+	;move up remainder of text in source
	BNE.S	4$
9$:	RTS

* Truncates leading blanks from TMP2. and appends result to TMP.

StripAppend:
	LEA	TMP2.,A0
	BSR	STRIP_LB..
	LEA	TMP2.,A0
	LEA	TMP.,A1
;	RTS

* APPENDS SOURCE STRING (A0) TO END OF DEST STRING (A1)

APPEND..:
1$:	TST.B	(A1)+		;position to end of dest
	BNE.S	1$
	DECL	A1		;backup to null

* MOVES SOURCE STRING TO DESTINATION STRING.

MOVE..:	MOVE.B	(A0)+,(A1)+	;MOVE TEXT
	BNE.S	MOVE..
	RTS

* RETURNS THE LAST CHAR IN D0 OF STRING pointed to by A0.
* COMPARES THAT CHAR TO BYTE IN D7.

GTLCHAR..
	MOVEQ	#-1,D0
1$:	INCL	D0
	TST.B	0(A0,D0.W)
	BNE.S	1$
	MOVE.B	-1(A0,D0.W),D0	;GET LAST CHAR
	CMP.B	D0,D7
	RTS

* STRIPS LEADING BLANKS FROM STRING IN A0.

STRIP_LB..:
	PUSH	A1
	MOVE.L	A0,A1		;SAVE PTR TO SOURCE
	TST.B	(A0)
	BEQ.S	2$		;NULL STRING
1$:	CMP.B	#' ',(A0)
	BNE.S	2$		;NO BLANK...STOP SCAN
	INCL	A0
	BRA.S	1$		;SEARCH ENTIRE STRING
2$:	MOVE.B	(A0)+,(A1)+	;MOVE STRING UP
	BNE.S	2$
	POP	A1
	RTS

*STRIPS TRAILING BLANKS FROM A STRING.  Doesn't change A0.

STRIP_TB..:
	PUSH	D0
	BSR	LEN..		;GET LENGTH IN D0
	TST.W	D0
	BEQ.S	1$		;NOTHING TO SCAN
	SUB.L	#1,D0
2$:	CMP.B	#' ',0(A0,D0.W)	;GOT A BLANK?
	BNE.S	1$		;NO...ALL DONE
	CLR.B	0(A0,D0.W)	;else make it null
	DBF	D0,2$
1$:	POP	D0
	RTS

* CLIPS D0 LEADING CHARS FROM STRING IN A0.

CLIP..:
	PUSH	D1/A1
	MOVE.W	D0,D1
	BSR	LEN..
	IFLEW	D1,D0,1$	;okay...we have enough bytes
	CLR.B	(A0)		;ELSE NOW HAVE NULL STRING
	BRA.S	3$
1$:	MOVE.L	A0,A1
	ADD.W	D1,A0		;POINT TO REMAINDER OF STRING
2$:	MOVE.B	(A0)+,(A1)+
	BNE.S	2$
3$:	POP	D1/A1
	RTS

* Converts null-terminated string to leading-count string.

Z_STG..:
	PUSH	A0-A2
	MOVE.L	A1,A2
	CLR.B	(A1)+		;START WITH ZERO LENGTH
1$:	MOVE.B	(A0)+,D0	;GET A BYTE
	BEQ	2$		;END OF STRING
	BCLR.B	#7,D0		;GET RID OF POSSIBLE HIGH BIT
	MOVE.B	D0,(A1)+	;STORE THE CHAR
	INCB	(A2)		;AND COUNT IT
	BRA.S	1$
2$:	POP	A0-A2
	RTS

* CONVERTS STRING A0 FROM LOWER CASE TO UPPER CASE.

UCASE..:
1$:	MOVE.B	(A0)+,D0	;GET A BYTE
	BEQ.S	2$		;end of string
	CMPI.B	#'a',D0
	BLT.S	1$		;NOT LOWER CASE ALPHA
	CMPI.B	#'z',D0
	BGT.S	1$		;NOT LOWER CASE ALPHA
	ANDI.B	#$5F,D0		;MAKE IT UPPER
	MOVE.B	D0,-1(A0)	;RESTORE CHAR TO STRING
	BRA.S	1$
2$:	RTS

* Converts leading-count string in A0 to null-terminated string in A1.

STG_Z..:
	PUSH	A0-A1
	ZAP	D0
	MOVE.B	(A0)+,D0	;GET LENGTH AND POINT TO 1ST TEXT BYTE
	BEQ.S	1$		;NOTHING TO MOVE
	DECW	D0		;ADJUST FOR DBF
2$:	MOVE.B	(A0)+,(A1)+	;move 1 byte
	DBF	D0,2$
1$:	CLR.B	(A1)		;PUT NULL AT END OF STRING
	POP	A0-A1
	RTS

* CONVERTS THE 32-bit UNSIGNED BINARY NUMBER IN D0 TO n-CHAR ASCII
* STRING POINTED TO BY A0.  CHAR IN D1 IS THE FILL CHAR IF RESULT HAS 
* LEADING 0'S; D1 high word=number of digits in result.
* Warning - the destination string must be long enough to accept result!

STR..:	PUSH	A0/D2-D3
	PUSH	D1
	SWAP	D1
	MOVE.W	D1,D3		;number of DIGITS
STRCOM:	ADD.W	D3,A0		;POINT PAST END OF STRING
	CLR.B	(A0)		;terminate string
	MOVE.L	#10,D2		;FOR DIVIDE
1$:	PUSH	D0		;SAVE 32-BIT DIVIDEND
	ZAP	D0
	MOVE.W	(SP)+,D0	;GET UPPER 16-BITS
	DIVU	D2,D0		;DIVIDE NUMBER BY 10
	MOVE.L	D0,D1		;SAVE REMAINDER FOR NEXT DIVISION
	SWAP	D0		;SAVE QUOTIENT FOR UPPER RESULT
	MOVE.W	(SP)+,D1	;GET LOWER WORD
	DIVU	D2,D1		;DIVIDE UPPER REMAINDER AND LOWER WORD
	MOVE.W	D1,D0		;QUOTIENT TO D0
	SWAP	D1		;REMAINDER
	ADD.B	#$30,D1		;MAKE INTO ASCII CHAR
	MOVE.B	D1,-(A0)	;AND STORE INTO BUFFER
	DECW	D3
	BEQ.S	4$		;oops...results too big...bail out
	TST.L	D0		;ANY QUOTIENT LEFT?
	BNE.S	1$		;YES...GO AGAIN
4$:	POP	D0		;GET FILLER CHAR
	IFZB	D3,3$		;no more room...don't fill
	DECW	D3		;ADJUST FOR DBF
2$:	MOVE.B	D0,-(A0)	;STORE FILLER CHAR
	DBF	D3,2$
3$:	POP	A0/D2-D3
	RTS

* FILLS STRING (A0) WITH CHAR IN D0, FOR COUNT IN D1.

STRING..:
	DECW	D1
1$:	MOVE.B	D0,(A0)+
	DBF	D1,1$
	CLR.B	(A0)		;add null termination
	RTS

* APPENDS A SINGLE CHAR IN D0 TO STRING POINTED TO BY A0.

ACHAR..:
1$:	TST.B	(A0)+
	BNE.S	1$		;positon to end of string
	MOVE.B	D0,-1(A0)
	CLR.B	(A0)
	RTS

* EXTRACTS LEFT SUBSTRING (A1) FROM SRC STRING (A0) FOR D0 CHARS OR LESS.

LEFT..:
	IFZW	D0,9$		;zero length
	DECW	D0
1$:	MOVE.B	(A0)+,(A1)+
	DBEQ	D0,1$		;copy until null or length
9$:	CLR.B	(A1)		;TERMINATE substring
	RTS

* EXTRACTS RIGHT SUBSTRING (A1) FROM SRC STRING (A0) FOR D0 CHARS OR LESS.

RIGHT..:
	CLR.B	(A1)		;just in case...
	MOVE.W	D0,D1		;save length desired
	BEQ.S	9$		;null...bail out
	BSR	LEN..		;get length of source
	IFGEW	D1,D0,1$	;use all of source
	SUB.W	D1,D0
	ADDA.W	D0,A0		;point to proper place for move
1$:	MOVE.B	(A0)+,(A1)+
	BNE.S	1$
9$:	RTS

* MOVES N TEXT CHARS.  A0=SOURCE, A1=DEST.  D0=MAX BYTE COUNT.

MOVE_CHARS:
	DECW	D0		;ADJUST FOR DBF
1$:	MOVE.B	(A0)+,(A1)+
	DBF	D0,1$
	RTS

* IMAGE STRUCT IN A1, X POS IN D0, Y POS IN D1.

DISP_IMAGE:
	MOVE.L	WINDOW,A0
	MOVE.L	wd_RPort(A0),A0
	CALLSYS	DrawImage,IntuitionBase
	RTS

* DISPLAYS INTUITEXT IN THE WINDOW.  POINTER TO TEXT STRING IN A0.
* X,Y OFFSET FROM 0,0 IN D0 (WORDS).  Colors and mode in D1.
* Enter at DISP_CURRENT to add this string to current position.
* Enter at DISP_CENT to center the string on the x position.

DISP_CENT:
	LEA	DT_TXT,A1
	MOVE.L	D0,it_LeftEdge(A1)	;OFFSET TO LEFT, TOP EDGE
	MOVE.W	D1,it_FrontPen(A1)	;color set colors
	SWAP	D1
	MOVE.B	D1,it_DrawMode(A1)
	MOVE.L	A0,it_IText(A1)		;POINTER TO NULL-TERM STRING
	MOVE.L	A1,A0
	CALLSYS	IntuiTextLength,IntuitionBase
	LEA	DT_TXT,A1
	ASR.W	#1,D0			;divide by 2
	SUB.W	D0,it_LeftEdge(A1)	;offset left edge of text
	BRA.S	D_com2	

DISP_CURRENT:
	LEA	DT_TXT,A1
	BRA.S	D_com1

DISP_MSG:
	LEA	DT_TXT,A1		;POINTER TO INTUITEXT STRUCT
	MOVE.L	D0,it_LeftEdge(A1)	;OFFSET TO LEFT, TOP EDGE
D_com1:	MOVE.W	D1,it_FrontPen(A1)	;color set colors
	SWAP	D1
	MOVE.B	D1,it_DrawMode(A1)
	MOVE.L	A0,it_IText(A1)		;POINTER TO NULL-TERM STRING
D_com2:	MOVE.L	WINDOW,A0
	MOVE.L	wd_RPort(A0),A0		;RPort
	ZAP	D0
	ZAP	D1
	CALLSYS	PrintIText,IntuitionBase ;PUT IT ON THE WINDOW
	LEA	DT_TXT,A0
	CALLSYS	IntuiTextLength
	LEA	DT_TXT,A0
	ADD.W	D0,it_LeftEdge(A0)	;add length of stg to left edge
	RTS

DISP_RMSG:
	LEA	DT_TXT,A1		;POINTER TO INTUITEXT STRUCT
	MOVE.L	D0,it_LeftEdge(A1)	;OFFSET TO LEFT, TOP EDGE
	MOVE.W	D1,it_FrontPen(A1)	;color set colors
	SWAP	D1
	MOVE.B	D1,it_DrawMode(A1)
	MOVE.L	A0,it_IText(A1)		;POINTER TO NULL-TERM STRING
	LEA	REQUEST,A0
	MOVE.L	ReqLayer(A0),A0		;point to layer
	MOVE.L	LayerRP(A0),A0		;point to rasterport
	ZAP	D0
	ZAP	D1
	CALLSYS	PrintIText,IntuitionBase ;PUT IT ON THE WINDOW
	RTS

DISP_RETRY:
	PUSH	A2-A3
	LEA	TRYTXT,A2
	LEA	NEGTXT,A3
	BRA.S	DISP_COM

* DISPLAYS ERROR MSG POINTED TO BY A0 IN STANDARD REQUESTER WITH NO
* POSITIVE OPTION.  WAITS FOR NEGATIVE REPLY BY OPERATOR.

DISP_ERR:
	PUSH	A2-A3
	ZAPA	A2
	LEA	OKTXT,A3
DISP_COM:
	LEA	ERRTXT,A1	;ITEXT STRUCT FOR ERR MSGS
	MOVE.L	A0,it_IText(A1)	;SAVE STRING
;	BSR.S	DISP_REQ	;PUT UP REQUESTER
;	RTS

* DISPLAYS STANDARD REQUESTER.  BODY TEXT IN A1, POS TEXT IN A2, NEG TEXT
* IN A3.  RETURNS CY=1 ON NO.  A2=0 if no positive text.

DISP_REQ:
	PUSH	D2-D3/A6
	PUSH	A1		;save ptr to body IText
	MOVE.L	A1,A0
	CALLSYS	IntuiTextLength,IntuitionBase
	MOVE.L	D0,D2		;length of msg in pixels of default font
	ADD.W	#50,D2		;allow a bit of room
	MOVE.L	#REQ_WD,D3	;min requester width
	IFGEL	D2,D3,1$	;wide enough...
	MOVE.L	D3,D2		;else use min width
1$:	POP	A1		;body IText
	MOVE.L	WINDOW,A0
	ZAP	D0		;NO POS FLAGS
	ZAP	D1		;NO NEG FLAGS
	MOVEQ	#REQ_HT,D3	;STANDARD REQUESTER HEIGHT
	CALLSYS	AutoRequest
	TST.L	D0
	BNE.S	2$
	STC
2$:	POP	D2-D3/A6
	POP	A2-A3
	RTS

* File name in A0, error msg in A1.

FILE_ERR:
	PUSH	A1
	LEA	RQTxtBuf1.,A1
	BSR	MOVE..
	POP	A0
	LEA	RQTxtBuf0.,A1
	BSR	MOVE..
	CLR.B	RQTxtBuf2.
	LEA	RQText,A0

* Puts up OK requester.
* Ptr to IText structure in A0.

ReqOkay:
	MOVE.L	A0,REQTXT
	LEA	ReqOKgad,A0
	BRA.S	ReqCom

* Puts up yes/no requester.

DISP_YN:
	MOVE.L	A0,REQTXT
	LEA	ReqYes,A0		;yes/no gadgets
ReqCom:	MOVE.L	A0,REQGAD		;INIT GADGET LIST
	BSR	OpenRequester		;OPEN THE REQUESTER
	ERROR	8$			;OPEN FAILURE
	BSR	WaitRequester		;GET RESPONSE
	ERROR	8$			;NO
	BSR	CloseRequester		;YES
	CLC
8$:	RTS

* REQUESTER SUBRS

OpenRequester:
	LEA	REQUEST,A0	;OPEN SPECIAL REQUESTER
	MOVE.L	WINDOW,A1
	CALLSYS	Request,IntuitionBase
	IFNZL	D0,1$		;good open
	STC			;oops...no requester
1$:	RTS

CloseRequester:
	MOVE.L	WINDOW,A1
	LEA	REQUEST,A0
	CALLSYS	EndRequest,IntuitionBase ;clear the requester
	RTS

WaitRequester:
	BSR	WaitForReqMsg
	AND.W	#$60,D0			;CHECK FOR GADGET FLAGS
	BEQ.S	WaitRequester		;IGNORE IT, WHATEVER IT WAS
	MOVE.L	GAD_PTR,A0
	MOVE.W	gg_GadgetID(A0),D0
;	IFEQIW	D0,#15,WaitRequester	;ignore spurious gadget hits
	IFNZW	D0,1$			;non-zero...isn't cancel
	BSR	CloseRequester		;else close the requester
	STC				;and return CY=1
1$:	RTS

* Checks for requester msg.  Returns CY=1 if msg is cancel gadget.
* Else returns CY=0 and ignores msg.

CancelRequester:
	BSR	CheckReqMsg		;got a msg?
	IFZL	D0,9$			;no
	AND.W	#$60,D0			;CHECK FOR GADGET FLAGS
	BEQ.S	CancelRequester		;IGNORE IT, WHATEVER IT WAS
	MOVE.L	GAD_PTR,A0
	MOVE.W	gg_GadgetID(A0),D0
	IFNZW	D0,9$			;non-zero...isn't cancel
	STC				;else return CY=1
9$:	RTS

WaitForReqMsg:
1$:	BSR	CheckReqMsg		;got a msg?
	IFZL	D0,2$			;no
	RTS				;else return with im_Class in D0
2$:	MOVEA.L	WINDOW,A0
	MOVE.L	wd_UserPort(A0),A0
	CALLSYS	WaitPort		;wait for something to happen
	BRA.S	1$			;it did

* Looks for requester msg.  Returns im_Class in D0 or 0 if no msg.
* Replies to msg, if any.

CheckReqMsg:
	PUSH	D2/A2
1$:	MOVEA.L	WINDOW,A0
	MOVE.L	wd_UserPort(A0),A0
	CALLSYS	GetMsg,SysBase		;msg ready?
	IFZL	D0,9$			;no
	MOVE.L	D0,A1
	MOVE.L	im_Class(A1),D2		;SAVE MSG CLASS
;	MOVE.W	im_Code(A1),MSG_CODE
	MOVE.L	im_IAddress(A1),GAD_PTR	;SAVE PTR TO POSSIBLE GADGET
	CALLSYS	ReplyMsg		;LET INTUITION KNOW WE HAVE IT
	MOVE.L	D2,D0			;return msg class in D0
	CMP.L	#REFRESHWINDOW,D0	;REFRESH REQUEST?
	BNE.S	2$
	BSR	RefreshWindow		;keep intuition happy
	BRA.S	1$

2$:	IFNEIL	D0,#REQSET,9$		;not REQSET
	MOVE.L	WINDOW,A1		;window
	LEA	REQUEST,A2
	MOVE.L	REQGAD,A0		;this is gadget to activate
	CALLSYS	ActivateGadget,IntuitionBase
	BRA	1$

9$:	POP	D2/A2
	RTS

* Move source string A0 into destination string A1.  At '@' insert string TMP. 
* At '%' insert string TMP2.

MoveInsert..
1$:	MOVE.B	(A0)+,D0		;get byte of source string
	BEQ	9$			;end of source
	CMP.B	#'@',D0			;insert TMP.?
	BEQ.S	2$			;yes
	CMP.B	#'%',D0			;insert TMP2.?
	BEQ.S	3$			;yes
	MOVE.B	D0,(A1)+		;else just save byte in dest string
	BRA.S	1$
2$:	PUSH	A0			;save ptr to where we are in msg
	LEA	TMP.,A0
	BRA.S	4$
3$:	PUSH	A0
	LEA	TMP2.,A0
4$:	MOVE.B	(A0)+,D0
	BEQ.S	5$			;end of "n" string
	MOVE.B	D0,(A1)+		;else store char
	BRA.S	4$			;loop
5$:	POP	A0
	BRA	1$
9$:	MOVE.B	D0,(A1)+		;terminate string
	RTS

* Colors the box of gadget in A0 to color in D0.

GadgetColor:
	MOVE.B	D0,D2
	MOVE.L	gg_LeftEdge(A0),D0
	MOVE.L	gg_Width(A0),D1
	BRA.S	CLEAR_BOX
;	BSR.S	CLEAR_BOX
;	RTS

* Clears the INSIDE of a box to the defined color.  Ptr to box data in A0.

ClearBox:
	MOVE.L	(A0)+,D0	;GET LE, TE
	MOVE.L	(A0)+,D1	;GET WD, HT
	MOVE.W	(A0)+,D2	;PEN COLORS
	ADD.L	#$20001,D0	;MOVE OVER BY 2, DOWN BY 1
	SUB.L	#$40002,D1	;REDUCE WIDTH BY 4, HT BY 2
	BSR.S	CLEAR_BOX	;CLEAR INSIDES TO PROPER COLOR
	RTS

* CLEARS A BOX TO THE COLOR IN D2.  LEFT, TOP IN D0, WIDTH, HT IN D1.

CLEAR_RBOX:
	MOVE.L	REQUEST+ReqLayer,A0
	MOVE.L	LayerRP(A0),A0
	BRA.S	CBcom

CLEAR_BOX:
	MOVE.L	WINDOW,A0
	MOVE.L	wd_RPort(A0),A0
CBcom:	LEA	IDATA,A1	;IMAGE DATA BLOCK
	MOVE.L	D0,(A1)		;L, T
	MOVE.L	D1,4(A1)	;W, H
	MOVE.B	D2,IPEN(A1)	;BORDER PEN
	ZAP	D0
	ZAP	D1
	CALLSYS	DrawImage,IntuitionBase
	RTS

* CLEARS THE WHOLE WINDOW

ClearWindow:
	MOVE.L	WINDOW,A0
	MOVE.L	wd_RPort(A0),A0
	LEA	WINI,A1
	ZAP	D0
	ZAP	D1
	CALLSYS	DrawImage,IntuitionBase
	MOVE.L	WINDOW,A0
	MOVE.W	wd_Height(A0),D1
	SUB.W	#9,D1
	MOVE.W	wd_Width(A0),D0
	SUB.W	#16,D0
	LEA	WINDSIZE,A1
	MOVE.L	wd_RPort(A0),A0
	CALLSYS	DrawImage
	RTS

* add gadget list in A0 to window and refresh too

AddGadgets:
	PUSH	A0
	MOVE.L	A0,A1
	MOVE.L	WINDOW,A0
	MOVEQ	#-1,D0
	MOVEQ	#-1,D1
	ZAPA	A2
	CALLSYS	AddGList,IntuitionBase
	POP	A0
	MOVE.L	WINDOW,A1
	ZAPA	A2
	MOVEQ	#-1,D0
	CALLSYS	RefreshGList
	RTS

RemoveGadgets:
	MOVE.L	A0,A1
	MOVE.L	WINDOW,A0
	MOVEQ	#-1,D0
	CALLSYS	RemoveGList,IntuitionBase
	RTS

RefreshWindow:
	PUSH	A6
	MOVE.L	WINDOW,A0
	CALLSYS	BeginRefresh,IntuitionBase	;KEEP INTUITION HAPPY
	MOVE.L	RefreshRoutine,A6		;specific refresh routine
	IFZL	A6,1$				;oops...no routine
	JSR	(A6)				;do it
1$:	MOVE.L	WINDOW,A0
	MOVEQ	#TRUE,D0			;COMPLETE
	CALLSYS	EndRefresh,IntuitionBase
	MOVE.L	WINDOW,A1
	ZAPA	A2
	MOVE.L	wd_FirstGadget(A1),A0
	CALLSYS	RefreshGadgets
	POP	A6
	RTS

* Called to display progess.  Offset from 0,0 in D0.  Percent complete
* given in pixels in D1 (active).
* Called at DISP_RBAR for requester in A0 or DISP_WBAR for window in A0.

DISP_WBAR:
	MOVE.L	wd_RPort(A0),A0
	BRA.S	DBar

DISP_RBAR:
	MOVE.L	ReqLayer(A0),A0		;point to layer
	MOVE.L	LayerRP(A0),A0		;point to rasterport
DBar:	PUSH	D2-D5/A2/A6
	MOVE.L	A0,A2			;raster port
	ZAP	D2
	ZAP	D3
	MOVE.W	D0,D2			;save x
	SWAP	D0
	MOVE.W	D0,D3			;save y
	MOVE.L	D1,D4			;save active pixel count
	MOVEQ	#BLACK,D0		;set A pen to black
	MOVE.L	A2,A1
	CALLSYS	SetAPen,GraphicsBase
	MOVEQ	#8-1,D5			;8 rows
1$:	MOVE.L	D2,D0			;x offset into rport
	ADD.W	D4,D0			;width offset
	MOVE.L	D3,D1			;y offset into rport
	MOVE.L	A2,A1			;rport
	CALLSYS	WritePixel		;do it
	INCW	D3			;increment y offset
	DBF	D5,1$			;loop for all rows
	POP	D2-D5/A2/A6
	RTS

	END
