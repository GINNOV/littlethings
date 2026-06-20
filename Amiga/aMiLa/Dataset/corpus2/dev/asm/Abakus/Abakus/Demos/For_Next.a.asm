
    Include "Abakus:I/StartWB"
    Include "Abakus:I/SLI"
    Include "Abakus:I/Tools1.m"

    Input  
    move.l  d0,stdin
    Output  
    move.l  d0,stdout

    move.b  #48,zz
    move.b  #57,d7
    bra _FCFORROUT_a1
_FCFORLOOP_a1
    add.b  #1,zz
    cmp.b  zz,d7
    blt _FCEXITFOR_a1
_FCFORROUT_a1
    Write  stdout,#zz,#1
    bra _FCFORLOOP_a1
_FCEXITFOR_a1

    Write  stdout,#lf,#1

    move.b  #"A",zz
    move.b  #"z",d7
    bra _FCFORROUT_a2
_FCFORLOOP_a2
    add.b  #3,zz
    cmp.b  zz,d7
    blt _FCEXITFOR_a2
_FCFORROUT_a2
    Write  stdout,#zz,#1
    bra _FCFORLOOP_a2
_FCEXITFOR_a2

    rts 
zz  dc.b 0
lf  dc.b 10
    Include "Abakus:I/Tools1.s"
    End
