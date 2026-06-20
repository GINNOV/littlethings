* 69.asm  Custom Requester     version 0.00     1.9.97


 include 'Front.i'


; When tandem.library makes a requester, it will "attach" it to the
; currently popped window, i.e. it will use the following data in the
; currently popped window:

;   xxp_ReqLeft    ;the requester xpos in the screen
;   xxp_ReqTop     ;the requester ypos in the screen
;   xxp_RFont      ;the font num
;   xxp_RFsty      ;the font style
;   xxp_RTspc      ;the text spacing

; And when the requester is removed, the owning window will again be the
; currently popped window. Values are given to xxp_RFont,RFsty & RTspc from
; xxp_pref(a4) when a window is opened, but you may poke new values there
; to over-ride the preferences, before calling the requester.

; But if there is no currently popped window, the requester is placed at
; screen position 0,0 and font num, style & tspace come from xxp_pref(a4).

; The process is:

;  1. create a workspace in the stack for setting up
;  2. call TLreqredi to do the initial setting up
;  3. TLreqredi puts default values in xxp_prfp(a4). These are pens &c
;     which your requester uses. You can over-ride these - in the program
;     below I insert the prefs for TLReqinfo-type requesters into xxp_prfp
;     which conveys the TLReqinfo user prefs to your custom requester.
;  4. xxp_prefp(a4) has the following things, which I recommend you use
;     in the drawing of your custom requester:
;     a. xxp_prfp+0  background pen
;     b. xxp_prfp+1  title pen (highlighted text)
;     c. xxp_prfp+2  text pen
;     d. xxp_prfp+3  horizontal gaps  } Used for "spreading out" your
;     e. xxp_prfp+4  vertical gaps    } requester
;  5. calculate the requester size. It if is too big, progressively do
;     the following:
;     a. poke 0 into xxp_RTspc
;     b. call TLnewfont #0,#0,#1 to attach Topaz/8
;     c. poke 0 into xxp_prfp+3
;     d. poke 0 into xxp_prfp+4
;     if it still won't fit, you have to re-design your requester. e.g. by
;     using TLTabs in it.
;  6. after width & height are calulated, call TLreqchek, which readies the
;     data in xxp_reqx,reqy,reqw,reqh. You can poke new values into
;     reqx & reqy after that to reposition the requester (but you must
;     make sure its bottom left will be on the screen).
;  7. your subroutine should then test xxp_ReqNull, and return if it is
;     null. (callers can set ReqNull to 0 to check the size & posn of the
;     requester).
;  8. Now, call TLreqon which actually turns the requester on. It will be
;     a blank window coloured in with the background pen in xxp_prfp.
;     (to over-ride that, poke a temporary value in xxp_prfp during TLreqon)
;  9. Now render the requester, using the above xxp_prfp data.
;     You may find TLbutprt,TLbuttxt,TLslider,TLtabs helpful in setting up
;     gadget-like areas on your requester. tandem.library rendering routines
;     TLreqarea,TLellipse,TLreqbev,TLgetilbm,TLpict may also be useful in
;     decorating the requester. TLreqedit has lots of options for font
;     display.
; 10. Attach help to your requester if applicable (using xxp_Help).
; 11. Your program may also do the following:
;     (a) poke a subroutine address into xxp_hook1(a4) which will be called
;         by TLreqon after it calculates the requester dimensions. You can
;         use that ot enlarge the requester for adding logos &c.
;     (b) poke a subroutine address into xxp_hook2(a4) which will be called
;         after your requester is drawn (after step 9 above).
;     If you do either of the above, you must at the beginning of your
;     requester program MOVEM.L D0-D7/A0-A6,-(A6) and then poke A7 to
;     xxp_Stak(a4), since hooks might want to know the register values
;     with which your requester program was called. Obviously, you will only
;     use hooks with "generic" type requesters which you plan to use in
;     many programs, like the requesters in tandem.library itself. Note
;     also that after TLreqon uses xxp_hook1 it puts 0 in it, to stop it
;     being accidentally left on, and your program should do the same after
;     testing xxp_hook2. Your program should pass A4 to the hooks, and
;     expect the hooks to trash all the registers (except A7 of course).
; 11. Call TLkeyboard for user response.
; 12. Process the user response. e.g.:
;     a. Call TLbutmon to see if buttons from TLbutprt have been clicked
;     b. Call TLslimon to see if slider(s) from TLslider have been clicked
;     c. Call TLtabmon to see if thumbtabs from TLtabs have been clicked
;     d. If an editable text area has been clicked, call TLReqedit
;     If the processing of the user input requires some redrawing of your
;     requester, go back to step 9. If not, go back to step 11. If the user
;     clicks a "Save" or "Cancel" button, or the "Esc" key, go to step 14.
;     TLmultiline may be useful for typing a series of strings into a
;     buffer.
; 13. Of course, while step 12 is taking place, your program will be putting
;     the effects of your users requests into its data sections, for
;     appropriate action when the requester closes. A sophisticated program
;     might even have another task acting on the data as the user
;     specifies it.
; 13. When the requester is ready to close, call TLreqoff.
; 14. It is probably best to call TLwslof, to remove clicks the user has
;     made off the requester window, after calling TLreqoff. tandem.library
;     requesters operate "synchronously", i.e. everything else in the
;     calling program stops until the requester is closed), which may not
;     be pleasing to the user, but in my opinion it is still worse to
;     have a delayed response to a click of another window some time later.
; 15. It is quite in order for requesters to do "power" things like loading
;     and running other programs, opening sub-windows & the like.


