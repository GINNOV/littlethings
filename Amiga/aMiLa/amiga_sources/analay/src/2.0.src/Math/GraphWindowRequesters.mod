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


MODULE GraphWindowRequesters;

(* COPY-call in QuickInput may cause problems due to the different string
   lengths. *)

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       gd : GadTools,
       st : Strings,
       lrc: LongRealConversions,
       ac : AnalayCatalog,
       wm : WindowManager,
       tt : TextTools,
       rt : RequesterTools,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       go : GraphicObjects,
       fb : FunctionBasics,
       ft : FunctionTrees,
       mb : MathBasics,
       mg : MathGUI,
       m  : Multitasking,
       mem: MemoryManager,
       tid: TaskIDs,
       w  : Window,
       t  : Terms,
       ter: EnterTermsRequester,
       fg : FunctionGraph,
       gr : Grid,
       al : AxisLabels,
       co : Coords,
       wf : WindowFunction,
       gw : GraphWindow,
       gb : GraphObject,
       to : TextObject,
       pmo: PointMarkObject,
       lc : LayoutConversion,
       cc : Concurrency,
       bt : BasicTypes,
       io,
       NoGuruRq;

VAR plotwind        * ,
    quickinputwind  * : wm.Window;

TYPE NewListEl = RECORD(l.NodeDesc) (* Used by PlotMenu *)
       node : l.Node;
     END;

TYPE PlotMenuObject * = POINTER TO PlotMenuDesc;
     PlotMenuDesc * = RECORD(m.TaskDesc)
       chable      * : m.ChangeAble;
     END;

PROCEDURE (plotobj:PlotMenuObject) PlotMenu*():BOOLEAN;

VAR subwind          : wm.SubWindow;
    wind             : I.WindowPtr;
    rast             : g.RastPortPtr;
    root             : gmb.Root;
    newwind,delwind,
    copywind,appwind,
    takefunc,delfunc : gmo.BooleanGadget;
    windlv,windfunclv,
    funclv           : gmo.ListView;
    gadobj           : gmb.Object;
    glist            : I.GadgetPtr;
    mes              : I.IntuiMessagePtr;
    msg              : m.Message;
    class            : LONGSET;
    actwind,
    actwindfunc,
    actfunc,
    node,node2,node3 : l.Node;
    dellist,newlist  : l.List;
    bool,ret,copywb,
    appwb            : BOOLEAN;
    pos              : INTEGER;

PROCEDURE RefreshWind;

BEGIN
  IF actwind#NIL THEN
    windlv.SetString(actwind(gw.GraphWindow).windname);
    windlv.SetValue(gw.graphwindows.GetNodeNumber(actwind));
  ELSE
    windlv.Refresh;
  END;
END RefreshWind;

PROCEDURE RefreshWindFunc;

BEGIN
  IF actwind#NIL THEN
    windfunclv.SetNoEntryText(s.ADR("No functions!"));
    windfunclv.ChangeListViewSpecial(-1,wf.PrintWindowFunction);
    windfunclv.ChangeListView(actwind(gw.GraphWindow).funcs,SHORT(actwind(gw.GraphWindow).funcs.GetNodeNumber(actwindfunc)));
  ELSE
    windfunclv.SetNoEntryText(s.ADR("No windows!"));
    windfunclv.ChangeListViewSpecial(0,wf.PrintWindowFunction);
  END;
(*  IF actwind#NIL THEN
    gm.SetListViewParams(windfunclist,176,28,200,84,SHORT(actwind(s1.Fenster).funcs.nbElements()),s1.GetNodeNumber(actwind(s1.Fenster).funcs,actwindfunc),s2.Printwf.WindowFunction);
    gm.SetNoEntryText(windfunclist,ac.GetString(ac.None),ac.GetString(ac.FunctionsEx));
    gm.SetCorrectPosition(windfunclist);
  ELSE
    gm.SetListViewParams(windfunclist,176,28,200,84,0,0,s2.Printwf.WindowFunction);
    gm.SetNoEntryText(windfunclist,ac.GetString(ac.NoWindow),ac.GetString(ac.SelectedEx));
    gm.SetCorrectPosition(windfunclist);
  END;*)
