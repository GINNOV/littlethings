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


MODULE Analay;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       r  : Requests,
       l  : LinkedLists,
       loc: Locale,
       ac : AnalayCatalog,
       bt : BasicTools,
       rt : RequesterTools,
       fo : FontOrganizer,
       ai : AnalayInfo,
       gb : GeneralBasics,
       gg : GeneralGUI,
       mb : MathBasics,
       mg : MathGUI,
       sr : SettingsRequesters,
       t  : Terms,
       ter: EnterTermsRequester,
       tdr: DefineRequester,
       tcr: ConnectRequester,
       tpr: ProcessRequester,
       w  : Window,
       gw : GraphWindow,
       gwr: GraphWindowRequesters,
       lw : Legend,
       m  : Multitasking,
       mem: MemoryManager,
       tid: TaskIDs,
       to : TextObject,
       ito: IntegrationObject,
       vs : VersionStrings,
       cc : Concurrency,
       ol : OberonLib,
       lm : Layout,
       kf : KeyFiles,
       btp: BasicTypes,
       io,
       NoGuruRq;

VAR class : LONGSET;
    mes   : I.IntuiMessagePtr;
    msg   : m.Message;
    quit,                       (* Set to true to quit Analay *)
    bool  : BOOLEAN;

    text  : POINTER TO ARRAY OF ARRAY OF CHAR;



PROCEDURE SendNewMsgToAllTasks(type:LONGINT;data:e.APTR);

VAR task : l.Node;

BEGIN
  m.taskdata.maintask.SendNewMsgToAllTasks(type,s.VAL(l.Node,data));
  task:=gw.graphwindows.head;
  WHILE task#NIL DO
    task(m.Task).SendNewMsg(type,data);
    task:=task.next;
  END;
  task:=lw.legends.head;
  WHILE task#NIL DO
    task(m.Task).SendNewMsg(type,data);
    task:=task.next;
  END;
END SendNewMsgToAllTasks;

PROCEDURE CloseDown;

VAR node,next : l.Node;

BEGIN
  SendNewMsgToAllTasks(m.msgQuit,NIL);
(*  m.taskdata.maintask.SendNewMsgToAllTasks(m.msgQuit,NIL);

  node:=gw.graphwindows.head;
  WHILE node#NIL DO
    next:=node.next;
    node(m.Task).SendNewMsg(m.msgQuit,NIL);
    node:=next;
  END;*)

  mem.ListToGarbage(t.functions);
  mem.ListToGarbage(t.terms);

  mem.ClearMemory;
  cc.WaitForAllProcesses; (* Could deadlock the system because Layout Mode
                             might wait for some windows to be closed which are
                             never closed because the owning task has chrashed! *)
  m.taskdata.maintask.ReplyAllMessages;
  m.taskdata.maintask.DestructCommunication;
  mem.ClearMemory;
END CloseDown;

PROCEDURE ChangeScreenMode;

VAR screen : I.ScreenPtr;

