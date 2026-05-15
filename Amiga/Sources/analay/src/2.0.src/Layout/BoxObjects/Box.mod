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


MODULE Box;

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
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       fo : FontOrganizer,
       m  : Multitasking,
       lg : LayoutGUI,
       col: Colors,
       pi : PlotInfo,
       ra : Raster,
       ac : AnalayCatalog,
       NoGuruRq;

TYPE Box * = POINTER TO BoxDesc;
     BoxDesc * = RECORD(l.NodeDesc)
       task          * : m.Task;     (* Owner of the box *)
       xpos*,ypos    * ,
       width*,height * : LONGREAL;
       xposs*,yposs  * ,
       widths*,heights*: ARRAY 256 OF CHAR;
       stdfontinfo   * : fo.FontInfo;
       usestdfont    * : BOOLEAN;
(*       backcol       * : col.Color;*)
       locked        * ,
       quickdisp     * ,
       transparent   * : BOOLEAN;
     END;

CONST simpleBorder   * = 1;
      standardBorder * = 2;

PROCEDURE (box:Box) Init*;

(* Set the boxes task field to a valid pointer before calling this
   Init method! *)

BEGIN
  box.Init^;
  NEW(box.stdfontinfo); box.stdfontinfo.Init;
  box.locked:=FALSE;
  box.quickdisp:=FALSE;
END Init;

PROCEDURE (box:Box) Destruct*;

BEGIN
  IF box.stdfontinfo#NIL THEN box.stdfontinfo.Destruct; END;
  box.Destruct^;
END Destruct;

PROCEDURE (box:Box) UpdateCoordStrings*;

VAR bool : BOOLEAN;

BEGIN
  bool:=lrc.RealToString(box.xpos,box.xposs,7,7,FALSE);
  bool:=lrc.RealToString(box.ypos,box.yposs,7,7,FALSE);
  bool:=lrc.RealToString(box.width,box.widths,7,7,FALSE);
  bool:=lrc.RealToString(box.height,box.heights,7,7,FALSE);
  tt.Clear(box.xposs);
  tt.Clear(box.yposs);
  tt.Clear(box.widths);
  tt.Clear(box.heights);
END UpdateCoordStrings;

PROCEDURE (box:Box) SetCMDims*(xpos,ypos,width,height:LONGREAL);

BEGIN
  box.xpos:=xpos;
  box.ypos:=ypos;
  box.width:=width;
  box.height:=height;
  box.UpdateCoordStrings;
END SetCMDims;

PROCEDURE (box:Box) SetPicDims*(plotinfo:pi.PlotInfo;picx,picy,picwi,piche:LONGINT);

BEGIN
  plotinfo.PicToCMRect(picx,picy,box.xpos,box.ypos,NIL);
  plotinfo.PicToCM(picwi,piche,box.width,box.height);
  box.UpdateCoordStrings;
END SetPicDims;

PROCEDURE (box:Box) CorrectCoords*;

BEGIN
  IF box.width=0 THEN box.width:=0.01; END;
  IF box.height=0 THEN box.height:=0.01; END;
  IF box.width<0 THEN
    box.xpos:=box.xpos+box.width;
    box.width:=-box.width;
  END;
  IF box.height<0 THEN
    box.ypos:=box.ypos+box.height;
    box.height:=-box.height;
  END;
END CorrectCoords;

PROCEDURE (box:Box) InitCoords*(maxwidth,maxheight:LONGREAL);
(* Finds a suitable size for this box. *)

BEGIN
  box.width:=2; box.height:=2;
  box.UpdateCoordStrings;
END InitCoords;

PROCEDURE (box:Box) Zoom*(plotinfo:pi.PlotInfo);
(* This method modifies zoom and x/y-offsets of the plotinfo structure
   so that box fits on the screen (exactly: the width of the box
   fits on the editing area). *)

BEGIN
  plotinfo.BoxZoom(box.xpos,box.ypos,box.width,box.height);
END Zoom;

PROCEDURE (box:Box) SetUseStdFont*(usestdfont:BOOLEAN);

BEGIN
  box.usestdfont:=usestdfont;
END SetUseStdFont;

PROCEDURE (box:Box) GetUseStdFont*():BOOLEAN;

BEGIN
  RETURN box.usestdfont;
END GetUseStdFont;

