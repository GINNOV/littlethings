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


MODULE Ruler;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       u  : Utility,
       gd : GadTools,
       st : Strings,
       tt : TextTools,
       gmb: GuiManagerBasics,
       lrp: LayerRastPort,
       co : Coords,
       pi : PlotInfo,
       lg : LayoutGUI,
       NoGuruRq;

(* Attention: Only works properly if x/ymin lies on proper borders (e.g. 0; 1) *)

TYPE Ruler * = POINTER TO RulerDesc;
     RulerDesc * = RECORD;
       rect      * : co.Rectangle; (* The rulers are plotted to the top and left border of this rectangle *)
       horizrast,
       vertrast    : lrp.LayerRastPort;
       xmin*,xmax*,              (* Ruler range *)
       ymin*,ymax* : LONGREAL;
(*       xpos*,ypos* : LONGREAL; (* Current position of ruler *)*)
       stepx,stepy : LONGREAL;
       picwidth,
       picheight   : LONGINT;  (* of complete ruler in pixels *)
       horizheight*,
       vertwidth * : LONGINT;
     END;

VAR auto : POINTER TO ARRAY OF LONGREAL;

PROCEDURE (ruler:Ruler) Init*;

BEGIN
  ruler.rect:=NIL;
  ruler.horizrast:=NIL;
  ruler.vertrast:=NIL;
  ruler.xmin:=0;
  ruler.xmax:=21;
  ruler.ymin:=0;
  ruler.ymax:=29.7;
(*  ruler.xpos:=0;
  ruler.ypos:=0;*)
END Init;

PROCEDURE (ruler:Ruler) Destruct*;

BEGIN
  IF ruler.horizrast#NIL THEN lrp.FreeLayerRast(ruler.horizrast);
                              ruler.horizrast:=NIL; END;
  IF ruler.vertrast#NIL THEN lrp.FreeLayerRast(ruler.vertrast);
                             ruler.vertrast:=NIL; END;
  DISPOSE(ruler);
END Destruct;

PROCEDURE (ruler:Ruler) RefreshInternal*(plotinfo:pi.PlotInfo);

VAR xpos,ypos             : LONGREAL;
    picwidth,picheight    : LONGINT;
    horizheight,vertwidth : LONGINT;
    picx,picy,picwi,piche : LONGINT;
    str                   : ARRAY 80 OF CHAR;
    bool                  : BOOLEAN;

  PROCEDURE GetXStep():LONGREAL;

  VAR stepx,xpos,ypos : LONGREAL;
      picx,picy,
      picwi,piche,
      lastpicx        : LONGINT;
      actauto         : INTEGER;
      str             : ARRAY 80 OF CHAR;
      overlapped,bool : BOOLEAN;

  BEGIN
    actauto:=0;
    lastpicx:=0; (* Always contains right edge of tick *)
    WHILE actauto<=LEN(auto^)-1 DO
      overlapped:=FALSE;
      picx:=MIN(LONGINT);
      xpos:=ruler.xmin;
      WHILE xpos<=ruler.xmax DO
        lastpicx:=picx;
        bool:=tt.RealToString(xpos,str,FALSE);
        picwi:=g.TextLength(plotinfo.rast,str,st.Length(str));
        plotinfo.CMToPic(xpos,0,picx,picy);
        IF picx-(picwi DIV 2)-plotinfo.rast.txHeight<lastpicx THEN
          overlapped:=TRUE;
          xpos:=ruler.xmax;
        END;
        xpos:=xpos+auto[actauto];
      END;
      IF ~overlapped THEN RETURN auto[actauto]; END;
      INC(actauto);
    END;
    RETURN auto[LEN(auto^)-1];
  END GetXStep;

  PROCEDURE GetYStep():LONGREAL;

  VAR picx,picy : LONGINT;
      actauto   : INTEGER;

  BEGIN
    actauto:=0;
    WHILE actauto<=LEN(auto^)-1 DO
      plotinfo.CMToPic(0,auto[actauto],picx,picy);
      IF picy>plotinfo.rast.txHeight*1.5 THEN
        RETURN auto[actauto];
      END;
      INC(actauto);
    END;
    RETURN auto[LEN(auto^)-1];
  END GetYStep;

  PROCEDURE GetXMaxWidth():LONGINT;

  VAR ypos        : LONGREAL;
      picwi,piche,
      maxwi       : LONGINT;
      str         : ARRAY 80 OF CHAR;
      bool        : BOOLEAN;

  BEGIN
    maxwi:=0;
    ypos:=ruler.ymin;
    WHILE ypos<=ruler.ymax DO
      bool:=tt.RealToString(ypos,str,FALSE);
      picwi:=g.TextLength(plotinfo.rast,str,st.Length(str));
      IF picwi>maxwi THEN maxwi:=picwi; END;
      ypos:=ypos+ruler.stepy;
    END;
    RETURN maxwi;
  END GetXMaxWidth;