width: dc.l 100  ; dummy width & height for the
height: dc.l 50  ; requester below


strings: dc.b 0
 dc.b 'Error: out of memory',0 ;1
 dc.b 'Click me!',0 ;2
 ds.w 0


* here is the "skeleton" of a custom requester.
Program:
 TLwindow #-1
 beq Pr_bad

 bsr Custom
 bra.s Pr_quit

Pr_bad:                     ;here if out of mem
 TLbad #1

Pr_quit:
 rts


* make a custom requester (with nothing on it)
Custom:
 movem.l d0-d7/a0-a6,-(a7) ;save all
 sub.w #xxp_WPort+4,a7     ;create dummy part xxp_wsuw

 move.l a7,a5              ;a5 points to dummy part xxp_wsuw
 TLreqredi a5              ;set pop window, default values to xxp_prfp
 beq .bad                  ;go if TLReqredi fails - unlikely

 move.l xxp_pref(a4),a0    ;prefs to prfp  } Optional:
 move.l xxp_yinf(a0),xxp_prfp(a4)          } Use prefs for TLReqinfo-type
 move.l xxp_yinf+4(a0),xxp_prfp+4(a4)      } requesters (but must set prfp)


                           ;calculate requester size: set width,height
                           ;(adjust prfp & font if necessary to make it fit)


 TLreqchek width,height    ;check req size & position
 beq .bad                  ;go if won't fit

 tst.w xxp_ReqNull(a4)     ;quit ok if ReqNull=0
 beq .wrap

 TLreqon a5                ;open requester window
 beq .bad                  ;go if can't

 move.b xxp_prfp+2(a4),xxp_FrontPen(a5)  ;} Set pens to TLReqinfo
 move.b xxp_prfp(a4),xxp_BackPen(a5)     ;} prefernces (see above)

                           ;attach help

.draw:                     ;draw requester

 TLstring #2,#5,#6

.wait:                     ;wait for user response
 TLwfront
 TLkeyboard

 cmp.b #$80,d0             ;process user response, branching to
 bne .wait                 ;  draw - if requester to be re-drawn
                           ;  wait - if requester not to be re-drawn
                           ;  clos - if user requested OK/Cancel &c


.clos:
 TLreqoff                  ;close requester window
 moveq #-1,d0              ;signal ok
 bra.s .wrap               ;return ok

.bad:
 moveq #0,d0               ;too big/can't open window

.wrap:
 move.w #-1,xxp_ReqNull(a4) ;leave ReqNull<>0
 TLwslof
 tst.l d0                  ;EQ if bad
 add.w #xxp_WPort+4,a7
 movem.l (a7)+,d0-d7/a0-a6
 rts
