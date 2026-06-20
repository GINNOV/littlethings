 IFND INTUITION_INTUTIONBASE_I
INTUITION_INTUITIONBASE_I SET 1
*
*  intuition/intuitionbase.i
*  Release 2.0
*  for PhxAss
*
*  © copyright by F.Wille in 1993
*

 ifnd EXEC_LIBRARIES_I
 include "exec/libraries.i"
 endc

 ifnd GRAPHICS_VIEW_I
 include "graphics/view.i"
 endc

* struct IntuitionBase
 rsset lib_SIZE
ib_ViewLord	rs.b v_SIZEOF
ib_ActiveWindow rs.l 1
ib_ActiveScreen rs.l 1
ib_FirstScreen	rs.l 1
ib_Flags	rs.l 1
ib_MouseY	rs.w 1
ib_MouseX	rs.w 1
ib_Seconds	rs.l 1
ib_Micros	rs.l 1
* ... (private)

 endc
