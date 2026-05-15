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


MODULE Rectangle;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       u  : Utility,
       gd : GadTools,
       ag : AmigaGuideTools,
       l  : LinkedLists,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       gme: GuiManagerExtendedObjects,
       gb : GeneralBasics,
       m  : Multitasking,
       col: Colors,
       pc : PageCoords,
       pi : PlotInfo,
       lb : LayoutBasics,
       lg : LayoutGUI,
       bo : Box,
       ac : AnalayCatalog,
       NoGuruRq;

TYPE Rectangle * = POINTER TO RectangleDesc;
     RectangleDesc * = RECORD(bo.BoxDesc)
       outlinecol      * ,
       fillcol         * : col.Color;
       borderthickness * : LONGREAL;  (* in pt *)
       fillout         * : BOOLEAN;   (* fill out, otherwise transparent *)
     END;

PROCEDURE (rect:Rectangle) Init*;

BEGIN
  rect.Init^;
  rect.outlinecol:=col.stdcolor;
  rect.fillcol:=col.stdcolor;
  IF rect.outlinecol#NIL THEN rect.outlinecol.NewUser(rect.task); END;
  IF rect.fillcol#NIL THEN rect.fillcol.NewUser(rect.task); END;
  rect.borderthickness:=1;
  rect.fillout:=FALSE;
END Init;

PROCEDURE (rect:Rectangle) Destruct*;

BEGIN
  IF rect.outlinecol#NIL THEN rect.outlinecol.FreeUser(rect.task); END;
  IF rect.fillcol#NIL THEN rect.fillcol.FreeUser(rect.task); END;
  rect.Destruct^;
END Destruct;

PROCEDURE (rect:Rectangle) SetOutlineColor*(color:col.Color);

BEGIN
  IF rect.outlinecol#NIL THEN rect.outlinecol.FreeUser(rect.task); END;
  rect.outlinecol:=color;
  IF rect.outlinecol#NIL THEN rect.outlinecol.NewUser(rect.task); END;
END SetOutlineColor;

PROCEDURE (rect:Rectangle) SetFillColor*(color:col.Color);

BEGIN
  IF rect.fillcol#NIL THEN rect.fillcol.FreeUser(rect.task); END;
  rect.outlinecol:=color;
  IF rect.fillcol#NIL THEN rect.fillcol.NewUser(rect.task); END;
END SetFillColor;

PROCEDURE (rect:Rectangle) BCopy*(dest:l.Node);

BEGIN
  WITH dest: Rectangle DO
    dest.SetOutlineColor(rect.outlinecol);
    dest.SetFillColor(rect.fillcol);
    dest.borderthickness:=rect.borderthickness;
    dest.fillout:=rect.fillout;
  END;
END BCopy;

PROCEDURE (rect:Rectangle) Plot*(plotinfo:pi.PlotInfo);
(* May crash, see below *)

VAR rast        : g.RastPortPtr;
    picx,picy,
    picwi,piche,
    inx,iny     : INTEGER;
    x,y         : LONGINT;
    i           : INTEGER;

BEGIN
  IF rect.quickdisp THEN
    rect.QuickPlot(plotinfo);
  ELSE
    rast:=plotinfo.rast;
    plotinfo.CMToPicRect(rect.xpos,rect.ypos,x,y,NIL);
    picx:=SHORT(x); picy:=SHORT(y);
    plotinfo.CMToPic(rect.width,rect.height,x,y);
    picwi:=SHORT(x); piche:=SHORT(y);
    plotinfo.CMToPic(pc.PtToCM(rect.borderthickness),pc.PtToCM(rect.borderthickness),x,y);
    inx:=SHORT(x); iny:=SHORT(y);
  
    i:=rect.outlinecol.SetColor(plotinfo,col.setFrontPen);
    IF rect.fillout THEN
      g.RectFill(rast,picx,picy,picx+picwi,picy+piche);
      (* Could crash when trying to plot a negative Rectangle *)
  
      IF (picwi>2*inx) & (piche>2*iny) THEN
        i:=rect.fillcol.SetColor(plotinfo,col.setFrontPen);
        g.RectFill(rast,picx+inx,picy+iny,picx+picwi-2*inx,picy+piche-2*iny);
      END;
    ELSE
      g.RectFill(rast,picx,picy,picx+inx,picy+piche); (* Left border *)
      g.RectFill(rast,picx+picwi-inx,picy,picx+picwi,picy+piche); (* Right border *)
      g.RectFill(rast,picx,picy,picx+picwi,picy+iny); (* Top border *)
      g.RectFill(rast,picx,picy+piche-iny,picx+picwi,picy+piche); (* Bottom border *)
    END;
  END;