END RefreshWindFunc;

PROCEDURE RefreshFunc;

BEGIN
  IF actfunc#NIL THEN
    funclv.SetValue(t.functions.GetNodeNumber(actfunc));
  ELSE
    funclv.Refresh;
  END;
END RefreshFunc;

BEGIN
  gw.graphwindows.NewUser(plotobj,TRUE);
  t.functions.NewUser(plotobj,TRUE);
  NEW(mes);
  dellist:=l.Create();
  newlist:=l.Create();

  ret:=FALSE;
  IF plotwind=NIL THEN
    plotwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.EnterFunctions),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=plotwind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.horizBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      windlv:=gmo.SetListView(ac.GetString(ac.Windows),gw.graphwindows,w.PrintWindow,0,TRUE,255);
      newwind:=gmo.SetBooleanGadget(ac.GetString(ac.NewWindow),FALSE);
      delwind:=gmo.SetBooleanGadget(ac.GetString(ac.DelWindow),FALSE);
      copywind:=gmo.SetBooleanGadget(ac.GetString(ac.CopyWindow),TRUE);
      appwind:=gmo.SetBooleanGadget(ac.GetString(ac.AppendWindow),TRUE);
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        windfunclv:=gmo.SetListView(ac.GetString(ac.SelectedFunctions),NIL,wf.PrintWindowFunction,0,FALSE,255);
        funclv:=gmo.SetListView(ac.GetString(ac.AvailableFunctions),t.functions,t.PrintFunction,0,FALSE,255);
      gmb.EndBox;
      takefunc:=gmo.SetBooleanGadget(ac.GetString(ac.InsertFunction),FALSE);
      delfunc:=gmo.SetBooleanGadget(ac.GetString(ac.DelFunction),FALSE); (* DelFunctionCreateWindow? *)
    gmb.EndBox;
  glist:=root.EndRoot();
  windlv.SetNoEntryText(s.ADR("No windows!"));
  windfunclv.SetNoEntryText(s.ADR("No functions!"));
  funclv.SetNoEntryText(s.ADR("No functions!"));

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    actwind:=gw.graphwindows.GetNode(windlv.GetValue());
    IF actwind#NIL THEN
      actwindfunc:=actwind(gw.GraphWindow).funcs.GetNode(windfunclv.GetValue());
    ELSE
      actwindfunc:=NIL;
    END;
    actfunc:=t.functions.GetNode(funclv.GetValue());

    RefreshWind;
    RefreshWindFunc;
    RefreshFunc;

    copywb:=FALSE;
    appwb:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF plotobj.msgsig IN class THEN
        REPEAT
          msg:=plotobj.ReceiveMsg();
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
              RefreshWind;
              RefreshWindFunc;
              RefreshFunc;
            ELSIF msg.type=m.msgActivate THEN
              subwind.ToFront;
            ELSIF msg.type=m.msgListChanged THEN
              IF msg.data=gw.graphwindows THEN
                IF ((actwind#NIL) AND (actwind.list=NIL)) OR (actwind=NIL) THEN
                  actwind:=gw.graphwindows.head;
                  IF actwind#NIL THEN
                    actwindfunc:=actwind(gw.GraphWindow).funcs.head;
                  ELSE
                    actwindfunc:=NIL;
                  END;
                END;
                RefreshWind;
                RefreshWindFunc;
              ELSIF msg.data=t.functions THEN
                IF ((actfunc#NIL) & mem.Garbaged(actfunc)) OR (actfunc=NIL) THEN
                  actfunc:=t.functions.head;
                END;
                RefreshFunc;
              END;
            ELSIF msg.type=m.msgNewPriority THEN
              plotobj.SetPriority(m.taskdata.requesterpri);
            END;
            msg.Reply;
          END;
        UNTIL msg=NIL;
      END;

      REPEAT
        root.GetIMes(mes);
        IF actwind#NIL THEN
          windlv.GetString(actwind(gw.GraphWindow).windname);
        END;
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
  (*          node:=dellist.RemHead();*)
  (*          node:=dellist.head;
            WHILE node#NIL DO
              node(gw.GraphWindow).Close;
              node2:=newlist.head;
              WHILE node2#NIL DO
                node3:=node2.next;
                IF node2(NewListEl).node=node THEN
                  node2.Remove;
                END;
                node2:=node3;
              END;
              actwind:=node;
              node:=node.next;
              mem.NodeToGarbage(actwind(gw.GraphWindow));
  (*            node:=dellist.RemHead();*)
            END;*)
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=newwind.gadget THEN
            node:=NIL;
            NEW(node(gw.GraphWindow)); node.Init;
            gw.graphwindows.AddTail(node);
            node(m.Task).InitTask(gw.GraphWindTask,NIL,10000,m.taskdata.windowpri);
            bool:=node(m.Task).Start();
            actwind:=node;
            actwindfunc:=NIL;
            RefreshWind;
            RefreshWindFunc;
  
            node:=NIL;
            NEW(node(NewListEl));
            node(NewListEl).node:=actwind;
            newlist.AddTail(node);
          ELSIF mes.iAddress=delwind.gadget THEN
            IF actwind#NIL THEN
              node:=actwind.next;
              IF node=NIL THEN
                node:=actwind.prev;
              END;
  
              actwind.Remove;
              actwind(m.Task).SendNewMsg(m.msgQuit,NIL);
  (*            dellist.AddTail(actwind);*)
  
              actwind:=node;
              IF actwind#NIL THEN
                actwindfunc:=actwind(gw.GraphWindow).funcs.head;
              ELSE
                actwindfunc:=NIL;
              END;
              RefreshWind;
              RefreshWindFunc;
            END;
          ELSIF mes.iAddress=copywind.gadget THEN
            copywb:=NOT(copywb);
            IF appwb THEN
  (*            gm.DeActivateBool(appw,wind);*)
            END;
            appwb:=FALSE;
          ELSIF mes.iAddress=appwind.gadget THEN
            appwb:=NOT(appwb);
            IF copywb THEN
  (*            gm.DeActivateBool(copyw,wind);*)
            END;
            copywb:=FALSE;
          ELSIF mes.iAddress=takefunc.gadget THEN
            IF (actfunc#NIL) AND (actwind#NIL) THEN
              subwind.SetBusyPointer;
              actwind(m.LockAble).Lock(FALSE);
              node:=NIL;
              NEW(node(wf.WindowFunction));
              node.Init;
              node(wf.WindowFunction).func:=actfunc(t.Function);
              node(wf.WindowFunction).window:=actwind(gw.GraphWindow);
              actfunc(t.Function).NewUser(actwind(gw.GraphWindow));
              node(wf.WindowFunction).changed:=TRUE;
              actwindfunc:=node;
              actwind(gw.GraphWindow).funcs.AddTail(node(wf.WindowFunction));
              actwind(gw.GraphWindow).changed:=TRUE;
              actwind(m.LockAble).UnLock;
              actwind(m.Task).SendNewMsg(m.msgNodeChanged,NIL);
              subwind.ClearPointer;
              RefreshWindFunc;
            END;
          ELSIF mes.iAddress=delfunc.gadget THEN
            IF (actwindfunc#NIL) AND (actwind#NIL) THEN
              subwind.SetBusyPointer;
              actwind(m.LockAble).Lock(FALSE);
              node:=actwindfunc.next;
              IF node=NIL THEN
                node:=actwindfunc.prev;
              END;
              actwindfunc.Remove;
              actwindfunc(wf.WindowFunction).func.FreeUser(actwind(gw.GraphWindow));
              actwindfunc.Destruct;
              actwindfunc:=node;
              actwind(gw.GraphWindow).changed:=TRUE;
              actwind(m.LockAble).UnLock;
              actwind(m.Task).SendNewMsg(m.msgNodeChanged,NIL);
              subwind.ClearPointer;
              RefreshWindFunc;
            END;
          ELSIF mes.iAddress=windlv.stringgad THEN
            windlv.Refresh;
            windlv.Activate;
          ELSIF mes.iAddress=windlv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              node:=actwind;
              actwind:=gw.graphwindows.GetNode(windlv.GetValue());
              IF (node#NIL) AND (actwind#NIL) THEN
                IF (copywb) OR (appwb) THEN
                  IF copywb THEN
  (*                  gm.DeActivateBool(copyw,wind);*)
                    copywb:=FALSE;
                    actwind(gw.GraphWindow).funcs.Init;
                  ELSIF appwb THEN
  (*                  gm.DeActivateBool(appw,wind);*)
                    appwb:=FALSE;
                  END;
                  node2:=node(gw.GraphWindow).funcs.head;
                  WHILE node2#NIL DO
                    node:=NIL;
                    NEW(node(wf.WindowFunction));
                    node.Init;
                    node(wf.WindowFunction).func:=node2(wf.WindowFunction).func;
                    node(wf.WindowFunction).changed:=TRUE;
                    actwind(gw.GraphWindow).funcs.AddTail(node);
                    node2:=node2.next;
                  END;
                  actwind(gw.GraphWindow).changed:=TRUE;
                  actwindfunc:=node;
                  RefreshWindFunc;
                END;
              END;
              actwindfunc:=actwind(gw.GraphWindow).funcs.head;
              RefreshWind;
              RefreshWindFunc;
            END;
          ELSIF mes.iAddress=windfunclv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              IF actwind#NIL THEN
                actwindfunc:=actwind(gw.GraphWindow).funcs.GetNode(windfunclv.GetValue());
              END;
            END;
          ELSIF mes.iAddress=funclv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              actfunc:=t.functions.GetNode(funclv.GetValue());
            END;
          END;
        END;
  (*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"plotfuncs",wind);
        END;*)
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
  END;
  root.Destruct;
(*  node:=newlist.head;
  WHILE node#NIL DO
(*    node(NewListEl).node(m.LockAble).SendNew;*)
    node:=node.next;
  END;*)

  dellist.Destruct;
  newlist.Destruct;
  DISPOSE(mes);
  t.functions.FreeUser(plotobj);
  gw.graphwindows.FreeUser(plotobj);
  RETURN ret;
END PlotMenu;

PROCEDURE PlotMenuTask*(plottask:bt.ANY):bt.ANY;

VAR bool : BOOLEAN;

BEGIN
  WITH plottask: PlotMenuObject DO
    plottask.InitCommunication;
    bool:=plottask.PlotMenu();

    plottask.chable.RemTask(plottask);
    plottask.ReplyAllMessages;
    plottask.DestructCommunication;
    mem.NodeToGarbage(plottask);
    plottask.chable.FreeUser(plottask);
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END PlotMenuTask;

PROCEDURE (plotobj:PlotMenuObject) Init*;

BEGIN
  plotobj.chable:=m.taskdata.maintask;

  plotobj.InitTask(PlotMenuTask,plotobj,10000,m.taskdata.requesterpri);
  plotobj.SetID(tid.plotMenuTaskID);
  plotobj.Init^;
END Init;

PROCEDURE (plotobj:PlotMenuObject) Destruct*;

BEGIN
  plotobj.Destruct^;
END Destruct;



TYPE QuickInputObject * = POINTER TO QuickInputDesc;
     QuickInputDesc * = RECORD(m.TaskDesc)
       chable      * : m.ChangeAble;
     END;

PROCEDURE (quickobj:QuickInputObject) QuickInput*():BOOLEAN;

VAR subwind          : wm.SubWindow;
    wind             : I.WindowPtr;
    rast             : g.RastPortPtr;
    root             : gmb.Root;
    funcgad          : gmo.StringGadget;
    gadobj           : gmb.Object;
    glist            : I.GadgetPtr;
    mes              : I.IntuiMessagePtr;
    class            : LONGSET;
    msg              : m.Message;
    term             : t.Term;
    func             : t.Function;
    functerm         : t.FuncTerm;
    graphwind        : gw.GraphWindow;
    windfunc         : wf.WindowFunction;
    bool,ret         : BOOLEAN;
    node     : l.Node;
    pos,bcount,
    err      : INTEGER;
    sinfo    : I.StringInfoPtr;
    text     : POINTER TO ARRAY OF ARRAY OF CHAR;

BEGIN
  NEW(mes);
  ret:=FALSE;

  IF quickinputwind=NIL THEN
    quickinputwind:=wm.InitWindow(wm.centered,wm.centered,10,10,TRUE,ac.GetString(ac.QuickEnter),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=quickinputwind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmo.SetText(ac.GetString(ac.EnterFunction),-1);
    funcgad:=gmo.SetStringGadget(NIL,t.maxtermchars,gmo.stringType);
  glist:=root.EndRoot();

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;
    funcgad.Activate;

    NEW(text,4,80);

    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF quickobj.msgsig IN class THEN
        REPEAT
          msg:=quickobj.ReceiveMsg();
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
            ELSIF msg.type=m.msgActivate THEN
              subwind.ToFront;
            ELSIF msg.type=m.msgNewPriority THEN
              quickobj.SetPriority(m.taskdata.requesterpri);
            END;
            msg.Reply;
          END;
        UNTIL msg=NIL;
      END;

      REPEAT
        root.GetIMes(mes);
        IF I.gadgetUp IN mes.class THEN
          IF (mes.iAddress=root.ok) OR (mes.iAddress=funcgad.gadget) THEN
            NEW(term);
            term.Init;
(*            term.changed:=TRUE;*)
            funcgad.GetString(term.term^);
            ft.SyntaxCheck(term.term^,pos,bcount,err);
            IF err=0 THEN
              t.terms.AddTail(term);
              term.NewUser(NIL);
              NEW(func);
              func.Init;
              func.isbase:=TRUE;
              NEW(functerm);
              functerm.Init;
              functerm.term:=term;
              func.terms.AddTail(functerm);
              term.basefunc:=func;
              COPY(term.term^,func.name);
(*              func.changed:=TRUE;*)
              t.functions.AddTail(func);
              func.MakeDepend;

              graphwind:=NIL;
              NEW(graphwind); graphwind.Init;
              COPY(term.term^,graphwind.windname);
              gw.graphwindows.AddTail(graphwind);
              graphwind.InitTask(gw.GraphWindTask,NIL,10000,m.taskdata.windowpri);

              windfunc:=NIL;
              NEW(windfunc);
              windfunc.Init;
              windfunc.func:=func;
              windfunc.window:=graphwind;
              windfunc.changed:=TRUE;
              graphwind.funcs.AddTail(windfunc);
              graphwind.changed:=TRUE;
              func.NewUser(graphwind);

              bool:=graphwind.Start();
              EXIT;
            ELSE
              ter.BuildUpFuncErrorReq(term,err,pos,text^);
              bool:=rt.Request(text^,"",ac.GetString(ac.OK)^,wind);
  (*            sinfo:=term.specialInfo;
              sinfo.dispPos:=pos;
              sinfo.bufferPos:=pos;
              I.RefreshGList(term,wind,NIL,1);*)
              funcgad.Activate;
              term.Destruct;
            END;
          ELSIF mes.iAddress=root.ca THEN
            EXIT;
          END;
        END;
  (*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"quickenter",wind);
        END;*)
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  RETURN bool;
END QuickInput;

PROCEDURE QuickInputTask*(quicktask:bt.ANY):bt.ANY;

VAR bool : BOOLEAN;

BEGIN
  WITH quicktask: QuickInputObject DO
    quicktask.InitCommunication;
    bool:=quicktask.QuickInput();

    quicktask.chable.RemTask(quicktask);
    quicktask.ReplyAllMessages;
    quicktask.DestructCommunication;
    mem.NodeToGarbage(quicktask);
    quicktask.chable.FreeUser(quicktask);
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END QuickInputTask;

PROCEDURE (plotobj:QuickInputObject) Init*;

BEGIN
  plotobj.chable:=m.taskdata.maintask;

  plotobj.Init^;
  plotobj.InitTask(QuickInputTask,plotobj,20000,m.taskdata.requesterpri);
  plotobj.SetID(tid.quickInputTaskID);
END Init;

PROCEDURE (plotobj:QuickInputObject) Destruct*;

BEGIN
  plotobj.Destruct^;
END Destruct;



BEGIN
  plotwind:=NIL;
  quickinputwind:=NIL;
END GraphWindowRequesters.

