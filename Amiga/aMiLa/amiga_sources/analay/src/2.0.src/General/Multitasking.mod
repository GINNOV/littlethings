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


 MODULE Multitasking;

(* This module contains basic objects for the parallel design of Analay.
   Other objects may be derived from these classes. *)

(* Ups, buggy (well, not really, but not good):

   SharedAble.Changed and MTList.Changed also send messages to the
   calling task! *)


IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       cc : Concurrency,
       bt : BasicTypes,
       tt : TextTools,
       io,
       NoGuruRq;


(*VAR maintask   * ,
    layouttask * : e.TaskPtr;
    mathpri    * ,
    reqpri     * ,
    layoutpri  * : SHORTINT;
    layoutlist * : l.List;       (* The layout mode gets new objects from
                                    this list. (This list is used as a queue.) *)
    changesig * ,                (* Signals for communication *)
    layoutnewobj * ,
    layoutgotobj * ,
    layoutobjch * ,
    layouttoact * ,
    layoutquit  * ,
    layoutchscr * ,
    mainchscr * ,
    loadsavesig*: SHORTINT;*)

TYPE LayoutNode * = POINTER TO LayoutNodeDesc;
     LayoutNodeDesc * = RECORD(l.NodeDesc) (* Element of layoutlist *)
       node      * : l.Node;
       prevgotobj* ,
       changed   * : BOOLEAN;
     END;



(* MultitaskingList is a list similar to LinkedLists.List. You should use MTList
   whenever multiple tasks have access to one list. *)

TYPE MTList * = POINTER TO MTListDesc;
     MTListDesc * = RECORD(l.ListDesc)
       semaphore * : e.SignalSemaphorePtr;
       remlist   * : l.List;           (* List of removed Nodes which can't be
                                          deleted because MTList still has to call a FreeUser on them. *)
       tasklist  * : l.List;           (* List of tasks using this MTList. *)
       numtasks  * : INTEGER;
     END;

