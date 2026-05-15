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


MODULE Layout;

(* Layout mode main module *)

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       m  : Multitasking,
       mem: MemoryManager,
       tid: TaskIDs,
       gb : GeneralBasics,
       mb : MathBasics,
       lg : LayoutGUI,
       lc : LayoutConversion,
       col: Colors,
       tb : Toolbox,
       db : DragBar,
       do : Document,
       gw : GraphWindow,
       bt : BasicTypes,
       NoGuruRq;

VAR (*toolbox      : tb.Toolbox;*)
    dragbar      : db.DragBar;
    layoutopen * : BOOLEAN;

PROCEDURE Open;

VAR bool : BOOLEAN;

BEGIN
  lg.Init;
(*  IF toolbox#NIL THEN
    bool:=toolbox.Open();
  END;*)
  IF dragbar#NIL THEN
    dragbar.Open;
  END;
END Open;

PROCEDURE Close;

BEGIN
  dragbar.Close;
(*  toolbox.Close;*)
  lg.Close;
END Close;

PROCEDURE CheckInput(class:LONGSET):BOOLEAN;

VAR mes  : I.IntuiMessagePtr;
    msg  : m.Message;
    icon : l.Node;
    quit : BOOLEAN;

  PROCEDURE NewDocument;

  VAR task : do.Document;
      bool : BOOLEAN;

  BEGIN
    NEW(task); task.Init;
    task.InitTask(do.DocumentTask,task,20000,m.taskdata.layoutpri);
    do.documents.AddTail(task);
    m.taskdata.layouttask.NewUser(task);
    bool:=task.Start();
  END NewDocument;

  PROCEDURE DoMenu(code:INTEGER);
  (* Check based upon LayoutGUI.dragbarmenu *)

  VAR strip,item,sub : LONGINT;
      task           : m.Task;
      node           : l.Node;
      bool           : BOOLEAN;

  BEGIN
    strip:=I.MenuNum(code);
    item:=I.ItemNum(code);
    sub:=I.SubNum(code);
    IF strip=0 THEN
      IF item=4 THEN
        NewDocument;
      ELSIF item=5 THEN (* Hide *)
        node:=gb.SelectNode(do.documents,s.ADR("Select document"),s.ADR("Document"),s.ADR("No documents are displayed at the moment!"),mb.mathoptions.quickselect,do.PrintDocument,NIL,dragbar.iwindow);
        IF node#NIL THEN node(m.Task).SendNewMsg(m.msgClose,NIL); END;
      ELSIF item=6 THEN (* Reveal *)
        node:=gb.SelectNode(do.documents,s.ADR("Select document"),s.ADR("Document"),s.ADR("No documents are displayed at the moment!"),mb.mathoptions.quickselect,do.PrintDocument,NIL,dragbar.iwindow);
        IF node#NIL THEN node(m.Task).SendNewMsg(m.msgOpen,NIL); END;
      ELSIF item=9 THEN
        layoutopen:=FALSE;
        Close;
      END;
    ELSIF strip=1 THEN (* Conversion *)
      IF item=1 THEN
        task:=m.taskdata.layouttask.FindTask(tid.layoutColorConvID);
        IF task=NIL THEN
          NEW(task); task.Init;
          task.InitTask(lc.ChangeColorTask,lg.layoutconv,10000,m.taskdata.requesterpri);
          task.SetID(tid.layoutColorConvID);
          m.taskdata.layouttask.AddTask(task);
          m.taskdata.layouttask.NewUser(task);
          bool:=task.Start();
        ELSE
          task.SendNewMsg(m.msgActivate,NIL);
        END;
      ELSIF item=2 THEN
        task:=m.taskdata.layouttask.FindTask(tid.layoutLineConvID);
        IF task=NIL THEN
          NEW(task); task.Init;
          task.InitTask(lc.ChangeThicknessTask,lg.layoutconv,10000,m.taskdata.requesterpri);
          task.SetID(tid.layoutLineConvID);
          m.taskdata.layouttask.AddTask(task);
          m.taskdata.layouttask.NewUser(task);
          bool:=task.Start();
        ELSE
          task.SendNewMsg(m.msgActivate,NIL);
        END;
      ELSIF item=4 THEN
        task:=m.taskdata.layouttask.FindTask(tid.layoutLabelsConvID);
        IF task=NIL THEN
          NEW(task); task.Init;
          task.InitTask(lc.ChangeLabelsTask,lg.layoutconv,10000,m.taskdata.requesterpri);
          task.SetID(tid.layoutLabelsConvID);
          m.taskdata.layouttask.AddTask(task);
          m.taskdata.layouttask.NewUser(task);
          bool:=task.Start();
        ELSE
          task.SendNewMsg(m.msgActivate,NIL);
        END;
      ELSIF item=5 THEN
        task:=m.taskdata.layouttask.FindTask(tid.layoutGridConvID);
        IF task=NIL THEN
          NEW(task); task.Init;
          task.InitTask(lc.ChangeGridTask,lg.layoutconv,10000,m.taskdata.requesterpri);
          task.SetID(tid.layoutGridConvID);
          m.taskdata.layouttask.AddTask(task);
          m.taskdata.layouttask.NewUser(task);
          bool:=task.Start();
        ELSE
          task.SendNewMsg(m.msgActivate,NIL);
        END;
      END;
    ELSIF strip=2 THEN
      IF item=2 THEN (* Change document colors *)
        task:=m.taskdata.layouttask.FindTask(tid.layoutChangeColorsID);
        IF task=NIL THEN
          NEW(task); task.Init;
          task.InitTask(col.ChangeColorsTask,NIL,10000,m.taskdata.requesterpri);
          task.SetID(tid.layoutChangeColorsID);
          m.taskdata.layouttask.AddTask(task);
          m.taskdata.layouttask.NewUser(task);
          bool:=task.Start();
        ELSE
          task.SendNewMsg(m.msgActivate,NIL);
        END;
      END;
    END;
  END DoMenu;

