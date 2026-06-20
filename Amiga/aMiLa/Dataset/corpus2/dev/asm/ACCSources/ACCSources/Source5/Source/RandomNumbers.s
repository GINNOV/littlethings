;This is a very simple program, which creates a random number (by
;using the verticle beam position) and then uses a macro to output
;the appropriate text.
;   Use it as you wish. Daniel Owens

    opt c-

    IncDir  "df0:include/"
    Include "exec/exec.i"
    Include "exec/exec_lib.i"
    Include "graphics/graphics_lib.i"
    Include "libraries/dos_lib.i"

DOSTEXT     macro           ;Text display macro
    move.l  handle,d1       
    move.l  #.TEXT\@,d2
    move.l  #TEXT_L\@,d3
    CALLDOS Write
    bra .TEXT_LABEL\@
.TEXT\@     dc.b    \1
TEXT_L\@    equ *-.text\@
.TEXT_LABEL\@   nop
    endm

    move.l  #GRAFNAME,a1        ;Open the Libraries
    move.l  #$0,d0
    CALLEXEC OpenLibrary
    move.l  d0,_GFXBase
    move.l  #DOSName,a1
    move.l  #$0,d0
    CALLEXEC OpenLibrary
    move.l  d0,_DOSBase
    CALLDOS Output
    move.l  d0,handle
    jsr     Printi
    CALLGRAF VBeamPos       ;Get Random Number
    move.l  d0,Number
    jmp do_it

clear   jsr clean_up
    jsr end

end btst    #6,$bfe001
    bne.s   end
    rts
    
error   move.l  _GFXBase,a1
    CALLEXEC CloseLibrary
    rts

clean_up                ;Clean up and exit
    move.l  _GFXBase,a1
    CALLEXEC CloseLibrary
    move.l  _DosBase,a1
    CALLEXEC CloseLibrary
    rts

do_it   DOSText <$a,"The Guru says,",$a>
    cmp.l   #$1c2,Number        ;Find appropriate text
    bge comment1        ;then jump to appropriate
    cmp.l   #$196,Number        ;display route
    bge comment2
    cmp.l   #$15e,Number
    bge comment3
    cmp.l   #$12c,Number
    bge comment4
    cmp.l   #$fa,Number
    bge comment5
    cmp.l   #$c8,Number
    bge comment6
    cmp.l   #$96,Number
    bge comment7
    cmp.l   #$64,Number
    bge comment8
    cmp.l   #$32,Number
    bge comment9
    jmp commentA
                    ;text
comment1
    DOSText <$a,"   Do not buy Atari",$a>
    jmp clear
comment2
    DOSText <$a,"   I HATE ALL Compilers",$a>
    jmp clear
comment3
    DOSText <$a,"   Well at least I contributed something!",$a>
    jmp clear
comment4
    DOSText <$a,"   Plug me in to a Sega!!",$a>
    jmp clear
comment5
    DOSText <$a,"   Hoch ein Bier!!!!",$a>
    jmp clear
comment6
    DOSText <$a,"   McDognald....",$a,"     Kotz dich frei, hab spass da bei!!",$a>
    jmp clear
comment7
    DOSText <$a,"   This proggy was coded by Daniel",$a>
    jmp clear
comment8
    DOSText <$a,"   Sorry Daniel..line censored!",$a,"....Pitty he isnt",$a>
    jmp clear
comment9
    DOSText <$a,"   I like Megadeth",$a>
    jmp clear
commentA
    DOSText <$a,"   BOO!",$a>
    jmp clear
Printi  DOSTEXT <$a,"Hello fellow coders!",$a>
    rts

DOSName dc.b    'dos.library',0
    even
_GfxBase    dc.l    0
    even
_DOSBase    dc.l    0
    even
Number  dc.l    0
    even
handle  dc.l    0
    even
GRAFNAME    dc.b    'graphics.library',0
    even