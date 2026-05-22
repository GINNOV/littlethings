.KEY NAME,FD
.BRA {
.KET }

FailAt 99999999

Cd G5Lib:

Echo "*E[0;0H*E[J{FD}*N*N"

If Not Exists Libstubs/{NAME}
	MakeDir LibStubs/{NAME}
EndIf
If Not Exists Libstubs/{NAME}/STD
	MakeDir LibStubs/{NAME}/STD
EndIf
If Not Exists Libstubs/{NAME}/040
	MakeDir LibStubs/{NAME}/040
EndIf
If Not Exists Libstubs/{NAME}/PPC
	MakeDir LibStubs/{NAME}/PPC
EndIf
If Not Exists Libstubs/{NAME}/WOS
	MakeDir LibStubs/{NAME}/WOS
EndIf
If Not Exists AutoLib
	MakeDir AutoLib
EndIf

PmmTool -n {FD} G5Lib:{NAME}.Lib
If WARN
	Echo "Erstelle {NAME}.Lib"
	Cd G5Lib:AutoLib
	GenAuto {FD}
	Cd G5Lib:LibStubs/{NAME}
	MakeDir std 040 ppc wos
	Delete G5Lib:{NAME}.#?
	Delete G5Lib:{NAME}_#?

	Cd G5Lib:LibStubs/{NAME}/STD
	FD2Lib {FD}
	List #?.s SORT N LFormat="PhxAss Q %s" > G5Lib:LibStubs/{NAME}/Make_{Name}.AsmSTD
	Execute G5Lib:LibStubs/{NAME}/Make_{Name}.AsmSTD
    Delete G5Lib:All.???
    Delete G5Lib:AllMu.???
	List #?.o SORT N LFormat="%m" >t:OL
    PmmLibr F G5Lib:{NAME} t:OL
Else
	Echo "{NAME}.Lib ist aktuell!"
EndIf

PmmTool -n {FD} G5Lib:{NAME}_040.Lib
If WARN
	Echo "Erstelle {NAME}_040.Lib"
	Cd G5Lib:LibStubs/{NAME}/040
	FD2Lib -40 {FD}
	List #?.s SORT N LFormat="PhxAss Q %s" > G5Lib:LibStubs/{NAME}/Make_{Name}.Asm040
	Execute G5Lib:LibStubs/{NAME}/Make_{Name}.Asm040
    Delete G5Lib:All_040.???
    Delete G5Lib:AllMu_040.???
	List #?.o SORT N LFormat="%m" >t:OL
    PmmLibr F G5Lib:{NAME}_040 t:OL
Else
	Echo "{NAME}_040.Lib ist aktuell!"
EndIf

PmmTool -n {FD} G5Lib:{NAME}_PPC.a
If WARN
	Echo "Erstelle {NAME}_ppc.a"
	Cd G5Lib:LibStubs/{NAME}/PPC
	FD2LibPPC {FD}
	List #?.s SORT N LFormat="vbin:Pasm_wos -R -F1 -O65536 %s" > G5Lib:LibStubs/{NAME}/Make_{Name}.AsmPPC
	Execute G5Lib:LibStubs/{NAME}/Make_{Name}.AsmPPC
    Delete G5Lib:All_ppc.a
    Delete G5Lib:AllMu_ppc.a
    Delete G5Lib:{NAME}_ppc.a
	List #?.o SORT N LFORMAT="vbin:ar q G5Lib:{NAME}_ppc.a %n" > G5Lib:LibStubs/{NAME}/Make_{Name}.LibPPC
	Execute G5Lib:LibStubs/{NAME}/Make_{Name}.LibPPC
Else
	Echo "{NAME}_PPC.a ist aktuell!"
EndIf

PmmTool -n {FD} G5Lib:{NAME}_WOS.lib
If WARN
	Echo "Erstelle {NAME}_wos.Lib"
	Cd G5Lib:LibStubs/{NAME}/WOS
	FD2LibWOS {FD}
	List #?.s SORT N LFormat="vbin:Pasm_wos -F2 -O65536 %s" > G5Lib:LibStubs/{NAME}/Make_{Name}.AsmWOS
	Execute G5Lib:LibStubs/{NAME}/Make_{Name}.AsmWOS
    Delete G5Lib:All_wos.???
    Delete G5Lib:AllMu_wos.???
	List #?.o SORT N LFormat="%m" >t:OL
    PmmLibr F G5Lib:{NAME}_wos t:OL
Else
	Echo "{NAME}_WOS.Lib ist aktuell!"
EndIf
