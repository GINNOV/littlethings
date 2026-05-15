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


MODULE AxisLabels;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       gd : GadTools,
       as : ASL,
       l  : LinkedLists,
       lrc: LongRealConversions,
       at : AslTools,
       tt : TextTools,
       ag : AmigaGuideTools,
       gt : GraphicsTools,
       vt : VectorTools,
       ac : AnalayCatalog,
       wm : WindowManager,
       fm : FontManager,
       fo : FontOrganizer,
       ft : FunctionTrees,
       m  : Multitasking,
       mem: MemoryManager,
       mg : MathGUI,
       dc : DisplayConversion,
       co : Coords,
       go : GraphicObjects,
       w  : Window,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       bt : BasicTypes,
       io,
       NoGuruRq;

TYPE AxisLabels * = POINTER TO AxisLabelsDesc;
     AxisLabelsDesc * = RECORD(bt.ANYDesc);
       window         * : w.Window;        (* The window this axis labels belong to. *)
       numsx *,numsy  * ,
       ticks1x*,ticks1y * ,
       ticks2x*,ticks2y * : LONGREAL;
       numsxs*,numsys * ,
       ticks1xs*,ticks1ys*,
       ticks2xs*,ticks2ys*: ARRAY 256 OF CHAR;
       color          * ,
       thickness      * ,
       pattern        * ,
       arrow          * : INTEGER;
       numsactive     * ,                  (* display numbers *)
       ticks1active   * ,                  (* display longer tick marks *)
       ticks2active   * ,                  (* display smaller tick marks *)
       active         * ,                  (* display whole axis system *)
       xnameactive    * ,                  (* display names of axis *)
       ynameactive    * : BOOLEAN;
       xname*,yname   * : ARRAY 80 OF CHAR;
       fontinfo       * : fo.FontInfo;
       font           * : fm.Font;
       auto           * : BOOLEAN;
     END;

VAR auto      : POINTER TO ARRAY OF LONGREAL;
    maxauto   : INTEGER;

PROCEDURE (labels:AxisLabels) Init*;

BEGIN
  labels.numsx:=1;
  labels.numsy:=1;
  labels.ticks1x:=0.5;
  labels.ticks1y:=0.5;
  labels.ticks2x:=0.25;
  labels.ticks2y:=0.25;
  labels.numsxs:="1";
  labels.numsys:="1";
  labels.ticks1xs:="0.5";
  labels.ticks1ys:="0.5";
  labels.ticks2xs:="0.25";
  labels.ticks2ys:="0.25";
  labels.color:=1;
  labels.pattern:=0;
  labels.thickness:=1;
  labels.arrow:=0;
  labels.numsactive:=TRUE;
  labels.ticks1active:=FALSE;
  labels.ticks2active:=FALSE;
  labels.active:=TRUE;
  labels.xnameactive:=TRUE;
  labels.ynameactive:=TRUE;
  labels.xname:="X";
  labels.yname:="Y";
  NEW(labels.fontinfo); labels.fontinfo.Init;
  labels.font:=(*labels.fontinfo.Open()*)NIL;
  labels.auto:=TRUE;
END Init;

PROCEDURE (labels:AxisLabels) Destruct*;

BEGIN
  IF labels.font#NIL THEN labels.font.Destruct; END;
  IF labels.fontinfo#NIL THEN labels.fontinfo.Destruct; END;
  DISPOSE(labels);
END Destruct;

PROCEDURE (labels:AxisLabels) BCopy*(dest:AxisLabels);

BEGIN
(*  e.CopyMemAPTR(labels,dest,SIZE(AxisLabels));*)
  dest.numsx:=labels.numsx;
  dest.numsy:=labels.numsy;
  dest.ticks1x:=labels.ticks1x;
  dest.ticks1y:=labels.ticks1y;
  dest.ticks2x:=labels.ticks2x;
  dest.ticks2y:=labels.ticks2y;
  COPY(labels.numsxs,dest.numsxs);
  COPY(labels.numsys,dest.numsys);
  COPY(labels.ticks1xs,dest.ticks1xs);
  COPY(labels.ticks1ys,dest.ticks1ys);
  COPY(labels.ticks2xs,dest.ticks2xs);
  COPY(labels.ticks2ys,dest.ticks2ys);
  dest.color:=labels.color;
  dest.thickness:=labels.thickness;
  dest.pattern:=labels.pattern;
  dest.arrow:=labels.arrow;
  dest.numsactive:=labels.numsactive;
  dest.ticks1active:=labels.ticks1active;
  dest.ticks2active:=labels.ticks2active;
  dest.active:=labels.active;
  dest.xnameactive:=labels.xnameactive;
  dest.ynameactive:=labels.ynameactive;
  COPY(labels.xname,dest.xname);
  COPY(labels.yname,dest.yname);
  labels.fontinfo.Copy(dest.fontinfo);
END BCopy;

PROCEDURE (labels:AxisLabels) AllocNew*():AxisLabels;

VAR node : AxisLabels;

BEGIN
  NEW(node);
  RETURN node;