(* Shareable access to a list is not supported yet! (Means, that
   MTList.Lock(TRUE) <-> MTList.UnLock; doesn't mean any difference to
   MTList.Lock(FALSE) <-> MTList.UnLock; *)

     MTNode * = POINTER TO MTNodeDesc;
     MTNodeDesc * = RECORD(l.NodeDesc)
     END;

(* MTList.remlist consists RemLstNodes. If the deleted nodes would be added
   to the remlist in a usual way, they couldn't be identified as nodes, which do
   not belong to a list. *)

     RemListNode * = POINTER TO RemListNodeDesc;
     RemListNodeDesc * = RECORD(l.NodeDesc)
       node : MTNode;
     END;

(* MTTaskNode is for keeping all tasks in the tasklist. *)

     MTTaskNode * = POINTER TO MTTaskNodeDesc;
     MTTaskNodeDesc * = RECORD(l.NodeDesc)
       task       : MTNode;
       activeuser : BOOLEAN;
     END;

PROCEDURE (list:MTList) Init*;

BEGIN
  list.semaphore:=NIL;
  NEW(list.semaphore); e.InitSemaphore(list.semaphore^);
  list.remlist:=l.Create();
  list.tasklist:=l.Create();
  list.numtasks:=0;
  list.Init^;
END Init;

PROCEDURE Create*():MTList;

VAR list : MTList;

BEGIN
  NEW(list);
  IF list#NIL THEN list.Init; END;
  RETURN list;
END Create;



(* A ShareAble object may be used by several tasks at the same time. However
   this must be a read-only access, because no semaphore-protection is
   performed. *)

TYPE ShareAble * = POINTER TO ShareAbleDesc;
     ShareAbleDesc * = RECORD(MTNodeDesc)
       tasks       * : MTList;
       sharesem    * : e.SignalSemaphorePtr;
       numtasks    * : INTEGER;
     END;



PROCEDURE (node:ShareAble) Init*;

BEGIN
  node.numtasks:=1;
  node.tasks:=Create();
  node.sharesem:=NIL;
  NEW(node.sharesem); e.InitSemaphore(node.sharesem^);
  node.Init^;
END Init;

PROCEDURE (node:ShareAble) Destruct*;

BEGIN
  IF node.tasks#NIL THEN node.tasks.Destruct; END;
  IF node.sharesem#NIL THEN DISPOSE(node.sharesem); END;
  node.Destruct^;
END Destruct;

(* The LockAble object is an extension of the ShareAble object. It performs
   a semaphore protection. *)

TYPE LockAble * = POINTER TO LockAbleDesc;
     LockAbleDesc * = RECORD(ShareAbleDesc)
       semaphore * : e.SignalSemaphorePtr;
       locked    * ,                  (* Used bysomeone at the moment?  *)
       mathpri   * : BOOLEAN;         (* Other tasks have to wait until *)
     END;                             (* math mode sets this to FALSE.  *)

PROCEDURE (node:LockAble) Init*;

BEGIN
  node.semaphore:=NIL;
  NEW(node.semaphore); e.InitSemaphore(node.semaphore^);
(*  node.locked:=FALSE;*)
  node.mathpri:=FALSE;
  node.Init^;
END Init;

PROCEDURE (node:LockAble) Destruct*;

BEGIN
  IF node.semaphore#NIL THEN DISPOSE(node.semaphore); END;
  node.Destruct^;
END Destruct;

PROCEDURE (node:LockAble) Copy*(dest:l.Node);

BEGIN
  dest(LockAble).locked:=node.locked;
  dest(LockAble).mathpri:=node.mathpri;
  node.Copy^(dest);
END Copy;

PROCEDURE (node:LockAble) AllocNew*():l.Node;

VAR node2 : LockAble;

BEGIN
  NEW(node2);
  RETURN node2;
END AllocNew;

PROCEDURE (node:LockAble) Lock*(shareable:BOOLEAN);

VAR exit : BOOLEAN;

BEGIN
  IF shareable THEN
    IF node.locked THEN io.WriteString("LockAble.Lock(shareable=TRUE): Node is currently locked, waiting ...\n");
                   ELSE io.WriteString("LockAble.Lock(shareable=TRUE): Node not locked, now obtaining semaphore ...\n"); END;
    e.ObtainSemaphoreShared(node.semaphore^);
    IF node.locked THEN io.WriteString("Shareable, got the semaphore though node is still locked?!?\n"); END;
  ELSE
    IF node.locked THEN io.WriteString("LockAble.Lock: Node is currently locked, waiting ...\n");
                   ELSE io.WriteString("LockAble.Lock: Node not locked, now obtaining semaphore ...\n"); END;
    e.ObtainSemaphore(node.semaphore^);
    IF node.locked THEN io.WriteString("Hups, got the semaphore though node is still locked?!?\n"); END;
  END;
  node.locked:=TRUE;
  node.mathpri:=FALSE;
(*  exit:=FALSE;
  REPEAT
    WHILE node.locked DO
      d.Delay(10);
    END;
    e.Forbid();
    IF NOT(node.locked) THEN
      node.locked:=TRUE;
      node.mathpri:=FALSE;
      exit:=TRUE;
    END;
    e.Permit();
  UNTIL exit;*)
END Lock;

PROCEDURE (node:LockAble) UnLock*;

BEGIN
  io.WriteString("LockAble: Unlocked.\n");
  node.locked:=FALSE;
  node.mathpri:=FALSE;
  e.ReleaseSemaphore(node.semaphore^);
END UnLock;

PROCEDURE (node:LockAble) WaitMathPri*;

BEGIN
  WHILE node.mathpri DO
    d.Delay(10);
  END;
END WaitMathPri;

PROCEDURE (node:LockAble) Locked*():BOOLEAN;

BEGIN
  RETURN node.locked;
END Locked;



(* The standard message used for the communication of tasks *)

TYPE Message * = POINTER TO MessageDesc;
     MessageDesc * = RECORD(l.NodeDesc);
       type * : LONGINT;
       data * : e.APTR;
     END;

PROCEDURE NewMessage*(type:LONGINT;data:e.APTR):Message;

VAR msg : Message;

BEGIN
  NEW(msg);
  msg.type:=type;
  msg.data:=data;
  RETURN msg;
END NewMessage;

PROCEDURE (msg:Message) Copy*(dest:l.Node);

BEGIN
  dest(Message).type:=msg.type;
  dest(Message).data:=msg.data;
END Copy;

PROCEDURE (msg:Message) AllocNew*():l.Node;

VAR node : Message;

BEGIN
  NEW(node);
  RETURN node;
END AllocNew;

(* Standard message types *)

CONST msgQuit        * = 1;
      msgClose       * = 2; (* Close all windows (e.g. to change screen) *)
      msgOpen        * = 3; (* Open again *)
      msgActivate    * = 4; (* Bring the task to front *)
      msgNewNode     * = 5; (* Receiving a new node (e.g. Tell LayoutMode of new window) *)
      msgNodeChanged * = 6; (* An already existing node has been changed. *)
      msgSizeChanged * = 7; (* Same as msgNodeChanged, but performs e.g. an Auto-Call with GraphWindows. *)
      msgMenuAction  * = 8; (* Perform a menu action, data=IntuiMessage.code *)
      msgListChanged * = 9; (* Sent by MTList whenever the mtlist ist changed. *)
      msgNewScreenMode*= 10; (* Only sent to Main Task! *)
      msgNewPriority * = 14; (* Sent to Main Task. Main Task will send the same message to all other started tasks. *)

(* Layout specific *)

      msgNewNodeFollow*= 11; (* Create new box of type msg.data and follow under mouse pointer *)
      msgNewNodeDropped*=12; (* User has dropped new box over the window *)
      msgNewNodeCancelled*=13;(*User has cancelled the new box (e.g. by right mouse button) *)

(* Data types *)

      typeRecalc     * = s.VAL(e.APTR,1);
      typeScreenMode * = s.VAL(e.APTR,2); (* Uses this type with msgOpen and msgClos if called when screen mode is changed. *)



(* Task object supporting a messaging system *)

TYPE Task * = POINTER TO TaskDesc;
     TaskDesc * = RECORD(LockAbleDesc)
       ccprocess * : cc.Process;
       task      * : d.ProcessPtr;
       proc      * : cc.ProcessProc;
       data      * : bt.ANY;           (* Attention: The cc.NewProcessX call is
                                          given the pointer to this Task sctructure
                                          as data, not the pointer Task.data! You can
                                          access the data-field via this Task structure. *)
       stack     * : LONGINT;
       msglist   * : l.List;
       taskname  * : ARRAY 80 OF CHAR;
       id        * : LONGINT;
       pri       * ,
       msgsig    * : SHORTINT;
       quitted   * : BOOLEAN; (* Set to TRUE when quitting task, because this Task-structure may stay
                                 allocated for a longer time and poeple have to know when the task is
                                 no longer running. See Task.Quitting and Task.Quitted. *)
     END;

PROCEDURE (task:Task) Init*;

BEGIN
  task.msglist:=l.Create();
  task.task:=NIL;
  task.ccprocess:=NIL;
  task.stack:=10000;
  task.pri:=0;
  task.msgsig:=-1;
  task.taskname:="";
  task.id:=0;
  task.quitted:=FALSE;
  task.Init^;
END Init;

PROCEDURE (task:Task) InitTask*(proc:cc.ProcessProc;data:bt.ANY;stack:LONGINT;pri:SHORTINT);

BEGIN
  task.proc:=proc;
  task.data:=data;
  task.stack:=stack;
  task.pri:=pri;
  task.taskname:="";
  task.id:=s.VAL(LONGINT,proc);
END InitTask;

PROCEDURE (task:Task) InitCommunication*;

(* HAS to be called by the started task as one of the first things it does! *)
(* For future versions: It must be save to call this function over and
   over again (see i.e. GraphWindow.CheckInput. *)

BEGIN
  IF task.msgsig=-1 THEN
    task.msgsig:=e.AllocSignal(-1);
    IF task.msgsig=-1 THEN HALT(20); END;
  END;
END InitCommunication;

PROCEDURE (task:Task) DestructCommunication*;

(* HAS to be called by the started task in the end! *)

BEGIN
  IF task.msgsig#-1 THEN
    e.FreeSignal(task.msgsig);
    task.msgsig:=-1;
  END;
END DestructCommunication;

PROCEDURE (task:Task) Destruct*;

VAR any : bt.ANY;

BEGIN
  IF task.ccprocess#NIL THEN
    any:=task.ccprocess.Wait();
    DISPOSE(task.ccprocess);
  END;
  IF task.msglist#NIL THEN task.msglist.Destruct; END;
  task.Destruct^;
END Destruct;

PROCEDURE (task:Task) Copy*(dest:l.Node);

BEGIN
  WITH dest: Task DO
    task.msglist.Copy(dest.msglist);
    dest.ccprocess:=task.ccprocess;
    dest.task:=task.task;
    dest.proc:=task.proc;
    dest.data:=task.data;
    dest.stack:=task.stack;
    dest.pri:=task.pri;
    dest.msgsig:=task.msgsig;
  END;
  task.Copy^(dest);
END Copy;

PROCEDURE (task:Task) AllocNew*():l.Node;

VAR node : Task;

BEGIN
  NEW(node);
  RETURN node;
END AllocNew;



PROCEDURE (task:Task) SetProcedure*(proc:cc.ProcessProc);

BEGIN
  task.proc:=proc;
END SetProcedure;

PROCEDURE (task:Task) SetData*(data:bt.ANY);

BEGIN
  task.data:=data;
END SetData;

PROCEDURE (task:Task) SetStack*(stack:LONGINT);

BEGIN
  task.stack:=stack;
END SetStack;

PROCEDURE (task:Task) SetPriority*(pri:SHORTINT);

VAR i : SHORTINT;

BEGIN
  task.pri:=pri;
  IF task.task#NIL THEN
    i:=e.SetTaskPri(task.task,task.pri);
  END;
END SetPriority;

PROCEDURE (task:Task) SetID*(id:LONGINT);

BEGIN
  task.id:=id;
END SetID;

PROCEDURE (task:Task) GetID*():LONGINT;

BEGIN
  RETURN task.id;
END GetID;

PROCEDURE (task:Task) SetName*(name:ARRAY OF CHAR);

BEGIN
  COPY(name,task.taskname);
END SetName;

PROCEDURE (task:Task) GetName*(VAR name:ARRAY OF CHAR);

BEGIN
  COPY(task.taskname,name);
END GetName;

PROCEDURE (task:Task) Start*():BOOLEAN;

BEGIN
  task.ccprocess:=cc.NewProcessX(task.proc,task,task.stack,task.pri);
  task.task:=task.ccprocess.dosProcess;
  IF task.task#NIL THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END;
END Start;

PROCEDURE (task:Task) Wait*():bt.ANY;

BEGIN
  IF task.ccprocess#NIL THEN
    RETURN task.ccprocess.Wait();
  ELSE
    RETURN NIL;
  END;
END Wait;

PROCEDURE (task:Task) isRunning*():BOOLEAN;
(* Be careful when changing this. Have a look at for example
   Legend.ChangeLegendTask. *)

BEGIN
  IF task.ccprocess#NIL THEN
    RETURN task.ccprocess.isRunning();
  ELSIF task.task#NIL THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END;
END isRunning;



PROCEDURE (task:Task) Signal*(signal:LONGSET);

BEGIN
  IF task.isRunning() THEN
    e.Signal(task.task,signal);
  END;
END Signal;

PROCEDURE (task:Task) SendMsg*(msg:Message);

VAR node: bt.ANY;
    i   : INTEGER;
    ret : BOOLEAN;

BEGIN
  IF task.isRunning() & ~task.quitted THEN

(*(* A little bit security *)
    node:=s.VAL(bt.ANY,msg.data); (* May cause problems when msg.data is just any pointer *)
    IF node IS ShareAble THEN node(ShareAble).NewUser(NIL); END;
(* End security. FreeUsered when message is replied. *)*)

    e.Forbid;
    task.msglist.AddTail(msg);
    e.Permit;
    i:=0;
    WHILE (task.msgsig=-1) AND (i<10) DO
      INC(i); d.Delay(100);
    END;
    IF task.msgsig>=0 THEN task.Signal(LONGSET{task.msgsig}); END;
  END;
END SendMsg;

PROCEDURE (task:Task) SendNewMsg*(type:LONGINT;data:e.APTR);

BEGIN
  task.SendMsg(NewMessage(type,data));
END SendNewMsg;

PROCEDURE (task:Task) ReceiveMsg*():Message;

VAR msg : l.Node;

BEGIN
  e.Forbid;
  msg:=task.msglist.RemHead();
  e.Permit;
  IF msg#NIL THEN
    RETURN msg(Message);
  ELSE
    RETURN NIL;
  END;
END ReceiveMsg;

PROCEDURE (task:Task) ReceiveMsgType*(type:LONGINT):Message;

VAR msg,node : l.Node;

BEGIN
(*  e.Forbid;*)
  msg:=NIL;
  node:=task.msglist.head;
  WHILE (node#NIL) & (msg=NIL) DO
    IF node(Message).type=type THEN
      node.Remove;
      msg:=node;
    END;
    node:=node.next;
  END;
(*  e.Permit;*)
  IF msg#NIL THEN
    RETURN msg(Message);
  ELSE
    RETURN NIL;
  END;
END ReceiveMsgType;

PROCEDURE (task:Task) ReceiveMsgTypeData*(type:LONGINT;data:e.APTR):Message;

VAR msg,node : l.Node;

BEGIN
(*  e.Forbid;*)
  msg:=NIL;
  node:=task.msglist.head;
  WHILE (node#NIL) & (msg=NIL) DO
    IF (node(Message).type=type) & (node(Message).data=data) THEN
      node.Remove;
      msg:=node;
    END;
    node:=node.next;
  END;
(*  e.Permit;*)
  IF msg#NIL THEN
    RETURN msg(Message);
  ELSE
    RETURN NIL;
  END;
END ReceiveMsgTypeData;

PROCEDURE (task:Task) ReceiveMsgNotOfType*(type:LONGINT):Message;
(* Returns messages which are not of type type. *)

VAR msg,node : l.Node;

BEGIN
(*  e.Forbid;*)
  msg:=NIL;
  node:=task.msglist.head;
  WHILE (node#NIL) & (msg=NIL) DO
    IF node(Message).type#type THEN
      node.Remove;
      msg:=node;
    END;
    node:=node.next;
  END;
(*  e.Permit;*)
  IF msg#NIL THEN
    RETURN msg(Message);
  ELSE
    RETURN NIL;
  END;
END ReceiveMsgNotOfType;

PROCEDURE (msg:Message) Reply*;

VAR node : bt.ANY;

BEGIN
(*  node:=s.VAL(bt.ANY,msg.data);
  IF node IS ShareAble THEN node(ShareAble).FreeUser(NIL); END;*)
  msg.Destruct;
END Reply;

PROCEDURE (task:Task) ReplyAllMessages*;

VAR msg : Message;

BEGIN
  REPEAT
    msg:=task.ReceiveMsg();
    IF msg#NIL THEN
      msg.Reply;
    END;
  UNTIL msg=NIL;
END ReplyAllMessages;

PROCEDURE (task:Task) Quitting*;
(* Actually it is save to simply quit a task without calling this
   method. However this may change in the future (Other tasks still
   can send messages to the no longer running one. However they won't
   get answered. But please make use of this method!

   Currently MemoryManager.NodeToGarbage calls this method for you! *)

BEGIN
  task.quitted:=TRUE;
END Quitting;

PROCEDURE (task:Task) Quitted*():BOOLEAN;

BEGIN
  RETURN task.quitted;
END Quitted;

(* How to stop and destruct a task properly:
   Send a message.type=msgquit to the task and do nothing more! Just call the
   MemoryManager's ClearMemory function regularly.

   The task has to do the following things when it receives a message of
   type msgquit:

   1.) Call task.Remove on itself to remove it from any tasklist it was
       added to (check first if it really was added to one! Maybe it already has
       been removed). You should not miss this though the memory manager will
       do it later for you. Doing so other tasks are not able to continue
       sending messages to the task while it is closing down. The user will
       also not see the task (e.g. a graph window) in any list anymore.
   2.) Check for any messages left at the message port of the task.
   3.) Close all windows, but do not free any allocated memory. The
       MemoryManager will do this for you if there are no other users anymore.
   4.) Add the task to the MemoryManager's garbage list using
       NodeToGarbage. Don't call FreeUser or anything else on itself but call
       FreeUser on other stuff the task has used. The initial NewUser should
       not be done by the task itself, but by the task which started the new
       task. This is because the starting task may have been stopped already
       when the newly created task calls NewUser (not likely, but possible!).
   5.) Call DestructCommunication.
   6.) Quit the task procedure.

   The MemoryManager will destruct the task as soon as there are no current
   users any longer and the task's procedure has finished
   (task.ccprocess.isRunning()=FALSE).
*)



