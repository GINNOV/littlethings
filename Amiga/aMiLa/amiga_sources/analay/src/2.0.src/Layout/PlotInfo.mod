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


MODULE PlotInfo;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       gd : GadTools,
       s  : SYSTEM,
       u  : Utility,
       bt : BasicTools,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       co : Coords,
       mg : MathGUI,
       pc : PageCoords,
       lb : LayoutBasics,
       dc : DisplayConversion,
       btp: BasicTypes,
       NoGuruRq;

TYPE Display * = POINTER TO DisplayDesc;
     DisplayDesc * = RECORD(btp.ANYDesc)
       screen       * : I.ScreenPtr;
       view         * : g.ViewPortPtr;
       colormap     * : g.ColorMapPtr;
       vinfo        * : gd.VisualInfo;

(* Greyscale data *)

       blackpen     * ,
       whitepen     * ,
       startpen     * ,
       numpens      * : LONGINT; (* numpens does NOT include blackpen and whitepen!
                                    While numpens represents the number of color pens
                                    starting at startpen used for the greyscale,
                                    blackpen and whitepen can be at completeley different
                                    places! *)
       usegreyscale * : BOOLEAN;
     END;

(* Set screen-field to proper value, then call Display.Init. *)

PROCEDURE GetColor(screen:I.ScreenPtr;red,green,blue:INTEGER;VAR dif:INTEGER):INTEGER;

VAR i,num,col,
    ret,
    red2,green2,
    blue2,grey,
    grey2     : INTEGER;
    set       : SET;
    colormap  : g.ColorMapPtr;

BEGIN
  colormap:=screen.viewPort.colorMap;
  num:=s.LSH(1,screen.rastPort.bitMap.depth);
  grey:=red+green+blue;
  ret:=0;
  dif:=MAX(INTEGER);
  FOR i:=0 TO num-1 DO
    col:=g.GetRGB4(colormap,i);
    set:=s.VAL(SET,col);
    red2:=s.VAL(INTEGER,s.LSH(s.LSH(set,4),-12))*255 DIV 15;
    green2:=s.VAL(INTEGER,s.LSH(s.LSH(set,8),-12))*255 DIV 15;
    blue2:=s.VAL(INTEGER,s.LSH(s.LSH(set,12),-12))*255 DIV 15;
    grey2:=red2+green2+blue2;
    IF ABS(grey2-grey)<dif THEN
      dif:=ABS(grey2-grey);
      ret:=i;
    END;
  END;
  RETURN ret;
END GetColor;

PROCEDURE (disp:Display) Init*;

VAR pen : LONGINT;
    dif : INTEGER;

BEGIN
  disp.view:=s.ADR(disp.screen.viewPort);
  disp.colormap:=disp.view.colorMap;
  disp.vinfo:=gd.GetVisualInfo(disp.screen,u.done);
  disp.blackpen:=-1;
  disp.whitepen:=-1;
  IF lb.layoutoptions.ownscreen THEN
    disp.numpens:=s.LSH(1,disp.screen.rastPort.bitMap.depth)-4;
    disp.startpen:=4;
  ELSE
    disp.numpens:=s.LSH(1,disp.screen.rastPort.bitMap.depth)-mg.screenmode.reserved;
    disp.startpen:=mg.screenmode.reserved;
  END;
  pen:=GetColor(disp.screen,0,0,0,dif);
  IF (dif<=3) OR (disp.numpens<2) THEN
    disp.blackpen:=pen;
  ELSE
    disp.blackpen:=-1;
  END;
  pen:=GetColor(disp.screen,255,255,255,dif);
  IF (dif<=3) OR (disp.numpens<2) THEN
    disp.whitepen:=pen;
  ELSE
    disp.whitepen:=-1;
  END;
  IF bt.os<39 THEN
    disp.usegreyscale:=TRUE;
  END;
END Init;

PROCEDURE (disp:Display) Destruct*;

BEGIN
  DISPOSE(disp);
END Destruct;

PROCEDURE (disp:Display) InitGreyScale*;

VAR bright,step   : LONGREAL;
    numpens       : LONGINT;
    pen,intbright : INTEGER;

BEGIN
  IF disp.usegreyscale THEN
    numpens:=disp.numpens;
    IF disp.blackpen>=0 THEN
      INC(numpens);
    END;
    IF disp.whitepen>=0 THEN
      INC(numpens);
    END;
    step:=15/numpens;
    bright:=0;
    IF disp.blackpen>=0 THEN
      bright:=bright+step;
    END;
    pen:=SHORT(disp.startpen);
    WHILE pen<disp.startpen+disp.numpens DO
      INC(pen);
      intbright:=SHORT(SHORT(SHORT(bright+0.5)));
      g.SetRGB4(disp.view,pen,intbright,intbright,intbright);
      bright:=bright+step;
    END;
  END;
END InitGreyScale;



TYPE PlotInfo * = POINTER TO PlotInfoDesc;
     PlotInfoDesc * = RECORD(pc.PageCoordsDesc)
       rast       * : g.RastPortPtr;
       subwind    * : wm.SubWindow;
       iwindow    * : I.WindowPtr;
       root       * : gmb.Root;
       vinfo      * : gd.VisualInfo;
       colormap   * : g.ColorMapPtr;
       view       * : g.ViewPortPtr;
       conv       * : dc.ConversionTable;
       display    * : Display;
(*       rect       * : co.Rectangle;*) (* To be found in pc.PageCoords *)
     END;

PROCEDURE (plotinfo:PlotInfo) Init*;

BEGIN
  plotinfo.Init^;
(*  NEW(plotinfo.conv); plotinfo.conv.Init;*) (* Must allocate lc.LayoutConversionTable! *)
                                              (* Cannot be allocated here due to a hirarchical conflict! *)
END Init;

PROCEDURE (plotinfo:PlotInfo) Destruct*;

BEGIN
(*  IF plotinfo.conv#NIL THEN plotinfo.conv.Destruct; END;*)
  plotinfo.Destruct^;
END Destruct;

END PlotInfo.

