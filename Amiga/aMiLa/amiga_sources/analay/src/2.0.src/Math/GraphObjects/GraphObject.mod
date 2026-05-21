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


MODULE GraphObject;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       dc : DisplayConversion,
       m  : Multitasking,
       mem: MemoryManager,
       tid: TaskIDs,
       mg : MathGUI,
       w  : Window,
       co : Coords,
       cf : CoordFormat,
       cb : CoordObject,
       nf : NumberFormat,
       fm : FontManager,
       fo : FontOrganizer,
       bt : BasicTypes,
       io,
       NoGuruRq;

TYPE GraphObject * = POINTER TO GraphObjectDesc;
     GraphObjectDesc * = RECORD(cb.CoordObjectDesc)
       string         * : ARRAY 256 OF CHAR;
       coordformat    * : cf.CoordFormat;
       numberformat   * : nf.NumberFormat;
       colorf*,colorb * : INTEGER;
       fontinfo       * : fo.FontInfo;
       font           * : fm.Font;
       transparent    * : BOOLEAN; (* Object is transparent? *)
       movingobject   * : BOOLEAN; (* Moving object at the moment? *)
       newobject      * : BOOLEAN; (* Object had only just been created. -> Delete it if user selects Cancel in the Change-Requester. *)
     END;

TYPE GraphObjectList * = POINTER TO GraphObjectListDesc;
     GraphObjectListDesc * = RECORD(m.MTListDesc)
     END;

PROCEDURE (graphobject:GraphObject) Init*;

BEGIN
  NEW(graphobject.coordformat); graphobject.coordformat.Init;
  NEW(graphobject.numberformat); graphobject.numberformat.Init;
  NEW(graphobject.fontinfo); graphobject.fontinfo.Init;
  graphobject.font:=NIL;
  graphobject.Init^;
  graphobject.string:="";
  graphobject.colorf:=2;
  graphobject.colorb:=0;
  graphobject.transparent:=FALSE;
  graphobject.movingobject:=FALSE;
  graphobject.newobject:=TRUE;
END Init;

PROCEDURE (graphobj:GraphObject) InitGraphObject*(window:w.Window;coords:co.CoordSystem);

BEGIN
  graphobj.Init;
  graphobj.SetWindow(window);
  graphobj.SetCoordSystem(coords);
END InitGraphObject;

PROCEDURE (graphobject:GraphObject) Destruct*;

