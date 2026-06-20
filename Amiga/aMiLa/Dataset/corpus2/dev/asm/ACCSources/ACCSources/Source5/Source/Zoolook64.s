; 64 colour Zoolook, almost all code by Mike Cross, minor mods by Nipper.

; The reason for including such a simple modification of the code is this:
; I couldn`t get 64-colour pictures to show properly - some of the first 32
; (true) colours were mucked up. It may be my mods, or it may be the IFF
; convertor. Who knows? I sent this so you could find out!

;  You must change the value in BPLCON0 if you are changing the display mode.
;For a display of EHB in LO-RES you should set BPLCON0=%0110001000000000. If
;you read Mikes first tutorial all this is explained. M.Meany Sept 90.

     
	opt	c-
  Section Zoolook,code_c     Chip mem only   

 Incdir "sys:include/"   	     Change it to Incdir "include:" on Argasm
 Include "exec/exec_lib.i"   Read library offsets from assembler disk  
 incdir  "source5:include/"
 Include "my_hardware.i"       Custom chip offsets  
 Include "macros_mc.i"          Define some macros

  
* START OF CODE *

 lea $dff000,a5	             Offset for hardware registers
 
 call Forbid                 Use defined macro to disable multi-tasking

 move.l #Picture,d0          Call up the incbin graphics from disk
 plane pl1l,pl1h,2800        Use the macro to put each of the  	       
 plane pl2l,pl2h,2800	     6 planes into the pointers in the
 plane pl3l,pl3h,2800	     copper list
 plane pl4l,pl4h,2800	     Pl4l and Pl6h - dest, 2800 - plane size(Hex)
 plane pl5l,pl5h,2800
 plane pl6l,pl6h,2800

 lea Colours,a3              D0 points to the colour table,
 move.l d0,a4                Which is placed into the colour   
 move.w #$180,d0       	     registers beginning at $dff180
 moveq #63,d5		     63 colours - exclding $180
Colloop	
 move.w d0,(a3)+	     Move first colour in, and increment pointer
 move.w (a4)+,(a3)+          And repeat for all colours
 addq.w #2,d0		     By adding two to register pointer
 dbra d5,Colloop             Exit loop when done

 lea Gfxname,a1     	     Get library name
 moveq #0,d0                 No particular version
 call OpenLibrary	     Open graphics library
 tst.l d0		     Was it hunkey dorey?
 beq.s Get_out_quick	     If not - fast exit 
 move.l d0,a1                Save old address
 move.l 38(a1),Old     	     Save old copper address
 call CloseLibrary	     Close graphics library
 move.w #$0020,dmacon(a5)    Disable sprites (Horizontal flickers!)
 move.l #Newcop,cop1lch(a5)  Insert new copper data
 
Wait
 mouse Wait		     Look in Macros.i to see how it works
 move.l Old,cop1lch(a5)      Restore copper
 move.w #$83e0,dmacon(a5)    Restore DMA channel
Get_out_quick  		    
 call Permit	             Restore multi-tasking
 rts			     Exit

Newcop                   
 dc.w diwstrt,$2c81          Top left of screen
 dc.w diwstop,$2cc1          Bottom right of screen - PAL ($F4c1 for NTSC)
 dc.w ddfstrt,$38            Data fetch start
 dc.w ddfstop,$d0            Data fetch stop
 dc.w bplcon0,%0110001000000000          Select EHB 64 colour 
 dc.w bplcon1,0              No horizontal offset

Colours ds.w 128             Space for 64 colour registers 
 
     dc.w bpl1pth            Plane pointers for 6 planes
pl1h dc.w 0,bpl1ptl          
pl1l dc.w 0,bpl2pth
pl2h dc.w 0,bpl2ptl
pl2l dc.w 0,bpl3pth
pl3h dc.w 0,bpl3ptl
pl3l dc.w 0,bpl4pth
pl4h dc.w 0,bpl4ptl
pl4l dc.w 0,bpl5pth
pl5h dc.w 0,bpl5ptl
pl5l dc.w 0,bpl6pth
pl6h dc.w 0,bpl6ptl
pl6l dc.w 0

     dc.w $ffff,$fffe        End of copper list
 
Old  dc.l 0
Gfxname dc.b "graphics.library",0
        even
Picture Incbin "source5:bitmaps/AussieBranch.bm"    Some gfx by RevOz.

