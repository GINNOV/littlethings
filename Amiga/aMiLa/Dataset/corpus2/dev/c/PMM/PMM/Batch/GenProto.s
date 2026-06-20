FailAt 20

ChangeTaskPri 5
Cd $PMMIN

if Exists $PMMCHECK_PMM
	Execute "$PMMCHECK_PMM"
Else
	Pmm:bin/GenProto -b "-f%R\t%N %P;\t\t/** %F\t**/\n" "$PMMCHECK" >> T:Tmp-Proto
EndIf