BEGIN
  SendNewMsgToAllTasks(m.msgClose,m.typeScreenMode);
  screen:=I.LockPubScreen("Workbench");
  IF mg.screen#screen THEN
    WHILE (mg.screen.firstWindow#NIL) & (mg.screen.firstWindow.nextWindow#NIL) DO
      d.Delay(50);
    END;
  END;
  I.UnlockPubScreen("Workbench",screen);
  mg.Close;
  mg.Init;
  SendNewMsgToAllTasks(m.msgOpen,m.typeScreenMode);
END ChangeScreenMode;

PROCEDURE DoMenu(code:INTEGER);

(* IMPORTANT: Actually a MTList should be NewUsered before calling
              gb.SelectNode since the selected node could be
              destructed until we use the returned pointer! *)

VAR node,node2,node3 : l.Node;
    task             : m.Task;
    strip,item,sub   : LONGINT;
    bool             : BOOLEAN;

BEGIN
(*  IF sv1.windactscreen=NIL THEN
    sv1.windactscreen:=s1.window;
  END;*)
  strip:=I.MenuNum(code);
  item:=I.ItemNum(code);
  sub:=I.SubNum(code);
  IF strip=0 THEN
    IF item=0 THEN
(*      bool:=fr.FileReqWin(ac.GetString(ac.LoadDocument)^,sv1.docname,sv1.windactscreen);
      IF bool THEN
        s4.CloseAll;
        s2.SetAllPointers(TRUE);
        bool:=sv.RawLoadDocument(sv1.docname);
        p1.rulerchanged:=TRUE;
        e.Signal(s1.prevtask,LONGSET{s1.prevnewobj});
        PlotAll;
        IF NOT(bool) THEN
          bool:=rt.RequestWin(ac.GetString(ac.CouldntOpenFile1),ac.GetString(ac.CouldntOpenFile2),s.ADR(""),ac.GetString(ac.OK),sv1.windactscreen);
        END;
        class:=LONGSET{};
        s2.SetAllPointers(FALSE);
        s1.loadsave:=-1;
      END;
    ELSIF item=1 THEN
      IF NOT(kf.demo) THEN
        s2.SetAllPointers(TRUE);
        s2.GetWindowSizes;
        bool:=sv1.RawSaveDocument(sv1.docname);
        IF NOT(bool) THEN
          bool:=rt.RequestWin(ac.GetString(ac.CouldntOpenFile1),ac.GetString(ac.CouldntOpenFile2),s.ADR(""),ac.GetString(ac.OK),sv1.windactscreen);
        END;
        s2.SetAllPointers(FALSE);
      ELSE
        kf.NotInDemo(sv1.windactscreen);
      END;
    ELSIF item=2 THEN
      IF NOT(kf.demo) THEN
        s2.SetAllPointers(TRUE);
        s2.GetWindowSizes;
        bool:=sv1.SaveDocument();
        s2.SetAllPointers(FALSE);
      ELSE
        kf.NotInDemo(sv1.windactscreen);
      END;*)
    ELSIF item=4 THEN
(*(*      ResizeAll(FALSE);
      s14.Preview;
      ResizeAll(TRUE);*)
      e.Signal(s1.prevtask,LONGSET{s1.prevtoact});*)
      m.taskdata.layouttask.SendNewMsg(m.msgOpen,NIL);
    ELSIF item=6 THEN
      task:=m.taskdata.maintask.FindTask(tid.analayInfoTaskID);
      IF task=NIL THEN
        NEW(task); task.Init;
        task.InitTask(ai.AnalayInfoTask,NIL,10000,m.taskdata.requesterpri);
        task.SetID(tid.analayInfoTaskID);
        m.taskdata.maintask.AddTask(task);
        m.taskdata.maintask.NewUser(task);
        bool:=task.Start();
      ELSE
        task.SendNewMsg(m.msgActivate,NIL);
      END;

(*      bool:=rt.Request(text^,"",ac.GetString(ac.OK)^,mg.window);*)
(*      ai.Information(s1.screen);*)
(*      bool:=rt.Request(s1.infotext^,"","   OK   ",s1.window);*)
    ELSIF item=7 THEN
      quit:=TRUE;
    END;
  ELSIF strip=1 THEN
    IF item=0 THEN
      task:=m.taskdata.maintask.FindTask(tid.enterTermsTaskID);
      IF task=NIL THEN
        NEW(task(ter.EnterTermsObject)); task.Init;
        m.taskdata.maintask.AddTask(task);
        m.taskdata.maintask.NewUser(task);
        bool:=task.Start();
      ELSE
        task.SendNewMsg(m.msgActivate,NIL);
      END;
(*      bool:=tr.EnterTerms();*)
(*      gw.graphwindows.Refresh;*)
(*      PlotAll;
      s9.RefreshLegends;*)
    ELSIF item=1 THEN
      task:=m.taskdata.maintask.FindTask(tid.defineTaskID);
      IF task=NIL THEN
        NEW(task(tdr.DefineObject)); task.Init;
        m.taskdata.maintask.AddTask(task);
        m.taskdata.maintask.NewUser(task);
        bool:=task.Start();
      ELSE
        task.SendNewMsg(m.msgActivate,NIL);
      END;
(*      bool:=tr.ChangeDefine();*)
(*      gw.graphwindows.Refresh;*)
(*      PlotAll;*)
    ELSIF item=2 THEN
      task:=m.taskdata.maintask.FindTask(tid.connectTaskID);
      IF task=NIL THEN
        NEW(task(tcr.ConnectObject)); task.Init;
        m.taskdata.maintask.AddTask(task);
        m.taskdata.maintask.NewUser(task);
        bool:=task.Start();
      ELSE
        task.SendNewMsg(m.msgActivate,NIL);
      END;
(*      bool:=tr.ConnectTerms();*)
(*      gw.graphwindows.Refresh;*)
(*      PlotAll;*)
    ELSIF item=3 THEN
      task:=m.taskdata.maintask.FindTask(tid.processTermsTaskID);
      IF task=NIL THEN
        NEW(task(tpr.ProcessObject)); task.Init;
        m.taskdata.maintask.AddTask(task);
        m.taskdata.maintask.NewUser(task);
        bool:=task.Start();
      ELSE
        task.SendNewMsg(m.msgActivate,NIL);
      END;
(*      bool:=tr.ProcessFunctions();*)
(*      gw.graphwindows.Refresh;*)
(*    ELSIF item=4 THEN
      bool:=s4.ChangeConstants();*)
    ELSIF item=6 THEN
      task:=m.taskdata.maintask.FindTask(tid.quickInputTaskID);
      IF task=NIL THEN
        NEW(task(gwr.QuickInputObject)); task.Init;
        m.taskdata.maintask.AddTask(task);
        m.taskdata.maintask.NewUser(task);
        bool:=task.Start();
      ELSE
        task.SendNewMsg(m.msgActivate,NIL);
      END;
(*      bool:=gwr.QuickInput();*)
(*      gw.graphwindows.Refresh;*)
    END;
  ELSIF strip=2 THEN
    IF item=0 THEN
      task:=m.taskdata.maintask.FindTask(tid.plotMenuTaskID);
      IF task=NIL THEN
        NEW(task(gwr.PlotMenuObject)); task.Init;
        m.taskdata.maintask.AddTask(task);
        m.taskdata.maintask.NewUser(task);
        bool:=task.Start();
      ELSE
        task.SendNewMsg(m.msgActivate,NIL);
      END;
(*      bool:=gwr.PlotMenu();*)
(*      gw.graphwindows.Refresh;*)
(*      PlotAll;
      s9.RefreshLegends;*)
    ELSIF item=1 THEN  (* Fenstereinstellungen *)
      node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
      IF node#NIL THEN
        node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
      END;
(*      node:=s2.SelectNode(s1.fenster,ac.GetString(ac.SelectWindow),ac.GetString(ac.AtTheMomentNo),ac.GetString(ac.WindowsAreDisplayed));
      IF node#NIL THEN
        ok:=s8.FensterOptions(node);
        IF (ok) AND (node(s1.Fenster).refresh) THEN
          s2.ResizeWindow(node);
          s1.ChangeNode(node);
          PlotAll;
(*          PlotWind(node);*)
        END;
      END;*)
    ELSIF item=3 THEN  (* Achsenbereich *)
      node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
      IF node#NIL THEN
        node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
      END;
(*      node:=s2.SelectNode(s1.fenster,ac.GetString(ac.SelectWindow),ac.GetString(ac.AtTheMomentNo),ac.GetString(ac.WindowsAreDisplayed));
      IF node#NIL THEN
        s1.NewNodeShare(node);
        reqnode:=NIL;
        NEW(reqnode(s1.ReqNode));
        data:=NIL;
        NEW(data(s1.ReqData));
        data(s1.ReqData).reqnode:=reqnode;
        data(s1.ReqData).wind:=node;
        proc:=cc.NewProcessX(s7.ChangeBereich,data,10000,s1.reqpri);
        reqnode(s1.ReqNode).task:=s.VAL(e.TaskPtr,proc.dosProcess);
        node(s1.ChangeAble).reqtasklist.AddTail(reqnode);
(*        ok:=s5.ChangeBereich(node);
        IF ok THEN
          node2:=node(s1.Fenster).funcs.head;
          WHILE node2#NIL DO
            node3:=node2(s1.FensterFunc).graphs.head;
            WHILE node3#NIL DO
              node3(s1.FunctionGraph).calced:=FALSE;
              node3:=node3.next;
            END;
            node2:=node2.next;
          END;
          Auto(node);
          PlotWind(node(s1.Fenster));
        END;*)
(*        ELSE
          ok:=s2.ChangeBereich(s1.mish[i-100]);
          IF ok THEN
            a:=-1;
            WHILE a<9 DO
              INC(a);
              s1.mish[i-100].calced[a]:=FALSE;
            END;
            PlotWind(s1.mish[i-100]);
          END;*)
      END;*)
    ELSIF item=4 THEN  (* Skala *)
      node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
      IF node#NIL THEN
        node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
      END;
(*      node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
      bool:=node(gw.GraphWindow).axislabels.Change();
      gw.graphwindows.Refresh;*)
    ELSIF item=5 THEN  (* Gitter *)
      node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
      IF node#NIL THEN
        node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
      END;
    ELSIF item=6 THEN  (* Aussehen *)
      node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
      IF node#NIL THEN
        node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
      END;
    ELSIF item=8 THEN
      IF sub=0 THEN
        node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
        IF node#NIL THEN
          node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
        END;
      ELSIF sub=1 THEN
        node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
        IF node#NIL THEN
          node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
        END;
      ELSIF sub=2 THEN
        node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
        IF node#NIL THEN
          node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
        END;
      ELSIF sub=4 THEN
(*        bool:=to.stdtextobj.Change();*)
      END;
    ELSIF item=9 THEN
      IF sub=0 THEN
        node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
        IF node#NIL THEN
          node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
        END;
      ELSIF sub=1 THEN
        node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
        IF node#NIL THEN
          node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
        END;
      ELSIF sub=2 THEN
        node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
        IF node#NIL THEN
          node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
        END;
      ELSIF sub=4 THEN
(*        ok:=s12.ChangePoint(s1.std.wind,s1.std.point);*)
      END;
    ELSIF item=11 THEN
      IF sub=0 THEN
        node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
        IF node#NIL THEN
          node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
        END;
      ELSIF sub=1 THEN
        node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
        IF node#NIL THEN
          node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
        END;
      ELSIF sub=2 THEN
        node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
        IF node#NIL THEN
          node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
        END;
      ELSIF sub=4 THEN
(*        bool:=to.stdtextobj.Change();*)
      END;
(*    ELSIF item=10 THEN
      IF sub=0 THEN
        node:=s2.SelectNode(s1.fenster,ac.GetString(ac.SelectWindow),ac.GetString(ac.AtTheMomentNo),ac.GetString(ac.WindowsAreDisplayed));
        IF node#NIL THEN
          NEW(node2(s1.Mark));
          s1.InitNode(node2);
          s1.CopyNode(s1.std.mark,node2);
          ok:=s12.ChangePoint(node,node2);
          IF ok THEN
            node(s1.Fenster).marks.AddTail(node2);
            s4.PlotObject(node,node2,TRUE);
          END;
        END;
      ELSIF sub=1 THEN
        node:=s2.SelectNode(s1.fenster,ac.GetString(ac.SelectWindow),ac.GetString(ac.AtTheMomentNo),ac.GetString(ac.WindowsAreDisplayed));
        IF node#NIL THEN
          IF NOT(node(s1.Fenster).marks.isEmpty()) THEN
            node2:=s16.SelectMark(node);
            IF node2#NIL THEN
              ok:=s12.ChangePoint(node,node2);
              IF ok THEN
                s1.ChangeNode(node);
                PlotAll;
(*                PlotWind(node);*)
              END;
            END;
          ELSE
            bool:=rt.RequestWin(ac.GetString(ac.InThisWindowNo),ac.GetString(ac.MarkersAreDisplayed),s.ADR(""),ac.GetString(ac.OK),s1.window);
          END;
        END;
      ELSIF sub=2 THEN
        node:=s2.SelectNode(s1.fenster,ac.GetString(ac.SelectWindow),ac.GetString(ac.AtTheMomentNo),ac.GetString(ac.WindowsAreDisplayed));
        IF node#NIL THEN
          IF NOT(node(s1.Fenster).marks.isEmpty()) THEN
            node2:=s16.SelectMark(node);
            IF node2#NIL THEN
              s1.FreeNode(node2);
              node2.Remove;
              s1.ChangeNode(node);
              PlotAll;
(*              PlotWind(node);*)
            END;
          ELSE
            bool:=rt.RequestWin(ac.GetString(ac.InThisWindowNo),ac.GetString(ac.MarkersAreDisplayed),s.ADR(""),ac.GetString(ac.OK),s1.window);
          END;
        END;
      ELSIF sub=4 THEN
        ok:=s12.ChangePoint(s1.std.wind,s1.std.mark);
      END;
    ELSIF item=11 THEN
      IF sub=0 THEN
        node:=s2.SelectNode(s1.fenster,ac.GetString(ac.SelectWindow),ac.GetString(ac.AtTheMomentNo),ac.GetString(ac.WindowsAreDisplayed));
        IF node#NIL THEN
          NEW(node2(s1.Area));
          node2(s1.Area).dims:=l.Create();
          s1.InitNode(node2);
          s1.CopyNode(s1.std.area,node2);
          ok:=s15.ChangeArea(node,node2);
          IF ok THEN
            node(s1.Fenster).areas.AddTail(node2);
            s1.ChangeNode(node);
            PlotAll;
(*            s2.SetAllPointers(TRUE);
            s3.PlotArea(node,node2);
            s2.SetAllPointers(FALSE);*)
          END;
        END;
      ELSIF sub=1 THEN
        node:=s2.SelectNode(s1.fenster,ac.GetString(ac.SelectWindow),ac.GetString(ac.AtTheMomentNo),ac.GetString(ac.WindowsAreDisplayed));
        IF node#NIL THEN
          IF NOT(node(s1.Fenster).areas.isEmpty()) THEN
            node2:=s2.SelectNode(node(s1.Fenster).areas,ac.GetString(ac.SelectHatching),ac.GetString(ac.InThisWindowNo),ac.GetString(ac.HatchingsAreDisplayed));
            IF node2#NIL THEN
              ok:=s15.ChangeArea(node,node2);
              IF ok THEN
                s1.ChangeNode(node);
                PlotAll;
(*                PlotWind(node);*)
              END;
            END;
          ELSE
            bool:=rt.RequestWin(ac.GetString(ac.InThisWindowNo),ac.GetString(ac.HatchingsAreDisplayed),s.ADR(""),ac.GetString(ac.OK),s1.window);
          END;
        END;
      ELSIF sub=2 THEN
        node:=s2.SelectNode(s1.fenster,ac.GetString(ac.SelectWindow),ac.GetString(ac.AtTheMomentNo),ac.GetString(ac.WindowsAreDisplayed));
        IF node#NIL THEN
          IF NOT(node(s1.Fenster).areas.isEmpty()) THEN
            node2:=s2.SelectNode(node(s1.Fenster).areas,ac.GetString(ac.SelectHatching),ac.GetString(ac.InThisWindowNo),ac.GetString(ac.HatchingsAreDisplayed));
            IF node2#NIL THEN
              node2.Remove;
              s1.ChangeNode(node);
              PlotAll;
(*              PlotWind(node);*)
            END;
          ELSE
            bool:=rt.RequestWin(ac.GetString(ac.InThisWindowNo),ac.GetString(ac.HatchingsAreDisplayed),s.ADR(""),ac.GetString(ac.OK),s1.window);
          END;
        END;
      ELSIF sub=4 THEN
        ok:=s15.ChangeArea(s1.std.wind,s1.std.area);
      END;*)
    END;
  ELSIF strip=3 THEN
    IF item=0 THEN
      node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
      IF node#NIL THEN
        node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
      END;
    ELSIF item=1 THEN
      node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
      IF node#NIL THEN
        node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
      END;
    ELSIF item=2 THEN
      node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
      IF node#NIL THEN
        node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
      END;
    ELSIF item=3 THEN
      node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
      IF node#NIL THEN
        node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
      END;
    ELSIF item=4 THEN
      node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
      IF node#NIL THEN
        node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
      END;
    ELSIF item=6 THEN
      node:=gb.SelectNode(gw.graphwindows,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
      IF node#NIL THEN
        node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
      END;
(*    ELSIF item=7 THEN
      s14.KomplettEinstellungen;*)
    ELSIF item=9 THEN
      (*          task:=graphwind.FindTask(tid.axisLabelsTaskID);*)
      task:=NIL;
      IF task=NIL THEN
        NEW(task(ito.IntegrationObject)); task.Init;
        m.taskdata.maintask.AddTask(task);
        m.taskdata.maintask.NewUser(task);
        bool:=task.Start();
      ELSE
        task.SendNewMsg(m.msgActivate,NIL);
      END;
(*      bool:=s16.Integrate();
      PlotAll;*)
    END;
  ELSIF strip=4 THEN (* Special *)
    IF item=0 THEN   (* Legend *)
      IF sub=0 THEN  (* Create *)
        node:=NIL;
        NEW(node(lw.Legend)); node.Init;
        lw.legends.AddTail(node);
(*        IF lw.standardlegend#NIL THEN lw.standardlegend.Copy(node); END;*)
        node(m.Task).InitTask(lw.LegendTask,NIL,10000,m.taskdata.windowpri);
        bool:=node(m.Task).Start();
      ELSIF sub=1 THEN (* Change *)
        node:=gb.SelectNode(lw.legends,ac.GetString(ac.SelectLegend),ac.GetString(ac.Legend),s.ADR("No legends are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
        IF node#NIL THEN
          node(m.Task).SendNewMsg(m.msgMenuAction,s.VAL(e.APTR,LONG(code)));
        END;
      ELSIF sub=2 THEN (* Delete *)
        node:=gb.SelectNode(lw.legends,ac.GetString(ac.SelectLegend),ac.GetString(ac.Legend),s.ADR("No legends are displayed at the moment!"),mb.mathoptions.quickselect,w.PrintWindow,NIL,mg.mainsub.GetWindow());
        IF node#NIL THEN
          node(m.Task).SendNewMsg(m.msgQuit,NIL);
        END;
      ELSIF sub=4 THEN (* Change standard *)
        IF lw.standardlegend#NIL THEN
          task:=m.taskdata.maintask.FindTask(tid.changeLegendTaskID);
          IF task=NIL THEN
            NEW(task); task.Init;
            task.InitTask(lw.ChangeLegendTask,lw.standardlegend,10000,m.taskdata.requesterpri);
            task.SetID(tid.changeLegendTaskID);
            m.taskdata.maintask.AddTask(task);
            m.taskdata.maintask.NewUser(task);
            bool:=task.Start();
          ELSE
            task.SendNewMsg(m.msgActivate,NIL);
          END;
        END;
      END;
(*    ELSIF item=1 THEN
      IF sub=0 THEN
        NEW(node(s1.Table));
        s1.InitNode(node);
        s1.CopyNode(s1.std.table,node);
        bool:=s11.ChangeTable(node);
        IF bool THEN
          s1.tables.AddTail(node);
          node(s1.Table).refresh:=TRUE;
          s1.SendNewObject(node);
          PlotAll;
(*          s11.PlotTable(node);*)
        END;
      ELSIF sub=1 THEN
        node:=s2.SelectNode(s1.tables,ac.GetString(ac.SelectTable),ac.GetString(ac.AtTheMomentNo),ac.GetString(ac.TablesAreDisplayed));
        IF node#NIL THEN
          ok:=s11.ChangeTable(node);
          IF ok THEN
            s1.ChangeNode(node);
(*            s1.SendChangedObject(node);*)
            PlotAll;
(*            s11.PlotTable(node);*)
          END;
        END;
      ELSIF sub=2 THEN
        node:=s2.SelectNode(s1.tables,ac.GetString(ac.SelectTable),ac.GetString(ac.AtTheMomentNo),ac.GetString(ac.TablesAreDisplayed));
        IF node#NIL THEN
          s4.FreeWind(node);
        END;
      ELSIF sub=4 THEN
        bool:=s11.ChangeTable(s1.std.table);
      END;
    ELSIF item=2 THEN
      IF sub=0 THEN
        NEW(node(s1.List));
        s1.InitNode(node);
        s1.CopyNode(s1.std.list,node);
        bool:=s10.ChangeList(node);
        IF bool THEN
          s1.lists.AddTail(node);
          node(s1.List).refresh:=TRUE;
          s1.SendNewObject(node);
          PlotAll;
(*          s10.PlotList(node);*)
        END;
      ELSIF sub=1 THEN
        node:=s2.SelectNode(s1.lists,ac.GetString(ac.SelectList),ac.GetString(ac.AtTheMomentNo),ac.GetString(ac.ListsAreDisplayed));
        IF node#NIL THEN
          bool:=s10.ChangeList(node);
          IF bool THEN
            s1.ChangeNode(node);
(*            s1.SendChangedObject(node);*)
            PlotAll;
(*            s10.PlotList(node);*)
          END;
        END;
      ELSIF sub=2 THEN
        node:=s2.SelectNode(s1.lists,ac.GetString(ac.SelectList),ac.GetString(ac.AtTheMomentNo),ac.GetString(ac.ListsAreDisplayed));
        IF node#NIL THEN
          s4.FreeWind(node);
        END;
      ELSIF sub=4 THEN
        bool:=s10.ChangeList(s1.std.list);
      END;
(*    ELSIF item=4 THEN
      node:=s2.SelectNode(s1.legends,"Legende auswählen","Es sind zur Zeit keine","Legenden dargestellt!");
      IF node#NIL THEN
        ok:=s9.ChangeLegend(node);
        s1.SendChangedObject(node);
        s9.PlotLegend(node);
      END;
    ELSIF item=5 THEN
      node:=s2.SelectNode(s1.tables,"Tabelle auswählen","Es sind zur Zeit keine","Tabellen dargestellt!");
      IF node#NIL THEN
        ok:=s11.ChangeTable(node);
        s1.SendChangedObject(node);
        s11.PlotTable(node);
      END;
    ELSIF item=6 THEN
      node:=s2.SelectNode(s1.lists,"Liste auswählen","Es sind zur Zeit keine","Listen dargestellt!");
      IF node#NIL THEN
        bool:=s10.ChangeList(node);
        s1.SendChangedObject(node);
        s10.PlotList(node);
      END;*)*)
    END;
  ELSIF strip=5 THEN
    IF item=0 THEN
      task:=m.taskdata.maintask.FindTask(tid.changeResTaskID);
      IF task=NIL THEN
        NEW(task); task.Init;
        task.InitTask(gg.ChangeScreenModeTask,mg.screenmode,10000,m.taskdata.requesterpri);
        task.SetID(tid.changeResTaskID);
        m.taskdata.maintask.AddTask(task);
        m.taskdata.maintask.NewUser(task);
        bool:=task.Start();
      ELSE
        task.SendNewMsg(m.msgActivate,NIL);
      END;

(*      bool:=s7.ChangeRes(s1.scr,s1.screen,s1.window);
      IF bool THEN
        s1.clonewb:=FALSE;
        ChangeMode;
      END;
(*      i:=SHORT(s1.scr.width);
      a:=SHORT(s1.scr.height);
      s7.Auflosung(i,a,s1.scr.depth,bool,s1.scr.ntsc,bool);
      s1.scr.width:=i;
      s1.scr.height:=a;
      ChangeMode;*)*)
(*    ELSIF item=1 THEN
      bool:=s4.ChangeColors(s1.screen,s1.scr);
      IF bool THEN
        ChangeMode;
      ELSE
        e.Signal(s1.prevtask,LONGSET{s1.prevnewobj});
      END;*)
    ELSIF item=2 THEN
      task:=m.taskdata.maintask.FindTask(tid.changePrisTaskID);
      IF task=NIL THEN
        NEW(task); task.Init;
        task.InitTask(sr.ChangePrioritiesTask,NIL,10000,m.taskdata.requesterpri);
        task.SetID(tid.changePrisTaskID);
        m.taskdata.maintask.AddTask(task);
        m.taskdata.maintask.NewUser(task);
        bool:=task.Start();
      ELSE
        task.SendNewMsg(m.msgActivate,NIL);
      END;

(*      bool:=s8.ChangePriorities();
      IF bool THEN
        i:=e.SetTaskPri(s1.prevtask,s1.prevpri);
        i:=e.SetTaskPri(s1.maintask,s1.mathpri);
      END;*)
    ELSIF item=3 THEN (* Change fonts *)
      task:=m.taskdata.maintask.FindTask(tid.changeFontsTaskID);
      IF task=NIL THEN
        NEW(task);
        IF task#NIL THEN
          task.Init;
          task.InitTask(fo.ChangeFontsTask,s.VAL(btp.ANY,mg.screen),10000,m.taskdata.requesterpri);
          task.SetID(tid.changeFontsTaskID);
          m.taskdata.maintask.AddTask(task);
          m.taskdata.maintask.NewUser(task);
          bool:=task.Start();
        END;
      ELSE
        task.SendNewMsg(m.msgActivate,NIL);
      END;
    ELSIF item=4 THEN
      mg.screenmode.usewbscreen:=NOT(mg.screenmode.usewbscreen);
      ChangeScreenMode;
    ELSIF item=5 THEN
      mb.mathoptions.quickselect:=~mb.mathoptions.quickselect;
    ELSIF item=6 THEN
      mb.mathoptions.autoactive:=~mb.mathoptions.autoactive;
    ELSIF item=7 THEN
      mg.screenmode.clonewb:=~mg.screenmode.clonewb;
      ChangeScreenMode;
(*    ELSIF item=9 THEN
      IF NOT(kf.demo) THEN
        s2.SetAllPointers(TRUE);
        GetWindowDims;
        bool:=sv1.RawSaveConfig("Analay.config");
        IF NOT(bool) THEN
          bool:=rt.RequestWin(ac.GetString(ac.CouldntOpenFile1),ac.GetString(ac.CouldntOpenFile2),s.ADR(""),ac.GetString(ac.OK),sv1.windactscreen);
        END;
        s2.SetAllPointers(FALSE);
      ELSE
        kf.NotInDemo(sv1.windactscreen);
      END;
    ELSIF item=11 THEN
      IF NOT(kf.demo) THEN
        s2.SetAllPointers(TRUE);
        bool:=sv.LoadConfig();
        s2.SetAllPointers(FALSE);
        IF bool THEN
          ChangeMode;
          s1.loadsave:=-1;
        END;
      ELSE
        kf.NotInDemo(sv1.windactscreen);
      END;
    ELSIF item=12 THEN
      IF NOT(kf.demo) THEN
        s2.SetAllPointers(TRUE);
        GetWindowDims;
        bool:=sv1.SaveConfig();
        s1.loadsave:=-2;
        s2.SetAllPointers(FALSE);
      ELSE
        kf.NotInDemo(sv1.windactscreen);
      END;*)
    END;
  END;
(*  sv1.windactscreen:=NIL;*)
END DoMenu;

PROCEDURE InputEvent(mes:I.IntuiMessagePtr);

BEGIN
  IF I.menuPick IN mes.class THEN
    DoMenu(mes.code);
  ELSIF I.vanillaKey IN mes.class THEN
    mg.ImitateMenu(mes.code);
    DoMenu(mes.code);
  END;
END InputEvent;

PROCEDURE CheckWindowList(wlist:w.WindowList);

BEGIN
  REPEAT
    wlist.GetIMes(mes);
    IF mes.class#LONGSET{} THEN
      InputEvent(mes);
    END;
  UNTIL mes.class=LONGSET{};
END CheckWindowList;

BEGIN
(*  NEW(text,5,80);
  text[0]:="Analay V2.0ß1        12.02.95";
  text[1]:="©1996 Marc Necker    Alle Rechte vorbehalten.";
  text[2]:="";
  text[3]:="Diese Batatestversion ist nur für die Proxity.Beta";
  text[4]:="bestimmt und darf nicht frei kopiert werden!";*)

(* Initial stuff *)

  mes:=NIL; NEW(mes);

(* AmigaOS 2.0? *)

  IF bt.os<36 THEN
    bool:=r.Request("Analay requires","AmigaOS 2.0 or higher!","","   OK   ");
    HALT(20);
  END;

(* Locale stuff *)

  IF ac.locale#NIL THEN
    ac.OpenCatalog(NIL,"");
  END;
  COPY(ac.GetString(ac.GuideName)^,gb.analaydoc);

(* Opening display *)

  mg.Init;

(* Starting tasks *)

  NEW(m.taskdata.maintask); m.taskdata.maintask.Init;
  m.taskdata.maintask.task:=s.VAL(d.ProcessPtr,ol.Me);
  m.taskdata.maintask.InitCommunication;

  IF (kf.demo) OR (kf.file=NIL) THEN
    ai.AnalayInfo(NIL);
  END;

  mg.mainsub.ClearPointer;

(* Starting Layout task *)

  NEW(m.taskdata.layouttask); m.taskdata.layouttask.Init;
  m.taskdata.layouttask.InitTask(lm.LayoutMainTask,NIL,10000,m.taskdata.layoutpri);
  m.taskdata.layouttask.SetID(tid.layoutMainTaskID);
  m.taskdata.maintask.AddTask(m.taskdata.layouttask);
  bool:=m.taskdata.layouttask.Start();

(* Main loop *)

  quit:=FALSE;
  REPEAT
    class:=e.Wait(LONGSET{0..31});

(* Checking main window *)

    REPEAT
      mg.mainsub.GetIMes(mes);
      InputEvent(mes);
    UNTIL mes.class=LONGSET{};

(*    IF m.taskdata.maintask.msgsig IN class THEN*)
      REPEAT
        msg:=m.taskdata.maintask.ReceiveMsg();
        IF msg#NIL THEN
          IF msg.type=m.msgQuit THEN
            quit:=TRUE;
          ELSIF msg.type=m.msgClose THEN
            SendNewMsgToAllTasks(m.msgClose,NIL);
          ELSIF msg.type=m.msgOpen THEN
            SendNewMsgToAllTasks(m.msgOpen,NIL);
          ELSIF msg.type=m.msgActivate THEN
          ELSIF msg.type=m.msgNodeChanged THEN
          ELSIF msg.type=m.msgMenuAction THEN
            DoMenu(SHORT(s.VAL(LONGINT,msg.data)));
          ELSIF msg.type=m.msgNewScreenMode THEN
            ChangeScreenMode;
          ELSIF msg.type=m.msgNewPriority THEN
            SendNewMsgToAllTasks(m.msgNewPriority,NIL);
            m.taskdata.maintask.SetPriority(m.taskdata.mainpri);
          END;
          msg.Reply;
        END;
      UNTIL msg=NIL;
(*    END;*)

(*(* Checking window lists *)

    CheckWindowList(gw.graphwindows);*)

    mem.ClearMemory;
  UNTIL quit;

CLOSE
  DISPOSE(text);
  io.WriteString("CA1\n");
  CloseDown;
  io.WriteString("CA2\n");
  mg.Destruct;
  io.WriteString("CA3\n");
  IF mes#NIL THEN DISPOSE(mes); END;
  io.WriteString("CA4\n");
END Analay.

