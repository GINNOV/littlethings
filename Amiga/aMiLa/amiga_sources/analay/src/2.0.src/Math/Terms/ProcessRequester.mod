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


MODULE ProcessRequester;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       gd : GadTools,
       st : Strings,
       c  : Conversions,
       bt : BasicTools,
       tt : TextTools,
       rt : RequesterTools,
       ac : AnalayCatalog,
       gb : GeneralBasics,
       mg : MathGUI,
       fb : FunctionBasics,
       ft : FunctionTrees,
       fd : FunctionDerive,
       fs : FunctionSimplify,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       m  : Multitasking,
       mem: MemoryManager,
       tid: TaskIDs,
       t  : Terms,
       bas: BasicTypes,
       io,
       NoGuruRq;

VAR processwind * ,
    mirrorwind  * : wm.Window;
    derstr        : ARRAY 80 OF CHAR;
    pxs,pys       : ARRAY 80 OF CHAR;
(*    autopy      : BOOLEAN;*)
    xstr,ystr(*,
    pxstr,pystr*) : ARRAY 80 OF CHAR;

TYPE ProcessObject * = POINTER TO ProcessObjectDesc;
     ProcessObjectDesc * = RECORD(m.TaskDesc)
       chable      * : m.ChangeAble;
     END;

PROCEDURE MirrorFunction*(VAR x,y:ARRAY OF CHAR;VAR type:INTEGER):BOOLEAN;

VAR subwind    : wm.SubWindow;
    wind       : I.WindowPtr;
    rast       : g.RastPortPtr;
    root       : gmb.Root;
    xval,yval  : gmo.StringGadget;
    radio      : gmo.RadioButtons;
    gadobj     : gmb.Object;
    glist      : I.GadgetPtr;
    mes        : I.IntuiMessagePtr;
    textarray  : ARRAY 4 OF e.STRPTR;
    ret        : BOOLEAN;

BEGIN
  NEW(mes);
  ret:=FALSE;
  IF mirrorwind=NIL THEN
    mirrorwind:=wm.InitWindow(wm.centered,wm.centered,10,10,TRUE,ac.GetString(ac.ReflectFunction),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=mirrorwind.InitSub(mg.screen);

  textarray[0]:=ac.GetString(ac.ThroughLineX);
  textarray[1]:=ac.GetString(ac.ThroughLineY);
  textarray[2]:=ac.GetString(ac.ThroughPoint);
  textarray[3]:=NIL;

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      gadobj:=gmo.SetText(ac.GetString(ac.ReflectFunction),-1);
      radio:=gmo.SetRadioButtons(s.ADR(textarray),type);
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      xval:=gmo.SetStringGadget(s.ADR("x"),255,gmo.realType);
      xval.SetMinVisible(5);
      yval:=gmo.SetStringGadget(s.ADR("y"),255,gmo.realType);
      yval.SetMinVisible(5);
    gmb.EndBox;
  glist:=root.EndRoot();

  xval.SetString(x);
  yval.SetString(y);
  IF type=0 THEN
    yval.Disable(TRUE);
  ELSIF type=1 THEN
    xval.Disable(TRUE);
  END;

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    LOOP
      subwind.WaitPort;
      root.GetIMes(mes);
      IF I.gadgetUp IN mes.class THEN
        IF mes.iAddress=root.ok THEN
          xval.GetString(x);
          yval.GetString(y);
          ret:=TRUE;
          EXIT;
        ELSIF mes.iAddress=root.ca THEN
          EXIT;
        END;
      ELSIF I.gadgetDown IN mes.class THEN
        IF mes.iAddress=radio.gadget THEN
          type:=SHORT(radio.GetValue());
          IF type=0 THEN
            xval.Disable(FALSE);(* xval.Refresh;*)
            yval.Disable(TRUE); (* yval.Refresh;*)
            xval.Activate;
          ELSIF type=1 THEN
            xval.Disable(TRUE); (* xval.Refresh;*)
            yval.Disable(FALSE);(* yval.Refresh;*)
            yval.Activate;
          ELSIF type=2 THEN
            xval.Disable(FALSE);(* xval.Refresh;*)
            yval.Disable(FALSE);(* yval.Refresh;*)
            xval.Activate;
          END;
        END;
      END;
(*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"mirrorfunc",wind);
      END;*)
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  RETURN ret;
END MirrorFunction;

