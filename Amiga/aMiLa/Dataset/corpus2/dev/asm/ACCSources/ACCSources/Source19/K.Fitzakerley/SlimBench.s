;SLIMDISK was written by Kevan Fitzakerley
;                        199 Taylor Street
;                        Toowoomba, Queensland.
;                        AUSTRALIA 4350
;
;     Using the Amiga Coders Club assembler.

openlib        = -408
closelib       = -414
execbase       = 4
open           = -30
close          = -36
execute        = -222
ioerr          = -132
mode_old       = 1005
alloc_abs      = -$cc
write          = -48
getkey         = $bfec01

run:
        bsr     init
        bra     test
init:
        move.l  execbase,a6
        lea     dosname(pc),a1
        moveq   #0,d0
        jsr     openlib(a6)
        move.l  d0,dosbase
        beq     error
        lea     consolname(pc),a1
        move.l  #mode_old,d0
        bsr     openfile
        beq     error
        move.l  d0,conhandle
        rts
test:
        move.l  #signon,d0
        bsr     pmsg
        bsr     command
        move.l  #$7fffff,d6
loop1:
        move.l  #$7f,d5
loop2:
        dbra    d5,loop2
        dbra    d6,loop1
        bra     qu


press:
        move.b  getkey,d0       ;wait till ENTER is pressed
        cmp.b   #$77,d0         ;'enter' has been pressed
        bne     press           ;jump back to format
        rts
command:
format:
        move.l  #insert,d0
        bsr     pmsg
        bsr     press
        move.l  #formatting,d0
        bsr     pmsg
        move.l  dosbase,a6
        move.l  #command1,d1
        clr.l   d2             ;  This will format the disk in DF1:
        move.l  conhandle,d3
        jsr     execute(a6)
copy_C:
        move.l  dosbase,a6
        move.l  #command2,d1   ;  This will create and the copy "C" dir
        clr.l   d2
        move.l  conhandle,d3
        jsr     execute(a6)
copy_DEVS:
        move.l  dosbase,a6
        move.l  #command3,d1   ;  This will create and copy the "Devs" dir
        clr.l   d2
        move.l  conhandle,d3
        jsr     execute(a6)
copy_devs_CONFIG:
        move.l  dosbase,a6
        move.l  #command4,d1
        clr.l   d2
        move.l  conhandle,d3
        jsr     execute(a6)
copy_L:
        move.l  dosbase,a6
        move.l  #command5,d1   ;  This will create and copy the "L" dir
        clr.l   d2
        move.l  conhandle,d3
        jsr     execute(a6)
copy_LIBS:
        move.l  dosbase,a6
        move.l  #command6,d1   ;  This will create and copy the "Libs" dir
        clr.l   d2
        move.l  conhandle,d3
        jsr     execute(a6)
copy_S:
        move.l  dosbase,a6
        move.l  #command7,d1   ;  This will create the "S" dir
        clr.l   d2
        move.l  conhandle,d3
        jsr     execute(a6)
make_SCRIPT1:
        move.l  dosbase,a6
        move.l  #command8,d1   ;  This will write part 1 of the "SUS"
        clr.l   d2
        move.l  conhandle,d3
        jsr     execute(a6)
make_SCRIPT2:
        move.l  dosbase,a6
        move.l  #command9,d1   ;  This will write part 2 of the "SUS"
        clr.l   d2
        move.l  conhandle,d3
        jsr     execute(a6)
make_BOOTBLOCK:
        move.l  dosbase,a6
        move.l  #command10,d1  ;  This will write the BootBlock
        clr.l   d2
        move.l  conhandle,d3
        jsr     execute(a6)
make_EMPTY:
        move.l  dosbase,a6
        move.l  #command11,d1  ;  This will create the empty dir
        clr.l   d2
        move.l  conhandle,d3
        jsr     execute(a6)
copy_DRAWER:
        move.l  dosbase,a6
        move.l  #command12,d1  ;  This will copy the drawer & the disk.info
        clr.l   d2             ;  files to df1:
        move.l  conhandle,d3
        jsr     execute(a6)
        move.l  #le_end,d0
        bsr     pmsg
        rts
error:
        move.l  dosbase,a6
        jsr     ioerr(a6)
        move.l  d0,d5
        move.l  #-1,d7
qu:
        move.l  conhandle,d1
        move.l  dosbase,a6
        jsr     close(a6)
        move.l  dosbase,a1
        move.l  execbase,a6
        jsr     closelib(a6)
openfile:
        move.l  a1,d1
        move.l  d0,d2
        move.l  dosbase,a6
        jsr     open(a6)
        tst.l   d0
        rts
pmsg:
        movem.l d0-d7/a0-a6,-(sp)
        move.l  d0,a0
        move.l  a0,d2
        clr.l   d3
mess1:
        tst.b   (a0)+
        beq     mess2
        addq.l  #1,d3
        bra     mess1
mess2:
        move.l  conhandle,d1
        move.l  dosbase,a6
        jsr     write(a6)
        movem.l (sp)+,d0-d7/a0-a6
        rts
dosname:       dc.b    "dos.library",0,0
consolname:    dc.b    "CON:10/10/500/100/SlimDisk V1.0",0
insert:        dc.b    13,10,10,10,"Please Insert Disk in Drive DF1:"
               dc.b    " and Press RETURN",13,10,10,0
formatting:    dc.b    13,"FORMATTING DF1:",13,0

le_end:        dc.b    13,10,10,"SlimDisk COMPLETE.......Please Wait",0
command1:      dc.b    "sys:system/format >NIL: drive df1: name SlimDisk_V1.0 noicons",0
command2:      dc.b    "copy c/loadwb|endcli|cd|dir|copy|delete"
               dc.b    "|run|execute|stack|info|path|list df1:c",0
command3:      dc.b    "makedir df1:devs",0
command4:      dc.b    "copy devs/system-configuration df1:devs",0
command5:      dc.b     "copy l/disk-validator|ram-handler|port"
               dc.b     "-handler df1:l",0
command6:      dc.b     "copy libs/diskfont.library|icon.library"
               dc.b     "|info.library df1:libs",0
command7:      dc.b     "makedir df1:s",0
command8:      dc.b     "echo > df1:s/startup-sequence loadwb",0
command9:      dc.b     "echo >> df1:s/startup-sequence endcli",0
command10:     dc.b     "install df1:",0
command11:     dc.b     "makedir df1:empty",0
command12:     dc.b     "copy empty.info|disk.info df1:",0
signon:        dc.b     12,"SlimDisk V1.0 ©Dec 1991",10,13
               dc.b     "Kevan Fitzakerley and Friends",10,13,0
               even
dosbase:       dc.l    0
conhandle:     dc.l    0
               end