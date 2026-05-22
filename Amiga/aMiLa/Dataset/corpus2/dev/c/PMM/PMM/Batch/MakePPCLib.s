.KEY OBJ,LIB
.BRA {
.KET }

FailAt 99999999

List {OBJ} Sort N LFormat="vbin:ar q {LIB} %s%s" >t:PPC
Cd Ram:
Delete {LIB}
Execute t:PPC
Move Ram:{LIB} G5Lib:
Delete t:PPC
