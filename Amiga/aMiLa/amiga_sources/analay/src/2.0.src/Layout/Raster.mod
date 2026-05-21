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


MODULE Raster;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       gd : GadTools,
       st : Strings,
       tt : TextTools,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       lb : LayoutBasics,
       pi : PlotInfo,
       col: Colors,
       ac : AnalayCatalog,
       NoGuruRq;

TYPE Raster * = POINTER TO RasterDesc;
     RasterDesc * = RECORD
       xspace*,yspace   * ,
       xstart*,ystart   * : LONGREAL;
       xspaces*,yspaces * ,
       xstarts*,ystarts * : ARRAY 256 OF CHAR;
       display*,snap    * : BOOLEAN;
     END;

PROCEDURE (raster:Raster) Init*;

BEGIN
  raster.xspace:=1;
  raster.yspace:=1;
  raster.xstart:=0;
  raster.ystart:=0;
  raster.xspaces:="1";
  raster.yspaces:="1";
  raster.xstarts:="0";
  raster.ystarts:="0";
END Init;

PROCEDURE (raster:Raster) Destruct*;

BEGIN
  DISPOSE(raster);
END Destruct;

PROCEDURE (raster:Raster) Plot*(plotinfo:pi.PlotInfo);

VAR rast        : g.RastPortPtr;
    xorig,yorig,
    xend,yend,
    x,y         : LONGREAL;
    picx,picy   : LONGINT;
    i           : INTEGER;
    bool        : BOOLEAN;

BEGIN
  IF raster.display THEN
    rast:=plotinfo.rast;
    plotinfo.PicToCM(plotinfo.rect.width,plotinfo.rect.height,xend,yend);
  
    (* Getting upper left corner *)
    plotinfo.PicToCM(0,0,xorig,yorig);
    xorig:=xorig-raster.xstart;
    xorig:=SHORT(SHORT((xorig+(raster.xspace/2))/raster.xspace));
    xorig:=xorig*raster.xspace+raster.xstart;
    yorig:=yorig-raster.ystart;
    yorig:=SHORT(SHORT((yorig+(raster.yspace/2))/raster.yspace));
    yorig:=yorig*raster.yspace+raster.ystart;
  
    IF col.black#NIL THEN
      i:=col.black.SetColor(plotinfo,col.setFrontPen);
    ELSE
      g.SetAPen(rast,1);
    END;
    g.SetAPen(rast,1);
  
    y:=yorig;
    WHILE y<yend DO
      x:=xorig;
      WHILE x<xend DO
        plotinfo.CMToPicRect(x,y,picx,picy,NIL);
        bool:=g.WritePixel(rast,SHORT(picx),SHORT(picy));
        x:=x+raster.xspace;
      END;
      y:=y+raster.yspace;
    END;
  END;
END Plot;

PROCEDURE (raster:Raster) Snap*(VAR x,y:LONGREAL);

BEGIN
  IF raster.snap THEN
    x:=x-raster.xstart;
    x:=SHORT(SHORT((x+raster.xspace/2)/raster.xspace));
    x:=x*raster.xspace+raster.xstart;
    y:=y-raster.ystart;
    y:=SHORT(SHORT((y+raster.yspace/2)/raster.yspace));
    y:=y*raster.yspace+raster.ystart;
  END;
END Snap;



VAR changerasterwind * : wm.Window;

PROCEDURE (raster:Raster) Change*():BOOLEAN;

VAR subwind             : wm.SubWindow;
    wind                : I.WindowPtr;
    rast                : g.RastPortPtr;
    root                : gmb.Root;
    xspace,yspace,
    xstart,ystart       : gmo.StringGadget;
    display,snap        : gmo.CheckboxGadget;
    gadobj              : gmb.Object;
    glist               : I.GadgetPtr;
    mes                 : I.IntuiMessagePtr;
    class               : LONGSET;
    bool,didchange,ret  : BOOLEAN;

  PROCEDURE GetInput;

  BEGIN
    xstart.GetString(raster.xstarts); raster.xstart:=xstart.real;
    ystart.GetString(raster.ystarts); raster.ystart:=ystart.real;
    xspace.GetString(raster.xspaces); raster.xspace:=xspace.real;
    yspace.GetString(raster.yspaces); raster.yspace:=yspace.real;
    raster.display:=display.Checked();
    raster.snap:=snap.Checked();
  END GetInput;

BEGIN
  NEW(mes);
  ret:=FALSE;
  IF changerasterwind=NIL THEN
    changerasterwind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.ChangeRasterGrid),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=changerasterwind.InitSub(lb.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,TRUE,NIL);
      gadobj:=gmo.SetText(ac.GetString(ac.GridSize),-1);
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        xspace:=gmo.SetStringGadget(s.ADR("x"),255,gmo.realType);
        xspace.SetMinVisible(5);
        xspace.SetMinMaxReal(0.01,100);
        yspace:=gmo.SetStringGadget(s.ADR("y"),255,gmo.realType);
        yspace.SetMinVisible(5);
        yspace.SetMinMaxReal(0.01,100);
      gmb.EndBox;
      gadobj:=gmo.SetText(ac.GetString(ac.StartCoordinates),-1);
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        xstart:=gmo.SetStringGadget(s.ADR("x"),255,gmo.realType);
        xstart.SetMinVisible(5);
        xstart.SetMinMaxReal(-100,100);
        ystart:=gmo.SetStringGadget(s.ADR("y"),255,gmo.realType);
        ystart.SetMinVisible(5);
        xstart.SetMinMaxReal(-100,100);
      gmb.EndBox;
    gmb.EndBox;
    display:=gmo.SetCheckboxGadget(ac.GetString(ac.DisplayRasterGrid),raster.display);
    snap:=gmo.SetCheckboxGadget(ac.GetString(ac.Snap),raster.snap);
    gmb.FillSpace;
    root.NewSameTextWidth;
      root.AddSameTextWidth(display);
      root.AddSameTextWidth(snap);
  glist:=root.EndRoot();

  root.Init;

  xstart.SetString(raster.xstarts);
  ystart.SetString(raster.ystarts);
  xspace.SetString(raster.xspaces);
  yspace.SetString(raster.yspaces);

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;
    xspace.Activate;

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
END Change;

BEGIN
  changerasterwind:=NIL;
END Raster.