(* The ChangeAble object may have several requesters open to change it. *)

TYPE TaskPointer * = POINTER TO TaskPointerDesc;
     TaskPointerDesc * = RECORD(MTNodeDesc);
       task * : Task;
     END;

PROCEDURE (tp:TaskPointer) Init*;

BEGIN
  tp.task:=NIL;
  tp.Init^;
END Init;

PROCEDURE (tp:TaskPointer) Copy*(dest:l.Node);

BEGIN
  dest(TaskPointer).task:=tp.task;
  tp.Copy^(dest);
END Copy;

PROCEDURE (tp:TaskPointer) AllocNew*():l.Node;

VAR node : TaskPointer;

BEGIN
  NEW(node);
  RETURN node;
END AllocNew;



TYPE ChangeAble * = POINTER TO ChangeAbleDesc;
     ChangeAbleDesc * = RECORD(TaskDesc)
       tasklist * : MTList;
     END;

PROCEDURE (node:ChangeAble) Init*;

BEGIN
  node.tasklist:=Create();
  node.Init^;
END Init;

PROCEDURE (node:ChangeAble) Destruct*;

VAR tp,next : l.Node;

BEGIN
(* Stopping tasks related to this window. *)
  io.WriteString("DCH1\n");

  IF node.tasklist#NIL THEN
  io.WriteString("DCH2\n");
    tp:=node.tasklist.head;
    WHILE tp#NIL DO
      next:=tp.next;
      tp(TaskPointer).task.SendNewMsg(msgQuit,NIL);
      e.Forbid;
      IF tp(TaskPointer).task.list#NIL THEN
        tp(TaskPointer).task.Remove;
      END;
      e.Permit;
      tp:=next;
    END;
  io.WriteString("DCH3\n");
    node.tasklist.Destruct;
  END;
  io.WriteString("DCH4\n");
  node.Destruct^;
  io.WriteString("DCH5\n");