BEGIN
  ruler.stepx:=GetXStep();
  ruler.stepy:=GetYStep();
  ruler.horizheight:=plotinfo.rast.txHeight*2;
  ruler.vertwidth:=GetXMaxWidth()+plotinfo.rast.txHeight;
  plotinfo.CMToPic(ruler.xmax-ruler.xmin,ruler.ymax-ruler.ymin,ruler.picwidth,ruler.picheight);

  IF ruler.horizrast#NIL THEN lrp.FreeLayerRast(ruler.horizrast);
                              ruler.horizrast:=NIL; END;
  IF ruler.vertrast#NIL THEN lrp.FreeLayerRast(ruler.vertrast);
                             ruler.vertrast:=NIL; END;
  ruler.horizrast:=lrp.AllocLayerRast(SHORT(ruler.picwidth+1),SHORT(ruler.horizheight),lg.screen.rastPort.bitMap.depth);
  ruler.vertrast:=lrp.AllocLayerRast(SHORT(ruler.vertwidth),SHORT(ruler.picheight+1),lg.screen.rastPort.bitMap.depth);

(* Refreshing horizontal *)

  IF ruler.horizrast#NIL THEN
    g.SetAPen(ruler.horizrast.rast,gmb.standard.textcol);
  
    xpos:=ruler.xmin;
    WHILE xpos<=ruler.xmax DO
      plotinfo.CMToPic(xpos,0,picx,picy);
      picy:=plotinfo.rast.txBaseline+3;
      tt.PrintMid(SHORT(picx),SHORT(picy),xpos,ruler.horizrast.rast);
      g.Move(ruler.horizrast.rast,SHORT(picx),plotinfo.rast.txHeight+4);
      g.Draw(ruler.horizrast.rast,SHORT(picx),SHORT(ruler.horizheight-1));
  
  (* Plotting extra ticks *)
  
      plotinfo.CMToPic(xpos+ruler.stepx/2,0,picx,picy);
      g.Move(ruler.horizrast.rast,SHORT(picx),SHORT(SHORT(plotinfo.rast.txHeight*1.3))+4);
      g.Draw(ruler.horizrast.rast,SHORT(picx),SHORT(ruler.horizheight-1));
  
      plotinfo.CMToPic(xpos+ruler.stepx/4,0,picx,picy);
      g.Move(ruler.horizrast.rast,SHORT(picx),SHORT(SHORT(plotinfo.rast.txHeight*1.5))+4);
      g.Draw(ruler.horizrast.rast,SHORT(picx),SHORT(ruler.horizheight-1));
      plotinfo.CMToPic(xpos+3*ruler.stepx/4,0,picx,picy);
      g.Move(ruler.horizrast.rast,SHORT(picx),SHORT(SHORT(plotinfo.rast.txHeight*1.5))+4);
      g.Draw(ruler.horizrast.rast,SHORT(picx),SHORT(ruler.horizheight-1));
      xpos:=xpos+ruler.stepx;
    END;
  END;

  IF ruler.vertrast#NIL THEN
  
  (* Refreshing vertical *)
  
    g.SetAPen(ruler.vertrast.rast,gmb.standard.textcol);
  
    ypos:=ruler.ymin;
    WHILE ypos<=ruler.ymax DO
      plotinfo.CMToPic(0,ypos,picx,picy);
      picx:=4;
      tt.PrintRight(SHORT(ruler.vertwidth-5-(plotinfo.rast.txHeight DIV 2)),SHORT(picy+(plotinfo.rast.txBaseline DIV 2)),ypos,ruler.vertrast.rast);
      g.Move(ruler.vertrast.rast,SHORT(ruler.vertwidth-1),SHORT(picy));
      g.Draw(ruler.vertrast.rast,SHORT(ruler.vertwidth-1-(plotinfo.rast.txHeight DIV 2)),SHORT(picy));
  
  (* Plotting extra ticks *)
  
      plotinfo.CMToPic(0,ypos+ruler.stepy/2,picx,picy);
      g.Move(ruler.vertrast.rast,SHORT(ruler.vertwidth-1),SHORT(picy));
      g.Draw(ruler.vertrast.rast,SHORT(ruler.vertwidth-1-(plotinfo.rast.txHeight DIV 3)),SHORT(picy));
  
      plotinfo.CMToPic(0,ypos+ruler.stepy/4,picx,picy);
      g.Move(ruler.vertrast.rast,SHORT(ruler.vertwidth-1),SHORT(picy));
      g.Draw(ruler.vertrast.rast,SHORT(ruler.vertwidth-1-(plotinfo.rast.txHeight DIV 4)),SHORT(picy));
      plotinfo.CMToPic(0,ypos+3*ruler.stepy/4,picx,picy);
      g.Move(ruler.vertrast.rast,SHORT(ruler.vertwidth-1),SHORT(picy));
      g.Draw(ruler.vertrast.rast,SHORT(ruler.vertwidth-1-(plotinfo.rast.txHeight DIV 4)),SHORT(picy));
  
      ypos:=ypos+ruler.stepy;
    END;
  END;
  
