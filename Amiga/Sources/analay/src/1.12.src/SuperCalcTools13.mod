(*
Copyright (c) 1994 - 1996 Marc Necker.

This file is part of Analay (v1.12).
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


MODULE SuperCalcTools13;

IMPORT I  : Intuition,
       g  : Graphics,
       d  : Dos,
       e  : Exec,
       s  : SYSTEM,
       f  : Function,
       f1 : Function1,
       c  : Conversions,
       l  : LinkedLists,
       wm : WindowManager,
       gm : GadgetManager,
       it : IntuitionTools,
       tt : TextTools,
       ag : AmigaGuideTools,
       rt : RequesterTools,
       ac : AnalayCatalog,
       lrc: LongRealConversions,
       st : Strings,
       r  : Requests,
       s1 : SuperCalcTools1,
       s2 : SuperCalcTools2,
       s3 : SuperCalcTools3,
       s4 : SuperCalcTools4,
       s5 : SuperCalcTools5,
       s6 : SuperCalcTools6,
       s7 : SuperCalcTools7,
       s8 : SuperCalcTools8,
       s9 : SuperCalcTools9,
       s10: SuperCalcTools10,
       s11: SuperCalcTools11,
       s12: SuperCalcTools12,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- *)

TYPE ListElement * = RECORD(l.NodeDesc)
       xstring * ,
       ystring * ,
       comment * : ARRAY 256 OF CHAR;
       marked  * : BOOLEAN;
       xreal   * ,
       yreal   * : LONGREAL;
     END;

VAR ok,bool     : BOOLEAN;
    code        : INTEGER;
    class       : LONGSET;
    address     : s.ADDRESS;
    a,j,i       : INTEGER;
    xlist*,ylist*: POINTER TO ARRAY OF ARRAY OF LONGREAL;
    comment   * : POINTER TO ARRAY OF ARRAY OF CHAR;
    elist     * : POINTER TO ARRAY OF ARRAY OF BOOLEAN;
    viewlist  * : l.List;
    string    * : POINTER TO ARRAY OF POINTER TO ARRAY OF CHAR;
    sel         : POINTER TO ARRAY OF ARRAY OF BOOLEAN;
    numlist   * : ARRAY 2 OF INTEGER;
    undertitle* : ARRAY 2 OF ARRAY 20 OF CHAR;
    func      * ,
    func2     * : s1.Funktion;
    err       * ,
    err2      * : s1.Error;
    listId    * : INTEGER;
    pos         : INTEGER;
    first       : BOOLEAN;
    searchrast* : g.RastPortPtr;
    fact        : REAL;
    picx        : REAL;
    name        : ARRAY 80 OF CHAR;
    prevmode,
    prevstand   : INTEGER;
    barwi     * : INTEGER;

PROCEDURE GetNextValue(VAR r:LONGREAL);

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

PROCEDURE Pos(r:LONGREAL):LONGREAL;

BEGIN
  IF r<0 THEN
    RETURN -r;
  ELSE
    RETURN r;
  END;
END Pos;

PROCEDURE ResetSearch*;

BEGIN
  first:=TRUE;
  pos:=-1;
END ResetSearch;

PROCEDURE SearchMin*(p:l.Node;func:l.Node;table:s1.FuncTable;VAR is:BOOLEAN;exact:LONGREAL):LONGREAL;

VAR distx,addx,x,
    y,oldy       : LONGREAL;
    error        : INTEGER;
    isone        : BOOLEAN;

BEGIN
  IF first THEN
    pos:=-1;
    first:=FALSE;
    fact:=barwi/LEN(table^);
  END;
  is:=TRUE;
  LOOP
    INC(pos);
    IF pos=LEN(table^) THEN
      is:=FALSE;
      EXIT;
    END;
    IF searchrast#NIL THEN
      IF (pos+1)*fact<barwi THEN
        g.Move(searchrast,SHORT(SHORT(16+(pos+1)*fact)),23);
        g.Draw(searchrast,SHORT(SHORT(16+(pos+1)*fact)),44);
      END;
    END;
    IF (pos>0) AND (pos<LEN(table^)-1) THEN
      IF (table[pos].real<table[pos-1].real) AND (table[pos].real<table[pos+1].real) AND (table[pos].error=0) AND (table[pos-1].error=0) AND (table[pos+1].error=0) THEN
        isone:=TRUE;
        distx:=ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax);
        addx:=distx/LEN(table^);
        x:=addx*(LONG(LONG(pos+2)))+p(s1.Fenster).xmin;
        GetNextValue(addx);
        y:=s2.GetFunctionValue(func,x,addx,error);
        REPEAT
          oldy:=y;
          x:=x-addx;
          y:=s2.GetFunctionValue(func,x,addx,error);
        UNTIL y>oldy;
        IF error#0 THEN
          isone:=FALSE;
        END;
        IF isone THEN
          REPEAT
            GetNextValue(addx);
            y:=s2.GetFunctionValue(func,x,addx,error);
            LOOP
              oldy:=y;
              x:=x+addx;
              y:=s2.GetFunctionValue(func,x,addx,error);
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
            END;
            IF error#0 THEN
              isone:=FALSE;
            END;
            IF addx>exact THEN
              x:=x-addx;
            END;
          UNTIL (addx<=exact) OR NOT(isone);
        END;
        y:=s2.GetFunctionValue(func,x,(ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax))/LEN(table^),error);
        IF error#0 THEN
          isone:=FALSE;
        END;
        IF isone THEN
          EXIT;
        END;
      END;
    END;
  END;
  RETURN x;
END SearchMin;

PROCEDURE SearchMax*(p:l.Node;func:l.Node;table:s1.FuncTable;VAR is:BOOLEAN;exact:LONGREAL):LONGREAL;

VAR distx,addx,x,
    y,oldy       : LONGREAL;
    error        : INTEGER;
    isone        : BOOLEAN;

BEGIN
  IF first THEN
    pos:=-1;
    first:=FALSE;
    fact:=barwi/LEN(table^);
  END;
  is:=TRUE;
  LOOP
    INC(pos);
    IF pos=LEN(table^) THEN
      is:=FALSE;
      EXIT;
    END;
    IF searchrast#NIL THEN
      IF (pos+1)*fact<barwi THEN
        g.Move(searchrast,SHORT(SHORT(16+(pos+1)*fact)),23);
        g.Draw(searchrast,SHORT(SHORT(16+(pos+1)*fact)),44);
      END;
    END;
    IF (pos>0) AND (pos<LEN(table^)-1) THEN
      IF (table[pos].real>table[pos-1].real) AND (table[pos].real>table[pos+1].real) AND (table[pos].error=0) AND (table[pos-1].error=0) AND (table[pos+1].error=0) THEN
        isone:=TRUE;
        distx:=ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax);
        addx:=distx/LEN(table^);
        x:=addx*(LONG(LONG(pos+2)))+p(s1.Fenster).xmin;
        GetNextValue(addx);
        y:=s2.GetFunctionValue(func,x,addx,error);
        REPEAT
          oldy:=y;
          x:=x-addx;
          y:=s2.GetFunctionValue(func,x,addx,error);
        UNTIL y<oldy;
        IF error#0 THEN
          isone:=FALSE;
        END;
        IF isone THEN
          REPEAT
            GetNextValue(addx);
            y:=s2.GetFunctionValue(func,x,addx,error);
            LOOP
              oldy:=y;
              x:=x+addx;
              y:=s2.GetFunctionValue(func,x,addx,error);
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
            END;
            IF error#0 THEN
              isone:=FALSE;
            END;
            IF addx>exact THEN
              x:=x-addx;
            END;
          UNTIL (addx<=exact) OR NOT(isone);
        END;
        y:=s2.GetFunctionValue(func,x,(ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax))/LEN(table^),error);
        IF error#0 THEN
          isone:=FALSE;
        END;
        IF isone THEN
          EXIT;
        END;
      END;
    END;
  END;
  RETURN x;
END SearchMax;

PROCEDURE SearchNull*(p:l.Node;func:l.Node;table:s1.FuncTable;VAR is:BOOLEAN;exact:LONGREAL):LONGREAL;

VAR distx,addx,x,
    y,oldy,startx,
    endx         : LONGREAL;
    error        : INTEGER;
    isone        : BOOLEAN;

