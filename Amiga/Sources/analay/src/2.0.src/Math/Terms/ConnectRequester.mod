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


MODULE ConnectRequester;

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

VAR connectwind    * : wm.Window;

TYPE ConnectObject * = POINTER TO ConnectObjectDesc;
     ConnectObjectDesc * = RECORD(m.TaskDesc)
       chable      * : m.ChangeAble;
     END;

PROCEDURE (connectobj:ConnectObject) ConnectTerms*():BOOLEAN;

VAR subwind    : wm.SubWindow;
    wind       : I.WindowPtr;
    rast       : g.RastPortPtr;
    root       : gmb.Root;
    newfunc,
    delfunc,
    copyfunc,
    taketerm,
    delterm    : gmo.BooleanGadget;
    funclv,
    functermlv,
    termlv     : gmo.ListView;
    gadobj     : gmb.Object;
    glist      : I.GadgetPtr;
    mes        : I.IntuiMessagePtr;
    class      : LONGSET;
    msg        : m.Message;
    actfunc,
    actfuncterm,
    actterm,
    node,node2,
    node3      : l.Node;
    bool,ret,
    copyfb     : BOOLEAN;

PROCEDURE RefreshFunc;

BEGIN
  IF actfunc#NIL THEN
    funclv.SetString(actfunc(t.Function).name);
    funclv.ChangeListViewSpecial(SHORT(t.NumberNotBaseFuncs()),t.PrintNotBaseFunction);
    funclv.SetValue(t.GetFuncNodeNumber(t.functions,actfunc));

    functermlv.ChangeListView(actfunc(t.Function).terms,SHORT(actfunc(t.Function).terms.GetNodeNumber(actfuncterm)));
  ELSE
    funclv.ChangeListViewSpecial(0,t.PrintNotBaseFunction);
  END;
END RefreshFunc;

PROCEDURE RefreshFuncTerm;

BEGIN
  IF actfunc#NIL THEN
    functermlv.SetNoEntryText(s.ADR("No terms!"));
    functermlv.ChangeListViewSpecial(-1,t.PrintFunctionTerm);
    functermlv.ChangeListView(actfunc(t.Function).terms,SHORT(actfunc(t.Function).terms.GetNodeNumber(actfuncterm)));
  ELSE
    functermlv.SetNoEntryText(s.ADR("No connection!"));
    functermlv.ChangeListViewSpecial(0,t.PrintFunctionTerm);
  END;
END RefreshFuncTerm;

PROCEDURE RefreshTerm;

BEGIN
  IF actterm#NIL THEN
    termlv.SetValue(t.terms.GetNodeNumber(actterm));
  ELSE
    termlv.Refresh;
  END;
END RefreshTerm;