END AllocNew;

PROCEDURE GetValueAfter(x,step:LONGREAL):LONGREAL;

BEGIN
  x:=x/step;
  RETURN SHORT(SHORT(x))*step+step;
END GetValueAfter;

PROCEDURE GetValueBefore(x,step:LONGREAL):LONGREAL;

BEGIN
  x:=x/step;
  RETURN SHORT(SHORT(x))*step-step;
END GetValueBefore;

PROCEDURE GetNextValueAfter(x,step:LONGREAL):LONGREAL;

BEGIN
  x:=x/step;
  IF SHORT(SHORT(x/step))#x/step THEN
    RETURN SHORT(SHORT(x))*step+step;
  ELSE
    RETURN x;
  END;
END GetNextValueAfter;

PROCEDURE GetNextValueBefore(x,step:LONGREAL):LONGREAL;

BEGIN
  x:=x/step;
  IF SHORT(SHORT(x/step))#x/step THEN
    RETURN SHORT(SHORT(x))*step-step;
  ELSE
    RETURN x;
  END;
END GetNextValueBefore;

PROCEDURE (labels:AxisLabels) Plot*(rast:g.RastPortPtr;coord:co.CoordSystem;rect:co.Rectangle;conv:dc.ConversionTable;dragbarplot:BOOLEAN);

VAR font        : fm.Font;
    xorig,yorig,
    xmin,xmax,
    ymin,ymax,
    real,x,y,
    stopx,stopy   : LONGREAL;
    xorigp,yorigp,
    widthp,xp,yp,
    xnamewidthp,
    ynamewidthp,
    txBaseline,
    txHeight      : INTEGER;
    stdpicx,
    stdpicy,
    linex,liney   : INTEGER;
    str           : ARRAY 80 OF CHAR;
    layoutplot,
    bool          : BOOLEAN;

PROCEDURE SetOrigin;

(* Sets the new origin if (0|0) is not visible in the axis system. *)

BEGIN
  io.WriteString("SetOrigin1\n");
  WITH coord: co.CartesianSystem DO
    xorig:=0;
    yorig:=0;
    IF coord.xmin>=0 THEN
      xorig:=GetValueAfter(coord.xmin,labels.numsx);
    END;
  io.WriteString("SetOrigin2\n");
    IF coord.ymin>=0 THEN
      yorig:=GetValueAfter(coord.ymin,labels.numsy);
      coord.WorldToPic(rect,xorig,yorig,xorigp,yorigp);
  
      WHILE yorigp+txHeight>rect.height+rect.yoff DO
        yorig:=GetValueAfter(yorig,labels.numsy);
        coord.WorldToPic(rect,xorig,yorig,xorigp,yorigp);
      END;
    END;
  io.WriteString("SetOrigin3\n");
    IF coord.xmax<=0 THEN
      xorig:=GetValueBefore(coord.xmax,labels.numsx);
    END;
  io.WriteString("SetOrigin4\n");
    IF coord.ymax<=0 THEN
      yorig:=GetValueBefore(coord.ymax,labels.numsy);
      coord.WorldToPic(rect,xorig,yorig,xorigp,yorigp);
  
      WHILE yorigp-txBaseline<rect.yoff DO
        yorig:=GetValueAfter(yorig,labels.numsy);
        coord.WorldToPic(rect,xorig,yorig,xorigp,yorigp);
      END;
    END;
  io.WriteString("SetOrigin5\n");
    coord.WorldToPic(rect,xorig,yorig,xorigp,yorigp);
  
    LOOP
      bool:=tt.RealToString(xorig,str,FALSE);
      real:=labels.font.TextWidthPix(rast,s.ADR(str));
      widthp:=SHORT(SHORT(SHORT(real)));
      IF xorigp-(widthp DIV 2)<rect.xoff THEN
        xorig:=GetValueAfter(xorig,labels.numsx);
        coord.WorldToPic(rect,xorig,yorig,xorigp,yorigp);
      ELSE
        EXIT;
      END;
    END;
    coord.WorldToPic(rect,xorig,yorig,xorigp,yorigp);
  io.WriteString("SetOrigin6\n");
  END;
END SetOrigin;

PROCEDURE DrawLine(rast:g.RastPortPtr;x1,y1,x2,y2,width:INTEGER);

VAR x : INTEGER;

BEGIN
  IF width<1 THEN
    width:=1;
  END;
  IF width MOD 2=0 THEN
    INC(width);
  END;
  IF x1-x2=0 THEN
    x:=x1-(width DIV 2)-1;
    WHILE x<x1+width DIV 2 DO
      INC(x);
      g.Move(rast,x,y1);
      g.Draw(rast,x,y2);
    END;
  ELSE
    x:=y1-(width DIV 2)-1;
    WHILE x<y1+width DIV 2 DO
      INC(x);
      g.Move(rast,x1,x);
      g.Draw(rast,x2,x);
    END;
  END;
END DrawLine;

