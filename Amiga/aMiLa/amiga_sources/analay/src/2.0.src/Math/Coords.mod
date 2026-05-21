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


MODULE Coords;

(* The WorldToPic method still has to be changed! *)



IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       gd : GadTools,
       l  : LinkedLists,
       lrc: LongRealConversions,
       tt : TextTools,
       wm : WindowManager,
       ac : AnalayCatalog,
       m  : Multitasking,
       mem: MemoryManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       mg : MathGUI,
       ft : FunctionTrees,
       bt : BasicTypes,
       io,
       NoGuruRq;

(* The rectangle in which the coordinate system shall be displayed. *)

TYPE Rectangle * = POINTER TO RectangleDesc;
     RectangleDesc * = RECORD
       xoff*,yoff*,
       width*,height * : INTEGER;
     END;

PROCEDURE (rect:Rectangle) Init*(wind:wm.SubWindow);

VAR iwind : I.WindowPtr;

BEGIN
  IF wind#NIL THEN
    iwind:=wind.GetWindow();
  ELSE
    iwind:=NIL;
  END;
  IF iwind#NIL THEN
    rect.xoff:=iwind.borderLeft;
    rect.yoff:=iwind.borderTop;
    rect.width:=iwind.width-iwind.borderLeft-iwind.borderRight;
    rect.height:=iwind.height-iwind.borderTop-iwind.borderBottom;
  ELSE
(*    wind.GetDimensions(rect.xoff,rect.yoff,rect.width,rect.height);*)
    rect.xoff:=0;
    rect.yoff:=0;
    rect.width:=100;
    rect.height:=100;
  END;
END Init;

PROCEDURE (rect:Rectangle) Destruct*;

BEGIN
  DISPOSE(rect);
END Destruct;

PROCEDURE (rect:Rectangle) SetClipRegion*(sub:wm.SubWindow);

BEGIN
  sub.SetClipRegion(rect.xoff,rect.yoff,rect.xoff+rect.width-1,rect.yoff+rect.height-1);
(*  rect.clipreg:=g.NewRegion();
  rect.cliprect.bounds.minX:=rect.xoff;
  rect.cliprect.bounds.minY:=rect.yoff;
  rect.cliprect.bounds.maxX:=rect.xoff+rect.width-1;
  rect.cliprect.bounds.maxY:=rect.yoff+rect.height-1;
  la.InstallClipRegion(rast.layer,rect.cliprect);*)
END SetClipRegion;

PROCEDURE (rect:Rectangle) RemoveClipRegion*(sub:wm.SubWindow);

BEGIN
  sub.RemoveClipRegion;
END RemoveClipRegion;



(* Several coordinate systems, may be used in graph windows for example. *)

TYPE CoordSystem * = POINTER TO CoordSystemDesc;
     CoordSystemDesc * = RECORD(l.NodeDesc)
       window            * : m.ChangeAble;
     END;

     CartesianSystem * = POINTER TO CartesianSystemDesc;
     CartesianSystemDesc * = RECORD(CoordSystemDesc)
       xmin*,xmax*,                   (* Axis range *)
       ymin*,ymax*,
       oldxmin*,oldxmax  * ,          (* Old axis range for undo *)
       oldymin*,oldymax  * : LONGREAL;
       xmins*,xmaxs*,                 (* Axis ranges for string gadgets in *)
       ymins*,ymaxs*,                 (* requesters. *)
       oldxmins*,oldxmaxs*,
       oldymins*,oldymaxs* : ARRAY 256 OF CHAR;
     END;

PROCEDURE (coords:CartesianSystem) Init*;

BEGIN
  coords.xmin:=-10;
  coords.xmax:=10;
  coords.ymin:=-10;
  coords.ymax:=10;
  coords.xmins:="-10";
  coords.xmaxs:="10";
  coords.ymins:="-10";
  coords.ymaxs:="10";
  coords.oldxmin:=-10;
  coords.oldxmax:=10;
  coords.oldymin:=-10;
  coords.oldymax:=10;
  coords.oldxmins:="-10";
  coords.oldxmaxs:="10";
  coords.oldymins:="-10";
  coords.oldymaxs:="10";

  coords.Init^;
