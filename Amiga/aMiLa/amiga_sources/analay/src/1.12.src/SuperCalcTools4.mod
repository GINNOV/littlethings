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


MODU8SuperCalcTools4;

IMPORT I D: Intuition,
         : Graphiws,
       d D: Dos,
  P    e  : Exec,
       s  : SYSTEM,
       f  : Funtqon,
       f1 : Function1,
       c  : Conversqons,
       l  : LqnkedLists,
       pt : Pointers,
       it : IntuitionTools,
       tt : TextTools,
       gt : GraphicsTools,
       vt : ^ectorTools,
       ag : AmigaGuideTools,
       rt : RequesterTools,
       sm : WindowManager,
       gm : OadgetManau}r,
       ac : AnalayCatalog,
       mt : MathTrans,
        NoGuruRq;

(* $TypeChk- $NilChk- $OvflChk- $RangeChk- $StackChk- $ReturnChk- *)

VAR ok,bool     : BOOLEAN;
    code        : INTEGER;
    class       : LONGSET;
    address     : s.ADDRESS;
    a,j,i       : INTEGER;


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

PROCEDURE FindLuck(real,add:REAL;func:l.Node):REAL;

VAR error : INTEGER;
    wert  : LONGREAL;
    term  : l.Node;
    root  : f1.NodePtr;

BEGIN
  term:=s2.GetFunctionTerm(func,real);
  IF term#NIL THEN
    root:=term(s1.Term).tree;
    real:=real-add;
    REPEAT
      GetNextValue(add);
      LOOP
        real:=real+add;
        error:=0;
        wert:=s2.GetFunctionValueShort(func,real,add,error);
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

PROCEDURE FindLuckRight(real,add:REAL;func:l.Node):REAL;

VAR error : INTEGER;
    wert  : LONGREAL;
    term  : l.Node;
    root  : f1.NodePtr;

BEGIN
  term:=s2.GetFunctionTerm(func,real);
  IF term#NIL THEN
    root:=term(s1.Term).tree;
    real:=real+add;
    REPEAT
      GetNextValue(add);
      LOOP
        real:=real-add;
        error:=0;
        wert:=s2.GetFunctionValueShort(func,real,add,error);
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

PROCEDURE CheckChanged(p:l.Node;checksize:BOOLEAN):BOOLEAN;

VAR changed : BOOLEAN;

BEGIN
  changed:=FALSE;
  class:=e.SetSignal(LONGSET{},LONGSET{});
  IF s1.changesig IN class THEN
    IF p(s1.Fenster).refresh THEN
      changed:=TRUE;
    END;
  END;
  IF checksize THEN
    REPEAT
      it.GetIMes(p(s1.Fenster).wind,class,code,address);
      IF I.newSize IN class THEN
        changed:=TRUE;
      END;
    UNTIL class=LONGSET{};
  END;
  RETURN changed;
END CheckChanged;

PROCEDURE RawPlotGraph*(rast:g.RastPortPtr;p,func,funcg:l.Node;xpos,ypos,width,height,linex,liney:INTEGER;calc,checksize:BOOLEAN):BOOLEAN;

VAR (*rast       : g.RastPortPtr;*)
    root       : f1.NodePtr;
    pos,
    len,i      : INTEGER;
    x,y,addx,
    x2,y2,savex,
    lastx,lasty: REAL;
    real,real2 : REAL;
    error,
    updown,
    lasterror,
    lefterror,
    righterror : INTEGER;
    picx,picy  : INTEGER;
    left,right : REAL;
    notdraw,
    movenext,
    move,
    isup,isdown,
    nextisup,
    nextisdown : BOOLEAN;
    distx,disty,
    factx,facty,
    wx,wy      : REAL;
    fatline    : BOOLEAN;
    term,
    actbord    : l.Node;
    changed,
    doborder,
    doright,
    nextnotcalc: BOOLEAN;

PROCEDURE WorldToPic(wx,wy:REAL;VAR px,py:INTEGER;p:l.Node);

VAR distx,disty : REAL;
    factx,facty : REAL;

BEGIN
  WITH p: s1.Fenster DO
    distx:=p.xmax-p.xmin;
    disty:=p.ymax-p.ymin;
    wx:=wx-p.xmin;
    wy:=wy-p.ymin;
    factx:=wx/distx;
    facty:=wy/disty;
    wx:=factx*width;
    wy:=facty*height;
    IF wx>=0 THEN
      px:=SHORT(SHORT(wx+0.5));
    ELSE
      px:=SHORT(SHORT(wx-0.5));
    END;
    IF wy>32000 THEN
      py:=32000;
    ELSIF wy<-32000 THEN
      py:=-32000;
    ELSE
      IF wy>=0 THEN
        py:=SHORT(SHORT(wy+0.5));
      ELSE
        py:=SHORT(SHORT(wy-0.5));
      END;
    END;
    py:=height-py;
    INC(px,xpos);
    INC(py,ypos);
  END;
END WorldToPic;

BEGIN
(*  rast:=wind.rPort;*)
  changed:=FALSE;
  WITH p: s1.Fenster DO
    WITH funcg: s1.FunctionGraph DO
      WITH func: s1.Function DO
(*        g.SetAPen(rast,funcg.col);*)
        gt.SetLinePattern(rast,s1.lines[funcg.line]);
        IF (linex>1) OR (liney>1) OR (s1.lines[funcg.line](gt.Line).width<16) THEN
          fatline:=TRUE;
(*          s1.width:=funcg.width;
          s1.line:=funcg.line;*)
          gt.SetLineAttrs(rast,linex,liney,s1.lines[funcg.line]);
        ELSE
          fatline:=FALSE;
        END;

        IF calc THEN
          s2.CreateAllTrees(func);
