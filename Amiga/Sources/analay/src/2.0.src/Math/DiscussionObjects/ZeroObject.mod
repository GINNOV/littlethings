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


MODULE ZeroObject;

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


TYPE ZeroObject * = POINTER TO ZeroObjectDesc;
     ZeroObjectDesc * = RECORD(do.DiscussionObjectDesc)
     END;

PROCEDURE (dobj:ZeroObject) Init*;

BEGIN
  dobj.Init^;
  dobj.reqtitle:=ac.GetString(ac.Zeros);
  dobj.discusstitle:=s.ADR("Zeros of function");
  dobj.statustitle:=ac.GetString(ac.FindingZeros);
END Init;

PROCEDURE (dobj:ZeroObject) FindNext*():do.Result;

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
      IF pos<LEN(table^)-1 THEN
        IF (((table[pos].real<0) AND (table[pos+1].real>0)) OR ((table[pos].real>0) AND (table[pos+1].real<0))) AND (table[pos].error=0) AND (table[pos+1].error=0) THEN
          isone:=TRUE;
          distx:=ABS(coords.xmin)+ABS(coords.xmax);
          addx:=distx/LEN(table^);
          startx:=addx*(LONG(LONG(pos-2)))+coords.xmin-2*addx;
          endx:=addx*(LONG(LONG(pos+2)))+coords.xmin+2*addx;
          x:=addx*(LONG(LONG(pos+2)))+coords.xmin+addx;
          do.GetNextValue(addx);
          error:=0;
          y:=dobj.func.GetFunctionValue(x,addx,error);
          REPEAT
            oldy:=y;
            x:=x-addx;
            y:=dobj.func.GetFunctionValue(x,addx,error);
            IF x<startx THEN
              isone:=FALSE;
            END;
          UNTIL ((y<0) AND (oldy>0)) OR ((y>0) AND (oldy<0)) OR (y=0) OR NOT(isone);
          IF error#0 THEN
            isone:=FALSE;
          END;
          IF (isone) AND (y#0) THEN
            REPEAT
              do.GetNextValue(addx);
              error:=0;
              y:=dobj.func.GetFunctionValue(x,addx,error);
              LOOP
                oldy:=y;
                x:=x+addx;
                y:=dobj.func.GetFunctionValue(x,addx,error);
                IF ((y<0) AND (oldy>0)) OR ((y>0) AND (oldy<0)) OR (y=0) THEN
                  EXIT;
                END;
                IF x>endx THEN
                  isone:=FALSE;
                  EXIT;
                END;
              END;
              IF error#0 THEN
                isone:=FALSE;
              END;
              IF addx>dobj.exact THEN
                x:=x-addx;
              END;
            UNTIL (addx<=dobj.exact) OR NOT(isone);
          END;
          error:=0;
          y:=dobj.func.GetFunctionValue(x,(ABS(coords.xmin)+ABS(coords.xmax))/LEN(table^),error);
          IF error#0 THEN
            isone:=FALSE;
          END;
          IF isone THEN
            EXIT;
          END;
        ELSIF (table[pos].real=0) AND (table[pos].error=0) THEN
          isone:=TRUE;
          distx:=ABS(coords.xmin)+ABS(coords.xmax);
          addx:=distx/LEN(table^);
          x:=addx*(LONG(LONG(pos)))+coords.xmin;
          error:=0;
          y:=dobj.func.GetFunctionValue(x,addx,error);
          IF error#0 THEN
            isone:=FALSE;
          END;
          IF isone THEN
            EXIT;
          END;
        END;
      END;
      IF (pos>0) AND (pos<LEN(table^)-1) THEN
        IF (table[pos].real<=table[pos-1].real) AND (table[pos].real<table[pos+1].real) AND (table[pos].real<0.5) AND (table[pos].real>-0.5) AND (table[pos].error=0) AND (table[pos-1].error=0) AND (table[pos+1].error=0) THEN
          isone:=TRUE;
          distx:=ABS(coords.xmin)+ABS(coords.xmax);
          addx:=distx/LEN(table^);
          startx:=addx*(LONG(LONG(pos-2)))+coords.xmin-addx;
          endx:=addx*(LONG(LONG(pos+2)))+coords.xmin+addx;
          x:=addx*(LONG(LONG(pos+2)))+coords.xmin+addx;
          do.GetNextValue(addx);
          error:=0;
          y:=dobj.func.GetFunctionValue(x,addx,error);
          REPEAT
            oldy:=y;
            x:=x-addx;
            y:=dobj.func.GetFunctionValue(x,addx,error);
            IF x<startx THEN
              isone:=FALSE;
            END;
          UNTIL (y>oldy) OR NOT(isone);
          IF error#0 THEN
            isone:=FALSE;
          END;
          IF isone THEN
            REPEAT
              do.GetNextValue(addx);
              error:=0;
              y:=dobj.func.GetFunctionValue(x,addx,error);
              LOOP
                oldy:=y;
                x:=x+addx;
                y:=dobj.func.GetFunctionValue(x,addx,error);
                IF y>=0 THEN
                  IF y>oldy THEN
                    x:=x-addx;
                    EXIT;
                  END;
                ELSE
                  IF -(y)<-(oldy) THEN
                    x:=x-addx;
                    EXIT;
                  END;
                END;
                IF x>endx THEN
                  isone:=FALSE;
                  EXIT;
                END;
              END;
              IF error#0 THEN
                isone:=FALSE;
              END;
              IF addx>dobj.exact THEN
                x:=x-addx;
              END;
            UNTIL (addx<=dobj.exact) OR NOT(isone);
          END;
          error:=0;
          y:=dobj.func.GetFunctionValue(x,(ABS(coords.xmin)+ABS(coords.xmax))/LEN(table^),error);
          IF (error#0) OR NOT((y>-0.00001) AND (y<0.00001)) THEN
            isone:=FALSE;
          END;
          IF isone THEN
            EXIT;
          END;
        ELSIF (table[pos].real>=table[pos-1].real) AND (table[pos].real>table[pos+1].real) AND (table[pos].real<0.5) AND (table[pos].real>-0.5) AND (table[pos].error=0) AND (table[pos-1].error=0) AND (table[pos+1].error=0) THEN
          isone:=TRUE;
          distx:=ABS(coords.xmin)+ABS(coords.xmax);
          addx:=distx/LEN(table^);
          startx:=addx*(LONG(LONG(pos-2)))+coords.xmin-addx;
          endx:=addx*(LONG(LONG(pos+2)))+coords.xmin+addx;
          x:=addx*(LONG(LONG(pos+2)))+coords.xmin+addx;
          do.GetNextValue(addx);
          error:=0;
          y:=dobj.func.GetFunctionValue(x,addx,error);
          REPEAT
            oldy:=y;
            x:=x-addx;
            y:=dobj.func.GetFunctionValue(x,addx,error);
            IF x<startx THEN
              isone:=FALSE;
            END;
          UNTIL (y<oldy) OR NOT(isone);
          IF error#0 THEN
            isone:=FALSE;
          END;
          IF isone THEN
            REPEAT
              do.GetNextValue(addx);
              error:=0;
              y:=dobj.func.GetFunctionValue(x,addx,error);
              LOOP
                oldy:=y;
                x:=x+addx;
                y:=dobj.func.GetFunctionValue(x,addx,error);
                IF y>=0 THEN
                  IF y<oldy THEN
                    x:=x-addx;
                    EXIT;
                  END;
                ELSE
                  IF -(y)>-(oldy) THEN
                    x:=x-addx;
                    EXIT;
                  END;
                END;
                IF x>endx THEN
                  isone:=FALSE;
                  EXIT;
                END;
              END;
              IF error#0 THEN
                isone:=FALSE;
              END;
              IF addx>dobj.exact THEN
                x:=x-addx;
              END;
            UNTIL (addx<=dobj.exact) OR NOT(isone);
          END;
          error:=0;
          y:=dobj.func.GetFunctionValue(x,(ABS(coords.xmin)+ABS(coords.xmax))/LEN(table^),error);
          IF (error#0) OR NOT((y>-0.00001) AND (y<0.00001)) THEN
            isone:=FALSE;
          END;
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
      error:=0;
      result.yreal:=dobj.func.GetFunctionValue(x,0.0001,error);
      result.yreal:=0;
      IF error=0 THEN
        bool:=lrc.RealToString(y,result.ystring,6,6,FALSE);
        tt.MoveDiffSign(result.ystring);
      ELSE
        COPY(ac.GetString(ac.Undefined)^,result.ystring);
      END;
  
      yl:=dobj.func.GetFunctionValue(result.xreal-0.0001,0.0001,error);
      yr:=dobj.func.GetFunctionValue(result.xreal+0.0001,0.0001,error);
      result.left:=yl; result.right:=yr;
      IF (yl<0) AND (yr>0) THEN
        COPY(ac.GetString(ac.ChangeInSign)^,result.comment);
        st.Append(result.comment," -/+");
      ELSIF (yl>0) AND (yr<0) THEN
        COPY(ac.GetString(ac.ChangeInSign)^,result.comment);
        st.Append(result.comment," +/-");
      ELSE
        COPY(ac.GetString(ac.NoChangeInSign)^,result.comment);
      END;
    END;
  END;
  
  RETURN result;
END FindNext;

END ZeroObject.

