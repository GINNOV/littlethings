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


MODULE Toolbox;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       s  : SYSTEM,
       gd : GadTools,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       im : Images,
       mg : MathGUI,
       lg : LayoutGUI,
       io,
       NoGuruRq;

TYPE Toolbox * = POINTER TO ToolboxDesc;
     ToolboxDesc * = RECORD
       window      - : wm.Window;
       subwind     - : wm.SubWindow;
       iwindow     - : I.WindowPtr;
       root        - : gmb.Root;
       pointer,
       cursor,
       glass,
       depth,
       text,
       delete,
       textline,
       line,
       rect,
       circle        : gmo.ImageGadget;
       zoom          : gmo.BooleanGadget;
       pointerimg,
       pointerselimg,
       cursorimg,
       cursorselimg,
       glassimg,
       glassselimg,
       depthimg,
       depthselimg,
       textimg,
       textselimg,
       deleteimg,
       deleteselimg,
       textlineimg,
       textlineselimg,
       lineimg,
       lineselimg,
       rectimg,
       rectselimg,
       circleimg,
       circleselimg  : im.Image;
     END;

PROCEDURE (toolbox:Toolbox) Init*;

VAR gadobj : gmb.Object;
    glist  : I.GadgetPtr;

BEGIN
  toolbox.pointerimg:=im.AllocPointerImage();
  toolbox.pointerselimg:=im.AllocPointerImage();
  im.InvertImage(toolbox.pointerselimg);
  toolbox.cursorimg:=im.AllocCursorImage();
  toolbox.cursorselimg:=im.AllocCursorImage();
  im.InvertImage(toolbox.cursorselimg);
  toolbox.glassimg:=im.AllocGlassImage();
  toolbox.glassselimg:=im.AllocGlassImage();
  im.InvertImage(toolbox.glassselimg);
  toolbox.depthimg:=im.AllocDepthImage();
  toolbox.depthselimg:=im.AllocDepthImage();
  im.InvertImage(toolbox.depthselimg);
  toolbox.textimg:=im.AllocTextImage();
  toolbox.textselimg:=im.AllocTextImage();
  im.InvertImage(toolbox.textselimg);
  toolbox.deleteimg:=im.AllocDeleteImage();
  toolbox.deleteselimg:=im.AllocDeleteImage();
  im.InvertImage(toolbox.deleteselimg);
  toolbox.textlineimg:=im.AllocTextLineImage();
  toolbox.textlineselimg:=im.AllocTextLineImage();
  im.InvertImage(toolbox.textlineselimg);
  toolbox.lineimg:=im.AllocLineImage();
  toolbox.lineselimg:=im.AllocLineImage();
  im.InvertImage(toolbox.lineselimg);
  toolbox.rectimg:=im.AllocRectangleImage();
  toolbox.rectselimg:=im.AllocRectangleImage();
  im.InvertImage(toolbox.rectselimg);
  toolbox.circleimg:=im.AllocCircleImage();
  toolbox.circleselimg:=im.AllocCircleImage();
  im.InvertImage(toolbox.circleselimg);

  toolbox.window:=wm.InitWindow(wm.centered,wm.centered,10,10,TRUE,s.ADR(""),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},gmb.stdIDCMP);
  toolbox.subwind:=toolbox.window.InitSub(mg.screen); (* lg.screen is probably not properly set yet! *)
  toolbox.root:=gmb.SetRootBox(gmb.vertBox,gmb.noBorder,FALSE,NIL,LONGSET{},toolbox.subwind);
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      toolbox.pointer:=gmo.SetImageGadget(32,19,2,toolbox.pointerimg,toolbox.pointerselimg,TRUE);
      toolbox.pointer.SetOutValues(0,0);
      toolbox.cursor:=gmo.SetImageGadget(32,19,2,toolbox.cursorimg,toolbox.cursorselimg,TRUE);
      toolbox.cursor.SetOutValues(0,0);
    gmb.EndBox;
    gadobj.SetOutValues(0,0);
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      toolbox.glass:=gmo.SetImageGadget(32,19,2,toolbox.glassimg,toolbox.glassselimg,TRUE);
      toolbox.glass.SetOutValues(0,0);
      toolbox.depth:=gmo.SetImageGadget(32,19,2,toolbox.depthimg,toolbox.depthselimg,FALSE);
      toolbox.depth.SetOutValues(0,0);
    gmb.EndBox;
    gadobj.SetOutValues(0,0);
    toolbox.zoom:=gmo.SetBooleanGadget(s.ADR("100 %"),FALSE);
    toolbox.zoom.SetOutValues(0,0);
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      toolbox.text:=gmo.SetImageGadget(32,19,2,toolbox.textimg,toolbox.textselimg,TRUE);
      toolbox.text.SetOutValues(0,0);
      toolbox.delete:=gmo.SetImageGadget(32,19,2,toolbox.deleteimg,toolbox.deleteselimg,FALSE);
      toolbox.delete.SetOutValues(0,0);
    gmb.EndBox;
    gadobj.SetOutValues(0,0);
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      toolbox.textline:=gmo.SetImageGadget(32,19,2,toolbox.textlineimg,toolbox.textlineselimg,FALSE);
      toolbox.textline.SetOutValues(0,0);
      toolbox.line:=gmo.SetImageGadget(32,19,2,toolbox.lineimg,toolbox.lineselimg,TRUE);
      toolbox.line.SetOutValues(0,0);
    gmb.EndBox;
    gadobj.SetOutValues(0,0);
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      toolbox.rect:=gmo.SetImageGadget(32,19,2,toolbox.rectimg,toolbox.rectselimg,TRUE);
      toolbox.rect.SetOutValues(0,0);
      toolbox.circle:=gmo.SetImageGadget(32,19,2,toolbox.circleimg,toolbox.circleselimg,TRUE);
      toolbox.circle.SetOutValues(0,0);
    gmb.EndBox;
    gadobj.SetOutValues(0,0);
  glist:=toolbox.root.EndRoot();
  toolbox.root.Init;
  toolbox.root.SetOutValues(0,0);
  toolbox.root.Resize;