END Init;

PROCEDURE (coords:CartesianSystem) AllocNew*():l.Node;

VAR node : CartesianSystem;

BEGIN
  NEW(node);
  RETURN node;
END AllocNew;

PROCEDURE (coords:CartesianSystem) Copy*(dest:l.Node);

BEGIN
  IF dest#NIL THEN
    WITH dest: CartesianSystem DO
      dest.xmin:=coords.xmin;
      dest.xmax:=coords.xmax;
      dest.ymin:=coords.ymin;
      dest.ymax:=coords.ymax;
      dest.oldxmin:=coords.oldxmin;
      dest.oldxmax:=coords.oldxmax;
      dest.oldymin:=coords.oldymin;
      dest.oldymax:=coords.oldymax;
      COPY(coords.xmins,dest.xmins);
      COPY(coords.xmaxs,dest.xmaxs);
      COPY(coords.ymins,dest.ymins);
      COPY(coords.ymaxs,dest.ymaxs);
      COPY(coords.oldxmins,dest.oldxmins);
      COPY(coords.oldxmaxs,dest.oldxmaxs);
      COPY(coords.oldymins,dest.oldymins);
      COPY(coords.oldymaxs,dest.oldymaxs);
    END;
  END;
END Copy;

PROCEDURE (coords:CoordSystem) WorldToPic*(rect:Rectangle;wx,wy:LONGREAL;VAR px,py:INTEGER);
END WorldToPic;

PROCEDURE (coords:CoordSystem) PicToWorld*(rect:Rectangle;px,py:INTEGER;VAR wx,wy:LONGREAL);
END PicToWorld;

PROCEDURE (coords:CartesianSystem) WorldToPic*(rect:Rectangle;wx,wy:LONGREAL;VAR px,py:INTEGER);

VAR distx,disty : LONGREAL;
    factx,facty : LONGREAL;

BEGIN
  distx:=coords.xmax-coords.xmin;
  disty:=coords.ymax-coords.ymin;
  wx:=wx-coords.xmin;
  wy:=wy-coords.ymin;
  factx:=wx/distx;
  facty:=wy/disty;
  distx:=factx*(rect.width-1);
  disty:=facty*(rect.height-1);
  IF (distx<=30000) AND (distx>=-30000) THEN
    IF distx>=0 THEN
      px:=SHORT(SHORT(SHORT(distx+0.5)));
    ELSE
      px:=SHORT(SHORT(SHORT(distx-0.5)));
    END;
  ELSIF distx>30000 THEN
    px:=30000;
  ELSIF distx<-30000 THEN
    px:=-30000;
  END;
  IF (disty<=30000) AND (disty>=-30000) THEN
    IF disty>=0 THEN
      py:=SHORT(SHORT(SHORT(disty+0.5)));
    ELSE
      py:=SHORT(SHORT(SHORT(disty-0.5)));
    END;
  ELSIF disty>30000 THEN
    py:=30000;
  ELSIF disty<-30000 THEN
    py:=-30000;
  END;
  py:=(rect.height-1)-py; (* Was (rect.height-1)-py) *)
  INC(px,rect.xoff);
  INC(py,rect.yoff);
END WorldToPic;

PROCEDURE (coords:CartesianSystem) PicToWorld*(rect:Rectangle;px,py:INTEGER;VAR wx,wy:LONGREAL);

VAR distx,disty : LONGREAL;
    factx,facty : LONGREAL;

BEGIN
  distx:=coords.xmax-coords.xmin;
  disty:=coords.ymax-coords.ymin;
  DEC(px,rect.xoff);
  DEC(py,rect.yoff);
  py:=rect.height-1-py;
  IF rect.width>1 THEN
    factx:=LONG(LONG(px))/LONG(LONG(rect.width-1));
  ELSE
    factx:=0;
  END;
  IF rect.height>1 THEN
    facty:=LONG(LONG(py))/LONG(LONG(rect.height-1));
  ELSE
    facty:=0;
  END;
  wx:=factx*distx;
  wy:=facty*disty;
  wx:=wx+coords.xmin;
  wy:=wy+coords.ymin;
END PicToWorld;

