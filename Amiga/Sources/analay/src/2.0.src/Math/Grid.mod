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


MODULE Grid;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       gd : GadTools,
       l  : LinkedLists,
       lrc: LongRealConversions,
       tt : TextTools,
       ag : AmigaGuideTools,
       m  : Multitasking,
       mm : MemoryManager,
       ac : AnalayCatalog,
       mg : MathGUI,
       co : Coords,
       al : AxisLabels,
       dc : DisplayConversion,
       go : GraphicObjects,
       gt : GraphicsTools,
       fb : FunctionBasics,
       ft : FunctionTrees,
       w  : Window,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       bt : BasicTypes,
       NoGuruRq;

(* Grid class for grid displayed in graph windows. *)

TYPE Grid * = POINTER TO GridDesc;
     GridDesc * = RECORD;
       window          * : w.Window;        (* The window this grid belongs to. *)
       xspace*,yspace  * ,
       xstart*,ystart  * : LONGREAL;
       xspaces*,yspaces* ,
       xstarts*,ystarts* : ARRAY 256 OF CHAR;
       color           * ,
       pattern         * ,
       thickness       * : INTEGER;
       active          * : BOOLEAN;
       auto            * : BOOLEAN;
     END;

PROCEDURE (grid:Grid) Init*(second:BOOLEAN);

BEGIN
  grid.color:=3;
  grid.thickness:=1;
  IF NOT(second) THEN
    grid.active:=TRUE;
    grid.pattern:=0;
    grid.xspace:=1;
    grid.yspace:=1;
    grid.xstart:=0;
    grid.ystart:=0;
    grid.xspaces:="1";
    grid.yspaces:="1";
    grid.xstarts:="0";
    grid.ystarts:="0";
    grid.auto:=TRUE;
  ELSE
    grid.active:=FALSE;
    grid.pattern:=3;
    grid.xspace:=1;
    grid.yspace:=1;
    grid.xstart:=0.5;
    grid.ystart:=0.5;
    grid.xspaces:="1";
    grid.yspaces:="1";
    grid.xstarts:="0.5";
    grid.ystarts:="0.5";
    grid.auto:=TRUE;
  END;
END Init;

PROCEDURE (grid:Grid) Destruct*;

BEGIN
  DISPOSE(grid);
END Destruct;

PROCEDURE (grid:Grid) Copy*(dest:Grid);

BEGIN
  dest.window:=grid.window;
  dest.xspace:=grid.xspace;
  dest.yspace:=grid.yspace;
  dest.xstart:=grid.xstart;
  dest.ystart:=grid.ystart;
  COPY(grid.xspaces,dest.xspaces);
  COPY(grid.yspaces,dest.yspaces);
  COPY(grid.xstarts,dest.xstarts);
  COPY(grid.ystarts,dest.ystarts);
  dest.color:=grid.color;
  dest.pattern:=grid.pattern;
  dest.thickness:=grid.thickness;
  dest.active:=grid.active;
END Copy;

PROCEDURE (grid:Grid) AllocNew*():Grid;

VAR node : Grid;

BEGIN
  NEW(node);
  RETURN node;
END AllocNew;

PROCEDURE (grid:Grid) Plot*(rast:g.RastPortPtr;coord:co.CoordSystem;rect:co.Rectangle;conv:dc.ConversionTable);

VAR r           : LONGREAL;
    x1,y1,x2,y2,               (* x1|y1 is upper left, x2|y2 is lower right *)
    px,py,pos,
    linex,liney : INTEGER;

(*PROCEDURE WorldToPic(wx,wy:LONGREAL;VAR px,py:INTEGER;p:l.Node);

VAR distx,disty : LONGREAL;
    factx,facty : LONGREAL;

BEGIN
  WITH p: s1.Fenster DO
    distx:=p.xmax-p.xmin;
    disty:=p.ymax-p.ymin;
    wx:=wx-p.xmin;
    wy:=wy-p.ymin;
    factx:=wx/distx;
    facty:=wy/disty;
    px:=SHORT(SHORT(SHORT(factx*width+0.5)));
    py:=SHORT(SHORT(SHORT(facty*height+0.5)));
    py:=height-py;
    INC(px,xpos);
    INC(py,ypos);
  END;
END WorldToPic;*)

