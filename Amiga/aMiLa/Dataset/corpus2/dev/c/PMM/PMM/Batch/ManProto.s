.KEY PFAD,PROTOH
.BRA {
.KET }

Echo "Prototypen erstellen, falls nötig!"
FailAt 20
Delete T:Pmm#? QUIET
Delete T:Tmp#? QUIET
List {PFAD}/#?.c lformat="Protoman %s%s O=T:Tmp-Proto AP" >T:Pro.s
Execute T:Pro.s
Sort T:Tmp-Proto T:Pmm-Proto
PmmTool -c T:Pmm-Proto {PROTOH}
If NOT WARN
	Echo "Prototypen sind aktuell"
Else
	Copy T:Pmm-Proto {PROTOH}
EndIf
Delete T:Pmm#? QUIET
Delete T:Tmp#? QUIET