PROCEDURE (box:Box) SetFontInfo*(fontinfo:fo.FontInfo);
(* COPIES the contents of the given fontinfo record to the boxes
   local stdfontinfo element. Does NOT store the pointer to given fontinfo!
   -> given fontinfo has to be allocated before calling this method!

   Redefinition of this method may store the data anywhere else than
   box.stdfontinfo. *)

BEGIN
  IF (box.stdfontinfo#NIL) & (fontinfo#NIL) THEN
    fontinfo.Copy(box.stdfontinfo);
    box.usestdfont:=FALSE;
  END;
END SetFontInfo;

PROCEDURE (box:Box) GetFontInfo*(fontinfo:fo.FontInfo);
(* COPIES the contents of stdfontinfo to the given fontinfo record.
   Does NOT changethe given pointer!
   -> given fontinfo has to be allocated before calling this method!

   Redefinition of this method may store the data anywhere else than
   box.stdfontinfo. *)

BEGIN
  IF (box.stdfontinfo#NIL) & (fontinfo#NIL) THEN
    box.stdfontinfo.Copy(fontinfo);
  END;
END GetFontInfo;

PROCEDURE (box:Box) FontAble*():BOOLEAN;
(* Returns TRUE if it makes sense to set a font via SetFontInfo. *)
(* You HAVE to redefine this method in childs of Box! *)

BEGIN
  RETURN FALSE;
END FontAble;



(* Plotting and moving around *)

PROCEDURE (box:Box) PlotBorder*(plotinfo:pi.PlotInfo;type:INTEGER;active:BOOLEAN);

VAR px,py       : LONGINT;
    picx,picy,
    picwi,piche,
    xh,yh,x1,y1,
    x2,y2       : INTEGER;
    rast        : g.RastPortPtr;

BEGIN
  rast:=plotinfo.rast;
  plotinfo.CMToPicRect(box.xpos,box.ypos,px,py,NIL);
  picx:=SHORT(px); picy:=SHORT(py);
  plotinfo.CMToPic(box.width,box.height,px,py);
  picwi:=SHORT(px); piche:=SHORT(py);
  IF picwi<0 THEN
    picx:=picx+picwi+1;
    picwi:=-picwi;
  END;
  IF piche<0 THEN
    picy:=picy+piche+1;
    piche:=-piche;
  END;
  g.SetDrMd(rast,SHORTSET{g.complement});
  IF ~active THEN
    plotinfo.rast.linePtrn:=s.VAL(INTEGER,SET{0,1,4,5,8,9,12,13});
  END;

  IF type=simpleBorder THEN
    g.Move(rast,picx,picy);
    g.Draw(rast,picx+picwi,picy);
    g.Draw(rast,picx+picwi,picy+piche);
    g.Draw(rast,picx,picy+piche);
    g.Draw(rast,picx,picy+1);
  ELSIF type=standardBorder THEN
    x1:=picx; y1:=picy;
    x2:=picx+picwi; y2:=picy+piche;
    xh:=((x2-x1) DIV 2)+x1-5;
    yh:=((y2-y1) DIV 2)+y1-2;

    g.Move(rast,x1,y1);
    g.Draw(rast,x2,y1);
    g.Draw(rast,x2,y2);
    g.Draw(rast,x1,y2);
    g.Draw(rast,x1,y1+1);
    g.Move(rast,x2-1,y1+5);
    g.Draw(rast,x2-10,y1+5);
    g.Draw(rast,x2-10,y1+1);
    g.Move(rast,x2-1,y2-5);
    g.Draw(rast,x2-10,y2-5);
    g.Draw(rast,x2-10,y2-1);
    g.Move(rast,x1+10,y2-1);
    g.Draw(rast,x1+10,y2-5);
    g.Draw(rast,x1+1,y2-5);
    g.Move(rast,x1+1,y1+5);
    g.Draw(rast,x1+10,y1+5);
    g.Draw(rast,x1+10,y1+1);
    g.Move(rast,xh,y1+1);
    g.Draw(rast,xh,y1+5);
    g.Draw(rast,xh+10,y1+5);
    g.Draw(rast,xh+10,y1+1);
    g.Move(rast,x2-1,yh);
    g.Draw(rast,x2-10,yh);
    g.Draw(rast,x2-10,yh+5);
    g.Draw(rast,x2-1,yh+5);
    g.Move(rast,xh,y2-1);
    g.Draw(rast,xh,y2-5);
    g.Draw(rast,xh+10,y2-5);
    g.Draw(rast,xh+10,y2-1);
    g.Move(rast,x1+1,yh);
    g.Draw(rast,x1+10,yh);
    g.Draw(rast,x1+10,yh+5);
    g.Draw(rast,x1+1,yh+5);
  END;
  IF ~active THEN
    plotinfo.rast.linePtrn:=s.VAL(INTEGER,SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15});
  END;
  g.SetDrMd(rast,g.jam1);
END PlotBorder;

PROCEDURE (box:Box) QuickPlot*(plotinfo:pi.PlotInfo);

VAR rast        : g.RastPortPtr;
    picx,picy,
    picwi,piche : INTEGER;
    x,y         : LONGINT;
    i           : INTEGER;

BEGIN
  rast:=plotinfo.rast;
  plotinfo.CMToPicRect(box.xpos,box.ypos,x,y,NIL);
  picx:=SHORT(x); picy:=SHORT(y);
  plotinfo.CMToPic(box.width,box.height,x,y);
  picwi:=SHORT(x); piche:=SHORT(y);

  IF col.black#NIL THEN
    i:=col.black.SetColor(plotinfo,col.setFrontPen);
  ELSE
    g.SetAPen(rast,1);
  END;
  g.Move(rast,picx,picy);
  g.Draw(rast,picx+picwi-1,picy);
  g.Draw(rast,picx+picwi-1,picy+piche-1);
  g.Draw(rast,picx,picy+piche-1);
  g.Draw(rast,picx,picy);
  g.Draw(rast,picx+picwi-1,picy+piche-1);
  g.Move(rast,picx+picwi-1,picy);
  g.Draw(rast,picx,picy+piche-1);
END QuickPlot;

PROCEDURE (box:Box) Plot*(plotinfo:pi.PlotInfo);

BEGIN

END Plot;

PROCEDURE (box:Box) Place*(plotinfo:pi.PlotInfo;raster:ra.Raster;mes:I.IntuiMessagePtr):BOOLEAN;
(* Let's the user draw a box from one edge to the opposite *)
(* Returns an IntuiMessage if the user aborts the action with another
   action (e.g. gadget klick). *)

VAR rast        : g.RastPortPtr;
    picx,picy,
    picwi,piche : LONGINT;
    intx,inty,
    oldx,oldy   : INTEGER;
    x1,y1,x2,y2 : LONGREAL;
    class       : LONGSET;
    pressed     : BOOLEAN;

BEGIN
  rast:=plotinfo.rast;
  g.SetDrMd(rast,SHORTSET{g.complement});
  pressed:=FALSE;
  LOOP
    class:=e.Wait(LONGSET{0..31});
    REPEAT
      plotinfo.root.GetIMes(mes);
      IF (I.mouseButtons IN mes.class) AND (mes.code=I.selectDown) THEN
        pressed:=TRUE; EXIT;
      ELSIF (I.newSize IN mes.class) OR (I.menuPick IN mes.class) OR (I.gadgetDown IN mes.class) THEN
        pressed:=FALSE; EXIT;
      END;
    UNTIL mes.class=LONGSET{};
  END;
  plotinfo.PicToCMRect(mes.mouseX,mes.mouseY,x1,y1,NIL);
  raster.Snap(x1,y1);
  box.xpos:=x1;
  box.ypos:=y1;
  box.width:=0;
  box.height:=0;
  oldx:=mes.mouseX;
  oldy:=mes.mouseY;

  IF pressed THEN
    box.PlotBorder(plotinfo,simpleBorder,TRUE);
    LOOP
      class:=e.Wait(LONGSET{0..31});
      REPEAT
        plotinfo.root.GetIMes(mes);
        plotinfo.subwind.GetMousePos(intx,inty);
        IF (intx#oldx) OR (inty#oldy) THEN
          box.PlotBorder(plotinfo,simpleBorder,TRUE);
          oldx:=intx; oldy:=inty;
          plotinfo.PicToCMRect(intx,inty,x2,y2,NIL);
          raster.Snap(x2,y2);
          box.width:=x2-x1;
          box.height:=y2-y1;
          box.PlotBorder(plotinfo,simpleBorder,TRUE);
        END;
        IF (I.mouseButtons IN mes.class) AND (mes.code=I.selectUp) THEN
          box.PlotBorder(plotinfo,simpleBorder,TRUE);
          plotinfo.PicToCMRect(mes.mouseX,mes.mouseY,x2,y2,NIL);
          raster.Snap(x2,y2);
          box.width:=x2-x1;
          box.height:=y2-y1;
          box.CorrectCoords;
          box.PlotBorder(plotinfo,simpleBorder,TRUE);
          pressed:=TRUE; EXIT;
        ELSIF (I.newSize IN mes.class) OR (I.menuPick IN mes.class) OR (I.gadgetDown IN mes.class) OR (I.gadgetUp IN mes.class) THEN
          pressed:=FALSE; EXIT;
        END;
      UNTIL mes.class=LONGSET{};
    END;
    box.PlotBorder(plotinfo,simpleBorder,TRUE);
  END;
  g.SetDrMd(rast,g.jam1);

  IF pressed THEN box.UpdateCoordStrings; RETURN TRUE;
             ELSE                         RETURN FALSE; END;
END Place;

PROCEDURE (box:Box) Move*(plotinfo:pi.PlotInfo;raster:ra.Raster;mes:I.IntuiMessagePtr;offcenter:BOOLEAN):BOOLEAN;
(* mes is the message where the mouseclick occured. If NIL the box
   is taken in the center by the mouse button. *)
(* abortoutside : Set to TRUE if you want box.Move() to return FALSE if
                  the mousepointer leaves the window. Used for drag and drop.
   task         : Pointer to calling task (e.g. document). Only used if
                  abortoutside=TRUE to check for msgNewNodeDropped. *)

VAR picx,picy,
    picwi,piche,
    offx,offy,
    oldx,oldy   : LONGINT; (* Old pic dims *)
    class       : LONGSET;
    x,y         : INTEGER;
    xold,yold,
    widthold,
    heightold   : LONGREAL;
    msg         : m.Message;

BEGIN
(*  IF abortoutside THEN
    REPEAT plotinfo.root.GetIMes(mes); UNTIL mes.class=LONGSET{};
  END;*)

  xold:=box.xpos; yold:=box.ypos;
  widthold:=box.width; heightold:=box.height;

  plotinfo.CMToPicRect(box.xpos,box.ypos,picx,picy,NIL);
  plotinfo.CMToPic(box.width,box.height,picwi,piche);
  IF (mes#NIL) & ~offcenter THEN
    offx:=mes.mouseX-picx;
    offy:=mes.mouseY-picy;
  ELSE
    offx:=picwi DIV 2;
    offy:=piche DIV 2;
  END;
  oldx:=picx; oldy:=picy;

  box.PlotBorder(plotinfo,simpleBorder,TRUE);
  LOOP
    class:=e.Wait(LONGSET{0..31});
    REPEAT
      plotinfo.root.GetIMes(mes);
      plotinfo.subwind.GetMousePos(x,y);
      IF (I.mouseButtons IN mes.class) & (mes.code=I.selectUp) THEN
        x:=mes.mouseX; y:=mes.mouseY;
      END;
      IF (x#picx) OR (y#picy) THEN
        picx:=x-offx; picy:=y-offy;
        box.PlotBorder(plotinfo,simpleBorder,TRUE);
        plotinfo.PicToCMRect(picx,picy,box.xpos,box.ypos,NIL);
        raster.Snap(box.xpos,box.ypos);
        box.PlotBorder(plotinfo,simpleBorder,TRUE);
      END;
      IF (I.mouseButtons IN mes.class) & (mes.code=I.selectUp) THEN
        EXIT;
      ELSIF I.menuPick IN mes.class THEN
        EXIT;
      END;
    UNTIL mes.class=LONGSET{};

  END;
  box.PlotBorder(plotinfo,simpleBorder,TRUE);
  IF (I.mouseButtons IN mes.class) & ((oldx#picx) OR (oldy#picy)) THEN
    box.CorrectCoords;
    box.UpdateCoordStrings;
    RETURN TRUE;
  ELSE
    box.xpos:=xold; box.ypos:=yold;
    box.width:=widthold; box.height:=heightold;
    RETURN FALSE;
  END;
END Move;

PROCEDURE (box:Box) MoveSize*(plotinfo:pi.PlotInfo;raster:ra.Raster;mes:I.IntuiMessagePtr;type:INTEGER):BOOLEAN;

(* Types:   0     1     2

            3    Box    4

            5     6     7   *)

VAR xold,yold,
    widthold,heightold,
    realx,realy        : LONGREAL;
    picx,picy,
    picwi,piche,
    oldx,oldy,
    oldwi,oldhe,                   (* Old pic dims *)
    updist,downdist,               (* Offset of mouse position in the beginning *)
    leftdist,rightdist : LONGINT;  (* always >0 *)
    class              : LONGSET;
    x,y                : INTEGER;

BEGIN
  xold:=box.xpos; yold:=box.ypos;
  widthold:=box.width; heightold:=box.height;

  plotinfo.CMToPicRect(box.xpos,box.ypos,picx,picy,NIL);
  plotinfo.CMToPic(box.width,box.height,picwi,piche);
  oldx:=picx; oldy:=picy;
  oldwi:=picwi; oldhe:=piche;

  IF ~raster.snap THEN
    leftdist:=mes.mouseX-picx;
    updist:=mes.mouseY-picy;
    rightdist:=picx+picwi-1-mes.mouseX;
    downdist:=picy+piche-1-mes.mouseY;
  ELSE
    leftdist:=0; updist:=0; rightdist:=0; downdist:=0;
  END;

  box.PlotBorder(plotinfo,standardBorder,TRUE);
  LOOP
    class:=e.Wait(LONGSET{0..31});
    REPEAT
      plotinfo.root.GetIMes(mes);
      oldx:=x; oldy:=y;
      plotinfo.subwind.GetMousePos(x,y);
      IF (I.mouseButtons IN mes.class) & (mes.code=I.selectUp) THEN
        x:=mes.mouseX; y:=mes.mouseY;
      END;
      IF raster.snap THEN
        plotinfo.PicToCMRect(x,y,realx,realy,NIL);
        raster.Snap(realx,realy);
        plotinfo.CMToPicRect(realx,realy,picx,picy,NIL); x:=SHORT(picx); y:=SHORT(picy);
      END;

      IF (x#oldx) OR (y#oldy) THEN
        plotinfo.CMToPicRect(box.xpos,box.ypos,picx,picy,NIL);
        plotinfo.CMToPic(box.width,box.height,picwi,piche);
        IF type=0 THEN    (* Upper left *)
          DEC(picwi,x-leftdist-picx);
          picx:=x-leftdist;
          DEC(piche,y-updist-picy);
          picy:=y-updist;
        ELSIF type=1 THEN (* Upper middle *)
          DEC(piche,y-updist-picy);
          picy:=y-updist;
        ELSIF type=2 THEN (* Upper right *)
          picwi:=x+rightdist-picx;
          DEC(piche,y-updist-picy);
          picy:=y-updist;
        ELSIF type=3 THEN (* Middle left *)
          DEC(picwi,x-leftdist-picx);
          picx:=x-leftdist;
        ELSIF type=4 THEN (* Middle right *)
          picwi:=x+rightdist-picx;
        ELSIF type=5 THEN (* Lower left *)
          DEC(picwi,x-leftdist-picx);
          picx:=x-leftdist;
          piche:=y+downdist-picy;
        ELSIF type=6 THEN (* Lower middle *)
          piche:=y+downdist-picy;
        ELSIF type=7 THEN (* Lower right *)
          picwi:=x+rightdist-picx;
          piche:=y+downdist-picy;
        END;
        box.PlotBorder(plotinfo,standardBorder,TRUE);
        plotinfo.PicToCMRect(picx,picy,box.xpos,box.ypos,NIL);
        plotinfo.PicToCM(picwi,piche,box.width,box.height);
(*        box.CorrectCoords;*)
        box.PlotBorder(plotinfo,standardBorder,TRUE);
      END;
      IF (I.mouseButtons IN mes.class) & (mes.code=I.selectUp) THEN
        EXIT;
      ELSIF I.menuPick IN mes.class THEN
        EXIT;
      END;
    UNTIL mes.class=LONGSET{};
  END;
  box.PlotBorder(plotinfo,standardBorder,TRUE);
  IF (I.mouseButtons IN mes.class) & ((oldx#picx) OR (oldy#picy) OR (oldwi#picwi) OR (oldhe#piche)) THEN
    box.CorrectCoords;
    box.UpdateCoordStrings;
    RETURN TRUE;
  ELSE
    box.xpos:=xold; box.ypos:=yold;
    box.width:=widthold; box.height:=heightold;
    RETURN FALSE;
  END;
END MoveSize;

PROCEDURE (box:Box) CheckClicked*(plotinfo:pi.PlotInfo;mouseX,mouseY:LONGINT):BOOLEAN;

VAR picx,picy,
    picwi,piche : LONGINT;

BEGIN
  plotinfo.CMToPicRect(box.xpos,box.ypos,picx,picy,NIL);
  plotinfo.CMToPic(box.width,box.height,picwi,piche);
  IF (mouseX>=picx) & (mouseX<picx+picwi) & (mouseY>=picy) & (mouseY<picy+piche) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END;
END CheckClicked;

PROCEDURE (box:Box) Clicked*(plotinfo:pi.PlotInfo;raster:ra.Raster;mes:I.IntuiMessagePtr):BOOLEAN;

VAR picx,picy,
    picwi,piche,
    xh,yh,mx,my  : LONGINT;
    bool,movebox : BOOLEAN;

BEGIN
  IF ~box.locked THEN
    mx:=mes.mouseX; my:=mes.mouseY;

    movebox:=TRUE;
    LOOP
      plotinfo.subwind.WaitPort;
      plotinfo.root.GetIMes(mes);
      IF I.mouseMove IN mes.class THEN
        IF (ABS(mes.mouseX-mx)>2) OR (ABS(mes.mouseY-my)>2) THEN
          movebox:=TRUE;
          EXIT;
        END;
      ELSIF I.mouseButtons IN mes.class THEN
        movebox:=FALSE;
        EXIT;
      END;
    END;

    IF movebox THEN
      plotinfo.CMToPicRect(box.xpos,box.ypos,picx,picy,NIL);
      plotinfo.CMToPic(box.width,box.height,picwi,piche);
      xh:=(picwi DIV 2)+picx-5;
      yh:=(piche DIV 2)+picy-2;
      IF (my>=picy) & (my<picy+5) THEN (* Top border *)
        IF (mx>=picx) & (mx<picx+10) THEN                (* Upper left *)
          bool:=box.MoveSize(plotinfo,raster,mes,0);
        ELSIF (mx>=xh) & (mx<xh+10) THEN                 (* Upper middle *)
          bool:=box.MoveSize(plotinfo,raster,mes,1);
        ELSIF (mx>=picx+picwi-10) & (mx<picx+picwi) THEN (* Upper right *)
          bool:=box.MoveSize(plotinfo,raster,mes,2);
        ELSE                                             (* None *)
          bool:=box.Move(plotinfo,raster,mes,FALSE);
        END;
      ELSIF (my>=yh) & (my<yh+5) THEN
        IF (mx>=picx) & (mx<picx+10) THEN                (* Middle left *)
          bool:=box.MoveSize(plotinfo,raster,mes,3);
        ELSIF (mx>=picx+picwi-10) & (mx<picx+picwi) THEN (* Middle right *)
          bool:=box.MoveSize(plotinfo,raster,mes,4);
        ELSE                                             (* None *)
          bool:=box.Move(plotinfo,raster,mes,FALSE);
        END;
      ELSIF (my>=picy+piche-5) & (my<picy+piche) THEN (* Bottom border *)
        IF (mx>=picx) & (mx<picx+10) THEN                (* Lower left *)
          bool:=box.MoveSize(plotinfo,raster,mes,5);
        ELSIF (mx>=xh) & (mx<xh+10) THEN                 (* Lowermiddle *)
          bool:=box.MoveSize(plotinfo,raster,mes,6);
        ELSIF (mx>=picx+picwi-10) & (mx<picx+picwi) THEN (* Lower right *)
          bool:=box.MoveSize(plotinfo,raster,mes,7);
        ELSE                                             (* None *)
          bool:=box.Move(plotinfo,raster,mes,FALSE);
        END;
      ELSE
        bool:=box.Move(plotinfo,raster,mes,FALSE);
      END;
      RETURN bool;
    ELSE
      RETURN FALSE;
    END;
  ELSE
    RETURN FALSE;
  END;
END Clicked;

VAR changecoordswind * : wm.Window;

PROCEDURE (box:Box) ChangeCoords*():BOOLEAN;

VAR subwind    : wm.SubWindow;
    wind       : I.WindowPtr;
    rast       : g.RastPortPtr;
    root       : gmb.Root;
    text       : gmo.Text;
    xposgad,
    yposgad,
    widthgad,
    heightgad  : gmo.StringGadget;
    lockbox,
    quickdisp  : gmo.CheckboxGadget;
    gadbox     : gmb.Box;
    gadobj     : gmb.Object;
    glist      : I.GadgetPtr;
    mes        : I.IntuiMessagePtr;
    msg        : m.Message;
    class      : LONGSET;
    bool,ret,
    didchange  : BOOLEAN;

  PROCEDURE GetInput;

  BEGIN
    xposgad.GetString(box.xposs); box.xpos:=xposgad.real;
    yposgad.GetString(box.yposs); box.ypos:=yposgad.real;
    widthgad.GetString(box.widths); box.width:=widthgad.real;
    heightgad.GetString(box.heights); box.height:=heightgad.real;
    box.locked:=lockbox.Checked();
    box.quickdisp:=quickdisp.Checked();
  END GetInput;

BEGIN
  NEW(mes);
  ret:=FALSE;
  IF changecoordswind=NIL THEN
    changecoordswind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.Grid),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=changecoordswind.InitSub(lg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadbox:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.BoxCoordinates));
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,ac.GetString(ac.Position));
        xposgad:=gmo.SetStringGadget(ac.GetString(ac.Left),255,gmo.realType);
        xposgad.SetMinVisible(5);
        text:=gmo.SetText(ac.GetString(ac.cm),-1);
        yposgad:=gmo.SetStringGadget(ac.GetString(ac.Top),255,gmo.realType);
        yposgad.SetMinVisible(5);
        text:=gmo.SetText(ac.GetString(ac.cm),-1);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,ac.GetString(ac.Dimensions));
        widthgad:=gmo.SetStringGadget(ac.GetString(ac.Width),255,gmo.realType);
        widthgad.SetMinVisible(5);
        text:=gmo.SetText(ac.GetString(ac.cm),-1);
        heightgad:=gmo.SetStringGadget(ac.GetString(ac.Height),255,gmo.realType);
        heightgad.SetMinVisible(5);
        text:=gmo.SetText(ac.GetString(ac.cm),-1);
      gmb.EndBox;
      root.NewSameTextWidth;
        root.AddSameTextWidth(xposgad);
        root.AddSameTextWidth(widthgad);
      root.NewSameTextWidth;
        root.AddSameTextWidth(yposgad);
        root.AddSameTextWidth(heightgad);
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.BoxParameters));
      lockbox:=gmo.SetCheckboxGadget(ac.GetString(ac.LockBox),box.locked);
      quickdisp:=gmo.SetCheckboxGadget(ac.GetString(ac.DisplayBoxFast),box.quickdisp);
      root.NewSameTextWidth;
        root.AddSameTextWidth(lockbox);
        root.AddSameTextWidth(quickdisp);
    gmb.EndBox;
    gadobj.SetSizeXY(0,-1);
  glist:=root.EndRoot();
  gadbox.SetSizeY(-1);

  root.Init;
  gadbox.SetSizeY(-1);

  xposgad.SetString(box.xposs);
  yposgad.SetString(box.yposs);
  widthgad.SetString(box.widths);
  heightgad.SetString(box.heights);

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;
    xposgad.Activate;

    didchange:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
(*      IF gridtask.msgsig IN class THEN
        REPEAT
          msg:=gridtask.ReceiveMsg();
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
                xspace1.Activate;
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
      END;*)
      REPEAT
        root.GetIMes(mes);
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            GetInput;
            box.CorrectCoords;
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            ret:=FALSE;
            EXIT;
          END;
        END;
  (*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"changegrid",wind);
        END;*)
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  RETURN ret;
END ChangeCoords;

PROCEDURE (box:Box) ChangeContents*(changetask:m.Task):BOOLEAN;

(* If this method is not started as a separate task, you have to provide
   a pointer to the calling task in the changetask-variable. *)

END ChangeContents;

END Box.










