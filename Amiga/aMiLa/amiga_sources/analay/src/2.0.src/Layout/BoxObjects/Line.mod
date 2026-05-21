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


MODULE Line;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       u  : Utility,
       gd : GadTools,
       ag : AmigaGuideTools,
       gt : GraphicsTools,
       l  : LinkedLists,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       gme: GuiManagerExtendedObjects,
       gb : GeneralBasics,
       go : GraphicObjects,
       m  : Multitasking,
       col: Colors,
       pc : PageCoords,
       pi : PlotInfo,
       lb : LayoutBasics,
       lg : LayoutGUI,
       ra : Raster,
       bo : Box,
       ac : AnalayCatalog,
       NoGuruRq;

TYPE Line * = POINTER TO LineDesc;
     LineDesc * = RECORD(bo.BoxDesc)
       color           * : col.Color;
       thickness       * : LONGREAL;  (* in pt *)
       turnaround      * : BOOLEAN; (* Line is drawn from lower left to upper right corner when set to TRUE. *)
     END;

PROCEDURE (line:Line) Init*;

BEGIN
  line.Init^;
  line.color:=col.stdcolor;
  IF line.color#NIL THEN line.color.NewUser(line.task); END;
  line.thickness:=1;
  line.turnaround:=FALSE;
END Init;

PROCEDURE (line:Line) Destruct*;

BEGIN
  IF line.color#NIL THEN line.color.FreeUser(line.task); END;
  line.Destruct^;
END Destruct;

PROCEDURE (line:Line) SetColor*(color:col.Color);

BEGIN
  IF line.color#NIL THEN line.color.FreeUser(line.task); END;
  line.color:=color;
  IF line.color#NIL THEN line.color.NewUser(line.task); END;
END SetColor;

PROCEDURE (line:Line) BCopy*(dest:l.Node);

BEGIN
  WITH dest: Line DO
    dest.SetColor(line.color);
    dest.thickness:=line.thickness;
  END;
END BCopy;

PROCEDURE (line:Line) CorrectCoords*;

BEGIN
  IF ((line.width<0) OR (line.height<0)) & ~((line.width<0) & (line.height<0)) THEN
    line.turnaround:=~line.turnaround;
  END;
  line.CorrectCoords^;
END CorrectCoords;

PROCEDURE (line:Line) PlotBorder*(plotinfo:pi.PlotInfo;type:INTEGER;active:BOOLEAN);

VAR px,py       : LONGINT;
    thickx,thicky:LONGINT;
    picx,picy,
    picwi,piche,
    xh,yh,x1,y1,
    x2,y2       : INTEGER;
    rast        : g.RastPortPtr;