PROCEDURE (coords:CartesianSystem) CurrentToUndo*;

BEGIN
  COPY(coords.xmins,coords.oldxmins);
  COPY(coords.xmaxs,coords.oldxmaxs);
  COPY(coords.ymins,coords.oldymins);
  COPY(coords.ymaxs,coords.oldymaxs);
  coords.oldxmin:=coords.xmin;
  coords.oldxmax:=coords.xmax;
  coords.oldymin:=coords.ymin;
  coords.oldymax:=coords.ymax;
END CurrentToUndo;

PROCEDURE (coords:CartesianSystem) CreateStrings*;

VAR bool : BOOLEAN;

BEGIN
  bool:=lrc.RealToString(coords.xmin,coords.xmins,7,7,FALSE);
  tt.Clear(coords.xmins);
  bool:=lrc.RealToString(coords.xmax,coords.xmaxs,7,7,FALSE);
  tt.Clear(coords.xmaxs);
  bool:=lrc.RealToString(coords.ymin,coords.ymins,7,7,FALSE);
  tt.Clear(coords.ymins);
  bool:=lrc.RealToString(coords.ymax,coords.ymaxs,7,7,FALSE);
  tt.Clear(coords.ymaxs);
END CreateStrings;

PROCEDURE (coords:CartesianSystem) Check*;

VAR real : LONGREAL;
    str  : ARRAY 256 OF CHAR;
    bool : BOOLEAN;

BEGIN
  IF coords.xmin>coords.xmax THEN
    real:=coords.xmin;
    coords.xmin:=coords.xmax;
    coords.xmax:=real;
    COPY(coords.xmins,str);
    COPY(coords.xmaxs,coords.xmins);
    COPY(str,coords.xmaxs);
  END;
  IF coords.ymin>coords.ymax THEN
    real:=coords.ymin;
    coords.ymin:=coords.ymax;
    coords.ymax:=real;
    COPY(coords.ymins,str);
    COPY(coords.ymaxs,coords.ymins);
    COPY(str,coords.ymaxs);
  END;
  real:=ABS(coords.xmax-coords.xmin);
  IF real<0.001 THEN
    coords.xmax:=coords.xmin+0.001;
    bool:=lrc.RealToString(coords.xmax,coords.xmaxs,7,7,FALSE);
    tt.Clear(coords.xmaxs);
  END;
  real:=ABS(coords.ymax-coords.ymin);
  IF real<0.001 THEN
    coords.ymax:=coords.ymin+0.001;
    bool:=lrc.RealToString(coords.ymax,coords.ymaxs,7,7,FALSE);
    tt.Clear(coords.ymaxs);
  END;
END Check;

VAR coordwind * : wm.Window;

PROCEDURE (coords:CartesianSystem) Change(coordtask:m.Task):BOOLEAN;

VAR subwind       : wm.SubWindow;
    wind          : I.WindowPtr;
    rast          : g.RastPortPtr;
    root          : gmb.Root;
    xmin,xmax,
    ymin,ymax     : gmo.StringGadget;
    undo          : gmo.BooleanGadget;
    gadobj        : gmb.Object;
    glist         : I.GadgetPtr;
    mes           : I.IntuiMessagePtr;
    msg           : m.Message;
    class         : LONGSET;
    savecoords    : CartesianSystem;
    bool,ret,
    didchange     : BOOLEAN;

  PROCEDURE SetData;

  BEGIN
    xmin.SetString(coords.xmins);
    xmax.SetString(coords.xmaxs);
    ymin.SetString(coords.ymins);
    ymax.SetString(coords.ymaxs);
  END SetData;

  PROCEDURE GetInput;

  VAR string  : ARRAY 256 OF CHAR;
      changed : BOOLEAN;

  BEGIN
    changed:=FALSE;
    xmin.GetString(string);
    IF ~tt.Compare(string,coords.xmins) THEN
      COPY(string,coords.xmins);
      coords.xmin:=ft.ExpressionToReal(coords.xmins);
      changed:=TRUE;
    END;
    xmax.GetString(string);
    IF ~tt.Compare(string,coords.xmaxs) THEN
      COPY(string,coords.xmaxs);
      coords.xmax:=ft.ExpressionToReal(coords.xmaxs);
      changed:=TRUE;
    END;
    ymin.GetString(string);
    IF ~tt.Compare(string,coords.ymins) THEN
      COPY(string,coords.ymins);
      coords.ymin:=ft.ExpressionToReal(coords.ymins);
      changed:=TRUE;
    END;
    ymax.GetString(string);
    IF ~tt.Compare(string,coords.ymaxs) THEN
      COPY(string,coords.ymaxs);
      coords.ymax:=ft.ExpressionToReal(coords.ymaxs);
      changed:=TRUE;
    END;

    IF changed THEN
      coords.Check; SetData;
      didchange:=TRUE;
      coords.window.SendNewMsg(m.msgSizeChanged,m.typeRecalc);
    END;
  END GetInput;