BEGIN
  IF conv.labelsconv#NIL THEN conv:=conv.labelsconv; END;
  IF rast#labels.window.rast THEN layoutplot:=TRUE;
                             ELSE layoutplot:=FALSE; END;
(*  rast:=wind.rPort;*)
  WITH coord: co.CartesianSystem DO
    IF labels.active THEN

(* Font stuff *)

      IF (labels.fontinfo.changed) OR (labels.font=NIL) THEN
        IF labels.font#NIL THEN labels.font.Destruct; labels.font:=NIL; END;
        labels.font:=labels.fontinfo.Open();
      END;
      font:=labels.font;
      font:=conv.GetFont(labels.font);

      stdpicx:=conv.GetStdPicX();
      stdpicy:=conv.GetStdPicY();
      linex:=conv.GetThicknessX(labels.thickness);
      liney:=conv.GetThicknessY(labels.thickness);
      IF stdpicx MOD 2=0 THEN
        INC(stdpicx);
      END;
      IF stdpicy MOD 2=0 THEN
        INC(stdpicy);
      END;

      bool:=font.Get64(fm.txHeight,real); txHeight:=SHORT(SHORT(SHORT(real)));
      bool:=font.Get64(fm.txBaseline,real); txBaseline:=SHORT(SHORT(SHORT(real)));

      g.SetDrMd(rast,g.jam1);
      gt.SetLinePattern(rast,go.lines[labels.pattern]);
      g.SetAPen(rast,conv.GetColor(labels.color,dc.standardType));

      SetOrigin;

(* Plotting axes *)

      IF liney=1 THEN
        g.Move(rast,rect.xoff,yorigp);
        g.Draw(rast,rect.xoff+rect.width-1,yorigp);
      ELSE
        g.RectFill(rast,rect.xoff,yorigp-(liney DIV 2),rect.xoff+rect.width-1,yorigp-(liney DIV 2)+liney);
      END;
      vt.DrawVectorObject(rast,go.arrows[labels.arrow],rect.xoff+rect.width-1,yorigp,stdpicx,stdpicy,0,1,1);
      IF labels.xnameactive THEN
        xp:=rect.xoff+rect.width-3;
        yp:=yorigp+SHORT(SHORT(SHORT(go.arrows[labels.arrow](vt.VectorObject).maxheight*stdpicy)/2+0.5))+SHORT(SHORT(txHeight*1/20+0.5))+1+txBaseline;
        font.PrintRight(rast,xp,yp,s.ADR(labels.xname));
        xnamewidthp:=SHORT(SHORT(SHORT(font.TextWidthPix(rast,s.ADR(labels.xname)))));
      END;

      IF linex=1 THEN
        g.Move(rast,xorigp,rect.yoff+rect.height-1);
        g.Draw(rast,xorigp,rect.yoff);
      ELSE
        g.RectFill(rast,xorigp-(linex DIV 2),rect.yoff,xorigp-(linex DIV 2)+linex,rect.yoff+rect.height-1);
      END;
      vt.DrawVectorObject(rast,go.arrows[labels.arrow],xorigp,rect.yoff,stdpicx,stdpicy,90,1,1);
      IF labels.ynameactive THEN