BEGIN
  IF active THEN
    rast:=plotinfo.rast;
    plotinfo.CMToPicRect(line.xpos,line.ypos,px,py,NIL);
    picx:=SHORT(px); picy:=SHORT(py);
    plotinfo.CMToPic(line.width,line.height,px,py);
    picwi:=SHORT(px); piche:=SHORT(py);
    plotinfo.CMToPic(pc.PtToCM(line.thickness),pc.PtToCM(line.thickness),thickx,thicky);
    IF (thickx=1) & (thicky=1) & (type#bo.simpleBorder) THEN
      (* If type=bo.simpleBorder the drawn border must start and end where the line
         starts and ends (type=simpleBorder is used by Box.Place). *)

      INC(picx); INC(picy);
    END;
    g.SetDrMd(rast,SHORTSET{g.complement});

    IF ~line.turnaround THEN
      g.Move(rast,picx,picy);
      g.Draw(rast,picx+picwi,picy+piche);
    ELSE
      g.Move(rast,picx,picy+piche);
      g.Draw(rast,picx+picwi,picy);
    END;

    g.SetDrMd(rast,g.jam1);
  END;
END PlotBorder;

PROCEDURE (line:Line) Plot*(plotinfo:pi.PlotInfo);
(* May crash, see below *)

VAR rast        : g.RastPortPtr;
    picx,picy,
    picwi,piche : INTEGER;
    thickx,thicky,
    x,y         : LONGINT;
    i           : INTEGER;

BEGIN
  rast:=plotinfo.rast;
  plotinfo.CMToPicRect(line.xpos,line.ypos,x,y,NIL);
  picx:=SHORT(x); picy:=SHORT(y);
  plotinfo.CMToPic(line.width,line.height,x,y);
  picwi:=SHORT(x); piche:=SHORT(y);
  plotinfo.CMToPic(pc.PtToCM(line.thickness),pc.PtToCM(line.thickness),thickx,thicky);

  i:=line.color.SetColor(plotinfo,col.setFrontPen);
  i:=0;
  IF ~line.turnaround THEN
    gt.DrawLine(rast,picx,picy,picx+picwi,picy+piche,SHORT(thickx),SHORT(thicky),go.lines[0],i);
  ELSE
    gt.DrawLine(rast,picx,picy+piche,picx+picwi,picy,SHORT(thickx),SHORT(thicky),go.lines[0],i);
  END;
END Plot;

PROCEDURE (line:Line) MoveSize*(plotinfo:pi.PlotInfo;raster:ra.Raster;mes:I.IntuiMessagePtr;type:INTEGER):BOOLEAN;

(* Types:   0

                2Line2

                         1   *)

VAR xold,yold,
    widthold,heightold,
    realx,realy        : LONGREAL;
    picx,picy,
    picwi,piche,
    offx,offy,                     (* Mouse offset to upper left *)
    oldx,oldy,
    oldwi,oldhe,                   (* Old pic dims *)
    updist,downdist,               (* Offset of mouse position in the beginning *)
    leftdist,rightdist : LONGINT;  (* always >0 *)
    class              : LONGSET;
    x,y                : INTEGER;

BEGIN
  xold:=line.xpos; yold:=line.ypos;
  widthold:=line.width; heightold:=line.height;

  plotinfo.CMToPicRect(line.xpos,line.ypos,picx,picy,NIL);
  plotinfo.CMToPic(line.width,line.height,picwi,piche);
  oldx:=picx; oldy:=picy;
  oldwi:=picwi; oldhe:=piche;
  offx:=mes.mouseX-picx;
  offy:=mes.mouseY-picy;

  IF ~raster.snap THEN
    leftdist:=mes.mouseX-picx;
    updist:=mes.mouseY-picy;
    rightdist:=picx+picwi-1-mes.mouseX;
    downdist:=picy+piche-1-mes.mouseY;
  ELSE
    leftdist:=0; updist:=0; rightdist:=0; downdist:=0;
  END;

  line.PlotBorder(plotinfo,bo.standardBorder,TRUE);
  LOOP
    class:=e.Wait(LONGSET{0..31});
    REPEAT
      plotinfo.root.GetIMes(mes);
      oldx:=x; oldy:=y;
      plotinfo.subwind.GetMousePos(x,y);
      IF (I.mouseButtons IN mes.class) & (mes.code=I.selectUp) THEN
        x:=mes.mouseX; y:=mes.mouseY;
      END;
      IF (type#2) & (raster.snap) THEN
        plotinfo.PicToCMRect(x,y,realx,realy,NIL);
        raster.Snap(realx,realy);
        plotinfo.CMToPicRect(realx,realy,picx,picy,NIL); x:=SHORT(picx); y:=SHORT(picy);
      END;

      IF (x#oldx) OR (y#oldy) THEN
        plotinfo.CMToPicRect(line.xpos,line.ypos,picx,picy,NIL);
        plotinfo.CMToPic(line.width,line.height,picwi,piche);
        IF ~line.turnaround THEN
          IF type=0 THEN    (* Upper left *)
            DEC(picwi,x-leftdist-picx);
            picx:=x-leftdist;
            DEC(piche,y-updist-picy);
            picy:=y-updist;
          ELSIF type=1 THEN (* Lower right *)
            picwi:=x+rightdist-picx;
            piche:=y+downdist-picy;
          ELSIF type=2 THEN (* Position *)
            picx:=x-offx; picy:=y-offy;
          END;
        ELSE
          IF type=0 THEN    (* Upper right *)
            picwi:=x+rightdist-picx;
            DEC(piche,y-updist-picy);
            picy:=y-updist;
          ELSIF type=1 THEN (* Lower left *)
            DEC(picwi,x-leftdist-picx);
            picx:=x-leftdist;
            piche:=y+downdist-picy;
          ELSIF type=2 THEN (* Position *)
            picx:=x-offx; picy:=y-offy;
          END;
        END;
        line.PlotBorder(plotinfo,bo.standardBorder,TRUE);
        plotinfo.PicToCMRect(picx,picy,line.xpos,line.ypos,NIL);
        plotinfo.PicToCM(picwi,piche,line.width,line.height);
        IF type=2 THEN
          raster.Snap(line.xpos,line.ypos);
        END;
(*        line.CorrectCoords;*)
        line.PlotBorder(plotinfo,bo.standardBorder,TRUE);
      END;
      IF (I.mouseButtons IN mes.class) & (mes.code=I.selectUp) THEN
        EXIT;
      ELSIF I.menuPick IN mes.class THEN
        EXIT;
      END;
    UNTIL mes.class=LONGSET{};
  END;
  line.PlotBorder(plotinfo,bo.standardBorder,TRUE);
  IF (I.mouseButtons IN mes.class) & ((oldx#picx) OR (oldy#picy) OR (oldwi#picwi) OR (oldhe#piche)) THEN
(*    line.CorrectCoords;*)
    line.UpdateCoordStrings;
    RETURN TRUE;
  ELSE
    line.xpos:=xold; line.ypos:=yold;
    line.width:=widthold; line.height:=heightold;
    RETURN FALSE;
  END;
END MoveSize;

PROCEDURE (line:Line) CheckClicked*(plotinfo:pi.PlotInfo;mouseX,mouseY:LONGINT):BOOLEAN;

VAR picx,picy,
    picwi,piche : LONGINT;
    x1,y1,x2,y2 : LONGINT;

BEGIN
  plotinfo.CMToPicRect(line.xpos,line.ypos,picx,picy,NIL);
  plotinfo.CMToPic(line.width,line.height,picwi,piche);
  IF line.turnaround THEN
    picx:=picx+picwi-1;
    picwi:=-picwi;
  END;

  x1:=picx;
  x2:=picx+picwi;
  y1:=picy;
  y2:=picy+piche;
  IF (ABS(line.width)>=ABS(line.height)) AND (x2-x1#0) THEN
    y1:=SHORT(SHORT(y2-((y2-y1)/(x2-x1))*(x2-mouseX)));
    y2:=y1;
  ELSIF y2-y1#0 THEN
    x1:=SHORT(SHORT(x1+((x2-x1)/(y2-y1))*(mouseY-y1)));
    x2:=x1;
  ELSE
    x2:=x1;
    y2:=y1;
  END;
  IF (((mouseX>=x1-5) AND (mouseX<=x2+5)) OR ((mouseX>=x2-5) AND (mouseX<=x1+5))) AND (((mouseY>=y1-3) AND (mouseY<=y2+3)) OR ((mouseY>=y2-3) AND (mouseY<=y1+3))) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END;
END CheckClicked;

PROCEDURE (line:Line) Clicked*(plotinfo:pi.PlotInfo;raster:ra.Raster;mes:I.IntuiMessagePtr):BOOLEAN;

VAR picx,picy,
    picwi,piche,
    xh,yh,mx,my  : LONGINT;
    bool,movebox : BOOLEAN;

BEGIN
  bool:=FALSE;
  IF ~line.locked THEN
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
      plotinfo.CMToPicRect(line.xpos,line.ypos,picx,picy,NIL);
      plotinfo.CMToPic(line.width,line.height,picwi,piche);
      IF line.turnaround THEN
        picx:=picx+picwi-1;
        picwi:=-picwi;
      END;
      IF (mx>=picx-5) & (mx<=picx+5) & (my>=picy-3) & (my<=picy+3) THEN
        bool:=line.MoveSize(plotinfo,raster,mes,0);
      ELSIF (mx>=picx+picwi-5) & (mx<=picx+picwi+5) & (my>=picy+piche-3) & (my<=picy+piche+3) THEN
        bool:=line.MoveSize(plotinfo,raster,mes,1);
      ELSE
        bool:=line.MoveSize(plotinfo,raster,mes,2);
      END;
      RETURN bool;
    ELSE
      RETURN FALSE;
    END;
  ELSE
    RETURN FALSE;
  END;
END Clicked;



VAR changelinewind * : wm.Window;

PROCEDURE (line:Line) ChangeContents*(changetask:m.Task):BOOLEAN;

VAR subwind     : wm.SubWindow;
    wind        : I.WindowPtr;
    rast        : g.RastPortPtr;
    root        : gmb.Root;
    color       : gme.FieldSelect;
    thickstr    : gmo.StringGadget;
    thickslide  : gmo.SliderGadget;
    gadobj      : gmb.Object;
    glist       : I.GadgetPtr;
    mes         : I.IntuiMessagePtr;
    msg         : m.Message;
    class       : LONGSET;
    plotinfo    : pi.PlotInfo;
    node        : l.Node;
    backup      : Line;
    bool,ret    : BOOLEAN;

  PROCEDURE SetData;
  
  BEGIN
    color.SetValue(col.colors.GetNodeNumber(line.color));
    thickstr.SetReal(line.thickness);
    thickslide.SetValue(SHORT(SHORT(line.thickness)));
  END SetData;
  
  PROCEDURE GetStringInput;
  
  BEGIN
    line.thickness:=thickstr.GetReal();
    thickslide.SetValue(SHORT(SHORT(line.thickness)));
  END GetStringInput;

BEGIN
  plotinfo:=col.AllocMinPlotInfo();
  NEW(mes);
  ret:=FALSE;
  IF changelinewind=NIL THEN
    changelinewind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.ChangeGraphic),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=changelinewind.InitSub(lg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.LayoutLine));
      color:=gme.SetFieldSelect(ac.GetString(ac.LineColor),col.colors,col.PrintColor,SHORT(col.colors.GetNodeNumber(line.color)),FALSE,plotinfo);
      color.SetMinVisible(10);
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,ac.GetString(ac.LineThickness));
        thickstr:=gmo.SetStringGadget(NIL,5,gmo.realType);
        thickstr.SetMinVisible(4);
        thickstr.SetSizeX(0);
        thickstr.SetMinMaxReal(0,10);
        thickslide:=gmo.SetSliderGadget(0,10,SHORT(SHORT(line.thickness)),0,NIL);
      gmb.EndBox;
      root.NewSameTextWidth;
        root.AddSameTextWidth(color);
    gmb.EndBox;
    gmb.FillSpace;
  glist:=root.EndRoot();

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    plotinfo.rast:=rast;
    root.Resize;

    SetData;
    thickstr.Activate;

    NEW(backup); backup.Init;
    line.BCopy(backup);

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
            GetStringInput;
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            backup.BCopy(line);
            ret:=FALSE;
            EXIT;
          ELSIF mes.iAddress=color.gadget THEN
            node:=gb.SelectNode(col.colors,s.ADR("Select linecolor"),ac.GetString(ac.Color),s.ADR("No colors are entered at the moment!"),FALSE,col.PrintColor,plotinfo,wind);
            IF node#NIL THEN
              line.SetColor(node(col.Color));
            END;
            color.SetValue(col.colors.GetNodeNumber(line.color));
          ELSIF mes.iAddress=thickslide.gadget THEN
            line.thickness:=thickslide.GetValue();
            SetData;
          ELSIF ~(mes.iAddress=root.help) THEN
            GetStringInput;
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

BEGIN
  changelinewind:=NIL;
END Line.