END Destruct;

PROCEDURE (node:ChangeAble) Copy*(dest:l.Node);

BEGIN
  node.tasklist.Copy(dest(ChangeAble).tasklist);
  node.Copy^(dest);
END Copy;

PROCEDURE (node:ChangeAble) AllocNew*():l.Node;

VAR node2 : ChangeAble;

BEGIN
  NEW(node2);
  RETURN node2;
END AllocNew;

PROCEDURE (node:ChangeAble) AddTask*(task:Task);

VAR tp : TaskPointer;

BEGIN
  NEW(tp); tp.Init;
  tp.task:=task;
  node.tasklist.AddTail(tp);
END AddTask;

PROCEDURE (node:ChangeAble) RemTask*(task:Task);

VAR tp,next : l.Node;

BEGIN
  tp:=node.tasklist.head;
  WHILE tp#NIL DO
    next:=tp.next;
    IF tp(TaskPointer).task=task THEN
      tp.Remove;
      tp.Destruct;
      next:=NIL;
    END;
    tp:=next;
  END;
END RemTask;

PROCEDURE (node:ChangeAble) FindTask*(id:LONGINT):Task;

VAR tp : l.Node;

BEGIN
  tp:=node.tasklist.head;
  WHILE tp#NIL DO
    IF (tp(TaskPointer).task.id=id) & tp(TaskPointer).task.isRunning() THEN
      RETURN tp(TaskPointer).task(Task);
    END;
    tp:=tp.next;
  END;
  RETURN NIL;