BEGIN
  IF conv.gridconv#NIL THEN conv:=conv.gridconv; END;
  IF coord IS co.CartesianSystem THEN
    WITH coord: co.CartesianSystem DO
      g.SetAPen(rast,conv.GetColor(grid.color,dc.standardType));
      gt.SetLinePattern(rast,go.lines[grid.pattern]);
      g.SetDrMd(rast,g.jam1);
      linex:=conv.GetThicknessX(grid.thickness);
      liney:=conv.GetThicknessY(grid.thickness);
      coord.WorldToPic(rect,coord.xmin,coord.ymin,x1,y1);
      coord.WorldToPic(rect,coord.xmax,coord.ymax,x2,y2);
  
      r:=grid.xstart;
      IF r<coord.xmin THEN
        r:=grid.xstart+SHORT(SHORT((coord.xmin-grid.xstart)/grid.xspace))*grid.xspace;
      END;
      r:=r-grid.xspace;
      pos:=0;
      WHILE r<=coord.xmax-grid.xspace DO
        r:=r+grid.xspace;
        IF r>=coord.xmin THEN
          coord.WorldToPic(rect,r,0,px,py);
          IF linex=1 THEN
            g.Move(rast,px,y1);
            g.Draw(rast,px,y2);
          ELSE
            gt.DrawLine(rast,px,y1,px,y2,linex,liney,go.lines[grid.pattern],pos);
          END;
        END;
      END;
  
      r:=grid.xstart;
      IF r>coord.xmax THEN
        r:=grid.xstart-SHORT(SHORT((grid.xstart-coord.xmax)/grid.xspace))*grid.xspace;
      END;
      r:=r+grid.xspace;
      pos:=0;
      WHILE r>=coord.xmin+grid.xspace DO
        r:=r-grid.xspace;
        IF r<=coord.xmax THEN
          coord.WorldToPic(rect,r,0,px,py);
          IF linex=1 THEN
            g.Move(rast,px,y1);
            g.Draw(rast,px,y2);
          ELSE
            gt.DrawLine(rast,px,y1,px,y2,linex,liney,go.lines[grid.pattern],pos);
          END;
        END;
      END;
  
      r:=grid.ystart;
      IF r<coord.ymin THEN
        r:=grid.ystart+SHORT(SHORT((coord.ymin-grid.ystart)/grid.yspace))*grid.yspace;
      END;
      r:=r-grid.yspace;
      pos:=0;
      WHILE r<=coord.ymax-grid.yspace DO
        r:=r+grid.yspace;
        IF r>=coord.ymin THEN
          coord.WorldToPic(rect,0,r,px,py);
          IF liney=1 THEN
            g.Move(rast,x1,py);
            g.Draw(rast,x2,py);
          ELSE
            gt.DrawLine(rast,x1,py,x2,py,linex,liney,go.lines[grid.pattern],pos);
          END;
        END;
      END;
  
      r:=grid.ystart;
      IF r>coord.ymax THEN
        r:=grid.ystart-SHORT(SHORT((grid.ystart-coord.ymax)/grid.yspace))*grid.yspace;
      END;
      r:=r+grid.yspace;
      pos:=0;
      WHILE r>=coord.ymin+grid.yspace DO
        r:=r-grid.yspace;
        IF r<=coord.ymax THEN
          coord.WorldToPic(rect,0,r,px,py);
          IF liney=1 THEN
            g.Move(rast,x1,py);
            g.Draw(rast,x2,py);
          ELSE
            gt.DrawLine(rast,x1,py,x2,py,linex,liney,go.lines[grid.pattern],pos);
          END;
        END;
      END;
      gt.SetFullPattern(rast);
  
  (*  ELSIF p.mode=1 THEN
      g.SetAPen(rast,pg.col);
      gt.SetLinePattern(rast,s1.lines[pg.muster]);
      r:=pg.ystart;
      r:=r-pg.yspace;
      pos:=0;
      s1.PolarToPic(0,0,ux,uy,p.xmin,p.xmax,p.ymin,p.ymax,width,height);
      WHILE r<=p.ymax-pg.yspace DO
        r:=r+pg.yspace;
        s1.PolarToPic(0,SHORT(r),px,pos,p.xmin,p.xmax,p.ymin,p.ymax,width,height);
        s1.PolarToPic(1.5*f1.PI,SHORT(r),pos,py,p.xmin,p.xmax,p.ymin,p.ymax,width,height);
        px:=px-(width DIV 2);
        py:=py-(height DIV 2);
        g.DrawEllipse(rast,ux+xpos,uy+ypos,px,py);
  (*      g.Move(p.rast,px+p.inx,p.iny);
        g.Draw(rast,px+p.inx,p.height+p.iny);*)
    (*    s2.DrawLine(p.rast,px,0,px,p.height,linie[pg.muster],pos);*)
      END;
      r:=pg.xstart;
      r:=r-pg.xspace;
      pos:=0;
      WHILE r<=p.xmax-pg.xspace DO
        r:=r+pg.xspace;
        s1.PolarToPic(SHORT(r),p.ymax,px,py,p.xmin,p.xmax,p.ymin,p.ymax,width,height);
  (*      px:=px-(p.width DIV 2);
        py:=py-(p.height DIV 2);*)
  (*      g.DrawEllipse(p.rast,(p.width DIV 2)+p.inx,(p.height DIV 2)+p.iny,px,py);*)
        g.Move(rast,ux+xpos,uy+ypos);
        g.Draw(rast,px+xpos,py+ypos);
    (*    s2.DrawLine(p.rast,px,0,px,p.height,linie[pg.muster],pos);*)
      END;*)
      gt.FreeRastPortNode(rast);
    END;
  END;
