
    Include "Abakus:I/StartWB"
    Include "Abakus:I/SLI"
    Include "Abakus:I/Tools1.m"


    Input  stdin
    Output  stdout
    raw  

    GetCurrentDirName  #puff,#100
    AssignLate  #Abakus,#puff
    Execute  #assi,#0,#0
    Write  stdout,#jn,#len4
warten
    Waits  warten
    ReadsChar  #x

    move.b  x,d7
    cmp.b  #13,d7
    beq ja
    cmp.b  #"j",d7
    beq ja
    cmp.b  #"J",d7
    beq ja
aus
    rts 

ja
    Write  stdout,#ok,#len5

    Open  #us,#1005,usad
    tst.l  d0
    beq aus

    Seek  usad,#0,#1
    Write  usad,#begABK,#len1
    Write  usad,#assi1,#len6

    ;Write0 usad #puff
    lea  puff,a3

_FC_REP_a
    Write  usad,a3,#1
    add.l  #1,a3
    tst.b  (a3)
    bne _FC_REP_a
_FC_EXREP_a

    Write  usad,#lf,#1
    Write  usad,#assi,#len2-1
    Write  usad,#endABK,#len3

    Close  usad
    rts 


Abakus    dc.b "Abakus",0


begABK    dc.b 10,";Beginn Abakus",10
len1      equ *-begABK

puff      ds.b 100

endABK    dc.b 10,";End Abakus",10
len3      equ *-endABK

assi1     dc.b "Assign Abakus: "
len6      equ *-assi1

assi      dc.b "c:Assign c: Abakus:c add",0
len2      equ *-assi

ok        dc.b "Assign wird angehängt.",10
len5      equ *-ok

jn        dc.b "Assign in User-Startup einfügen (J/n) ? ",0
len4      equ *-jn
us        dc.b "s:user-startup",0

x         ds.b 2

lf        dc.b 10

    cnop  0,4
usad      ds.l 1
    Include "Abakus:I/Tools1.s"
    End
