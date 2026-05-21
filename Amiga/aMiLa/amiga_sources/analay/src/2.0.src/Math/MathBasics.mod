(*
Copyright (c) 1994 - 2000 Marc Necker.

This file is part of Analay (v2.0).
http://www.analay.de

Analay is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License version 2
as published by the Free Software Foundation.

Analay is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Analay.  If not, see <https://www.gnu.org/licenses/>.
*)


MODULE MathBasics;

TYPE MathOptions * = POINTER TO MathOptionsDesc;
     MathOptionsDesc * = RECORD
       quickselect * ,
       autoactive  * : BOOLEAN;
     END;

VAR mathoptions * : MathOptions;

PROCEDURE GetNextValue*(VAR r:LONGREAL);

BEGIN
  IF r>0.1 THEN r:=0.1;
  ELSIF r>0.01 THEN r:=0.01;
  ELSIF r>0.001 THEN r:=0.001;
  ELSIF r>0.0001 THEN r:=0.0001;
  ELSIF r>0.00001 THEN r:=0.00001;
  ELSIF r>0.000001 THEN r:=0.000001;
  ELSIF r>0.0000001 THEN r:=0.0000001;
  ELSIF r>0.00000001 THEN r:=0.00000001;
  ELSIF r>0.000000001 THEN r:=0.000000001;
  ELSIF r>0.0000000001 THEN r:=0.0000000001;
  END;
END GetNextValue;

BEGIN
  mathoptions:=NIL;
  NEW(mathoptions);
  mathoptions.quickselect:=TRUE;
  mathoptions.autoactive:=FALSE;
CLOSE
  IF mathoptions#NIL THEN DISPOSE(mathoptions); END;
END MathBasics.