PROCEDURE (processobj:ProcessObject) ProcessFunctions*():BOOLEAN;

VAR subwind    : wm.SubWindow;
    wind       : I.WindowPtr;
    rast       : g.RastPortPtr;
    root       : gmb.Root;
    der,tang,
    norm,mir   : gmo.BooleanGadget;
    funclv     : gmo.ListView;
    gadobj     : gmb.Object;
    glist      : I.GadgetPtr;
    mes        : I.IntuiMessagePtr;
    class      : LONGSET;
    msg        : m.Message;
    actfunc,term,
    node,node2,
    node3      : l.Node;
    nodef,
    nodef2,
    nodef3,
    nodex      : fb.Node;
    bool,ret   : BOOLEAN;
    switchtext : ARRAY 2 OF ARRAY 80 OF CHAR;
    switchpos,
    pos,type   : INTEGER;
    string     : ARRAY 80 OF CHAR;
    px,py,alpha,
    dx1,dy1,
    dx2,dy2    : LONGREAL;

PROCEDURE RefreshFunc;

BEGIN
  IF actfunc#NIL THEN
    funclv.SetValue(t.functions.GetNodeNumber(actfunc));
  ELSE
    funclv.Refresh;
  END;
END RefreshFunc;

PROCEDURE ReplaceX(VAR node,nodex:fb.Node);

VAR node2 : fb.Node;
(*    parent,
    right,
    left   : f1.NodePtr;*)