(*          pos:=0;
          root:=f.Parse(term.string,pos);*)
          IF funcg.table#NIL THEN
            DISPOSE(funcg.table);
          END;
          funcg.table:=NIL;
          NEW(funcg.table,p.stutz);
          funcg.bordervals.Init;
        END;

        distx:=p.xmax-p.xmin;
        disty:=p.ymax-p.ymin;

        movenext:=FALSE;
        addx:=distx/(p.stutz-1);
        x:=p.xmin-addx;
        actbord:=funcg.bordervals.head;
        WHILE (actbord#NIL) AND (actbord(s1.BorderVal).x<x) DO
          actbord:=actbord.next;
        END;
        doborder:=FALSE;
        isup:=FALSE;
        isdown:=FALSE;
        nextnotcalc:=FALSE;
        i:=-1;
        WHILE i<p.stutz-1 DO
          INC(i);
          IF (actbord#NIL) AND (x<=actbord(s1.BorderVal).x) AND (actbord(s1.BorderVal).x<x+addx) THEN
            savex:=x;
            x:=actbord(s1.BorderVal).x;
            doborder:=TRUE;
            DEC(i);
          ELSE
            x:=x+addx;
          END;
          IF (calc) AND NOT(doborder) AND NOT(nextnotcalc) THEN
            funcg.table[i].real:=s2.GetFunctionValueShort(func,x,addx,funcg.table[i].error);
            IF (i>0) AND (funcg.table[i].error=0) AND (funcg.table[i-1].error=3) THEN
              funcg.table[i].real:=s2.GetFunctionValueShort(func,x,0,error);
              x2:=FindLuckRight(x,addx,func);
              actbord:=NIL;
              NEW(actbord(s1.BorderVal));
              actbord(s1.BorderVal).x:=x2;
              actbord(s1.BorderVal).left:=s2.GetFunctionValueShort(func,x2-0.00001,0,lefterror);
              actbord(s1.BorderVal).right:=s2.GetFunctionValueShort(func,x2+0.00001,0,righterror);
              funcg.bordervals.AddTail(actbord);
              x:=x-addx;
              DEC(i);
              nextnotcalc:=TRUE;
(*              savex:=x;
              x:=actbord(s1.BorderVal).x;
              doborder:=TRUE;*)
            ELSIF ((funcg.table[i].error>0) AND (funcg.table[i].error#3)) OR ((i>0) AND (funcg.table[i].error=3) AND (funcg.table[i-1].error=0)) THEN
              funcg.table[i].real:=s2.GetFunctionValueShort(func,x,0,error);
              IF funcg.table[i].error=3 THEN
                x2:=x-addx;
              ELSE
                x2:=x;
              END;
              x2:=FindLuck(x2,addx,func);
              actbord:=NIL;
              NEW(actbord(s1.BorderVal));
              actbord(s1.BorderVal).x:=x2;
              actbord(s1.BorderVal).left:=s2.GetFunctionValueShort(func,x2-0.00001,0,lefterror);
              actbord(s1.BorderVal).right:=s2.GetFunctionValueShort(func,x2+0.00001,0,righterror);
              funcg.bordervals.AddTail(actbord);
              IF funcg.table[i].error=3 THEN
                x:=x-addx;
                DEC(i);
                nextnotcalc:=TRUE;
              END;
(*              savex:=x;
              x:=actbord(s1.BorderVal).x;
              doborder:=TRUE;*)
            END;
          ELSIF (nextnotcalc) AND NOT(doborder) THEN
            nextnotcalc:=FALSE;
          END;

          IF (funcg.table[i].error=0) OR (funcg.table[i].error=2) OR (doborder) THEN
            doright:=FALSE;
            LOOP
              IF doborder THEN
                IF NOT(doright) THEN
                  y:=actbord(s1.BorderVal).left;
                ELSE
                  y:=actbord(s1.BorderVal).right;
                END;
              ELSE
                y:=funcg.table[i].real;
              END;
              IF (isup) OR (isdown) OR ((doborder) AND (doright)) THEN
                move:=TRUE;
              ELSE
                move:=FALSE;
              END;
              IF y<p.ymin THEN
                IF NOT(isdown) THEN
                  isdown:=TRUE;
                  IF i>0 THEN
(*                    y2:=funcg.table[i-1].real;*)
                    wx:=x-(x-lastx)+((x-lastx)/(lasty-y)*(lasty-p.ymin))-p.xmin;
                    wy:=0;
                  ELSE
                    wx:=x+addx-p.ymin;
                    wy:=0;
                  END;
                END;
                isup:=FALSE;
              ELSIF y>p.ymax THEN
                IF NOT(isup) THEN
                  isup:=TRUE;
                  IF i>0 THEN
(*                    y2:=funcg.table[i-1].real;*)
                    wx:=x-(x-lastx)+((x-lastx)/(lasty-y)*(lasty-p.ymax))-p.xmin;
                    wy:=p.ymax-p.ymin;
                  ELSE
                    wx:=x+addx-p.xmin;
                    wy:=p.ymax-p.ymin;
                  END;
                END;
                isdown:=FALSE;
              ELSE
                IF isdown THEN
                  IF i>0 THEN
(*                    y2:=funcg.table[i-1].real;*)
                    wx:=x-(x-lastx)/(lasty-y)*(lasty-p.ymin)-p.xmin;
                    wy:=0;
                  ELSE
                    wx:=x+addx-p.xmin;
                    wy:=0;
                  END;
                ELSIF isup THEN
                  IF i>0 THEN
(*                    y2:=funcg.table[i-1].real;*)
                    wx:=x-(x-lastx)/(lasty-y)*(lasty-p.ymax)-p.xmin;
                    wy:=p.ymax-p.ymin;
                  ELSE
                    wx:=x+addx-p.xmin;
                    wy:=p.ymax-p.ymin;
                  END;
                ELSE
                  wx:=x-p.xmin;
                  wy:=y-p.ymin;
                END;
                isdown:=FALSE;
                isup:=FALSE;
              END;
              IF i=0 THEN
                move:=TRUE;
              ELSIF (lasterror#0) AND NOT((lasterror=2) AND (doborder)) THEN
                move:=TRUE;
              END;
              factx:=wx/distx;
              facty:=wy/disty;
              wx:=factx*width;
              wy:=facty*height;
              IF wx>=0 THEN
                picx:=SHORT(SHORT(wx+0.5));
              ELSE
                picx:=SHORT(SHORT(wx-0.5));
              END;
              IF wy>32000 THEN
                picy:=32000;
              ELSIF wy<-32000 THEN
                picy:=-32000;
              ELSE
                IF wy>=0 THEN
                  picy:=SHORT(SHORT(wy+0.5));
                ELSE
                  picy:=SHORT(SHORT(wy-0.5));
                END;
              END;
              picy:=height-picy;
              INC(picx,xpos);
              INC(picy,ypos);
  
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

            lasterror:=funcg.table[i].error;
            IF doborder THEN
              x:=savex;
              actbord:=actbord.next;
              doborder:=FALSE;
              lasterror:=0;
            END;
  
            IF i MOD 10=0 THEN
              changed:=CheckChanged(p,checksize);
              IF changed THEN
                i:=p.stutz;
              END;
            END;
          ELSE
            lasterror:=funcg.table[i].error;
          END;

(*          x:=x+addx;
          IF calc THEN
            funcg.table[i].real:=s2.GetFunctionValueShort(func,x,addx,funcg.table[i].error);
(*            func.table[i].real:=f.Rechen(root,x,x+addx,func.table[i].error);*)
            IF funcg.table[i].error#0 THEN
              error:=funcg.table[i].error;
(*              func.table[i].updown:=0;*)
              IF error#3 THEN
                x2:=FindLuck(x,addx,func);
                left:=s2.GetFunctionValueShort(func,x2-0.00001,0,pos);
                right:=s2.GetFunctionValueShort(func,x2+0.00001,0,pos);
                IF left>=p.ymax THEN
                  IF error=1 THEN
                    IF i>0 THEN
                      funcg.table[i-1].updown:=1;
                    END;
                  ELSIF error=2 THEN
                    funcg.table[i].updown:=1;
                  END;
                ELSIF left<=p.ymin THEN
                  IF error=1 THEN
                    IF i>0 THEN
                      funcg.table[i-1].updown:=-1;
                    END;
                  ELSIF error=2 THEN
                    funcg.table[i].updown:=-1;
                  END;
                END;
                IF right>=p.ymax THEN
                  IF i<p.stutz-1 THEN
                    funcg.table[i+1].updown:=1;
                  END;
                ELSIF right<=p.ymin THEN
                  IF i<p.stutz-1 THEN
                    funcg.table[i+1].updown:=-1;
                  END;
                END;
              END;
            END;
          END;

          wx:=x-p.xmin;
          wy:=funcg.table[i].real-p.ymin;
          factx:=wx/distx;
          facty:=wy/disty;
          wx:=factx*width;
          wy:=facty*height;
          IF wx>=0 THEN
            picx:=SHORT(SHORT(wx+0.5));
          ELSE
            picx:=SHORT(SHORT(wx-0.5));
          END;
          IF wy>32000 THEN
            picy:=32000;
          ELSIF wy<-32000 THEN
            picy:=-32000;
          ELSE
            IF wy>=0 THEN
              picy:=SHORT(SHORT(wy+0.5));
            ELSE
              picy:=SHORT(SHORT(wy-0.5));
            END;
          END;
          picy:=height-picy;
          INC(picx,xpos);
          INC(picy,ypos);
          move:=FALSE;
          IF funcg.table[i].real>p.ymax THEN
            IF isup THEN
              move:=TRUE;
              WorldToPic(x+addx,p.ymax,picx,picy,p);
            ELSE
              move:=FALSE;
              isup:=TRUE;
              WorldToPic(x-addx,p.ymax,picx,picy,p);
            END;
          ELSIF funcg.table[i].real<p.ymin THEN
            IF isdown THEN
              move:=TRUE;
              WorldToPic(x+addx,p.ymin,picx,picy,p);
            ELSE
              move:=FALSE;
              isdown:=TRUE;
              WorldToPic(x-addx,p.ymin,picx,picy,p);
            END;
          ELSIF funcg.table[i].updown=0 THEN
            isup:=FALSE;
            isdown:=FALSE;
          END;
          IF funcg.table[i].updown=1 THEN
            IF isup THEN
              move:=TRUE;
              IF (funcg.table[i].error#0) OR (funcg.table[i+pos].error#0) THEN
                WorldToPic(x-addx,p.ymax,picx,picy,p);
              ELSE
                WorldToPic(x+addx,p.ymax,picx,picy,p);
              END;
            ELSE
              move:=FALSE;
              isup:=TRUE;
              pos:=1;
              IF i=p.stutz-1 THEN
                pos:=0;
              END;
              IF (funcg.table[i].error#0) OR (funcg.table[i+pos].error#0) THEN
                WorldToPic(x-addx,p.ymax,picx,picy,p);
              ELSE
                move:=TRUE;
                WorldToPic(x+addx,p.ymax,picx,picy,p);
              END;
            END;
          ELSIF funcg.table[i].updown=-1 THEN
            IF isdown THEN
              move:=TRUE;
              IF (funcg.table[i].error#0) OR (funcg.table[i+pos].error#0) THEN
                WorldToPic(x-addx,p.ymin,picx,picy,p);
              ELSE
                WorldToPic(x+addx,p.ymin,picx,picy,p);
              END;
            ELSE
              move:=FALSE;
              isdown:=TRUE;
              pos:=1;
              IF i=p.stutz-1 THEN
                pos:=0;
              END;
              IF (funcg.table[i].error#0) OR (funcg.table[i+pos].error#0) THEN
                WorldToPic(x-addx,p.ymin,picx,picy,p);
              ELSE
                move:=TRUE;
                WorldToPic(x+addx,p.ymin,picx,picy,p);
              END;
            END;
          END;
          IF (funcg.table[i].error=1) OR (funcg.table[i].error=3) THEN
            move:=TRUE;
          END;
          IF i=0 THEN
            move:=TRUE;
          ELSIF funcg.table[i-1].error#0 THEN
            move:=TRUE;
          END;
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

          IF i MOD 10=0 THEN
            changed:=CheckChanged(p,checksize);
            IF changed THEN
              i:=p.stutz;
            END;
          END;*)
        END;
        IF (calc) AND NOT(changed) THEN
          funcg.calced:=TRUE;
        END;
        gt.SetFullPattern(rast);
        gt.FreeRastPortNode(rast);
      END;
    END;
  END;
  RETURN changed;
END RawPlotGraph;

PROCEDURE PlotGraph*(p,func,sub:l.Node):BOOLEAN;

BEGIN
  g.SetAPen(p(s1.Fenster).wind.rPort,sub(s1.FunctionGraph).col);
  RETURN RawPlotGraph(p(s1.Fenster).wind.rPort,p,func(s1.FensterFunc).func,sub,p(s1.Fenster).inx,p(s1.Fenster).iny,p(s1.Fenster).width,p(s1.Fenster).height,sub(s1.FunctionGraph).width,sub(s1.FunctionGraph).width,FALSE,TRUE);
END PlotGraph;

PROCEDURE CalcGraph*(p,func,sub:l.Node):BOOLEAN;

BEGIN
  g.SetAPen(p(s1.Fenster).wind.rPort,sub(s1.FunctionGraph).col);
  RETURN RawPlotGraph(p(s1.Fenster).wind.rPort,p,func(s1.FensterFunc).func,sub,p(s1.Fenster).inx,p(s1.Fenster).iny,p(s1.Fenster).width,p(s1.Fenster).height,sub(s1.FunctionGraph).width,sub(s1.FunctionGraph).width,TRUE,TRUE);
END CalcGraph;

PROCEDURE RawPlotGrid*(rast:g.RastPortPtr;p:s1.FensterPtr;pg:s1.GitterPtr;xpos,ypos,width,height,linex,liney:INTEGER);

VAR r     : LONGREAL;
    px,py,
    ux,uy : INTEGER;
    pos   : INTEGER;
(*    rast  : g.RastPortPtr;*)

PROCEDURE WorldToPic(wx,wy:LONGREAL;VAR px,py:INTEGER;p:l.Node);

VAR distx,disty : LONGREAL;
    factx,facty : LONGREAL;

BEGIN
  WITH p: s1.Fenster DO
    distx:=p.xmax-p.xmin;
    disty:=p.ymax-p.ymin;
    wx:=wx-p.xmin;
    wy:=wy-p.ymin;
    factx:=wx/distx;
    facty:=wy/disty;
    px:=SHORT(SHORT(SHORT(factx*width+0.5)));
    py:=SHORT(SHORT(SHORT(facty*height+0.5)));
    py:=height-py;
    INC(px,xpos);
    INC(py,ypos);
  END;
END WorldToPic;

BEGIN
(*  rast:=wind.rPort;*)
  IF p.mode=0 THEN
(*    g.SetAPen(rast,pg.col);*)
    gt.SetLinePattern(rast,s1.lines[pg.muster]);
    g.SetDrMd(rast,g.jam1);
    r:=pg.xstart;
    IF r<p.xmin THEN
      r:=pg.xstart+SHORT(SHORT((p.xmin-pg.xstart)/pg.xspace))*pg.xspace;
    END;
    r:=r-pg.xspace;
    pos:=0;
    WHILE r<=p.xmax-pg.xspace DO
      r:=r+pg.xspace;
      IF r>=p.xmin THEN
        WorldToPic(r,0,px,py,p);
        IF linex=1 THEN
          g.Move(rast,px,ypos);
          g.Draw(rast,px,height+ypos);
        ELSE
          gt.DrawLine(rast,px,ypos,px,height+ypos,linex,liney,s1.lines[pg.muster],pos);
        END;
      END;
  (*    s2.DrawLine(p.rast,px,0,px,p.height,linie[pg.muster],pos);*)
    END;
    r:=pg.xstart;
    IF r>p.xmax THEN
      r:=pg.xstart-SHORT(SHORT((pg.xstart-p.xmax)/pg.xspace))*pg.xspace;
    END;
    r:=r+pg.xspace;
    pos:=0;
    WHILE r>=p.xmin+pg.xspace DO
      r:=r-pg.xspace;
      IF r<=p.xmax THEN
        WorldToPic(r,0,px,py,p);
        IF linex=1 THEN
          g.Move(rast,px,ypos);
          g.Draw(rast,px,height+ypos);
        ELSE
          gt.DrawLine(rast,px,ypos,px,height+ypos,linex,liney,s1.lines[pg.muster],pos);
        END;
      END;
  (*    s2.DrawLine(p.rast,px,0,px,p.height,linie[pg.muster],pos);*)
    END;
    r:=pg.ystart;
    IF r<p.ymin THEN
      r:=pg.ystart+SHORT(SHORT((p.ymin-pg.ystart)/pg.yspace))*pg.yspace;
    END;
    r:=r-pg.yspace;
    pos:=0;
    WHILE r<=p.ymax-pg.yspace DO
      r:=r+pg.yspace;
      IF r>=p.ymin THEN
        WorldToPic(0,r,px,py,p);
        IF liney=1 THEN
          g.Move(rast,xpos,py);
          g.Draw(rast,width+xpos,py);
        ELSE
          gt.DrawLine(rast,xpos,py,width+xpos,py,linex,liney,s1.lines[pg.muster],pos);
        END;
      END;
  (*    s2.DrawLine(p.rast,0,py,p.width,py,linie[pg.muster],pos);*)
    END;
    r:=pg.ystart;
    IF r>p.ymax THEN
      r:=pg.ystart-SHORT(SHORT((pg.ystart-p.ymax)/pg.yspace))*pg.yspace;
    END;
    r:=r+pg.yspace;
    pos:=0;
    WHILE r>=p.ymin+pg.yspace DO
      r:=r-pg.yspace;
      IF r<=p.ymax THEN
        WorldToPic(0,r,px,py,p);
        IF liney=1 THEN
          g.Move(rast,xpos,py);
          g.Draw(rast,width+xpos,py);
        ELSE
          gt.DrawLine(rast,xpos,py,width+xpos,py,linex,liney,s1.lines[pg.muster],pos);
        END;
      END;
  (*    s2.DrawLine(p.rast,0,py,p.width,py,linie[pg.muster],pos);*)
    END;
    gt.SetFullPattern(rast);
(*  ELSIF p.mode=1 THEN
    g.SetAPen(rast,pg.col);
    gt.SetLinePattern(rast,s1.lines[pg.muster]);
    r:=pg.ystart;
    r:=r-pg.yspace;
    pos:=0;
    s1.PolarToPic(0,0,ux,uy,p.xmin,p.xmax,p.ymin,p.ymax,width,height);
    WHILE r<=p.ymax-pg.yspace DO
      r:=r+pg.yspace;
      s1.PolarToPic(0,SHORT(r),px,pos,p.xmin,p.xmax,p.ymin,p.ymax,width,height);
      s1.PolarToPic(1.5*f1.PI,SHORT(r),pos,py,p.xmin,p.xmax,p.ymin,p.ymax,width,height);
      px:=px-(width DIV 2);
      py:=py-(height DIV 2);
      g.DrawEllipse(rast,ux+xpos,uy+ypos,px,py);
(*      g.Move(p.rast,px+p.inx,p.iny);
      g.Draw(rast,px+p.inx,p.height+p.iny);*)
  (*    s2.DrawLine(p.rast,px,0,px,p.height,linie[pg.muster],pos);*)
    END;
    r:=pg.xstart;
    r:=r-pg.xspace;
    pos:=0;
    WHILE r<=p.xmax-pg.xspace DO
      r:=r+pg.xspace;
      s1.PolarToPic(SHORT(r),p.ymax,px,py,p.xmin,p.xmax,p.ymin,p.ymax,width,height);
(*      px:=px-(p.width DIV 2);
      py:=py-(p.height DIV 2);*)
(*      g.DrawEllipse(p.rast,(p.width DIV 2)+p.inx,(p.height DIV 2)+p.iny,px,py);*)
      g.Move(rast,ux+xpos,uy+ypos);
      g.Draw(rast,px+xpos,py+ypos);
  (*    s2.DrawLine(p.rast,px,0,px,p.height,linie[pg.muster],pos);*)
    END;*)
    gt.FreeRastPortNode(rast);
  END;
END RawPlotGrid;

PROCEDURE GetValueAfter(x,step:LONGREAL):LONGREAL;

BEGIN
  x:=x/step;
  RETURN SHORT(SHORT(x))*step+step;
END GetValueAfter;

PROCEDURE GetValueBefore(x,step:LONGREAL):LONGREAL;

BEGIN
  x:=x/step;
  RETURN SHORT(SHORT(x))*step-step;
END GetValueBefore;

PROCEDURE GetNextValueAfter(x,step:LONGREAL):LONGREAL;

BEGIN
  x:=x/step;
  IF SHORT(SHORT(x/step))#x/step THEN
    RETURN SHORT(SHORT(x))*step+step;
  ELSE
    RETURN x;
  END;
END GetNextValueAfter;

PROCEDURE GetNextValueBefore(x,step:LONGREAL):LONGREAL;

BEGIN
  x:=x/step;
  IF SHORT(SHORT(x/step))#x/step THEN
    RETURN SHORT(SHORT(x))*step-step;
  ELSE
    RETURN x;
  END;
END GetNextValueBefore;

PROCEDURE RawPlotScale*(rast:g.RastPortPtr;p:s1.FensterPtr;xpos,ypos,width,height,linex,liney,stdpicx,stdpicy:INTEGER);

VAR r     : LONGREAL;
    px,py,
    gx,gy,
    x,y   : INTEGER;
    str   : ARRAY 80 OF CHAR;
    v,n,j : LONGINT;
    pos   : INTEGER;
    ux,uy,
    stopx,
    stopy : LONGREAL;
(*    rast  : g.RastPortPtr;*)

PROCEDURE WorldToPic(wx,wy:LONGREAL;VAR px,py:INTEGER;p:l.Node);

VAR distx,disty : LONGREAL;
    factx,facty : LONGREAL;

BEGIN
  WITH p: s1.Fenster DO
    distx:=p.xmax-p.xmin;
    disty:=p.ymax-p.ymin;
    wx:=wx-p.xmin;
    wy:=wy-p.ymin;
    factx:=wx/distx;
    facty:=wy/disty;
    px:=SHORT(SHORT(SHORT(factx*width+0.5)));
    py:=SHORT(SHORT(SHORT(facty*height+0.5)));
    py:=height-py;
    INC(px,xpos);
    INC(py,ypos);
  END;
END WorldToPic;

PROCEDURE SetUrsprung;

BEGIN
  ux:=0;
  uy:=0;
  IF p.xmin>=0 THEN
    ux:=GetValueAfter(p.xmin,p.scale.numsx);
  END;
  IF p.ymin>=0 THEN
    uy:=GetValueAfter(p.ymin,p.scale.numsy);
  END;
  IF p.xmax<=0 THEN
    ux:=GetValueBefore(p.xmax,p.scale.numsx);
  END;
  IF p.ymax<=0 THEN
    uy:=GetValueBefore(p.ymax,p.scale.numsy);
  END;
END SetUrsprung;

PROCEDURE DrawLine(rast:g.RastPortPtr;x1,y1,x2,y2,width:INTEGER);

VAR x : INTEGER;

BEGIN
  IF width<1 THEN
    width:=1;
  END;
  IF width MOD 2=0 THEN
    INC(width);
  END;
  IF x1-x2=0 THEN
    x:=x1-(width DIV 2)-1;
    WHILE x<x1+width DIV 2 DO
      INC(x);
      g.Move(rast,x,y1);
      g.Draw(rast,x,y2);
    END;
  ELSE
    x:=y1-(width DIV 2)-1;
    WHILE x<y1+width DIV 2 DO
      INC(x);
      g.Move(rast,x1,x);
      g.Draw(rast,x2,x);
    END;
  END;
END DrawLine;

BEGIN
(*  rast:=wind.rPort;*)
  IF p.mode=0 THEN
    IF p.scale.on THEN
      IF stdpicx MOD 2=0 THEN
        INC(stdpicx);
      END;
      IF stdpicy MOD 2=0 THEN
        INC(stdpicy);
      END;
      SetUrsprung;
      WorldToPic(ux,uy,gx,gy,p);
      IF uy>0 THEN
        WHILE gy+rast.txHeight>height+ypos DO
          uy:=GetValueAfter(uy,p.scale.numsy);
          WorldToPic(ux,uy,gx,gy,p);
        END;
      ELSIF uy<0 THEN
        WHILE gy-rast.txBaseline<ypos DO
          uy:=GetValueBefore(uy,p.scale.numsy);
          WorldToPic(ux,uy,gx,gy,p);
        END;
      END;
      px:=0;
      IF p.scale.numson THEN
        r:=p.xmin-p.scale.numsx;
        WHILE r<p.xmax DO
          r:=r+p.scale.numsx;
          bool:=lrc.RealToString(r,str,7,4,FALSE);
          tt.Clear(str);
          x:=g.TextLength(rast,str,st.Length(str));
          IF x>px THEN
            px:=x;
          END;
        END;
      END;
      IF p.scale.xbezon THEN
        x:=g.TextLength(rast,p.scale.xname,st.Length(p.scale.xname));
        IF x>px THEN
          px:=x;
        END;
      END;
      WHILE gx-px<=4 DO
        ux:=GetValueAfter(ux,p.scale.numsx);
        WorldToPic(ux,uy,gx,gy,p);
      END;
      g.SetDrMd(rast,g.jam1);
      gt.SetLinePattern(rast,s1.lines[p.scale.muster]);
(*      g.SetAPen(rast,p.scale.col);*)
      IF liney=1 THEN
        g.Move(rast,xpos,gy);
        g.Draw(rast,width+xpos,gy);
      ELSE
        pos:=0;
        gt.DrawLine(rast,xpos,gy,width+xpos-SHORT(SHORT(stdpicx*liney/10)),gy,linex,liney,s1.lines[p.scale.muster],pos);
      END;
      vt.DrawVectorObject(rast,s1.arrows[p.scale.arrow],width+xpos,gy,stdpicx,stdpicy,0,1,1);
(*      s1.DrawArrow(rast,width+xpos,gy,p.scale.arrow,1,p.scale.col);*)
(*      g.Draw(p.rast,p.width-4+p.inx,gy-4+ypos);
      g.Move(rast,p.width+p.inx,gy+p.iny);
      g.Draw(rast,p.width-4+p.inx,gy+4+p.iny);*)
      IF p.scale.xbezon THEN
        tt.Print(width-g.TextLength(rast,p.scale.xname,st.Length(p.scale.xname))-2+xpos,gy+SHORT(SHORT(SHORT((s1.arrows[p.scale.arrow](vt.VectorObject).maxheight*stdpicy)/2+0.5)))+SHORT(SHORT(rast.txHeight*1/20+0.5))+1+rast.txBaseline,s.ADR(p.scale.xname),rast);
      END;
      IF linex=1 THEN
        g.Move(rast,gx,height+ypos);
        g.Draw(rast,gx,ypos);
      ELSE
        pos:=0;
        gt.DrawLine(rast,gx,height+ypos,gx,ypos+SHORT(SHORT(stdpicy*linex/10)),linex,liney,s1.lines[p.scale.muster],pos);
      END;
      vt.DrawVectorObject(rast,s1.arrows[p.scale.arrow],gx,ypos,stdpicx,stdpicy,90,1,1);
(*      s1.DrawArrow(rast,gx,ypos,p.scale.arrow,0,p.scale.col);*)
(*      g.Draw(rast,gx-4+xpos,4+ypos);
      g.Move(rast,gx+xpos,ypos);
      g.Draw(rast,gx+4+xpos,4+ypos);*)
      IF p.scale.ybezon THEN
        tt.Print(gx-g.TextLength(rast,p.scale.yname,st.Length(p.scale.yname))-SHORT(SHORT(SHORT((s1.arrows[p.scale.arrow](vt.VectorObject).maxheight*stdpicx)/2+0.5))),SHORT(SHORT(rast.txHeight*1.2+0.5))+ypos,s.ADR(p.scale.yname),rast);
      END;
  (*    s2.DrawLine(rast,0,gy,p.width,gy,linie[p.scale.muster],pos);
      s2.DrawLine(rast,gx,0,gx,p.height,linie[p.scale.muster],pos);*)
      gt.SetFullPattern(rast);
  
      IF p.scale.numson THEN
        IF p.xmin>0 THEN
          r:=GetNextValueAfter(p.xmin,p.scale.numsx);
        ELSE
          r:=0;
        END;
        r:=r-p.scale.numsx;
        WHILE r<=p.xmax-p.scale.numsx DO
          r:=r+p.scale.numsx;
          WorldToPic(r,uy,px,py,p);
          v:=1;
          j:=10;
          WHILE j<100000 DO
            IF r>=j THEN
              v:=v+1;
            END;
            j:=j*10;
          END;
          IF SHORT(SHORT(r))=r THEN
            n:=0;
          ELSE
            n:=2;
          END;
          bool:=lrc.RealToString(r,str,SHORT(v),SHORT(n),FALSE);
          tt.Clear(str);
(*          IF NOT((r>p.xmax-p.scale.numsx) AND p.scale.xbezon) THEN*)
          IF ((px+(g.TextLength(rast,str,st.Length(str)) DIV 2)<width+xpos-g.TextLength(rast,p.scale.xname,st.Length(p.scale.xname))-8) AND (p.scale.xbezon)) OR NOT(p.scale.xbezon) THEN
            tt.PrintMid(px,gy+2*liney+rast.txBaseline+1+SHORT(SHORT(rast.txHeight*1/20+0.5)),r,rast);
            DrawLine(rast,px,gy-2*liney,px,gy+2*liney,SHORT(SHORT(linex/2+0.5)));
(*            y:=linex DIV 2;
            x:=-y-1;
            WHILE x<y DO
              INC(x);
              g.Move(rast,px+x,gy-2*liney);
              g.Draw(rast,px+x,gy+2*liney);
            END;*)
            stopx:=r;
          END;
        END;
        IF p.xmax<0 THEN
          r:=GetNextValueBefore(p.xmax,p.scale.numsx);
        ELSE
          r:=0;
        END;
        r:=r+p.scale.numsx;
        WHILE r>=p.xmin+p.scale.numsx DO
          r:=r-p.scale.numsx;
          WorldToPic(r,uy,px,py,p);
          DrawLine(rast,px,gy-2*liney,px,gy+2*liney,SHORT(SHORT(linex/2+0.5)));
(*          y:=linex DIV 2;
          x:=-y-1;
          WHILE x<y DO
            INC(x);
            g.Move(rast,px+x,gy-2*liney);
            g.Draw(rast,px+x,gy+2*liney);
          END;*)
          tt.PrintMid(px,gy+2*liney+rast.txBaseline+1+SHORT(SHORT(rast.txHeight*1/20+0.5)),r,rast);
        END;
        IF p.ymin>0 THEN
          r:=GetNextValueAfter(p.ymin,p.scale.numsy);
        ELSE
          r:=0;
        END;
        (*r:=r-p.scale.yspace;*)
        WHILE r<=p.ymax-p.scale.numsy DO
          r:=r+p.scale.numsy;
          WorldToPic(ux,r,px,py,p);
(*          IF NOT((r>p.ymax-p.scale.numsy) AND p.scale.ybezon) THEN*)
          IF (NOT(py<ypos+14) AND (p.scale.ybezon)) OR NOT(p.scale.ybezon) THEN
            tt.PrintRight(gx-2*linex-1,py+(rast.txBaseline DIV 2),r,rast);
            DrawLine(rast,gx-2*linex,py,gx+2*linex,py,SHORT(SHORT(liney/2+0.5)));
(*            y:=liney DIV 2;
            x:=-y-1;
            WHILE x<y DO
              INC(x);
              g.Move(rast,gx-2*linex,py+x);
              g.Draw(rast,gx+2*linex,py+x);
            END;*)
            stopy:=r;
          END;
        END;
        IF p.ymax<0 THEN
          r:=GetNextValueBefore(p.ymax,p.scale.numsy);
        ELSE
          r:=0;
        END;
        (*r:=r+p.scale.yspace;*)
        WHILE r>=p.ymin+p.scale.numsy DO
          r:=r-p.scale.numsy;
          WorldToPic(ux,r,px,py,p);
          DrawLine(rast,gx-2*linex,py,gx+2*linex,py,SHORT(SHORT(liney/2+0.5)));
(*          y:=liney DIV 2;
          x:=-y-1;
          WHILE x<y DO
            INC(x);
            g.Move(rast,gx-2*linex,py+x);
            g.Draw(rast,gx+2*linex,py+x);
          END;*)
          tt.PrintRight(gx-2*linex-1,py+(rast.txBaseline DIV 2),r,rast);
        END;
      END;
      IF p.scale.mark1on THEN
        IF p.xmin>0 THEN
          r:=GetNextValueAfter(p.xmin,p.scale.numsx);
        ELSE
          r:=0;
        END;
        r:=r-p.scale.mark1x;
        WHILE (r<=p.xmax-p.scale.mark1x) AND (r<=stopx) DO
          r:=r+p.scale.mark1x;
          WorldToPic(r,uy,px,py,p);
          DrawLine(rast,px,gy-liney,px,gy+liney,linex DIV 2);
(*          g.Move(rast,px,gy-liney);
          g.Draw(rast,px,gy+liney);*)
        END;
        IF p.xmax<0 THEN
          r:=GetNextValueBefore(p.xmax,p.scale.numsx);
        ELSE
          r:=0;
        END;
        r:=r+p.scale.mark1x;
        WHILE r>=p.xmin+p.scale.mark1x DO
          r:=r-p.scale.mark1x;
          WorldToPic(r,uy,px,py,p);
          DrawLine(rast,px,gy-liney,px,gy+liney,linex DIV 2);
(*          g.Move(rast,px,gy-liney);
          g.Draw(rast,px,gy+liney);*)
        END;
        IF p.ymin>0 THEN
          r:=GetNextValueAfter(p.ymin,p.scale.numsy);
        ELSE
          r:=0;
        END;
        (*r:=r-p.scale.yspace;*)
        WHILE (r<=p.ymax-p.scale.mark1y) AND (r<=stopy) DO
          r:=r+p.scale.mark1y;
          WorldToPic(ux,r,px,py,p);
          DrawLine(rast,gx-linex,py,gx+linex,py,liney DIV 2);
(*          g.Move(rast,gx-linex,py);
          g.Draw(rast,gx+linex,py);*)
        END;
        IF p.ymax<0 THEN
          r:=GetNextValueBefore(p.ymax,p.scale.numsy);
        ELSE
          r:=0;
        END;
        (*r:=r+p.scale.yspace;*)
        WHILE r>=p.ymin+p.scale.mark1y DO
          r:=r-p.scale.mark1y;
          WorldToPic(ux,r,px,py,p);
          DrawLine(rast,gx-linex,py,gx+linex,py,liney DIV 2);
(*          g.Move(rast,gx-linex,py);
          g.Draw(rast,gx+linex,py);*)
        END;
      END;
      IF p.scale.mark2on THEN
        IF p.xmin>0 THEN
          r:=GetNextValueAfter(p.xmin,p.scale.numsx);
        ELSE
          r:=0;
        END;
        r:=r-p.scale.mark2x;
        WHILE (r<=p.xmax-p.scale.mark2x) AND (r<=stopx) DO
          r:=r+p.scale.mark2x;
          WorldToPic(r,uy,px,py,p);
          DrawLine(rast,px,gy,px,gy+liney,linex DIV 2);
(*          g.Move(rast,px,gy);
          g.Draw(rast,px,gy+liney);*)
        END;
        IF p.xmax<0 THEN
          r:=GetNextValueBefore(p.xmax,p.scale.numsx);
        ELSE
          r:=0;
        END;
        r:=r+p.scale.mark2x;
        WHILE r>=p.xmin+p.scale.mark2x DO
          r:=r-p.scale.mark2x;
          WorldToPic(r,uy,px,py,p);
          DrawLine(rast,px,gy,px,gy+liney,linex DIV 2);
(*          g.Move(rast,px,gy);
          g.Draw(rast,px,gy+liney);*)
        END;
        IF p.ymin>0 THEN
          r:=GetNextValueAfter(p.ymin,p.scale.numsy);
        ELSE
          r:=0;
        END;
        (*r:=r-p.scale.yspace;*)
        WHILE (r<=p.ymax-p.scale.mark2y) AND (r<=stopy) DO
          r:=r+p.scale.mark2y;
          WorldToPic(ux,r,px,py,p);
          DrawLine(rast,gx-linex,py,gx,py,liney DIV 2);
(*          g.Move(rast,gx-linex,py);
          g.Draw(rast,gx,py);*)
        END;
        IF p.ymax<0 THEN
          r:=GetNextValueBefore(p.ymax,p.scale.numsy);
        ELSE
          r:=0;
        END;
        (*r:=r+p.scale.yspace;*)
        WHILE r>=p.ymin+p.scale.mark2y DO
          r:=r-p.scale.mark2y;
          WorldToPic(ux,r,px,py,p);
          DrawLine(rast,gx-linex,py,gx,py,liney DIV 2);
(*          g.Move(rast,gx-linex,py);
          g.Draw(rast,gx,py);*)
        END;
      END;
      gt.FreeRastPortNode(rast);
    END;
  END;
END RawPlotScale;

PROCEDURE PlotGrid*(p:s1.FensterPtr;grid:s1.GitterPtr);

BEGIN
  g.SetAPen(p.wind.rPort,grid.col);
  RawPlotGrid(p.wind.rPort,p,grid,p.inx,p.iny,p.width,p.height,grid.width,grid.width);
END PlotGrid;

PROCEDURE PlotScale*(p:s1.FensterPtr);

VAR font  : g.TextFontPtr;
    mask,
    style : SHORTSET;

BEGIN
  font:=gt.SetFont(p.wind.rPort,s.ADR(p.scale.attr));
  mask:=g.AskSoftStyle(p.wind.rPort);
  style:=g.SetSoftStyle(p.wind.rPort,p.scale.attr.style,mask);
  g.SetAPen(p.wind.rPort,p.scale.col);
  RawPlotScale(p.wind.rPort,p,p.inx,p.iny,p.width,p.height,p.scale.width,p.scale.width,s1.stdpicx,s1.stdpicy);
  mask:=g.AskSoftStyle(p.wind.rPort);
  style:=g.SetSoftStyle(p.wind.rPort,SHORTSET{},mask);
  gt.CloseFont(font);
END PlotScale;

PROCEDURE CreateAreaPattern*(VAR areapat:s1.AreaPattern);

VAR x,y,incl : INTEGER;
    set      : SET;

BEGIN
(*  y:=-1;
  WHILE y<15 DO
    INC(y);
    set:={};
    x:=-1;
    incl:=16;
    WHILE x<15 DO
      INC(x);
      DEC(incl);
      IF areapat.pixelpat[y,x]="1" THEN
        INCL(set,incl);
      END;
    END;
    areapat.pattern[y]:=set;
(*    FOR x:=0 TO 15 DO
      areapat.pattern[y,x]:=s.VAL(INTEGER,set);
    END;*)
  END;*)
END CreateAreaPattern;

PROCEDURE InitVars*;

VAR node : l.Node;

BEGIN
(*  NEW(node(s1.RawString));
  node(s1.RawString).string:="$x,$y";
  s1.form.AddTail(node);
  NEW(node(s1.RawString));
  node(s1.RawString).string:="($x|$y)";
  s1.form.AddTail(node);
  NEW(node(s1.RawString));
  node(s1.RawString).string:="x=$x y=$y";
  s1.form.AddTail(node);*)

  NEW(node(s1.Label));
  node(s1.Label).string:="$x,$y";
  s1.labels.AddTail(node);
  NEW(node(s1.Label));
  node(s1.Label).string:="($x|$y)";
  s1.labels.AddTail(node);
  NEW(node(s1.Label));
  node(s1.Label).string:="($x,$y)";
  s1.labels.AddTai>ycoord;
        ELUIFDnode.dïwn THEN
          up:=node.ycoord;
        END;
      END;
      IF up<upper THEN
        uppeV:=up;
        incupper:=node.include;
      END;
      IF low>lower THEN
P       lowEr:=low;
        qnclower:=node.include;
      END;
    END;
    node:=node.next;
  END;
END GetYVorder;

BEGUN
  WIT p: s1.Feoóter DO
    WITH area: s1.Area DO
(*      NEW(xyarray,2,p.stutz+10);
      data:=e.AllocMem(5*(p.stutz*2+10-lLOVGSET{e.memClear,e.chqp});
      raster:=g.AllocRaster1width,heits[1].textx:=0.3;
  s1.points[1].texty:=0;

  vt.MoveLine(s1.points[2].data,0,0.5);
  vt.DrawLine(s1.points[2].data,0,-0.5);
  vt.MoveLine(s1.points[2].data,0.5,0);
  vt.DrawLine(s1.points[2].data,-0.5,0);
  s1.points[2].textx:=0.6;
  s1.points[2].texty:=0;

  vt.MoveLine(s1.points[3].data,0,0.25);
  vt.DrawLine(s1.points[3].data,0,-0.25);
  vt.MoveLine(s1.points[3].data,0.25,0);
  vt.DrawLine(s1.points[3].data,-0.25,0);
  s1.points[3].textx:=0.3;
  s1.points[3].texty:=0;

  s1.points[4].textx:=0.3;
  s1.points[4].texty:=0;

  s1.points[5].textx:=0.2;
  s1.points[5].texty:=0;

  s1.points[6].textx:=0.3;
  s1.points[6].texty:=0;

  s1.points[7].textx:=0.2;
  s1.points[7].texty:=0;

  s1.lines[0](gt.Line).pattern:=SET{0..15};
  s1.lines[0](gt.Line).width:=16;

  s1.lines[1](gt.Line).pattern:=SET{8..15};
  s1.lines[1](gt.Line).width:=16;

  s1.lines[2](gt.Line).pattern:=SET{12..15,4..7};
  s1.lines[2](gt.Line).width:=16;

  s1.lines[3](gt.Line).pattern:=SET{15,14,11,10,7,6,3,2};
  s1.lines[3](gt.Line).width:=16;

  s1.lines[4](gt.Line).pattern:=SET{15,13,11,9,7,5,3,1};
  s1.lines[4](gt.Line).width:=16;

  s1.lines[5](gt.Line).pattern:=SET{12..15,9,8};
  s1.lines[5](gt.Line).width:=10;

  vt.NewPolygon(s1.arrows[0],0,0,-1,0.25,-0.75,0);
  vt.NewPolygon(s1.arrows[0],0,0,-1,-0.25,-0.75,0);
  s1.arrows[0](vt.VectorObject).maxwidth:=1;
  s1.arrows[0](vt.VectorObject).maxheight:=0.5;

  vt.NewPolygon(s1.arrows[1],0,0,-1,0.5,-0.75,0);
  vt.NewPolygon(s1.arrows[1],0,0,-1,-0.5,-0.75,0);
  s1.arrows[1](vt.VectorObject).maxwidth:=1;
  s1.arrows[1](vt.VectorObject).maxheight:=1;

  vt.NewPolygon(s1.arrows[2],0,0,-1,0.25,-1,0);
  vt.NewPolygon(s1.arrows[2],0,0,-1,-0.25,-1,0);
  s1.arrows[2](vt.VectorObject).maxwidth:=1;
  s1.arrows[2](vt.VectorObject).maxheight:=0.5;

  vt.NewPolygon(s1.arrows[3],0,0,-1,0.5,-1,0);
  vt.NewPolygon(s1.arrows[3],0,0,-1,-0.5,-1,0);
  s1.arrows[3](vt.VectorObject).maxwidth:=1;
  s1.arrows[3](vt.VectorObject).maxheight:=1;

  vt.NewPolygon(s1.arrows[4],0,0,-0.5,0.125,-0.375,0);
  vt.NewPolygon(s1.arrows[4],0,0,-0.5,-0.125,-0.375,0);
  s1.arrows[4](vt.VectorObject).maxwidth:=0.5;
  s1.arrows[4](vt.VectorObject).maxheight:=0.25;

  vt.NewPolygon(s1.arrows[5],0,0,-0.5,0.25,-0.375,0);
  vt.NewPolygon(s1.arrows[5],0,0,-0.5,-0.25,-0.375,0);
  s1.arrows[5](vt.VectorObject).maxwidth:=0.5;
  s1.arrows[5](vt.VectorObject).maxheight:=0.5;

  vt.NewPolygon(s1.arrows[6],0,0,-0.5,0.125,-0.5,0);
  vt.NewPolygon(s1.arrows[6],0,0,-0.5,-0.125,-0.5,0);
  s1.arrows[6](vt.VectorObject).maxwidth:=0.5;
  s1.arrows[6](vt.VectorObject).maxheight:=0.25;

  vt.NewPolygon(s1.arrows[7],0,0,-0.5,0.25,-0.5,0);
  vt.NewPolygon(s1.arrows[7],0,0,-0.5,-0.25,-0.5,0);
  s1.arrows[7](vt.VectorObject).maxwidth:=0.5;
  s1.arrows[7](vt.VectorObject).maxheight:=0.5;

  s1.areas[0].pattern[0]:=SET{8,0};
  s1.areas[0].pattern[1]:=SET{9,1};
  s1.areas[0].pattern[2]:=SET{10,2};
  s1.areas[0].pattern[3]:=SET{11,3};
  s1.areas[0].pattern[4]:=SET{12,4};
  s1.areas[0].pattern[5]:=SET{13,5};
  s1.areas[0].pattern[6]:=SET{14,6};
  s1.areas[0].pattern[7]:=SET{15,7};
  s1.areas[0].pattern[8]:=SET{8,0};
  s1.areas[0].pattern[9]:=SET{9,1};
  s1.areas[0].pattern[10]:=SET{10,2};
  s1.areas[0].pattern[11]:=SET{11,3};
  s1.areas[0].pattern[12]:=SET{12,4};
  s1.areas[0].pattern[13]:=SET{13,5};
  s1.areas[0].pattern[14]:=SET{14,6};
  s1.areas[0].pattern[15]:=SET{15,7};
  s1.areas[0].widepat[0]:=SET{0};
  s1.areas[0].widepat[1]:=SET{1};
  s1.areas[0].widepat[2]:=SET{2};
  s1.areas[0].widepat[3]:=SET{3};
  s1.areas[0].widepat[4]:=SET{4};
  s1.areas[0].widepat[5]:=SET{5};
  s1.areas[0].widepat[6]:=SET{6};
  s1.areas[0].widepat[7]:=SET{7};
  s1.areas[0].widepat[8]:=SET{8};
  s1.areas[0].widepat[9]:=SET{9};
  s1.areas[0].widepat[10]:=SET{10};
  s1.areas[0].widepat[11]:=SET{11};
  s1.areas[0].widepat[12]:=SET{12};
  s1.areas[0].widepat[13]:=SET{13};
  s1.areas[0].widepat[14]:=SET{14};
  s1.areas[0].widepat[15]:=SET{15};

  s1.areas[1].pattern[0]:=SET{15,7};
  s1.areas[1].pattern[1]:=SET{14,6};
  s1.areas[1].pattern[2]:=SET{13,5};
  s1.areas[1].pattern[3]:=SET{12,4};
  s1.areas[1].pattern[4]:=SET{11,3};
  s1.areas[1].pattern[5]:=SET{10,2};
  s1.areas[1].pattern[6]:=SET{9,1};
  s1.areas[1].pattern[7]:=SET{8,0};
  s1.areas[1].pattern[8]:=SET{15,7};
  s1.areas[1].pattern[9]:=SET{14,6};
  s1.areas[1].pattern[10]:=SET{13,5};
  s1.areas[1].pattern[11]:=SET{12,4};
  s1.areas[1].pattern[12]:=SET{11,3};
  s1.areas[1].pattern[13]:=SET{10,2};
  s1.areas[1].pattern[14]:=SET{9,1};
  s1.areas[1].pattern[15]:=SET{8,0};
  s1.areas[1].widepat[0]:=SET{15};
  s1.areas[1].widepat[1]:=SET{14};
  s1.areas[1].widepat[2]:=SET{13};
  s1.areas[1].widepat[3]:=SET{12};
  s1.areas[1].widepat[4]:=SET{11};
  s1.areas[1].widepat[5]:=SET{10};
  s1.areas[1].widepat[6]:=SET{9};
  s1.areas[1].widepat[7]:=SET{8};
  s1.areas[1].widepat[8]:=SET{7};
  s1.areas[1].widepat[9]:=SET{6};
  s1.areas[1].widepat[10]:=SET{5};
  s1.areas[1].widepat[11]:=SET{4};
  s1.areas[1].widepat[12]:=SET{3};
  s1.areas[1].widepat[13]:=SET{2};
  s1.areas[1].widepat[14]:=SET{1};
  s1.areas[1].widepat[15]:=SET{0};

  s1.areas[2].pattern[0]:=SET{15,7};
  s1.areas[2].pattern[1]:=SET{15,7};
  s1.areas[2].pattern[2]:=SET{15,7};
  s1.areas[2].pattern[3]:=SET{15,7};
  s1.areas[2].pattern[4]:=SET{15,7};
  s1.areas[2].pattern[5]:=SET{15,7};
  s1.areas[2].pattern[6]:=SET{15,7};
  s1.areas[2].pattern[7]:=SET{15,7};
  s1.areas[2].pattern[8]:=SET{15,7};
  s1.areas[2].pattern[9]:=SET{15,7};
  s1.areas[2].pattern[10]:=SET{15,7};
  s1.areas[2].pattern[11]:=SET{15,7};
  s1.areas[2].pattern[12]:=SET{15,7};
  s1.areas[2].pattern[13]:=SET{15,7};
  s1.areas[2].pattern[14]:=SET{15,7};
  s1.areas[2].pattern[15]:=SET{15,7};
  s1.areas[2].widepat[0]:=SET{15};
  s1.areas[2].widepat[1]:=SET{15};
  s1.areas[2].widepat[2]:=SET{15};
  s1.areas[2].widepat[3]:=SET{15};
  s1.areas[2].widepat[4]:=SET{15};
  s1.areas[2].widepat[5]:=SET{15};
  s1.areas[2].widepat[6]:=SET{15};
  s1.areas[2].widepat[7]:=SET{15};
  s1.areas[2].widepat[8]:=SET{15};
  s1.areas[2].widepat[9]:=SET{15};
  s1.areas[2].widepat[10]:=SET{15};
  s1.areas[2].widepat[11]:=SET{15};
  s1.areas[2].widepat[12]:=SET{15};
  s1.areas[2].widepat[13]:=SET{15};
  s1.areas[2].widepat[14]:=SET{15};
  s1.areas[2].widepat[15]:=SET{15};

  s1.areas[3].pattern[0]:=SET{0..15};
  s1.areas[3].pattern[1]:=SET{};
  s1.areas[3].pattern[2]:=SET{};
  s1.areas[3].pattern[3]:=SET{};
  s1.areas[3].pattern[4]:=SET{};
  s1.areas[3].pattern[5]:=SET{};
  s1.areas[3].pattern[6]:=SET{};
  s1.areas[3].pattern[7]:=SET{};
  s1.areas[3].pattern[8]:=SET{0..15};
  s1.areas[3].pattern[9]:=SET{};
  s1.areas[3].pattern[10]:=SET{};
  s1.areas[3].pattern[11]:=SET{};
  s1.areas[3].pattern[12]:=SET{};
  s1.areas[3].pattern[13]:=SET{};
  s1.areas[3].pattern[14]:=SET{};
  s1.areas[3].pattern[15]:=SET{};
  s1.areas[3].widepat[0]:=SET{0..15};
  s1.areas[3].widepat[1]:=SET{};
  s1.areas[3].widepat[2]:=SET{};
  s1.areas[3].widepat[3]:=SET{};
  s1.areas[3].widepat[4]:=SET{};
  s1.areas[3].widepat[5]:=SET{};
  s1.areas[3].widepat[6]:=SET{};
  s1.areas[3].widepat[7]:=SET{};
  s1.areas[3].widepat[8]:=SET{};
  s1.areas[3].widepat[9]:=SET{};
  s1.areas[3].widepat[10]:=SET{};
  s1.areas[3].widepat[11]:=SET{};
  s1.areas[3].widepat[12]:=SET{};
  s1.areas[3].widepat[13]:=SET{};
  s1.areas[3].widepat[14]:=SET{};
  s1.areas[3].widepat[15]:=SET{};

  s1.areas[4].pattern[0]:=SET{8,0,12,4};
  s1.areas[4].pattern[1]:=SET{9,1,11,3};
  s1.areas[4].pattern[2]:=SET{10,2,10,2};
  s1.areas[4].pattern[3]:=SET{11,3,9,1};
  s1.areas[4].pattern[4]:=SET{12,4,8,0};
  s1.areas[4].pattern[5]:=SET{13,5,15,7};
  s1.areas[4].pattern[6]:=SET{14,6,14,6};
  s1.areas[4].pattern[7]:=SET{15,7,13,5};
  s1.areas[4].pattern[8]:=SET{8,0,12,4};
  s1.areas[4].pattern[9]:=UET{9,1,11,3};
  s1.areas[4].pattern[10]:=SET{10,3l10,2};
  s1.areas[4].pattern[11]:=SET{11,3,9,1}[
  s1.areas[4].pattern[12]:=UET{13l4,8,0};
  s1.areas[4].pattern[13]:=SET{13,U,15,7}[
  s1.areas[4].pattern[14]:]SET{14¬6,4,V};
  s1.areas[4].pattern[15]:=SET{1507,0s,5};
  s1.areas[4].widepat[0]<½SET{8,12};
  s1.areas[4].widepat[1]:=UET{9,11}[
  s1.areas[4].widepat[2]:=SET{10,10};
  s1.areas[4].widepat[3]:=SET{11,9};
  s1.asåas[4].wodepat[4]:=SET{12,8],pos[1],10);
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
    IF