BEGIN
  IF first THEN
    pos:=-1;
    first:=FALSE;
    fact:=barwi/LEN(table^);
    picx:=16;
  END;
  is:=TRUE;
  LOOP
    INC(pos);
    IF pos=LEN(table^) THEN
      is:=FALSE;
      EXIT;
    END;
    IF searchrast#NIL THEN
      picx:=picx+fact;
      IF picx-16<barwi THEN
        (* $OvflChk- *)
        g.Move(searchrast,SHORT(SHORT(picx)),23);
        g.Draw(searchrast,SHORT(SHORT(picx)),44);
        (* $OvflChk= *)
      END;
    END;
    IF pos<LEN(table^)-1 THEN
      IF (((table[pos].real<0) AND (table[pos+1].real>0)) OR ((table[pos].real>0) AND (table[pos+1].real<0))) AND (table[pos].error=0) AND (table[pos+1].error=0) THEN
        isone:=TRUE;
        distx:=ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax);
        addx:=distx/LEN(table^);
        startx:=addx*(LONG(LONG(pos-2)))+p(s1.Fenster).xmin-addx;
        endx:=addx*(LONG(LONG(pos+2)))+p(s1.Fenster).xmin+addx;
        x:=addx*(LONG(LONG(pos+2)))+p(s1.Fenster).xmin+addx;
        GetNextValue(addx);
        error:=0;
        y:=s2.GetFunctionValue(func,x,addx,error);
        REPEAT
          oldy:=y;
          x:=x-addx;
          y:=s2.GetFunctionValue(func,x,addx,error);
          IF x<startx THEN
            isone:=FALSE;
          END;
        UNTIL ((y<0) AND (oldy>0)) OR ((y>0) AND (oldy<0)) OR (y=0) OR NOT(isone);
        IF error#0 THEN
          isone:=FALSE;
        END;
        IF (isone) AND (y#0) THEN
          REPEAT
            GetNextValue(addx);
            error:=0;
            y:=s2.GetFunctionValue(func,x,addx,error);
            LOOP
              oldy:=y;
              x:=x+addx;
              y:=s2.GetFunctionValue(func,x,addx,error);
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
            IF addx>exact THEN
              x:=x-addx;
            END;
          UNTIL (addx<=exact) OR NOT(isone);
        END;
        error:=0;
        y:=s2.GetFunctionValue(func,x,(ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax))/LEN(table^),error);
        IF error#0 THEN
          isone:=FALSE;
        END;
        IF isone THEN
          EXIT;
        END;
      ELSIF (table[pos].real=0) AND (table[pos].error=0) THEN
        isone:=TRUE;
        distx:=ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax);
        addx:=distx/LEN(table^);
        x:=addx*(LONG(LONG(pos)))+p(s1.Fenster).xmin;
        error:=0;
        y:=s2.GetFunctionValue(func,x,addx,error);
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
        distx:=ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax);
        addx:=distx/LEN(table^);
        startx:=addx*(LONG(LONG(pos-2)))+p(s1.Fenster).xmin-addx;
        endx:=addx*(LONG(LONG(pos+2)))+p(s1.Fenster).xmin+addx;
        x:=addx*(LONG(LONG(pos+2)))+p(s1.Fenster).xmin+addx;
        GetNextValue(addx);
        error:=0;
        y:=s2.GetFunctionValue(func,x,addx,error);
        REPEAT
          oldy:=y;
          x:=x-addx;
          y:=s2.GetFunctionValue(func,x,addx,error);
          IF x<startx THEN
            isone:=FALSE;
          END;
        UNTIL (y>oldy) OR NOT(isone);
        IF error#0 THEN
          isone:=FALSE;
        END;
        IF isone THEN
          REPEAT
            GetNextValue(addx);
            error:=0;
            y:=s2.GetFunctionValue(func,x,addx,error);
            LOOP
              oldy:=y;
              x:=x+addx;
              y:=s2.GetFunctionValue(func,x,addx,error);
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
            IF addx>exact THEN
              x:=x-addx;
            END;
          UNTIL (addx<=exact) OR NOT(isone);
        END;
        error:=0;
        y:=s2.GetFunctionValue(func,x,(ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax))/LEN(table^),error);
        IF (error#0) OR NOT((y>-0.00001) AND (y<0.00001)) THEN
          isone:=FALSE;
        END;
        IF isone THEN
          EXIT;
        END;
      ELSIF (table[pos].real>=table[pos-1].real) AND (table[pos].real>table[pos+1].real) AND (table[pos].real<0.5) AND (table[pos].real>-0.5) AND (table[pos].error=0) AND (table[pos-1].error=0) AND (table[pos+1].error=0) THEN
        isone:=TRUE;
        distx:=ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax);
        addx:=distx/LEN(table^);
        startx:=addx*(LONG(LONG(pos-2)))+p(s1.Fenster).xmin-addx;
        endx:=addx*(LONG(LONG(pos+2)))+p(s1.Fenster).xmin+addx;
        x:=addx*(LONG(LONG(pos+2)))+p(s1.Fenster).xmin+addx;
        GetNextValue(addx);
        error:=0;
        y:=s2.GetFunctionValue(func,x,addx,error);
        REPEAT
          oldy:=y;
          x:=x-addx;
          y:=s2.GetFunctionValue(func,x,addx,error);
          IF x<startx THEN
            isone:=FALSE;
          END;
        UNTIL (y<oldy) OR NOT(isone);
        IF error#0 THEN
          isone:=FALSE;
        END;
        IF isone THEN
          REPEAT
            GetNextValue(addx);
            error:=0;
            y:=s2.GetFunctionValue(func,x,addx,error);
            LOOP
              oldy:=y;
              x:=x+addx;
              y:=s2.GetFunctionValue(func,x,addx,error);
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
            IF addx>exact THEN
              x:=x-addx;
            END;
          UNTIL (addx<=exact) OR NOT(isone);
        END;
        error:=0;
        y:=s2.GetFunctionValue(func,x,(ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax))/LEN(table^),error);
        IF (error#0) OR NOT((y>-0.00001) AND (y<0.00001)) THEN
          isone:=FALSE;
        END;
        IF isone THEN
          EXIT;
        END;
      END;
    END;
  END;
  RETURN x;
END SearchNull;

PROCEDURE SearchLuck*(p:l.Node;func:l.Node;table:s1.FuncTable;VAR is:BOOLEAN;exact:LONGREAL):LONGREAL;

VAR distx,addx,x,
    y,oldy       : LONGREAL;
    error        : INTEGER;
    isone        : BOOLEAN;

BEGIN
  IF first THEN
    pos:=-1;
    first:=FALSE;
    fact:=barwi/LEN(table^);
  END;
  is:=TRUE;
  LOOP
    INC(pos);
    IF pos=LEN(table^) THEN
      is:=FALSE;
      EXIT;
    END;
    IF searchrast#NIL THEN
      IF (pos+1)*fact<barwi THEN
        g.Move(searchrast,SHORT(SHORT(16+(pos+1)*fact)),23);
        g.Draw(searchrast,SHORT(SHORT(16+(pos+1)*fact)),44);
      END;
    END;
    IF (pos>0) AND (pos<LEN(table^)-1) THEN
      IF table[pos].error=1 THEN
        isone:=TRUE;
        distx:=ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax);
        addx:=distx/LEN(table^);
        x:=addx*(LONG(LONG(pos)))+p(s1.Fenster).xmin;
      ELSIF table[pos].error#0 THEN
        isone:=TRUE;
        distx:=ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax);
        addx:=distx/LEN(table^);
        x:=addx*(LONG(LONG(pos+2)))+p(s1.Fenster).xmin;
        GetNextValue(addx);
        y:=s2.GetFunctionValue(func,x,addx,error);
        REPEAT
          oldy:=y;
          x:=x-addx;
          error:=0;
          y:=s2.GetFunctionValue(func,x,addx,error);
        UNTIL error#0;
        x:=x-addx;
        IF error=0 THEN
          isone:=FALSE;
        END;
        IF isone THEN
          REPEAT
            GetNextValue(addx);
            y:=s2.GetFunctionValue(func,x,addx,error);
            LOOP
              oldy:=y;
              x:=x+addx;
              error:=0;
              y:=s2.GetFunctionValue(func,x,addx,error);
              IF error#0 THEN
                EXIT;
              END;
            END;
            IF addx>exact THEN
              x:=x-addx;
              x:=x-addx;
            END;
          UNTIL (addx<=exact) OR NOT(isone);
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
  RETURN x;
END SearchLuck;

