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


MODULE SuperCalcTools2;

IMPORT I  : Intuition,
       g  : Graphics,
       d  : Dos,
       e  : Exec,
       s  : SYSTEM,
       f  : Function,
       f1 : Function1,
       c  : Conversions,
       l  : LinkedLists,
       u  : Utility,
       gd : GadTools,
       pt : Pointers,
       it : IntuitionTools,
       tt : TextTools,
       gt : GraphicsTools,
       rt : RequesterTools,
       wm : WindowManager,
       gm : GadgetManager,
       mm : MenuManager,
       ac : AnalayCatalog,
       mt : MathTrans,
       lrc: LongRealConversions,
       st : Strings,
       r  : Requests,
       s1 : SuperCalcTools1,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- $StackChk- $ReturnChk- *)

VAR ok,bool     : BOOLEAN;
    code        : INTEGER;
    class       : LONGSET;
    address     : s.ADDRESS;
    a,j,i       : INTEGER;
    listId    * : INTEGER;
    plast       : ARRAY 1 OF INTEGER;
    vinfo       : gd.VisualInfo;


PROCEDURE TermDefined*(node:l.Node;x:LONGREAL):BOOLEAN;

VAR node2 : l.Node;
    ret,
    break : BOOLEAN;

BEGIN
  ret:=FALSE;
  break:=FALSE;
  node2:=node(s1.Term).define.head;
  IF node2=NIL THEN
    ret:=TRUE;
  END;
  WHILE node2#NIL DO
    WITH node2: s1.Define DO
      IF node2.type=0 THEN
        IF (x>node2.start) OR ((x>=node2.start) AND (node2.startequal)) THEN
          ret:=TRUE;
(*        ELSE
          break:=TRUE;*)
        END;
      ELSIF node2.type=1 THEN
        IF (x<node2.start) OR ((x<=node2.start) AND (node2.startequal)) THEN
          ret:=TRUE;
(*        ELSE
          break:=TRUE;*)
        END;
      ELSIF node2.type=2 THEN
        IF x=node2.start THEN
          break:=TRUE;
        ELSE
          ret:=TRUE;
        END;
      ELSIF node2.type=3 THEN
        IF x=node2.start THEN
          ret:=TRUE;
        END;
      ELSIF node2.type=10 THEN
        IF (node2.start<x) AND (x<node2.end) THEN
          ret:=TRUE;
        ELSIF ((node2.start=x) AND (node2.startequal)) OR ((node2.end=x) AND (node2.endequal)) THEN
          ret:=TRUE;
        END;
      END;
    END;
    node2:=node2.next;
  END;
  IF break THEN
    ret:=FALSE;
  END;
  RETURN ret;
END TermDefined;

PROCEDURE FunctionDefined*(node:l.Node;x:LONGREAL):BOOLEAN;

VAR node2 : l.Node;
    ret   : BOOLEAN;

BEGIN
  ret:=FALSE;
  node2:=node(s1.Function).terms.head;
  WHILE node2#NIL DO
    IF TermDefined(node2(s1.FuncTerm).term,x) THEN
      ret:=TRUE;
    END;
    node2:=node2.next;
  END;
  RETURN ret;
END FunctionDefined;

PROCEDURE GetFunctionTerm*(node:l.Node;x:LONGREAL):l.Node;

VAR node2,ret : l.Node;

BEGIN
  ret:=NIL;
  node2:=node(s1.Function).terms.head;
  WHILE node2#NIL DO
    IF TermDefined(node2(s1.FuncTerm).term,x) THEN
      ret:=node2(s1.FuncTerm).term;
    END;
    node2:=node2.next;
  END;
  RETURN ret;
END GetFunctionTerm;

PROCEDURE NotDefinedBetween(node:l.Node;x1,x2:LONGREAL):BOOLEAN;

VAR node2   : l.Node;
    ret,
    break   : BOOLEAN;
    x1d,x2d : LONGREAL;
    x1e,x2e : BOOLEAN;

BEGIN
  ret:=TRUE;
  break:=FALSE;
  x1d:=x1;
  x2d:=x2;
  x1e:=FALSE;
  x2e:=FALSE;
  node2:=node(s1.Term).define.head;
  WHILE node2#NIL DO
    WITH node2: s1.Define DO
      IF node2.type=0 THEN
        IF node2.start<=x2d THEN
          x2d:=node2.start;
          IF node2.startequal THEN
            x2e:=TRUE;
          END;
        END;
      ELSIF node2.type=1 THEN
        IF node2.start>=x1d THEN
          x1d:=node2.start;
          IF node2.startequal THEN
            x1e:=TRUE;
          END;
        END;
      ELSIF node2.type=2 THEN
        IF (x1<node2.start) AND (node2.start<x2) THEN
          break:=TRUE;
        END;
      ELSIF node2.type=10 THEN
      END;
    END;
    node2:=node2.next;
  END;
END NotDefinedBetween;

PROCEDURE GetFunctionValue*(node:l.Node;x,xstep:LONGREAL;VAR error:INTEGER):LONGREAL;

VAR node2 : l.Node;
    val   : LONGREAL;
    pos   : INTEGER;

BEGIN
  val:=0;
  node2:=GetFunctionTerm(node,x);
  IF node2#NIL THEN
    WITH node2: s1.Term DO
      IF node2.tree=NIL THEN
        pos:=0;
        node2.tree:=f.Parse(node2.string);
      END;
      pos:=0;
      val:=f.CalcLong(node2.tree,x,xstep,error);
    END;
    IF node(s1.Function).diffunc#NIL THEN
      val:=val-GetFunctionValue(node(s1.Function).diffunc,x,xstep,error);
    END;
  ELSE
    error:=3;
  END;
  RETURN val;
END GetFunctionValue;

PROCEDURE GetFunctionValueShort*(node:l.Node;x,xstep:REAL;VAR error:INTEGER):REAL;

VAR node2 : l.Node;
    val   : REAL;
    pos   : INTEGER;

BEGIN
  val:=0;
  node2:=GetFunctionTerm(node,x);
  IF node2#NIL THEN
    WITH node2: s1.Term DO
      IF node2.tree=NIL THEN
        pos:=0;
        node2.tree:=f.Parse(node2.string);
      END;
      pos:=0;
      error:=0;
(* $IF FPU *)
      val:=SHORT(f.CalcLong(node2.tree,x,xstep,error));
(* $ELSE *)
      val:=f.Calc(node2.tree,x,xstep,error);
(* $END *)
    END;
    IF node(s1.Function).diffunc#NIL THEN
      val:=val-GetFunctionValueShort(node(s1.Function).diffunc,x,xstep,error);
    END;
  ELSE
    error:=3;
  END;
  RETURN val;
END GetFunctionValueShort;

PROCEDURE CreateAllTrees*(node:l.Node);

VAR node2 : l.Node;
    pos   : INTEGER;

BEGIN
  WITH node: s1.Function DO
    node2:=node.terms.head;
    WHILE node2#NIL DO
      pos:=0;
      node2(s1.FuncTerm).term(s1.Term).tree:=f.Parse(node2(s1.FuncTerm).term(s1.Term).string);
      node2:=node2.next;
    END;
  END;
END CreateAllTrees;

PROCEDURE RemoveEmptyFunctions*;

VAR node,node2 : l.Node;

BEGIN
  node:=s1.functions.head;
  WHILE node#NIL DO
    node2:=node.next;
    IF node(s1.Function).terms.isEmpty() THEN
      node.Remove;
    END;
    node:=node2;
  END;
END RemoveEmptyFunctions;

PROCEDURE RefreshDepends*(node:l.Node);

VAR term,depend,depend2 : l.Node;
    bool                : BOOLEAN;

BEGIN
  WITH node: s1.Function DO
    node.depend.Init;
    term:=node.terms.head;
    WHILE term#NIL DO
      depend:=term(s1.FuncTerm).term(s1.Term).depend.head;
      WHILE depend#NIL DO
        bool:=TRUE;
        depend2:=node.depend.head;
        WHILE depend2#NIL DO
          IF depend2=depend THEN
            bool:=FALSE;
          END;
          depend2:=depend2.next;
        END;
        IF bool THEN
          NEW(depend2(s1.Depend));
          depend2(s1.Depend).var:=depend(s1.Depend).var;
          node.depend.AddTail(depend2);
        END;
        depend:=depend.next;
      END;
      term:=term.next;
    END;
  END;
END RefreshDepends;

PROCEDURE MakeDepend*(node:l.Node);

