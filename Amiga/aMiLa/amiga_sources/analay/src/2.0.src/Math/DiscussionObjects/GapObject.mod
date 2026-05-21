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


MODULE GapObject;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       st : Strings,
       l  : LinkedLists,
       lrc: LongRealConversions,
       tt : TextTools,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       m  : Multitasking,
       mem: MemoryManager,
       mg : MathGUI,
       t  : Terms,
       c  : Coords,
       fg : FunctionGraph,
       do : DiscussionObject,
       ac : AnalayCatalog,
       NoGuruRq;

TYPE GapObject * = POINTER TO GapObjectDesc;
     GapObjectDesc * = RECORD(do.DiscussionObjectDesc)
     END;

PROCEDURE (dobj:GapObject) Init*;

BEGIN
  dobj.Init^;
  dobj.reqtitle:=ac.GetString(ac.DefinitionGaps);
  dobj.discusstitle:=s.ADR("Definition gaps of function");
  dobj.statustitle:=ac.GetString(ac.FindingGaps);
END Init;

PROCEDURE (dobj:GapObject) FindNext*():do.Result;

VAR result       : do.Result;
    table        : fg.FuncTable; (* Pointer to DiscussionObject.table *)
    coords       : c.CoordSystem;
    pos          : INTEGER;
    yl,yr        : LONGREAL;

    distx,addx,x,
    y,oldy,startx,
    endx         : LONGREAL;
    error        : INTEGER;
    isone,bool   : BOOLEAN;

BEGIN
  coords:=dobj.coords;
  table:=dobj.table;
  pos:=dobj.pos;
  NEW(result); result.Init;
  WITH coords: c.CartesianSystem DO
(*    is:=TRUE;*)
    LOOP
      INC(pos);
      IF dobj.statusbar#NIL THEN
        dobj.statusbar.SetValue(SHORT(SHORT(100*LONG(pos)/LEN(table^))));
      END;
      IF pos=LEN(table^) THEN
        result.Destruct; result:=NIL;
        EXIT;
      END;
      IF (pos>0) AND (pos<LEN(table^)-1) THEN
        IF table[pos].error=1 THEN
          isone:=TRUE;
          distx:=ABS(coords.xmin)+ABS(coords.xmax);
          addx:=distx/LEN(table^);
          x:=addx*(LONG(LONG(pos)))+coords.xmin;
        ELSIF table[pos].error#0 THEN
          isone:=TRUE;
          distx:=ABS(coords.xmin)+ABS(coords.xmax);
          addx:=distx/LEN(table^);
          x:=addx*(LONG(LONG(pos+2)))+coords.xmin;
          do.GetNextValue(addx);
          error:=0;
          y:=dobj.func.GetFunctionValue(x,addx,error);
          REPEAT
            oldy:=y;
            x:=x-addx;
            error:=0;
            y:=dobj.func.GetFunctionValue(x,addx,error);
          UNTIL error#0;
          x:=x-addx;
          IF error=0 THEN
            isone:=FALSE;
          END;
          IF isone THEN
            REPEAT
              do.GetNextValue(addx);
              y:=dobj.func.GetFunctionValue(x,addx,error);
              LOOP
                oldy:=y;
                x:=x+addx;
                error:=0;
                y:=dobj.func.GetFunctionValue(x,addx,error);
                IF error#0 THEN
                  EXIT;
                END;
              END;
              IF addx>dobj.exact THEN
                x:=x-addx;
                x:=x-addx;
              END;
            UNTIL (addx<=dobj.exact) OR NOT(isone);
          END;
  (*        error:=0;
          y:=f.RechenLong(root,x,x+(ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax))/LEN(table^),error);
          IF error=0 THEN
            isone:=FALSE;
          END;*)
          IF isone THEN
            EXIT;
          END;
        END;
      END;
    END;
    dobj.pos:=pos; (* Don't ever forget to write back the modified value! *)
  
    IF result#NIL THEN
      result.xreal:=x;
      bool:=lrc.RealToString(result.xreal,result.xstring,6,6,FALSE);
      tt.MoveDiffSign(result.xstring);
      result.yreal:=0;
      COPY(ac.GetString(ac.Undefined)^,result.ystring);

      result.comment:="";
    END;
  END;
  
  RETURN result;
END FindNext;

END GapObject.