BEGIN
  NEW(mes);
  IF layoutopen THEN
(*    IF toolbox.subwind#NIL THEN
      REPEAT
        toolbox.subwind.GetIMes(mes);
        toolbox.InputEvent(mes);
        IF I.menuPick IN mes.class THEN DoMenu(mes.code); END;
      UNTIL (mes.class=LONGSET{}) OR ~layoutopen;
    END;*)

    IF dragbar.subwindow#NIL THEN
      REPEAT
        IF dragbar.root#NIL THEN
          dragbar.root.GetIMes(mes);
        ELSE
          dragbar.subwindow.GetIMes(mes);
        END;
        dragbar.InputEvent(mes);
        IF I.menuPick IN mes.class THEN DoMenu(mes.code); END;
      UNTIL (mes.class=LONGSET{}) OR ~layoutopen;
    END;
  END;

  REPEAT
    msg:=m.taskdata.layouttask.ReceiveMsg();
    IF msg#NIL THEN
      IF msg.type=m.msgQuit THEN
        quit:=TRUE;
      ELSIF msg.type=m.msgClose THEN
        IF layoutopen THEN
          IF msg.data=m.typeScreenMode THEN
            do.documents.SendNewMsgToAllTasks(m.msgClose,NIL);
            Close;
          ELSE
            do.documents.SendNewMsgToAllTasks(m.msgClose,NIL);
            Close;
            layoutopen:=FALSE;
          END;
        END;
      ELSIF msg.type=m.msgOpen THEN
        IF msg.data=m.typeScreenMode THEN
          IF layoutopen THEN
            do.documents.SendNewMsgToAllTasks(m.msgOpen,msg.data);
            Open;
          END;
        ELSE
          IF ~layoutopen THEN
            layoutopen:=TRUE;
            do.documents.SendNewMsgToAllTasks(m.msgOpen,msg.data);
            Open;
          END;
        END;
      ELSIF msg.type=m.msgListChanged THEN
        IF msg.data=gw.graphwindows THEN
          IF layoutopen THEN
            dragbar.InitGadgets;
          END;
        END;
      ELSIF msg.type=m.msgNodeChanged THEN
        IF msg.data=lg.layoutconv THEN
          do.documents.SendNewMsgToAllNodes(msg.type,msg.data);
        ELSE
          IF layoutopen THEN
            icon:=dragbar.GetIcon(s.VAL(l.Node,msg.data));
            IF icon#NIL THEN icon(db.IconPicture).changed:=TRUE; END;
            dragbar.InitGadgets;
          END;
        END;
      ELSIF msg.type=m.msgMenuAction THEN
        DoMenu(SHORT(s.VAL(LONGINT,msg.data)));
      ELSIF msg.type=m.msgActivate THEN