VAR str,str2 : POINTER TO ARRAY OF CHAR;
    node2,
    newnode  : l.Node;
    long     : LONGINT;
    root     : f1.NodePtr;

PROCEDURE CheckDepend(root:f1.NodePtr);

VAR node2 : l.Node;
    bool  : BOOLEAN;

BEGIN
  IF root#NIL THEN
    IF (root IS f1.TreeObj) AND (root(f1.TreeObj).object IS f1.Variable) THEN
      bool:=FALSE;
      node2:=node(s1.Term).depend.head;
      WHILE node2#NIL DO
        IF node2(s1.Depend).var=root(f1.TreeObj).object THEN
          bool:=TRUE;
        END;
        node2:=node2.next;
      END;
      IF NOT(bool) THEN
        newnode:=NIL;
        NEW(newnode(s1.Depend));
        newnode(s1.Depend).var:=root(f1.TreeObj).object;
        node(s1.Term).depend.AddTail(newnode);
      END;
    END;
    CheckDepend(root.left);
    CheckDepend(root.right);
    IF root IS f1.Operation THEN
      CheckDepend(root(f1.Operation).data);
      CheckDepend(root(f1.Operation).root);
    END;
  END;
END CheckDepend;

BEGIN
  WITH node: s1.Term DO
    node.depend.Init;
    root:=f.Parse(node.string);
    CheckDepend(root);
(*    NEW(str,st.Length(node.string)+1);
    COPY(node.string,str^);
    st.Upper(str^);
    node2:=f.objects.head;
    WHILE node2#NIL DO
      IF node2 IS f1.Variable THEN
        str2:=NIL;
        NEW(str2,st.Length(node2(f1.Variable).name^)+1);
        COPY(node2(f1.Variable).name^,str2^);
        st.Upper(str2^);
        long:=st.Occurs(str^,str2^);
        IF long#-1 THEN
          newnode:=NIL;
          NEW(newnode(s1.Depend));
          newnode(s1.Depend).var:=node2;
          node.depend.AddTail(newnode);
        END;
        node2:=node2.next;
      END;
    END;*)
  END;
END MakeDepend;

PROCEDURE AbleitFunction*(func:l.Node;ablstring:ARRAY OF CHAR):l.Node;

VAR node,node2 : l.Node;
    root       : f1.NodePtr;

BEGIN
  node:=NIL;
  IF func#NIL THEN
    WITH func: s1.Function DO
      NEW(node(s1.Function));
      WITH node: s1.Function DO
        COPY(ac.GetString(ac.DerivativeOf)^,node.name);
        st.AppendChar(node.name," ");
        st.Append(node.name,func.name);
        node.terms:=l.Create();
        s1.CopyList(func.terms,node.terms);
        node.define:=l.Create();
        s1.CopyList(func.define,node.define);
        node.depend:=l.Create();
        s1.CopyList(func.depend,node.depend);
        node.changed:=TRUE;
        node.isbase:=func.isbase;
        CreateAllTrees(node);
        node2:=node.terms.head;
        WHILE node2#NIL DO
          IF node2(s1.FuncTerm).term(s1.Term).basefunc=func THEN
            node2(s1.FuncTerm).term(s1.Term).basefunc:=node;
          END;
          f.Simplify(node2(s1.FuncTerm).term(s1.Term).tree);
          f.Derive(node2(s1.FuncTerm).term(s1.Term).tree,ablstring);
          f.Simplify(node2(s1.FuncTerm).term(s1.Term).tree);
          f.TreeToString(node2(s1.FuncTerm).term(s1.Term).tree,node2(s1.FuncTerm).term(s1.Term).string);
          MakeDepend(node2);
          node2:=node2.next;
        END;
      END;
    END;
  END;
  RETURN node;
END AbleitFunction;

PROCEDURE LockFunction*(func:l.Node);

VAR node : l.Node;
    root : f1.NodePtr;

BEGIN
  node:=func(s1.Function).terms.head;
  WHILE node#NIL DO
    f.LockTree(node(s1.FuncTerm).term(s1.Term).tree);
    node:=node.next;
  END;
END LockFunction;

PROCEDURE UnLockFunction*(func:l.Node);

VAR node : l.Node;
    root : f1.NodePtr;

BEGIN
  node:=func(s1.Function).terms.head;
  WHILE node#NIL DO
    f.UnLockTree(node(s1.FuncTerm).term(s1.Term).tree);
    node:=node.next;
  END;
END UnLockFunction;