BEGIN
  t.terms.NewUser(connectobj,TRUE);
  t.functions.NewUser(connectobj,TRUE);
  NEW(mes);
  ret:=FALSE;
  IF connectwind=NIL THEN
    connectwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.ConnectFunctions),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=connectwind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.horizBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      funclv:=gmo.SetListView(ac.GetString(ac.Connections),t.functions,t.PrintNotBaseFunction,0,TRUE,255);
      newfunc:=gmo.SetBooleanGadget(ac.GetString(ac.NewConnection),FALSE);
      delfunc:=gmo.SetBooleanGadget(ac.GetString(ac.DelConnection),FALSE);
      copyfunc:=gmo.SetBooleanGadget(ac.GetString(ac.CopyConnection),TRUE);
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        functermlv:=gmo.SetListView(ac.GetString(ac.ConnectedFunctions),NIL,t.PrintFunctionTerm,0,FALSE,255);
        termlv:=gmo.SetListView(ac.GetString(ac.Functions),t.terms,t.PrintTerm,0,FALSE,255);
      gmb.EndBox;
      taketerm:=gmo.SetBooleanGadget(ac.GetString(ac.InsertFunction),FALSE);
      delterm:=gmo.SetBooleanGadget(ac.GetString(ac.DelFunction),FALSE); (* DelFunctionCreateWindow? *)
    gmb.EndBox;
  glist:=root.EndRoot();
  funclv.SetNoEntryText(s.ADR("No connections!"));
  functermlv.SetNoEntryText(s.ADR("No terms!"));
  termlv.SetNoEntryText(s.ADR("No terms!"));

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    actfunc:=t.GetFuncNode(t.functions,funclv.GetValue());
    IF actfunc#NIL THEN
      actfuncterm:=actfunc(t.Function).terms.GetNode(functermlv.GetValue());
    END;
    actterm:=t.terms.GetNode(termlv.GetValue());

    RefreshFunc;
    RefreshFuncTerm;
    RefreshTerm;

    copyfb:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF connectobj.msgsig IN class THEN
        REPEAT
          msg:=connectobj.ReceiveMsg();
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
            ELSIF msg.type=m.msgNodeChanged THEN
              RefreshFunc;
              RefreshFuncTerm;
              RefreshTerm;
            ELSIF msg.type=m.msgListChanged THEN
              IF (actfunc#NIL) & mem.Garbaged(actfunc) THEN (* Node has been removed from list *)
                funclv.SetValue(0);
                actfunc:=t.GetFuncNode(t.functions,funclv.GetValue());
                IF actfunc#NIL THEN
                  actfuncterm:=actfunc(t.Function).terms.GetNode(functermlv.GetValue());
                END;
              END;
              IF (actterm#NIL) & mem.Garbaged(actterm) THEN
                termlv.SetValue(0);
                actterm:=t.terms.GetNode(termlv.GetValue());
              END;
              RefreshFunc;
              RefreshFuncTerm;
              RefreshTerm;
            ELSIF msg.type=m.msgActivate THEN
              subwind.ToFront;
            ELSIF msg.type=m.msgNewPriority THEN
              connectobj.SetPriority(m.taskdata.requesterpri);
            END;
            msg.Reply;
          END;
        UNTIL msg=NIL;
      END;

      REPEAT
        root.GetIMes(mes);
        IF actfunc#NIL THEN
          funclv.GetString(actfunc(t.Function).name);
        END;
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            node:=t.functions.head;
            WHILE node#NIL DO
              IF NOT(node(t.Function).isbase) THEN
                node(t.Function).MakeDepend;
              END;
              node:=node.next;
            END;
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=newfunc.gadget THEN
            node:=NIL;
            NEW(node(t.Function));
            node(t.Function).Init;
            COPY(ac.GetString(ac.Connection)^,node(t.Function).name);
            node(t.Function).isbase:=FALSE;
            actfunc:=node;
            t.functions.AddTail(actfunc);
            actfuncterm:=NIL;
            RefreshFunc;
            RefreshFuncTerm;
          ELSIF mes.iAddress=delfunc.gadget THEN
            IF actfunc#NIL THEN
              node:=actfunc;
              LOOP
                node:=node.next;
                IF node=NIL THEN
                  EXIT;
                END;
                IF NOT(node(t.Function).isbase) THEN
                  EXIT;
                END;
              END;
              IF node=NIL THEN
                node:=actfunc;
                LOOP
                  node:=node.prev;
                  IF node=NIL THEN
                    EXIT;
                  END;
                  IF NOT(node(t.Function).isbase) THEN
                    EXIT;
                  END;
                END;
              END;
              actfunc.Remove;
              mem.NodeToGarbage(actfunc(t.Function));
              actfunc:=node;
              IF actfunc#NIL THEN
                actfuncterm:=actfunc(t.Function).terms.head;
              ELSE
                actfuncterm:=NIL;
              END;
              RefreshFunc;
              RefreshFuncTerm;
            END;
          ELSIF mes.iAddress=copyfunc.gadget THEN
            copyfb:=NOT(copyfb);
          ELSIF mes.iAddress=taketerm.gadget THEN
            IF (actfunc#NIL) AND (actterm#NIL) THEN
              actterm(t.Function).NewUser(NIL);
              node:=NIL;
              NEW(node(t.FuncTerm));
              node(t.FuncTerm).term:=actterm(t.Term);
              actfunc(t.Function).changed:=TRUE;
              actfuncterm:=node;
              actfunc(t.Function).terms.AddTail(node);
              RefreshFuncTerm;
            END;
          ELSIF mes.iAddress=delterm.gadget THEN
            IF actfuncterm#NIL THEN
              actfuncterm(t.FuncTerm).term.FreeUser(NIL);
              node:=actfuncterm.next;
              IF node=NIL THEN
                node:=actfuncterm.prev;
              END;
              actfuncterm.Remove;
              actfuncterm:=node;
              actfunc(t.Function).changed:=TRUE;
              RefreshFuncTerm;
            END;
          ELSIF mes.iAddress=funclv.stringgad THEN
            IF actfunc#NIL THEN
              funclv.Refresh;
              funclv.Activate;
            END;
          ELSIF mes.iAddress=funclv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              node:=actfunc;
              actfunc:=t.GetFuncNode(t.functions,funclv.GetValue());
              IF (node#NIL) AND (actfunc#NIL) THEN
                IF copyfb THEN
                  COPY(node(t.Function).name,actfunc(t.Function).name);
                  actfunc(t.Function).changed:=TRUE;
                  actfunc(t.Function).isbase:=FALSE;
  
                  IF actfunc(t.Function).depend#NIL THEN actfunc(t.Function).depend.Destruct; END;
                  actfunc(t.Function).depend:=l.Create();
                  node(t.Function).depend.Copy(actfunc(t.Function).depend);
  
                  IF actfunc(t.Function).define#NIL THEN actfunc(t.Function).define.Destruct; END;
                  actfunc(t.Function).define:=l.Create();
                  node(t.Function).define.Copy(actfunc(t.Function).define);
  
                  IF actfunc(t.Function).terms#NIL THEN actfunc(t.Function).terms.Destruct; END;
                  actfunc(t.Function).terms.Init;
                  node2:=node(t.Function).terms.head;
                  WHILE node2#NIL DO
                    node3:=NIL;
                    NEW(node3(t.FuncTerm));
                    node3(t.FuncTerm).term:=node2(t.FuncTerm).term;
                    actfunc(t.Function).terms.AddTail(node3);
                    node2:=node2.next;
                  END;
  (*                gm.DeActivateBool(copyf,wind);*)
                  copyfb:=FALSE;
                END;
              END;
              actfuncterm:=actfunc(t.Function).terms.head;
              RefreshFunc;
              RefreshFuncTerm;
            END;
          ELSIF mes.iAddress=functermlv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              IF actfunc#NIL THEN
                actfuncterm:=actfunc(t.Function).terms.GetNode(functermlv.GetValue());
              END;
            END;
          ELSIF mes.iAddress=termlv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              actterm:=t.terms.GetNode(termlv.GetValue());
            END;
          END;
        END;
  (*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"connectfuncs",wind);
        END;*)
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  t.functions.FreeUser(connectobj);
  t.terms.FreeUser(connectobj);
  RETURN ret;
END ConnectTerms;

PROCEDURE ConnectTask*(connecttask:bas.ANY):bas.ANY;

VAR bool : BOOLEAN;

BEGIN
  WITH connecttask: ConnectObject DO
    connecttask.InitCommunication;
    bool:=connecttask.ConnectTerms();

    connecttask.chable.RemTask(connecttask);
    connecttask.ReplyAllMessages;
    connecttask.DestructCommunication;
    mem.NodeToGarbage(connecttask);
    connecttask.chable.FreeUser(connecttask);
  END;
  IF bool THEN
    RETURN s.VAL(bas.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END ConnectTask;

PROCEDURE (connectobj:ConnectObject) Init*;

BEGIN
  connectobj.chable:=m.taskdata.maintask;

  connectobj.InitTask(ConnectTask,connectobj,10000,m.taskdata.requesterpri);
  connectobj.SetID(tid.connectTaskID);
  connectobj.Init^;
END Init;

PROCEDURE (connectobj:ConnectObject) Destruct*;

BEGIN
  connectobj.Destruct^;
END Destruct;

BEGIN
  connectwind:=NIL;
END ConnectRequester.

