.KEY NAME,FD
.BRA {
.KET }

FailAt 99999999

Cd G5Lib:

Echo "*N{FD}"

If Not Exists MuAutoLib
	MakeDir MuAutoLib
EndIf

Cd G5Lib:MuAutoLib
GenAuto {FD}

Cd G5Lib:LibStubs/{NAME}/STD
List #?.o SORT N LFormat="%m" >t:OL
PmmLibr F G5Lib:AllMu t:OL

Cd G5Lib:LibStubs/{NAME}/040
List #?.o SORT N LFormat="%m" >t:OL
PmmLibr F G5Lib:AllMu_040 t:OL

Cd G5Lib:LibStubs/{NAME}/PPC
List #?.o SORT N LFORMAT="vbin:ar q G5Lib:AllMu_ppc.a %n" > G5Lib:LibStubs/{NAME}/Make_AllMu.LibPPC
Execute G5Lib:LibStubs/{NAME}/Make_AllMu.LibPPC

Cd G5Lib:LibStubs/{NAME}/WOS
List #?.o SORT N LFormat="%m" >t:OL
PmmLibr F G5Lib:AllMu_wos t:OL
