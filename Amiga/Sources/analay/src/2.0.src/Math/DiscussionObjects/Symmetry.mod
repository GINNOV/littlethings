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


MODULE Symmetry;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       gd : GadTools,
       l  : LinkedLists,
       st : Strings,
       lrc: LongRealConversions,
       tt : TextTools,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       m  : Multitasking,
       mem: MemoryManager,
       tid: TaskIDs,
       gb : GeneralBasics,
       mb : MathBasics,
       mg : MathGUI,
       w  : Window,
       t  : Terms,
       c  : Coords,
       fg : FunctionGraph,
       wf : WindowFunction,
       do : DiscussionObject,
       zo : ZeroObject,
       mo : MinMaxObject,
       ifo: InflectionObject,
       ac : AnalayCatalog,
       bt : BasicTypes,
       lio: LongRealInOut,
       io,
       NoGuruRq;

TYPE SymmetryData * = POINTER TO SymmetryDataDesc;
     SymmetryDataDesc * = RECORD
       type - : INTEGER;
       x-,y - : LONGREAL;
     END;

CONST noSymmetry    * = 0;
      axisSymmetry  * = 1;
      pointSymmetry * = 2;

PROCEDURE (data:SymmetryData) Init*;

BEGIN
  data.type:=noSymmetry;
  data.x:=0;
  data.y:=0;
END Init;

PROCEDURE (data:SymmetryData) Destruct*;

BEGIN
  DISPOSE(data);
END Destruct;

PROCEDURE FindSymmetry*(func:t.Function;simple:BOOLEAN):SymmetryData;
(* Set simple to TRUE to search only for simple symmetries. *)

VAR data         : SymmetryData;
    sx,sy,sy2    : REAL;
    i,
    error,error2 : INTEGER;
    bool         : BOOLEAN;

BEGIN
  NEW(data);
  IF data#NIL THEN
    data.Init;
    i:=-1;
    sx:=-0.1;
    WHILE sx<10 DO
      sx:=sx+0.1;
      error:=0;
      error2:=0;
      sy:=func.GetFunctionValueShort(sx,0.1,error);
      bool:=lio.WriteReal(sy,7,7,FALSE);
      sy2:=func.GetFunctionValueShort(-sx,-0.1,error2);
      bool:=lio.WriteReal(sy2,7,7,FALSE);
      IF error>0 THEN
        error:=1;
      END;
      IF error2>0 THEN
        error2:=1;
      END;
      IF (sy-sy2>-0.0001) AND (sy-sy2<0.0001) AND (error=error2) THEN
        i:=0;
      ELSE
        i:=-1;
        sx:=10;
      END;
    END;
    IF i=-1 THEN
      sx:=-0.1;
      WHILE sx<10 DO
        sx:=sx+0.1;
        error:=0;
        error2:=0;
        sy:=func.GetFunctionValueShort(sx,0.1,error);
        bool:=lio.WriteReal(sy,7,7,FALSE);
        sy2:=func.GetFunctionValueShort(sx,-0.1,error2);
        bool:=lio.WriteReal(sy2,7,7,FALSE);
        IF error>0 THEN
          error:=1;
        END;
        IF error2>0 THEN
          error2:=1;
        END;
        IF (sy+sy2>-0.0001) AND (sy+sy2<0.0001) AND (error=error2) THEN
          i:=1;
        ELSE
          i:=-1;
          sx:=10;
        END;
      END;
    END;
    IF i=-1 THEN
      data.type:=noSymmetry;
      io.WriteString("No symmetry.\n");
    ELSIF i=0 THEN
      data.type:=axisSymmetry;
      io.WriteString("Axis symmetry.\n");
    ELSIF i=1 THEN
      data.type:=pointSymmetry;
      io.WriteString("Point symmetry.\n");
    END;
  END;
  RETURN data;
END FindSymmetry;

END Symmetry.