(* Don't forget to change values below in the program text if you change
   one of the scaling values (e.g. txHeight*1.1 to txHeight*1.2) *)

        xp:=xorigp-SHORT(SHORT(SHORT((go.arrows[labels.arrow](vt.VectorObject).maxheight*stdpicx)/2+0.5)));
        yp:=SHORT(SHORT(txHeight*1.1+0.5))+rect.yoff; (* Was: txHeight*1.2 (instead of txHeight*1.1) *)
        font.PrintRight(rast,xp,yp,s.ADR(labels.yname));
        ynamewidthp:=SHORT(SHORT(SHORT(font.TextWidthPix(rast,s.ADR(labels.yname)))));
      END;

      gt.SetFullPattern(rast);

      IF ~dragbarplot THEN

  (* Plotting nums ticks *)
  
        IF labels.numsactive THEN
          IF coord.xmin>0 THEN (* Pos. x-axis. *)
            x:=GetNextValueAfter(coord.xmin,labels.numsx);
          ELSE
            x:=0;
          END;
          x:=x-labels.numsx;
          WHILE x<=coord.xmax-labels.numsx DO
            x:=x+labels.numsx;
            coord.WorldToPic(rect,x,yorig,xp,yp);
            bool:=tt.RealToString(x,str,FALSE);
  
            real:=font.TextWidthPix(rast,s.ADR(str)); widthp:=SHORT(SHORT(SHORT(real)));
            IF ((xp+(widthp DIV 2)<rect.xoff+rect.width-xnamewidthp-txHeight) AND (labels.xnameactive)) OR NOT(labels.xnameactive) THEN
              font.PrintMid(rast,xp,yorigp+2*liney+txBaseline+1+SHORT(SHORT(txHeight*1/20+0.5)),s.ADR(str));
              DrawLine(rast,xp,yorigp-2*liney,xp,yorigp+2*liney,SHORT(SHORT(linex/2+0.5)));
              stopx:=x;
            END;
          END;
  
          IF coord.xmax<0 THEN (* Neg. x-axis. *)
            x:=GetNextValueBefore(coord.xmax,labels.numsx);
          ELSE
            x:=0;
          END;
          x:=x+labels.numsx;
          WHILE x>=coord.xmin+labels.numsx DO
            x:=x-labels.numsx;
            coord.WorldToPic(rect,x,yorig,xp,yp);
            bool:=tt.RealToString(x,str,FALSE);
  
            font.PrintMid(rast,xp,yorigp+2*liney+txBaseline+1+SHORT(SHORT(txHeight*1/20+0.5)),s.ADR(str));
            DrawLine(rast,xp,yorigp-2*liney,xp,yorigp+2*liney,SHORT(SHORT(linex/2+0.5)));
          END;
  
          IF coord.ymin>0 THEN (* Pos. y-axis *)
            y:=GetNextValueAfter(coord.ymin,labels.numsy);
          ELSE
            y:=0;
          END;
          (*y:=y-labels.yspace;*)
          WHILE y<=coord.ymax-labels.numsy DO
            y:=y+labels.numsy;
            coord.WorldToPic(rect,xorig,y,xp,yp);
            bool:=tt.RealToString(y,str,FALSE);
  
            IF (NOT(yp<rect.yoff+2*txHeight*1.1) AND (labels.ynameactive)) OR NOT(labels.ynameactive ) THEN
              font.PrintRight(rast,xorigp-2*linex-1,yp+(txBaseline DIV 2),s.ADR(str));
              DrawLine(rast,xorigp-2*linex,yp,xorigp+2*linex,yp,SHORT(SHORT(liney/2+0.5)));
              stopy:=y;
            END;
          END;
  
          IF coord.ymax<0 THEN
            y:=GetNextValueBefore(coord.ymax,labels.numsy);
          ELSE
            y:=0;
          END;
          (*y:=y+labels.yspace;*)
          WHILE y>=coord.ymin+labels.numsy DO
            y:=y-labels.numsy;
            coord.WorldToPic(rect,xorig,y,xp,yp);
            bool:=tt.RealToString(y,str,FALSE);
  
            font.PrintRight(rast,xorigp-2*linex-1,yp+(txBaseline DIV 2),s.ADR(str));
            DrawLine(rast,xorigp-2*linex,yp,xorigp+2*linex,yp,SHORT(SHORT(liney/2+0.5)));
          END;
        END;
  
  (* Plotting ticks 1 *)
  
        IF labels.ticks1active THEN
          IF coord.xmin>0 THEN (* Pos. x-axis *)
            x:=GetNextValueAfter(coord.xmin,labels.numsx);
          ELSE
            x:=0;
          END;
          x:=x-labels.ticks1x;
          WHILE (x<=coord.xmax-labels.ticks1x) AND (x<=stopx) DO
            x:=x+labels.ticks1x;
            coord.WorldToPic(rect,x,yorig,xp,yp);
  
            DrawLine(rast,xp,yorigp-liney,xp,yorigp+liney,linex DIV 2);
          END;
  
          IF coord.xmax<0 THEN (* Neg. y-axis *)
            x:=GetNextValueBefore(coord.xmax,labels.numsx);
          ELSE
            x:=0;
          END;
          x:=x+labels.ticks1x;
          WHILE x>=coord.xmin+labels.ticks1x DO
            x:=x-labels.ticks1x;
            coord.WorldToPic(rect,x,yorig,xp,yp);
            DrawLine(rast,xp,yorigp-liney,xp,yorigp+liney,linex DIV 2);
          END;
  
          IF coord.ymin>0 THEN (* Pos. y-axis *)
            y:=GetNextValueAfter(coord.ymin,labels.numsy);
          ELSE
            y:=0;
          END;
          (*y:=y-labels.yspace;*)
          WHILE (y<=coord.ymax-labels.ticks1y) AND (y<=stopy) DO
            y:=y+labels.ticks1y;
            coord.WorldToPic(rect,xorig,y,xp,yp);
            DrawLine(rast,xorigp-linex,yp,xorigp+linex,yp,liney DIV 2);
          END;
  
          IF coord.ymax<0 THEN (* Neg. y-axis *)
            y:=GetNextValueBefore(coord.ymax,labels.numsy);
          ELSE
            y:=0;
          END;
          (*y:=y+labels.yspace;*)
          WHILE y>=coord.ymin+labels.ticks1y DO
            y:=y-labels.ticks1y;
            coord.WorldToPic(rect,xorig,y,xp,yp);
            DrawLine(rast,xorigp-linex,yp,xorigp+linex,yp,liney DIV 2);
          END;
        END;
  
  (* Plotting ticks 2 *)
  
        IF labels.ticks2active THEN
          IF coord.xmin>0 THEN (* Pos. x-axis *)
            x:=GetNextValueAfter(coord.xmin,labels.numsx);
          ELSE
            x:=0;
          END;
          x:=x-labels.ticks2x;
          WHILE (x<=coord.xmax-labels.ticks2x) AND (x<=stopx) DO
            x:=x+labels.ticks2x;
            coord.WorldToPic(rect,x,yorig,xp,yp);
  
            DrawLine(rast,xp,yorigp,xp,yorigp+liney,linex DIV 2);
          END;
  
          IF coord.xmax<0 THEN (* Neg. y-axis *)
            x:=GetNextValueBefore(coord.xmax,labels.numsx);
          ELSE
            x:=0;
          END;
          x:=x+labels.ticks2x;
          WHILE x>=coord.xmin+labels.ticks2x DO
            x:=x-labels.ticks2x;
            coord.WorldToPic(rect,x,yorig,xp,yp);
            DrawLine(rast,xp,yorigp,xp,yorigp+liney,linex DIV 2);
          END;
  
          IF coord.ymin>0 THEN (* Pos. y-axis *)
            y:=GetNextValueAfter(coord.ymin,labels.numsy);
          ELSE
            y:=0;
          END;
          (*y:=y-labels.yspace;*)
          WHILE (y<=coord.ymax-labels.ticks2y) AND (y<=stopy) DO
            y:=y+labels.ticks2y;
            coord.WorldToPic(rect,xorig,y,xp,yp);
            DrawLine(rast,xorigp-linex,yp,xorigp,yp,liney DIV 2);
          END;
  
          IF coord.ymax<0 THEN (* Neg. y-axis *)
            y:=GetNextValueBefore(coord.ymax,labels.numsy);
          ELSE
            y:=0;
          END;
          (*y:=y+labels.yspace;*)
          WHILE y>=coord.ymin+labels.ticks2y DO
            y:=y-labels.ticks2y;
            coord.WorldToPic(rect,xorig,y,xp,yp);
            DrawLine(rast,xorigp-linex,yp,xorigp,yp,liney DIV 2);
          END;
        END;
      END;

      IF (font#NIL) & (font#labels.font) THEN font.Destruct; END;
      gt.FreeRastPortNode(rast);
    END;
  ELSE
  END;
END Plot;

PROCEDURE (labels:AxisLabels) Auto*(rast:g.RastPortPtr;coord:co.CoordSystem;rect:co.Rectangle);

VAR max : INTEGER;
    numsx,
    numsy,
    marksx,
    marksy,
    hervx,
    hervy,
    real : REAL;
    str  : ARRAY 20 OF CHAR;
    bool : BOOLEAN;
    i    : INTEGER;
    font : g.TextFontPtr;
    mask,
    style: SHORTSET;
    txHeight : LONGINT;
    lreal    : LONGREAL;

PROCEDURE CheckSchneid(nums:LONGREAL):BOOLEAN;

VAR ret   : BOOLEAN;
    r     : LONGREAL;
    px,py,
    gx,gy : INTEGER;
    wi,
    maxwi : INTEGER;
    str   : ARRAY 20 OF CHAR;
    bool  : BOOLEAN;
    lpx,
    dist  : REAL;

BEGIN
  WITH coord: co.CartesianSystem DO
    ret:=FALSE;
    maxwi:=0;
    r:=coord.xmax-2*nums;
    lpx:=0;
    dist:=0;
    r:=r-nums;
    WHILE r<=coord.xmax-nums DO
      r:=r+nums;
      lpx:=px;
      coord.WorldToPic(rect,r,0,px,py);
      dist:=px-lpx;
      IF NOT((r>coord.xmax-labels.numsx) AND labels.xnameactive) THEN
        bool:=lrc.RealToString(r,str,7,4,FALSE);
        tt.Clear(str);
        wi:=SHORT(SHORT(SHORT(labels.font.TextWidthPix(rast,s.ADR(str)))));
        IF wi>maxwi THEN
          maxwi:=wi;
          IF maxwi>=dist THEN
            r:=coord.xmax;
          END;
        END;
      END;
    END;
    r:=coord.xmin+2*nums;
    r:=r+nums;
    WHILE r>=coord.xmin+nums DO
      r:=r-nums;
      coord.WorldToPic(rect,r,0,px,py);
      bool:=lrc.RealToString(r,str,7,4,FALSE);
      tt.Clear(str);
      wi:=SHORT(SHORT(SHORT(labels.font.TextWidthPix(rast,s.ADR(str)))));
      IF wi>maxwi THEN
        maxwi:=wi;
        IF maxwi>=dist THEN
          r:=coord.xmin;
        END;
      END;
    END;
    IF dist<=maxwi THEN
      ret:=TRUE;
    END;
  END;
  RETURN ret;
END CheckSchneid;

BEGIN
  IF (labels.fontinfo.changed) OR (labels.font=NIL) THEN
    IF labels.font#NIL THEN labels.font.Destruct; labels.font:=NIL; END;
    labels.font:=labels.fontinfo.Open();
  END;
  WITH coord: co.CartesianSystem DO
    IF labels.font#NIL THEN
      bool:=labels.font.Get64(fm.txHeight,lreal); txHeight:=SHORT(SHORT(lreal));
    ELSE
      txHeight:=8;
    END;
  (*  font:=gt.SetFont(node(s1.Fenster).wind.rPort,s.ADR(node(s1.Fenster).scale.attr));
    mask:=g.AskSoftStyle(node(s1.Fenster).wind.rPort);
    style:=g.SetSoftStyle(node(s1.Fenster).wind.rPort,node(s1.Fenster).scale.attr.style,mask);*)
    i:=-1;
    LOOP
      INC(i);
      IF i>maxauto THEN
        i:=maxauto;
        EXIT;
      END;
      IF NOT(CheckSchneid(auto[i])) THEN
        EXIT;
      END;
    END;
    labels.numsx:=auto[i];
    IF labels.ticks1active THEN
      labels.ticks1x:=auto[i]/2;
    END;
    IF labels.ticks2active THEN
      labels.ticks2x:=auto[i]/4;
    END;

    real:=SHORT(rect.height/(ABS(coord.ymin)+ABS(coord.ymax)));
    i:=-1;
    LOOP
      INC(i);
      IF i>maxauto THEN
        i:=maxauto;
        EXIT;
      END;
      IF real*auto[i]/2>=txHeight+2 THEN  (* "/2" to prevent labels from being too close together. *)
        EXIT;
      END;
    END;
    labels.numsy:=auto[i];
    bool:=lrc.RealToString(labels.numsx,labels.numsxs,7,7,FALSE);
    tt.Clear(labels.numsxs);
    bool:=lrc.RealToString(labels.numsy,labels.numsys,7,7,FALSE);
    tt.Clear(labels.numsys);
    IF labels.ticks1active THEN
      labels.ticks1y:=auto[i]/2;
      bool:=lrc.RealToString(labels.ticks1x,labels.ticks1xs,7,7,FALSE);
      tt.Clear(labels.ticks1xs);
      bool:=lrc.RealToString(labels.ticks1y,labels.ticks1ys,7,7,FALSE);
      tt.Clear(labels.ticks1ys);
    END;
    IF labels.ticks2active THEN
      labels.ticks2y:=auto[i]/4;
      bool:=lrc.RealToString(labels.ticks2x,labels.ticks2xs,7,7,FALSE);
      tt.Clear(labels.ticks2xs);
      bool:=lrc.RealToString(labels.ticks2y,labels.ticks2ys,7,7,FALSE);
      tt.Clear(labels.ticks2ys);
    END;
  (*  mask:=g.AskSoftStyle(node(s1.Fenster).wind.rPort);
    style:=g.SetSoftStyle(node(s1.Fenster).wind.rPort,SHORTSET{},mask);
    gt.CloseFont(font);*)
  END;
END Auto;

(*PROCEDURE PlotScale*(p:s1.FensterPtr);

VAR font  : g.TextFontPtr;
    mask,
    style : SHORTSET;

BEGIN
  font:=gt.SetFont(p.wind.rPort,s.ADR(p.scale.attr));
  mask:=g.AskSoftStyle(p.wind.rPort);
  style:=g.SetSoftStyle(p.wind.rPort,p.scale.attr.style,mask);
  g.SetAPen(p.wind.rPort,p.scale.col);
  RawPlotScale(p.wind.rPort,p,p.inx,p.iny,p.width,p.height,p.scale.width,p.scale.width,s1.stdpicx,s1.stdpicy);
  mask:=g.AskSoftStyle(p.wind.rPort);
  style:=g.SetSoftStyle(p.wind.rPort,SHORTSET{},mask);
  gt.CloseFont(font);
END PlotScale;*)

VAR axislabelswind * : wm.Window;

PROCEDURE (labels:AxisLabels) Change*(labelstask:m.Task):BOOLEAN;

VAR subwind         : wm.SubWindow;
    wind            : I.WindowPtr;
    rast            : g.RastPortPtr;
    root            : gmb.Root;
    active,
    numsactive,
    ticks1active,
    ticks2active,
    xnameactive,
    ynameactive     : gmo.CheckboxGadget;
    xnums,ynums,
    xticks1,yticks1,
    xticks2,yticks2,
    xname,yname     : gmo.StringGadget;
    font            : gmo.BooleanGadget;
    palette         : gmo.PaletteGadget;
    pattern,
    thickness,
    arrow           : gmo.SelectBox;
    gadobj          : gmb.Object;
    glist           : I.GadgetPtr;
    mes             : I.IntuiMessagePtr;
    msg             : m.Message;
    savelabels      : AxisLabels;
    class           : LONGSET;
    depth           : INTEGER;
    bool,ret,
    didchange       : BOOLEAN;


  PROCEDURE SetData;
  
  BEGIN
    active.Check(labels.active);
    numsactive.Check(labels.numsactive);
    ticks1active.Check(labels.ticks1active);
    ticks2active.Check(labels.ticks2active);
    xnameactive.Check(labels.xnameactive);
    ynameactive.Check(labels.ynameactive);
    xnums.SetString(labels.numsxs);
    ynums.SetString(labels.numsys);
    xticks1.SetString(labels.ticks1xs);
    yticks1.SetString(labels.ticks1ys);
    xticks2.SetString(labels.ticks2xs);
    yticks2.SetString(labels.ticks2ys);
    xname.SetString(labels.xname);
    yname.SetString(labels.yname);
    palette.SetValue(labels.color);
    pattern.SetValue(labels.pattern);
    io.WriteString("Thickness: ");
    io.WriteInt(labels.thickness,7);
    io.WriteLn;
    thickness.SetValue(labels.thickness-1);
    arrow.SetValue(labels.arrow);
  END SetData;
  
  PROCEDURE GetInput;
  
  BEGIN
    labels.active:=active.Checked();
    labels.numsactive:=numsactive.Checked();
    labels.ticks1active:=ticks1active.Checked();
    labels.ticks2active:=ticks2active.Checked();
    labels.xnameactive:=xnameactive.Checked();
    labels.ynameactive:=ynameactive.Checked();
    xnums.GetString(labels.numsxs);
    ynums.GetString(labels.numsys);
    xticks1.GetString(labels.ticks1xs);
    yticks1.GetString(labels.ticks1ys);
    xticks2.GetString(labels.ticks2xs);
    yticks2.GetString(labels.ticks2ys);
    xname.GetString(labels.xname);
    yname.GetString(labels.yname);
    labels.color:=SHORT(palette.GetValue());
    labels.pattern:=SHORT(pattern.GetValue());
    labels.thickness:=SHORT(thickness.GetValue()+1);
    labels.arrow:=SHORT(arrow.GetValue());

    labels.numsx:=ft.ExpressionToReal(labels.numsxs);
    labels.numsy:=ft.ExpressionToReal(labels.numsxs);
    labels.ticks1x:=ft.ExpressionToReal(labels.ticks1xs);
    labels.ticks1y:=ft.ExpressionToReal(labels.ticks1ys);
    labels.ticks2x:=ft.ExpressionToReal(labels.ticks2xs);
    labels.ticks2y:=ft.ExpressionToReal(labels.ticks2ys);
  END GetInput;
  
BEGIN
  NEW(mes);
  ret:=FALSE;
  IF axislabelswind=NIL THEN
    axislabelswind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.Grid),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=axislabelswind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.horizBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    depth:=s.LSH(1,mg.screenmode.depth); IF depth>16 THEN depth:=16; END;
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      active:=gmo.SetCheckboxGadget(ac.GetString(ac.AxisSystemOn),labels.active);
      gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.Scale));
        numsactive:=gmo.SetCheckboxGadget(ac.GetString(ac.Values),labels.numsactive);
        gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
          xnums:=gmo.SetStringGadget(s.ADR("x"),255,gmo.realType);
          xnums.SetMinVisible(5);
          ynums:=gmo.SetStringGadget(s.ADR("y"),255,gmo.realType);
          ynums.SetMinVisible(5);
        gmb.EndBox;
        ticks1active:=gmo.SetCheckboxGadget(ac.GetString(ac.Ticks1),labels.ticks1active);
        gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
          xticks1:=gmo.SetStringGadget(s.ADR("x"),255,gmo.realType);
          xticks1.SetMinVisible(5);
          yticks1:=gmo.SetStringGadget(s.ADR("y"),255,gmo.realType);
          yticks1.SetMinVisible(5);
        gmb.EndBox;
        ticks2active:=gmo.SetCheckboxGadget(ac.GetString(ac.Ticks2),labels.ticks2active);
        gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
          xticks2:=gmo.SetStringGadget(s.ADR("x"),255,gmo.realType);
          xticks2.SetMinVisible(5);
          yticks2:=gmo.SetStringGadget(s.ADR("y"),255,gmo.realType);
          yticks2.SetMinVisible(5);
        gmb.EndBox;
        gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
          xname:=gmo.SetStringGadget(ac.GetString(ac.XAxisLabel),79,gmo.stringType);
          xname.SetMinVisible(5);
          xnameactive:=gmo.SetCheckboxGadget(NIL,labels.xnameactive);
        gmb.EndBox;
        gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
          yname:=gmo.SetStringGadget(ac.GetString(ac.YAxisLabel),79,gmo.stringType);
          yname.SetMinVisible(5);
          ynameactive:=gmo.SetCheckboxGadget(NIL,labels.ynameactive);
        gmb.EndBox;
        font:=gmo.SetBooleanGadget(ac.GetString(ac.Font),FALSE);
      gmb.EndBox;
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.AxisRealDesign));
      palette:=gmo.SetPaletteGadget(ac.GetString(ac.Color),mg.screenmode.depth,depth,labels.color);
      pattern:=gmo.SetSelectBox(ac.GetString(ac.LinePattern),10,labels.pattern,5,2,16,mg.window.rPort.txHeight*3 DIV 8,-1,gmo.horizOrient,go.PlotPatternLine);
      thickness:=gmo.SetSelectBox(ac.GetString(ac.LineThickness),5,labels.thickness-1,2,3,16*4,mg.window.rPort.txHeight*3 DIV 5,-1,gmo.vertOrient,go.PlotThicknessLine);
      arrow:=gmo.SetSelectBox(ac.GetString(ac.Arrow),10,labels.arrow,5,2,20,11,-1,gmo.horizOrient,go.PlotArrow);
    gmb.EndBox;
  glist:=root.EndRoot();

  root.Init;

  xnums.SetString(labels.numsxs);
  ynums.SetString(labels.numsys);
  xticks1.SetString(labels.ticks1xs);
  yticks1.SetString(labels.ticks1ys);
  xticks2.SetString(labels.ticks2xs);
  yticks2.SetString(labels.ticks2ys);
  xname.SetString(labels.xname);
  yname.SetString(labels.yname);

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;
    xnums.Activate;

    savelabels:=NIL;
    NEW(savelabels); savelabels.Init; labels.BCopy(savelabels);

    didchange:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF labelstask.msgsig IN class THEN
        REPEAT
          msg:=labelstask.ReceiveMsg();
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
                xnums.Activate;
              ELSE
                msg.Reply;
                EXIT;
              END;
            ELSIF msg.type=m.msgNodeChanged THEN
              SetData;
            ELSIF msg.type=m.msgActivate THEN
              subwind.ToFront;
            ELSIF msg.type=m.msgNewPriority THEN
              labelstask.SetPriority(m.taskdata.requesterpri);
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
            labels.window.changed:=TRUE;
            labels.window.SendNewMsg(m.msgNodeChanged,NIL);
  
  (*          p.autoskalascale:=FALSE;
            COPY(attr.name^,p.scale.attr.name^);
            p.scale.attr.ySize:=attr.ySize;
            p.scale.attr.style:=attr.style;*)
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            savelabels.BCopy(labels);
  
            IF didchange THEN
              labels.window.changed:=TRUE;
              labels.window.SendNewMsg(m.msgNodeChanged,NIL);
            END;
  
            ret:=FALSE;
            EXIT;
          ELSIF mes.iAddress=font.gadget THEN
            bool:=labels.fontinfo.SelectFont(labelstask,mg.screen);