(*  horizheight:=ruler.rast.txHeight*2;
  vertwidth:=ruler.rast.txHeight*3;
  ruler.coordobj.CMToPic(ruler.xmax-ruler.xmin,ruler.ymax-ruler.ymin,picwidth,picheight);
  IF (picwidth#ruler.picwidth) OR (picheight#ruler.picheight) OR (vertwidth#ruler.vertwidth) OR (horizheight#ruler.horizheight) THEN
    ruler.picwidth:=picwidth;
    ruler.picheight:=picheight;
    ruler.horizheight:=horizheight;
    ruler.vertwidth:=vertwidth;
    IF ruler.horizrast#NIL THEN lrp.FreeLayerRast(ruler.horizrast);
                                ruler.horizrast:=NIL; END;
    IF ruler.vertrast#NIL THEN lrp.FreeLayerRast(ruler.vertrast);
                               ruler.vertrast:=NIL; END;
    ruler.horizrast:=lrp.AllocLayerRast(picwidth,horizheight,lg.screen.depth);
    ruler.vertrast:=lrp.AllocLayerRast(picheight,vertwidth,lg.screen.depth);
  END;*)
END RefreshInternal;

PROCEDURE (ruler:Ruler) Plot*(plotinfo:pi.PlotInfo);

VAR picx,picy   : LONGINT;
    picwi,piche : LONGINT;

BEGIN
  ruler.rect.SetClipRegion(plotinfo.subwind);

(*  plotinfo.CMToPic(ruler.xpos,ruler.ypos,picx,picy);*)
  picx:=plotinfo.offx; picy:=plotinfo.offy;

  picwi:=ruler.rect.width;
(*  IF picwi+picx>ruler.picwidth THEN picwi:=ruler.picwidth-picx; END;*)
  piche:=ruler.rect.height;
(*  IF piche+picy>ruler.picheight THEN piche:=ruler.picheight-picy; END;*)

  picwi:=ruler.rect.width-ruler.vertwidth;
  piche:=ruler.rect.height-ruler.horizheight;
  IF ruler.picwidth<(picwi+1) THEN picwi:=ruler.picwidth+1; END;
  IF ruler.picheight<(piche+1) THEN piche:=ruler.picheight+1; END;

(* What is what:
   picx, picy : Page offset in pixels (taken from plotinfo.offx/y)
   picwi,piche: Width/Height of displayed ruler. May be smaller than edit width, but never larger.

*)

  IF ruler.horizrast#NIL THEN
    g.ClipBlit(ruler.horizrast.rast,SHORT(picx),0,plotinfo.rast,SHORT(ruler.rect.xoff+ruler.vertwidth),ruler.rect.yoff,SHORT(picwi),SHORT(ruler.horizheight),s.VAL(s.BYTE,0C0H));
  END;
  IF ruler.vertrast#NIL THEN
    g.ClipBlit(ruler.vertrast.rast,0,SHORT(picy),plotinfo.rast,ruler.rect.xoff,SHORT(ruler.rect.yoff+ruler.horizheight),SHORT(ruler.vertwidth),SHORT(piche),s.VAL(s.BYTE,0C0H));
  END;

  gd.DrawBevelBox(plotinfo.rast,ruler.rect.xoff+ruler.vertwidth,ruler.rect.yoff,
                                picwi,ruler.horizheight,
                                        gd.bbFrameType,gd.bbftButton,
                                        gd.visualInfo,plotinfo.vinfo,
                                        u.done);
  gd.DrawBevelBox(plotinfo.rast,ruler.rect.xoff,ruler.rect.yoff+ruler.horizheight,
                                ruler.vertwidth,piche,
                                        gd.bbFrameType,gd.bbftButton,
                                        gd.visualInfo,plotinfo.vinfo,
                                        u.done);

  g.SetAPen(plotinfo.rast,0);
  IF picwi<ruler.rect.width-ruler.vertwidth THEN
    (* There's some space left to the upper ruler to clear. *)
    g.RectFill(plotinfo.rast,SHORT(ruler.rect.xoff+ruler.vertwidth+picwi),ruler.rect.yoff,ruler.rect.xoff+ruler.rect.width-1,SHORT(ruler.rect.yoff+ruler.horizheight-1));
  END;

  IF picwi<ruler.rect.width-ruler.vertwidth THEN
    g.RectFill(plotinfo.rast,ruler.rect.xoff,SHORT(ruler.rect.yoff+ruler.horizheight+piche),SHORT(ruler.rect.xoff+ruler.vertwidth-1),ruler.rect.yoff+ruler.rect.height-1);
  END;

  g.RectFill(plotinfo.rast,ruler.rect.xoff,ruler.rect.yoff,SHORT(ruler.rect.xoff+ruler.vertwidth-1),SHORT(ruler.rect.yoff+ruler.horizheight-1));
  gd.DrawBevelBox(plotinfo.rast,ruler.rect.xoff,ruler.rect.yoff,
                                ruler.vertwidth,ruler.horizheight,
                                        gd.bbFrameType,gd.bbftButton,
                                        gd.visualInfo,plotinfo.vinfo,
                                        u.done);

  ruler.rect.RemoveClipRegion(plotinfo.subwind);
END Plot;

BEGIN
  NEW(auto,10);
  auto[0]:=0.1;
  auto[1]:=0.2;
  auto[2]:=0.25;
  auto[3]:=0.5;
  auto[4]:=1;
  auto[5]:=1.5;
  auto[6]:=2;
  auto[7]:=5;
  auto[8]:=10;
  auto[9]:=20;
CLOSE
  DISPOSE(auto);
END Ruler.

