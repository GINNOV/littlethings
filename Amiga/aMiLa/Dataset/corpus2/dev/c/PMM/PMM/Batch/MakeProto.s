.KEY PFAD,PROTOH
.BRA {
.KET }

Echo "Prototypen erstellen, falls nötig!"
FailAt 999
Delete T:Pmm#? QUIET >NIL:
Delete T:Tmp#? QUIET >NIL:
List {PFAD}/#?.c lformat="Setenv PMMCHECK=%s *N Execute Pmm:batch/GenProto.s" >T:Pmm-Tmp-Script
SetEnv PMMIN={PFAD}
Execute T:Pmm-Tmp-Script
Sort T:Tmp-Proto T:Pmm-Proto
PmmTool -c T:Pmm-Proto {PROTOH} >NIL:
If NOT WARN
	Echo "Prototypen sind aktuell"
Else
	Copy T:Pmm-Proto {PROTOH}
EndIf
Delete Env:PMMCHECK QUIET >NIL:
Delete Env:PMMIN QUIET >NIL:
Delete T:Pmm#? QUIET >NIL:
Delete T:Tmp#? QUIET >NIL:
