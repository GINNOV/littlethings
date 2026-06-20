* PERSONAL MACROS

call Macro                   Define a macro for calling library
 move.l $4,a6                routines, This keeps the source tidy
 jsr _LVO\1(a6)              and shorter  
 Endm

plane Macro 		     Define macro for placing pic into
 move.w d0,\1		     plane pointers. The \1 and \2 is 
 swap d0 		     where the macro passes the parameters to.
 move.w d0,\2 		     ie. move.w d0,\1 is assembled as
 swap d0		     move.w d0,pl1l in line 37.
 add.l #$\3,d0	    	     Add plane size, ready for next plane.
 Endm
 
mouse Macro
 btst #6,Ciaapra
 bne.s \1
 Endm
  