END Plot;

VAR changerectwind * : wm.Window;

PROCEDURE (rect:Rectangle) ChangeContents*(changetask:m.Task):BOOLEAN;

VAR subwind     : wm.SubWindow;
    wind        : I.WindowPtr;
    rast        : g.RastPortPtr;
    root        : gmb.Root;
    outlinecolor,
    fillcolor   : gme.FieldSelect;
    fillout     : gmo.CheckboxGadget;
    gadobj      : gmb.Object;
    glist       : I.GadgetPtr;
    mes         : I.IntuiMessagePtr;
    msg         : m.Message;
    class       : LONGSET;
    plotinfo    : pi.PlotInfo;
    node        : l.Node;
    backup      : Rectangle;
    bool,ret    : BOOLEAN;

BEGIN
  plotinfo:=col.AllocMinPlotInfo();
  NEW(mes);
  ret:=FALSE;
  IF changerectwind=NIL THEN
    changerectwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.ChangeGraphic),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=changerectwind.InitSub(lg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.Rectangle));
      outlinecolor:=gme.SetFieldSelect(s.ADR("Outline"),col.colors,col.PrintColor,SHORT(col.colors.GetNodeNumber(rect.outlinecol)),FALSE,plotinfo);
      outlinecolor.SetMinVisible(10);
      fillcolor:=gme.SetFieldSelect(s.ADR("Fill"),col.colors,col.PrintColor,SHORT(col.colors.GetNodeNumber(rect.fillcol)),FALSE,plotinfo);
      fillcolor.SetMinVisible(10);
      fillout:=gmo.SetCheckboxGadget(s.ADR("Fillout"),rect.fillout);
      root.NewSameTextWidth;
        root.AddSameTextWidth(outlinecolor);
        root.AddSameTextWidth(fillcolor);
        root.AddSameTextWidth(fillout);
    gmb.EndBox;
  glist:=root.EndRoot();

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    plotinfo.rast:=rast;
    root.Resize;

    NEW(backup); backup.Init;
    rect.BCopy(backup);

    LOOP
      class:=e.Wait(LONGSET{0..31});
(*      IF gridtask.msgsig IN class THEN (* Care of plotinfo when reactivating this passage (screen change etc.) *)
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
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            backup.BCopy(rect);
            ret:=FALSE;
            EXIT;
          ELSIF mes.iAddress=outlinecolor.gadget THEN
            node:=gb.SelectNode(col.colors,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),FALSE,col.PrintColor,plotinfo,wind);
            IF node#NIL THEN
              IF rect.outlinecol#NIL THEN
                rect.outlinecol.FreeUser(rect.task);
              END;
              rect.outlinecol:=node(col.Color);
              rect.outlinecol.NewUser(rect.task);
            END;
            outlinecolor.SetValue(col.colors.GetNodeNumber(rect.outlinecol));
          ELSIF mes.iAddress=fillcolor.gadget THEN
            node:=gb.SelectNode(col.colors,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),FALSE,col.PrintColor,plotinfo,wind);
            IF node#NIL THEN
              IF rect.fillcol#NIL THEN
                rect.fillcol.FreeUser(rect.task);
              END;
              rect.fillcol:=node(col.Color);
              rect.fillcol.NewUser(rect.task);
            END;
            fillcolor.SetValue(col.colors.GetNodeNumber(rect.fillcol));
          ELSIF mes.iAddress=fillout.gadget THEN
            rect.fillout:=fillout.Checked();
          END;
        END;
        IF (I.gadgetUp IN mes.class) AND (mes.iAddress=root.help) THEN
          ag.ShowFile(ag.guidename,"graphiccontents",wind);
        END;
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;

    IF backup#NIL THEN backup.Destruct; END;
  END;
  root.Destruct;
  DISPOSE(mes);
  col.DestructMinPlotInfo(plotinfo);
  RETURN ret;
END ChangeContents;

END Rectangle.

