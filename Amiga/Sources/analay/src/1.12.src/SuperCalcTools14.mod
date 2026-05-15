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


MODULE SuperCalcTools14;

IMPORT I  : Intuition,
       g  : Graphics,
       d  : Dos,
       e  : Exec,
       s  : SYSTEM,
       f  : Function,
       f1 : Function1,
       c  : Conversions,
       l  : LinkedLists,
       gm : GadgetManager,
       pt : Pointers,
       pr : Printer,
       es : ExecSupport,
       it : IntuitionTools,
       tt : TextTools,
       ag : AmigaGuideTools,
       wm : WindowManager,
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
       s13: SuperCalcTools13,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- *)

TYPE TextLine * = RECORD(l.NodeDesc)
       string  * : POINTER TO ARRAY OF CHAR;
       style   * : SHORTSET;
       color   * : INTEGER;
     END;

VAR ok,bool     : BOOLEAN;
    code        : INTEGER;
    class       : LONGSET;
    address     : s.ADDRESS;
    a,j,i       : INTEGER;
    ableitung,
    symmetrie,
    nullstellen,
    extrempunkte,
    wendepunkte : BOOLEAN;
    ableitanz,
    nullnach,
    extremnach,
    wendenach   : INTEGER;
    diskId    * ,
    discussId * ,
    discussoptId*: INTEGER;


(*PROCEDURE SetFunctionVariables*(func:l.Node):BOOLEAN;

BEGIN

END SetFunctionVariables;*)

PROCEDURE CalcTable(rast:g.RastPortPtr;p,func:l.Node;VAR table:s1.FuncTable);

VAR x,xx,sx,sy,
    dx,dy,fact : REAL;
    ci,error   : INTEGER;

