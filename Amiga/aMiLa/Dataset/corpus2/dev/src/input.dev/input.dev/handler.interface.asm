*
*	DISCLAIMER:
*
*	This program is provided as a service to the programmer
*	community to demonstrate one or more features of the Amiga
*	personal computer.  These code samples may be freely used
*	for commercial or noncommercial purposes.
* 
* 	Commodore Electronics, Ltd ("Commodore") makes no
*	warranties, either expressed or implied, with respect
*	to the program described herein, its quality, performance,
*	merchantability, or fitness for any particular purpose.
*	This program is provided "as is" and the entire risk
*	as to its quality and performance is with the user.
*	Should the program prove defective following its
*	purchase, the user (and not the creator of the program,
*	Commodore, their distributors or their retailers)
*	assumes the entire cost of all necessary damages.  In 
*	no event will Commodore be liable for direct, indirect,
*	incidental or consequential damages resulting from any
*	defect in the program even if it has been advised of the 
*	possibility of such damages.  Some laws do not allow
*	the exclusion or limitation of implied warranties or
*	liabilities for incidental or consequential damages,
*	so the above limitation or exclusion may not apply.
*

*************************************************************************
*   HandlerInterface()
*
*   This code is needed to convert the calling sequence performed by
*   the input.task for the input stream management into something
*   that a C program can understand.
*
*   This routine expects a pointer to an InputEvent in A0, a pointer
*   to a data area in A1.  These values are transferred to the stack
*   in the order that a C program would need to find them.  Since the
*   actual handler is written in C, this works out fine. 
*
*   Author: Rob Peck, 12/1/85
*
    XREF	_myhandler
    XDEF	_HandlerInterface

_HandlerInterface:
    MOVEM.L	A0/A1,-(A7)
    JSR		_myhandler
    ADDQ.L	#8,A7
    RTS

    END