(*        IF graphwind.iwind#NIL THEN
          I.WindowToFront(graphwind.iwind);
          I.ActivateWindow(graphwind.iwind);
        END;*)
(*      ELSIF (msg.type=m.msgNodeChanged) OR (msg.type=m.msgSizeChanged) THEN
        IF msg.data#NIL THEN
          node:=graphwind.funcs.head;
          WHILE node#NIL DO
            IF node(wf.WindowFunction).func=msg.data THEN
              node(wf.WindowFunction).changed:=TRUE;
            ELSIF msg.data=m.typeRecalc THEN
              node(wf.WindowFunction).changed:=TRUE;
            END;
            node:=node.next;
          END;
        END;
        IF graphwind.iwind#NIL THEN
          graphwind.changed:=TRUE;
          IF msg.type=m.msgSizeChanged THEN graphwind.sizechanged:=TRUE; END;
          graphwind.Refresh;
        END;
        graphwind.SendNewMsgToAllTasks(m.msgNodeChanged,NIL);
      ELSIF msg.type=m.msgMenuAction THEN
        IF graphwind.iwind#NIL THEN
          DoMenu(SHORT(s.VAL(LONGINT,msg.data)));
        END;*)
      END;
      msg.Reply;
    END;
  UNTIL msg=NIL;

  DISPOSE(mes);
  RETURN quit;
END CheckInput;

PROCEDURE LayoutMainTask*(layouttask:bt.ANY):bt.ANY;
(* layouttask is equal to m.taskdata.layouttask *)
(* Screens have to be opened already! *)

VAR class     : LONGSET;
    doc       : l.Node;
    bool,quit : BOOLEAN;

BEGIN
  WITH layouttask: m.Task DO
    layouttask.InitCommunication;
(*    data:=layouttask.data;*)
    gw.graphwindows.NewUser(m.taskdata.layouttask,FALSE);

    NEW(lg.layoutconv); lg.layoutconv.Init(m.taskdata.layouttask);
(*    NEW(toolbox); toolbox.Init;*)
    NEW(dragbar); dragbar.Init;

    REPEAT
      class:=e.Wait(LONGSET{0..31});
      quit:=CheckInput(class);
    UNTIL quit;

    doc:=do.documents.head;
    WHILE doc#NIL DO
      doc(m.Task).SendNewMsg(m.msgQuit,NIL);
      doc:=doc.next;
    END;
    IF layoutopen THEN Close; END;
    REPEAT d.Delay(50); UNTIL do.documents.nbElements()=0;

    dragbar.Destruct;
(*    toolbox.Destruct;*)
    lg.layoutconv.Destruct(m.taskdata.layouttask);
    gw.graphwindows.FreeUser(m.taskdata.layouttask);
    lg.Destruct;

    m.taskdata.maintask.RemTask(layouttask);
    layouttask.ReplyAllMessages;
    layouttask.DestructCommunication;
    mem.NodeToGarbage(layouttask);
(*    data.grid1.window.FreeUser(gridtask);*)
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END LayoutMainTask;

BEGIN
  layoutopen:=FALSE;
END Layout.