END FindTask;

PROCEDURE (node:ChangeAble) FindTaskName*(name:ARRAY OF CHAR):Task;

VAR tp : l.Node;

BEGIN
  tp:=node.tasklist.head;
  WHILE tp#NIL DO
    IF tt.Compare(tp(TaskPointer).task.taskname,name) THEN
      RETURN tp(TaskPointer).task;
    END;
    tp:=tp.next;
  END;
  RETURN NIL;
END FindTaskName;

PROCEDURE (chable:ChangeAble) SendMsgToAllTasks*(msg:Message);

VAR tp,next : l.Node;

BEGIN
  tp:=chable.tasklist.head;
  WHILE tp#NIL DO
    next:=tp.next;
    tp(TaskPointer).task.SendMsg(msg);
    tp:=next;
  END;
END SendMsgToAllTasks;

PROCEDURE (chable:ChangeAble) SendNewMsgToAllTasks*(type:LONGINT;data:l.Node);

VAR tp,next : l.Node;

BEGIN
  tp:=chable.tasklist.head;
  WHILE tp#NIL DO
    next:=tp.next;
    tp(TaskPointer).task.SendNewMsg(type,data);
    tp:=next;
  END;
END SendNewMsgToAllTasks;


(*(* Remember that you have to Lock and UnLock an object after using one of the
   following two methods due to the mathpri field which is set to TRUE!
   (or the Layout Mode will hang around waiting for you to setting the
   mathpri field to FALSE!) *)

PROCEDURE PutObject*(node:l.Node;changed:BOOLEAN);

VAR node2 : LayoutNode;

BEGIN
  NEW(node2);
  node2(LayoutNode).node:=node;
  node2(LayoutNode).prevgotobj:=FALSE;
  node2(LayoutNode).changed:=FALSE;
  layoutlist.AddTail(node2);
END PutObject;

PROCEDURE GetObject*():LayoutNode;

BEGIN

END GetObject;

PROCEDURE (node:LockAble) SendNew*;

BEGIN
  node.NewUser;
  node(LockAble).mathpri:=TRUE;
  PutObject(node,FALSE);
  e.Signal(layouttask,LONGSET{layoutnewobj});
END SendNew;

PROCEDURE (node:LockAble) SendChanged*;

BEGIN
  node.mathpri:=TRUE;
  PutObject(node,TRUE);
  e.Signal(layouttask,LONGSET{layoutnewobj});
END SendChanged;*)



(* Additional for ShareAble-Object *)

PROCEDURE (node:ShareAble) Copy*(dest:l.Node);

BEGIN
  dest(ShareAble).numtasks:=node.numtasks;
  node.Copy^(dest);