BEGIN
  IF node#NIL THEN
    IF (node IS fb.TreeObj) AND (node(fb.TreeObj).object#NIL) AND (node(fb.TreeObj).object IS fb.XYObject) AND (node(fb.TreeObj).object(fb.XYObject).isX) THEN
      node2:=node;
      node:=fb.CopyTree(nodex);
(*      node:=NIL;
      NEW(node(f1.Number));
      node(f1.Number).real:=x;*)
      node.parent:=node2.parent;
(*      node.left:=node2.left;
      node.right:=node2.right;*)
    END;
(*    IF node IS f2.X THEN
      parent:=node.parent;
      right:=node.right;
      left:=node.left;
      node:=NIL;
      NEW(node(f2.Number));
      node(f2.Number).real:=SHORT(x);
      node.parent:=parent;
      node.right:=right;
      node.left:=left;
      IF node.right#NIL THEN
        node.right.parent:=node;
      END;
      IF node.left#NIL THEN
        node.left.parent:=node;
      END;
    ELSIF node IS f2.Constant THEN
      IF node(f2.Constant).isX THEN
        parent:=node.parent;
        right:=node.right;
        left:=node.left;
        node:=NIL;
        NEW(node(f2.Number));
        node(f2.Number).real:=SHORT(x);
        node.parent:=parent;
        node.right:=right;
        node.left:=left;
        IF node.right#NIL THEN
          node.right.parent:=node;
        END;
        IF node.left#NIL THEN
          node.left.parent:=node;
        END;
      END;
    END;*)
    ReplaceX(node.left,nodex);
    ReplaceX(node.right,nodex);
    IF node IS fb.Operation THEN
      ReplaceX(node(fb.Operation).root,nodex);
      ReplaceX(node(fb.Operation).data,nodex);
    END;
  END;
END ReplaceX;

PROCEDURE MirrorNode(VAR node:fb.Node;offset:fb.Node);

VAR node2 : fb.Node;

BEGIN
  node2:=node.parent;
  node.parent:=NIL;
  NEW(node.parent(fb.Sign));
  node.parent.right:=node;
  node:=node.parent;
  node(fb.Sign).sign:="-";
  NEW(node.left(fb.Number));
  node.left.parent:=node;
  node.left(fb.Number).real:=0;
  NEW(node.parent(fb.Sign));
  node.parent.left:=node;
  node:=node.parent;
  node(fb.Sign).sign:="+";
  node.parent:=node2;
  NEW(node.right(fb.Sign));
  node.right.parent:=node;
  node2:=node.right;
  node2(fb.Sign).sign:="*";
  NEW(node2.left(fb.Number));
  node2.left.parent:=node2;
  node2.left(fb.Number).real:=2;
  node2.right:=fb.CopyTree(offset);
  node2.right.parent:=node2;
END MirrorNode;

PROCEDURE Mirror(VAR node:fb.Node;offset:fb.Node);

BEGIN
  IF node#NIL THEN
    Mirror(node.left,offset);
    Mirror(node.right,offset);
    IF node IS fb.Operation THEN
      Mirror(node(fb.Operation).root,offset);
      Mirror(node(fb.Operation).data,offset);
    END;
    IF (node IS fb.TreeObj) AND (node(fb.TreeObj).object#NIL) AND (node(fb.TreeObj).object IS fb.XYObject) AND (node(fb.TreeObj).object(fb.XYObject).isX) THEN
      MirrorNode(node,offset);
    END;
  END;
END Mirror;

BEGIN
  t.terms.NewUser(processobj,TRUE);
  t.functions.NewUser(processobj,TRUE);
  NEW(mes);
  ret:=FALSE;
  IF processwind=NIL THEN
    processwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.ProcessFunctions),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=processwind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad},subwind);
    funclv:=gmo.SetListView(ac.GetString(ac.Functions),t.functions,t.PrintFunction,0,FALSE,255);
    der:=gmo.SetBooleanGadget(ac.GetString(ac.DeriveFunction),FALSE);
    tang:=gmo.SetBooleanGadget(ac.GetString(ac.TangentAtPoint),FALSE);
    norm:=gmo.SetBooleanGadget(ac.GetString(ac.NormalAtPoint),FALSE);
    mir:=gmo.SetBooleanGadget(ac.GetString(ac.ReflectFunction),FALSE);
  glist:=root.EndRoot();
  funclv.SetNoEntryText(s.ADR("No functions!"));

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    actfunc:=t.functions.GetNode(funclv.GetValue());

    RefreshFunc;

    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF processobj.msgsig IN class THEN
        REPEAT
          msg:=processobj.ReceiveMsg();
          IF msg#NIL THEN
            IF msg.type=m.msgQuit THEN
              msg.Reply;
              EXIT;
            ELSIF msg.type=m.msgClose THEN
              subwind.Close;
              root.Resize;
            ELSIF msg.type=m.msgOpen THEN
              subwind.SetScreen(mg.screen);
              wind:=subwind.Open(NIL);
              IF wind#NIL THEN
                rast:=wind.rPort;
                root.Resize;
              ELSE
                msg.Reply;
                EXIT;
              END;
            ELSIF (msg.type=m.msgNodeChanged) OR (msg.type=m.msgListChanged) THEN
              IF (actfunc#NIL) & mem.Garbaged(actfunc) THEN
                funclv.SetValue(0);
                actfunc:=t.functions.GetNode(funclv.GetValue());
              END;
              RefreshFunc;
            ELSIF msg.type=m.msgActivate THEN
              subwind.ToFront;
            ELSIF msg.type=m.msgNewPriority THEN
              processobj.SetPriority(m.taskdata.requesterpri);
            END;
            msg.Reply;
          END;
        UNTIL msg=NIL;
      END;

      REPEAT
        root.GetIMes(mes);
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=der.gadget THEN
            IF actfunc#NIL THEN
              subwind.SetBusyPointer;
              bool:=gb.EnterString(mg.screen,ac.GetString(ac.Derivative),ac.GetString(ac.DeriveFor),derstr);
              IF bool THEN
                IF actfunc(t.Function).isbase THEN
                  term:=actfunc(t.Function).terms.head(t.FuncTerm).term;
                  node:=NIL;
                  NEW(node(t.Term));
                  node(t.Term).Init;
                  COPY(term(t.Term).term^,node(t.Term).term^);
                  actfunc(t.Function).terms.head(t.FuncTerm).term.AddBehind(node);
                  pos:=0;
                  node(t.Term).tree:=ft.Parse(node(t.Term).term^);
                  bool:=fs.Optimize(node(t.Term).tree);
                  fd.Derive(node(t.Term).tree,derstr);
                  bool:=fs.Optimize(node(t.Term).tree);
                  ft.TreeToString(node(t.Term).tree,node(t.Term).term^);
                  node2:=NIL;
                  NEW(node2(t.Function));
                  node2(t.Function).Init;
                  COPY(node(t.Term).term^,node2(t.Function).name);
                  node2(t.Function).isbase:=TRUE;
                  node3:=NIL;
                  NEW(node3(t.FuncTerm));
                  node3(t.FuncTerm).term:=node(t.Term);
                  node2(t.Function).terms.AddTail(node3);
                  node(t.Term).basefunc:=node2;
                  node(t.Term).MakeDepend;
                  actfunc.AddBehind(node2);
                  actfunc:=node2;
                ELSE
                  node:=actfunc(t.Function).AbleitFunction(derstr);
                  actfunc.AddBehind(node);
                  actfunc:=node;
                END;
                RefreshFunc;
              END;
              subwind.ClearPointer;
            END;
          ELSIF mes.iAddress=tang.gadget THEN
            IF actfunc#NIL THEN
              subwind.SetBusyPointer;
              bool:=gb.EnterPoint(mg.screen,pxs,pys,TRUE);
              IF bool THEN
                px:=ft.ExpressionToReal(pxs);
                term:=actfunc(t.Function).GetFunctionTerm(px);
                nodex:=ft.Parse(pxs);
                nodef:=NIL;
                nodef2:=NIL;
                nodef3:=NIL;
                pos:=0;
    (*            pos:=0;
                nodef:=f.Parse(pys,pos);
                py:=f.RechenLong(nodef,0,0,pos);*)
                pos:=0;
                nodef:=ft.Parse(term(t.Term).term^);
                pos:=0;
                py:=actfunc(t.Function).GetFunctionValue(px,0,pos);
                IF pos=0 THEN
                  nodef2:=fb.CopyTree(nodef);
                  fs.Simplify(nodef2);
                  fd.Derive(nodef2,"x");
                  fs.Simplify(nodef2);
                  ReplaceX(nodef2,nodex);
                  nodef2.parent:=NIL;
                  NEW(nodef2.parent(fb.Sign));
                  nodef2.parent.left:=nodef2;
                  nodef2:=nodef2.parent;
                  nodef2(fb.Sign).sign:="*";
                  nodef2.right:=NIL;
                  NEW(nodef2.right(fb.Sign));
                  nodef2.right.parent:=nodef2;
                  nodef3:=nodef2.right;
                  nodef3(fb.Sign).sign:="-";
                  NEW(nodef3.left(fb.TreeObj));
                  nodef3.left.parent:=nodef3;
                  NEW(nodef3.left(fb.TreeObj).object(fb.XYObject));
                  nodef3.left(fb.TreeObj).object(fb.XYObject).isX:=TRUE;
                  NEW(nodef3.left(fb.TreeObj).object(fb.XYObject).name,2);
                  COPY("x",nodef3.left(fb.TreeObj).object(fb.XYObject).name^);
                  nodef3.right:=fb.CopyTree(nodex);
                  nodef3.right.parent:=nodef3;
                  NEW(nodef2.parent(fb.Sign));
                  nodef2.parent.left:=nodef2;
                  nodef2:=nodef2.parent;
                  nodef2(fb.Sign).sign:="+";
                  nodef2.right:=fb.CopyTree(nodef);
                  nodef2.right.parent:=nodef2;
                  ReplaceX(nodef2.right,nodex);
                  fs.Simplify(nodef2);
  (*                alpha:=f.CalcLong(nodef,px,0,pos);
                  ReplaceX(nodef,px);
                  f.Simplify(nodef);
  (*                NEW(nodef2(f2.Bracket));
                  nodef2(f2.Bracket).root:=nodef;*)
                  NEW(nodef2(f1.Sign));
                  nodef2(f1.Sign).sign:="*";
                  NEW(nodef2.right(f1.TreeObj));
                  NEW(nodef2.right(f1.TreeObj).object(f1.XYObject));
                  NEW(nodef2.right(f1.TreeObj).object(f1.Object).name,2);
                  nodef2.right(f1.TreeObj).object(f1.Object).name^:="x";
                  nodef2.right(f1.TreeObj).object(f1.XYObject).isX:=TRUE;
                  nodef2.right.parent:=nodef2;
                  nodef2.left:=nodef;
                  nodef.parent:=nodef2;
                  NEW(nodef3(f1.Sign));
                  nodef3(f1.Sign).sign:="+";
                  nodef3.left:=nodef2;
                  nodef2.parent:=nodef3;
                  NEW(nodef3.right(f1.Number));
                  nodef3.right.parent:=nodef3;
                  IF alpha#0 THEN
    (*                alpha:=mdt.Atan(alpha);*)
                    dy1:=py;
                    dx1:=py/alpha;
                    dx2:=px-dx1;
                    dy2:=-alpha*dx2;
                    IF dy2<0 THEN
                      dy2:=-dy2;
                      nodef3(f1.Sign).sign:="-";
                    END;
                    nodef3.right(f1.Number).real:=dy2;
                  ELSE
                    nodef3:=NIL;
                    NEW(nodef3(f1.Number));
                    nodef3(f1.Number).real:=py;
                  END;
                  f.Simplify(nodef3);*)
  (*                py:=f.CalcLong(nodef2,px,0.0001,pos);
                  IF pos=0 THEN*)
                    node:=NIL;
                    NEW(node(t.Term));
                    node(t.Term).Init;
                    ft.TreeToString(nodef2,node(t.Term).term^);
                    IF (term.next#NIL) OR (term.prev#NIL) OR (t.terms.head=term) OR (t.terms.tail=term) THEN
                      term.AddBehind(node);
                    END;
                    node2:=NIL;
                    NEW(node2(t.Function));
                    node2(t.Function).Init;
                    COPY(node(t.Term).term^,node2(t.Function).name);
                    node2(t.Function).isbase:=TRUE;
                    node3:=NIL;
                    NEW(node3(t.FuncTerm));
                    node3(t.FuncTerm).term:=node(t.Term);
                    node2(t.Function).terms.AddTail(node3);
                    actfunc.AddBehind(node2);
                    node(t.Term).basefunc:=node2;
                    actfunc:=node2;
                    node(t.Term).MakeDepend;
                    RefreshFunc;
  (*                ELSE
                    bool:=r.RequestWin("Tangente darf nicht","senkrecht sein!","","   OK   ",wind);
                  END;*)
                ELSE
                  bool:=rt.RequestWin(ac.GetString(ac.TangentCannotBe),ac.GetString(ac.DrawnAtAGapTangent),s.ADR(""),ac.GetString(ac.OK),wind);
                END;
              END;
              subwind.ClearPointer;
            END;
          ELSIF mes.iAddress=norm.gadget THEN
            IF actfunc#NIL THEN
              subwind.SetBusyPointer;
              bool:=gb.EnterPoint(mg.screen,pxs,pys,TRUE);
              IF bool THEN
                px:=ft.ExpressionToReal(pxs);
                term:=actfunc(t.Function).GetFunctionTerm(px);
                nodex:=ft.Parse(pxs);
                nodef:=NIL;
                nodef2:=NIL;
                nodef3:=NIL;
                pos:=0;
    (*            pos:=0;
                nodef:=f.Parse(pys,pos);
                py:=f.RechenLong(nodef,0,0,pos);*)
                pos:=0;
                nodef:=ft.Parse(term(t.Term).term^);
                pos:=0;
                py:=actfunc(t.Function).GetFunctionValue(px,0,pos);
                IF pos=0 THEN
                  nodef2:=fb.CopyTree(nodef);
                  fs.Simplify(nodef2);
                  fd.Derive(nodef2,"x");
                  fs.Simplify(nodef2);
                  ReplaceX(nodef2,nodex);
                  nodef2.parent:=NIL;
                  NEW(nodef2.parent(fb.Sign));
                  nodef2.parent.right:=nodef2;
                  nodef2:=nodef2.parent;
                  nodef2(fb.Sign).sign:="/";
                  NEW(nodef2.left(fb.Number));
                  nodef2.left.parent:=nodef2;
                  nodef2.left(fb.Number).real:=1;
                  NEW(nodef2.parent(fb.Sign));
                  nodef2.parent.right:=nodef2;
                  nodef2:=nodef2.parent;
                  nodef2(fb.Sign).sign:="-";
                  NEW(nodef2.left(fb.Number));
                  nodef2.left.parent:=nodef2;
                  nodef2.left(fb.Number).real:=0;
                  NEW(nodef2.parent(fb.Sign));
                  nodef2.parent.left:=nodef2;
                  nodef2:=nodef2.parent;
                  nodef2(fb.Sign).sign:="*";
                  nodef2.right:=NIL;
                  NEW(nodef2.right(fb.Sign));
                  nodef2.right.parent:=nodef2;
                  nodef3:=nodef2.right;
                  nodef3(fb.Sign).sign:="-";
                  NEW(nodef3.left(fb.TreeObj));
                  nodef3.left.parent:=nodef3;
                  NEW(nodef3.left(fb.TreeObj).object(fb.XYObject));
                  nodef3.left(fb.TreeObj).object(fb.XYObject).isX:=TRUE;
                  NEW(nodef3.left(fb.TreeObj).object(fb.XYObject).name,2);
                  COPY("x",nodef3.left(fb.TreeObj).object(fb.XYObject).name^);
                  nodef3.right:=fb.CopyTree(nodex);
                  nodef3.right.parent:=nodef3;
                  NEW(nodef2.parent(fb.Sign));
                  nodef2.parent.left:=nodef2;
                  nodef2:=nodef2.parent;
                  nodef2(fb.Sign).sign:="+";
                  nodef2.right:=fb.CopyTree(nodef);
                  nodef2.right.parent:=nodef2;
                  ReplaceX(nodef2.right,nodex);
                  fs.Simplify(nodef2);
  (*(*                NEW(nodef2(f2.Bracket));
                  nodef2(f2.Bracket).root:=nodef;*)
                  NEW(nodef2(f1.Sign));
                  nodef2(f1.Sign).sign:="/";
                  nodef2.right:=nodef;
                  nodef.parent:=nodef2;
                  NEW(nodef2.left(f1.Number));
                  nodef2.left(f1.Number).real:=-1;
                  nodef2.left.parent:=nodef2;
                  nodef:=nodef2;
                  nodef2:=NIL;
                  ReplaceX(nodef,px);
                  f.Simplify(nodef);
                  NEW(nodef2(f1.Sign));
                  nodef2(f1.Sign).sign:="*";
                  NEW(nodef2.right(f1.TreeObj));
                  NEW(nodef2.right(f1.TreeObj).object(f1.XYObject));
                  NEW(nodef2.right(f1.TreeObj).object(f1.Object).name,2);
                  nodef2.right(f1.TreeObj).object(f1.Object).name^:="x";
                  nodef2.right(f1.TreeObj).object(f1.XYObject).isX:=TRUE;
                  nodef2.right.parent:=nodef2;
                  nodef2.left:=nodef;
                  NEW(nodef3(f1.Sign));
                  nodef3(f1.Sign).sign:="+";
                  nodef3.left:=nodef2;
                  nodef2.parent:=nodef3;
                  NEW(nodef3.right(f1.Number));
                  nodef3.right.parent:=nodef3;
  (*                NEW(nodef2(f2.Bracket));
                  nodef2(f2.Bracket).root:=nodef;
                  NEW(nodef2.parent(f2.Sign));
                  nodef2.parent(f2.Sign).sign:="*";
                  NEW(nodef2.parent.right(f2.Constant));
                  nodef2.parent.right(f2.Constant).isX:=TRUE;
                  nodef2.parent.right.parent:=nodef2.parent;
                  nodef2.parent.left:=nodef2;
                  NEW(nodef3(f2.Sign));
                  nodef3(f2.Sign).sign:="+";
                  nodef3.left:=nodef2.parent;
                  nodef2.parent.parent:=nodef3;
                  NEW(nodef3.right(f2.Number));
                  nodef3.right.parent:=nodef3;*)
                  alpha:=f.CalcLong(nodef,px,0,pos);
                  IF alpha#0 THEN
    (*                alpha:=mdt.Atan(alpha);*)
                    dy1:=py;
                    dx1:=py/alpha;
                    dx2:=px-dx1;
                    dy2:=-alpha*dx2;
                    IF dy2<0 THEN
                      dy2:=-dy2;
                      nodef3(f1.Sign).sign:="-";
                    END;
                    nodef3.right(f1.Number).real:=dy2;
                  ELSE
                    nodef3:=NIL;
                    NEW(nodef3(f1.Number));
                    nodef3(f1.Number).real:=py;
                  END;
                  f.Simplify(nodef3);*)
  (*                py:=f.CalcLong(nodef2,px,0.0001,pos);
                  IF pos=0 THEN*)
                    node:=NIL;
                    NEW(node(t.Term));
                    node(t.Term).Init;
                    ft.TreeToString(nodef2,node(t.Term).term^);
                    IF (term.next#NIL) OR (term.prev#NIL) OR (t.terms.head=term) OR (t.terms.tail=term) THEN
                      term.AddBehind(node);
                    END;
                    node2:=NIL;
                    NEW(node2(t.Function));
                    node2(t.Function).Init;
                    COPY(node(t.Term).term^,node2(t.Function).name);
                    node2(t.Function).isbase:=TRUE;
                    node3:=NIL;
                    NEW(node3(t.FuncTerm));
                    node3(t.FuncTerm).term:=node(t.Term);
                    node2(t.Function).terms.AddTail(node3);
                    actfunc.AddBehind(node2);
                    node(t.Term).basefunc:=node2;
                    actfunc:=node2;
                    node(t.Term).MakeDepend;
                    RefreshFunc;
  (*                ELSE
                    bool:=r.RequestWin("Normale darf nicht","senkrecht sein!","","   OK   ",wind);
                  END;*)
                ELSE
                  bool:=rt.RequestWin(ac.GetString(ac.NormalCannotBe),ac.GetString(ac.DrawnAtAGapNormal),s.ADR(""),ac.GetString(ac.OK),wind);
                END;
              END;
              subwind.ClearPointer;
            END;
  (*        ELSIF address=switch THEN
            gm.CyclePressed(switch,wind,switchtext,switchpos);
            listterms:=NOT(listterms);
            NewTermList;*)
          ELSIF mes.iAddress=mir.gadget THEN
            IF actfunc#NIL THEN
              bool:=MirrorFunction(xstr,ystr,type);
              IF bool THEN
                node:=NIL;
                NEW(node(t.Function));
                node(t.Function).Init;
                actfunc.Copy(node);
                WITH node: t.Function DO
                  COPY(ac.GetString(ac.ReflectionOf)^,node.name);
                  st.Append(node.name,actfunc(t.Function).name);
  (*                s1.CopyList(actfunc(s1.Function).terms,node.terms);
                  s1.CopyList(actfunc(s1.Function).define,node.define);
                  s1.CopyList(actfunc(s1.Function).depend,node.depend);
                  node.isbase:=actfunc(t.Function).isbase;*)
                  node.CreateAllTrees;
                  IF (type=0) OR (type=2) THEN
  (*                  IF type=0 THEN*)
                      nodef3:=ft.Parse(xstr);
  (*                  ELSE
                      nodef3:=ft.Parse(pxstr);
                    END;*)
                    fs.Simplify(nodef3);
                    node2:=node.terms.head;
                    WHILE node2#NIL DO
                      IF node2(t.FuncTerm).term(t.Term).basefunc=actfunc THEN
                        node2(t.FuncTerm).term(t.Term).basefunc:=node;
                      END;
                      term:=node2(t.FuncTerm).term;
                      fs.Simplify(term(t.Term).tree);
                      Mirror(term(t.Term).tree,nodef3);
                      fs.Simplify(term(t.Term).tree);
                      ft.TreeToString(term(t.Term).tree,term(t.Term).term^);
                      node2(t.FuncTerm).term.MakeDepend;
                      node2:=node2.next;
                    END;
                  END;
                  IF (type=1) OR (type=2) THEN
  (*                  IF type=1 THEN*)
                      nodef3:=ft.Parse(ystr);
  (*                  ELSE
                      nodef3:=ft.Parse(pystr);
                    END;*)
                    fs.Simplify(nodef3);
                    node2:=node.terms.head;
                    WHILE node2#NIL DO
                      IF node2(t.FuncTerm).term(t.Term).basefunc=actfunc THEN
                        node2(t.FuncTerm).term(t.Term).basefunc:=node;
                      END;
                      term:=node2(t.FuncTerm).term;
                      fs.Simplify(term(t.Term).tree);
                      MirrorNode(term(t.Term).tree,nodef3);
                      fs.Simplify(term(t.Term).tree);
                      ft.TreeToString(term(t.Term).tree,term(t.Term).term^);
                      node2(t.FuncTerm).term.MakeDepend;
                      node2:=node2.next;
                    END;
                  END;
                  IF node.isbase THEN
                    IF term#NIL THEN
                      COPY(node.terms.head(t.FuncTerm).term(t.Term).term^,node.name);
                      actfunc(t.Function).terms.head(t.FuncTerm).term.AddBehind(term);
                    END;
                  END;
                END;
                actfunc.AddBehind(node);
                actfunc:=node;
                RefreshFunc;
              END;
            END;
          ELSIF mes.iAddress=funclv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              actfunc:=t.functions.GetNode(funclv.GetValue());
            END;
          END;
        END;
  (*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"funcsymb",wind);
        END;*)
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  t.functions.FreeUser(processobj);
  t.terms.FreeUser(processobj);
  RETURN ret;
END ProcessFunctions;

PROCEDURE ProcessTask*(processtask:bas.ANY):bas.ANY;

VAR bool : BOOLEAN;

BEGIN
  WITH processtask: ProcessObject DO
    processtask.InitCommunication;
    bool:=processtask.ProcessFunctions();

    processtask.chable.RemTask(processtask);
    processtask.ReplyAllMessages;
    processtask.DestructCommunication;
    mem.NodeToGarbage(processtask);
    processtask.chable.FreeUser(processtask);
  END;
  IF bool THEN
    RETURN s.VAL(bas.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END ProcessTask;

PROCEDURE (processobj:ProcessObject) Init*;

BEGIN
  processobj.chable:=m.taskdata.maintask;

  processobj.InitTask(ProcessTask,processobj,10000,m.taskdata.requesterpri);
  processobj.SetID(tid.processTermsTaskID);
  processobj.Init^;
END Init;

PROCEDURE (processobj:ProcessObject) Destruct*;

BEGIN
  processobj.Destruct^;
END Destruct;

BEGIN
  processwind:=NIL;
  mirrorwind:=NIL;
  derstr:="x";
  pxs:="0";
  COPY(ac.GetString(ac.Auto)^,pys);
(*  autopy:=TRUE;*)
  xstr:="0";
  ystr:="0";
(*  pxstr:="0";
  pystr:="0";*)
END ProcessRequester.