(*            bool:=at.FontRequest(fontrequest,ac.GetString(ac.SelectAxisLabelsFont),wind,s.ADR(labels.attr),at.nocols,at.nocols);*)
            IF bool THEN
              didchange:=TRUE;
              labels.window.changed:=TRUE;
              labels.window.SendNewMsg(m.msgNodeChanged,NIL);
            END;
          ELSIF NOT(mes.iAddress=root.help) THEN
            GetInput; didchange:=TRUE;
            labels.window.changed:=TRUE;
            labels.window.SendNewMsg(m.msgNodeChanged,NIL);
          END;
        END;
        IF ((I.gadgetUp IN mes.class) AND (mes.iAddress=root.help)) OR ((I.rawKey IN mes.class) AND (mes.code=95)) THEN
          ag.ShowFile(ag.guidename,"changeaxes",wind);
        END;
      UNTIL mes.class=LONGSET{};
    END;

(*    IF fontrequest#NIL THEN
      as.FreeAslRequest(fontrequest);
    END;
    e.FreeMem(attr.name,s.SIZE(CHAR)*256);*)

    IF savelabels#NIL THEN savelabels.Destruct; END;
    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  RETURN ret;
END Change;

PROCEDURE ChangeAxisLabelsTask*(labelstask:bt.ANY):bt.ANY;