BEGIN
(*  IF graphobject.attr.name#NIL THEN e.FreeMem(graphobject.attr.name,SIZE(CHAR)*256); END;*)
  IF graphobject.font#NIL THEN graphobject.font.Destruct; END;
  IF graphobject.fontinfo#NIL THEN graphobject.fontinfo.Destruct; END;
  IF graphobject.numberformat#NIL THEN graphobject.numberformat.Destruct; END;
  IF graphobject.coordformat#NIL THEN graphobject.coordformat.Destruct; END;
  graphobject.Destruct^;
END Destruct;

PROCEDURE (graphobj:GraphObject) Copy*(dest:l.Node);

BEGIN
  WITH dest: GraphObject DO
    COPY(graphobj.string,dest.string);
    dest.coordformat:=graphobj.coordformat;
    dest.numberformat:=graphobj.numberformat;
    dest.colorf:=graphobj.colorf;
    dest.colorb:=graphobj.colorb;
    IF dest.fontinfo=NIL THEN NEW(dest.fontinfo); dest.fontinfo.Init; END;
    graphobj.fontinfo.Copy(dest.fontinfo);
    IF dest.font#NIL THEN dest.font.Destruct; dest.font:=NIL; END;
    dest.font:=dest.fontinfo.Open();
    dest.transparent:=graphobj.transparent;
    dest.movingobject:=graphobj.movingobject;
  END;
  graphobj.Copy^(dest);
END Copy;

PROCEDURE (graphobj:GraphObject) AllocNew*():l.Node;

VAR node : l.Node;

BEGIN
  NEW(node(GraphObject));
  RETURN node;
END AllocNew;

PROCEDURE (graphobj:GraphObject) Clicked*(mouseX,mouseY:LONGINT):BOOLEAN;
END Clicked;

PROCEDURE (graphobj:GraphObject) SetDrawModes*(rast:g.RastPortPtr);

BEGIN
  IF graphobj.transparent THEN
    g.SetDrMd(rast,g.jam1);
  ELSE
    g.SetDrMd(rast,g.jam2);
  END;
  g.SetAPen(rast,graphobj.colorf);
  g.SetBPen(rast,graphobj.colorb);
END SetDrawModes;

PROCEDURE (graphobj:GraphObject) Plot*(rast:g.RastPortPtr;rect:co.Rectangle;conv:dc.ConversionTable);
END Plot;

PROCEDURE (graphobj:GraphObject) PlotBorder*(rast:g.RastPortPtr);
END PlotBorder;

PROCEDURE (graphobj:GraphObject) Change*(changetask:m.Task):BOOLEAN;
END Change;

PROCEDURE (graphobj:GraphObject) Move*(mes:I.IntuiMessagePtr):BOOLEAN;

(* TRUE if position really was changed, FALSE if aborted. *)

VAR oldx,oldy : LONGREAL;
    offx,offy,
    x,y,ox,oy : INTEGER;
    ret       : BOOLEAN;

BEGIN
  IF graphobj.window#NIL THEN
    graphobj.window.Lock(TRUE);

    ret:=TRUE;
    graphobj.movingobject:=TRUE;
    graphobj.GetCoordsWorld(graphobj.window.rect,oldx,oldy);
    IF (I.mouseButtons IN mes.class) OR (I.mouseMove IN mes.class) THEN
      graphobj.GetCoordsPic(graphobj.window.rect,x,y);
      offx:=mes.mouseX-x;
      offy:=mes.mouseY-y;
    ELSE
      offx:=0;
      offy:=0;
    END;
    graphobj.Plot(graphobj.window.rast,graphobj.window.rect,mg.mathconv);
    LOOP
      graphobj.window.subwindow.WaitPort;
      graphobj.window.GetIMes(mes);
      ox:=x; oy:=y;
      graphobj.window.subwindow.GetMousePos(x,y);
      x:=x-offx; y:=y-offy;
      IF (x#ox) OR (y#oy) THEN
        graphobj.Plot(graphobj.window.rast,graphobj.window.rect,mg.mathconv);
        graphobj.SetCoordsPic(graphobj.window.rect,x,y);
        graphobj.Snap;
        graphobj.Plot(graphobj.window.rast,graphobj.window.rect,mg.mathconv);
      END;
      IF (I.mouseButtons IN mes.class) & (mes.code=I.selectUp) THEN
        graphobj.Plot(graphobj.window.rast,graphobj.window.rect,mg.mathconv);
        graphobj.SetCoordsPic(graphobj.window.rect,mes.mouseX-offx,mes.mouseY-offy);
        graphobj.Snap;
        mes.class:=LONGSET{};
        graphobj.Changed;
        EXIT;
      ELSIF (I.menuPick IN mes.class) THEN
        graphobj.Plot(graphobj.window.rast,graphobj.window.rect,mg.mathconv);
        graphobj.SetCoordsWorld(graphobj.window.rect,oldx,oldy);
        ret:=FALSE;
        EXIT;
      END;
    END;
    graphobj.movingobject:=FALSE;

    graphobj.window.UnLock;
  ELSE
    ret:=FALSE;
  END;
  RETURN ret;
END Move;

PROCEDURE (graphobj:GraphObject) InputEvent*(mes:I.IntuiMessagePtr):BOOLEAN;

VAR xpos,ypos : INTEGER;
    bool      : BOOLEAN;

BEGIN
  IF graphobj.window#NIL THEN
    IF (I.mouseButtons IN mes.class) & (mes.code=I.selectDown) THEN
      IF graphobj.Clicked(mes.mouseX,mes.mouseY) THEN
        bool:=graphobj.Move(mes);
        IF bool THEN
          graphobj.window.changed:=TRUE;
          graphobj.window.SendNewMsg(m.msgNodeChanged,graphobj);
        END;
        RETURN TRUE;
      END;
    END;
  END;
  RETURN FALSE;
END InputEvent;



(* Methods of GraphObjectList *)

PROCEDURE Create*():GraphObjectList;

VAR
  list: GraphObjectList;
BEGIN
  NEW(list); list.Init;
  RETURN list;
END Create;

PROCEDURE (list:GraphObjectList) GetMouseObject*(x,y:LONGINT):GraphObject;

VAR node : l.Node;

BEGIN
  node:=list.head;
  WHILE node#NIL DO
    IF node(GraphObject).Clicked(x,y) THEN
      RETURN node(GraphObject);
    END;
    node:=node.next;
  END;
  RETURN NIL;
END GetMouseObject;

PROCEDURE (list:GraphObjectList) Select*():GraphObject;

VAR mes       : I.IntuiMessagePtr;
    actobj    : l.Node;
    graphwind : w.Window;
    x,y,ox,oy : INTEGER;

BEGIN
  IF list.head#NIL THEN
    graphwind:=list.head(GraphObject).window;
    IF graphwind=NIL THEN RETURN NIL; END;

io.WriteString("SG1\n");

    graphwind.Lock(TRUE);

    NEW(mes);

io.WriteString("SG2\n");
    graphwind.subwindow.GetMousePos(x,y);
io.WriteString("SG3\n");
    actobj:=list.GetMouseObject(x,y);
io.WriteString("SG4\n");
    IF actobj#NIL THEN actobj(GraphObject).PlotBorder(graphwind.rast); END;

    REPEAT
io.WriteString("SG5\n");
      graphwind.subwindow.WaitPort;
io.WriteString("SG6\n");
      graphwind.GetIMes(mes);
io.WriteString("SG7\n");
      ox:=x; oy:=y;
io.WriteString("SG8\n");
      graphwind.subwindow.GetMousePos(x,y);
io.WriteString("SG9\n");
      IF (ox#x) OR (oy#y) THEN
        IF actobj#NIL THEN actobj(GraphObject).PlotBorder(graphwind.rast); END;
io.WriteString("SG10\n");
        actobj:=list.GetMouseObject(x,y);
io.WriteString("SG11\n");
        IF actobj#NIL THEN actobj(GraphObject).PlotBorder(graphwind.rast); END;
io.WriteString("SG12\n");
      END;
      IF I.mouseButtons IN mes.class THEN
        IF actobj#NIL THEN actobj(GraphObject).PlotBorder(graphwind.rast); END;
        actobj:=list.GetMouseObject(mes.mouseX,mes.mouseY);
      ELSIF I.menuPick IN mes.class THEN
        IF actobj#NIL THEN actobj(GraphObject).PlotBorder(graphwind.rast); END;
        actobj:=NIL;
      END;
    UNTIL (I.mouseButtons IN mes.class) OR (I.menuPick IN mes.class);

    DISPOSE(mes);
    IF actobj#NIL THEN RETURN actobj(GraphObject);
                  ELSE RETURN NIL; END;

    graphwind.UnLock;
  ELSE
    RETURN NIL;
  END;
END Select;

PROCEDURE ChangeGraphObjectTask*(changetask:bt.ANY):bt.ANY;

VAR data : GraphObject;
    bool : BOOLEAN;

BEGIN
  WITH changetask: m.Task DO
    changetask.InitCommunication;
    data:=changetask.data(GraphObject);
    bool:=data.Change(changetask);
  
    data.RemTask(changetask);
    changetask.ReplyAllMessages;
    changetask.DestructCommunication;
    data.FreeUser(changetask);
    mem.NodeToGarbage(changetask);
    IF (~bool) & (data.newobject) THEN
      IF data.list#NIL THEN
        data.Remove;
      END;
      data.SendNewMsgToAllTasks(m.msgQuit,NIL);
      data.ReplyAllMessages;
      data.DestructCommunication;
      mem.NodeToGarbage(data);
    ELSE
      data.newobject:=FALSE;
    END;
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END ChangeGraphObjectTask;

PROCEDURE (graphobj:GraphObject) StartChangeTask*;

VAR task : m.Task;
    bool : BOOLEAN;

BEGIN
  task:=graphobj.FindTask(tid.changeTaskID);
  IF task=NIL THEN
    NEW(task); task.Init;
    task.InitTask(ChangeGraphObjectTask,graphobj,10000,m.taskdata.requesterpri);
    task.SetID(tid.changeTaskID);
    graphobj.AddTask(task);
    graphobj.NewUser(task);
    bool:=task.Start();
  ELSE
    task.SendNewMsg(m.msgActivate,NIL);
  END;
END StartChangeTask;

END GraphObject.