(*PROCEDURE DefineMax*(node:l.Node;VAR pos:INTEGER;root:f2.NodePtr;minx,maxx:REAL;r:g.RastPortPtr;genau:REAL;VAR ismax:BOOLEAN):LONGREAL;
(* $CopyArrays- *)

VAR dx,sx            : REAL;
    real,oldreal,
    oldwert,wert,add : LONGREAL;
    error            : INTEGER;
    bool,break       : BOOLEAN;
    p                : s1.Funktion;

BEGIN
(*  real:=-1000000;
  LOOP
    INC(pos);
    IF pos>638 THEN
      EXIT;
    END;
    IF r#NIL THEN
      g.Move(r,18+(pos DIV 4),23);
      g.Draw(r,18+(pos DIV 4),44);
    END;
    IF (p[pos]>p[pos-1]) AND (p[pos]>p[pos+1]) THEN
      dx:=ABS(minx)+ABS(maxx);
      sx:=dx/640;
      real:=sx*(LONG(LONG(pos-1)))+minx;
      fpos:=0;
      root:=f.Parse(s1.funcstr[num],fpos);
      oldwert:=f.Rechen(root,real,real+0.0001,error);
      LOOP
        oldreal:=real;
        real:=real+genau;
        wert:=f.Rechen(root,real,real+0.0001,error);
        IF wert<oldwert THEN
          EXIT;
        END;
        oldwert:=wert;
      END;
      real:=oldreal;
      EXIT;
    END;
  END;
  RETURN real;*)
  p:=func;
  real:=-1000000;
  LOOP
    INC(pos);
    IF pos>638 THEN
      EXIT;
    END;
    IF r#NIL THEN
      g.Move(r,16+(pos DIV 4),23);
      g.Draw(r,16+(pos DIV 4),44);
    END;
    IF (p[pos]>=p[pos-1]) AND (p[pos]>p[pos+1]) AND (err[pos]=0) AND (err[pos+1]=0) AND (err[pos-1]=0) THEN
      EXIT;
    END;
  END;
  ismax:=TRUE;
  IF pos<=638 THEN
    dx:=ABS(minx)+ABS(maxx);
    sx:=dx/640;
    add:=sx;
    real:=sx*(LONG(LONG(pos(*-2*))))+minx;
    GetNextValue(add);
    wert:=f.RechenLong(root,real,real+0.0001,error);
    REPEAT
      oldwert:=wert;
      real:=real-add;
      wert:=f.RechenLong(root,real,real+0.0001,error);
    UNTIL wert<oldwert;
    IF error#0 THEN
      break:=TRUE;
    END;
    IF NOT(break) THEN
      REPEAT
        GetNextValue(add);
        wert:=f.RechenLong(root,real,real+0.0001,error);
        LOOP
          oldwert:=wert;
          real:=real+add;
          wert:=f.RechenLong(root,real,real+0.0001,error);
          IF wert>=0 THEN
            IF wert<oldwert THEN
              real:=real-add;
              EXIT;
            END;
          ELSE
            IF Pos(wert)>Pos(oldwert) THEN
              real:=real-add;
              EXIT;
            END;
          END;
        END;
        IF error#0 THEN
          break:=TRUE;
        END;
        IF add>0.0000001 THEN
          real:=real-add;
        END;
      UNTIL (add<=0.0000001) OR (break);
    END;
    wert:=f.RechenLong(root,real,real+(ABS(minx)+ABS(maxx))/640,error);
    IF (error#0) OR (break) THEN
      ismax:=FALSE;
    END;
  END;
  RETURN real;

(*      dx:=ABS(minx)+ABS(maxx);
      sx:=dx/640;
      real:=sx*(LONG(LONG(pos-1)))+minx;
      fpos:=0;
      root:=f.Parse(fpos,s1.funcstr[num]);
      oldwert:=f.Rechen(root,real,real+0.0001,error);
      LOOP
        oldreal:=real;
        real:=real+genau;
        wert:=f.Rechen(root,real,real+0.0001,error);
        IF wert<oldwert THEN
          EXIT;
        END;
        oldwert:=wert;
      END;
      real:=oldreal;
      EXIT;
    END;
  END;
  RETURN real;*)
END DefineMax;

PROCEDURE DefineMin*(node:l.Node;VAR pos:INTEGER;root:f2.NodePtr;minx,maxx:REAL;r:g.RastPortPtr;genau:REAL;VAR ismin:BOOLEAN):LONGREAL;
(* $CopyArrays- *)

VAR dx,sx            : REAL;
    real,oldreal,
    wert,oldwert,add : LONGREAL;
    error            : INTEGER;
    p                : s1.Funktion;
    break            : BOOLEAN;

BEGIN
(*  real:=-1000000;
  LOOP
    INC(pos);
    IF pos>638 THEN
      EXIT;
    END;
    IF r#NIL THEN
      g.Move(r,18+(pos DIV 4),23);
      g.Draw(r,18+(pos DIV 4),44);
    END;
    IF (p[pos]<p[pos-1]) AND (p[pos]<p[pos+1]) THEN
      dx:=ABS(minx)+ABS(maxx);
      sx:=dx/640;
      real:=sx*(LONG(LONG(pos-2)))+minx;
      fpos:=0;
      root:=f.Parse(s1.funcstr[num],fpos);
      oldwert:=f.Rechen(root,real,real+0.0001,error);
      LOOP
        oldreal:=real;
        real:=real+genau;
        wert:=f.Rechen(root,real,real,error);
        IF wert>oldwert THEN
          EXIT;
        END;
        oldwert:=wert;
      END;
      real:=oldreal;
      EXIT;
    END;
  END;
  RETURN real;*)
  p:=func;
  real:=-1000000;
  LOOP
    INC(pos);
    IF pos>638 THEN
      EXIT;
    END;
    IF r#NIL THEN
      g.Move(r,16+(pos DIV 4),23);
      g.Draw(r,16+(pos DIV 4),44);
    END;
    IF (p[pos]<=p[pos-1]) AND (p[pos]<p[pos+1]) AND (err[pos]=0) AND (err[pos+1]=0) AND (err[pos-1]=0) THEN
      EXIT;
    END;
  END;
  ismin:=TRUE;
  break:=FALSE;
  IF pos<=638 THEN
    dx:=ABS(minx)+ABS(maxx);
    sx:=dx/640;
    add:=sx;
    real:=sx*(LONG(LONG(pos(*-2*))))+minx;
    GetNextValue(add);
    wert:=f.RechenLong(root,real,real+0.0001,error);
    REPEAT
      oldwert:=wert;
      real:=real-add;
      wert:=f.RechenLong(root,real,real+0.0001,error);
    UNTIL wert>oldwert;
    IF error#0 THEN
      break:=TRUE;
    END;
    IF NOT(break) THEN
      REPEAT
        GetNextValue(add);
        wert:=f.RechenLong(root,real,real+0.0001,error);
        LOOP
          oldwert:=wert;
          real:=real+add;
          wert:=f.RechenLong(root,real,real+0.0001,error);
          IF wert>=0 THEN
            IF wert>oldwert THEN
              real:=real-add;
              EXIT;
            END;
          ELSE
            IF Pos(wert)<Pos(oldwert) THEN
              real:=real-add;
              EXIT;
            END;
          END;
        END;
        IF error#0 THEN
          break:=TRUE;
        END;
        IF add>0.0000001 THEN
          real:=real-add;
        END;
      UNTIL (add<=0.0000001) OR (break);
    END;
    wert:=f.RechenLong(root,real,real+(ABS(minx)+ABS(maxx))/640,error);
    IF (error#0) OR (break) THEN
      ismin:=FALSE;
    END;
  END;
  RETURN real;
END DefineMin;

PROCEDURE DefineNull*(node:l.Node;VAR pos:INTEGER;root:f2.NodePtr;minx,maxx:REAL;r:g.RastPortPtr;VAR isnull:BOOLEAN):LONGREAL;
(* $CopyArrays- *)

VAR dx,sx            : REAL;
    real,oldreal,
    oldwert,wert,add : LONGREAL;
    fpos : INTEGER;
    error: INTEGER;
    bool : BOOLEAN;
    mode : INTEGER;
    p    : s1.Funktion;
    e    : s1.Error;

BEGIN
  p:=func;
  e:=err;
  real:=-1000000;
  LOOP
    INC(pos);
    IF pos>638 THEN
      EXIT;
    END;
    IF r#NIL THEN
      g.Move(r,16+(pos DIV 4),23);
      g.Draw(r,16+(pos DIV 4),44);
    END;
    IF ((p[pos]>0) (*AND (p[pos]<1)*)) AND ((p[pos+1]<0) (*AND (p[pos+1]>-1)*)) AND (e[pos]=0) AND (e[pos+1]=0) THEN
      mode:=0;
      EXIT;
    ELSIF ((p[pos]<0) (*AND (p[pos]>-1)*)) AND ((p[pos+1]>0) (*AND (p[pos+1]<1)*)) AND (e[pos]=0) AND (e[pos+1]=0) THEN
      mode:=1;
      EXIT;
    ELSIF (p[pos]>=p[pos-1]) AND (p[pos]>p[pos+1]) AND (p[pos]<0.5) AND (p[pos]>-0.5) AND (e[pos]=0) AND (e[pos+1]=0) AND (e[pos-1]=0) THEN
      mode:=2;
      EXIT;
    ELSIF (p[pos]<=p[pos-1]) AND (p[pos]<p[pos+1]) AND (p[pos]<0.5) AND (p[pos]>-0.5) AND (e[pos]=0) AND (e[pos+1]=0) AND (e[pos-1]=0) THEN
      mode:=3;
      EXIT;
    ELSIF (p[pos]=0) AND (e[pos]=0) THEN
      mode:=4;
      EXIT;
    END;
  END;
  isnull:=TRUE;
  error:=0;
  IF pos<=638 THEN
    IF mode=0 THEN
      dx:=ABS(minx)+ABS(maxx);
      sx:=dx/640;
      add:=sx;
      real:=sx*(LONG(LONG(pos)))+minx;
      GetNextValue(add);
      wert:=f.RechenLong(root,real,real+0.0001,error);
      REPEAT
        oldwert:=wert;
        real:=real-add;
        wert:=f.RechenLong(root,real,real+0.0001,error);
      UNTIL wert>0;
      REPEAT
        GetNextValue(add);
        wert:=f.RechenLong(root,real,real,error);
        LOOP
          oldwert:=wert;
          real:=real+add;
          wert:=f.RechenLong(root,real,real,error);
          IF error#0 THEN
            isnull:=FALSE;
            EXIT;
          ELSE
            isnull:=TRUE;
          END;
          IF wert<0 THEN
            real:=real-add;
            EXIT;
          END;
        END;
        IF add>0.0000001 THEN
          real:=real-add;
        END;
      UNTIL add<=0.0000001;
      wert:=f.RechenLong(root,real,real,error);
      IF error#0 THEN
        isnull:=FALSE;
      END;
    ELSIF mode=1 THEN
      dx:=ABS(minx)+ABS(maxx);
      sx:=dx/640;
      add:=sx;
      real:=sx*(LONG(LONG(pos)))+minx;
      GetNextValue(add);
      wert:=f.RechenLong(root,real,real+0.0001,error);
      REPEAT
        oldwert:=wert;
        real:=real-add;
        wert:=f.RechenLong(root,real,real+0.0001,error);
      UNTIL wert<0;
      REPEAT
        GetNextValue(add);
        wert:=f.RechenLong(root,real,real,error);
        LOOP
          oldwert:=wert;
          real:=real+add;
          wert:=f.RechenLong(root,real,real,error);
          IF error#0 THEN
            isnull:=FALSE;
            EXIT;
          ELSE
            isnull:=TRUE;
          END;
          IF wert>0 THEN
            real:=real-add;
            EXIT;
          END;
        END;
        IF add>0.0000001 THEN
          real:=real-add;
        END;
      UNTIL add<=0.0000001;
      wert:=f.RechenLong(root,real,real,error);
      IF error#0 THEN
        isnull:=FALSE;
      END;
    ELSIF mode=2 THEN
      dx:=ABS(minx)+ABS(maxx);
      sx:=dx/640;
      add:=sx;
      real:=sx*(LONG(LONG(pos)))+minx;
      GetNextValue(add);
      wert:=f.RechenLong(root,real,real+0.0001,error);
      REPEAT
        oldwert:=wert;
        real:=real-add;
        wert:=f.RechenLong(root,real,real+0.0001,error);
      UNTIL wert<oldwert;
      REPEAT
        GetNextValue(add);
        wert:=f.RechenLong(root,real,real,error);
        LOOP
          oldwert:=wert;
          real:=real+add;
          wert:=f.RechenLong(root,real,real,error);
          IF error#0 THEN
            isnull:=FALSE;
            EXIT;
          ELSE
            isnull:=TRUE;
          END;
          IF wert<oldwert THEN
            real:=real-add;
            EXIT;
          END;
        END;
        IF add>0.00000001 THEN
          real:=real-add;
        END;
      UNTIL add<=0.00000001;
      wert:=f.RechenLong(root,real,real,error);
      IF (wert>0.0000001) OR (wert<-0.0000001) OR (error#0) THEN
        isnull:=FALSE;
      END;
    ELSIF mode=3 THEN
      dx:=ABS(minx)+ABS(maxx);
      sx:=dx/640;
      add:=sx;
      real:=sx*(LONG(LONG(pos)))+minx;
      GetNextValue(add);
      wert:=f.RechenLong(root,real,real+0.0001,error);
      REPEAT
        oldwert:=wert;
        real:=real-add;
        wert:=f.RechenLong(root,real,real+0.0001,error);
      UNTIL wert>oldwert;
      REPEAT
        GetNextValue(add);
        wert:=f.RechenLong(root,real,real,error);
        LOOP
          oldwert:=wert;
          real:=real+add;
          wert:=f.RechenLong(root,real,real,error);
          IF error#0 THEN
            isnull:=FALSE;
            EXIT;
          ELSE
            isnull:=TRUE;
          END;
          IF wert>oldwert THEN
            real:=real-add;
            EXIT;
          END;
        END;
        IF add>0.00000001 THEN
          real:=real-add;
        END;
      UNTIL add<=0.00000001;
      wert:=f.RechenLong(root,real,real,error);
      IF (wert>0.0000001) OR (wert<-0.0000001) OR (error#0) THEN
        isnull:=FALSE;
      END;
    ELSIF mode=4 THEN
      dx:=ABS(minx)+ABS(maxx);
      sx:=dx/640;
      real:=sx*(LONG(LONG(pos)))+minx;
      wert:=f.RechenLong(root,real,real,error);
      IF error#0 THEN
        isnull:=FALSE;
      END;
    END;
  END;
  RETURN real;
END DefineNull;

PROCEDURE DefineLuck*(node:l.Node;VAR pos:INTEGER;root:f2.NodePtr;minx,maxx:REAL;r:g.RastPortPtr):LONGREAL;
(* $CopyArrays- *)

VAR dx,sx            : REAL;
    real,oldreal,
    oldwert,wert,add : LONGREAL;
    fpos : INTEGER;
    error: INTEGER;
    bool : BOOLEAN;
    p    : s1.Funktion;
    e    : s1.Error;

BEGIN
  p:=func;
  e:=err;
  real:=-1000000;
  LOOP
    INC(pos);
    IF pos>638 THEN
      EXIT;
    END;
    IF r#NIL THEN
      g.Move(r,16+(pos DIV 4),23);
      g.Draw(r,16+(pos DIV 4),44);
    END;
    IF e[pos]#0 THEN
      EXIT;
    END;
  END;
  IF pos<=638 THEN
    dx:=ABS(minx)+ABS(maxx);
    sx:=dx/640;
    add:=sx;
    real:=sx*(LONG(LONG(pos+1(*-2*))))+minx;
    GetNextValue(add);
    REPEAT
      oldwert:=wert;
      real:=real-add;
      error:=0;
      wert:=f.RechenLong(root,real,real+add,error);
    UNTIL error#0;
    real:=real-add;
    REPEAT
      GetNextValue(add);
      LOOP
        oldwert:=wert;
        real:=real+add;
        error:=0;
        wert:=f.RechenLong(root,real,real+add,error);
        IF error#0 THEN
          EXIT;
        END;
      END;
      IF add>0.0000001 THEN
        real:=real-add;
        real:=real-add;
      END;
    UNTIL add<=0.0000001;
  END;
  RETURN real;
END DefineLuck;

PROCEDURE DefineWende*(node:l.Node;VAR pos:INTEGER;second,third:f2.NodePtr;minx,maxx:REAL;r:g.RastPortPtr;VAR isnull:BOOLEAN):LONGREAL;
(* $CopyArrays- *)
VAR dx,sx            : REAL;
    real,oldreal,
    oldwert,wert,add : LONGREAL;
    fpos : INTEGER;
    error: INTEGER;
    bool : BOOLEAN;
    mode : INTEGER;
    p    : s1.Funktion;

BEGIN
  p:=func;
  real:=-1000000;
  LOOP
    INC(pos);
    IF pos>638 THEN
      EXIT;
    END;
    IF r#NIL THEN
      g.Move(r,16+(pos DIV 4),23);
      g.Draw(r,16+(pos DIV 4),44);
    END;
    IF ((p[pos]>0) (*AND (p[pos]<1)*)) AND ((p[pos+1]<0) (*AND (p[pos+1]>-1)*)) AND (err[pos]=0) AND (err[pos+1]=0) THEN
      mode:=0;
      EXIT;
    ELSIF ((p[pos]<0) (*AND (p[pos]>-1)*)) AND ((p[pos+1]>0) (*AND (p[pos+1]<1)*)) AND (err[pos]=0) AND (err[pos+1]=0) THEN
      mode:=1;
      EXIT;
    ELSIF (p[pos]>=p[pos-1]) AND (p[pos]>p[pos+1]) AND (p[pos]<0.5) AND (p[pos]>-0.5) AND (err[pos]=0) AND (err[pos+1]=0) THEN
      mode:=2;
      EXIT;
    ELSIF (p[pos]<=p[pos-1]) AND (p[pos]<p[pos+1]) AND (p[pos]<0.5) AND (p[pos]>-0.5) AND (err[pos]=0) AND (err[pos+1]=0) THEN
      mode:=3;
      EXIT;
    ELSIF (p[pos]=0) AND (err[pos]=0) THEN
      mode:=4;
      EXIT;
    END;
  END;
  isnull:=TRUE;
  error:=0;
  IF pos<=638 THEN
    IF mode=0 THEN
      dx:=ABS(minx)+ABS(maxx);
      sx:=dx/640;
      add:=sx;
      real:=sx*(LONG(LONG(pos)))+minx;
      GetNextValue(add);
      wert:=f.RechenLong(second,real,real+0.0001,error);
      REPEAT
        oldwert:=wert;
        real:=real-add;
        wert:=f.RechenLong(second,real,real+0.0001,error);
      UNTIL wert>0;
      REPEAT
        GetNextValue(add);
        wert:=f.RechenLong(second,real,real,error);
        LOOP
          oldwert:=wert;
          real:=real+add;
          wert:=f.RechenLong(second,real,real,error);
          IF error#0 THEN
            isnull:=FALSE;
            EXIT;
          ELSE
            isnull:=TRUE;
          END;
          IF wert<0 THEN
            real:=real-add;
            EXIT;
          END;
        END;
        IF add>0.0000001 THEN
          real:=real-add;
        END;
      UNTIL add<=0.0000001;
      wert:=f.RechenLong(second,real,real,error);
      IF error#0 THEN
        isnull:=FALSE;
      END;
      wert:=f.RechenLong(third,real,real,error);
      IF wert=0 THEN
        isnull:=FALSE;
      END;
    ELSIF mode=1 THEN
      dx:=ABS(minx)+ABS(maxx);
      sx:=dx/640;
      add:=sx;
      real:=sx*(LONG(LONG(pos)))+minx;
      GetNextValue(add);
      wert:=f.RechenLong(second,real,real+0.0001,error);
      REPEAT
        oldwert:=wert;
        real:=real-add;
        wert:=f.RechenLong(second,real,real+0.0001,error);
      UNTIL wert<0;
      REPEAT
        GetNextValue(add);
        wert:=f.RechenLong(second,real,real,error);
        LOOP
          oldwert:=wert;
          real:=real+add;
          wert:=f.RechenLong(second,real,real,error);
          IF error#0 THEN
            isnull:=FALSE;
            EXIT;
          ELSE
            isnull:=TRUE;
          END;
          IF wert>0 THEN
            real:=real-add;
            EXIT;
          END;
        END;
        IF add>0.0000001 THEN
          real:=real-add;
        END;
      UNTIL add<=0.0000001;
      wert:=f.RechenLong(second,real,real,error);
      IF error#0 THEN
        isnull:=FALSE;
      END;
      wert:=f.RechenLong(third,real,real,error);
      IF wert=0 THEN
        isnull:=FALSE;
      END;
    ELSIF mode=2 THEN
      dx:=ABS(minx)+ABS(maxx);
      sx:=dx/640;
      add:=sx;
      real:=sx*(LONG(LONG(pos)))+minx;
      GetNextValue(add);
      wert:=f.RechenLong(second,real,real+0.0001,error);
      REPEAT
        oldwert:=wert;
        real:=real-add;
        wert:=f.RechenLong(second,real,real+0.0001,error);
      UNTIL wert<oldwert;
      REPEAT
        GetNextValue(add);
        wert:=f.RechenLong(second,real,real,error);
        LOOP
          oldwert:=wert;
          real:=real+add;
          wert:=f.RechenLong(second,real,real,error);
          IF error#0 THEN
            isnull:=FALSE;
            EXIT;
          ELSE
            isnull:=TRUE;
          END;
          IF wert<oldwert THEN
            real:=real-add;
            EXIT;
          END;
        END;
        IF add>0.00000001 THEN
          real:=real-add;
        END;
      UNTIL add<=0.00000001;
      wert:=f.RechenLong(second,real,real,error);
      IF (wert>0.0000001) OR (wert<-0.0000001) OR (error#0) THEN
        isnull:=FALSE;
      END;
      wert:=f.RechenLong(third,real,real,error);
      IF wert=0 THEN
        isnull:=FALSE;
      END;
    ELSIF mode=3 THEN
      dx:=ABS(minx)+ABS(maxx);
      sx:=dx/640;
      add:=sx;
      real:=sx*(LONG(LONG(pos)))+minx;
      GetNextValue(add);
      wert:=f.RechenLong(second,real,real+0.0001,error);
      REPEAT
        oldwert:=wert;
        real:=real-add;
        wert:=f.RechenLong(second,real,real+0.0001,error);
      UNTIL wert>oldwert;
      REPEAT
        GetNextValue(add);
        wert:=f.RechenLong(second,real,real,error);
        LOOP
          oldwert:=wert;
          real:=real+add;
          wert:=f.RechenLong(second,real,real,error);
          IF error#0 THEN
            isnull:=FALSE;
            EXIT;
          ELSE
            isnull:=TRUE;
          END;
          IF wert>oldwert THEN
            real:=real-add;
            EXIT;
          END;
        END;
        IF add>0.00000001 THEN
          real:=real-add;
        END;
      UNTIL add<=0.00000001;
      wert:=f.RechenLong(second,real,real,error);
      IF (wert>0.0000001) OR (wert<-0.0000001) OR (error#0) THEN
        isnull:=FALSE;
      END;
      wert:=f.RechenLong(third,real,real,error);
      IF wert=0 THEN
        isnull:=FALSE;
      END;
    ELSIF mode=4 THEN
      dx:=ABS(minx)+ABS(maxx);
      sx:=dx/640;
      real:=sx*(LONG(LONG(pos)))+minx;
      wert:=f.RechenLong(second,real,real,error);
      IF error#0 THEN
        isnull:=FALSE;
      END;
      wert:=f.RechenLong(third,real,real,error);
      IF wert=0 THEN
        isnull:=FALSE;
      END;
    END;
  END;
  RETURN real;
END DefineWende;*)

(*PROCEDURE DefineSchnitt*(node1,node2:l.Node;root1,root2:f2.NodePtr;VAR pos:INTEGER;minx,maxx:REAL;r:g.RastPortPtr):LONGREAL;
(* $CopyArrays- *)

VAR dx,sx            : REAL;
    real,oldreal,
    oldwert,wert1,add,wert2 : LONGREAL;
    fpos : INTEGER;
    error: INTEGER;
    bool : BOOLEAN;
    mode : INTEGER;
    p1,p2: s1.Funktion;

BEGIN
  p1:=func;
  p2:=func2;
  real:=-1000000;
  LOOP
    INC(pos);
    IF pos>638 THEN
      EXIT;
    END;
    IF r#NIL THEN
      g.Move(r,16+(pos DIV 4),23);
      g.Draw(r,16+(pos DIV 4),44);
    END;
    IF (p1[pos-1]>p2[pos-1]) AND (p1[pos]<p2[pos]) AND (err[pos-1]=0) AND (err[pos]=0) AND (err2[pos-1]=0) AND (err2[pos]=0) THEN
      mode:=0;
      EXIT;
    ELSIF (p1[pos-1]<p2[pos-1]) AND (p1[pos]>p2[pos]) AND (err[pos-1]=0) AND (err[pos]=0) AND (err2[pos-1]=0) AND (err2[pos]=0) THEN
      mode:=1;
      EXIT;
    ELSIF (p1[pos]=p2[pos]) AND (err[pos]=0) AND (err2[pos]=0) THEN
      mode:=2;
      EXIT;
    END;
  END;
  IF pos<=638 THEN
    IF mode=0 THEN
      dx:=ABS(minx)+ABS(maxx);
      sx:=dx/640;
      add:=sx;
      real:=sx*(LONG(LONG(pos+1(*-2*))))+minx;
      GetNextValue(add);
      REPEAT
        real:=real-add;
        wert1:=f.RechenLong(root1,real,real+0.0001,error);
        wert2:=f.RechenLong(root2,real,real+0.0001,error);
      UNTIL wert1>wert2;
      REPEAT
        GetNextValue(add);
        LOOP
          real:=real+add;
          wert1:=f.RechenLong(root1,real,real+0.0001,error);
          wert2:=f.RechenLong(root2,real,real+0.0001,error);
          IF wert1<wert2 THEN
            real:=real-add;
            EXIT;
          END;
        END;
        IF add>0.0000001 THEN
          real:=real-add;
        END;
      UNTIL add<=0.0000001;
    ELSIF mode=1 THEN
      dx:=ABS(minx)+ABS(maxx);
      sx:=dx/640;
      add:=sx;
      real:=sx*(LONG(LONG(pos+1(*-2*))))+minx;
      GetNextValue(add);
      REPEAT
        real:=real-add;
        wert1:=f.RechenLong(root1,real,real+0.0001,error);
        wert2:=f.RechenLong(root2,real,real+0.0001,error);
      UNTIL wert1<wert2;
      REPEAT
        GetNextValue(add);
        LOOP
          real:=real+add;
          wert1:=f.RechenLong(root1,real,real+0.0001,error);
          wert2:=f.RechenLong(root2,real,real+0.0001,error);
          IF wert1>wert2 THEN
            real:=real-add;
            EXIT;
          END;
        END;
        IF add>0.0000001 THEN
          real:=real-add;
        END;
      UNTIL add<=0.0000001;
    ELSIF mode=2 THEN
      dx:=ABS(minx)+ABS(maxx);
      sx:=dx/640;
      add:=sx;
      real:=sx*(LONG(LONG(pos(*-2*))))+minx;
    END;
  END;
  RETURN real;
END DefineSchnitt;*)

(*PROCEDURE ListSelect*(title:ARRAY OF CHAR;undertitle:ARRAY OF ARRAY OF CHAR;numlists:INTEGER):INTEGER;

VAR wind : I.WindowPtr;
    rast : g.RastPortPtr;
    ok,ca,
    scroll,
    scroll1,
    scroll2,
    punkt,
    liste,
    mark,
    gleiche,
    sort : I.Gadget;
    check: ARRAY 10 OF ARRAY 10 OF I.Gadget;
    bord : I.BorderPtr;
    pos,
    old  : ARRAY 10 OF INTEGER;
    str  : ARRAY 20 OF CHAR;
    bool : BOOLEAN;
    mode : INTEGER;

PROCEDURE RefrList1(n:INTEGER);

BEGIN
  i:=-1;
  LOOP
    INC(i);
    IF (i>9) OR (i+pos[n]>=numlist[n]) THEN
      EXIT;
    END;
    bool:=nrc.RealToString(list[n,i+pos[n]],str,6,6,FALSE);
(*    s1.Clear(str);*)
    g.SetAPen(rast,0);
    g.RectFill(rast,40+n*182,27+i*10,160+n*182,37+i*10);

    g.SetAPen(rast,2);
    b.Print(40+n*182,35+i*10,str,rast);
    IF sel[n,i+pos[n]] THEN
      s1.ActivateBool(s.ADR(check[n,i]),wind);
    ELSE
      s1.DeActivateBool(s.ADR(check[n,i]),wind);
    END;
  END;
END RefrList1;

PROCEDURE RefrList2(n:INTEGER);

BEGIN
  i:=-1;
  LOOP
    INC(i);
    IF (i>9) OR (i+pos[n]>=numlist[n]) THEN
      EXIT;
    END;
    bool:=nrc.RealToString(list[n,i+pos[n]],str,6,6,FALSE);
(*    s1.Clear(str);*)
    g.SetAPen(rast,0);
    g.RectFill(rast,40+n*182,27+i*10,160+n*182,37+i*10);

    g.SetAPen(rast,2);
    b.Print(40+n*182,35+i*10,str,rast);
    IF sel[n,i+pos[n]] THEN
      s1.ActivateBool(s.ADR(check[n,i]),wind);
    ELSE
      s1.DeActivateBool(s.ADR(check[n,i]),wind);
    END;
  END;
END RefrList2;

BEGIN
  IF numlists=1 THEN
    wind:=is.SetWindow(120,15,200,193,s.ADR(title),LONGSET{I.activate,I.windowDrag,I.windowDepth},
                       LONGSET{I.menuPick,I.rawKey,I.gadgetUp,I.gadgetDown,I.mouseButtons,I.mouseMove},s1.screen);
    IF wind#NIL THEN
      rast:=wind.rPort;
      ig.SetPlastGadget(ok,wind,NIL,s.ADR("   OK   "),14,174,
                        SET{I.gadgImmediate,I.relVerify});
      ig.SetPlastGadget(ca,wind,NIL,s.ADR(" Cancel "),118,174,
                        SET{I.gadgImmediate,I.relVerify});
      ig.SetPlastGadget(liste,wind,NIL,s.ADR("      Als Liste      "),14,133,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
      ig.SetPlastGadget(mark,wind,NIL, s.ADR("    Als Markierung   "),14,146,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
      ig.SetPlastGadget(punkt,wind,NIL,s.ADR("      Als Punkt      "),14,159,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
      ig.SetPlastProp(scroll,SET{I.autoKnob,I.freeVert,I.knobHit},172,27,12,100,
                      0,4096,wind);
      i:=-1;
      WHILE i<9 DO
        INC(i);
        ig.SetCheckGadget(check[0,i],wind,16,27+i*10,
                          SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
      END;

      g.SetAPen(rast,2);
      b.Print(16,22,undertitle[0],rast);

      bord:=ig.SetPlastBorder(100,152);
      I.DrawBorder(rast,bord,16,27);
      pos[0]:=0;
      RefrList1(0);
      s1.RefrScroll(scroll,wind,numlist[0],pos[0],10);
      s1.ActivateBool(s.ADR(liste),wind);
      mode:=0;
  
      LOOP
        e.WaitPort(wind.userPort);
        old[0]:=pos[0];
        s1.GetProp(scroll,numlist[0],10,pos[0]);
        IF pos[0]#old[0] THEN
          s1.RefrScroll(scroll,wind,numlist[0],pos[0],10);
          RefrList1(0);
        END;
        is.GetIMes(wind,class,code,address);
        IF I.gadgetUp IN class THEN
          IF address=s.ADR(ok) THEN
            EXIT;
          ELSIF address=s.ADR(liste) THEN
            s1.DeActivateBool(s.ADR(mark),wind);
            s1.DeActivateBool(s.ADR(punkt),wind);
            mode:=0;
            s1.ActivateBool(s.ADR(liste),wind);
          ELSIF address=s.ADR(mark) THEN
            s1.DeActivateBool(s.ADR(liste),wind);
            s1.DeActivateBool(s.ADR(punkt),wind);
            mode:=0;
            s1.ActivateBool(s.ADR(mark),wind);
          ELSIF address=s.ADR(punkt) THEN
            s1.DeActivateBool(s.ADR(mark),wind);
            s1.DeActivateBool(s.ADR(liste),wind);
            mode:=0;
            s1.ActivateBool(s.ADR(punkt),wind);
          ELSE
            i:=-1;
            WHILE i<9 DO
              INC(i);
              IF address=s.ADR(check[0,i]) THEN
                sel[0,i+pos[0]]:=NOT(sel[0,i+pos[0]]);
                IF sel[0,i+pos[0]] THEN
                  s1.ActivateBool(s.ADR(check[0,i]),wind);
                ELSE
                  s1.DeActivateBool(s.ADR(check[0,i]),wind);
                END;
              END;
            END;
          END;
        END;
      END;
  
      i:=10;
      WHILE i>0 DO
        DEC(i);
        ig.FreePlastCheckGadget(check[0,i],wind);
      END;
      ig.FreePlastPropGadget(scroll,wind);
      ig.FreePlastBooleanGadget(punkt,wind);
      ig.FreePlastBooleanGadget(mark,wind);
      ig.FreePlastBooleanGadget(liste,wind);
      ig.FreePlastBooleanGadget(ca,wind);
      ig.FreePlastBooleanGadget(ok,wind);
      I.CloseWindow(wind);
    END;
  ELSIF numlists=2 THEN
    wind:=is.SetWindow(60,15,400,193,s.ADR(title),LONGSET{I.activate,I.windowDrag,I.windowDepth},
                       LONGSET{I.menuPick,I.rawKey,I.gadgetUp,I.gadgetDown,I.mouseButtons,I.mouseMove},s1.screen);
    IF wind#NIL THEN
      rast:=wind.rPort;
      ig.SetPlastGadget(ok,wind,NIL,s.ADR("   OK   "),14,174,
                        SET{I.gadgImmediate,I.relVerify});
      ig.SetPlastGadget(ca,wind,NIL,s.ADR(" Cancel "),118,174,
                        SET{I.gadgImmediate,I.relVerify});
      ig.SetPlastGadget(liste,wind,NIL,s.ADR("      Als Liste      "),14,133,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
      ig.SetPlastGadget(mark,wind,NIL, s.ADR("    Als Markierung   "),14,146,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
      ig.SetPlastGadget(punkt,wind,NIL,s.ADR("      Als Punkt      "),14,159,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
      ig.SetPlastProp(scroll1,SET{I.autoKnob,I.freeVert,I.knobHit},172,27,12,100,
                      0,4096,wind);
      ig.SetPlastProp(scroll2,SET{I.autoKnob,I.freeVert,I.knobHit},354,27,12,100,
                      0,4096,wind);
      ig.SetCheckBoxGadget(gleiche,wind,340,133,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
      ig.SetCheckBoxGadget(sort,wind,340,146,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
      a:=-1;
      WHILE a<1 DO
        INC(a);
        i:=-1;
        WHILE i<9 DO
          INC(i);
          ig.SetCheckGadget(check[a,i],wind,16+a*182,27+i*10,
                            SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
        END;
      END;

      g.SetAPen(rast,2);
      b.Print(16,22,undertitle[0],rast);
      b.Print(198,22,undertitle[1],rast);
      b.Print(198,141,"In gleiche Spalte",rast);
      b.Print(198,154,"Sortieren",rast);

      bord:=ig.SetPlastBorder(100,152);
      I.DrawBorder(rast,bord,16,27);
      I.DrawBorder(rast,bord,198,27);
      pos[0]:=0;
      pos[1]:=0;
      RefrList2(0);
      RefrList2(1);
      s1.RefrScroll(scroll1,wind,numlist[0],pos[0],10);
      s1.RefrScroll(scroll2,wind,numlist[1],pos[1],10);
      s1.ActivateBool(s.ADR(liste),wind);
      mode:=0;
  
      LOOP
        e.WaitPort(wind.userPort);
        old[1]:=pos[0];
        s1.GetProp(scroll1,numlist[0],10,pos[0]);
        IF pos[0]#old[1] THEN
          s1.RefrScroll(scroll1,wind,numlist[0],pos[0],10);
          RefrList2(0);
        END;
        old[2]:=pos[1];
        s1.GetProp(scroll2,numlist[1],10,pos[1]);
        IF pos[1]#old[2] THEN
          s1.RefrScroll(scroll2,wind,numlist[1],pos[1],10);
          RefrList2(1);
        END;
        is.GetIMes(wind,class,code,address);
        IF I.gadgetUp IN class THEN
          IF address=s.ADR(ok) THEN
            EXIT;
          ELSIF address=s.ADR(liste) THEN
            s1.DeActivateBool(s.ADR(mark),wind);
            s1.DeActivateBool(s.ADR(punkt),wind);
            mode:=0;
            s1.ActivateBool(s.ADR(liste),wind);
          ELSIF address=s.ADR(mark) THEN
            s1.DeActivateBool(s.ADR(liste),wind);
            s1.DeActivateBool(s.ADR(punkt),wind);
            mode:=1;
            s1.ActivateBool(s.ADR(mark),wind);
          ELSIF address=s.ADR(punkt) THEN
            s1.DeActivateBool(s.ADR(mark),wind);
            s1.DeActivateBool(s.ADR(liste),wind);
            mode:=2;
            s1.ActivateBool(s.ADR(punkt),wind);
          ELSE
            a:=-1;
            WHILE a<1 DO
              INC(a);
              i:=-1;
              WHILE i<9 DO
                INC(i);
                IF address=s.ADR(check[a,i]) THEN
                  sel[0,i+pos[a]]:=NOT(sel[0,i+pos[a]]);
                  IF sel[0,i+pos[0]] THEN
                    s1.ActivateBool(s.ADR(check[a,i]),wind);
                  ELSE
                    s1.DeActivateBool(s.ADR(check[a,i]),wind);
                  END;
                END;
              END;
            END;
          END;
        END;
      END;
  
      a:=2;
      WHILE a>0 DO
        DEC(a);
        i:=10;
        WHILE i>0 DO
          DEC(i);
          ig.FreePlastCheckGadget(check[a,i],wind);
        END;
      END;
      ig.FreePlastCheckBoxGadget(sort,wind);
      ig.FreePlastCheckBoxGadget(gleiche,wind);
      ig.FreePlastPropGadget(scroll2,wind);
      ig.FreePlastPropGadget(scroll1,wind);
      ig.FreePlastBooleanGadget(punkt,wind);
      ig.FreePlastBooleanGadget(mark,wind);
      ig.FreePlastBooleanGadget(liste,wind);
      ig.FreePlastBooleanGadget(ca,wind);
      ig.FreePlastBooleanGadget(ok,wind);
      I.CloseWindow(wind);
    END;
  END;
  RETURN mode;
END ListSelect;*)

PROCEDURE ListToList(title,term:ARRAY OF CHAR;stand:BOOLEAN);
(* $CopyArrays- *)

VAR node,node2,list : l.Node;
    real            : LONGREAL;

BEGIN
  bool:=s8.NumberFormat(s8.nach,s8.exp);
  IF bool THEN
    list:=NIL;
    NEW(list(s1.List));
    s1.InitNode(list);
    s1.CopyNode(s1.std.list,list);
    WITH list: s1.List DO
(*      list.topsep:=TRUE;*)
      COPY(title,list.name);
      st.AppendChar(list.name," ");
      st.Append(list.name,ac.GetString(ac.Of)^);
      st.AppendChar(list.name," ");
      st.Append(list.name,term);
    END;
  
    NEW(node2(s1.ListSpalt));
    node2(s1.ListSpalt).zeilen:=l.Create();
    list(s1.List).spalten.AddTail(node2);
    NEW(node2(s1.ListSpalt));
    node2(s1.ListSpalt).zeilen:=l.Create();
    list(s1.List).spalten.AddTail(node2);
  
    node2:=NIL;
    NEW(node2(s1.ListZeil));
    node2(s1.ListZeil).string:="x";
    node2(s1.ListZeil).color:=1;
    list(s1.List).spalten.head(s1.ListSpalt).zeilen.AddTail(node2);
    NEW(node2(s1.ListZeil));
    node2(s1.ListZeil).string:="f(x)";
    node2(s1.ListZeil).color:=1;
    list(s1.List).spalten.head.next(s1.ListSpalt).zeilen.AddTail(node2);
  
    node:=viewlist.head;
    WHILE node#NIL DO
      NEW(node2(s1.ListZeil));
      COPY(node(ListElement).xstring,node2(s1.ListZeil).string);
      tt.Clear(node2(s1.ListZeil).string);
      bool:=lrc.StringToReal(node2(s1.ListZeil).string,real);
      bool:=lrc.RealToString(real,node2(s1.ListZeil).string,8,s8.nach,s8.exp);
      tt.Clear(node2(s1.ListZeil).string);
      node2(s1.ListZeil).color:=1;
      list(s1.List).spalten.head(s1.ListSpalt).zeilen.AddTail(node2);
      NEW(node2(s1.ListZeil));
      COPY(node(ListElement).ystring,node2(s1.ListZeil).string);
      tt.Clear(node2(s1.ListZeil).string);
      bool:=lrc.StringToReal(node2(s1.ListZeil).string,real);
      bool:=lrc.RealToString(real,node2(s1.ListZeil).string,8,s8.nach,s8.exp);
      tt.Clear(node2(s1.ListZeil).string);
      node2(s1.ListZeil).color:=1;
      list(s1.List).spalten.head.next(s1.ListSpalt).zeilen.AddTail(node2);
  
      node:=node.next;
    END;
  
    bool:=TRUE;
    IF NOT(stand) THEN
      bool:=s10.ChangeList(list);
    END;
    IF bool THEN
      s1.lists.AddTail(list);
      s10.RefreshListDatas(s1.window.rPort,list);
      s1.SendNewObject(list);
      s1.LockNode(list);
      s10.PlotList(list);
      s1.UnLockNode(list);
    END;
  END;
END ListToList;

PROCEDURE GetNextName(VAR name:ARRAY OF CHAR);

VAR chars     : ARRAY 80 OF CHAR;
    i,pos     : INTEGER;
    num,onum,
    exit      : BOOLEAN;
    real      : LONGREAL;

BEGIN
  i:=SHORT(st.Length(name))-1;
  IF i>=0 THEN
    exit:=FALSE;
    num:=f.isNumber(name[i]);
    WHILE (i>0) AND NOT(exit) DO
      DEC(i);
      onum:=num;
      num:=f.isNumber(name[i]);
      IF num#onum THEN
        exit:=TRUE;
      END;
    END;
    IF NOT(exit) AND (i<0) THEN
      INC(i);
    END;
    st.Cut(name,i,st.Length(name)-i,chars);
    st.Delete(name,i,st.Length(name));
    IF num THEN
      bool:=lrc.StringToReal(chars,real);
      real:=real+1;
      bool:=lrc.RealToString(real,chars,7,7,FALSE);
      tt.Clear(chars);
    ELSE
      pos:=SHORT(st.Length(chars));
      exit:=FALSE;
      WHILE (pos>0) AND NOT(exit) DO
        DEC(pos);
        i:=ORD(chars[pos]);
        INC(i);
        IF i=90 THEN
          i:=65;
        ELSIF i=122 THEN
          i:=97;
        ELSE
          exit:=TRUE;
        END;
        chars[pos]:=CHR(i);
      END;
      IF (pos=0) AND NOT(exit) THEN
        i:=SHORT(st.Length(chars))-1;
        st.AppendChar(chars,chars[i]);
      END;
    END;
    st.Append(name,chars);
  END;
END GetNextName;

PROCEDURE ListToPoints(p:l.Node;stand:BOOLEAN);

VAR node,node2,
    point      : l.Node;
    colf,colb  : INTEGER;
    style      : SHORTSET;
    trans      : BOOLEAN;
    nach       : INTEGER;
    exp        : BOOLEAN;

BEGIN
  bool:=s4.GetString(s1.screen,ac.GetString(ac.CreatePoints),ac.GetString(ac.NameOfFirstPoint),name);
  IF bool THEN
    NEW(point(s1.Point));
    s1.InitNode(point);
    s1.CopyNode(s1.std.point,point);
    bool:=TRUE;
    IF NOT(stand) THEN
      bool:=s12.ChangePoint(s1.std.wind,point);
    END;
    node:=viewlist.head;
    IF NOT(bool) THEN
      node:=NIL;
    END;
    WHILE node#NIL DO
      NEW(node2(s1.Point));
      s1.InitNode(node2);
      s1.CopyNode(point,node2);
      WITH node2: s1.Point DO
        COPY(name,node2.string);
        COPY(node(ListElement).xstring,node2.xkstr);
        COPY(node(ListElement).ystring,node2.ykstr);
        tt.Clear(node2.xkstr);
        tt.Clear(node2.ykstr);
        node2.weltx:=f.ExpressionToReal(node2.xkstr);
        node2.welty:=f.ExpressionToReal(node2.ykstr);
        s1.WorldToPic(node2.weltx,node2.welty,node2.picx,node2.picy,p);
        node2.welt:=TRUE;
      END;
      p(s1.Fenster).points.AddTail(node2);
      s4.PlotObject(p,node2,TRUE);
      GetNextName(name);
      node:=node.next;
    END;
  END;
END ListToPoints;

PROCEDURE ListToMarks(p:l.Node;stand:BOOLEAN);

VAR node,node2,
    mark       : l.Node;
    colf,colb  : INTEGER;
    style      : SHORTSET;
    trans      : BOOLEAN;
    nach       : INTEGER;
    exp        : BOOLEAN;

BEGIN
  bool:=s4.GetString(s1.screen,ac.GetString(ac.CreateMarkers),ac.GetString(ac.NameOfFirstMarker),name);
  IF bool THEN
    NEW(mark(s1.Mark));
    s1.InitNode(mark);
    s1.CopyNode(s1.std.mark,mark);
    bool:=TRUE;
    IF NOT(stand) THEN
      bool:=s12.ChangePoint(s1.std.wind,mark);
    END;
    node:=viewlist.head;
    IF NOT(bool) THEN
      node:=NIL;
    END;
    WHILE node#NIL DO
      NEW(node2(s1.Mark));
      s1.InitNode(node2);
      s1.CopyNode(mark,node2);
      WITH node2: s1.Mark DO
        COPY(name,node2.string);
        COPY(node(ListElement).xstring,node2.xkstr);
(*        COPY(node(ListElement).ystring,node2.ykstr);*)
        tt.Clear(node2.xkstr);
(*        tt.Clear(node2.ykstr);*)
        node2.weltx:=f.ExpressionToReal(node2.xkstr);
        node2.welty:=f.ExpressionToReal(node2.ykstr);
        s1.WorldToPic(node2.weltx,node2.welty,node2.picx,node2.picy,p);
        node2.welt:=TRUE;
      END;
      p(s1.Fenster).marks.AddTail(node2);
      s4.PlotObject(p,node2,TRUE);
      GetNextName(name);
      node:=node.next;
    END;
  END;
END ListToMarks;

PROCEDURE ListSelect*(title:e.STRPTR;term:ARRAY OF CHAR;xmin,xmax:REAL;p:l.Node;twofuncs:BOOLEAN):INTEGER;

VAR wind    : I.WindowPtr;
    rast    : g.RastPortPtr;
    ok,ca,
    help,
    mode,
    stand,
    up,down,
    scroll  : I.GadgetPtr;
    str,str2,
    req1,req2: ARRAY 80 OF CHAR;
    bord1,
    bord2,
    bord3   : I.BorderPtr;
    pos,opos,
    ret,shown,
    modepos,
    standpos,
    width,
    height,
    x,y,
    count   : INTEGER;
    table   : ARRAY 3 OF ARRAY 28 OF CHAR;
    table2  : ARRAY 2 OF ARRAY 30 OF CHAR;
    boolup,
    booldown,
    pressed : BOOLEAN;
    sec1,mic1,
    sec2,mic2 : LONGINT;
    act,old : l.Node;
    name    : ARRAY 80 OF CHAR;
    marked  : BOOLEAN;

PROCEDURE GetElement(x,y:INTEGER):l.Node;

VAR node : l.Node;

BEGIN
  IF (x>=22) AND (x<width-52) THEN
    DEC(y,58);
    y:=y DIV 10;
    IF (y>=0) AND (y<shown) THEN
      INC(y,pos);
      node:=s1.GetNode(viewlist,y);
    END;
  END;
  RETURN node;
END GetElement;

PROCEDURE RefreshList;

VAR str : ARRAY 20 OF CHAR;
    x   : INTEGER;
    node: l.Node;

BEGIN
  x:=30+((width-278) DIV 2);
  x:=148;
  i:=-1;
  node:=s1.GetNode(viewlist,pos);
  WHILE node#NIL DO
    INC(i);
    IF node(ListElement).marked THEN
      g.SetAPen(rast,1);
    ELSE
      g.SetAPen(rast,2);
    END;
    tt.Print(26,i*10+65,s.ADR(node(ListElement).xstring),rast);
    tt.Print(x,i*10+65,s.ADR(node(ListElement).ystring),rast);
    tt.Print(270,i*10+65,s.ADR(node(ListElement).comment),rast);
    node:=node.next;
    IF i>=shown-1 THEN
      node:=NIL;
    END;
  END;
END RefreshList;

PROCEDURE ScrollOneUp;

VAR str : ARRAY 20 OF CHAR;
    x,i : INTEGER;
    node: l.Node;

BEGIN
  IF (pos>=0) AND (shown+pos<SHORT(viewlist.nbElements())+1) THEN
    x:=142;
    node:=s1.GetNode(viewlist,pos);
    IF node(ListElement).marked THEN
      g.SetAPen(rast,1);
    ELSE
      g.SetAPen(rast,2);
    END;
    g.ScrollRaster(rast,0,-10,22,57,x-1,57+height-103);
    tt.Print(26,65,s.ADR(node(ListElement).xstring),rast);
    g.ScrollRaster(rast,0,-10,x+2,57,263,57+height-103);
    tt.Print(148,65,s.ADR(node(ListElement).ystring),rast);
    g.ScrollRaster(rast,0,-10,266,57,width-74,57+height-103);
    tt.Print(270,65,s.ADR(node(ListElement).comment),rast);
  END;
END ScrollOneUp;

PROCEDURE ScrollOneDown;

VAR str : ARRAY 20 OF CHAR;
    x,i : INTEGER;
    node: l.Node;

BEGIN
  IF (pos>=0) AND (shown+pos<SHORT(viewlist.nbElements())+1) THEN
    x:=142;
    node:=s1.GetNode(viewlist,shown-1+pos);
    IF node(ListElement).marked THEN
      g.SetAPen(rast,1);
    ELSE
      g.SetAPen(rast,2);
    END;
    g.ScrollRaster(rast,0,10,22,57,x-1,57+height-103);
    tt.Print(26,(shown-1)*10+65,s.ADR(node(ListElement).xstring),rast);
    g.ScrollRaster(rast,0,10,x+2,57,263,57+height-103);
    tt.Print(148,(shown-1)*10+65,s.ADR(node(ListElement).ystring),rast);
    g.ScrollRaster(rast,0,10,266,57,width-74,57+height-103);
    tt.Print(270,(shown-1)*10+65,s.ADR(node(ListElement).comment),rast);
  END;
END ScrollOneDown;

PROCEDURE RefreshBorders;

VAR bord : I.BorderPtr;

BEGIN
  gm.DrawPropBorders(wind);

  it.DrawBorder(rast,14,16,width-42,height-40);
  it.DrawBorder(rast,20,44,width-70,12);
  it.DrawBorder(rast,20,56,width-70,height-99);

(*  bord:=ig.SetPlastBorder(height-44,width-46);
  I.DrawBorder(rast,bord,16,17);
  ig.FreePlastBorder(bord);

  bord:=ig.SetPlastInBorder(8,width-74);
  I.DrawBorder(rast,bord,22,45);
  ig.FreePlastBorder(bord);

  bord:=ig.SetPlastInBorder(height-103,width-74);
  I.DrawBorder(rast,bord,22,57);
  ig.FreePlastBorder(bord);

  bord:=ig.SetPlastBorder(height-123,12);
  I.DrawBorder(rast,bord,width-48,57);
  ig.FreePlastBorder(bord);*)

  i:=22+((width-278) DIV 2);
  i:=142;
  g.SetAPen(rast,1);
  g.Move(rast,i,46);
  g.Draw(rast,i,53);
  g.Move(rast,i,58);
  g.Draw(rast,i,height-46);
  INC(i);
  g.SetAPen(rast,2);
  g.Move(rast,i,46);
  g.Draw(rast,i,53);
  g.Move(rast,i,58);
  g.Draw(rast,i,height-46);

  i:=264;
  g.SetAPen(rast,1);
  g.Move(rast,i,46);
  g.Draw(rast,i,53);
  g.Move(rast,i,58);
  g.Draw(rast,i,height-46);
  INC(i);
  g.SetAPen(rast,2);
  g.Move(rast,i,46);
  g.Draw(rast,i,53);
  g.Move(rast,i,58);
  g.Draw(rast,i,height-46);
END RefreshBorders;

PROCEDURE RefreshText;

BEGIN
  i:=width-56;
  i:=i DIV 8;
  g.SetAPen(rast,1);
  IF twofuncs THEN
    str:=" ";
    st.Append(str,ac.GetString(ac.OfFunctions)^);
  ELSE
    str:=" ";
    st.Append(str,ac.GetString(ac.OfFunction)^);
  END;
  st.Insert(str,0,title^);
  st.AppendChar(str,0X);
  tt.Print(20,25,s.ADR(str),rast);
  st.Delete(str,0,i);
  st.Cut(term,0,i,str);
  IF st.Length(term)>i THEN
    str[i-2]:=".";
    str[i-1]:=".";
  END;
  tt.Print(20,33,s.ADR(str),rast);
  st.Delete(str,0,i);
  FOR a:=0 TO i DO
    str[a]:=" ";
  END;
  bool:=lrc.RealToString(xmin,str,6,2,FALSE);
  bool:=lrc.RealToString(xmax,str2,6,2,FALSE);
  tt.Clear(str);
  tt.Clear(str2);
  st.Append(str,"..");
  st.Append(str,str2);
  st.AppendChar(str,0X);
  st.Insert(str,0,": ");
  st.Insert(str,0,ac.GetString(ac.XAxisDomain)^);
  IF st.Length(term)>i THEN
    str[i-2]:=".";
    str[i-1]:=".";
  END;
  tt.Print(20,41,s.ADR(str),rast);
  g.SetAPen(rast,2);
  tt.Print(52,52,ac.GetString(ac.Abscissa),rast);
  tt.Print(175,52,ac.GetString(ac.Ordinate),rast);
  tt.Print(318+(width-318-40) DIV 2-g.TextLength(rast,ac.GetString(ac.Comment)^,st.Length(ac.GetString(ac.Comment)^)),52,ac.GetString(ac.Comment),rast);
END RefreshText;

PROCEDURE RefreshStand;

BEGIN
  IF modepos=0 THEN
    COPY(ac.GetString(ac.DefaultList)^,table2[0]);
    COPY(ac.GetString(ac.CustomList)^,table2[1]);
  ELSIF modepos=1 THEN
    COPY(ac.GetString(ac.DefaultPoint)^,table2[0]);
    COPY(ac.GetString(ac.CustomPoint)^,table2[1]);
  ELSIF modepos=2 THEN
    COPY(ac.GetString(ac.DefaultMarker)^,table2[0]);
    COPY(ac.GetString(ac.CustomMarker)^,table2[1]);
  END;
  gm.CyclePressed(stand,wind,table2,standpos);
  gm.CyclePressed(stand,wind,table2,standpos);
END RefreshStand;

BEGIN
  IF NOT(viewlist.isEmpty()) THEN
    ret:=0;
    IF listId=-1 THEN
      listId:=wm.InitWindow(20,10,(*328*)526,203,title,LONGSET{I.activate,I.windowDrag,I.windowDepth,I.windowSizing,I.noCareRefresh},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.newSize},s1.screen,TRUE);
    END;
    gm.StartGadgets(s1.window);
    ok:=gm.SetBooleanGadget(14,-20,100,14,ac.GetString(ac.OK));
    INCL(ok.flags,I.gRelBottom);
    help:=gm.SetBooleanGadget(120,-20,100,14,ac.GetString(ac.Help));
    INCL(help.flags,I.gRelBottom);
    ca:=gm.SetBooleanGadget(-127,-20,100,14,ac.GetString(ac.Cancel));
    INCL(ca.flags,I.gRelBottom);
    INCL(ca.flags,I.gRelRight);
    COPY(ac.GetString(ac.AsList)^,table[0]);
    COPY(ac.GetString(ac.AsPoints)^,table[1]);
    COPY(ac.GetString(ac.AsMarkers)^,table[2]);
    modepos:=0;
    mode:=gm.SetCycleGadget(20,-40,234,14,table[0]);
    INCL(mode.flags,I.gRelBottom);
    COPY(ac.GetString(ac.DefaultList)^,table2[0]);
    COPY(ac.GetString(ac.CustomList)^,table2[1]);
    standpos:=0;
    stand:=gm.SetCycleGadget(258,-40,234,14,table2[0]);
    INCL(stand.flags,I.gRelBottom);
    up:=gm.SetArrowUpGadget(-49,-62);
    INCL(up.flags,I.gRelBottom);
    INCL(up.flags,I.gRelRight);
    down:=gm.SetArrowDownGadget(-49,-52);
    INCL(down.flags,I.gRelBottom);
    INCL(down.flags,I.gRelRight);
    scroll:=gm.SetPropGadget(-49,56,16,-119,0,0,0,32767);
    INCL(scroll.flags,I.gRelHeight);
    INCL(scroll.flags,I.gRelRight);
    gm.EndGadgets;
    wm.SetGadgets(listId,ok);
    wm.ChangeTitle(listId,title);
    wm.ChangeScreen(listId,s1.screen);
    wind:=wm.OpenWindow(listId);
  (*  wind:=is.SetWindow(20,10,328,203,s.ADR(title),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.windowSizing},
                       LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.newSize},s1.screen);*)
    IF wind#NIL THEN
      rast:=wind.rPort;
      width:=wind.width;
      height:=wind.height;
      bool:=I.WindowLimits(wind,526,203,-1,-1);
(*      ok.flags:=SET{I.gRelBottom};
      ig.SetPlastHighGadget(ok,wind,s.ADR("OK"),12,-21,100,
                        SET{I.gadgImmediate,I.relVerify});
      ca.flags:=SET{I.gRelBottom,I.gRelRight};
      ig.SetPlastHighGadget(ca,wind,s.ADR("Abbruch"),-129,-21,100,
                        SET{I.gadgImmediate,I.relVerify});
      table[0]:="Als Liste";
      table[1]:="Als Punkte";
      table[2]:="Als Markierungen";
      modepos:=0;
      mode.flags:=SET{I.gRelBottom};
      ig.SetPlastCycleGadget(mode,wind,s.ADR(table[0]),18,-41,234,
                        SET{I.gadgImmediate,I.relVerify});
      table2[0]:="Standard-Liste";
      table2[1]:="Eigene Liste";
      standpos:=0;
      stand.flags:=SET{I.gRelBottom};
      ig.SetPlastCycleGadget(stand,wind,s.ADR(table2[0]),256,-41,234,
                        SET{I.gadgImmediate,I.relVerify});
      up.flags:=SET{I.gRelBottom,I.gRelRight};
      ig.SetArrowUpGadget(up,wind,-49,-62,
                        SET{I.gadgImmediate,I.relVerify});
      down.flags:=SET{I.gRelBottom,I.gRelRight};
      ig.SetArrowDownGadget(down,wind,-49,-52,
                        SET{I.gadgImmediate,I.relVerify});
      scroll.flags:=SET{I.gRelHeight,I.gRelRight};
      ig.SetPlastProp(scroll,SET{I.autoKnob,I.freeVert,I.knobHit},-47,57,12,-123,
                      0,4096,wind);*)

      WHILE modepos#prevmode DO
        gm.CyclePressed(mode,wind,table,modepos);
      END;
      WHILE standpos#prevstand DO
        gm.CyclePressed(stand,wind,table2,standpos);
      END;

      g.SetDrMd(rast,g.jam2);
  
      RefreshBorders;
      RefreshText;
  
      shown:=(height-103) DIV 10;
      pos:=0;
      opos:=0;
      RefreshList;
      gm.SetScroller(scroll,wind,SHORT(viewlist.nbElements()),shown,pos);

      RefreshStand;
      count:=-1;
      name[0]:=title[0];
      name[1]:=0X;

      LOOP
        IF NOT(pressed) AND NOT(boolup) AND NOT(booldown) THEN
          e.WaitPort(wind.userPort);
        END;
        it.GetIMes(wind,class,code,address);
        IF I.gadgetDown IN class THEN
          IF address=scroll THEN
            pressed:=TRUE;
          ELSIF address=up THEN
            boolup:=TRUE;
          ELSIF address=down THEN
            booldown:=TRUE;
          END;
        ELSIF I.gadgetUp IN class THEN
          IF address=scroll THEN
            pressed:=FALSE;
          ELSIF address=up THEN
            boolup:=FALSE;
          ELSIF address=down THEN
            booldown:=FALSE;
          END;
        ELSIF I.mouseButtons IN class THEN
          IF code=I.selectUp THEN
            boolup:=FALSE;
            booldown:=FALSE;
          END;
        END;
        opos:=pos;
        pos:=gm.GetScroller(scroll,SHORT(viewlist.nbElements()),shown);
        IF boolup THEN
          DEC(pos);
          IF pos<0 THEN
            pos:=0;
          END;
          IF opos#pos THEN
            gm.SetScroller(scroll,wind,SHORT(viewlist.nbElements()),shown,pos);
          END;
        ELSIF booldown THEN
          INC(pos);
          IF pos>SHORT(viewlist.nbElements())-shown THEN
            DEC(pos);
          END;
          IF opos#pos THEN
            gm.SetScroller(scroll,wind,SHORT(viewlist.nbElements()),shown,pos);
          END;
        END;
        IF opos#pos THEN
          gm.SetScroller(scroll,wind,SHORT(viewlist.nbElements()),shown,pos);
          IF (opos>pos) AND (opos<pos+(shown DIV 2)) THEN
            i:=pos;
            pos:=opos;
            WHILE pos#i DO
              DEC(pos);
              ScrollOneUp;
            END;
          ELSIF (opos<pos) AND (opos>pos-(shown DIV 2)) THEN
            i:=pos;
            pos:=opos;
            WHILE pos#i DO
              INC(pos);
              ScrollOneDown;
            END;
          ELSE
            RefreshList;
          END;
        END;
        IF I.gadgetUp IN class THEN
          IF address=ok THEN
            prevmode:=modepos;
            prevstand:=standpos;
            IF standpos=0 THEN
              bool:=TRUE;
            ELSE
              bool:=FALSE;
            END;
            IF modepos=0 THEN
              ListToList(title^,term,bool);
            ELSIF modepos=1 THEN
              ListToPoints(p,bool);
            ELSIF modepos=2 THEN
              ListToMarks(p,bool);
            END;
            EXIT;
          ELSIF address=ca THEN
            EXIT;
          ELSIF address=mode THEN
            gm.CyclePressed(mode,wind,table,modepos);
            RefreshStand;
          ELSIF address=stand THEN
            gm.CyclePressed(stand,wind,table2,standpos);
          END;
        ELSIF I.mouseButtons IN class THEN
          IF code=I.selectDown THEN
            it.GetMousePos(wind,x,y);
            old:=act;
            act:=GetElement(x,y);
            IF act#NIL THEN
              marked:=TRUE;
              g.SetDrMd(rast,SHORTSET{g.complement});
              i:=((y-58) DIV 10)*10+58;
              g.RectFill(rast,22,i,width-53,i+9);
              g.SetDrMd(rast,g.jam1);
              sec1:=sec2;
              mic1:=mic2;
              I.CurrentTime(sec2,mic2);
              IF old=act THEN
                IF I.DoubleClick(sec1,mic1,sec2,mic2) THEN
                  COPY(title^,str);
                  str[st.Length(title^)-1]:=0X;
                  INC(count);
                  IF count>32766 THEN
                    count:=0;
                  END;
                  bool:=c.IntToString(count,str2,5);
                  tt.Clear(str2);
                  st.Insert(str2,0,name);
                  act:=s4.AddConstant(str2,str,act(ListElement).xreal);
                  bool:=s4.GetConstant(ac.GetString(ac.ChangeVariable),act);
                  IF NOT(bool) THEN
                    act.Remove;
                    DEC(count);
                  ELSE
                    str[0]:=0X;
                    i:=SHORT(st.Length(act(f1.Constant).name^)-1);
                    WHILE (i>=0) AND (f.isNumber(act(f1.Constant).name[i])) DO
                      st.InsertChar(str,0,act(f1.Constant).name[i]);
                      DEC(i);
                    END;
                    COPY(act(f1.Constant).name^,name);
                    name[i+1]:=0X;
                    bool:=c.StringToInt(str,sec1);
                    count:=SHORT(sec1);
                  END;
                  act:=NIL;
                  marked:=FALSE;
                  g.SetDrMd(rast,SHORTSET{g.complement});
                  i:=((y-58) DIV 10)*10+58;
                  g.RectFill(rast,22,i,width-53,i+9);
                  g.SetDrMd(rast,g.jam1);
                END;
              END;
            END;
          ELSIF code=I.selectUp THEN
            IF marked THEN
              marked:=FALSE;
              g.SetDrMd(rast,SHORTSET{g.complement});
              i:=((y-58) DIV 10)*10+58;
              g.RectFill(rast,22,i,width-53,i+9);
              g.SetDrMd(rast,g.jam1);
            END;
          END;
        ELSIF I.newSize IN class THEN
          width:=wind.width;
          height:=wind.height;
          shown:=(height-103) DIV 10;
          g.SetAPen(rast,0);
          g.RectFill(rast,4,11,width-19,height-3);
          I.RefreshGList(ok,wind,NIL,6);
          I.RefreshWindowFrame(wind);
          RefreshBorders;
          RefreshText;
          RefreshList;
        END;
        IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"discusslistreq",wind);
        END;
      END;
  
(*      ig.FreePlastPropGadget(scroll,wind);
      ig.FreePlastArrowGadget(down,wind);
      ig.FreePlastArrowGadget(up,wind);
      ig.FreePlastCycleGadget(stand,wind);
      ig.FreePlastCycleGadget(mode,wind);
      ig.FreePlastHighBooleanGadget(ca,wind);
      ig.FreePlastHighBooleanGadget(ok,wind);*)
      wm.CloseWindow(listId);
    END;
    wm.FreeGadgets(listId);
  ELSE
    COPY(ac.GetString(ac.None)^,req1);
    st.Append(req1,title^);
    st.AppendChar(req1," ");
    st.Append(req1,ac.GetString(ac.InThe)^);
    COPY(ac.GetString(ac.Range)^,req2);
    st.AppendChar(req2," ");
    bool:=lrc.RealToString(xmin,str,6,2,FALSE);
    bool:=lrc.RealToString(xmax,str2,6,2,FALSE);
    tt.Clear(str);
    tt.Clear(str2);
    st.Append(str,"..");
    st.Append(str,str2);
    st.Append(req2,str);
    st.AppendChar(req2," ");
    st.Append(req2,ac.GetString(ac.FoundEx)^);
    bool:=rt.RequestWin(s.ADR(req1),s.ADR(req2),s.ADR(""),ac.GetString(ac.OK),s1.window);
  END;
  RETURN ret;
END ListSelect;

(*PROCEDURE QUICK(links,rechts:INTEGER); (* $StackChk- *)

VAR li,re     : INTEGER;
    test,hilf : REAL;

BEGIN
  li:=links; re:=rechts; test:=list[0,(li+re) DIV 2];

  WHILE (li<=re) DO
    WHILE (list[0,li]<test) DO li:=li+1;END;
    WHILE (list[0,re]>test) DO re:=re-1;END;
    IF (li<=re) THEN
      hilf:=list[0,li];
      list[0,li]:=list[0,re];
      list[0,re]:=hilf;
      li:=li+1; re:=re-1;
    END;
  END;
  IF (links<re) THEN QUICK(links,re);END;
  IF (li<rechts) THEN QUICK(li,rechts);END;
END QUICK; (* StackChk= *)*)

PROCEDURE Sort*;

VAR node,node2,next : l.Node;

BEGIN
  node:=viewlist.head;
  WHILE node#NIL DO
    next:=node.next;
    node2:=viewlist.head;
    WHILE node2#NIL DO
      IF node(ListElement).xreal<node2(ListElement).xreal THEN
        node.Remove;
        node2.AddBefore(node);
        node2:=NIL;
      END;
      IF node2#NIL THEN
        node2:=node2.next;
      END;
    END;
    node:=next;
  END;
END Sort;

BEGIN
  listId:=-1;
  viewlist:=l.Create();
  first:=TRUE;
  name:="A1";
  prevmode:=0;
  prevstand:=0;
  barwi:=320;
END SuperCalcTools13.











































































































