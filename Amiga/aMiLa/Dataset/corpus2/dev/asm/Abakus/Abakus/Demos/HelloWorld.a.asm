
    Include "Abakus:I/StartCLI"
    Include "Abakus:I/SLI"
    Include "Abakus:I/Tools1.m"

    Input  stdin
    Output  stdout

    Write  stdout,#HelloWorld,#HWln
    rts 

HelloWorld dc.b "Hello World",10
HWln      equ *-HelloWorld

    Include "Abakus:I/Tools1.s"
    End