VAR data : AxisLabels;
    bool : BOOLEAN;

BEGIN
  WITH labelstask: m.Task DO
    labelstask.InitCommunication;
    data:=labelstask.data(AxisLabels);
    bool:=data.Change(labelstask);
  
    data.window.RemTask(labelstask);
    labelstask.ReplyAllMessages;
    labelstask.DestructCommunication;
    mem.NodeToGarbage(labelstask);
    data.window.FreeUser(labelstask);
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END ChangeAxisLabelsTask;

BEGIN
  axislabelswind:=NIL;

  auto:=NIL;
  NEW(auto,29); maxauto:=28;
  auto[0]:=0.0001;
  auto[1]:=0.0002;
  auto[2]:=0.0005;
  auto[3]:=0.001;
  auto[4]:=0.002;
  auto[5]:=0.005;
  auto[6]:=0.01;
  auto[7]:=0.02;
  auto[8]:=0.05;
  auto[9]:=0.1;
  auto[10]:=0.2;
  auto[11]:=0.25;
  auto[12]:=0.5;
  auto[13]:=0.5;
  auto[14]:=1;
  auto[15]:=2;
  auto[16]:=3;
  auto[17]:=4;
  auto[18]:=5;
  auto[19]:=10;
  auto[20]:=20;
  auto[21]:=50;
  auto[22]:=100;
  auto[23]:=200;
  auto[24]:=500;
  auto[25]:=1000;
  auto[26]:=2000;
  auto[27]:=5000;
  auto[28]:=10000;
CLOSE
  IF auto#NIL THEN DISPOSE(auto); END;
END AxisLabels.

