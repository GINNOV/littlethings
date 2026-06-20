.KEY NAME,FD
.BRA {
.KET }

FailAt 99999999

Cd G5Lib:

Echo "*N{FD}"

Cd G5Lib:LibStubs/{NAME}/STD
List #?.o SORT N LFormat="%m" >t:OL
PmmLibr F G5Lib:All t:OL

Cd G5Lib:LibStubs/{NAME}/040
List #?.o SORT N LFormat="%m" >t:OL
PmmLibr F G5Lib:All_040 t:OL

Cd G5Lib:LibStubs/{NAME}/PPC
List #?.o SORT N LFORMAT="vbin:ar q G5Lib:All_ppc.a %n" > G5Lib:LibStubs/{NAME}/Make_All.LibPPC
Execute G5Lib:LibStubs/{NAME}/Make_All.LibPPC

Cd G5Lib:LibStubs/{NAME}/WOS
List #?.o SORT N LFormat="%m" >t:OL
PmmLibr F G5Lib:All_wos t:OL