BEGIN
  NEW(mes);
  ret:=FALSE;
  IF coordwind=NIL THEN
    coordwind:=wm.InitWindow(wm.centered,wm.centered,10,10,TRUE,ac.GetString(ac.ChangeAxisLimits),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=coordwind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,s.ADR("Grenzkoordinaten"));
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        xmin:=gmo.SetStringGadget(s.ADR("x-min"),255,gmo.realType);
        xmin.SetMinVisible(5);
        xmax:=gmo.SetStringGadget(s.ADR("x-max"),255,gmo.realType);
        xmax.SetMinVisible(5);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        ymin:=gmo.SetStringGadget(s.ADR("y-min"),255,gmo.realType);
        ymin.SetMinVisible(5);
        ymax:=gmo.SetStringGadget(s.ADR("y-max"),255,gmo.realType);
        ymax.SetMinVisible(5);
      gmb.EndBox;
    gmb.EndBox;
    undo:=gmo.SetBooleanGadget(ac.GetString(ac.UndoChanges),FALSE);
  glist:=root.EndRoot();

  root.Init;

  SetData;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;
    xmin.Activate;

    savecoords:=NIL;
    NEW(savecoords); savecoords.Init; coords.Copy(savecoords);

    didchange:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF coordtask.msgsig IN class THEN
        REPEAT
          msg:=coordtask.ReceiveMsg();
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
                xmin.Activate;
              ELSE
                msg.Reply;
                EXIT;
              END;
            ELSIF msg.type=m.msgNodeChanged THEN
              SetData;
            ELSIF msg.type=m.msgActivate THEN
              subwind.ToFront;
            END;
            msg.Reply;
          END;
        UNTIL msg=NIL;
      END;
      REPEAT
        root.GetIMes(mes);
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            GetInput;
            ret:=TRUE;
            coords.window.SendNewMsg(m.msgSizeChanged,m.typeRecalc);
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            savecoords.Copy(coords);

            IF didchange THEN
              coords.window.SendNewMsg(m.msgSizeChanged,m.typeRecalc);
            END;
            ret:=FALSE;
            EXIT;
          ELSIF mes.iAddress=undo.gadget THEN
            xmin.SetString(coords.oldxmins);
            xmax.SetString(coords.oldxmaxs);
            ymin.SetString(coords.oldymins);
            ymax.SetString(coords.oldymaxs);
            GetInput;
          ELSIF NOT(mes.iAddress=root.help) THEN
            GetInput;
          END;
        END;
  (*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"changegrid",wind);
        END;*)
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;

    IF savecoords#NIL THEN savecoords.Destruct; END;
  END;
  root.Destruct;
  DISPOSE(mes);
  RETURN ret;
END Change;

PROCEDURE ChangeCoordsTask*(coordtask:bt.ANY):bt.ANY;

VAR data : CoordSystem;
    bool : BOOLEAN;

BEGIN
  WITH coordtask: m.Task DO
    coordtask.InitCommunication;
    data:=coordtask.data(CoordSystem);
    bool:=data(CartesianSystem).Change(coordtask);

    data.window.RemTask(coordtask);
    coordtask.ReplyAllMessages;
    coordtask.DestructCommunication;
    mem.NodeToGarbage(coordtask);
    data.window.FreeUser(coordtask);
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END ChangeCoordsTask;



END Coords.