END Plot;

PROCEDURE (grid1:Grid) Auto*(grid2:Grid;labels:al.AxisLabels);

VAR bool : BOOLEAN;

BEGIN
  IF grid1.active THEN
    grid1.xspace:=labels.numsx;
    grid1.yspace:=labels.numsy;
    grid1.xstart:=0;
    grid1.ystart:=0;
    bool:=lrc.RealToString(grid1.xspace,grid1.xspaces,7,7,FALSE);
    tt.Clear(grid1.xspaces);
    bool:=lrc.RealToString(grid1.yspace,grid1.yspaces,7,7,FALSE);
    tt.Clear(grid1.yspaces);
    bool:=lrc.RealToString(grid1.xstart,grid1.xstarts,7,7,FALSE);
    tt.Clear(grid1.xstarts);
    bool:=lrc.RealToString(grid1.ystart,grid1.ystarts,7,7,FALSE);
    tt.Clear(grid1.ystarts);
  END;
(*  IF grid2.active THEN*)
    grid2.xstart:=grid1.xspace/2;
    grid2.ystart:=grid1.yspace/2;
(*    node(Fenster).grid1.xspace:=node(Fenster).grid1.xspace*2;
    node(Fenster).grid1.yspace:=node(Fenster).grid1.yspace*2;*)
    grid2.xspace:=grid1.xspace;
    grid2.yspace:=grid1.yspace;
    bool:=lrc.RealToString(grid2.xspace,grid2.xspaces,7,7,FALSE);
    tt.Clear(grid2.xspaces);
    bool:=lrc.RealToString(grid2.yspace,grid2.yspaces,7,7,FALSE);
    tt.Clear(grid2.yspaces);
    bool:=lrc.RealToString(grid2.xstart,grid2.xstarts,7,7,FALSE);
    tt.Clear(grid2.xstarts);
    bool:=lrc.RealToString(grid2.ystart,grid2.ystarts,7,7,FALSE);
    tt.Clear(grid2.ystarts);
(*  END;*)
END Auto;



VAR gridwind * : wm.Window;

PROCEDURE (grid1:Grid) Change*(gridtask:m.Task;grid2:Grid):BOOLEAN;