BEGIN
  NEW(table,p(s1.Fenster).stutz);
  xx:=ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax);
  xx:=xx/p(s1.Fenster).stutz;
  x:=p(s1.Fenster).xmin-xx;
  ci:=-1;
  dx:=ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax);
  sx:=p(s1.Fenster).width/dx;
  fact:=160/LEN(table^);
  WHILE ci<(p(s1.Fenster).stutz-1) DO
    INC(ci);
    IF (rast#NIL) AND (16+(ci+1)*fact<176) THEN
      g.Move(rast,SHORT(SHORT(16+(ci+1)*fact)),23);
      g.Draw(rast,SHORT(SHORT(16+(ci+1)*fact)),44);
    END;
    x:=x+xx;
    error:=0;
    table[ci].real:=s2.GetFunctionValueShort(func,x,xx,error);
    table[ci].error:=error;
  END;
  IF rast#NIL THEN
    g.SetAPen(rast,0);
    g.RectFill(rast,16,23,175,44);
    g.SetAPen(rast,3);
  END;
END CalcTable;

PROCEDURE SetMinMax*(node1,node2:l.Node);

VAR pos,i : INTEGER;
    r     : LONGREAL;
    wind  : I.WindowPtr;
    rast  : g.RastPortPtr;
(*    bord  : I.BorderPtr;*)
(*    depth : ARRAY 5 OF I.Gadget;*)
    ca    : I.GadgetPtr;
(*    act,*)
    error : INTEGER;
(*    genau : REAL;*)
    num1  : INTEGER;
    ismin,
    ismax : BOOLEAN;
(*    root  : f1.NodePtr;
    fpos  : INTEGER;*)
(*    err   : s1.Error;*)
    node,
    sub,
    func  : l.Node;
    x,y   : LONGREAL;
    max,
    min   : LONGREAL;
    firstmax,
    firstmin : BOOLEAN;
    maxnode,
    minnode : l.Node;
    xmax  : REAL;
    str   : ARRAY 256 OF CHAR;
    table : s1.FuncTable;

BEGIN
 (* wind:=is.SetWindow(120,70,196,65,s.ADR("Suche Minimal/Maximal"),LONGSET{I.activate,I.windowDrag,I.windowDepth},
                     LONGSET{I.menuPick,I.rawKey,I.gadgetUp,I.gadgetDown,I.mouseButtons,I.mouseMove},s1.screen);
  IF wind#NIL THEN
    rast:=wind.rPort;
    g.SetAPen(rast,2);
    b.Print(18,25,s.ADR("Rechentiefe:"),rast);
    bord:=ig.SetPlastBorder(23,164);
    I.DrawBorder(rast,bord,16,17);
    act:=2;
    ig.SetPlastGadget(ok,wind,NIL,s.ADR("   OK   "),14,46,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetPlastGadget(ca,wind,NIL,s.ADR(" Cancel "),114,46,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetPlastGadget(depth[0],wind,NIL,s.ADR(" 1 "),20,28,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetPlastGadget(depth[1],wind,NIL,s.ADR(" 2 "),52,28,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetPlastGadget(depth[2],wind,NIL,s.ADR(" 3 "),84,28,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetPlastGadget(depth[3],wind,NIL,s.ADR(" 4 "),116,28,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetPlastGadget(depth[4],wind,NIL,s.ADR(" 5 "),148,28,
                      SET{I.gadgImmediate,I.relVerify});
    s1.ActivateBool(s.ADR(depth[act]),wind);
    genau:=1/ig.Hoch(10,act+1);
    s1.PrintLeft(114,25,genau,rast);

    LOOP
      e.WaitPort(wind.userPort);
      is.GetIMes(wind,class,code,address);
      IF I.gadgetUp IN class THEN
        IF address=s.ADR(ok) THEN
          EXIT;
        ELSE
          i:=-1;
          WHILE i<4 DO
            INC(i);
            IF address=s.ADR(depth[i]) THEN
              s1.DeActivateBool(s.ADR(depth[act]),wind);
              act:=i;
              s1.ActivateBool(s.ADR(depth[act]),wind);
              genau:=1/ig.Hoch(10,act+1);
              g.SetAPen(rast,0);
              g.RectFill(rast,114,17,180,25);
              g.SetAPen(rast,2);
              s1.PrintLeft(114,25,genau,rast);
            END;
          END;
        END;
      END;
    END;
    I.CloseWindow(wind);
  END;*)

  IF (node1#NIL) AND (node2#NIL) THEN
    s13.viewlist.Init;
    IF diskId=-1 THEN
      diskId:=wm.InitWindow(120,70,s13.barwi+32,70,s.ADR(""),LONGSET{I.activate,I.windowDrag,I.windowDepth},LONGSET{I.gadgetUp},s1.screen,FALSE);
    END;
    wm.SetDimensions(diskId,-1,-1,s13.barwi+32,70);
    gm.StartGadgets(s1.window);
    ca:=gm.SetBooleanGadget(14,49,s13.barwi+4,14,ac.GetString(ac.Cancel));
    gm.EndGadgets;
    wm.SetGadgets(diskId,ca);
    wm.ChangeTitle(diskId,ac.GetString(ac.FindExtremes));
    wm.ChangeScreen(diskId,s1.screen);
    wind:=wm.OpenWindow(diskId);
(*    wind:=is.SetWindow(120,70,194,70,s.ADR("Suche Extremalpunkte"),LONGSET{I.activate,I.windowDrag,I.windowDepth},
                       LONGSET{I.gadgetUp},s1.screen);*)
    IF wind#NIL THEN
      rast:=wind.rPort;
      s13.searchrast:=rast;
(*      ig.SetPlastHighGadget(ca,wind,s.ADR("Abbruch"),12,48,164,
                        SET{I.gadgImmediate,I.relVerify});*)
      g.SetAPen(rast,2);
      tt.Print(12,19,ac.GetString(ac.FindingMaximumPoints),rast);
      it.DrawBorder(rast,14,22,s13.barwi+4,24);
(*      bord:=ig.SetPlastBorder(20,160);
      I.DrawBorder(rast,bord,16,23);*)
      g.SetAPen(rast,3);
    END;
    s13.ResetSearch;
(*    fpos:=0;
    root:=f.Parse(node2(s1.FensterFunc).func.terms.head(s1.Term).string,fpos);
    f.Vereinfache(root);*)
    pos:=1;
    i:=-1;
    sub:=node2(s1.FensterFunc).graphs.head;
    func:=node2(s1.FensterFunc).func;
    node:=node1;
    IF NOT(func(s1.Function).depend.isEmpty()) THEN
      COPY(ac.GetString(ac.SetVariableValues)^,str);
      st.Append(str,": ");
      st.Append(str,func(s1.Function).name);
      node:=s2.SelectNode(func(s1.Function).depend,s.ADR(str),ac.GetString(ac.None),ac.GetString(ac.VariablesEx));

      IF node#NIL THEN
        CalcTable(rast,node1,func,table);
      END;
    ELSE
      table:=sub(s1.FunctionGraph).table;
    END;
    IF node#NIL THEN
      xmax:=node1(s1.Fenster).xmax;
      REPEAT
        r:=s13.SearchMax(node1,func,table,ismax,0.0000001);
        IF ismax THEN
          node:=NIL;
          NEW(node(s13.ListElement));
          WITH node: s13.ListElement DO
            node.xreal:=r;
            bool:=lrc.RealToString(r,node.xstring,6,6,FALSE);
            error:=0;
            y:=s2.GetFunctionValue(func,r,0.0001,error);
            node.yreal:=y;
            IF error=0 THEN
              bool:=lrc.RealToString(y,node.ystring,6,6,FALSE);
            ELSE
              COPY(ac.GetString(ac.Undefined)^,node.ystring);
            END;
            COPY(ac.GetString(ac.LocalMaximum)^,node.comment);
            node.marked:=FALSE;
          END;
          s13.viewlist.AddTail(node);
        END;
        it.GetIMes(wind,class,code,address);
        IF I.gadgetUp IN class THEN
          IF address=ca THEN
            pos:=-1;
            ismax:=FALSE;
            xmax:=SHORT(r);
          END;
        END;
      UNTIL NOT(ismax);
      IF pos#-1 THEN
        IF rast#NIL THEN
          g.SetAPen(rast,2);
          tt.Print(12,19,ac.GetString(ac.FindingMinimumPoints),rast);
          g.SetAPen(rast,0);
          g.RectFill(rast,16,23,s13.barwi+15,44);
          g.SetAPen(rast,3);
        END;
        s13.ResetSearch;
        num1:=i;
        pos:=1;
        i:=-1;
        REPEAT
          r:=s13.SearchMin(node1,func,table,ismin,0.0000001);
          IF ismin THEN
            node:=NIL;
            NEW(node(s13.ListElement));
            WITH node: s13.ListElement DO
              node.xreal:=r;
              bool:=lrc.RealToString(r,node.xstring,6,6,FALSE);
              error:=0;
              y:=s2.GetFunctionValue(func,r,0.0001,error);
              node.yreal:=y;
              IF error=0 THEN
                bool:=lrc.RealToString(y,node.ystring,6,6,FALSE);
              ELSE
                COPY(ac.GetString(ac.Undefined)^,node.ystring);
              END;
              COPY(ac.GetString(ac.LocalMinimum)^,node.comment);
              node.marked:=TRUE;
            END;
            s13.viewlist.AddTail(node);
          END;
          it.GetIMes(wind,class,code,address);
          IF I.gadgetUp IN class THEN
            IF address=ca THEN
              pos:=10000;
              ismin:=FALSE;
              xmax:=SHORT(r);
            END;
          END;
        UNTIL NOT(ismin);
      END;
  (*    QUICK(0,i);*)
      IF wind#NIL THEN
  (*      ig.FreePlastBorder(bord);
        ig.FreePlastHighBooleanGadget(ca,wind);*)
        wm.CloseWindow(diskId);
      END;
      wm.FreeGadgets(diskId);
      max:=0;
      min:=0;
      i:=0;
      WHILE i<LEN(table^) DO
        IF table[i].real>max THEN
          max:=table[i].real;
        END;
        IF table[i].real<min THEN
          min:=table[i].real;
        END;
        INC(i);
      END;
      firstmin:=TRUE;
      firstmax:=TRUE;
      maxnode:=NIL;
      minnode:=NIL;
      node:=s13.viewlist.head;
      WHILE node#NIL DO
        IF NOT(node(s13.ListElement).marked) THEN
          IF firstmax THEN
            firstmax:=FALSE;
            max:=node(s13.ListElement).yreal;
            maxnode:=node;
          ELSE
            IF node(s13.ListElement).yreal>max THEN
              max:=node(s13.ListElement).yreal;
              maxnode:=node;
            ELSIF (node(s13.ListElement).yreal>=max-0.00001) AND (node(s13.ListElement).yreal<=max+0.00001) THEN
              maxnode:=NIL;
            END;
          END;
        ELSE
          IF firstmin THEN
            firstmin:=FALSE;
            min:=node(s13.ListElement).yreal;
            minnode:=node;
          ELSE
            IF node(s13.ListElement).yreal<min THEN
              min:=node(s13.ListElement).yreal;
              minnode:=node;
            ELSIF (node(s13.ListElement).yreal>=min-0.00001) AND (node(s13.ListElement).yreal<=min+0.00001) THEN
              minnode:=NIL;
            END;
          END;
          node(s13.ListElement).marked:=FALSE;
        END;
        node:=node.next;
      END;
      i:=0;
      WHILE i<LEN(table^) DO
        IF table[i].real>max THEN
          max:=table[i].real;
          maxnode:=NIL;
        END;
        IF table[i].real<min THEN
          min:=table[i].real;
          minnode:=NIL;
        END;
        INC(i);
      END;
      IF maxnode#NIL THEN
        COPY(ac.GetString(ac.GlobalMaximumQ)^,maxnode(s13.ListElement).comment);
      END;
      IF minnode#NIL THEN
        COPY(ac.GetString(ac.GlobalMinimumQ)^,minnode(s13.ListElement).comment);
      END;
      s13.searchrast:=NIL;
      s13.numlist[0]:=num1+1;
      s13.numlist[1]:=i+1;
(*      s13.undertitle[0]:="Maxima";
      s13.undertitle[1]:="Minima";*)
      s13.Sort;
      i:=s13.ListSelect(ac.GetString(ac.ExtremePoints),node2(s1.FensterFunc).func(s1.Function).name,node1(s1.Fenster).xmin,xmax,node1,FALSE);
      IF NOT(func(s1.Function).depend.isEmpty()) THEN
        DISPOSE(table);
      END;
    ELSE
      IF wind#NIL THEN
        wm.CloseWindow(diskId);
      END;
      wm.FreeGadgets(diskId);
    END;
  END;
END SetMinMax;

PROCEDURE SetNull*(p,wfunc:l.Node);

VAR pos,i,
    ci    : INTEGER;
    r     : LONGREAL;
    wind  : I.WindowPtr;
    rast  : g.RastPortPtr;
    bord  : I.BorderPtr;
    depth : ARRAY 5 OF I.Gadget;
    ok,ca : I.GadgetPtr;
    act,
    error : INTEGER;
    genau : REAL;
    num1  : INTEGER;
    isnull: BOOLEAN;
    root  : f1.NodePtr;
    fpos  : INTEGER;
    err   : s1.Error;
    xmax  : REAL;
    node,
    sub,
    func  : l.Node;
    x,y,
    yl,yr : LONGREAL;
    str   : ARRAY 256 OF CHAR;
    table : s1.FuncTable;
    xx,
    sx,sy,
    dx,dy,
    fact  : REAL;

BEGIN
  IF (p#NIL) AND (wfunc#NIL) THEN
    s13.viewlist.Init;
    IF diskId=-1 THEN
      diskId:=wm.InitWindow(120,70,s13.barwi+32,70,s.ADR(""),LONGSET{I.activate,I.windowDrag,I.windowDepth},LONGSET{I.gadgetUp},s1.screen,FALSE);
    END;
    wm.SetDimensions(diskId,-1,-1,s13.barwi+32,70);
    gm.StartGadgets(s1.window);
    ca:=gm.SetBooleanGadget(14,49,s13.barwi+4,14,ac.GetString(ac.Cancel));
    gm.EndGadgets;
    wm.SetGadgets(diskId,ca);
    wm.ChangeTitle(diskId,ac.GetString(ac.FindZeros));
    wm.ChangeScreen(diskId,s1.screen);
    wind:=wm.OpenWindow(diskId);
(*    wind:=is.SetWindow(120,70,194,70,s.ADR("Suche Nullstellen"),LONGSET{I.activate,I.windowDrag,I.windowDepth},
                       LONGSET{I.gadgetUp},s1.screen);*)
    IF wind#NIL THEN
      rast:=wind.rPort;
      s13.searchrast:=rast;
(*      ig.SetPlastHighGadget(ca,wind,s.ADR("Abbruch"),12,48,164,
                        SET{I.gadgImmediate,I.relVerify});*)
      g.SetAPen(rast,2);
      tt.Print(12,19,ac.GetString(ac.FindingZeros),rast);
      it.DrawBorder(rast,14,22,s13.barwi+4,24);
(*      bord:=ig.SetPlastBorder(20,160);
      I.DrawBorder(rast,bord,16,23);*)
      g.SetAPen(rast,3);
    END;
    s13.ResetSearch;
(*    fpos:=0;
    root:=f.Parse(node2(s1.FensterFunc).func.terms.head(s1.Term).string,fpos);
    f.Vereinfache(root);*)
    sub:=wfunc(s1.FensterFunc).graphs.head;
    func:=wfunc(s1.FensterFunc).func;
    node:=p;
    IF NOT(func(s1.Function).depend.isEmpty()) THEN
      COPY(ac.GetString(ac.SetVariableValues)^,str);
      st.Append(str,": ");
      st.Append(str,func(s1.Function).name);
      node:=s2.SelectNode(func(s1.Function).depend,s.ADR(str),ac.GetString(ac.None),ac.GetString(ac.VariablesEx));

      IF node#NIL THEN
        CalcTable(rast,p,func,table);
      END;
    ELSE
      table:=sub(s1.FunctionGraph).table;
    END;
    IF node#NIL THEN
      pos:=1;
      i:=-1;
      xmax:=p(s1.Fenster).xmax;
      REPEAT
        r:=s13.SearchNull(p,func,table,isnull,0.0000001);
        IF isnull THEN
          node:=NIL;
          NEW(node(s13.ListElement));
          WITH node: s13.ListElement DO
            bool:=lrc.RealToString(r,node.xstring,6,6,FALSE);
            node.xreal:=r;
            error:=0;
            y:=s2.GetFunctionValue(func,r,0.0001,error);
            y:=0;
            IF error=0 THEN
              bool:=lrc.RealToString(y,node.ystring,6,6,FALSE);
            ELSE
              COPY(ac.GetString(ac.Undefined)^,node.ystring);
            END;
            yl:=s2.GetFunctionValue(func,r-0.0001,0.0001,error);
            yr:=s2.GetFunctionValue(func,r+0.0001,0.0001,error);
            IF (yl<0) AND (yr>0) THEN
              COPY(ac.GetString(ac.ChangeInSign)^,node.comment);
              st.Append(node.comment," -/+");
            ELSIF (yl>0) AND (yr<0) THEN
              COPY(ac.GetString(ac.ChangeInSign)^,node.comment);
              st.Append(node.comment," +/-");
            ELSE
              COPY(ac.GetString(ac.NoChangeInSign)^,node.comment);
            END;
            node.marked:=FALSE;
          END;
          s13.viewlist.AddTail(node);
        END;
        it.GetIMes(wind,class,code,address);
        IF I.gadgetUp IN class THEN
          IF address=ca THEN
            pos:=10000;
            xmax:=SHORT(r);
            isnull:=FALSE;
          END;
        END;
      UNTIL NOT(isnull);
  (*    QUICK(0,i);*)
      IF wind#NIL THEN
  (*      ig.FreePlastBorder(bord);
        ig.FreePlastHighBooleanGadget(ca,wind);*)
        wm.CloseWindow(diskId);
      END;
      wm.FreeGadgets(diskId);
      s13.searchrast:=NIL;
      s13.numlist[0]:=i+1;
(*      s13.undertitle[0]:="Nullstellen";*)
      i:=s13.ListSelect(ac.GetString(ac.Zeros),wfunc(s1.FensterFunc).func(s1.Function).name,p(s1.Fenster).xmin,xmax,p,FALSE);
      IF NOT(func(s1.Function).depend.isEmpty()) THEN
        DISPOSE(table);
      END;
    ELSE
      IF wind#NIL THEN
        wm.CloseWindow(diskId);
      END;
      wm.FreeGadgets(diskId);
    END;
  END;
END SetNull;

PROCEDURE SetLuck*(node1,node2:l.Node);

VAR pos,i,
    ci,error : INTEGER;
    r     : LONGREAL;
    wind  : I.WindowPtr;
    rast  : g.RastPortPtr;
    bord  : I.BorderPtr;
    depth : ARRAY 5 OF I.Gadget;
    ok,ca : I.GadgetPtr;
    act   : INTEGER;
    num1  : INTEGER;
    isnull: BOOLEAN;
    root  : f1.NodePtr;
    fpos  : INTEGER;
    err   : s1.Error;
    xmax  : REAL;
    node,
    sub,
    func  : l.Node;
    x,y   : LONGREAL;
    isone : BOOLEAN;
    str   : ARRAY 256 OF CHAR;
    table : s1.FuncTable;
    xx,
    sx,sy,
    dx,dy,
    fact  : REAL;

BEGIN
  IF (node1#NIL) AND (node2#NIL) THEN
    s13.viewlist.Init;
    IF diskId=-1 THEN
      diskId:=wm.InitWindow(120,70,s13.barwi+32,70,s.ADR(""),LONGSET{I.activate,I.windowDrag,I.windowDepth},LONGSET{I.gadgetUp},s1.screen,FALSE);
    END;
    wm.SetDimensions(diskId,-1,-1,s13.barwi+32,70);
    gm.StartGadgets(s1.window);
    ca:=gm.SetBooleanGadget(14,49,s13.barwi+4,14,ac.GetString(ac.Cancel));
    gm.EndGadgets;
    wm.SetGadgets(diskId,ca);
    wm.ChangeTitle(diskId,ac.GetString(ac.FindingGaps));
    wm.ChangeScreen(diskId,s1.screen);
    wind:=wm.OpenWindow(diskId);
(*    wind:=is.SetWindow(120,70,194,70,s.ADR("Suche Lücken"),LONGSET{I.activate,I.windowDrag,I.windowDepth},
                       LONGSET{I.gadgetUp},s1.screen);*)
    IF wind#NIL THEN
      rast:=wind.rPort;
      s13.searchrast:=rast;
(*      ig.SetPlastHighGadget(ca,wind,s.ADR("Abbruch"),12,48,164,
                        SET{I.gadgImmediate,I.relVerify});*)
      g.SetAPen(rast,2);
      tt.Print(12,19,ac.GetString(ac.FindingGaps),rast);
      it.DrawBorder(rast,14,22,s13.barwi+4,24);
(*      bord:=ig.SetPlastBorder(20,160);
      I.DrawBorder(rast,bord,16,23);*)
      g.SetAPen(rast,3);
    END;
    s13.ResetSearch;
(*    fpos:=0;
    root:=f.Parse(node2(s1.FensterFunc).func.terms.head(s1.Term).string,fpos);
    f.Vereinfache(root);*)
    sub:=node2(s1.FensterFunc).graphs.head;
    func:=node2(s1.FensterFunc).func;
    node:=node1;
    IF NOT(func(s1.Function).depend.isEmpty()) THEN
      COPY(ac.GetString(ac.SetVariableValues)^,str);
      st.Append(str,": ");
      st.Append(str,func(s1.Function).name);
      node:=s2.SelectNode(func(s1.Function).depend,s.ADR(str),ac.GetString(ac.None),ac.GetString(ac.VariablesEx));

      IF node#NIL THEN
        CalcTable(rast,node1,func,table);
      END;
    ELSE
      table:=sub(s1.FunctionGraph).table;
    END;
    IF node#NIL THEN
      pos:=1;
      i:=-1;
      xmax:=node1(s1.Fenster).xmax;
      REPEAT
        r:=s13.SearchLuck(node1,func,table,isone,0.0000001);
        IF isone THEN
          node:=NIL;
          NEW(node(s13.ListElement));
          WITH node: s13.ListElement DO
            bool:=lrc.RealToString(r,node.xstring,6,6,FALSE);
            node.xreal:=r;
            COPY(ac.GetString(ac.Undefined)^,node.ystring);
            node.comment:="";
            node.marked:=FALSE;
          END;
          s13.viewlist.AddTail(node);
  (*        INC(i);
          s11.xlist[0,i]:=r;
          s11.elist[0,i]:=TRUE;*)
        END;
        it.GetIMes(wind,class,code,address);
        IF I.gadgetUp IN class THEN
          IF address=ca THEN
            pos:=10000;
            xmax:=SHORT(r);
            isone:=FALSE;
          END;
        END;
      UNTIL NOT(isone);
  (*    QUICK(0,i);*)
      IF wind#NIL THEN
  (*      ig.FreePlastBorder(bord);
        ig.FreePlastHighBooleanGadget(ca,wind);*)
        wm.CloseWindow(diskId);
      END;
      wm.FreeGadgets(diskId);
      s13.searchrast:=NIL;
      s13.numlist[0]:=i+1;
(*      s13.undertitle[0]:="Definitionslücken";*)
      i:=s13.ListSelect(ac.GetString(ac.DefinitionGaps),node2(s1.FensterFunc).func(s1.Function).name,node1(s1.Fenster).xmin,xmax,node1,FALSE);
      IF NOT(func(s1.Function).depend.isEmpty()) THEN
        DISPOSE(table);
      END;
    ELSE
      IF wind#NIL THEN
        wm.CloseWindow(diskId);
      END;
      wm.FreeGadgets(diskId);
    END;
  END;
END SetLuck;

PROCEDURE SetWende*(node1,node2:l.Node);

VAR pos,i : INTEGER;
    r     : LONGREAL;
    wind  : I.WindowPtr;
    rast  : g.RastPortPtr;
    bord  : I.BorderPtr;
    depth : ARRAY 5 OF I.Gadget;
    ok,ca : I.GadgetPtr;
    act   : INTEGER;
    genau : REAL;
    num1  : INTEGER;
    isnull: BOOLEAN;
    node,
    sub,
    func,
    second: l.Node;
    fpos  : INTEGER;
    x,xx,
    sx,sy,
    dx,dy : REAL;
    ci,
    error : INTEGER;
    p     : s1.Funktion;
    xmax  : REAL;
    y     : LONGREAL;
    table : s1.FuncTable;
    fact  : REAL;
    left,
    right : LONGREAL;
    exit  : BOOLEAN;
    str   : ARRAY 256 OF CHAR;

BEGIN
  IF (node1#NIL) AND (node2#NIL) THEN
    s13.viewlist.Init;
    IF diskId=-1 THEN
      diskId:=wm.InitWindow(120,70,s13.barwi+32,70,s.ADR(""),LONGSET{I.activate,I.windowDrag,I.windowDepth},LONGSET{I.gadgetUp},s1.screen,FALSE);
    END;
    wm.SetDimensions(diskId,-1,-1,s13.barwi+32,70);
    gm.StartGadgets(s1.window);
    ca:=gm.SetBooleanGadget(14,49,s13.barwi+4,14,ac.GetString(ac.Cancel));
    gm.EndGadgets;
    wm.SetGadgets(diskId,ca);
    wm.ChangeTitle(diskId,ac.GetString(ac.FindingPointsOfInflection));
    wm.ChangeScreen(diskId,s1.screen);
    wind:=wm.OpenWindow(diskId);
(*    wind:=is.SetWindow(120,70,194,70,s.ADR("Suche Wendepunkte"),LONGSET{I.activate,I.windowDrag,I.windowDepth},
                       LONGSET{I.gadgetUp},s1.screen);*)
    IF wind#NIL THEN
      rast:=wind.rPort;
      s13.searchrast:=rast;
(*      ig.SetPlastHighGadget(ca,wind,s.ADR("Abbruch"),12,48,164,
                        SET{I.gadgImmediate,I.relVerify});*)
      g.SetAPen(rast,2);
      tt.Print(12,19,ac.GetString(ac.FindingPointsOfInflection),rast);
      it.DrawBorder(rast,14,22,s13.barwi+4,24);
(*      bord:=ig.SetPlastBorder(20,160);
      I.DrawBorder(rast,bord,16,23);*)
      g.SetAPen(rast,3);
    END;
    s13.ResetSearch;
(*    fpos:=0;
    root:=f.Parse(node2(s1.FensterFunc).func.terms.head(s1.Term).string,fpos);
    f.Vereinfache(root);
    second:=f2.CopyTree(root);
    f.Ableit(second,"X");
    f.Vereinfache(second);
    f.Ableit(second,"X");
    f.Vereinfache(second);*)
(*    third:=f2.CopyTree(second);
    f.Ableit(third);
    f.Vereinfache(third);*)
    sub:=node2(s1.FensterFunc).graphs.head;
    func:=node2(s1.FensterFunc).func;
    second:=s2.AbleitFunction(func,"x");
    second:=s2.AbleitFunction(second,"x");
    node:=node1;
    IF NOT(func(s1.Function).depend.isEmpty()) THEN
      COPY(ac.GetString(ac.SetVariableValues)^,str);
      st.Append(str,": ");
      st.Append(str,func(s1.Function).name);
      node:=s2.SelectNode(func(s1.Function).depend,s.ADR(str),ac.GetString(ac.None),ac.GetString(ac.VariablesEx));
    END;
    IF node#NIL THEN
      NEW(table,node1(s1.Fenster).stutz);
      xx:=ABS(node1(s1.Fenster).xmin)+ABS(node1(s1.Fenster).xmax);
      xx:=xx/node1(s1.Fenster).stutz;
      x:=node1(s1.Fenster).xmin-xx;
      ci:=-1;
      dx:=ABS(node1(s1.Fenster).xmin)+ABS(node1(s1.Fenster).xmax);
      sx:=node1(s1.Fenster).width/dx;
      fact:=s13.barwi/LEN(table^);
      WHILE ci<(node1(s1.Fenster).stutz-1) DO
        INC(ci);
        IF (rast#NIL) AND ((ci+1)*fact<s13.barwi) THEN
          g.Move(rast,SHORT(SHORT(16+(ci+1)*fact)),23);
          g.Draw(rast,SHORT(SHORT(16+(ci+1)*fact)),44);
        END;
        x:=x+xx;
        error:=0;
        table[ci].real:=s2.GetFunctionValueShort(second,x,xx,error);
        table[ci].error:=error;
      END;
      IF rast#NIL THEN
        g.SetAPen(rast,0);
        g.RectFill(rast,16,23,s13.barwi+15,44);
        g.SetAPen(rast,3);
      END;
      pos:=1;
      i:=-1;
      xmax:=node1(s1.Fenster).xmax;
      REPEAT
        r:=s13.SearchNull(node1,second,table,isnull,0.0000001);
        exit:=NOT(isnull);
  (*      x:=SHORT(r);*)
        left:=s2.GetFunctionValue(second,r-0.0001,xx,error);
        right:=s2.GetFunctionValue(second,r+0.0001,xx,error);
        IF ((left>0) AND (right>0)) OR ((left<0) AND (right<0)) OR ((left=0) AND (right=0)) THEN
          isnull:=FALSE;
        END;
        IF isnull THEN
          node:=NIL;
          NEW(node(s13.ListElement));
          WITH node: s13.ListElement DO
            bool:=lrc.RealToString(r,node.xstring,6,6,FALSE);
            node.xreal:=r;
            error:=0;
            y:=s2.GetFunctionValue(func,r,0.0001,error);
            IF error=0 THEN
              bool:=lrc.RealToString(y,node.ystring,6,6,FALSE);
            ELSE
              COPY(ac.GetString(ac.Undefined)^,node.ystring);
            END;
            node.comment:="";
            IF (left>0) AND (right<0) THEN
              COPY(ac.GetString(ac.CurvatureLeftRight)^,node.comment);
            ELSIF (left<0) AND (right>0) THEN
              COPY(ac.GetString(ac.CurvatureRightLeft)^,node.comment);
            END;
            node.marked:=FALSE;
          END;
          s13.viewlist.AddTail(node);
        END;
        it.GetIMes(wind,class,code,address);
        IF I.gadgetUp IN class THEN
          IF address=ca THEN
            pos:=10000;
            xmax:=SHORT(r);
            exit:=TRUE;
          END;
        END;
      UNTIL exit;
  (*    QUICK(0,i);*)
      IF wind#NIL THEN
  (*      ig.FreePlastBorder(bord);
        ig.FreePlastHighBooleanGadget(ca,wind);*)
        wm.CloseWindow(diskId);
      END;
      wm.FreeGadgets(diskId);
      IF table#NIL THEN
        DISPOSE(table);
      END;
      s13.searchrast:=NIL;
      s13.numlist[0]:=i+1;
(*      s13.undertitle[0]:="Wendepunkte";*)
      i:=s13.ListSelect(ac.GetString(ac.PointsOfInflection),node2(s1.FensterFunc).func(s1.Function).name,node1(s1.Fenster).xmin,xmax,node1,FALSE);
      DISPOSE(table);
    ELSE
      IF wind#NIL THEN
        wm.CloseWindow(diskId);
      END;
      wm.FreeGadgets(diskId);
    END;
  END;
END SetWende;

PROCEDURE SetSchnitt*(p,wfunc1,wfunc2:l.Node);

VAR pos,i : INTEGER;
    r     : LONGREAL;
    wind  : I.WindowPtr;
    rast  : g.RastPortPtr;
    bord  : I.BorderPtr;
    depth : ARRAY 5 OF I.Gadget;
    ok,ca : I.GadgetPtr;
    act,
    error : INTEGER;
    genau : REAL;
    num1  : INTEGER;
    isnull: BOOLEAN;
    root  : f1.NodePtr;
    fpos  : INTEGER;
    err   : s1.Error;
    xmax  : REAL;
    node,
    sub1,
    sub2,
    func1,
    func2 : l.Node;
    x,y,
    yl,yr : LONGREAL;
    table,
    table2,
    table3: s1.FuncTable;
    alloc,
    alloc2: BOOLEAN;
    str   : ARRAY 256 OF CHAR;

BEGIN
  IF (p#NIL) AND (wfunc1#NIL) AND (wfunc2#NIL) THEN
    s13.viewlist.Init;
    IF diskId=-1 THEN
      diskId:=wm.InitWindow(120,70,s13.barwi+32,70,s.ADR(""),LONGSET{I.activate,I.windowDrag,I.windowDepth},LONGSET{I.gadgetUp},s1.screen,FALSE);
    END;
    wm.SetDimensions(diskId,-1,-1,s13.barwi+32,70);
    gm.StartGadgets(s1.window);
    ca:=gm.SetBooleanGadget(14,49,s13.barwi+4,14,ac.GetString(ac.Cancel));
    gm.EndGadgets;
    wm.SetGadgets(diskId,ca);
    wm.ChangeTitle(diskId,ac.GetString(ac.FindingIntersections));
    wm.ChangeScreen(diskId,s1.screen);
    wind:=wm.OpenWindow(diskId);
(*    wind:=is.SetWindow(120,70,194,70,s.ADR("Suche Nullstellen"),LONGSET{I.activate,I.windowDrag,I.windowDepth},
                       LONGSET{I.gadgetUp},s1.screen);*)
    IF wind#NIL THEN
      rast:=wind.rPort;
      s13.searchrast:=rast;
(*      ig.SetPlastHighGadget(ca,wind,s.ADR("Abbruch"),12,48,164,
                        SET{I.gadgImmediate,I.relVerify});*)
      g.SetAPen(rast,2);
      tt.Print(12,19,ac.GetString(ac.FindingIntersections),rast);
      it.DrawBorder(rast,14,22,s13.barwi+4,24);
(*      bord:=ig.SetPlastBorder(20,160);
      I.DrawBorder(rast,bord,16,23);*)
      g.SetAPen(rast,3);
    END;
    s13.ResetSearch;
(*    fpos:=0;
    root:=f.Parse(node2(s1.FensterFunc).func.terms.head(s1.Term).string,fpos);
    f.Vereinfache(root);*)
    sub1:=wfunc1(s1.FensterFunc).graphs.head;
    func1:=wfunc1(s1.FensterFunc).func;
    sub2:=wfunc2(s1.FensterFunc).graphs.head;
    func2:=wfunc2(s1.FensterFunc).func;
    node:=p;
    table:=NIL;
    table2:=NIL;
    alloc:=FALSE;
    alloc2:=FALSE;
    IF NOT(func1(s1.Function).depend.isEmpty()) THEN
      COPY(ac.GetString(ac.SetVariableValues)^,str);
      st.Append(str,": ");
      st.Append(str,func1(s1.Function).name);
      node:=s2.SelectNode(func1(s1.Function).depend,s.ADR(str),ac.GetString(ac.None),ac.GetString(ac.VariablesEx));

      IF node#NIL THEN
        CalcTable(rast,p,func1,table);
        alloc:=TRUE;
      END;
    ELSE
      table:=sub1(s1.FunctionGraph).table;
    END;
    IF NOT(func2(s1.Function).depend.isEmpty()) AND (node#NIL) THEN
      COPY(ac.GetString(ac.SetVariableValues)^,str);
      st.Append(str,": ");
      st.Append(str,func2(s1.Function).name);
      node:=s2.SelectNode(func2(s1.Function).depend,s.ADR(str),ac.GetString(ac.None),ac.GetString(ac.VariablesEx));

      IF node#NIL THEN
        CalcTable(rast,p,func2,table2);
        alloc2:=TRUE;
      END;
    ELSE
      table2:=sub2(s1.FunctionGraph).table;
    END;
    IF node#NIL THEN
      NEW(table3,p(s1.Fenster).stutz);
      i:=-1;
      WHILE i<p(s1.Fenster).stutz-1 DO
        INC(i);
        table3[i].real:=table[i].real-table2[i].real;
        table3[i].error:=table[i].error;
        IF table2[i].error#0 THEN
          table3[i].error:=table2[i].error;
        END;
      END;
      pos:=1;
      i:=-1;
      func1(s1.Function).diffunc:=func2;
      xmax:=p(s1.Fenster).xmax;
      REPEAT
        r:=s13.SearchNull(p,func1,table3,isnull,0.0000001);
        IF isnull THEN
          node:=NIL;
          NEW(node(s13.ListElement));
          WITH node: s13.ListElement DO
            bool:=lrc.RealToString(r,node.xstring,6,6,FALSE);
            node.xreal:=r;
            error:=0;
            y:=s2.GetFunctionValue(func2,r,0.0001,error);
            IF error=0 THEN
              bool:=lrc.RealToString(y,node.ystring,6,6,FALSE);
            ELSE
              COPY(ac.GetString(ac.Undefined)^,node.ystring);
            END;
  (*          yl:=s2.GetFunctionValue(func,r-0.0001,0.0001,error);
            yr:=s2.GetFunctionValue(func,r+0.0001,0.0001,error);
            IF (yl<0) AND (yr>0) THEN
              node.comment:="Vorzeichenwechsel -/+";
            ELSIF (yl>0) AND (yr<0) THEN
              node.comment:="Vorzeichenwechsel +/-";
            ELSE
              node.comment:="Kein Vorzeichenwechsel";
            END;*)
            node.marked:=FALSE;
          END;
          s13.viewlist.AddTail(node);
        END;
        it.GetIMes(wind,class,code,address);
        IF I.gadgetUp IN class THEN
          IF address=ca THEN
            pos:=10000;
            xmax:=SHORT(r);
            isnull:=FALSE;
          END;
        END;
      UNTIL NOT(isnull);
      func1(s1.Function).diffunc:=NIL;
  (*    QUICK(0,i);*)
      IF wind#NIL THEN
  (*      ig.FreePlastBorder(bord);
        ig.FreePlastHighBooleanGadget(ca,wind);*)
        wm.CloseWindow(diskId);
      END;
      wm.FreeGadgets(diskId);
      s13.searchrast:=NIL;
      s13.numlist[0]:=i+1;
(*      s13.undertitle[0]:="Schnittpunkte";*)
      COPY(wfunc1(s1.FensterFunc).func(s1.Function).name,str);
      st.Append(str,"; ");
      st.Append(str,wfunc2(s1.FensterFunc).func(s1.Function).name);
      i:=s13.ListSelect(ac.GetString(ac.Intersections),str,p(s1.Fenster).xmin,xmax,p,TRUE);
      IF (alloc) AND (table#NIL) THEN
        DISPOSE(table);
      END;
      IF (alloc2) AND (table2#NIL) THEN
        DISPOSE(table2);
      END;
    ELSE
      IF wind#NIL THEN
        wm.CloseWindow(diskId);
      END;
      wm.FreeGadgets(diskId);
      IF (alloc) AND (table#NIL) THEN
        DISPOSE(table);
      END;
      IF (alloc2) AND (table2#NIL) THEN
        DISPOSE(table2);
      END;
    END;
  END;
END SetSchnitt;

PROCEDURE KomplettDiscuss*(p,ffunc:l.Node);

VAR wind : I.WindowPtr;
    rast : g.RastPortPtr;
    ok,ca,
    help,
    print,
    text,
    up,down,
    scroll : I.GadgetPtr;
    bord : I.BorderPtr;
    list : l.List;
    node,
    node2,
    node3,
    abl,
    second,
    func : l.Node;
    pos,
    opos,
    pos2,
    pos1,
    error,
    error2,
    shown,
    i,a,ci : INTEGER;
    root : f1.NodePtr;
    string,
    str  : ARRAY 200 OF CHAR;
    r,x,y: LONGREAL;
    isnull,
    ismax,
    ismin: BOOLEAN;
    xx,
    sx,sy,
    dx,dy : REAL;
    pf    : s1.Funktion;
    sx2,sy2 : REAL;
    found : BOOLEAN;
    pressed,
    boolup,
    booldown : BOOLEAN;
    width,
    height: INTEGER;
    anz   : INTEGER;
    sub   : l.Node;
    table : s1.FuncTable;
    owntable : BOOLEAN;
    left,
    right : LONGREAL;
    exit,
    break : BOOLEAN;

PROCEDURE PrintLastLine;

VAR node : l.Node;
    i,max: INTEGER;
    mask,
    style: SHORTSET;
    str  : e.STRPTR;

BEGIN
  max:=((width-58) DIV 8)-1;
  NEW(str);
  node:=list.tail;
  mask:=g.AskSoftStyle(rast);
  style:=g.SetSoftStyle(rast,node(TextLine).style,mask);
  g.SetAPen(rast,node(TextLine).color);
  i:=SHORT(list.nbElements())-1;
  DEC(i,pos);
  IF (i>=0) AND (i<shown) THEN
    COPY(node(TextLine).string^,str^);
    str^[max]:=0X;
    tt.Print(18,24+i*8,str,rast);
  ELSIF i>=shown THEN
    REPEAT
      INC(pos);
      DEC(i);
      g.ScrollRaster(rast,0,8,18,18,width-47,height-26);
    UNTIL i<shown;
    COPY(node(TextLine).string^,str^);
    str^[max]:=0X;
    tt.Print(18,24+i*8,str,rast);
  END;
  mask:=g.AskSoftStyle(rast);
  style:=g.SetSoftStyle(rast,SHORTSET{},mask);
  gm.SetScroller(scroll,wind,SHORT(list.nbElements()),shown,pos);
  DISPOSE(str);
END PrintLastLine;

PROCEDURE PrintAll;

VAR node : l.Node;
    i,a,
    max  : INTEGER;
    mask,
    style: SHORTSET;
    str  : e.STRPTR;

BEGIN
  max:=((width-58) DIV 8)-1;
  NEW(str);
  i:=-1;
  node:=list.head;
  WHILE node#NIL DO
    INC(i);
    mask:=g.AskSoftStyle(rast);
    style:=g.SetSoftStyle(rast,node(TextLine).style,mask);
    g.SetAPen(rast,node(TextLine).color);
    a:=i;
    DEC(a,pos);
    IF (a>=0) AND (a<shown) THEN
      COPY(node(TextLine).string^,str^);
      str^[max]:=0X;
      tt.Print(18,24+a*8,str,rast);
    END;
    node:=node.next;
  END;
  mask:=g.AskSoftStyle(rast);
  style:=g.SetSoftStyle(rast,SHORTSET{},mask);
  DISPOSE(str);
END PrintAll;

PROCEDURE NewLine():l.Node;

VAR node : l.Node;

BEGIN
  NEW(node(TextLine));
  NEW(node(TextLine).string,256);
  node(TextLine).string^:="";
  node(TextLine).style:=SHORTSET{};
  node(TextLine).color:=1;
  list.AddTail(node);
  RETURN node;
END NewLine;

PROCEDURE RefreshBorders;

VAR bord : I.BorderPtr;

BEGIN
  gm.DrawPropBorders(wind);

  it.DrawBorder(rast,14,16,width-58,height-40);

(*  bord:=ig.SetPlastBorder(height-44,width-62);
  I.DrawBorder(rast,bord,16,17);
  ig.FreePlastBorder(bord);

  bord:=ig.SetPlastBorder(height-64,12);
  I.DrawBorder(rast,bord,width-42,17);
  ig.FreePlastBorder(bord);*)
END RefreshBorders;

PROCEDURE PrintOut;

VAR port  : e.MsgPortPtr;
    req   : e.IOStdReqPtr;
    cmd   : pr.IOPrtCmdReqPtr;
    short : SHORTINT;
    node  : l.Node;
    str   : ARRAY 256 OF CHAR;
    handle: d.FileHandlePtr;
    long  : LONGINT;

BEGIN
(*  port:=es.CreatePort("",0);
  req:=es.CreateExtIO(port,s.SIZE(e.IOStdReq));
  short:=e.OpenDevice("printer.device",0,req,LONGSET{});*)
  handle:=NIL;
  handle:=d.Open("prt:",d.oldFile);

  IF handle#NIL THEN
    node:=list.head;
    WHILE node#NIL DO
      WITH node: TextLine DO
  (*      IF g.bold IN node.style THEN
          cmd:=es.CreateExtIO(port,s.SIZE(pr.IOPrtCmdReq));
          short:=e.OpenDevice("printer.device",0,cmd,LONGSET{});
          cmd.command:=pr.prtCommand;
          cmd.prtCommand:=pr.aSGR1;
          short:=e.DoIO(cmd);
          e.CloseDevice(cmd);
          es.DeleteExtIO(cmd);
        END;
        req:=es.CreateExtIO(port,s.SIZE(e.IOStdReq));
        short:=e.OpenDevice("printer.device",0,req,LONGSET{});*)
        str:="";
        IF g.bold IN node.style THEN
          str:="\[1m";
        END;
(*        COPY(node.string,str);*)
        st.Append(str,node.string^);
        IF g.bold IN node.style THEN
          st.Append(str,"\[22m");
        END;
        st.AppendChar(str,"\n");
        long:=d.Write(handle,str,st.Length(str));
  (*      req.command:=e.write;
        req.data:=s.ADR(str);
        req.length:=st.Length(str);
        short:=e.DoIO(req);*)
  (*      e.CloseDevice(req);
        es.DeleteExtIO(req);
        IF g.bold IN node.style THEN
          cmd:=es.CreateExtIO(port,s.SIZE(pr.IOPrtCmdReq));
          short:=e.OpenDevice("printer.device",0,cmd,LONGSET{});
          cmd.command:=pr.prtCommand;
          cmd.prtCommand:=pr.aSGR22;
          short:=e.DoIO(cmd);
          e.CloseDevice(cmd);
          es.DeleteExtIO(cmd);
        END;*)
      END;
      node:=node.next;
    END;
  END;

  bool:=d.Close(handle);
(*  e.CloseDevice(req);
  es.DeleteExtIO(req);
  es.DeletePort(port);*)
END PrintOut;

(*PROCEDURE SetNachKomma(VAR string:ARRAY OF CHAR;n:INTEGER);

VAR i,a : INTEGER;

BEGIN
  i:=0;
  WHILE (string[i]#".") AND (i<st.Length(string)) DO
    INC(i);
  END;
  INC(i);
  IF i<st.Length(string) THEN
    FOR a:=1 TO n DO
      INC(i);
    END;
    IF i<st.Length(string) THEN
      string[i]:=0X;
    END;
  END;
END SetNachKomma;*)

PROCEDURE PrintFunction(func:l.Node;anz:INTEGER);

VAR term,node,
    firstnode,
    node2,
    functerm  : l.Node;
    max       : INTEGER;
    first     : BOOLEAN;

BEGIN
  max:=0;
  firstnode:=NIL;
  first:=TRUE;
  functerm:=func(s1.Function).terms.head;
  WHILE functerm#NIL DO
    term:=functerm(s1.FuncTerm).term;
    node:=NewLine();
    NEW(node(TextLine).string,1024);
    IF firstnode=NIL THEN
      firstnode:=node;
    END;
    IF first THEN
      node(TextLine).string^:="  f(x) = ";
    ELSE
      node(TextLine).string^:="         ";
    END;
    IF ableitung THEN
      IF (anz>0) AND (first) THEN
        FOR a:=1 TO anz DO
          st.InsertChar(node(TextLine).string^,3,"'");
        END;
        IF ableitanz-anz>0 THEN
          FOR a:=1 TO ableitanz-anz DO
            st.InsertChar(node(TextLine).string^,6+anz," ");
          END;
        END;
      ELSE
        FOR a:=1 TO ableitanz DO
          st.InsertChar(node(TextLine).string^,6," ");
        END;
      END;
    END;
    st.Append(node(TextLine).string^,term(s1.Term).string);
    IF st.Length(node(TextLine).string^)>max THEN
      max:=SHORT(st.Length(node(TextLine).string^));
    END;
    node2:=term(s1.Term).define.head;
    IF node2#NIL THEN
      node2:=node2.next;
    END;
    WHILE node2#NIL DO
      node:=NewLine();
      NEW(node(TextLine).string,1024);
      node2:=node2.next;
    END;
    functerm:=functerm.next;
    first:=FALSE;
  END;
  INC(max,2);
  functerm:=func(s1.Function).terms.head;
  WHILE functerm#NIL DO
    IF NOT(term(s1.Term).define.isEmpty()) THEN
      term:=functerm(s1.FuncTerm).term;
      WHILE st.Length(firstnode(TextLine).string^)<max DO
        st.AppendChar(firstnode(TextLine).string^," ");
      END;
    END;
    node:=term(s1.Term).define.head;
    WHILE node#NIL DO
      IF node=term(s1.Term).define.head THEN
        st.Append(firstnode(TextLine).string^,ac.GetString(ac.ForRange)^);
        st.AppendChar(firstnode(TextLine).string^," ");
      ELSE
        st.Append(firstnode(TextLine).string^,ac.GetString(ac.And)^);
        st.AppendChar(firstnode(TextLine).string^," ");
      END;
      st.Append(firstnode(TextLine).string^,node(s1.Define).string);
      node:=node.next;
      IF node#NIL THEN
        firstnode:=firstnode.next;
      END;
    END;
    firstnode:=firstnode.next;
    functerm:=functerm.next;
  END;
END PrintFunction;

PROCEDURE SendTextBox;

VAR node : l.Node;

BEGIN
  NEW(node(s1.PreviewNode));
  node(s1.PreviewNode).node:=list.head;
  node(s1.PreviewNode).prevgotobj:=FALSE;
  node(s1.PreviewNode).changed:=FALSE;
  s1.prevlist.AddTail(node);
  e.Signal(s1.prevtask,LONGSET{s1.prevnewobj});
END SendTextBox;

BEGIN
  IF discussId=-1 THEN
    discussId:=wm.InitWindow(20,10,566,188,ac.GetString(ac.CompleteFunctionAnalysis),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.windowSizing,I.noCareRefresh},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.newSize},s1.screen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,-20,100,14,ac.GetString(ac.OK));
  INCL(ok.flags,I.gRelBottom);
  ca:=gm.SetBooleanGadget(-127,-20,100,14,ac.GetString(ac.Cancel));
  INCL(ca.flags,I.gRelBottom);
  INCL(ca.flags,I.gRelRight);
  help:=gm.SetBooleanGadget(120,-20,100,14,ac.GetString(ac.Help));
  INCL(help.flags,I.gRelBottom);
  print:=gm.SetBooleanGadget(226,-20,100,14,ac.GetString(ac.Print));
  INCL(print.flags,I.gRelBottom);
  text:=gm.SetBooleanGadget(332,-20,100,14,ac.GetString(ac.TextBox));
  INCL(text.flags,I.gRelBottom);
  up:=gm.SetArrowUpGadget(-43,-43);
  INCL(up.flags,I.gRelBottom);
  INCL(up.flags,I.gRelRight);
  down:=gm.SetArrowDownGadget(-43,-33);
  INCL(down.flags,I.gRelBottom);
  INCL(down.flags,I.gRelRight);
  scroll:=gm.SetPropGadget(-43,16,16,-60,0,0,0,32767);
  INCL(scroll.flags,I.gRelHeight);
  INCL(scroll.flags,I.gRelRight);
  gm.EndGadgets;
  wm.SetGadgets(discussId,ok);
  wm.ChangeScreen(discussId,s1.screen);
  wind:=wm.OpenWindow(discussId);
  IF wind#NIL THEN
    rast:=wind.rPort;
    width:=wind.width;
    height:=wind.height;
    bool:=I.WindowLimits(wind,566,188,-1,-1);
(*    ok.flags:=SET{I.gRelBottom};
    ig.SetPlastHighGadget(ok,wind,s.ADR("OK"),12,-21,100,
                      SET{I.gadgImmediate,I.relVerify});
    ca.flags:=SET{I.gRelBottom,I.gRelRight};
    ig.SetPlastHighGadget(ca,wind,s.ADR("Abbruch"),-129,-21,100,
                      SET{I.gadgImmediate,I.relVerify});
    print.flags:=SET{I.gRelBottom};
    ig.SetPlastHighGadget(print,wind,s.ADR("Drucken"),200,-21,100,
                      SET{I.gadgImmediate,I.relVerify});
    up.flags:=SET{I.gRelBottom,I.gRelRight};
    ig.SetArrowUpGadget(up,wind,-43,-43,
                      SET{I.gadgImmediate,I.relVerify});
    down.flags:=SET{I.gRelBottom,I.gRelRight};
    ig.SetArrowDownGadget(down,wind,-43,-33,
                      SET{I.gadgImmediate,I.relVerify});
    scroll.flags:=SET{I.gRelHeight,I.gRelRight};
    ig.SetPlastProp(scroll,SET{I.autoKnob,I.freeVert,I.knobHit},-41,17,12,-64,
                    0,4096,wind);*)

    g.SetDrMd(rast,g.jam2);

    RefreshBorders;

    pos:=0;
    shown:=(height-44) DIV 8;
    list:=l.Create();
    break:=FALSE;

    pt.SetBusyPointer(wind);

    sub:=ffunc(s1.FensterFunc).graphs.head;
    func:=ffunc(s1.FensterFunc).func;
    node:=p;
    owntable:=FALSE;
    IF NOT(func(s1.Function).depend.isEmpty()) THEN
      COPY(ac.GetString(ac.SetVariableValues)^,str);
      st.Append(str,": ");
      st.Append(str,func(s1.Function).name);
      node:=s2.SelectNode(func(s1.Function).depend,s.ADR(str),ac.GetString(ac.None),ac.GetString(ac.VariablesEx));

      IF node#NIL THEN
        owntable:=TRUE;
        CalcTable(NIL,p,func,table);
      END;
    ELSE
      table:=sub(s1.FunctionGraph).table;
    END;
    IF node#NIL THEN
      node:=NewLine();
      COPY(ac.GetString(ac.AnalysisOfFunction)^,node(TextLine).string^);
      node(TextLine).style:=SHORTSET{g.bold};
  (*    node:=NewLine();
      node(TextLine).string:="  f(x) = ";
      IF ableitung THEN
        FOR anz:=1 TO ableitanz DO
          st.InsertChar(node(TextLine).string,6," ");
        END;
      END;
      st.Append(node(TextLine).string,func(s1.FensterFunc).func.terms.head(s1.Term).string);*)
      PrintFunction(func,0);
      PrintAll;
      IF ableitung THEN
        node:=NewLine();
        node:=NewLine();
        COPY(ac.GetString(ac.Derivatives)^,node(TextLine).string^);
        st.AppendChar(node(TextLine).string^,":");
        node(TextLine).style:=SHORTSET{g.bold};
        PrintLastLine;
  (*      i:=0;
        root:=f.Parse(func(s1.FensterFunc).func.terms.head(s1.Term).string,i);
        f.Vereinfache(root);*)
        abl:=func;
        i:=ableitanz;
        IF i<2 THEN
          i:=2;
        END;
        anz:=0;
        WHILE anz<i DO
          INC(anz);
  (*        node:=NewLine();*)
  (*        f.Ableit(root,"X");
          f.Vereinfache(root);*)
          abl:=s2.AbleitFunction(abl,"x");
          IF anz<=ableitanz THEN
  (*          f.TreeToString(root,string,FALSE);
            node(TextLine).string:="  f(x) = ";
            FOR a:=1 TO anz DO
              st.InsertChar(node(TextLine).string,3,"'");
            END;
            IF ableitanz-anz>0 THEN
              FOR a:=1 TO ableitanz-anz DO
                st.InsertChar(node(TextLine).string,6+anz," ");
              END;
            END;
            st.Append(node(TextLine).string,string);
            PrintLastLine;*)
            PrintFunction(abl,anz);
            PrintAll;
          END;
          IF anz=2 THEN
  (*          second:=f2.CopyTree(root);*)
            second:=abl;
  (*        ELSIF anz=3 THEN
            third:=f2.CopyTree(root);*)
          END;
          it.GetIMes(wind,class,code,address);
          IF I.gadgetUp IN class THEN
            IF address=ca THEN
              break:=TRUE;
              anz:=i;
            END;
          END;
        END;
      ELSIF wendepunkte THEN
        second:=s2.AbleitFunction(func,"x");
        second:=s2.AbleitFunction(second,"x");
      END;
  (*    pos1:=0;
      root:=f.Parse(func(s1.FensterFunc).func.terms.head(s1.Term).string,pos1);
      f.Vereinfache(root);*)
  
      IF (symmetrie) AND NOT(break) THEN
        node:=NewLine();
        PrintLastLine;
        node:=NewLine();
        COPY(ac.GetString(ac.Symmetry)^,node(TextLine).string^);
        st.AppendChar(node(TextLine).string^,":");
        node(TextLine).style:=SHORTSET{g.bold};
        PrintLastLine;
        i:=-1;
        sx:=-0.1;
        WHILE sx<10 DO
          sx:=sx+0.1;
          error:=0;
          error2:=0;
          sy:=s2.GetFunctionValueShort(func,sx,0.1,error);
          sy2:=s2.GetFunctionValueShort(func,-sx,-0.1,error2);
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
            sy:=s2.GetFunctionValueShort(func,sx,0.1,error);
            sy2:=s2.GetFunctionValueShort(func,-sx,-0.1,error2);
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
        node:=NewLine();
        IF i=-1 THEN
          node(TextLine).string^:="  ";
          st.Append(node(TextLine).string^,ac.GetString(ac.NoSimpleSymmetryFound)^);
        ELSIF i=0 THEN
          node(TextLine).string^:="  ";
          st.Append(node(TextLine).string^,ac.GetString(ac.AxialSymmetryToYAxis)^);
        ELSIF i=1 THEN
          node(TextLine).string^:="  ";
          st.Append(node(TextLine).string^,ac.GetString(ac.PointSymmetryToOrigin)^);
        END;
        PrintLastLine;
      END;
  
      IF (nullstellen) AND NOT(break) THEN
        s13.ResetSearch;
        node:=NewLine();
        PrintLastLine;
        node:=NewLine();
        COPY(ac.GetString(ac.Zeros)^,node(TextLine).string^);
        st.AppendChar(node(TextLine).string^,":");
        node(TextLine).style:=SHORTSET{g.bold};
        PrintLastLine;
    
        pos1:=1;
        i:=-1;
        found:=FALSE;
        REPEAT
          r:=s13.SearchNull(p,func,table,isnull,0.000000001);
  (*        r:=s11.SearchNull(p,root,sub(s1.FunctionGraph).table,isnull);*)
          IF isnull THEN
            found:=TRUE;
            node:=NewLine();
            node(TextLine).string^:="  x = ";
            bool:=lrc.RealToString(r,string,10,nullnach,FALSE);
  (*          SetNachKomma(string,nullnach);*)
            tt.Clear(string);
            st.Append(node(TextLine).string^,string);
            PrintLastLine;
          END;
          it.GetIMes(wind,class,code,address);
          IF I.gadgetUp IN class THEN
            IF address=ca THEN
              isnull:=FALSE;
              break:=TRUE;
            END;
          END;
        UNTIL NOT(isnull);
        IF NOT(found) THEN
          node:=NewLine();
          node(TextLine).string^:="  ";
          st.Append(node(TextLine).string^,ac.GetString(ac.NoZerosFound)^);
          PrintLastLine;
        END;
      END;
  
      IF (extrempunkte) AND NOT(break) THEN
        s13.ResetSearch;
        node:=NewLine();
        PrintLastLine;
        node:=NewLine();
        COPY(ac.GetString(ac.ExtremePoints)^,node(TextLine).string^);
        st.AppendChar(node(TextLine).string^,":");
        node(TextLine).style:=SHORTSET{g.bold};
        PrintLastLine;
    
        pos1:=1;
        pos2:=1;
        i:=-1;
        found:=FALSE;
        ismax:=TRUE;
        ismin:=TRUE;
        node2:=NIL;
        REPEAT
          node:=NIL;
          IF ismax THEN
            r:=s13.SearchMax(p,func,table,ismax,0.000000001);
  (*          r:=s11.SearchMax(p,root,sub(s1.FunctionGraph).table,ismax);*)
            IF ismax THEN
              node:=NewLine();
              IF NOT(found) THEN
                node2:=node;
              END;
              found:=TRUE;
              string:="  ";
              st.Append(string,ac.GetString(ac.MaximumPoint)^);
              st.Append(string," H(");
              bool:=lrc.RealToString(r,str,10,extremnach,FALSE);
  (*            SetNachKomma(str,extremnach);*)
              tt.Clear(str);
              st.Append(string,str);
              st.AppendChar(string,"|");
              error:=0;
              y:=s2.GetFunctionValue(func,r,0.0001,error);
              bool:=lrc.RealToString(y,str,10,extremnach,FALSE);
  (*            SetNachKomma(str,extremnach);*)
              tt.Clear(str);
              st.Append(string,str);
              st.AppendChar(string,")");
              IF st.Length(string)<35 THEN
                REPEAT
                  st.AppendChar(string," ");
                UNTIL st.Length(string)>=30;
              END;
              COPY(string,node(TextLine).string^);
              PrintLastLine;
            END;
          END;
          it.GetIMes(wind,class,code,address);
          IF I.gadgetUp IN class THEN
            IF address=ca THEN
              ismax:=FALSE;
              break:=TRUE;
            END;
          END;
        UNTIL NOT(ismax);
        IF NOT(break) THEN
          s13.ResetSearch;
          REPEAT
            IF ismin THEN
              r:=s13.SearchMin(p,func,table,ismin,0.000000001);
    (*          r:=s11.SearchMin(p,root,sub(s1.FunctionGraph).table,ismin);*)
              IF ismin THEN
                node:=node2;
                IF node2#NIL THEN
                  node2:=node2.next;
                END;
                found:=TRUE;
                IF node=NIL THEN
                  node:=NewLine();
                  node(TextLine).string^:="";
                  REPEAT
                    st.AppendChar(node(TextLine).string^," ");
                  UNTIL st.Length(node(TextLine).string^)>=30;
                  st.Append(node(TextLine).string^,ac.GetString(ac.MinimumPoint)^);
                  st.Append(node(TextLine).string^," T(");
                ELSE
                  st.Append(node(TextLine).string^,ac.GetString(ac.MinimumPoint)^);
                  st.Append(node(TextLine).string^," T(");
                END;
                bool:=lrc.RealToString(r,str,10,extremnach,FALSE);
  (*              SetNachKomma(str,extremnach);*)
                tt.Clear(str);
                st.Append(node(TextLine).string^,str);
                st.AppendChar(node(TextLine).string^,"|");
                error:=0;
                y:=s2.GetFunctionValue(func,r,0.0001,error);
                bool:=lrc.RealToString(y,str,10,extremnach,FALSE);
  (*              SetNachKomma(str,extremnach);*)
                tt.Clear(str);
                st.Append(node(TextLine).string^,str);
                st.AppendChar(node(TextLine).string^,")");
                PrintLastLine;
              END;
            END;
            it.GetIMes(wind,class,code,address);
            IF I.gadgetUp IN class THEN
              IF address=ca THEN
                ismin:=FALSE;
                break:=TRUE;
              END;
            END;
          UNTIL NOT(ismin);
        END;
        WHILE node2#NIL DO
          PrintLastLine;
          node2:=node2.next;
        END;
        PrintAll;
        IF NOT(found) THEN
          node:=NewLine();
          node(TextLine).string^:="  ";
          st.Append(node(TextLine).string^,ac.GetString(ac.NoExtremePointsFound)^);
          PrintLastLine;
        END;
      END;

      IF (owntable) AND (table#NIL) THEN
        DISPOSE(table);
      END;
      IF (wendepunkte) AND NOT(break) THEN
        s13.ResetSearch;
        node:=NewLine();
        PrintLastLine;
        node:=NewLine();
        COPY(ac.GetString(ac.PointsOfInflection)^,node(TextLine).string^);
        st.AppendChar(node(TextLine).string^,":");
        node(TextLine).style:=SHORTSET{g.bold};
        PrintLastLine;
    
        NEW(table,p(s1.Fenster).stutz);
        pos1:=1;
        xx:=ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax);
        xx:=xx/p(s1.Fenster).stutz;
        x:=p(s1.Fenster).xmin-xx;
        i:=-1;
        dx:=ABS(p(s1.Fenster).xmin)+ABS(p(s1.Fenster).xmax);
        sx:=p(s1.Fenster).width/dx;
        WHILE i<(p(s1.Fenster).stutz-1) DO
          INC(i);
          x:=x+xx;
          error:=0;
          table[i].real:=s2.GetFunctionValueShort(second,SHORT(x),SHORT(xx),error);
          table[i].error:=error;
        END;
        pos1:=1;
        i:=-1;
        found:=FALSE;
        REPEAT
          r:=s13.SearchNull(p,second,table,isnull,0.000000001);
  (*        r:=s11.SearchNull(p,second,table,isnull);*)
          exit:=NOT(isnull);
          left:=s2.GetFunctionValue(second,r-0.0001,xx,error);
          right:=s2.GetFunctionValue(second,r+0.0001,xx,error);
          IF ((left>0) AND (right>0)) OR ((left<0) AND (right<0)) OR ((left=0) AND (right=0)) THEN
            isnull:=FALSE;
          END;
          IF isnull THEN
            found:=TRUE;
            node:=NewLine();
            node(TextLine).string^:="  W(";
            bool:=lrc.RealToString(r,string,10,wendenach,FALSE);
  (*          SetNachKomma(string,wendenach);*)
            tt.Clear(string);
            st.Append(node(TextLine).string^,string);
            st.AppendChar(node(TextLine).string^,"|");
            error:=0;
            y:=s2.GetFunctionValue(func,r,0,error);
            bool:=lrc.RealToString(y,string,10,wendenach,FALSE);
  (*          SetNachKomma(string,wendenach);*)
            tt.Clear(string);
            st.Append(node(TextLine).string^,string);
            st.AppendChar(node(TextLine).string^,")");
            PrintLastLine;
          END;
          it.GetIMes(wind,class,code,address);
          IF I.gadgetUp IN class THEN
            IF address=ca THEN
              exit:=TRUE;
              break:=TRUE;
            END;
          END;
        UNTIL exit;
        IF NOT(found) THEN
          node:=NewLine();
          node(TextLine).string^:="  ";
          st.Append(node(TextLine).string^,ac.GetString(ac.NoPointsOfInflectionFound)^);
          PrintLastLine;
        END;
        DISPOSE(table);
      END;
  
      pt.ClearPointer(wind);
  
      IF NOT(break) THEN
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
          pos:=gm.GetScroller(scroll,SHORT(list.nbElements()),shown);
          IF boolup THEN
            DEC(pos);
            IF pos<0 THEN
              pos:=0;
            END;
            IF opos#pos THEN
              gm.SetScroller(scroll,wind,SHORT(list.nbElements()),shown,pos);
            END;
          ELSIF booldown THEN
            INC(pos);
            IF pos>SHORT(list.nbElements())-shown THEN
              DEC(pos);
            END;
            IF opos#pos THEN
              gm.SetScroller(scroll,wind,SHORT(list.nbElements()),shown,pos);
            END;
          END;
          IF opos#pos THEN
            gm.SetScroller(scroll,wind,SHORT(list.nbElements()),shown,pos);
            g.SetAPen(rast,0);
            g.RectFill(rast,18,18,width-47,height-26);
            g.SetAPen(rast,1);
            PrintAll;
    (*        IF (opos>pos) AND (opos<pos+(shown DIV 2)) THEN
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
            END;*)
          END;
          IF I.gadgetUp IN class THEN
            IF address=ok THEN
              EXIT;
            ELSIF address=ca THEN
              EXIT;
            ELSIF address=text THEN
              SendTextBox;
            ELSIF address=print THEN
              pt.SetBusyPointer(wind);
              PrintOut;
              pt.ClearPointer(wind);
            END;
          ELSIF I.newSize IN class THEN
            width:=wind.width;
            height:=wind.height;
            shown:=(height-44) DIV 8;
            g.SetAPen(rast,0);
            g.RectFill(rast,4,11,width-19,height-3);
            I.RefreshGList(ok,wind,NIL,6);
            I.RefreshWindowFrame(wind);
            RefreshBorders;
            IF SHORT(list.nbElements())-pos<shown THEN
              pos:=SHORT(list.nbElements())-shown;
            END;
            PrintAll;
            gm.SetScroller(scroll,wind,SHORT(list.nbElements()),shown,pos);
          END;
          IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
            ag.ShowFile(s1.analaydoc,"completediscuss",wind);
          END;
        END;
      END;
    END;

(*    ig.FreePlastPropGadget(scroll,wind);
    ig.FreePlastArrowGadget(down,wind);
    ig.FreePlastArrowGadget(up,wind);
    ig.FreePlastHighBooleanGadget(print,wind);
    ig.FreePlastHighBooleanGadget(ca,wind);
    ig.FreePlastHighBooleanGadget(ok,wind);*)
    wm.CloseWindow(discussId);
  END;
  wm.FreeGadgets(discussId);
END KomplettDiscuss;

PROCEDURE KomplettEinstellungen*;

VAR wind : I.WindowPtr;
    rast : g.RastPortPtr;
    ok,ca,
    help,
    ableitgad,ableitanzgad,
    symmgad,
    nullgad,nullnachgad,
    extremgad,extremnachgad,
    wendegad,wendenachgad : I.GadgetPtr;
    old  : INTEGER;
    oldabl,
    oldsymm,
    oldnull,
    oldextrem,
    oldwende     : BOOLEAN;
    oldablanz,
    oldnullnach,
    oldextremnach,
    oldwendenach : INTEGER;

BEGIN
  IF discussoptId=-1 THEN
    discussoptId:=wm.InitWindow(20,0,332,164,ac.GetString(ac.CompleteAnalysisSettings),LONGSET{I.activate,I.windowDrag,I.windowDepth},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.intuiTicks},s1.screen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,143,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(218,143,100,14,ac.GetString(ac.Cancel));
  ableitgad:=gm.SetCheckBoxGadget(286,18,26,9,ableitung);
  symmgad:=gm.SetCheckBoxGadget(286,45,26,9,symmetrie);
  nullgad:=gm.SetCheckBoxGadget(286,58,26,9,nullstellen);
  extremgad:=gm.SetCheckBoxGadget(286,85,26,9,extrempunkte);
  wendegad:=gm.SetCheckBoxGadget(286,112,26,9,wendepunkte);
  ableitanzgad:=gm.SetPropGadget(208,31,104,12,0,0,32767,0);
  nullnachgad:=gm.SetPropGadget(208,71,104,12,0,0,32767,0);
  extremnachgad:=gm.SetPropGadget(208,98,104,12,0,0,32767,0);
  wendenachgad:=gm.SetPropGadget(208,125,104,12,0,0,32767,0);
  gm.EndGadgets;
  wm.SetGadgets(discussoptId,ok);
  wm.ChangeScreen(discussoptId,s1.screen);
  wind:=wm.OpenWindow(discussoptId);
  IF wind#NIL THEN
    rast:=wind.rPort;
(*    ig.SetPlastHighGadget(ok,wind,s.ADR("OK"),12,142,100,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetPlastHighGadget(ca,wind,s.ADR("Abbrechen"),216,142,100,
                      SET{I.gadgImmediate,I.relVerify});*)

    gm.DrawPropBorders(wind);

    it.DrawBorder(rast,14,16,304,124);

    g.SetAPen(rast,1);
    tt.Print(20,26,ac.GetString(ac.Derivatives),rast);
    g.SetAPen(rast,2);
    tt.Print(200,26,ac.GetString(ac.create),rast);
(*    ig.SetCheckBoxGadget(ableitgad,wind,286,18,
                      SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
    ig.SetPlastProp(ableitanzgad,SET{I.autoKnob,I.freeHoriz,I.knobHit},210,32,100,8,
                    0,4096,wind);*)
    tt.Print(20,39,ac.GetString(ac.MaxDegree),rast);
    tt.PrintInt(178,39,ableitanz,2,rast);

    g.SetAPen(rast,1);
    tt.Print(20,53,ac.GetString(ac.Symmetry),rast);
    g.SetAPen(rast,2);
    tt.Print(224,53,ac.GetString(ac.search),rast);
(*    ig.SetCheckBoxGadget(symmgad,wind,286,45,
                      SET{I.gadgImmediate,I.relVerify,I.toggleSelect});*)

    g.SetAPen(rast,1);
    tt.Print(20,66,ac.GetString(ac.Zeros),rast);
    g.SetAPen(rast,2);
    tt.Print(224,66,ac.GetString(ac.search),rast);
(*    ig.SetCheckBoxGadget(nullgad,wind,286,58,
                      SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
    ig.SetPlastProp(nullnachgad,SET{I.autoKnob,I.freeHoriz,I.knobHit},210,72,100,8,
                    0,4096,wind);*)
    tt.Print(20,79,ac.GetString(ac.DecimalPlaces),rast);
    tt.PrintInt(178,79,nullnach,2,rast);

    g.SetAPen(rast,1);
    tt.Print(20,93,ac.GetString(ac.ExtremePoints),rast);
    g.SetAPen(rast,2);
    tt.Print(224,93,ac.GetString(ac.search),rast);
(*    ig.SetCheckBoxGadget(extremgad,wind,286,85,
                      SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
    ig.SetPlastProp(extremnachgad,SET{I.autoKnob,I.freeHoriz,I.knobHit},210,99,100,8,
                    0,4096,wind);*)
    tt.Print(20,106,ac.GetString(ac.DecimalPlaces),rast);
    tt.PrintInt(178,106,extremnach,2,rast);

    g.SetAPen(rast,1);
    tt.Print(20,120,ac.GetString(ac.PointsOfInflection),rast);
    g.SetAPen(rast,2);
    tt.Print(224,120,ac.GetString(ac.search),rast);
(*    ig.SetCheckBoxGadget(wendegad,wind,286,112,
                      SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
    ig.SetPlastProp(wendenachgad,SET{I.autoKnob,I.freeHoriz,I.knobHit},210,126,100,8,
                    0,4096,wind);*)
    tt.Print(20,133,ac.GetString(ac.DecimalPlaces),rast);
    tt.PrintInt(178,133,wendenach,2,rast);

    gm.SetSlider(ableitanzgad,wind,1,10,ableitanz);
    gm.SetSlider(nullnachgad,wind,1,8,nullnach);
    gm.SetSlider(extremnachgad,wind,1,8,extremnach);
    gm.SetSlider(wendenachgad,wind,1,8,wendenach);

(*    IF ableitung THEN
      gm.ActivateBool(ableitgad,wind);
    END;
    IF symmetrie THEN
      gm.ActivateBool(symmgad,wind);
    END;
    IF nullstellen THEN
      gm.ActivateBool(nullgad,wind);
    END;
    IF extrempunkte THEN
      gm.ActivateBool(extremgad,wind);
    END;
    IF wendepunkte THEN
      gm.ActivateBool(wendegad,wind);
    END;*)

    oldabl:=ableitung;
    oldsymm:=symmetrie;
    oldnull:=nullstellen;
    oldextrem:=extrempunkte;
    oldwende:=wendepunkte;
    oldablanz:=ableitanz;
    oldnullnach:=nullnach;
    oldextremnach:=extremnach;
    oldwendenach:=wendenach;

    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      old:=ableitanz;
      ableitanz:=gm.GetSlider(ableitanzgad,1,10);
      IF old#ableitanz THEN
        tt.PrintInt(178,39,ableitanz,2,rast);
      END;
      old:=nullnach;
      nullnach:=gm.GetSlider(nullnachgad,1,8);
      IF old#nullnach THEN
        tt.PrintInt(178,79,nullnach,2,rast);
      END;
      old:=extremnach;
      extremnach:=gm.GetSlider(extremnachgad,1,8);
      IF old#extremnach THEN
        tt.PrintInt(178,106,extremnach,2,rast);
      END;
      old:=wendenach;
      wendenach:=gm.GetSlider(wendenachgad,1,8);
      IF old#wendenach THEN
        tt.PrintInt(178,133,wendenach,2,rast);
      END;
      IF I.gadgetUp IN class THEN
        IF address=ok THEN
          EXIT;
        ELSIF address=ca THEN
          ableitung:=oldabl;
          symmetrie:=oldsymm;
          nullstellen:=oldnull;
          extrempunkte:=oldextrem;
          wendepunkte:=oldwende;
          ableitanz:=oldablanz;
          nullnach:=oldnullnach;
          extremnach:=oldextremnach;
          wendenach:=oldwendenach;
          EXIT;
        ELSIF address=ableitgad THEN
          ableitung:=NOT(ableitung);
        ELSIF address=symmgad THEN
          symmetrie:=NOT(symmetrie);
        ELSIF address=nullgad THEN
          nullstellen:=NOT(nullstellen);
        ELSIF address=extremgad THEN
          extrempunkte:=NOT(extrempunkte);
        ELSIF address=wendegad THEN
          wendepunkte:=NOT(wendepunkte);
        END;
      END;
      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"completesettings",wind);
      END;
    END;

(*    ig.FreePlastPropGadget(wendenachgad,wind);
    ig.FreePlastCheckBoxGadget(wendegad,wind);
    ig.FreePlastPropGadget(extremnachgad,wind);
    ig.FreePlastCheckBoxGadget(extremgad,wind);
    ig.FreePlastPropGadget(nullnachgad,wind);
    ig.FreePlastCheckBoxGadget(nullgad,wind);
    ig.FreePlastCheckBoxGadget(symmgad,wind);
    ig.FreePlastPropGadget(ableitanzgad,wind);
    ig.FreePlastCheckBoxGadget(ableitgad,wind);
    ig.FreePlastHighBooleanGadget(ca,wind);
    ig.FreePlastHighBooleanGadget(ok,wind);*)
    wm.CloseWindow(discussoptId);
  END;
  wm.FreeGadgets(discussoptId);
END KomplettEinstellungen;

BEGIN
  diskId:=-1;
  discussId:=-1;
  discussoptId:=-1;
  ableitung:=TRUE;
  symmetrie:=TRUE;
  nullstellen:=TRUE;
  extrempunkte:=TRUE;
  wendepunkte:=TRUE;
  ableitanz:=3;
  nullnach:=7;
  extremnach:=4;
  wendenach:=7;
END SuperCalcTools14.