END Copy;

PROCEDURE (node:ShareAble) AllocNew*():l.Node;

VAR node2 : ShareAble;

BEGIN
  NEW(node2);
  RETURN node2;
END AllocNew;

PROCEDURE (node:ShareAble) NewUser*(task:Task);

VAR taskptr : TaskPointer;

BEGIN
  e.ObtainSemaphore(node.sharesem^);
  INC(node.numtasks);
  IF task#NIL THEN
    NEW(taskptr); taskptr.Init;
    taskptr.task:=task;
    node.tasks.AddTail(taskptr);
  END;
  e.ReleaseSemaphore(node.sharesem^);
END NewUser;

PROCEDURE (node:ShareAble) FreeUser*(task:Task);

VAR taskptr,next : l.Node;

BEGIN
  e.ObtainSemaphore(node.sharesem^);
  IF task#NIL THEN
    taskptr:=node.tasks.head;
    WHILE taskptr#NIL DO
      next:=taskptr.next;
      IF taskptr(TaskPointer).task=task THEN
        taskptr.Remove;
        taskptr.Destruct;
        next:=NIL;
      END;
      taskptr:=next;
    END;
  END;
  DEC(node.numtasks);
  e.ReleaseSemaphore(node.sharesem^);
END FreeUser;

PROCEDURE (node:ShareAble) GetUserNumber*():INTEGER;

BEGIN
  RETURN node.numtasks;
END GetUserNumber;

PROCEDURE (node:ShareAble) SendNewMsgToAllUsers*(type:LONGINT;data:e.APTR);
(* Sends a change message to tasks which use this node at the moment. *)
(* If a task multiple uses this node it will only get one message. *)
(* Former name of method: SendChangeMessage *)

(* I once had a SendMsgToAllusers method. However there are problems
   with such a method:
   You provide a pointer to a message when calling the method. This
   msg gets sent to several tasks, which all try to Reply (and DISPOSE)
   the same message. This will lead to a crash!
   To avoid this problem the method has been removed. *)

VAR taskptr,taskptr2 : l.Node;

