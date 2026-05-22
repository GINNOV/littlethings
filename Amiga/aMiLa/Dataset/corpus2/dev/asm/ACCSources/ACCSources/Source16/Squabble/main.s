        **************************
        *                        *
        * Squamble Source Code   *
        *                        *
        * Main.s                 *
        *                        *
        * John Kennedy June 1991 *
        *                        *
        * From Amiganuts United  *
        *                        *
        **************************




MUSIC equ 1     * Tunes playing?
FLOPPY equ 1        * Switch off floppy disk?

    INCDIR Source:Squabble/

    section main,code_c
    
    include "xref.include"

    IFNE MUSIC
    bsr InitPlayer
    cmp.w #0,d0
    beq ok
    rts
ok
    bsr Relocate_modules
    ENDC

    IFNE FLOPPY
    move.l #$bfd100,a0
    move.w #$8000,(a0)
    ENDC

    include "custom.header"
    include "forbid.include"
    
    bsr Title_Screen
    move.w #2,game_flag 
    bsr InterOn

    
loop
    btst #6,$bfe001
    beq.s quit1
 
    bra loop

quit1   

    IFNE MUSIC
    bsr StopPlayer
    bsr RemPlayer
    ENDC

    bra quit

    include "permit.include"

    * Level Three *

newlevel3
    movem.l d0-d7/a0-a6,-(sp)
    
    and.w #$10,INTREQR+CUSTOM
    beq.s out
    move.w #$10,INTREQ+CUSTOM

    cmp.w #0,intflag
    beq  out 
    
    lea CUSTOM,a6
    bsr Control
    
out movem.l (sp)+,d0-d7/a0-a6
    even
    dc.w $4ef9
oldlevel3
    dc.l 0
    even
oldcpr
    dc.l 0
    even
GFXNAME dc.b "graphics.library",0,0,0,0
    even
    include "control.include"
    include "debug.include"
    include "screen.include"
    include "objects.include"
    include "enemy.include"
    include "weapons.include"
    include "landscape.include"
    include "variables.include"
    include "explode.include"
    include "sound.include"
    include "spiker.include"
    include "bumph.include"

    IFNE MUSIC
    include "medplayer.include"
    ENDC

    even
gfxbase dc.l 0
    even
    include "data.include"
    end