PROCEDURE * PrintTerm*(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=s1.GetNode(s1.terms,num);
  IF node#NIL THEN
    WITH node: s1.Term DO
      NEW(str);
      COPY(node.string,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintTerm;

PROCEDURE * PrintVar*(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;
    i    : INTEGER;

BEGIN
  node:=f.objects.head;
  i:=-1;
  LOOP
    IF node=NIL THEN
      EXIT;
    END;
    IF node IS f1.Variable THEN
      INC(i);
    END;
    IF i=num THEN
      EXIT;
    END;
    node:=node.next;
  END;
(*  node:=s1.GetNode(s1.variables,num);*)
  IF node#NIL THEN
    WITH node: f1.Variable DO
      NEW(str);
      COPY(node.string,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintVar;

PROCEDURE * PrintFunction*(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=s1.GetNode(s1.functions,num);
  IF node#NIL THEN
    WITH node: s1.Function DO
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintFunction;

PROCEDURE * PrintWindow*(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=s1.GetNode(s1.fenster,num);
  IF node#NIL THEN
    WITH node: s1.Fenster DO
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintWindow;

PROCEDURE * PrintWindowFunction*(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  IF datalist#NIL THEN
    node:=s1.GetNode(datalist,num);
    IF node#NIL THEN
      WITH node: s1.FensterFunc DO
        NEW(str);
        COPY(node.func(s1.Function).name,str^);
        tt.CutStringToLength(rast,str^,width);
        tt.Print(x,y,str,rast);
        DISPOSE(str);
      END;
    END;
  END;
END PrintWindowFunction;

PROCEDURE * PrintNotBaseFunction*(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;
    i    : INTEGER;

BEGIN
(*  node:=s1.functions.head;
  i:=0;
  WHILE (node#NIL) AND (i<num) DO
    IF NOT(node(s1.Function).isbase) THEN
      INC(i);
    END;
    node:=node.next;
  END;*)
  node:=s1.GetFuncNode(s1.functions,num);
  IF node#NIL THEN
    WITH node: s1.Function DO
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintNotBaseFunction;

PROCEDURE * PrintLegend*(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=s1.GetNode(s1.legends,num);
  IF node#NIL THEN
    WITH node: s1.Legend DO
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintLegend;

PROCEDURE * PrintTable*(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=s1.GetNode(s1.tables,num);
  IF node#NIL THEN
    WITH node: s1.Table DO
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintTable;

PROCEDURE * PrintList*(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=s1.GetNode(s1.lists,num);
  IF node#NIL THEN
    WITH node: s1.List DO
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintList;

PROCEDURE * PrintArea*(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=s1.GetNode(datalist,num);
  IF node#NIL THEN
    WITH node: s1.Area DO
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintArea;

PROCEDURE * PrintDepend*(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=s1.GetNode(datalist,num);
  IF node#NIL THEN
    WITH node: s1.Depend DO
      NEW(str);
      COPY(node.var(f1.Variable).name^,str^);
      st.AppendChar(str^,"=");
      st.Append(str^,node.var(f1.Variable).comment^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintDepend;

PROCEDURE SelectNode*(list:l.List;title,elname,elnamep:e.STRPTR):l.Node;

VAR wind     : I.WindowPtr;
    rast     : g.RastPortPtr;
    ok,ca,
    strgad   : I.GadgetPtr;
    listview,
    node,
    actel,
    oldel    : l.Node;
    string   : ARRAY 80 OF CHAR;
    proc     : gm.PrintProc;
    i,x,y,dy : INTEGER;
    sec1,mic1,
    sec2,mic2: LONGINT;
    dovar    : BOOLEAN;

PROCEDURE NewWindowSize;

BEGIN
  gm.SetListViewParams(listview,20,28,wind.width-54,wind.height-55-dy,SHORT(list.nbElements()),s1.GetNodeNumber(list,actel),proc);
  gm.SetCorrectPosition(listview);
  I.RefreshGList(listview(gm.ListView).scroll,wind,NIL,1);

  g.SetAPen(rast,0);
  g.RectFill(rast,4,11,wind.width-19,wind.height-3);
  it.DrawBevelBorder(rast,14,16,wind.width-42,wind.height-40);
  IF dovar THEN
    I.RefreshGList(ok,wind,NIL,3);
  ELSE
    I.RefreshGList(ok,wind,NIL,2);
  END;

  g.SetAPen(rast,2);
  tt.Print(20,25,s.ADR(string),rast);

  gm.RefreshListView(listview);
  I.RefreshWindowFrame(wind);
  IF dovar THEN
    bool:=I.ActivateGadget(strgad^,wind,NIL);
  END;
END NewWindowSize;

BEGIN
  actel:=NIL;
  IF (list.nbElements()=1) AND (s1.quickselect) AND NOT (list.head IS s1.Depend) THEN
    actel:=list.head;
  ELSIF NOT(list.isEmpty()) THEN
    actel:=NIL;
    node:=list.head;
    IF (s1.autoactive) AND ((node IS s1.Fenster) OR (node IS s1.Legend) OR (node IS s1.Table) OR (node IS s1.List)) THEN
      WHILE node#NIL DO
        IF node IS s1.Fenster THEN
          wind:=node(s1.Fenster).wind;
        ELSIF node IS s1.Legend THEN
          wind:=node(s1.Legend).wind;
        ELSIF node IS s1.Table THEN
          wind:=node(s1.Table).wind;
        ELSIF node IS s1.List THEN
          wind:=node(s1.List).wind;
        END;
        IF wind#NIL THEN
          IF I.windowActive IN wind.flags THEN
            actel:=node;
            node:=NIL;
          END;
        END;
        IF node#NIL THEN
          node:=node.next;
        END;
      END;
    END;
    IF actel=NIL THEN
      IF list.head IS s1.Depend THEN
        dy:=14;
        dovar:=TRUE;
      ELSE
        dy:=0;
        dovar:=FALSE;
      END;
      IF listId=-1 THEN
        listId:=wm.InitWindow(100,10,280,159,title,LONGSET{I.activate,I.windowDrag,I.windowDepth,I.windowSizing,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.intuiTicks,I.newSize,I.mouseMove},s1.screen,FALSE);
        wm.SetMinMax(listId,248,99,-1,-1);
      END;
      wm.ChangeTitle(listId,title);
      gm.StartGadgets(s1.window);
      ok:=gm.SetBooleanGadget(14,-20,100,14,ac.GetString(ac.OK));
      INCL(ok.flags,I.gRelBottom);
      ca:=gm.SetBooleanGadget(-127,-20,100,14,ac.GetString(ac.Cancel));
      INCL(ca.flags,I.gRelBottom);
      INCL(ca.flags,I.gRelRight);
      listview:=gm.SetListView(20,28,340,84,0,0,PrintTerm);
      IF dovar THEN
        strgad:=gm.SetStringGadget(20,-40,176,14,40);
      INCL(strgad.flags,I.gRelBottom);
      END;
      gm.EndGadgets;
      wm.SetGadgets(listId,ok);
      wm.ChangeScreen(listId,s1.screen);
      wind:=wm.OpenWindow(listId);
      IF wind#NIL THEN
        rast:=wind.rPort;
        g.SetDrMd(rast,g.jam1);
    
        g.SetAPen(rast,2);
        string:="";
        i:=0;
        WHILE (title[i]#" ") AND (title[i]#0X) DO
          string[i]:=title[i];
          INC(i);
        END;
        string[i+1]:=0X;
        tt.Print(20,25,s.ADR(string),rast);
    
        gm.SetCorrectWindow(listview,wind);
  (*      COPY(elnamep,string);
        st.AppendChar(string,"!");
        gm.SetNoEntryText(listview,"Keine",string);*)
  
        gm.SetDataList(listview,list);
  
        actel:=list.head;
        IF actel IS s1.Term THEN
          proc:=PrintTerm;
        ELSIF actel IS s1.Function THEN
          proc:=PrintFunction;
        ELSIF actel IS s1.Fenster THEN
          proc:=PrintWindow;
        ELSIF actel IS s1.FensterFunc THEN
          proc:=PrintWindowFunction;
        ELSIF actel IS s1.Legend THEN
          proc:=PrintLegend;
        ELSIF actel IS s1.Table THEN
          proc:=PrintTable;
        ELSIF actel IS s1.List THEN
          proc:=PrintList;
        ELSIF actel IS s1.Area THEN
          proc:=PrintArea;
        ELSIF actel IS s1.Depend THEN
          proc:=PrintDepend;
          WHILE actel#NIL DO
            node:=actel(s1.Depend).var;
            NEW(node(f1.Variable).comment,80);
            bool:=lrc.RealToString(node(f1.Variable).real,node(f1.Variable).comment^,7,7,FALSE);
            tt.Clear(node(f1.Variable).comment^);
            actel:=actel.next;
          END;
          actel:=list.head;
          gm.PutGadgetText(strgad,actel(s1.Depend).var(f1.Variable).comment^);
          I.RefreshGList(strgad,wind,NIL,1);
        ELSE
          proc:=PrintTerm;
        END;
    
        NewWindowSize;
  
        sec2:=0;
        mic2:=0;
        LOOP
          e.WaitPort(wind.userPort);
          it.GetIMes(wind,class,code,address);
          IF I.gadgetUp IN class THEN
            IF address=ok THEN
              IF dovar THEN
                gm.GetGadgetText(strgad,actel(s1.Depend).var(f1.Variable).comment^);
                actel:=list.head;
                WHILE actel#NIL DO
                  node:=actel(s1.Depend).var;
                  node(f1.Variable).real:=f.ExpressionToReal(node(f1.Variable).comment^);
                  node(f1.Variable).comment:=NIL;
                  actel:=actel.next;
                END;
                actel:=list.head;
              END;
              EXIT;
            ELSIF address=ca THEN
              actel:=NIL;
              EXIT;
            ELSIF address=strgad THEN
              IF dovar THEN
                gm.GetGadgetText(strgad,actel(s1.Depend).var(f1.Variable).comment^);
                IF actel.next#NIL THEN
                  actel:=actel.next;
                END;
                gm.SetListViewParams(listview,20,28,wind.width-54,wind.height-55-dy,SHORT(list.nbElements()),s1.GetNodeNumber(list,actel),proc);
                gm.SetCorrectPosition(listview);
                gm.RefreshListView(listview);
                gm.PutGadgetText(strgad,actel(s1.Depend).var(f1.Variable).comment^);
                I.RefreshGList(strgad,wind,NIL,1);
                bool:=I.ActivateGadget(strgad^,wind,NIL);
              END;
            END;
          ELSIF I.mouseButtons IN class THEN
            it.GetMousePos(wind,x,y);
            IF (x>=20) AND (x<=2+wind.width-53) AND (y>=28) AND (y<=26+wind.height-54) THEN
              IF dovar THEN
                gm.GetGadgetText(strgad,actel(s1.Depend).var(f1.Variable).comment^);
              END;
              oldel:=actel;
              bool:=gm.CheckListView(listview,class,code,address);
              IF bool THEN
                actel:=s1.GetNode(list,gm.ActEl(listview));
                IF dovar THEN
                  gm.PutGadgetText(strgad,actel(s1.Depend).var(f1.Variable).comment^);
                  I.RefreshGList(strgad,wind,NIL,1);
                  bool:=I.ActivateGadget(strgad^,wind,NIL);
                END;
              END;
              IF oldel=actel THEN
                sec1:=sec2;
                mic1:=mic2;
                I.CurrentTime(sec2,mic2);
                IF (I.DoubleClick(sec1,mic1,sec2,mic2)) AND NOT(dovar) THEN
                  EXIT;
                END;
              ELSE
                I.CurrentTime(sec2,mic2);
              END;
            END;
          ELSIF I.newSize IN class THEN
            NewWindowSize;
          END;
          bool:=gm.CheckListView(listview,class,code,address);
          IF bool THEN
            actel:=s1.GetNode(list,gm.ActEl(listview));
          END;
        END;
    
        wm.CloseWindow(listId);
      END;
      wm.FreeGadgets(listId);
      gm.FreeListView(listview);
    END;
  ELSE
(*    COPY(elnamep,string);
    st.Append(string," vorhanden!");*)
    bool:=rt.RequestWin(elname,elnamep,s.ADR(""),ac.GetString(ac.OK),s1.window);
  END;
  RETURN actel;
END SelectNode;

PROCEDURE SnapToFunktion*(p:l.Node;VAR x,y:LONGREAL);

VAR root : f1.NodePtr;
    node,
    node2: l.Node;
    list : l.List;
    pos  : INTEGER;
    dist : LONGREAL;

PROCEDURE CheckGraphs(func,node:l.Node);

VAR node2,node3 : l.Node;

BEGIN
  node2:=node(s1.Depend).var;
  WITH node2: f1.Variable DO
    node2.real:=node2.startx;
    LOOP
      IF node.next#NIL THEN
        CheckGraphs(func,node.next);
      ELSE
        NEW(node3(s1.Value));
        pos:=0;
        node3(s1.Value).real:=GetFunctionValue(func,x,0,pos);
        IF pos=0 THEN
          node3(s1.Value).defined:=TRUE;
        ELSE
          node3(s1.Value).defined:=FALSE;
        END;
        list.AddTail(node3);
      END;
      node2.real:=node2.real+node2.stepx;
      IF node2.stepx>0 THEN
        IF node2.real>node2.endx THEN
          EXIT;
        END;
      ELSIF node2.stepx<0 THEN
        IF node2.real<node2.endx THEN
          EXIT;
        END;
      ELSE
        EXIT;
      END;
    END;
  END;
END CheckGraphs;

BEGIN
  list:=l.Create();
  WITH p: s1.Fenster DO
    node:=p.funcs.head;
    WHILE node#NIL DO
(*      pos:=0;
      root:=f.Parse(node(FensterFunc).(Term).string,pos);*)
      IF node(s1.FensterFunc).func(s1.Function).depend.isEmpty() THEN
        NEW(node2(s1.Value));
        pos:=0;
        node2(s1.Value).real:=GetFunctionValue(node(s1.FensterFunc).func,x,0,pos);
        IF pos=0 THEN
          node2(s1.Value).defined:=TRUE;
        ELSE
          node2(s1.Value).defined:=FALSE;
        END;
        list.AddTail(node2);
      ELSE
        CheckGraphs(node(s1.FensterFunc).func,node(s1.FensterFunc).func(s1.Function).depend.head);
      END;
      node:=node.next;
    END;
    dist:=1000000;
    node2:=NIL;
    node:=list.head;
    WHILE node#NIL DO
      IF (ABS(node(s1.Value).real-y)<dist) AND (node(s1.Value).defined) THEN
        dist:=ABS(node(s1.Value).real-y);
        node2:=node;
      END;
      node:=node.next;
    END;
    IF node2#NIL THEN
      y:=node2(s1.Value).real;
    END;
  END;
END SnapToFunktion;

PROCEDURE RefreshGridData*(node:s1.GitterPtr);

BEGIN
  IF node#NIL THEN
    node.xspace:=f.ExpressionToReal(node.xspaces);
    node.yspace:=f.ExpressionToReal(node.yspaces);
    node.xstart:=f.ExpressionToReal(node.xstarts);
    node.ystart:=f.ExpressionToReal(node.ystarts);
  END;
END RefreshGridData;

PROCEDURE RefreshScaleData*(node:s1.SkalaPtr);

BEGIN
  IF node#NIL THEN
    node.numsx:=f.ExpressionToReal(node.numsxs);
    node.numsy:=f.ExpressionToReal(node.numsys);
    node.mark1x:=f.ExpressionToReal(node.mark1xs);
    node.mark1y:=f.ExpressionToReal(node.mark1ys);
    node.mark2x:=f.ExpressionToReal(node.mark2xs);
    node.mark2y:=f.ExpressionToReal(node.mark2ys);
  END;
END RefreshScaleData;

PROCEDURE RefreshWindowData*(node:l.Node);

BEGIN
  IF node#NIL THEN
    WITH node: s1.Fenster DO
      node.xmin:=SHORT(f.ExpressionToReal(node.xmins));
      node.xmax:=SHORT(f.ExpressionToReal(node.xmaxs));
      node.ymin:=SHORT(f.ExpressionToReal(node.ymins));
      node.ymax:=SHORT(f.ExpressionToReal(node.ymaxs));
      node.oldxmin:=SHORT(f.ExpressionToReal(node.oldxmins));
      node.oldxmax:=SHORT(f.ExpressionToReal(node.oldxmaxs));
      node.oldymin:=SHORT(f.ExpressionToReal(node.oldymins));
      node.oldymax:=SHORT(f.ExpressionToReal(node.oldymaxs));
      RefreshGridData(s.ADR(node.grid1));
      RefreshGridData(s.ADR(node.grid2));
      RefreshScaleData(s.ADR(node.scale));
    END;
  END;
END RefreshWindowData;

PROCEDURE RefreshCoordData*(p,node:l.Node);

VAR longx,longy : LONGREAL;

BEGIN
  IF node#NIL THEN
    WITH node: s1.Coord DO
      longx:=f.ExpressionToReal(node.xkstr);
      longy:=f.ExpressionToReal(node.ykstr);
      IF node.welt THEN
        node.weltx:=longx;
        node.welty:=longy;
      ELSE
        node.picx:=SHORT(SHORT(SHORT(longx)));
        node.picy:=SHORT(SHORT(SHORT(longy)));
      END;
      s1.RefreshOtherCoord(p,node);
    END;
  END;
END RefreshCoordData;

PROCEDURE RefreshAreaDim*(node:l.Node);

BEGIN
  IF node#NIL THEN
    WITH node: s1.AreaDim DO
      node.xcoord:=f.ExpressionToReal(node.xcoords);
      node.ycoord:=f.ExpressionToReal(node.ycoords);
    END;
  END;
END RefreshAreaDim;

PROCEDURE RefreshArea*(node:l.Node);

VAR node2 : l.Node;

BEGIN
  IF node#NIL THEN
    WITH node: s1.Area DO
      node2:=node.dims.head;
      WHILE node2#NIL DO
        RefreshAreaDim(node2);
        node2:=node2.next;
      END;
    END;
  END;
END RefreshArea;

PROCEDURE SetAllPointers*(busy:BOOLEAN);

VAR node : l.Node;

PROCEDURE SetPointer(wind:I.WindowPtr);

BEGIN
  IF busy THEN
    pt.SetBusyPointer(wind);
  ELSE
    pt.ClearPointer(wind);
  END;
END SetPointer;

BEGIN
  SetPointer(s1.window);
  node:=s1.fenster.head;
  WHILE node#NIL DO
    SetPointer(node(s1.Fenster).wind);
    node:=node.next;
  END;
  node:=s1.legends.head;
  WHILE node#NIL DO
    SetPointer(node(s1.Legend).wind);
    node:=node.next;
  END;
  node:=s1.tables.head;
  WHILE node#NIL DO
    SetPointer(node(s1.Table).wind);
    node:=node.next;
  END;
  node:=s1.lists.head;
  WHILE node#NIL DO
    SetPointer(node(s1.List).wind);
    node:=node.next;
  END;
END SetAllPointers;

PROCEDURE AutoFuncScale*(node:l.Node);

VAR node2,node3 : l.Node;
    min,max     : REAL;

PROCEDURE MinMaxSub(VAR min,max:REAL;subnode:l.Node);

VAR real : REAL;
    i    : INTEGER;

BEGIN
  FOR i:=0 TO SHORT(LEN(subnode(s1.FunctionGraph).table^)-1) DO
    real:=subnode(s1.FunctionGraph).table[i].real;
    IF real>max THEN
      max:=real;
    END;
    IF real<min THEN
      min:=real;
    END;
  END;
END MinMaxSub;

BEGIN
  min:=0;
  max:=0;
  node2:=node(s1.Fenster).funcs.head;
  WHILE node2#NIL DO
    node3:=node2(s1.FensterFunc).graphs.head;
    WHILE node3#NIL DO
      MinMaxSub(min,max,node3);
      node3:=node3.next;
    END;
    node2:=node2.next;
  END;
  IF (node(s1.Fenster).ymin#min) OR (node(s1.Fenster).ymax#max) THEN
    node(s1.Fenster).ymin:=min;
    node(s1.Fenster).ymax:=max;
    bool:=lrc.RealToString(min,node(s1.Fenster).ymins,7,7,FALSE);
    tt.Clear(node(s1.Fenster).ymins);
    bool:=lrc.RealToString(max,node(s1.Fenster).ymaxs,7,7,FALSE);
    tt.Clear(node(s1.Fenster).ymaxs);
    node(s1.Fenster).refresh:=TRUE;
  END;
END AutoFuncScale;

PROCEDURE AutoSkalaScale*(node:l.Node);

VAR max : INTEGER;
    numsx,
    numsy,
    marksx,
    marksy,
    hervx,
    hervy,
    real : REAL;
    str  : ARRAY 20 OF CHAR;
    bool : BOOLEAN;
    i    : INTEGER;
    font : g.TextFontPtr;
    mask,
    style: SHORTSET;

PROCEDURE CheckSchneid(nums:LONGREAL):BOOLEAN;

VAR ret   : BOOLEAN;
    r     : LONGREAL;
    px,py,
    gx,gy : INTEGER;
    wi,
    maxwi : INTEGER;
    str   : ARRAY 20 OF CHAR;
    bool  : BOOLEAN;
    lpx,
    dist  : REAL;

BEGIN
  ret:=FALSE;
  maxwi:=0;
  r:=node(s1.Fenster).xmax-2*nums;
  lpx:=0;
  dist:=0;
  r:=r-nums;
  WHILE r<=node(s1.Fenster).xmax-nums DO
    r:=r+nums;
(*    IF r>node(s1.Fenster).xmax-3*nums THEN*)
      lpx:=px;
(*      WeltToPic(SHORT(r),0,px,py,node(Fenster).xmin,node(Fenster).xmax,node(Fenster).ymin,node(Fenster).ymax,node(Fenster).width,node(Fenster).height);*)
      s1.WorldToPic(r,0,px,py,node);
(*      px:=px+node(Fenster).inx;*)
      dist:=px-lpx;
      IF NOT((r>node(s1.Fenster).xmax-node(s1.Fenster).scale.numsx) AND node(s1.Fenster).scale.xbezon) THEN
        bool:=lrc.RealToString(r,str,7,4,FALSE);
        tt.Clear(str);
        wi:=g.TextLength(node(s1.Fenster).rast,str,st.Length(str));
        IF wi>maxwi THEN
          maxwi:=wi;
          IF maxwi>=dist THEN
            r:=node(s1.Fenster).xmax;
          END;
        END;
      END;
(*    END;*)
  END;
  r:=node(s1.Fenster).xmin+2*nums;
  r:=r+nums;
  WHILE r>=node(s1.Fenster).xmin+nums DO
    r:=r-nums;
(*    IF r<node(Fenster).xmin+3*nums THEN*)
(*      WeltToPic(SHORT(r),0,px,py,node(Fenster).xmin,node(Fenster).xmax,node(Fenster).ymin,node(Fenster).ymax,node(Fenster).width,node(Fenster).height);*)
      s1.WorldToPic(r,0,px,py,node);
(*      px:=px+node(Fenster).inx;*)
      bool:=lrc.RealToString(r,str,7,4,FALSE);
      tt.Clear(str);
      wi:=g.TextLength(node(s1.Fenster).rast,str,st.Length(str));
      IF wi>maxwi THEN
        maxwi:=wi;
        IF maxwi>=dist THEN
          r:=node(s1.Fenster).xmin;
        END;
      END;
(*    END;*)
  END;
  IF dist<=maxwi THEN
    ret:=TRUE;
  END;
  RETURN ret;
END CheckSchneid;

BEGIN
  font:=gt.SetFont(node(s1.Fenster).wind.rPort,s.ADR(node(s1.Fenster).scale.attr));
  mask:=g.AskSoftStyle(node(s1.Fenster).wind.rPort);
  style:=g.SetSoftStyle(node(s1.Fenster).wind.rPort,node(s1.Fenster).scale.attr.style,mask);
(*  real:=0.5;
  IF ABS(node(Fenster).xmin)+ABS(node(Fenster).xmax)<2 THEN
    real:=real/8;
  END;
  WHILE CheckSchneid(real) DO
    real:=real*2;
  END;*)
  i:=-1;
  LOOP
    INC(i);
    IF i>28 THEN
      i:=28;
      EXIT;
    END;
    IF NOT(CheckSchneid(s1.auto[i])) THEN
      EXIT;
    END;
  END;
  node(s1.Fenster).scale.numsx:=s1.auto[i];
  IF node(s1.Fenster).scale.mark1on THEN
    node(s1.Fenster).scale.mark1x:=s1.auto[i]/2;
  END;
  IF node(s1.Fenster).scale.mark2on THEN
    node(s1.Fenster).scale.mark2x:=s1.auto[i]/4;
  END;
(*  real:=0.5;
  IF ABS(node(Fenster).ymin)+ABS(node(Fenster).ymax)<2 THEN
    real:=real/2;
  END;
  WHILE node(Fenster).height/(ABS(node(Fenster).ymin)+ABS(node(Fenster).ymax)/real)<10 DO
    real:=real*2;
  END;*)
  real:=node(s1.Fenster).height/(ABS(node(s1.Fenster).ymin)+ABS(node(s1.Fenster).ymax));
  i:=-1;
  LOOP
    INC(i);
    IF i>28 THEN
      i:=28;
      EXIT;
    END;
    IF real*s1.auto[i]>=node(s1.Fenster).rast.txHeight+2 THEN
      EXIT;
    END;
  END;
  node(s1.Fenster).scale.numsy:=s1.auto[i];
  bool:=lrc.RealToString(node(s1.Fenster).scale.numsx,node(s1.Fenster).scale.numsxs,7,7,FALSE);
  tt.Clear(node(s1.Fenster).scale.numsxs);
  bool:=lrc.RealToString(node(s1.Fenster).scale.numsy,node(s1.Fenster).scale.numsys,7,7,FALSE);
  tt.Clear(node(s1.Fenster).scale.numsys);
  IF node(s1.Fenster).scale.mark1on THEN
    node(s1.Fenster).scale.mark1y:=s1.auto[i]/2;
    bool:=lrc.RealToString(node(s1.Fenster).scale.mark1x,node(s1.Fenster).scale.mark1xs,7,7,FALSE);
    tt.Clear(node(s1.Fenster).scale.mark1xs);
    bool:=lrc.RealToString(node(s1.Fenster).scale.mark1y,node(s1.Fenster).scale.mark1ys,7,7,FALSE);
    tt.Clear(node(s1.Fenster).scale.mark1ys);
  END;
  IF node(s1.Fenster).scale.mark2on THEN
    node(s1.Fenster).scale.mark2y:=s1.auto[i]/4;
    bool:=lrc.RealToString(node(s1.Fenster).scale.mark2x,node(s1.Fenster).scale.mark2xs,7,7,FALSE);
    tt.Clear(node(s1.Fenster).scale.mark2xs);
    bool:=lrc.RealToString(node(s1.Fenster).scale.mark2y,node(s1.Fenster).scale.mark2ys,7,7,FALSE);
    tt.Clear(node(s1.Fenster).scale.mark2ys);
  END;
  node(s1.Fenster).refresh:=TRUE;
  mask:=g.AskSoftStyle(node(s1.Fenster).wind.rPort);
  style:=g.SetSoftStyle(node(s1.Fenster).wind.rPort,SHORTSET{},mask);
  gt.CloseFont(font);
END AutoSkalaScale;

PROCEDURE AutoGridScale*(node:l.Node);

BEGIN
  IF node(s1.Fenster).grid1.on THEN
    node(s1.Fenster).grid1.xspace:=node(s1.Fenster).scale.numsx;
    node(s1.Fenster).grid1.yspace:=node(s1.Fenster).scale.numsy;
    node(s1.Fenster).grid1.xstart:=0;
    node(s1.Fenster).grid1.ystart:=0;
    bool:=lrc.RealToString(node(s1.Fenster).grid1.xspace,node(s1.Fenster).grid1.xspaces,7,7,FALSE);
    tt.Clear(node(s1.Fenster).grid1.xspaces);
    bool:=lrc.RealToString(node(s1.Fenster).grid1.yspace,node(s1.Fenster).grid1.yspaces,7,7,FALSE);
    tt.Clear(node(s1.Fenster).grid1.yspaces);
    bool:=lrc.RealToString(node(s1.Fenster).grid1.xstart,node(s1.Fenster).grid1.xstarts,7,7,FALSE);
    tt.Clear(node(s1.Fenster).grid1.xstarts);
    bool:=lrc.RealToString(node(s1.Fenster).grid1.ystart,node(s1.Fenster).grid1.ystarts,7,7,FALSE);
    tt.Clear(node(s1.Fenster).grid1.ystarts);
  END;
  IF node(s1.Fenster).grid2.on THEN
    node(s1.Fenster).grid2.xstart:=node(s1.Fenster).grid1.xspace/2;
    node(s1.Fenster).grid2.ystart:=node(s1.Fenster).grid1.yspace/2;
(*    node(Fenster).grid1.xspace:=node(Fenster).grid1.xspace*2;
    node(Fenster).grid1.yspace:=node(Fenster).grid1.yspace*2;*)
    node(s1.Fenster).grid2.xspace:=node(s1.Fenster).grid1.xspace;
    node(s1.Fenster).grid2.yspace:=node(s1.Fenster).grid1.yspace;
    bool:=lrc.RealToString(node(s1.Fenster).grid2.xspace,node(s1.Fenster).grid2.xspaces,7,7,FALSE);
    tt.Clear(node(s1.Fenster).grid2.xspaces);
    bool:=lrc.RealToString(node(s1.Fenster).grid2.yspace,node(s1.Fenster).grid2.yspaces,7,7,FALSE);
    tt.Clear(node(s1.Fenster).grid2.yspaces);
    bool:=lrc.RealToString(node(s1.Fenster).grid2.xstart,node(s1.Fenster).grid2.xstarts,7,7,FALSE);
    tt.Clear(node(s1.Fenster).grid2.xstarts);
    bool:=lrc.RealToString(node(s1.Fenster).grid2.ystart,node(s1.Fenster).grid2.ystarts,7,7,FALSE);
    tt.Clear(node(s1.Fenster).grid2.ystarts);
  END;
END AutoGridScale;

PROCEDURE Auto*(p:l.Node);

BEGIN
  SetAllPointers(TRUE);
  WITH p: s1.Fenster DO
    IF p.autofuncscale THEN
      AutoFuncScale(p);
    END;
    IF p.autoskalascale THEN
      AutoSkalaScale(p);
    END;
    IF p.autogridscale THEN
      AutoGridScale(p);
    END;
  END;
  SetAllPointers(FALSE);
END Auto;

PROCEDURE ResizeWindow*(p:l.Node);

BEGIN
  IF p IS s1.Fenster THEN
    WITH p: s1.Fenster DO
      p.xpos:=p.wind.leftEdge;
      p.ypos:=p.wind.topEdge;
      IF p.freeborder THEN
        p.inx:=4;
        p.iny:=11;
        p.width:=p.wind.width-23;
        p.height:=p.wind.height-14;
      ELSE
        p.inx:=0;
        p.iny:=0;
        p.width:=p.wind.width-1;
        p.height:=p.wind.height-1;
      END;
    END;
    Auto(p);
  ELSIF p IS s1.Legend THEN
    WITH p: s1.Legend DO
      p.xpos:=p.wind.leftEdge;
      p.ypos:=p.wind.topEdge;
      p.width:=p.wind.width;
      p.height:=p.wind.height;
    END;
  ELSIF p IS s1.List THEN
    WITH p: s1.List DO
      p.xpos:=p.wind.leftEdge;
      p.ypos:=p.wind.topEdge;
      p.width:=p.wind.width;
      p.height:=p.wind.height;
    END;
  ELSIF p IS s1.Table THEN
    WITH p: s1.Table DO
      p.xpos:=p.wind.leftEdge;
      p.ypos:=p.wind.topEdge;
      p.width:=p.wind.width;
      p.height:=p.wind.height;
    END;
  END;
END ResizeWindow;

PROCEDURE GetWindowSizes*;

VAR node : l.Node;

BEGIN
  node:=s1.fenster.head;
  WHILE node#NIL DO
    WITH node: s1.Fenster DO
      IF node.wind#NIL THEN
        WITH node: s1.Fenster DO
          node.xpos:=node.wind.leftEdge;
          node.ypos:=node.wind.topEdge;
          IF node.freeborder THEN
            node.inx:=4;
            node.iny:=11;
            node.width:=node.wind.width-23;
            node.height:=node.wind.height-14;
          ELSE
            node.inx:=0;
            node.iny:=0;
            node.width:=node.wind.width-1;
            node.height:=node.wind.height-1;
          END;
        END;
(*        ResizeWindow(node);*)
      END;
    END;
    node:=node.next;
  END;

  node:=s1.legends.head;
  WHILE node#NIL DO
    WITH node: s1.Legend DO
      IF node.wind#NIL THEN
        ResizeWindow(node);
      END;
    END;
    node:=node.next;
  END;

  node:=s1.tables.head;
  WHILE node#NIL DO
    WITH node: s1.Table DO
      IF node.wind#NIL THEN
        ResizeWindow(node);
      END;
    END;
    node:=node.next;
  END;

  node:=s1.lists.head;
  WHILE node#NIL DO
    WITH node: s1.List DO
      IF node.wind#NIL THEN
        ResizeWindow(node);
      END;
    END;
    node:=node.next;
  END;
END GetWindowSizes;

PROCEDURE IntToRGB*(i:LONGINT):LONGINT;

VAR set : LONGSET;

BEGIN
  set:=s.VAL(LONGSET,i);
  RETURN s.VAL(LONGINT,s.LSH(set,24));
END IntToRGB;

PROCEDURE RGBToInt*(rgb:LONGINT):INTEGER;

VAR set : LONGSET;

BEGIN
  set:=s.VAL(LONGSET,rgb);
  RETURN SHORT(s.VAL(LONGINT,s.LSH(set,-24)));
END RGBToInt;

PROCEDURE Init*;

VAR new             : I.ExtNewScreen;
    long            : LONGINT;
    rgb             : ARRAY 3 OF LONGINT;
    set             : SET;
    col,width,height: INTEGER;
    usewbscreenitem,
    quickselectitem,
    autoactiveitem  : I.MenuItemPtr;

BEGIN
  plast[0]:=-1;
(*  IF s1.os<36 THEN
    s1.screen:=it.SetScreen(SHORT(s1.scr.width),SHORT(s1.scr.height),s1.scr.depth,s.ADR("Analay V0.95 © 1991-1994 Marc Necker"),s1.scr.ntsc,TRUE(*s1.over*),FALSE(*s1.a4*));
  ELSE*)
    IF s1.usewbscreen THEN
      s1.screen:=I.LockPubScreen("Workbench");
    ELSE
      IF s1.scr.autoscroll THEN
        long:=I.LTRUE;
      ELSE
        long:=0;
      END;
      INCL(new.ns.type,I.nsExtended);
      IF s1.clonewb THEN
        s1.screen:=I.LockPubScreen("Workbench");
        s1.scr.width:=s1.screen.width;
        s1.scr.height:=s1.screen.height;
        s1.scr.depth:=s1.screen.rastPort.bitMap.depth;
        s1.scr.displayId:=g.GetVPModeID(s.ADR(s1.screen.viewPort));
        I.UnlockPubScreen("Workbench",s1.screen);
      END;
      s1.screen:=I.OpenScreenTags(new,I.saLeft,0,
                                   I.saTop,0,
                                   I.saWidth,s1.scr.width,
                                   I.saHeight,s1.scr.height,
                                   I.saDepth,s1.scr.depth,
                                   I.saTitle,s.ADR("Analay V1.12 © 1991-1996 Marc Necker"),
                                   I.saPens,s.ADR(plast),
                                   I.saDetailPen,0,
                                   I.saBlockPen,1,
                                   I.saDisplayID,s1.scr.displayId,
                                   I.saOverscan,s1.scr.oscan,
                                   I.saFont,0,
                                   I.saSysFont,0,
                                   I.saBitMap,0,
                                   I.saAutoScroll,long,
                                   I.saSharePens,I.LTRUE,
                                   I.saFullPalette,I.LTRUE,
                                   u.done);
    END;
(*  END;*)
  IF (s1.usewbscreen) AND (s1.os>=36) THEN
    IF s1.mainwidth=0 THEN
      s1.mainxpos:=0;
      s1.mainypos:=11;
      s1.mainwidth:=s1.screen.width;
      s1.mainheight:=s1.screen.height-s1.mainypos;
    END;
    IF s1.mainwidth>s1.screen.width THEN
      s1.mainwidth:=s1.screen.width;
    END;
    IF s1.mainheight>s1.screen.height THEN
      s1.mainheight:=s1.screen.height;
    END;
    IF s1.mainxpos+s1.mainwidth>s1.screen.width THEN
      s1.mainxpos:=s1.screen.width-s1.mainwidth;
    END;
    IF s1.mainypos+s1.mainheight>s1.screen.height THEN
      s1.mainypos:=s1.screen.height-s1.mainheight;
    END;
    s1.window:=it.SetWindow(s1.mainxpos,s1.mainypos,s1.mainwidth,s1.mainheight,s.ADR("Analay V1.12 © 1991-1996 Marc Necker"),LONGSET{I.activate,I.simpleRefresh,I.noCareRefresh,I.windowDepth,I.windowDrag,I.windowSizing},
                         LONGSET{I.menuPick,I.rawKey,I.inactiveWindow,I.activeWindow,I.vanillaKey},s1.screen);
    I.UnlockPubScreen("Workbench",s1.screen);
  ELSE
    s1.window:=it.SetWindow(0,11,s1.screen.width,s1.screen.height-11,NIL,LONGSET{I.backDrop,I.borderless,I.activate,I.simpleRefresh,I.noCareRefresh},
                         LONGSET{I.menuPick,I.rawKey,I.inactiveWindow,I.activeWindow,I.vanillaKey},s1.screen);
  END;
(*  s1.meswin:=is.SetWindow(0,s1.scrhe-42,s1.scrwi,42,s.ADR("Message Window"),LONGSET{I.activate,I.windowDrag,I.windowSizing,I.windowClose,I.windowDepth},
                          LONGSET{I.menuPick,I.rawKey,I.gadgetUp,I.inactiveWindow},s1.screen);*)

  s1.view:=s.ADR(s1.screen.viewPort);
  s1.rast:=s1.window.rPort;

(*  IF s1.clonewb THEN
    s1.scr.displayId:=g.GetVPModeID(s1.view);
  END;*)

(* ColorSharing *)
  s1.colormap:=s1.view.colorMap;
  IF s1.os>=39 THEN
(*    i:=s.LSH(1,s1.scr.depth);
    IF i<32 THEN
      i:=32;
    END;
    s1.colormap:=g.GetColorMap(i);
    s1.view.colorMap:=s1.colormap;
    long:=g.AttachPalExtra(s1.colormap,s1.view);*)

(* Reserving colors for Math-Mode *)
    i:=3;
    WHILE i<s1.scr.reserved-1 DO
      INC(i);
      g.GetRGB32(s1.colormap,i,1,rgb);
      long:=g.ObtainPen(s1.colormap,i,rgb[0],rgb[1],rgb[2],0);
    END;
(*    FOR i:=0 TO 3 DO
      long:=g.ObtainPen(s1.colormap,i,0,0,0,s.VAL(LONGINT,LONGSET{g.penbNoSetcolor}));
    END;*)

(*    g.SetRGB32CM(s1.colormap,17,s.LSH(14*17,24),s.LSH(4*17,24),s.LSH(4*17,24));
    g.SetRGB32CM(s1.colormap,18,0,0,0);
    g.SetRGB32CM(s1.colormap,19,s.LSH(14*17,24),s.LSH(14*17,24),s.LSH(12*17,24));
    long:=g.ObtainPen(s1.colormap,0,s.LSH(10*17,24),s.LSH(10*17,24),s.LSH(10*17,24),0);
    long:=g.ObtainPen(s1.colormap,1,0,0,0,0);
    long:=g.ObtainPen(s1.colormap,2,-1,-1,-1,0);
    long:=g.ObtainPen(s1.colormap,3,s.LSH(6*17,24),s.LSH(8*17,24),s.LSH(11*17,24),0);
    long:=g.ObtainPen(s1.colormap,17,s.LSH(14*17,24),s.LSH(4*17,24),s.LSH(4*17,24),0);
    long:=g.ObtainPen(s1.colormap,18,0,0,0,0);
    long:=g.ObtainPen(s1.colormap,19,s.LSH(14*17,24),s.LSH(14*17,24),s.LSH(12*17,24),0);*)
  END;

(*  IF s1.os<36 THEN
    g.SetRGB4(s1.view,0,10,10,10);
    g.SetRGB4(s1.view,1,0,0,0);
    g.SetRGB4(s1.view,2,15,15,15);
    g.SetRGB4(s1.view,3,6,8,11);
    g.SetRGB4(s1.view,4,15,0,0);
    g.SetRGB4(s1.view,5,0,15,0);
    g.SetRGB4(s1.view,6,0,0,15);
    g.SetRGB4(s1.view,7,15,15,0);
    g.SetRGB4(s1.view,8,0,15,8);
    g.SetRGB4(s1.view,9,15,0,15);
    g.SetRGB4(s1.view,10,9,0,15);
    g.SetRGB4(s1.view,11,0,8,0);
    g.SetRGB4(s1.view,12,15,12,0);
    g.SetRGB4(s1.view,13,0,15,15);
    g.SetRGB4(s1.view,14,15,7,0);
    g.SetRGB4(s1.view,15,0,9,15);
  END;*)

  IF s1.scr.colormap[0,0]=-1 THEN
    IF s1.os>=39 THEN
      FOR i:=0 TO 15 DO
        g.GetRGB32(s1.colormap,i,1,rgb);
        s1.scr.colormap[i,0]:=RGBToInt(rgb[0]);
        s1.scr.colormap[i,1]:=RGBToInt(rgb[1]);
        s1.scr.colormap[i,2]:=RGBToInt(rgb[2]);
      END;
    ELSE
      FOR i:=0 TO 15 DO
        col:=g.GetRGB4(s1.colormap,i);
        set:=s.VAL(SET,col);
        s1.scr.colormap[i,0]:=s.VAL(INTEGER,s.LSH(s.LSH(set,4),-12))*255 DIV 15;
        s1.scr.colormap[i,1]:=s.VAL(INTEGER,s.LSH(s.LSH(set,8),-12))*255 DIV 15;
        s1.scr.colormap[i,2]:=s.VAL(INTEGER,s.LSH(s.LSH(set,12),-12))*255 DIV 15;
      END;
    END;
  ELSIF NOT(s1.usewbscreen) THEN
    FOR i:=0 TO 15 DO
      IF s1.os<39 THEN
        g.SetRGB4(s1.view,i,s1.scr.colormap[i,0]*15 DIV 255,s1.scr.colormap[i,1]*15 DIV 255,s1.scr.colormap[i,2]*15 DIV 255);
      ELSE
        g.SetRGB32(s1.view,i,IntToRGB(s1.scr.colormap[i,0]),IntToRGB(s1.scr.colormap[i,1]),IntToRGB(s1.scr.colormap[i,2]));
      END;
    END;
  END;

(*  s1.mesrast:=s1.meswin.rPort;*)

  IF vinfo#NIL THEN
    gd.FreeVisualInfo(vinfo);
    vinfo:=NIL;
  END;
  vinfo:=gd.GetVisualInfo(s1.screen,NIL);
  IF s1.menu=NIL THEN
    pt.SetBusyPointer(s1.window);

    mm.StartMenu(s1.window);
  
    mm.NewMenu(ac.GetString(ac.Program));
    mm.NewItem(ac.GetString(ac.Load),"O");
    mm.NewItem(ac.GetString(ac.Save),"S");
    mm.NewItem(ac.GetString(ac.SaveAs),"A");
    mm.Separator;
    mm.NewItem(ac.GetString(ac.Layout),"Y");
    mm.Separator;
    mm.NewItem(ac.GetString(ac.About),0X);
    mm.NewItem(ac.GetString(ac.Quit),"Q");
  
    mm.NewMenu(ac.GetString(ac.Function));
    mm.NewItem(ac.GetString(ac.Input),"I");
    mm.NewItem(ac.GetString(ac.DefinitionDomain),"D");
    mm.NewItem(ac.GetString(ac.Connect),"C");
    mm.NewItem(ac.GetString(ac.Process),"P");
    mm.NewItem(ac.GetString(ac.ChangeConstants),"O");
    mm.Separator;
    mm.NewItem2(ac.GetString(ac.QuickEnter),s.ADR("Ctrl+I"));
  
    mm.NewMenu(ac.GetString(ac.Windows));
    mm.NewItem(ac.GetString(ac.Create),"W");
    mm.NewItem(ac.GetString(ac.Settings),"N");
    mm.Separator;
    mm.NewItem(ac.GetString(ac.AxisLimits),"B");
    mm.NewItem(ac.GetString(ac.AxisDesign),"A");
    mm.NewItem(ac.GetString(ac.Grid),"G");
    mm.NewItem(ac.GetString(ac.GraphDesign),"F");
    mm.Separator;
    mm.NewItem2(ac.GetString(ac.Text),s.ADR("»"));
    mm.NewSubItem2(ac.GetString(ac.Place),s.ADR("Ctrl+T"));
    mm.NewSubItem2(ac.GetString(ac.Change),s.ADR("Alt+T"));
    mm.NewSubItem(ac.GetString(ac.Delete),0X);
    mm.SubSeparator;
    mm.NewSubItem2(ac.GetString(ac.Default),s.ADR("Ctrl+Alt+T"));
    mm.NewItem2(ac.GetString(ac.Point),s.ADR("»"));
    mm.NewSubItem2(ac.GetString(ac.Place),s.ADR("Ctrl+P"));
    mm.NewSubItem2(ac.GetString(ac.Change),s.ADR("Alt+P"));
    mm.NewSubItem(ac.GetString(ac.Delete),0X);
    mm.SubSeparator;
    mm.NewSubItem2(ac.GetString(ac.Default),s.ADR("Ctrl+Alt+P"));
    mm.NewItem2(ac.GetString(ac.Marker),s.ADR("»"));
    mm.NewSubItem2(ac.GetString(ac.Place),s.ADR("Ctrl+M"));
    mm.NewSubItem2(ac.GetString(ac.Change),s.ADR("Alt+M"));
    mm.NewSubItem(ac.GetString(ac.Delete),0X);
    mm.SubSeparator;
    mm.NewSubItem2(ac.GetString(ac.Default),s.ADR("Ctrl+Alt+M"));
    mm.NewItem2(ac.GetString(ac.Hatching),s.ADR("»"));
    mm.NewSubItem2(ac.GetString(ac.Place),s.ADR("Ctrl+S"));
    mm.NewSubItem2(ac.GetString(ac.Change),s.ADR("Alt+S"));
    mm.NewSubItem(ac.GetString(ac.Delete),0X);
    mm.SubSeparator;
    mm.NewSubItem2(ac.GetString(ac.Default),s.ADR("Ctrl+Alt+S"));
  
  (*  mm.NewItem2("Text setzen","Ctrl+T");
    mm.NewItem2("Punkt setzen","Ctrl+P");
    mm.NewItem2("Markierung setzen","Ctrl+M");
    mm.NewItem2("Bereich schraffieren","Ctrl+B");
    mm.Separator;
    mm.NewItem2("Text verändern","Ctrl+Shift+T");
    mm.NewItem2("Punkt verändern","Ctrl+Shift+P");
    mm.NewItem2("Markierung verändern","Ctrl+Shift+M");
    mm.NewItem2("Bereich verändern","Ctrl+Shift+B");
    mm.Separator;
    mm.NewItem("Text löschen",0X);
    mm.NewItem("Punkt löschen",0X);
    mm.NewItem("Markierung löschen",0X);
    mm.NewItem("Bereich löschen",0X);*)
  
    mm.NewMenu(ac.GetString(ac.Analysis));
    mm.NewItem(ac.GetString(ac.FindZeros),"1");
    mm.NewItem(ac.GetString(ac.FindExtremes),"2");
    mm.NewItem(ac.GetString(ac.FindGaps),"3");
    mm.NewItem(ac.GetString(ac.FindInflections),"4");
    mm.NewItem(ac.GetString(ac.FindIntersections),"5");
    mm.Separator;
    mm.NewItem(ac.GetString(ac.CompleteAnalysis),"6");
    mm.NewItem(ac.GetString(ac.CompleteSettings),"7");
    mm.Separator;
    mm.NewItem(ac.GetString(ac.CalcArea),"S");
  
    mm.NewMenu(ac.GetString(ac.Special));
    mm.NewItem2(ac.GetString(ac.Legend),s.ADR("»"));
    mm.NewSubItem(ac.GetString(ac.Create),"N");
    mm.NewSubItem2(ac.GetString(ac.Change),s.ADR("Alt+N"));
    mm.NewSubItem(ac.GetString(ac.Delete),0X);
    mm.SubSeparator;
    mm.NewSubItem2(ac.GetString(ac.Default),s.ADR("Ctrl+Alt+N"));
    mm.NewItem2(ac.GetString(ac.Table),s.ADR("»"));
    mm.NewSubItem(ac.GetString(ac.Create),"T");
    mm.NewSubItem2(ac.GetString(ac.Change),s.ADR("Alt+T"));
    mm.NewSubItem(ac.GetString(ac.Delete),0X);
    mm.SubSeparator;
    mm.NewSubItem2(ac.GetString(ac.Default),s.ADR("Ctrl+Alt+T"));
    mm.NewItem2(ac.GetString(ac.List),s.ADR("»"));
    mm.NewSubItem(ac.GetString(ac.Create),"L");
    mm.NewSubItem2(ac.GetString(ac.Change),s.ADR("Alt+L"));
    mm.NewSubItem(ac.GetString(ac.Delete),0X);
    mm.SubSeparator;
    mm.NewSubItem2(ac.GetString(ac.Default),s.ADR("Ctrl+Alt+L"));
(*    mm.Separator;
    mm.NewItem("Verändere Legende",0X);
    mm.NewItem("Verändere Wertetabelle",0X);
    mm.NewItem("Verändere Liste",0X);*)
  (*  mm.Separator;
    mm.NewItem("Setze Punkt","6");
    mm.NewItem("Lösche Punkt","7");
    mm.NewItem("Setze Markierung","8");
    mm.NewItem("Lösche Markierung","9");
    mm.NewItem("Markiere Bereich","0");*)
  
    mm.NewMenu(ac.GetString(ac.SettingsMenu));
    mm.NewItem(ac.GetString(ac.ScreenMode),0X);
    mm.NewItem(ac.GetString(ac.ScreenColors),0X);
    mm.NewItem(ac.GetString(ac.Priorities),0X);
    mm.NewCheckItem(ac.GetString(ac.UseWBScreen),0X,s1.usewbscreen);
    mm.NewCheckItem(ac.GetString(ac.QuickSelect),0X,s1.quickselect);
    mm.NewCheckItem(ac.GetString(ac.AutoActiveWindow),0X,s1.autoactive);
    mm.NewCheckItem(ac.GetString(ac.CloneWB),0X,s1.clonewb);
    mm.Separator;
    mm.NewItem(ac.GetString(ac.Save),0X);
    mm.Separator;
    mm.NewItem(ac.GetString(ac.Load),0X);
    mm.NewItem(ac.GetString(ac.SaveAs),0X);
(*    mm.NewItem("Linien editieren",0X);
    mm.NewItem("Punkte editieren",0X);
    mm.NewItem("Markierungen editieren",0X);
    mm.NewItem("Füllmuster editieren",0X);*)
  
    s1.menu:=mm.EndMenu();
  END;
  bool:=gd.LayoutMenus(s1.menu,vinfo,gd.mnNewLookMenus,I.LTRUE,
                                     u.done);
  usewbscreenitem:=s1.menu.nextMenu.nextMenu.nextMenu.nextMenu.nextMenu.firstItem.nextItem.nextItem.nextItem;
  quickselectitem:=usewbscreenitem.nextItem;
  autoactiveitem:=quickselectitem.nextItem;

  IF s1.usewbscreen THEN
    INCL(usewbscreenitem.flags,I.checked);
  ELSE
    EXCL(usewbscreenitem.flags,I.checked);
  END;
  IF s1.quickselect THEN
    INCL(quickselectitem.flags,I.checked);
  ELSE
    EXCL(quickselectitem.flags,I.checked);
  END;
  IF s1.autoactive THEN
    INCL(autoactiveitem.flags,I.checked);
  ELSE
    EXCL(autoactiveitem.flags,I.checked);
  END;
  IF s1.clonewb THEN
    INCL(autoactiveitem.nextItem.flags,I.checked);
  ELSE
    EXCL(autoactiveitem.nextItem.flags,I.checked);
  END;

  bool:=I.SetMenuStrip(s1.window,s1.menu^);
(*  I.OffMenu(s1.window,I.FullMenuNum(0,0,0));
  I.OffMenu(s1.window,I.FullMenuNum(0,1,0));
  I.OffMenu(s1.window,I.FullMenuNum(0,5,0));
  I.OffMenu(s1.window,I.FullMenuNum(1,1,0));
  I.OffMenu(s1.window,I.FullMenuNum(2,10,0));
  I.OffMenu(s1.window,I.FullMenuNum(2,10,1));
  I.OffMenu(s1.window,I.FullMenuNum(2,10,2));
  I.OffMenu(s1.window,I.FullMenuNum(2,11,0));
  I.OffMenu(s1.window,I.FullMenuNum(2,11,1));
  I.OffMenu(s1.window,I.FullMenuNum(2,11,2));
  I.OffMenu(s1.window,I.FullMenuNum(5,1,0));
  I.OffMenu(s1.window,I.FullMenuNum(5,5,0));
  I.OffMenu(s1.window,I.FullMenuNum(5,6,0));*)
END Init;

BEGIN
  listId:=-1;

  vinfo:=NIL;

(*  NEW(s1.infotext,5,80);
  s1.infotext[0]:="SuperCalc V0.9 internal";
  s1.infotext[1]:="© 1994 Marc Necker";
  s1.infotext[2]:="";
  s1.infotext[3]:="Dies ist eine Vorversion, die";
  s1.infotext[4]:="nicht frei kopiert werden darf!";*)
END SuperCalcTools2.
