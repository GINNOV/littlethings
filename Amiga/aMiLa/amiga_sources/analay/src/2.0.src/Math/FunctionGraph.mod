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


MODULE FunctionGraph;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       gt : GraphicsTools,
       tt : TextTools,
       gmo: GuiManagerObjects,
       gme: GuiManagerExtendedObjects,
       go : GraphicObjects,
       w  : Window,
       c  : Coords,
       dc : DisplayConversion,
       fb : FunctionBasics,
       ft : FunctionTrees,
       t  : Terms,
       io,
       NoGuruRq;

TYPE BorderVal * = POINTER TO BorderValDesc;
     BorderValDesc * = RECORD(l.NodeDesc)    (* Left and right limiting value of *)
       x      * ,                            (* a definition gap. *)
       left   * ,
       right  * : LONGREAL;
     END;

TYPE FuncData  * = RECORD                    (* One point of a function's graph. *)
       real      * : LONGREAL;
       error     * : INTEGER;
       updown    * : INTEGER;
     END;
     FuncTable * = POINTER TO ARRAY OF FuncData;  (* Table with all calculated points of a functions's graph. *)

PROCEDURE CopyFuncTable*(table,dest:FuncTable);

VAR i    : LONGINT;

BEGIN
  IF dest#NIL THEN
    FOR i:=0 TO LEN(dest^)-1 DO
      dest[i].real:=table[i].real;
      dest[i].error:=table[i].error;
      dest[i].updown:=table[i].updown;
    END;
  END;
END CopyFuncTable;

PROCEDURE CopyFuncTableNew*(table:FuncTable):FuncTable;

VAR dest: FuncTable;

BEGIN
  NEW(dest,LEN(table^));
  IF dest#NIL THEN
    CopyFuncTable(table,dest);
  END;
  RETURN dest;
END CopyFuncTableNew;



TYPE FunctionGraph * = POINTER TO FunctionGraphDesc;
     FunctionGraphDesc * = RECORD(l.NodeDesc)
       table      * : FuncTable;
       bordervals * : l.List;                (* List of BorderVal Nodes. *)
       stutz      * : LONGINT;
       varstr     * : POINTER TO ARRAY OF CHAR; (* This string is used by GraphWindow.ChangeDesign to display the "a=1.5; b=2" lines. *)
       color      * ,
       pattern    * ,
       thickness  * : INTEGER;
       calced     * : BOOLEAN;
(*       pcolor * : l.Node;
       pwidth * : INTEGER;*)

       oldcolor   * ,                        (* Used for Cancel-Button in requesters. *)
       oldpattern * ,
       oldthickness*: INTEGER;
     END;

PROCEDURE (funcgraph:FunctionGraph) Clear*;      (* Was SoftClearGraph *)

VAR i : INTEGER;

BEGIN
  FOR i:=0 TO SHORT(LEN(funcgraph.table^)-1) DO
    funcgraph.table[i].real:=0;
    funcgraph.table[i].error:=0;
    funcgraph.table[i].updown:=0;
  END;
  funcgraph.calced:=FALSE;
END Clear;

PROCEDURE (funcgraph:FunctionGraph) InitValues*; (* Was ClearGraph *)

BEGIN
  funcgraph.Clear;
  funcgraph.color:=2;
  funcgraph.pattern:=0;
  funcgraph.thickness:=1;
END InitValues;

PROCEDURE (funcgraph:FunctionGraph) InitGraph*(stutz:LONGINT);

BEGIN
  IF funcgraph.table#NIL THEN DISPOSE(funcgraph.table); END;
  NEW(funcgraph.table,stutz);
  funcgraph.InitValues;
  funcgraph.stutz:=stutz;
END InitGraph;

PROCEDURE (funcgraph:FunctionGraph) Init*;

BEGIN
  funcgraph.table:=NIL;
  funcgraph.bordervals:=l.Create();
  funcgraph.varstr:=NIL;
  funcgraph.InitGraph(640);
END Init;

PROCEDURE (funcgraph:FunctionGraph) Destruct*;

BEGIN
  DISPOSE(funcgraph.table);
  funcgraph.bordervals.Destruct;
  funcgraph.Destruct^;
END Destruct;

PROCEDURE (funcgraph:FunctionGraph) Backup*;

BEGIN
  funcgraph.oldcolor:=funcgraph.color;
  funcgraph.oldpattern:=funcgraph.pattern;
  funcgraph.oldthickness:=funcgraph.thickness;
END Backup;

PROCEDURE (funcgraph:FunctionGraph) Restore*;

BEGIN
  funcgraph.color:=funcgraph.oldcolor;
  funcgraph.pattern:=funcgraph.oldpattern;
  funcgraph.thickness:=funcgraph.oldthickness;
END Restore;

PROCEDURE * PrintFunctionGraph*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=datalist.GetNode(num);
  IF node#NIL THEN
    WITH node: FunctionGraph DO
      NEW(str);
      COPY(node.varstr^,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintFunctionGraph;



PROCEDURE (funcgraph:FunctionGraph) CalcTable*(func:t.Function;coords:c.CoordSystem;statusbox:gme.StatusBar);

VAR x,xx,dx,dy : LONGREAL;
    ci,error   : INTEGER;

BEGIN
  WITH coords: c.CartesianSystem DO
    xx:=ABS(coords.xmin)+ABS(coords.xmax);
    xx:=xx/funcgraph.stutz;
    x:=coords.xmin-xx;
    ci:=-1;
    dx:=ABS(coords.xmin)+ABS(coords.xmax);
    WHILE ci<(funcgraph.stutz-1) DO
      INC(ci);
      IF statusbox#NIL THEN
        statusbox.SetValue(SHORT(SHORT(100*LONG(ci)/(funcgraph.stutz-1))));
      END;
      x:=x+xx;
      error:=0;
      funcgraph.table[ci].real:=func.GetFunctionValue(x,xx,error);
      funcgraph.table[ci].error:=error;
    END;
  ELSE END;
END CalcTable;

PROCEDURE GetNextValue(VAR r:REAL);

BEGIN
  IF r>0.1 THEN r:=0.1;
  ELSIF r>0.01 THEN r:=0.01;
  ELSIF r>0.001 THEN r:=0.001;
  ELSIF r>0.0001 THEN r:=0.0001;
  ELSIF r>0.00001 THEN r:=0.00001;
  ELSIF r>0.000001 THEN r:=0.000001;
(*  ELSIF r>0.0000001 THEN r:=0.0000001;
  ELSIF r>0.00000001 THEN r:=0.00000001;*)
  END;
END GetNextValue;

PROCEDURE FindLuck(real,add:REAL;func:t.Function):REAL;

VAR error : INTEGER;
    wert  : LONGREAL;
    term  : l.Node;
    root  : fb.Node;

BEGIN
  term:=func.GetFunctionTerm(real);
  IF term#NIL THEN
    root:=term(t.Term).tree;
    real:=real-add;
    REPEAT
      GetNextValue(add);
      LOOP
        real:=real+add;
        error:=0;
        wert:=func.GetFunctionValueShort(real,add,error);
(*        wert:=f.Calc(root,real,add,error);*)
        IF error#0 THEN
          EXIT;
        END;
      END;
      IF add>0.00001 THEN
        real:=real-add;
        real:=real-add;
      END;
    UNTIL add<=0.00001;
  END;
  RETURN real;
END FindLuck;

PROCEDURE FindLuckRight(real,add:REAL;func:t.Function):REAL;

VAR error : INTEGER;
    wert  : LONGREAL;
    term  : l.Node;
    root  : fb.Node;

BEGIN
  term:=func.GetFunctionTerm(real);
  IF term#NIL THEN
    root:=term(t.Term).tree;
    real:=real+add;
    REPEAT
      GetNextValue(add);
      LOOP
        real:=real-add;
        error:=0;
        wert:=func.GetFunctionValueShort(real,add,error);
(*        wert:=f.Calc(root,real,-add,error);*)
        IF error#0 THEN
          EXIT;
        END;
      END;
      IF add>0.00001 THEN
        real:=real+add;
        real:=real+add;
      END;
    UNTIL add<=0.00001;
  END;
  RETURN real;
END FindLuckRight;

PROCEDURE (funcgraph:FunctionGraph) Plot*(rast:g.RastPortPtr;coord:c.CoordSystem;rect:c.Rectangle;conv:dc.ConversionTable;window:w.Window;func:t.Function;calc,checksize:BOOLEAN):BOOLEAN;

(* Sorry, but it needs to use the Module Window to check if the window was
   changed during the plot. *)

VAR root        : fb.Node;
    linex,liney : INTEGER;    (* Width of line in x and y direction *)
    fatline     : BOOLEAN;    (* Set to TRUE when line thickness is >1 (speeds up output). *)
    pos,
    len,i      : INTEGER;
    x,y,addx,
    x2,y2,savex,
    lastx,lasty: LONGREAL;
    real,real2 : LONGREAL;
    error,
    updown,
    lasterror,
    lefterror,
    righterror : INTEGER;
    picx,picy  : INTEGER;
    left,right : LONGREAL;
    notdraw,
    movenext,
    move,
    isup,isdown,
    nextisup,
    nextisdown : BOOLEAN;
    distx,disty,
    factx,facty,
    wx,wy      : LONGREAL;
    term,
    actbord    : l.Node;
    changed,
    doborder,
    doright,
    nextnotcalc: BOOLEAN;

BEGIN
  changed:=FALSE;
  WITH coord: c.CartesianSystem DO
    WITH func: t.Function DO
      g.SetAPen(rast,conv.GetColor(funcgraph.color,dc.standardType));
      gt.SetLinePattern(rast,go.lines[funcgraph.pattern]);
      linex:=conv.GetThicknessX(funcgraph.thickness);
      liney:=conv.GetThicknessY(funcgraph.thickness);
      IF (linex>1) OR (liney>1) OR (go.lines[funcgraph.pattern](gt.Line).width<16) THEN
        fatline:=TRUE;
        gt.SetLineAttrs(rast,linex,liney,go.lines[funcgraph.pattern]);
      ELSE
        fatline:=FALSE;
      END;

(* I hope it won't cause any problems when not re-creating every tree at the
   beginning. *)

(*      IF calc THEN
        func.CreateAllTrees;
      END;*)

      distx:=coord.xmax-coord.xmin;
      disty:=coord.ymax-coord.ymin;

      movenext:=FALSE;
      addx:=distx/(funcgraph.stutz-1);
      x:=coord.xmin-addx;
      actbord:=funcgraph.bordervals.head;
      WHILE (actbord#NIL) AND (actbord(BorderVal).x<x) DO
        actbord:=actbord.next;
      END;
      doborder:=FALSE;
      isup:=FALSE;
      isdown:=FALSE;
      nextnotcalc:=FALSE;
      i:=-1;
      WHILE i<funcgraph.stutz-1 DO
        INC(i);
        IF (actbord#NIL) AND (x<=actbord(BorderVal).x) AND (actbord(BorderVal).x<x+addx) THEN
          savex:=x;
          x:=actbord(BorderVal).x;
          doborder:=TRUE;
          DEC(i);
        ELSE
          x:=x+addx;
        END;
        IF (calc) AND NOT(doborder) AND NOT(nextnotcalc) THEN
          funcgraph.table[i].real:=func.GetFunctionValueShort(SHORT(x),SHORT(addx),funcgraph.table[i].error);
          IF (i>0) AND (funcgraph.table[i].error=0) AND (funcgraph.table[i-1].error=3) THEN
            funcgraph.table[i].real:=func.GetFunctionValueShort(SHORT(x),0,error);
            x2:=FindLuckRight(SHORT(x),SHORT(addx),func);
            actbord:=NIL;
            NEW(actbord(BorderVal));
            actbord(BorderVal).x:=x2;
            actbord(BorderVal).left:=func.GetFunctionValueShort(SHORT(x2-0.00001),0,lefterror);
            actbord(BorderVal).right:=func.GetFunctionValueShort(SHORT(x2+0.00001),0,righterror);
            funcgraph.bordervals.AddTail(actbord);
            x:=x-addx;
            DEC(i);
            nextnotcalc:=TRUE;
(*            savex:=x;
            x:=actbord(BorderVal).x;
            doborder:=TRUE;*)
          ELSIF ((funcgraph.table[i].error>0) AND (funcgraph.table[i].error#3)) OR ((i>0) AND (funcgraph.table[i].error=3) AND (funcgraph.table[i-1].error=0)) THEN
            funcgraph.table[i].real:=func.GetFunctionValueShort(SHORT(x),0,error);
            IF funcgraph.table[i].error=3 THEN
              x2:=x-addx;
            ELSE
              x2:=x;
            END;
            x2:=FindLuck(SHORT(x2),SHORT(addx),func);
            actbord:=NIL;
            NEW(actbord(BorderVal));
            actbord(BorderVal).x:=x2;
            actbord(BorderVal).left:=func.GetFunctionValueShort(SHORT(x2-0.00001),0,lefterror);
            actbord(BorderVal).right:=func.GetFunctionValueShort(SHORT(x2+0.00001),0,righterror);
            funcgraph.bordervals.AddTail(actbord);
            IF funcgraph.table[i].error=3 THEN
              x:=x-addx;
              DEC(i);
              nextnotcalc:=TRUE;
            END;
(*            savex:=x;
            x:=actbord(BorderVal).x;
            doborder:=TRUE;*)
          END;
        ELSIF (nextnotcalc) AND NOT(doborder) THEN
          nextnotcalc:=FALSE;
        END;

        wx:=x;
        wy:=funcgraph.table[i].real;
        IF (funcgraph.table[i].error=0) OR (funcgraph.table[i].error=2) OR (doborder) THEN
          doright:=FALSE;
          LOOP
            IF doborder THEN
              IF NOT(doright) THEN
                y:=actbord(BorderVal).left;
              ELSE
                y:=actbord(BorderVal).right;
              END;
            ELSE
              y:=funcgraph.table[i].real;
            END;
            IF (isup) OR (isdown) OR ((doborder) AND (doright)) THEN
              move:=TRUE;
            ELSE
              move:=FALSE;
            END;
            IF y<coord.ymin THEN
              IF NOT(isdown) THEN
                isdown:=TRUE;
                IF i>0 THEN
(*                  y2:=funcgraph.table[i-1].real;*)
                  wx:=x-(x-lastx)+((x-lastx)/(lasty-y)*(lasty-coord.ymin))-coord.xmin;
                  wy:=0;
                ELSE
                  wx:=x+addx-coord.ymin;
                  wy:=0;
                END;
              END;
              isup:=FALSE;
            ELSIF y>coord.ymax THEN
              IF NOT(isup) THEN
                isup:=TRUE;
                IF i>0 THEN
(*                  y2:=funcgraph.table[i-1].real;*)
                  wx:=x-(x-lastx)+((x-lastx)/(lasty-y)*(lasty-coord.ymax))-coord.xmin;
                  wy:=coord.ymax-coord.ymin;
                ELSE
                  wx:=x+addx-coord.xmin;
                  wy:=coord.ymax-coord.ymin;
                END;
              END;
              isdown:=FALSE;
            ELSE
              IF isdown THEN
                IF i>0 THEN
(*                  y2:=funcgraph.table[i-1].real;*)
                  wx:=x-(x-lastx)/(lasty-y)*(lasty-coord.ymin)-coord.xmin;
                  wy:=0;
                ELSE
                  wx:=x+addx-coord.xmin;
                  wy:=0;
                END;
              ELSIF isup THEN
                IF i>0 THEN
(*                  y2:=funcgraph.table[i-1].real;*)
                  wx:=x-(x-lastx)/(lasty-y)*(lasty-coord.ymax)-coord.xmin;
                  wy:=coord.ymax-coord.ymin;
                ELSE
                  wx:=x+addx-coord.xmin;
                  wy:=coord.ymax-coord.ymin;
                END;
              ELSE
                wx:=x-coord.xmin;
                wy:=y-coord.ymin;
              END;
              isdown:=FALSE;
              isup:=FALSE;
            END;
            IF i=0 THEN
              move:=TRUE;
            ELSIF (lasterror#0) AND NOT((lasterror=2) AND (doborder)) THEN
              move:=TRUE;
            END;
            coord.WorldToPic(rect,wx+coord.xmin,wy+coord.ymin,picx,picy);
(*            factx:=wx/distx;
            facty:=wy/disty;
            wx:=factx*rect.width;
            wy:=facty*rect.height;
            IF wx>=0 THEN
              picx:=SHORT(SHORT(SHORT(wx+0.5)));
            ELSE
              picx:=SHORT(SHORT(SHORT(wx-0.5)));
            END;
            IF wy>32000 THEN
              picy:=32000;
            ELSIF wy<-32000 THEN
              picy:=-32000;
            ELSE
              IF wy>=0 THEN
                picy:=SHORT(SHORT(SHORT(wy+0.5)));
              ELSE
                picy:=SHORT(SHORT(SHORT(wy-0.5)));
              END;
            END;
            picy:=rect.height-picy;
            INC(picx,rect.xoff);
            INC(picy,rect.yoff);*)

            IF move THEN
              IF fatline THEN
                gt.Move(rast,picx,picy);
              ELSE
                g.Move(rast,picx,picy);
              END;
            ELSE
              IF fatline THEN
                gt.Draw(rast,picx,picy);
              ELSE
                g.Draw(rast,picx,picy);
              END;
            END;
            lastx:=x;
            lasty:=y;

            IF NOT(doborder) OR (doright) THEN
              EXIT;
            END;
            doright:=TRUE;
          END;

          lasterror:=funcgraph.table[i].error;
          IF doborder THEN
            x:=savex;
            actbord:=actbord.next;
            doborder:=FALSE;
            lasterror:=0;
          END;

          IF i MOD 10=0 THEN
            changed:=window.CheckChanged(checksize);
            IF changed THEN
              i:=SHORT(funcgraph.stutz);
            END;
          END;
        ELSE
          lasterror:=funcgraph.table[i].error;
        END;

      END;
      IF (calc) AND NOT(changed) THEN
        funcgraph.calced:=TRUE;
      END;
      gt.SetFullPattern(rast);
      gt.FreeRastPortNode(rast);
    END;
  ELSE
    (* No known coordinate system. *)
  END;
  RETURN changed;
END Plot;

(*PROCEDURE PlotGraph*(p,func,sub:l.Node):BOOLEAN;

BEGIN
  g.SetAPen(p(s1.Fenster).wind.rPort,sub(s1.FunctionGraph).col);
  RETURN RawPlotGraph(p(s1.Fenster).wind.rPort,p,func(s1.FensterFunc).func,sub,p(s1.Fenster).inx,p(s1.Fenster).iny,p(s1.Fenster).width,p(s1.Fenster).height,sub(s1.FunctionGraph).width,sub(s1.FunctionGraph).width,FALSE,TRUE);
END PlotGraph;

PROCEDURE CalcGraph*(p,func,sub:l.Node):BOOLEAN;

BEGIN
  g.SetAPen(p(s1.Fenster).wind.rPort,sub(s1.FunctionGraph).col);
  RETURN RawPlotGraph(p(s1.Fenster).wind.rPort,p,func(s1.FensterFunc).func,sub,p(s1.Fenster).inx,p(s1.Fenster).iny,p(s1.Fenster).width,p(s1.Fenster).height,sub(s1.FunctionGraph).width,sub(s1.FunctionGraph).width,TRUE,TRUE);
END CalcGraph;*)

END FunctionGraph.

