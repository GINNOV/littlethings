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


MODULE Circle;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       u  : Utility,
       gd : GadTools,
       l  : LinkedLists,
       gt : GraphicsTools,
       ag : AmigaGuideTools,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       gme: GuiManagerExtendedObjects,
       go : GraphicObjects,
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

TYPE Circle * = POINTER TO CircleDesc;
     CircleDesc * = RECORD(bo.BoxDesc)
       outlinecol      * ,
       fillcol         * : col.Color;
       borderthickness * : LONGREAL;  (* in pt *)
       fillout         * : BOOLEAN;   (* fill out, otherwise transparent *)
     END;

PROCEDURE (circle:Circle) Init*;

BEGIN
  circle.Init^;
  circle.outlinecol:=col.stdcolor;
  circle.fillcol:=col.stdcolor;
  IF circle.outlinecol#NIL THEN circle.outlinecol.NewUser(circle.task); END;
  IF circle.fillcol#NIL THEN circle.fillcol.NewUser(circle.task); END;
  circle.borderthickness:=1;
  circle.fillout:=FALSE;
END Init;

PROCEDURE (circle:Circle) Destruct*;

BEGIN
  IF circle.outlinecol#NIL THEN circle.outlinecol.FreeUser(circle.task); END;
  IF circle.fillcol#NIL THEN circle.fillcol.FreeUser(circle.task); END;
  circle.Destruct^;
END Destruct;

PROCEDURE (circle:Circle) SetOutlineColor*(color:col.Color);

BEGIN
  IF circle.outlinecol#NIL THEN circle.outlinecol.FreeUser(circle.task); END;
  circle.outlinecol:=color;
  IF circle.outlinecol#NIL THEN circle.outlinecol.NewUser(circle.task); END;
END SetOutlineColor;

PROCEDURE (circle:Circle) SetFillColor*(color:col.Color);

BEGIN
  IF circle.fillcol#NIL THEN circle.fillcol.FreeUser(circle.task); END;
  circle.outlinecol:=color;
  IF circle.fillcol#NIL THEN circle.fillcol.NewUser(circle.task); END;
END SetFillColor;

PROCEDURE (circle:Circle) BCopy*(dest:l.Node);

BEGIN
  WITH dest: Circle DO
    dest.SetOutlineColor(circle.outlinecol);
    dest.SetFillColor(circle.fillcol);
    dest.borderthickness:=circle.borderthickness;
    dest.fillout:=circle.fillout;
  END;
END BCopy;

PROCEDURE (circle:Circle) Plot*(plotinfo:pi.PlotInfo);
(* May crash, see below *)

VAR rast        : g.RastPortPtr;
    picx,picy,
    picwi,piche,
    inx,iny     : INTEGER;
    x,y         : LONGINT;
    i           : INTEGER;

BEGIN
  IF circle.quickdisp THEN
    circle.QuickPlot(plotinfo);
  ELSE
    rast:=plotinfo.rast;
    plotinfo.CMToPicRect(circle.xpos,circle.ypos,x,y,NIL);
    picx:=SHORT(x); picy:=SHORT(y);
    plotinfo.CMToPic(circle.width,circle.height,x,y);
    picwi:=SHORT(x); piche:=SHORT(y);
    plotinfo.CMToPic(pc.PtToCM(circle.borderthickness),pc.PtToCM(circle.borderthickness),x,y);
    inx:=SHORT(x); iny:=SHORT(y);
  
    i:=circle.outlinecol.SetColor(plotinfo,col.setFrontPen);
    INC(picwi);
    INC(piche);
    IF circle.fillout THEN
      gt.DrawFilledEllipse(rast,picx+((picwi-1) DIV 2),picy+((piche-1) DIV 2),(picwi+1) DIV 2,(piche+1) DIV 2);
      IF circle.outlinecol#circle.fillcol THEN
        i:=circle.fillcol.SetColor(plotinfo,col.setFrontPen);
        gt.DrawFilledEllipse(rast,picx+((picwi-1) DIV 2),picy+((piche-1) DIV 2),((picwi+1) DIV 2)-inx,((piche+1) DIV 2)-iny);
      END;
    ELSE
      gt.DrawEllipse(rast,picx+((picwi-1) DIV 2),picy+((piche-1) DIV 2),(picwi+1) DIV 2,(piche+1) DIV 2,inx,iny,go.lines[0]);
    END;
  END;
END Plot;

VAR changecirclewind * : wm.Window;

PROCEDURE (circle:Circle) ChangeContents*(changetask:m.Task):BOOLEAN;

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
    backup      : Circle;
    bool,ret    : BOOLEAN;

BEGIN
  NEW(plotinfo); plotinfo.Init;
  plotinfo.view:=s.ADR(lb.screen.viewPort);
  plotinfo.colormap:=plotinfo.view.colorMap;
  plotinfo.vinfo:=gd.GetVisualInfo(lb.screen,u.done);
  plotinfo.display:=lb.maindisp(pi.Display);
  NEW(mes);
  ret:=FALSE;
  IF changecirclewind=NIL THEN
    changecirclewind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.ChangeGraphic),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=changecirclewind.InitSub(lg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.Ellipse));
      outlinecolor:=gme.SetFieldSelect(s.ADR("Outline"),col.colors,col.PrintColor,SHORT(col.colors.GetNodeNumber(circle.outlinecol)),FALSE,plotinfo);
      outlinecolor.SetMinVisible(10);
      fillcolor:=gme.SetFieldSelect(s.ADR("Fill"),col.colors,col.PrintColor,SHORT(col.colors.GetNodeNumber(circle.fillcol)),FALSE,plotinfo);
      fillcolor.SetMinVisible(10);
      fillout:=gmo.SetCheckboxGadget(s.ADR("Fillout"),circle.fillout);
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
    circle.BCopy(backup);

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
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            backup.BCopy(circle);
            ret:=FALSE;
            EXIT;
          ELSIF mes.iAddress=outlinecolor.gadget THEN
            node:=gb.SelectNode(col.colors,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),FALSE,col.PrintColor,plotinfo,wind);
            IF node#NIL THEN
              circle.SetOutlineColor(node(col.Color));
            END;
            outlinecolor.SetValue(col.colors.GetNodeNumber(circle.outlinecol));
          ELSIF mes.iAddress=fillcolor.gadget THEN
            node:=gb.SelectNode(col.colors,ac.GetString(ac.SelectWindow),ac.GetString(ac.Window),s.ADR("No windows are displayed at the moment!"),FALSE,col.PrintColor,plotinfo,wind);
            IF node#NIL THEN
              circle.SetFillColor(node(col.Color));
            END;
            fillcolor.SetValue(col.colors.GetNodeNumber(circle.fillcol));
          ELSIF mes.iAddress=fillout.gadget THEN
            circle.fillout:=fillout.Checked();
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
  col.FreePensSelect(plotinfo.display);
  IF plotinfo.vinfo#NIL THEN gd.FreeVisualInfo(plotinfo.vinfo); END;
  plotinfo.Destruct;
  RETURN ret;
END ChangeContents;

END Circle.