VAR subwind           : wm.SubWindow;
    wind              : I.WindowPtr;
    rast              : g.RastPortPtr;
    root              : gmb.Root;
    active1,active2   : gmo.CheckboxGadget;
    xspace1,yspace1,
    xstart1,ystart1,
    xspace2,yspace2,
    xstart2,ystart2   : gmo.StringGadget;
    palette1,palette2 : gmo.PaletteGadget;
    pattern1,pattern2,
    thickness1,thickness2 : gmo.SelectBox;
    gadobj            : gmb.Object;
    glist             : I.GadgetPtr;
    mes               : I.IntuiMessagePtr;
    msg               : m.Message;
    class             : LONGSET;
    savegrid1,
    savegrid2         : Grid;
    depth             : INTEGER;
    bool,didchange,ret: BOOLEAN;

  PROCEDURE SetData;

  BEGIN
    active1.Check(grid1.active);
    xspace1.SetString(grid1.xspaces);
    yspace1.SetString(grid1.yspaces);
    xstart1.SetString(grid1.xstarts);
    ystart1.SetString(grid1.ystarts);
    palette1.SetValue(grid1.color);
    pattern1.SetValue(grid1.pattern);
    thickness1.SetValue(grid1.thickness-1);

    active2.Check(grid2.active);
    xspace2.SetString(grid2.xspaces);
    yspace2.SetString(grid2.yspaces);
    xstart2.SetString(grid2.xstarts);
    ystart2.SetString(grid2.ystarts);
    palette2.SetValue(grid2.color);
    pattern2.SetValue(grid2.pattern);
    thickness2.SetValue(grid2.thickness-1);
  END SetData;

  PROCEDURE GetInput;

  BEGIN
    grid1.active:=active1.Checked();
    xspace1.GetString(grid1.xspaces);
    yspace1.GetString(grid1.yspaces);
    xstart1.GetString(grid1.xstarts);
    ystart1.GetString(grid1.ystarts);
    grid1.xstart:=ft.ExpressionToReal(grid1.xstarts);
    grid1.ystart:=ft.ExpressionToReal(grid1.ystarts);
    grid1.xspace:=ft.ExpressionToReal(grid1.xspaces);
    grid1.yspace:=ft.ExpressionToReal(grid1.yspaces);
    grid1.color:=SHORT(palette1.GetValue());
    grid1.pattern:=SHORT(pattern1.GetValue());
    grid1.thickness:=SHORT(thickness1.GetValue()+1);

    grid2.active:=active2.Checked();
    xspace2.GetString(grid2.xspaces);
    yspace2.GetString(grid2.yspaces);
    xstart2.GetString(grid2.xstarts);
    ystart2.GetString(grid2.ystarts);
    grid2.xstart:=ft.ExpressionToReal(grid2.xstarts);
    grid2.ystart:=ft.ExpressionToReal(grid2.ystarts);
    grid2.xspace:=ft.ExpressionToReal(grid2.xspaces);
    grid2.yspace:=ft.ExpressionToReal(grid2.yspaces);
    grid2.color:=SHORT(palette2.GetValue());
    grid2.pattern:=SHORT(pattern2.GetValue());
    grid2.thickness:=SHORT(thickness2.GetValue()+1);
  END GetInput;