BEGIN
  e.ObtainSemaphoreShared(node.sharesem^);
  taskptr:=node.tasks.head;
  WHILE taskptr#NIL DO
    IF taskptr(TaskPointer).task#NIL THEN
      taskptr2:=node.tasks.head;
      WHILE (taskptr2#NIL) & (taskptr2#taskptr) & (taskptr2(TaskPointer).task#taskptr(TaskPointer).task) DO
        taskptr2:=taskptr2.next;
      END;
      IF taskptr2=taskptr THEN
        io.WriteString("ShareAble.SendNewMsgToAllUsers sent a msg to an task using this ShareAble.\n");
        taskptr(TaskPointer).task.SendNewMsg(type,data);
      END;
(*      taskptr2:=node.tasks.head;
      WHILE (taskptr2#taskptr) & (taskptr2#NIL) DO
        IF taskptr2=taskptr THEN
          taskptr(TaskPointer).task.SendNewMsg(msgNodeChanged,node);
        ELSIF taskptr2(TaskPointer).task=taskptr(TaskPointer).task THEN
          taskptr2:=NIL;
        END;
        IF taskptr2#NIL THEN taskptr2:=taskptr2.next; END;
      END;*)
(*      taskptr(TaskPointer).task.SendNewMsg(msgListChanged,node.list);*)
    END;
    taskptr:=taskptr.next;
  END;
  e.ReleaseSemaphore(node.sharesem^);
END SendNewMsgToAllUsers;

PROCEDURE (node:ShareAble) Changed*;
(* Sends a change message to tasks which use this node at the moment. *)
(* If a task multiple uses this node it will only get one message. *)
(* Former name of method: SendChangeMessage *)

VAR taskptr,taskptr2 : l.Node;

BEGIN
  node.SendNewMsgToAllUsers(msgNodeChanged,node);
(*  e.ObtainSemaphoreShared(node.sharesem^);
  taskptr:=node.tasks.head;
  WHILE taskptr#NIL DO
    IF taskptr(TaskPointer).task#NIL THEN
      taskptr2:=node.tasks.head;
      WHILE (taskptr2#NIL) & (taskptr2#taskptr) & (taskptr2(TaskPointer).task#taskptr(TaskPointer).task) DO
        taskptr2:=taskptr2.next;
      END;
      IF taskptr2=taskptr THEN
        io.WriteString("ShareAble.Changed an task using this ShareAble.\n");
        taskptr(TaskPointer).task.SendNewMsg(msgNodeChanged,node);
      END;
(*      taskptr2:=node.tasks.head;
      WHILE (taskptr2#taskptr) & (taskptr2#NIL) DO
        IF taskptr2=taskptr THEN
          taskptr(TaskPointer).task.SendNewMsg(msgNodeChanged,node);
        ELSIF taskptr2(TaskPointer).task=taskptr(TaskPointer).task THEN
          taskptr2:=NIL;
        END;
        IF taskptr2#NIL THEN taskptr2:=taskptr2.next; END;
      END;*)
(*      taskptr(TaskPointer).task.SendNewMsg(msgListChanged,node.list);*)
    END;
    taskptr:=taskptr.next;
  END;
  e.ReleaseSemaphore(node.sharesem^);*)
END Changed;



(* Methods of MTList *)

PROCEDURE (list:MTList) Destruct*;

BEGIN
  WHILE list.numtasks>0 DO
    d.Delay(50);
  END;
  list.DestructNodes;
  IF list.tasklist#NIL THEN DISPOSE(list.tasklist); END;
  IF list.remlist#NIL THEN DISPOSE(list.remlist); END;
  IF list.semaphore#NIL THEN DISPOSE(list.semaphore); END;
  DISPOSE(list);
END Destruct;

PROCEDURE (list:MTList) Lock*(shared:BOOLEAN);

BEGIN
  e.ObtainSemaphore(list.semaphore^);
END Lock;

PROCEDURE (list:MTList) UnLock*;

BEGIN
  e.ReleaseSemaphore(list.semaphore^);
END UnLock;

PROCEDURE (list:MTList) SendNewMsgToAllTasks*(type:LONGINT;data:e.APTR);
(* Sends msg to all using tasks *)

VAR tasknode : l.Node;

BEGIN
  e.ObtainSemaphore(list.semaphore^);
  tasknode:=list.tasklist.head;
  WHILE tasknode#NIL DO
    tasknode(MTTaskNode).task(Task).SendNewMsg(type,data);
    tasknode:=tasknode.next;
  END;
  e.ReleaseSemaphore(list.semaphore^);
END SendNewMsgToAllTasks;

PROCEDURE (list:MTList) Changed*;

BEGIN
  list.SendNewMsgToAllTasks(msgListChanged,list);
END Changed;

PROCEDURE (list:MTList) SendNewMsgToAllNodes*(type:LONGINT;data:e.APTR);
(* Sends msg to all nodes of this list which are of type Task. *)

VAR node : l.Node;

BEGIN
  node:=list.head;
  WHILE node#NIL DO
    IF node IS Task THEN
      io.WriteString("Sending msg to task in MTList\n");
      node(Task).SendNewMsg(type,data);
    END;
    node:=node.next;
  END;
END SendNewMsgToAllNodes;

PROCEDURE (list:MTList) AddUsers*(node:ShareAble);

VAR tasknode : l.Node;

BEGIN
  tasknode:=list.tasklist.head;
  WHILE tasknode#NIL DO
    IF tasknode(MTTaskNode).activeuser THEN
      node.NewUser(tasknode(MTTaskNode).task(Task));
    END;
    tasknode:=tasknode.next;
  END;
END AddUsers;

PROCEDURE (list:MTList) AddHead*(node:l.Node);

BEGIN
  e.ObtainSemaphore(list.semaphore^);
  IF node IS ShareAble THEN
(*    INC(node(ShareAble).numtasks,list.numtasks);*)
    list.AddUsers(node(ShareAble));
  END;
  list.AddHead^(node);
  list.Changed;
  e.ReleaseSemaphore(list.semaphore^);
END AddHead;

PROCEDURE (list:MTList) AddTail*(node:l.Node);

BEGIN
  e.ObtainSemaphore(list.semaphore^);
  IF node IS ShareAble THEN
(*    INC(node(ShareAble).numtasks,list.numtasks);*)
    list.AddUsers(node(ShareAble));
  END;
  list.AddTail^(node);
  list.Changed;
  e.ReleaseSemaphore(list.semaphore^);
END AddTail;

PROCEDURE (list:MTList) RemHead*():l.Node;

VAR node : l.Node;

BEGIN
  e.ObtainSemaphore(list.semaphore^);
  node:=list.RemHead^();
  list.Changed;
  e.ReleaseSemaphore(list.semaphore^);
  RETURN node;
END RemHead;

PROCEDURE (list:MTList) RemTail*():l.Node;

VAR node : l.Node;

BEGIN
  e.ObtainSemaphore(list.semaphore^);
  node:=list.RemTail^();
  list.Changed;
  e.ReleaseSemaphore(list.semaphore^);
  RETURN node;
END RemTail;

PROCEDURE (list:MTList) Add*(node:bt.ANY);

BEGIN
  e.ObtainSemaphore(list.semaphore^);
  IF node IS ShareAble THEN
(*    INC(node(ShareAble).numtasks,list.numtasks);*)
    list.AddUsers(node(ShareAble));
  END;
  list.Add^(node);
  list.Changed;
  e.ReleaseSemaphore(list.semaphore^);
END Add;

PROCEDURE (node:MTNode) Remove*;

(* Remember: node can't be destructed during this procedure because the caller
             has to call node.FreeUser before. *)

VAR semaphore : e.SignalSemaphorePtr;
    list      : l.List;
    remnode   : l.Node;

BEGIN
  e.Forbid;
  IF node.list#NIL THEN
    list:=node.list;
    WITH list: MTList DO
      semaphore:=node.list(MTList).semaphore;
      e.Permit;
      e.ObtainSemaphore(semaphore^);
      node.Remove^;

      IF list.numtasks>0 THEN
        NEW(remnode(RemListNode));
        remnode(RemListNode).node:=node;
        list(MTList).remlist.AddTail(remnode);
      END;
      e.ReleaseSemaphore(semaphore^);
      list(MTList).Changed;
    ELSE
      node.Remove^;
    END;
  ELSE
    e.Permit;
  END;
END Remove;

PROCEDURE (node:MTNode) AddBefore*(node2:l.Node);

VAR list : l.List;

BEGIN
  list:=node.list;
  IF list#NIL THEN
    IF list IS MTList THEN
      e.ObtainSemaphore(list(MTList).semaphore^);
      IF node2 IS ShareAble THEN
(*        INC(node2(ShareAble).numtasks,list(MTList).numtasks);*)
        list(MTList).AddUsers(node2(ShareAble));
      END;
      node.AddBefore^(node2);
      list(MTList).Changed;
      e.ReleaseSemaphore(list(MTList).semaphore^);
    ELSE
      node.AddBefore^(node2);
    END;
  END;
END AddBefore;

PROCEDURE (node:MTNode) AddBehind*(node2:l.Node);

VAR list : l.List;

BEGIN
  list:=node.list;
  IF list#NIL THEN
    IF list IS MTList THEN
      e.ObtainSemaphore(list(MTList).semaphore^);
      IF node2 IS ShareAble THEN
(*        INC(node2(ShareAble).numtasks,list(MTList).numtasks);*)
        list(MTList).AddUsers(node2(ShareAble));
      END;
      node.AddBehind^(node2);
      list(MTList).Changed;
      e.ReleaseSemaphore(list(MTList).semaphore^);
    ELSE
      node.AddBehind^(node2);
    END;
  END;
END AddBehind;

PROCEDURE (list:MTList) NewUserAllNodes(task:Task);

VAR node : l.Node;

BEGIN
  e.ObtainSemaphore(list.semaphore^);
  node:=list.head;
  WHILE node#NIL DO
    IF node IS ShareAble THEN
      node(ShareAble).NewUser(task);
    END;
    node:=node.next;
  END;
  node:=list.remlist.head;
  WHILE node#NIL DO
    IF node IS ShareAble THEN
      node(RemListNode).node(ShareAble).NewUser(task);
    END;
    node:=node.next;
  END;
  e.ReleaseSemaphore(list.semaphore^);
END NewUserAllNodes;

PROCEDURE (list:MTList) FreeUserAllNodes(task:Task);

VAR node,next : l.Node;

BEGIN
  e.ObtainSemaphore(list.semaphore^);
  node:=list.head;
  WHILE node#NIL DO
    IF node IS ShareAble THEN
      node(ShareAble).FreeUser(task);
    END;
    node:=node.next;
  END;
  node:=list.remlist.head;
  WHILE node#NIL DO
    next:=node.next;
    IF node(RemListNode).node IS ShareAble THEN
      node(RemListNode).node(ShareAble).FreeUser(task);
    END;
    IF list.numtasks=0 THEN
      node.Remove;
      node.Destruct;
    END;
    node:=next;
  END;
  e.ReleaseSemaphore(list.semaphore^);
END FreeUserAllNodes;

PROCEDURE (list:MTList) NewUser*(task:Task;activeuser:BOOLEAN);
(* Set activeuser to TRUE if all nodes of the list shall be
   NewUserered. In this case they won't get destructed unless you
   call MTList.FreeUser. Set to FALSE if you only want to be
   informed when the list gets changed. *)

VAR tasknode : l.Node;

BEGIN
  e.ObtainSemaphore(list.semaphore^);
  INC(list.numtasks);
  NEW(tasknode(MTTaskNode)); tasknode.Init;
  tasknode(MTTaskNode).task:=task;
  tasknode(MTTaskNode).activeuser:=activeuser;
  list.tasklist.AddTail(tasknode);
  IF activeuser THEN
    list.NewUserAllNodes(task);
  END;
  e.ReleaseSemaphore(list.semaphore^);
END NewUser;

PROCEDURE (list:MTList) FreeUser*(task:Task);

VAR tasknode,next : l.Node;
    activeuser    : BOOLEAN;

BEGIN
  activeuser:=FALSE;
  e.ObtainSemaphore(list.semaphore^);
  DEC(list.numtasks);
  tasknode:=list.tasklist.head;
  WHILE tasknode#NIL DO
    next:=tasknode.next;
    IF tasknode(MTTaskNode).task=task THEN
      tasknode.Remove;
      tasknode.Destruct;
      activeuser:=tasknode(MTTaskNode).activeuser;
      next:=NIL;
    END;
    tasknode:=next;
  END;
  IF activeuser THEN
    list.FreeUserAllNodes(task);
  END;
  e.ReleaseSemaphore(list.semaphore^);
END FreeUser;



TYPE TaskData * = POINTER TO TaskDataDesc;
     TaskDataDesc * = RECORD
       maintask      * ,
       layouttask    * : ChangeAble;
(*       windowlist    * ,
       requesterlist * : l.List;*)
       mainpri       * ,
       layoutpri     * ,
       windowpri     * ,
       requesterpri  * : SHORTINT;
     END;

VAR taskdata * : TaskData;

PROCEDURE (taskdata:TaskData) Init*;

BEGIN
  taskdata.maintask:=NIL;
  taskdata.layouttask:=NIL;
(*  taskdata.windowlist:=l.Create();
  taskdata.requesterlist:=l.Create();*)
  taskdata.mainpri:=1;
  taskdata.layoutpri:=0;
  taskdata.windowpri:=0;
  taskdata.requesterpri:=1;
END Init;

PROCEDURE (taskdata:TaskData) Destruct*;

BEGIN
(*  IF taskdata.windowlist#NIL THEN taskdata.windowlist.Destruct; END;
  IF taskdata.requesterlist#NIL THEN taskdata.requesterlist.Destruct; END;*)
  DISPOSE(taskdata);
END Destruct;



BEGIN
  taskdata:=NIL;
  NEW(taskdata); taskdata.Init;
CLOSE
  io.WriteString("CMU1\n");
  IF taskdata#NIL THEN taskdata.Destruct; END;
  io.WriteString("CMU2\n");
END Multitasking.

