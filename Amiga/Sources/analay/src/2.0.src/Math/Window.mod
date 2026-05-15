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


MODULE Window;

(* CheckChanged has to be prepared for communication with Layout Mode. *)

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       tt : TextTools,
       m  : Multitasking,
       co : Coords,
       dc : DisplayConversion,
       mg : MathGUI,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       io,
       NoGuruRq;

(* General class for any window in the math mode (except requesters). *)

TYPE Window * = POINTER TO WindowDesc;
     WindowDesc * = RECORD(m.ChangeAbleDesc)
       windname * : ARRAY 256 OF CHAR;
       window   * : wm.Window;
       subwindow* : wm.SubWindow;
       iwind    * : I.WindowPtr;
       rast     * : g.RastPortPtr;
       rect     * : co.Rectangle;  (* Substitutes inx,iny,innerwi,innerhe. *)
       innerrect* : co.Rectangle;  (* Same as rect, but leaves some space towards the window borders. *)
(*       inx*,iny*,                   (* Top- and Leftedge of drawing area. *)
       innerwi*,innerhe*: INTEGER;*)
       backcol  * : INTEGER;
       changed  * ,
       sizechanged*: BOOLEAN;      (* For quick Auto-Method (e.g. GraphWindow's Auto-Method) *)
     END;

TYPE WindowList * = POINTER TO WindowListDesc;
     WindowListDesc * = RECORD(m.MTListDesc)
     END;



PROCEDURE (window:Window) Init*;

BEGIN
  window.windname:="Window";
  window.window:=wm.InitWindow(100,20,320,152,FALSE,s.ADR(window.windname),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing,I.windowClose},gmb.stdIDCMP);
  window.window.SetMinMax(100,80,-1,-1);
  window.window.SetMenu(mg.menu);
  window.subwindow:=NIL;
  window.iwind:=NIL;
  window.rast:=NIL;
  window.rect:=NIL;
  NEW(window.rect);
  window.rect.Init(window.subwindow);
  window.innerrect:=NIL;
  NEW(window.innerrect);
  window.innerrect.Init(window.subwindow);
  window.backcol:=0;
  window.changed:=TRUE;
  window.sizechanged:=TRUE;
  window.Init^;
END Init;

PROCEDURE (window:Window) Destruct*;

BEGIN
  io.WriteString("DW1\n");
  IF window.window#NIL THEN
    window.window.Destruct;
  END;
  io.WriteString("DW2\n");
  window.rect.Destruct;
  io.WriteString("DW3\n");
  window.innerrect.Destruct;
  io.WriteString("DW4\n");
  window.Destruct^;
  io.WriteString("DW5\n");
END Destruct;

PROCEDURE (window:Window) Copy*(dest:l.Node);

BEGIN
  WITH dest: Window DO
    COPY(window.windname,dest.windname);
    dest.backcol:=window.backcol;
(*    dest.window:=window.window;
    dest.subwindow:=window.subwindow;
    dest.iwind:=window.iwind;
    dest.rast:=window.rast;
    dest.rect:=window.rect;
    dest.innerrect:=window.innerrect;
    dest.backcol:=window.backcol;
    dest.changed:=dest.changed;*)
  END;
(*  window.Copy^(dest);*) (* Caused problems with standardlegend.Copy(newlegend); *)
END Copy;

PROCEDURE (window:Window) AllocNew*():l.Node;

VAR node : Window;

BEGIN
  NEW(node);
  RETURN node;
END AllocNew;

PROCEDURE (window:Window) InitInnerRect;

BEGIN
  window.innerrect.Init(window.subwindow);
  IF window.iwind#NIL THEN
    INC(window.innerrect.xoff,window.iwind.borderLeft);
    INC(window.innerrect.yoff,window.iwind.borderLeft DIV 2);
    DEC(window.innerrect.width,window.iwind.borderLeft*2);
    DEC(window.innerrect.height,window.iwind.borderLeft);
  END;
END InitInnerRect;

PROCEDURE (window:Window) Open*;

BEGIN
  IF window.subwindow=NIL THEN
    window.subwindow:=window.window.InitSub(mg.screen);
  END;
  IF (window.subwindow#NIL) & (window.iwind=NIL) THEN
    window.iwind:=window.subwindow.Open(NIL);
    IF window.iwind=NIL THEN
      window.subwindow.Destruct;
    END;
  END;
  IF window.iwind#NIL THEN
    window.rast:=window.iwind.rPort;
    window.rect.Init(window.subwindow);
    window.InitInnerRect;
  END;
END Open;

PROCEDURE (window:Window) Close*;

BEGIN
  IF window.subwindow#NIL THEN
    window.subwindow.Destruct;
    window.subwindow:=NIL;
    window.iwind:=NIL;
(*    I.ClearMenuStrip(node.wind);*)
  END;
END Close;

PROCEDURE (window:Window) ClearBack*;

BEGIN
  IF window.iwind#NIL THEN
    g.SetAPen(window.rast,window.backcol);
    g.RectFill(window.rast,window.rect.xoff,window.rect.yoff,window.rect.xoff+window.rect.width-1,window.rect.yoff+window.rect.height-1);
  END;
END ClearBack;

PROCEDURE (window:Window) Plot*(rast:g.RastPortPtr;rect:co.Rectangle;conv:dc.ConversionTable;dragbarplot:BOOLEAN);
END Plot;

PROCEDURE (window:Window) Refresh*;

BEGIN
  IF window.changed THEN
    window.Open;           (* Also updates window.rect *)
    window.ClearBack;
  END;
END Refresh;

PROCEDURE (window:Window) Resize*;

(* Adapts window to new size. Same as Refresh, but does not refresh window
   contents. *)

BEGIN
  IF window.changed THEN
    window.Open;           (* Also updates window.rect *)
    window.ClearBack;
  END;
END Resize;

PROCEDURE (window:Window) InputEvent*(mes:I.IntuiMessagePtr);

BEGIN
(*  IF I.closeWindow IN mes.class THEN
    window.Destruct;
  ELSIF I.newSize IN mes.class THEN
    window.changed:=TRUE;
    window.Refresh;
  END;*)
END InputEvent;

PROCEDURE (window:Window) RawGetIMes*(mes:I.IntuiMessagePtr);

BEGIN
  mes.class:=LONGSET{};
  mes.code:=0;
  mes.iAddress:=NIL;
  mes.qualifier:=SET{};
  IF window.subwindow#NIL THEN
    window.subwindow.GetIMes(mes);
  END;
END RawGetIMes;

PROCEDURE (window:Window) GetIMes*(mes:I.IntuiMessagePtr);

BEGIN
  mes.class:=LONGSET{};
  mes.code:=0;
  mes.iAddress:=NIL;
  mes.qualifier:=SET{};
  IF window.subwindow#NIL THEN
    window.subwindow.GetIMes(mes);
    window.InputEvent(mes);
  END;
END GetIMes;

PROCEDURE (window:Window) CheckChanged*(checksize:BOOLEAN):BOOLEAN;

(* Checks if the window has to be redrawn. *)

VAR mes     : I.IntuiMessagePtr;
    msg     : m.Message;
    changed : BOOLEAN;

BEGIN
  NEW(mes);
  changed:=FALSE;
(*  mes.class:=e.SetSignal(LONGSET{},LONGSET{});
  IF window.msgsig IN mes.class THEN*)
    msg:=window.ReceiveMsgType(m.msgNodeChanged);
    IF msg#NIL THEN
      IF msg.type=m.msgNodeChanged THEN
        changed:=TRUE;
        msg.Reply;
(*      ELSE
        window.SendMsg(msg);*)
      END;
    END;
(*  END;*)
  IF checksize THEN
    REPEAT
      window.RawGetIMes(mes);
      IF I.newSize IN mes.class THEN
        changed:=TRUE;
        window.rect.Init(window.subwindow);
        window.InitInnerRect;
      END;
    UNTIL mes.class=LONGSET{};
  END;
  IF changed THEN
    window.changed:=TRUE;
    window.sizechanged:=TRUE; (* Maybe the axisranges have been changed. *)
  END;
  DISPOSE(mes);
  RETURN changed;
END CheckChanged;

PROCEDURE (window:Window) SelectBox*(VAR x1,y1,x2,y2:INTEGER):BOOLEAN;
(* TRUE=success *)
(* MouseButton must already be pressed -> x,y have to be filled with
   proper values. *)

VAR rast    : g.RastPortPtr;
    mes     : I.IntuiMessagePtr;
    ox2,oy2 : INTEGER;
    ret     : BOOLEAN;

  PROCEDURE DrawBox;

  BEGIN
    g.Move(rast,x1,y1);
    g.Draw(rast,x2,y1);
    g.Draw(rast,x2,y2);
    g.Draw(rast,x1,y2);
    g.Draw(rast,x1,y1);
  END DrawBox;

BEGIN
  ret:=FALSE;
  IF window.iwind#NIL THEN
    NEW(mes);
    rast:=window.rast;
    g.SetDrMd(rast,SHORTSET{g.complement});
    window.subwindow.GetMousePos(x2,y2);
    DrawBox;
    REPEAT
      e.WaitPort(window.iwind.userPort);
      window.GetIMes(mes);
      window.subwindow.GetMousePos(ox2,oy2);
      IF (x2#ox2) OR (y2#oy2) THEN
        DrawBox;
        x2:=ox2; y2:=oy2;
        DrawBox;
      END;
      IF I.menuPick IN mes.class THEN ret:=FALSE;
      ELSIF I.mouseButtons IN mes.class THEN ret:=TRUE; END;
    UNTIL (I.mouseButtons IN mes.class) OR (I.menuPick IN mes.class);
    DrawBox;
    g.SetDrMd(rast,g.jam1);
    IF x2<x1 THEN
      ox2:=x2;
      x2:=x1;
      x1:=ox2;
    END;
    IF y2<y1 THEN
      oy2:=y2;
      y2:=y1;
      y1:=oy2;
    END;
    IF (x1=x2) OR (y1=y2) THEN ret:=FALSE; END;
    DISPOSE(mes);
  END;
  RETURN ret;
END SelectBox;

PROCEDURE * PrintWindow*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=datalist.GetNode(num);
  IF node#NIL THEN
    WITH node: Window DO
      NEW(str);
      COPY(node.windname,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintWindow;



PROCEDURE Create * (): WindowList;
VAR
  list: WindowList;
BEGIN
  NEW(list); list.Init;
  RETURN list;
END Create;

PROCEDURE (wlist:WindowList) Refresh*;

VAR node : l.Node;

BEGIN
  node:=wlist.head;
  WHILE node#NIL DO
    node(Window).Refresh;
    node:=node.next;
  END;
END Refresh;

PROCEDURE (wlist:WindowList) GetIMes*(mes:I.IntuiMessagePtr);

VAR node,next : l.Node;

BEGIN
  mes.class:=LONGSET{};
  mes.code:=0;
  mes.iAddress:=NIL;
  node:=wlist.head;
  WHILE node#NIL DO
    next:=node.next;
    node(Window).GetIMes(mes);
    IF mes.class=LONGSET{} THEN
      node:=next;
    ELSE
      node:=NIL;  (* Exit and return IMessage to Main loop. *)
    END;
  END;
END GetIMes;



(* Due to some hirarchical conflicts these methods of GraphWindow have to be
defined here already! Sorry for this. *)

PROCEDURE (window:Window) SnapToFunction*(VAR xcoord,ycoord:LONGREAL);
END SnapToFunction;

PROCEDURE (window:Window) SnapToGrid*(VAR xcoord,ycoord:LONGREAL);
END SnapToGrid;

PROCEDURE (window:Window) ResultsToObjects*(list:l.List;type:LONGINT);
END ResultsToObjects;

END Window.