END Init;

PROCEDURE (toolbox:Toolbox) Destruct*;

BEGIN

(* Shouldn't toolbox.window be destructed BEFORE toolbox.root? *)

  toolbox.root.Destruct;
  toolbox.window.Destruct;
  im.DestructImage(toolbox.pointerimg,32,19,2);
  im.DestructImage(toolbox.pointerselimg,32,19,2);
  im.DestructImage(toolbox.cursorimg,32,19,2);
  im.DestructImage(toolbox.cursorselimg,32,19,2);
  im.DestructImage(toolbox.glassimg,32,19,2);
  im.DestructImage(toolbox.glassselimg,32,19,2);
  im.DestructImage(toolbox.depthimg,32,19,2);
  im.DestructImage(toolbox.depthselimg,32,19,2);
  im.DestructImage(toolbox.textimg,32,19,2);
  im.DestructImage(toolbox.textselimg,32,19,2);
  im.DestructImage(toolbox.deleteimg,32,19,2);
  im.DestructImage(toolbox.deleteselimg,32,19,2);
  im.DestructImage(toolbox.textlineimg,32,19,2);
  im.DestructImage(toolbox.textlineselimg,32,19,2);
  im.DestructImage(toolbox.lineimg,32,19,2);
  im.DestructImage(toolbox.lineselimg,32,19,2);
  im.DestructImage(toolbox.rectimg,32,19,2);
  im.DestructImage(toolbox.rectselimg,32,19,2);
  im.DestructImage(toolbox.circleimg,32,19,2);
  im.DestructImage(toolbox.circleselimg,32,19,2);
END Destruct;

PROCEDURE (toolbox:Toolbox) Open*():BOOLEAN;

BEGIN
  toolbox.window.SetMenu(lg.menu);
  toolbox.subwind.SetScreen(lg.screen);
  toolbox.iwindow:=toolbox.subwind.Open(NIL);
  IF toolbox.iwindow#NIL THEN
    toolbox.root.Resize;
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END;
END Open;

PROCEDURE (toolbox:Toolbox) Close*;

BEGIN
  IF toolbox.iwindow#NIL THEN
    toolbox.subwind.Close;
    toolbox.root.Resize;
  END;
END Close;

PROCEDURE (toolbox:Toolbox) InputEvent*(mes:I.IntuiMessagePtr);
(* Does not check menus! *)

BEGIN

END InputEvent;

END Toolbox.