BEGIN
  NEW(mes);
  ret:=FALSE;
  IF gridwind=NIL THEN
    gridwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.Grid),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=gridwind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.horizBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    depth:=s.LSH(1,mg.screenmode.depth); IF depth>16 THEN depth:=16; END;
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      active1:=gmo.SetCheckboxGadget(ac.GetString(ac.Grid1On),grid1.active);
      gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,NIL);
        gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,TRUE,ac.GetString(ac.Settings));
          gadobj:=gmo.SetText(ac.GetString(ac.GridSize),-1);
          gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
            xspace1:=gmo.SetStringGadget(s.ADR("x"),255,gmo.realType);
            xspace1.SetMinVisible(5);
            yspace1:=gmo.SetStringGadget(s.ADR("y"),255,gmo.realType);
            yspace1.SetMinVisible(5);
          gmb.EndBox;
          gadobj:=gmo.SetText(ac.GetString(ac.StartCoordinates),-1);
          gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
            xstart1:=gmo.SetStringGadget(s.ADR("x"),255,gmo.realType);
            xstart1.SetMinVisible(5);
            ystart1:=gmo.SetStringGadget(s.ADR("y"),255,gmo.realType);
            ystart1.SetMinVisible(5);
          gmb.EndBox;
        gmb.EndBox;
        gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,TRUE,ac.GetString(ac.GridDesign));
          palette1:=gmo.SetPaletteGadget(ac.GetString(ac.Color),mg.screenmode.depth,depth,grid1.color);
          pattern1:=gmo.SetSelectBox(ac.GetString(ac.LinePattern),10,grid1.pattern,5,2,16,mg.window.rPort.txHeight*3 DIV 8,-1,gmo.horizOrient,go.PlotPatternLine);
          thickness1:=gmo.SetSelectBox(ac.GetString(ac.LineThickness),5,grid1.thickness-1,2,3,16*4,mg.window.rPort.txHeight*7 DIV 8,-1,gmo.vertOrient,go.PlotThicknessLine);
        gmb.EndBox;
      gmb.EndBox;
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      active2:=gmo.SetCheckboxGadget(ac.GetString(ac.Grid2On),grid2.active);
      gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,NIL);
        gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,TRUE,ac.GetString(ac.Settings));
          gadobj:=gmo.SetText(ac.GetString(ac.GridSize),-1);
          gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
            xspace2:=gmo.SetStringGadget(s.ADR("x"),255,gmo.realType);
            xspace2.SetMinVisible(5);
            yspace2:=gmo.SetStringGadget(s.ADR("y"),255,gmo.realType);
            yspace2.SetMinVisible(5);
          gmb.EndBox;
          gadobj:=gmo.SetText(ac.GetString(ac.StartCoordinates),-1);
          gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
            xstart2:=gmo.SetStringGadget(s.ADR("x"),255,gmo.realType);
            xstart2.SetMinVisible(5);
            ystart2:=gmo.SetStringGadget(s.ADR("y"),255,gmo.realType);
            ystart2.SetMinVisible(5);
          gmb.EndBox;
        gmb.EndBox;
        gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,TRUE,ac.GetString(ac.GridDesign));
          palette2:=gmo.SetPaletteGadget(ac.GetString(ac.Color),mg.screenmode.depth,depth,grid2.color);
          pattern2:=gmo.SetSelectBox(ac.GetString(ac.LinePattern),10,grid2.pattern,5,2,16,mg.window.rPort.txHeight*3 DIV 8,-1,gmo.horizOrient,go.PlotPatternLine);
          thickness2:=gmo.SetSelectBox(ac.GetString(ac.LineThickness),5,grid2.thickness-1,2,3,16*4,mg.window.rPort.txHeight*7 DIV 8,-1,gmo.vertOrient,go.PlotThicknessLine);
        gmb.EndBox;
      gmb.EndBox;
    gmb.EndBox;
  glist:=root.EndRoot();

  root.Init;

  xstart1.SetString(grid1.xstarts);
  ystart1.SetString(grid1.ystarts);
  xspace1.SetString(grid1.xspaces);
  yspace1.SetString(grid1.yspaces);
  xstart2.SetString(grid2.xstarts);
  ystart2.SetString(grid2.ystarts);
  xspace2.SetString(grid2.xspaces);
  yspace2.SetString(grid2.yspaces);

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;
    xspace1.Activate;

    savegrid1:=NIL; savegrid2:=NIL;
    NEW(savegrid1); savegrid1.Init(TRUE);  grid1.Copy(savegrid1);
    NEW(savegrid2); savegrid2.Init(FALSE); grid2.Copy(savegrid2);

    didchange:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF gridtask.msgsig IN class THEN
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
            ELSIF msg.type=m.msgNewPriority THEN
              gridtask.SetPriority(m.taskdata.requesterpri);
            END;
            msg.Reply;
          END;
        UNTIL msg=NIL;
      END;
      REPEAT
        root.GetIMes(mes);
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            grid1.auto:=FALSE;
            grid2.auto:=FALSE;
  
            GetInput;
            ret:=TRUE;
            grid1.window.changed:=TRUE;
            grid1.window.SendNewMsg(m.msgNodeChanged,NIL);
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            savegrid1.Copy(grid1);
            savegrid2.Copy(grid2);
  
            IF didchange THEN
              grid1.window.changed:=TRUE;
              grid1.window.SendNewMsg(m.msgNodeChanged,NIL);
            END;
            ret:=FALSE;
            EXIT;
          ELSIF NOT(mes.iAddress=root.help) THEN
            GetInput; didchange:=TRUE;
            grid1.auto:=FALSE; grid2.auto:=FALSE;
            grid1.window.changed:=TRUE;
            grid1.window.SendNewMsg(m.msgNodeChanged,NIL);
          END;
        END;
        IF ((I.gadgetUp IN mes.class) AND (mes.iAddress=root.help)) THEN
          ag.ShowFile(ag.guidename,"changegrid",wind);
        END;
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;

    IF savegrid2#NIL THEN savegrid2.Destruct; END;
    IF savegrid1#NIL THEN savegrid1.Destruct; END;
  END;
  root.Destruct;
  DISPOSE(mes);
  RETURN ret;
END Change;



(* Procedure started as task *)

TYPE ChangeGridData * = POINTER TO ChangeGridDataDesc;
     ChangeGridDataDesc * = RECORD(bt.ANYDesc)
       grid1 * ,
       grid2 * : Grid;
     END;

PROCEDURE ChangeGridTask*(gridtask:bt.ANY):bt.ANY;

VAR data : ChangeGridData;
    bool : BOOLEAN;

BEGIN
  WITH gridtask: m.Task DO
    gridtask.InitCommunication;
    data:=gridtask.data(ChangeGridData);
    bool:=data.grid1.Change(gridtask,data.grid2);

    data.grid1.window.RemTask(gridtask);
    gridtask.ReplyAllMessages;
    gridtask.DestructCommunication;
    mm.NodeToGarbage(gridtask);
    data.grid1.window.FreeUser(gridtask);
    DISPOSE(data);
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END ChangeGridTask;

BEGIN
  gridwind:=NIL;
END Grid.

