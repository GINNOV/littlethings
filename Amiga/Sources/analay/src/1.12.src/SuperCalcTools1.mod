(*
Copyright (c) 1994 - 1996 Marc Necker.

This file is part of Analay (v1.12).
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


MODULE SuperCalcTools1;

IMPORT I  : Intuition,
       g  : Graphics,
       d  : Dos,
       e  : Exec,
       s  : SYSTEM,
       f  : Function,
       f1 : Function1,
       c  : Conversions,
       r  : Requests,
       l  : LinkedLists,
       df : DiskFont,
       bt : BasicTypes,
       loc: Locale,
       mt : MathTrans,
       it : IntuitionTools,
       tt : TextTools,
       vt : VectorTools,
       gt : GraphicsTools,
(*       lt : LocaleTools,*)
       wm : WindowManager,
       gm : GadgetManager,
       ac : AnalayCatalog,
       al : Alerts,
       lrc: LongRealConversions,
       st : Strings,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- $StackChk- $ReturnChk- *)

TYPE Func     * = ARRAY 10 OF ARRAY 1000 OF CHAR;
     Funktion * = ARRAY 640 OF REAL;
     Error    * = ARRAY 640 OF INTEGER;
     updown   * = ARRAY 641 OF INTEGER;
     FuncData  * = RECORD
       real      * : REAL;
       error     * : INTEGER;
       updown    * : INTEGER;
     END;
     FuncTable * = UNTRACED POINTER TO ARRAY OF FuncData;
     DependPtr * = POINTER TO Depend;
     Depend * = RECORD(l.NodeDesc)
       var * : l.Node;
     END;
     DefinePtr * = POINTER TO Define;
     Define * = RECORD(l.NodeDesc)
       start      * ,
       end        * : LONGREAL;
       startequal * ,
       endequal   * : BOOLEAN;
       string     * : ARRAY 256 OF CHAR;
       type       * : INTEGER;
     END;
     TermPtr * = POINTER TO Term;
     Term * = RECORD(l.NodeDesc)
       string * : ARRAY 256 OF CHAR;
       tree   * : f1.NodePtr;
       depend * : l.List;
       define * : l.List;
       changed* : BOOLEAN;
       basefunc*: l.Node;
     END;
     FuncTermPtr * = POINTER TO FuncTerm;
     FuncTerm * = RECORD(l.NodeDesc)
       term   * : l.Node;
       termnum* : INTEGER;
     END;
     FunctionPtr * = POINTER TO Function;
     Function * = RECORD(l.NodeDesc)
       name   * : ARRAY 80 OF CHAR;
       terms  * : l.List;
       depend * : l.List;
       define * : l.List;
       changed* : BOOLEAN;
       isbase * : BOOLEAN;
       diffunc* : l.Node;
     END;
     ConstantPtr * = POINTER TO Constant;
     Constant * = RECORD(Term)
       name   * ,
       term   * : POINTER TO ARRAY OF CHAR;
       cdepend* : l.List;
     END;
     BorderVal * = RECORD(l.NodeDesc)
       x      * ,
       left   * ,
       right  * : REAL;
     END;
     FunctionGraphPtr * = POINTER TO FunctionGraph;
     FunctionGraph * = RECORD(l.NodeDesc)
       table  * : FuncTable;
       bordervals * : l.List;
(*       func   * : Funktion;
       error  * : Error;
       updown * : updown;*)
       col    * : INTEGER;
       calced * : BOOLEAN;
       line   * ,
       width  * : INTEGER;
       pcolor * : l.Node;
       pwidth * : INTEGER;
     END;
     FensterFuncPtr * = POINTER TO FensterFunc;
     FensterFunc * = RECORD(l.NodeDesc)
       func   * : l.Node;
       graphs * : l.List;
       changed* : BOOLEAN;
     END;
     TextDes * = RECORD
       mode  * : SHORTSET;
       style * : SHORTSET;
       col   * : INTEGER;
     END;
     TextDesPtr * = POINTER TO TextDes;
     RawStringPtr * = POINTER TO RawString;
     RawString * = RECORD(l.NodeDesc)
       string * : ARRAY 256 OF CHAR;
     END;
     ReqNode * = RECORD(l.NodeDesc)
       sigtoend   * ,
       sigtofront * ,
       sigtosleep * ,
       sigtonewvals*: SHORTINT;
       task       * : e.TaskPtr;
       reqtype    * : INTEGER;
       reqsleeping* : BOOLEAN;
     END;
     ShareAble * = RECORD(l.NodeDesc)
       numtasks    * : INTEGER;
     END;
     LockAble * = RECORD(ShareAble)
       locked    * ,
       mathpri   * : BOOLEAN;
     END;
     ChangeAble * = RECORD(LockAble)
       reqtasklist * : l.List;
     END;
     ChangeListEl * = RECORD(l.NodeDesc)
       node     * : l.Node;
     END;
     ReqData * = RECORD(bt.ANYDesc);
       reqnode   * : l.Node;
       wind      * ,
       data1     * ,
       data2     * ,
       data3     * ,
       data4     * : l.Node;
     END;
     PreviewNode * = RECORD(l.NodeDesc)
       node      * : l.Node;
       prevgotobj* ,
       changed   * : BOOLEAN;
     END;
     FontNode * = RECORD(ChangeAble)
       font      * ,
       printfont * : g.TextAttr;
     END;
     GitterPtr * = UNTRACED POINTER TO Gitter;
     Gitter * = RECORD;
       xspace *,
       yspace *,
       xstart *,
       ystart * : LONGREAL;
       xspaces* ,
       yspaces* ,
       xstarts* ,
       ystarts* : ARRAY 80 OF CHAR;
       col *,
       muster * ,
       width  * : INTEGER;
       on     * : BOOLEAN;
     END;
     SkalaPtr * = UNTRACED POINTER TO Skala;
     Skala * = RECORD;
       numson  *,
       mark1on *,
       mark2on * : BOOLEAN;
       numsx   *,
       numsy   *,
       mark1x  *,
       mark1y  *,
       mark2x  *,
       mark2y  * : LONGREAL;
       numsxs  * ,
       numsys  * ,
       mark1xs * ,
       mark1ys * ,
       mark2xs * ,
       mark2ys * : ARRAY 80 OF CHAR;
       col     * ,
       width   * ,
       muster  * ,
       arrow   * : INTEGER;
       on      * ,
       xbezon  * ,
       ybezon  * : BOOLEAN;
       xname   * ,
       yname   * : ARRAY 10 OF CHAR;
       attr    * : g.TextAttr;
     END;
     CoordPtr * = POINTER TO Coord;
     Coord * = RECORD(l.NodeDesc)
       picx    * ,
       picy    * : INTEGER;
       weltx   * ,
       welty   * : LONGREAL;
       xkstr   * ,
       ykstr   * : ARRAY 80 OF CHAR;
       welt    * : BOOLEAN;
     END;
     GraphObject * = RECORD(Coord)
       string  * : ARRAY 256 OF CHAR;
       label   * : l.Node;
       colf    * ,
       colb    * : INTEGER;
       trans   * : BOOLEAN;
       style   * : SHORTSET;
       attr    * : g.TextAttr;
       snap    * : BOOLEAN;
       exp     * : BOOLEAN;
       nach    * : INTEGER;
     END;
     TextPtr * = POINTER TO Text;
     Text * = RECORD(GraphObject)
(*       string  * : ARRAY 256 OF CHAR;*)
     END;
     LabelPtr * = POINTER TO Label;
     Label * = RECORD(l.NodeDesc)
       string  * : ARRAY 256 OF CHAR;
     END;
     PointPtr * = POINTER TO Point;
     Point * = RECORD(GraphObject)
(*       name    * : ARRAY 80 OF CHAR;
       label   * : l.Node;*)
       point   * : INTEGER;
       fill    * : BOOLEAN;
     END;
     AreaDim * = RECORD(l.NodeDesc)
       type    * : INTEGER;
       name    * : ARRAY 80 OF CHAR;
       object  * : l.Node;
       string  * : ARRAY 256 OF CHAR;
       root    * : f1.NodePtr;
       xcoord  * ,
       ycoord  * : LONGREAL;
       xcoords * ,
       ycoords * : ARRAY 256 OF CHAR;
       up      * ,
       down    * ,
       left    * ,
       right   * ,
       include * : BOOLEAN;
     END;
     Area * = RECORD(l.NodeDesc)
       name    * : ARRAY 80 OF CHAR;
       dims    * : l.List;
       pattern * ,
       colf    * ,
       colb    * : INTEGER;
       clearb  * ,
       areab   * : BOOLEAN;
     END;
     Mark * = RECORD(GraphObject)
(*       name    * : ARRAY 80 OF CHAR;
       label   * : l.Node;*)
       line    * ,
       width   * ,
       textdir * ,
       textside* : INTEGER;
     END;
     FensterPtr * = POINTER TO Fenster;
     Fenster * = RECORD(ChangeAble)
       name   * : ARRAY 80 OF CHAR;
       num    * : INTEGER;
       wind   * : I.WindowPtr;
       rast   * : g.RastPortPtr;
       xpos *,
       ypos *,
       width *,
       height * ,
       inx*,iny* : INTEGER;
       xmin *,
       xmax *,
       ymin *,
       ymax   * ,
       oldxmin* ,
       oldxmax* ,
       oldymin* ,
       oldymax* : REAL;
       xmins  * ,
       xmaxs  * ,
       ymins  * ,
       ymaxs  * ,
       oldxmins*,
       oldxmaxs*,
       oldymins*,
       oldymaxs*: ARRAY 80 OF CHAR;
       grid1  * ,
       grid2  * : Gitter;
       scale  * : Skala;
       funcs  * : l.List;
       texts  * : l.List;
       points * : l.List;
       marks  * : l.List;
       areas  * : l.List;
       lines  * : l.List;
       refresh* ,
       changed* : BOOLEAN;
       mode           * : INTEGER;
       drawmode       * : INTEGER;
       backcol        * : INTEGER;
       transparent    * ,
       freeborder     * ,
       autofuncscale  * ,
       autoskalascale * ,
       autogridscale  * : BOOLEAN;
       stutz          * : INTEGER;
     END;
(*     FensterPtr * = POINTER TO Fenster;
     Fenster * = RECORD
       num    * : INTEGER;
       wind   * : I.WindowPtr;
       rast   * : g.RastPortPtr;
       xpos *,
       ypos *,
       width *,
       height * : INTEGER;
       xmin *,
       xmax *,
       ymin *,
       ymax   * : REAL;
       grid1  * ,
       grid2  * : Gitter;
       scale  * : Skala;
       points * : ARRAY 100 OF PointPtr;
       marks  * : ARRAY 100 OF MarkPtr;
       bereichs*: ARRAY 10 OF BereichPtr;
       refresh* : BOOLEAN;
     END;
     EinzPtr    * = POINTER TO Einz;
     Einz * = RECORD(Fenster)
       func   * : Funktion;
       error  * : Error;
       updown * : updown;
       col    * : INTEGER;
       calced * : BOOLEAN;
       line   * : INTEGER;
     END;
     MishPtr    * = POINTER TO Mish;
     Mish * = RECORD(Fenster)
       func   * : POINTER TO ARRAY 10 OF Funktion;
       error  * : POINTER TO ARRAY 10 OF Error;
       updown * : ARRAY 10 OF updown;
       col    * : ARRAY 10 OF INTEGER;
       on     *,
       calced * : ARRAY 10 OF BOOLEAN;
       line   * : ARRAY 10 OF INTEGER;
     END;*)
     LegendePtr * = POINTER TO Legende;
     Legende * = RECORD
       act  * : ARRAY 10 OF INTEGER;
       modi * : ARRAY 10 OF INTEGER;
       colfunc*,
       colschr* : ARRAY 10 OF INTEGER;
       line * : ARRAY 10 OF INTEGER;
       same * : BOOLEAN;
       wind * : I.WindowPtr;
       xpos * ,
       ypos * : INTEGER;
       wiewind*: INTEGER;
     END;
     LegendElement * = RECORD(l.NodeDesc);
       term * : ARRAY 256 OF CHAR;
       col  * ,
       line * ,
       width* ,
       point* : INTEGER;
       sub  * : BOOLEAN;
       font * : g.TextFontPtr;
       func * : l.Node;
     END;
     Legend * = RECORD(ChangeAble);
       wind     * : I.WindowPtr;
       rast     * : g.RastPortPtr;
       name     * : ARRAY 80 OF CHAR;
       elements * : l.List;
       outsame  * ,
       insame   * ,
       fontsame * ,
       einruck  * ,
       vorbild  * : BOOLEAN;
       default  * : l.Node;
       xpos     * ,
       ypos     * ,
       width    * ,
       height   * : INTEGER;
       refresh  * : BOOLEAN;
       attr     * : g.TextAttr;
     END;
     DesignPtr * = UNTRACED POINTER TO Design;
     Design * = RECORD
       hindex   * ,
       vindex   * ,
       width    * ,
       height   * ,
       left     * ,
       top      * ,
       col      * : INTEGER;
     END;
     ListZeil * = RECORD(l.NodeDesc);
       string   * : ARRAY 256 OF CHAR;
       color    * : INTEGER;
       style    * : SHORTSET;
     END;
     ListSpalt * = RECORD(l.NodeDesc);
       zeilen   * : l.List;
       samecol  * : BOOLEAN;
       samefont * : BOOLEAN;
       width    * ,
       integwidth*,
       floatwidth*,
       pointwidth*: INTEGER;
       pwidth   * ,
       pintegwidth*,
       pfloatwidth*,
       ppointwidth*: LONGREAL;
     END;
     List * = RECORD(ChangeAble);
       wind     * : I.WindowPtr;
       rast     * : g.RastPortPtr;
       name     * : ARRAY 80 OF CHAR;
       spalten  * : l.List;
       samewi   * ,
       samecol  * ,
       center   * ,
       dectab   * ,
       topsep   * ,
       samefield* : BOOLEAN;
       design   * : Design;
       attr     * : g.TextAttr;
       colf     * ,
       colb     * : INTEGER;
       xpos     * ,
       ypos     * ,
       width    * ,
       height   * ,
       lwidth   * ,
       lheight  * : INTEGER;
       pwidth   * ,
       pheight  * : LONGREAL;
       refresh  * : BOOLEAN;
     END;
     TableSpalt * = RECORD(l.NodeDesc);
       string   * : ARRAY 256 OF CHAR;
       color    * : INTEGER;
       style    * : SHORTSET;
       width    * ,
       integwidth*,
       floatwidth*,
       pointwidth*: INTEGER;
       pwidth   * ,
       pintegwidth*,
       pfloatwidth*,
       ppointwidth*: LONGREAL;
     END;
     TableZeil * = RECORD(l.NodeDesc);
       spalten  * : l.List;
       samecol  * ,
       samefont * : BOOLEAN;
       height   * : INTEGER;
       pheight  * : LONGREAL;
     END;
     Table * = RECORD(ChangeAble);
       wind     * : I.WindowPtr;
       rast     * : g.RastPortPtr;
       name     * : ARRAY 80 OF CHAR;
       zeilen   * : l.List;
       samewi   * ,
       samecol  * ,
       center   * ,
       dectab   * ,
       firstsep * : BOOLEAN;
       design   * : Design;
       attr     * : g.TextAttr;
       colf     * ,
       colb     * : INTEGER;
       xpos     * ,
       ypos     * ,
       width    * ,
       height   * ,
       lwidth   * ,
       lheight  * : INTEGER;
       pwidth   * ,
       pheight  * : LONGREAL;
       refresh  * : BOOLEAN;
     END;
     TabellePtr * = POINTER TO Tabelle;
     Tabelle * = RECORD
       wert      * : ARRAY 20 OF ARRAY 100 OF REAL;
       error     * : ARRAY 20 OF ARRAY 100 OF BOOLEAN;
       spaltname * : ARRAY 100 OF ARRAY 10 OF CHAR;
       zeilname  * : ARRAY 20 OF ARRAY 100 OF CHAR;
       spaltwi   * : ARRAY 100 OF INTEGER;
       nachkomma * : INTEGER;
       samewi    * : BOOLEAN;
       numzeil   * : INTEGER;
       numspalt  * : ARRAY 20 OF INTEGER;
       design    * : INTEGER;
       wind      * : I.WindowPtr;
       xpos      * ,
       ypos      * ,
       width     * ,
       height    * : INTEGER;
     END;
     ListePtr * = POINTER TO Liste;
     Liste * = RECORD
       wert      * : ARRAY 20 OF ARRAY 100 OF REAL;
       error     * : ARRAY 20 OF ARRAY 100 OF BOOLEAN;
       spaltname * : ARRAY 20 OF ARRAY 20 OF CHAR;
       spaltwi   * : ARRAY 20 OF INTEGER;
       nachkomma * : INTEGER;
       numspalt  * : INTEGER;
       samewi    * : BOOLEAN;
       numzeil   * : ARRAY 20 OF INTEGER;
       design    * : INTEGER;
       wind      * : I.WindowPtr;
     END;
     LineMatrixPtr * = POINTER TO LineMatrix;
     LineMatrix * = RECORD
       matrix    * : ARRAY 16 OF BOOLEAN;
       breite    * : INTEGER;
     END;
     ArrowMatrixPtr * = POINTER TO ArrowMatrix;
     ArrowMatrix * = RECORD
       matrix    * : ARRAY 9 OF ARRAY 16 OF CHAR;
       hotx*,hoty* : INTEGER;
     END;
     PointMatrixPtr * = POINTER TO PointMatrix;
     PointMatrix * = RECORD
       feld * : ARRAY 16 OF ARRAY 16 OF CHAR; (* ! ACHTUNG ! ARRAY !Y! OF ARRAY !X! ! *)
       hotx * ,
       hoty * : INTEGER;
       textx* ,
       texty* : INTEGER;
     END;
     MarkMust * = RECORD
       feld * : ARRAY 16 OF ARRAY 3 OF CHAR; (* ! ACHTUNG ! ARRAY !Y! OF ARRAY !X! ! *)
       hotx * ,
       hoty * : INTEGER;
       textx* ,
       texty* : INTEGER;
       bott * : INTEGER;
       last * : INTEGER;
     END;
     AreaPattern * = RECORD
       pattern  * ,
       widepat  * : ARRAY 16 OF SET;
       pixelpat * : ARRAY 16 OF ARRAY 16 OF CHAR;
     END;
     PointDataPtr * = POINTER TO PointData;
     PointData * = RECORD
       data  * : l.Node;
       textx * ,
       texty * : LONGREAL;
     END;
     ValuePtr * = POINTER TO Value;
     Value * = RECORD(l.NodeDesc)
       real    * : LONGREAL;
       defined * : BOOLEAN;
     END;
     ScreenModePtr * = POINTER TO ScreenMode;
     ScreenMode * = RECORD
       displayId * ,
       width     * ,
       height    * : LONGINT;
       depth     * : INTEGER;
       oscan     * : INTEGER;
       autoscroll* : BOOLEAN;
       ntsc      * : BOOLEAN;
       colormap  * : ARRAY 16 OF ARRAY 3 OF INTEGER;
       reserved  * : INTEGER;
     END;
     AslRequesterDimsPtr * = POINTER TO AslRequesterDims;
     AslRequesterDims * = RECORD
       filereqx  * ,
       filereqy  * ,
       filereqwi * ,
       filereqhe * ,
       fontreqx  * ,
       fontreqy  * ,
       fontreqwi * ,
       fontreqhe * ,
       scrreqx   * ,
       scrreqy   * ,
       scrreqwi  * ,
       scrreqhe  * : INTEGER;
     END;
     StandardObjectsPtr * = POINTER TO StandardObjects;
     StandardObjects * = RECORD
       wind      * ,
       legend    * ,
       table     * ,
       list      * ,
       text      * ,
       point     * ,
       mark      * ,
       area      * : l.Node;
     END;

VAR ok,bool     : BOOLEAN;
    code        : INTEGER;
    class       : LONGSET;
    address     : s.ADDRESS;
    a,i,x,y     : INTEGER;
    window    * : I.WindowPtr;
    rast      * : g.RastPortPtr;
    view      * : g.ViewPortPtr;
    screen    * : I.ScreenPtr;
    colormap  * : g.ColorMapPtr;
    scr       * : ScreenModePtr;
    reqs      * : AslRequesterDimsPtr;
    std       * : StandardObjectsPtr;
    os2*,os3  * : BOOLEAN;
    os        * : INTEGER;
    mainxpos  * ,
    mainypos  * ,
    mainwidth * ,
    mainheight* : INTEGER;
(*    meswin    * : I.WindowPtr;
    mesrast   * : g.RastPortPtr;
    scrwi     * ,
    scrhe     * ,
    scrde     * : INTEGER;
    ntsc      * ,
    over      * ,
    a4        * : BOOLEAN;*)
    fenster   * : l.List;
    form      * : l.List;
    formnum   * : INTEGER;
    nums      * : INTEGER;
(*    pointmust * : ARRAY 15 OF PointMust;
    markmust  * : ARRAY 15 OF MarkMust;*)
    legends   * ,
    lists     * ,
    tables    * : l.List;
    lines     * : POINTER TO ARRAY OF l.Node;
    arrows    * : POINTER TO ARRAY OF l.Node;
    points    * : POINTER TO ARRAY OF PointDataPtr;
    areas     * : POINTER TO ARRAY OF AreaPattern;
    terms     * : l.List;
    functions * : l.List;
(*    funktions * : l.List;*)
    variables * : l.List;
    labels    * : l.List;
    auto      * : POINTER TO ARRAY OF LONGREAL;
    line      * ,
    width     * : INTEGER;
    greyscale * : BOOLEAN;
    mat         : INTEGER;
    menu      * : I.MenuPtr;
    top       * : INTEGER;
    locale    * : loc.LocalePtr;
    catalog   * : loc.CatalogPtr;
    printout  * : BOOLEAN;
(*    wflist    * : l.List;*)
    changesig * ,
    prevnewobj* ,
    prevgotobj* ,
    prevobjch * ,
    prevtoact * ,
    prevquit  * ,
    prevchscr * ,
    mainchscr * ,
    loadsavesig*: SHORTINT;
    maintask  * ,
    prevtask  * : e.TaskPtr;
    mathpri   * ,
    reqpri    * ,
    prevpri   * : SHORTINT;
    prevlist  * : l.List;
    prevtext  * : POINTER TO ARRAY OF CHAR;
    bereichsId* : INTEGER;
    prevx     * ,
    prevy     * ,
    prevwi    * ,
    prevhe    * : INTEGER;
    prevactive* : BOOLEAN;
    mathcolors* : INTEGER;
    prevsleeping*:BOOLEAN;
    garbage   * : l.List;
    factx     * ,
    facty     * : LONGREAL;
    stdpicx   * ,
    stdpicy   * : INTEGER;
    loadsave  * : INTEGER;
    quickselect*,
    autoactive* ,
    usewbscreen*,
    clonewb   * ,
    demo      * : BOOLEAN;
    infotext  * : UNTRACED POINTER TO ARRAY OF ARRAY OF CHAR;
    analaydoc * : ARRAY 80 OF CHAR;

(*PROCEDURE GetMousePos*(wi:I.WindowPtr;VAR x,y:INTEGER);

BEGIN
  x:=wi.mouseX;
  y:=wi.mouseY;
END GetMousePos;

PROCEDURE ActivateBool*(gad:I.GadgetPtr;wind:I.WindowPtr);

BEGIN
  INCL(gad.flags,I.selected);
  I.RefreshGList(gad,wind,NIL,1);
END ActivateBool;

PROCEDURE DeActivateBool*(gad:I.GadgetPtr;wind:I.WindowPtr);

BEGIN
  EXCL(gad.flags,I.selected);
  I.RefreshGList(gad,wind,NIL,1);
END DeActivateBool;*)

PROCEDURE WeltToPic*(wx,wy:REAL;VAR px,py:INTEGER;minx,maxx,miny,maxy:REAL;picx,picy:INTEGER);

VAR dx,dy : REAL;
    sx,sy : REAL;

BEGIN
(*  wy:=-wy;*)
(*  IF minx<0 THEN
    dx:=ABS(minx)+ABS(maxx);
  ELSE
    dx:=ABS(maxx)-ABS(minx);
  END;
  IF miny<0 THEN
    dy:=ABS(miny)+ABS(maxy);
  ELSE
    dy:=ABS(maxy)-ABS(miny);
  END;
  sx:=picx/dx;
  sy:=picy/dy;
  IF minx<0 THEN
    px:=SHORT(SHORT(sx*(wx+ABS(minx))));
  ELSE
    px:=SHORT(SHORT(sx*(wx-ABS(minx))));
  END;
  IF miny<0 THEN
    py:=SHORT(SHORT(sy*(wy+ABS(miny))));
  ELSE
    py:=SHORT(SHORT(sy*(wy-ABS(miny))));
  END;
  py:=ABS(picy-py);*)
END WeltToPic;

PROCEDURE PicToWelt*(VAR wx,wy:REAL;px,py:INTEGER;minx,maxx,miny,maxy:REAL;picx,picy:INTEGER);

VAR dx,dy : REAL;
    sx,sy : REAL;

BEGIN
(*  py:=picy-py;
  IF minx<0 THEN
    dx:=ABS(minx)+ABS(maxx);
  ELSE
    dx:=ABS(maxx)-ABS(minx);
  END;
  IF miny<0 THEN
    dy:=ABS(miny)+ABS(maxy);
  ELSE
    dy:=ABS(maxy)-ABS(miny);
  END;
  sx:=dx/picx;
  sy:=dy/picy;
  wx:=sx*(LONG(LONG(px)))+minx;
  wy:=sy*(LONG(LONG(py)))+miny;*)
(*  wy:=-wy;*)
END PicToWelt;

PROCEDURE PolarToPic*(wx,wy:REAL;VAR px,py:INTEGER;minx,maxx,miny,maxy:REAL;picx,picy:INTEGER);

VAR dx,dy : REAL;
    sx,sy : REAL;

BEGIN
(*  wy:=-wy;*)
(*  dx:=wx;
  wx:=mt.Cos(dx)*wy;
  wy:=mt.Sin(dx)*wy;
  dx:=ABS(maxy)+ABS(maxy);
  dy:=ABS(maxy)+ABS(maxy);
  sx:=picx/dx;
  sy:=picy/dy;
  px:=SHORT(SHORT(sx*(wx+ABS(maxy))));
  py:=SHORT(SHORT(sy*(wy+ABS(maxy))));
(*  px:=px+(picx DIV 2);
  py:=py+(picy DIV 2);*)
  py:=ABS(picy-py);*)
END PolarToPic;

PROCEDURE PicToPolar*(VAR wx,wy:REAL;px,py:INTEGER;minx,maxx,miny,maxy:REAL;picx,picy:INTEGER);

VAR dx,dy : REAL;
    sx,sy : REAL;

BEGIN
(*  dx:=ABS(miny)+ABS(maxy);
  dy:=ABS(miny)+ABS(maxy);
  sx:=dx/picx;
  sy:=dy/picy;
  wx:=sx*(LONG(LONG(px)))+miny;
  wy:=sy*(LONG(LONG(py)))+miny;
  wy:=-wy;*)
END PicToPolar;

PROCEDURE WorldToPic*(wx,wy:LONGREAL;VAR px,py:INTEGER;p:l.Node);

VAR distx,disty : LONGREAL;
    factx,facty : LONGREAL;

BEGIN
  WITH p: Fenster DO
    distx:=p.xmax-p.xmin;
    disty:=p.ymax-p.ymin;
    wx:=wx-p.xmin;
    wy:=wy-p.ymin;
    factx:=wx/distx;
    facty:=wy/disty;
    distx:=factx*p.width;
    disty:=facty*p.height;
    IF (distx<=30000) AND (distx>=-30000) THEN
      IF distx>=0 THEN
        px:=SHORT(SHORT(SHORT(distx+0.5)));
      ELSE
        px:=SHORT(SHORT(SHORT(distx-0.5)));
      END;
    ELSIF distx>30000 THEN
      px:=30000;
    ELSIF distx<-30000 THEN
      px:=-30000;
    END;
    IF (disty<=30000) AND (disty>=-30000) THEN
      IF disty>=0 THEN
        py:=SHORT(SHORT(SHORT(disty+0.5)));
      ELSE
        py:=SHORT(SHORT(SHORT(disty-0.5)));
      END;
    ELSIF disty>30000 THEN
      py:=30000;
    ELSIF disty<-30000 THEN
      py:=-30000;
    END;
    py:=p.height-py;
    INC(px,p.inx);
    INC(py,p.iny);
  END;
END WorldToPic;

PROCEDURE PicToWorld*(VAR wx,wy:LONGREAL;px,py:INTEGER;p:l.Node);

VAR distx,disty : LONGREAL;
    factx,facty : LONGREAL;

BEGIN
  WITH p: Fenster DO
    distx:=p.xmax-p.xmin;
    disty:=p.ymax-p.ymin;
    DEC(px,p.inx);
    DEC(py,p.iny);
    py:=p.height-py;
    factx:=LONG(LONG(LONG(px)))/LONG(LONG(LONG(p.width)));
    facty:=LONG(LONG(LONG(py)))/LONG(LONG(LONG(p.height)));
    wx:=factx*distx;
    wy:=facty*disty;
    wx:=wx+p.xmin;
    wy:=wy+p.ymin;
  END;
END PicToWorld;

PROCEDURE InitNode*(node:l.Node);

BEGIN
  IF node IS ShareAble THEN
    node(ShareAble).numtasks:=1;
  END;
  IF node IS ChangeAble THEN
    node(ChangeAble).reqtasklist:=l.Create();
  END;
  IF node IS Fenster THEN
    WITH node: Fenster DO
      node.scale.attr.name:=e.AllocMem(s.SIZE(CHAR)*256,LONGSET{e.memClear});
      COPY("topaz.font",node.scale.attr.name^);
      node.scale.attr.ySize:=8;
    END;
  ELSIF node IS GraphObject THEN
    WITH node: GraphObject DO
      node.attr.name:=e.AllocMem(s.SIZE(CHAR)*256,LONGSET{e.memClear});
      COPY("topaz.font",node.attr.name^);
      node.attr.ySize:=8;
    END;
  ELSIF node IS Area THEN
    WITH node: Area DO
      node.dims:=l.Create();
    END;
  ELSIF node IS Legend THEN
    WITH node: Legend DO
      node.attr.name:=e.AllocMem(s.SIZE(CHAR)*256,LONGSET{e.memClear});
      COPY("topaz.font",node.attr.name^);
      node.attr.ySize:=8;
      node.elements:=l.Create();
    END;
  ELSIF node IS List THEN
    WITH node: List DO
      node.attr.name:=e.AllocMem(s.SIZE(CHAR)*256,LONGSET{e.memClear});
      COPY("topaz.font",node.attr.name^);
      node.attr.ySize:=8;
      node.spalten:=l.Create();
    END;
  ELSIF node IS Table THEN
    WITH node: Table DO
      node.attr.name:=e.AllocMem(s.SIZE(CHAR)*256,LONGSET{e.memClear});
      COPY("topaz.font",node.attr.name^);
      node.attr.ySize:=8;
      node.zeilen:=l.Create();
    END;
  ELSIF node IS TableZeil THEN
    WITH node: TableZeil DO
      node.spalten:=l.Create();
    END;
  ELSIF node IS ListSpalt THEN
    WITH node: ListSpalt DO
      node.zeilen:=l.Create();
    END;
  END;
END InitNode;

PROCEDURE FreeNode*(p:l.Node);

VAR node,node2 : l.Node;

BEGIN
  IF p IS Fenster THEN
    WITH p: Fenster DO
      node:=p.funcs.head;
      WHILE node#NIL DO
        node2:=node(FensterFunc).graphs.head;
        WHILE node2#NIL DO
          IF node2(FunctionGraph).table#NIL THEN
            DISPOSE(node2(FunctionGraph).table);
          END;
          node2:=node2.next;
        END;
        node:=node.next;
      END;
      node:=p.texts.head;
      WHILE node#NIL DO
        FreeNode(node);
        node:=node.next;
      END;
      node:=p.points.head;
      WHILE node#NIL DO
        FreeNode(node);
        node:=node.next;
      END;
      node:=p.marks.head;
      WHILE node#NIL DO
        FreeNode(node);
        node:=node.next;
      END;
      node:=p.areas.head;
      WHILE node#NIL DO
        FreeNode(node);
        node:=node.next;
      END;
      e.FreeMem(p.scale.attr.name,s.SIZE(CHAR)*256);
      IF p.wind#NIL THEN
        I.ClearMenuStrip(p.wind);
        I.CloseWindow(p.wind);
      END;
    END;
  ELSIF p IS Legend THEN
    WITH p: Legend DO
      e.FreeMem(p.attr.name,s.SIZE(CHAR)*256);
      IF p.wind#NIL THEN
        I.ClearMenuStrip(p.wind);
        I.CloseWindow(p.wind);
      END;
    END;
  ELSIF p IS Table THEN
    WITH p: Table DO
      e.FreeMem(p.attr.name,s.SIZE(CHAR)*256);
      IF p.wind#NIL THEN
        I.ClearMenuStrip(p.wind);
        I.CloseWindow(p.wind);
      END;
    END;
  ELSIF p IS List THEN
    WITH p: List DO
      e.FreeMem(p.attr.name,s.SIZE(CHAR)*256);
      IF p.wind#NIL THEN
        I.ClearMenuStrip(p.wind);
        I.CloseWindow(p.wind);
      END;
    END;
  ELSIF p IS GraphObject THEN
    WITH p: GraphObject DO
      e.FreeMem(p.attr.name,s.SIZE(CHAR)*256);
    END;
  END;
END FreeNode;

PROCEDURE NewNodeShare*(node:l.Node);

BEGIN
  IF node IS ShareAble THEN
    e.Forbid();
    INC(node(ShareAble).numtasks);
    e.Permit();
  END;
END NewNodeShare;

PROCEDURE FreeNodeShare*(VAR node:l.Node);

BEGIN
  IF node IS ShareAble THEN
    e.Forbid();
    DEC(node(ShareAble).numtasks);
    e.Permit();
  END;
END FreeNodeShare;

PROCEDURE NodeToGarbage*(VAR node:l.Node);

BEGIN
  FreeNodeShare(node);
  node.Remove;
  garbage.AddTail(node);
END NodeToGarbage;

PROCEDURE CopyTextAttr*(attr,attr2:g.TextAttrPtr);

BEGIN
  COPY(attr.name^,attr2.name^);
  attr2.ySize:=attr.ySize;
END CopyTextAttr;

PROCEDURE CopyDesign*(des,des2:DesignPtr);

BEGIN
  des2.hindex:=des.hindex;
  des2.vindex:=des.vindex;
  des2.width:=des.width;
  des2.height:=des.height;
  des2.left:=des.left;
  des2.top:=des.top;
  des2.col:=des.col;
END CopyDesign;

PROCEDURE CopyNode*(node:l.Node;VAR node2:l.Node);

PROCEDURE CopyList(list:l.List;VAR list2:l.List);

VAR node,node2 : l.Node;

BEGIN
  IF list#NIL THEN
    node:=list.head;
    node2:=list2.head;
    WHILE node#NIL DO
      IF node2=NIL THEN
        IF node IS Term THEN
          NEW(node2(Term));
        ELSIF node IS Depend THEN
          NEW(node2(Depend));
        ELSIF node IS Define THEN
          NEW(node2(Define));
        ELSIF node IS FuncTerm THEN
          NEW(node2(FuncTerm));
        ELSIF node IS LegendElement THEN
          NEW(node2(LegendElement));
        ELSIF node IS TableZeil THEN
          NEW(node2(TableZeil));
        ELSIF node IS TableSpalt THEN
          NEW(node2(TableSpalt));
        ELSIF node IS ListZeil THEN
          NEW(node2(ListZeil));
        ELSIF node IS ListSpalt THEN
          NEW(node2(ListSpalt));
        ELSIF node IS AreaDim THEN
          NEW(node2(AreaDim));
        END;
        InitNode(node2);
        list2.AddTail(node2);
      END;
      CopyNode(node,node2);
      node:=node.next;
      node2:=node2.next;
    END;
    WHILE node2#NIL DO
      node:=node2.next;
      node2.Remove;
      node2:=node;
    END;
  END;
END CopyList;

BEGIN
  IF node IS Term THEN
    WITH node: Term DO
      WITH node2: Term DO
        COPY(node.string,node2.string);
        node2.tree:=node.tree;
        CopyList(node.depend,node2.depend);
        CopyList(node.define,node2.define);
        node2.changed:=node.changed;
        node2.basefunc:=node.basefunc;
      END;
    END;
  ELSIF node IS Depend THEN
    WITH node: Depend DO
      WITH node2: Depend DO
        node2.var:=node.var;
      END;
    END;
  ELSIF node IS Define THEN
    WITH node: Define DO
      WITH node2: Define DO
        node2.start:=node.start;
        node2.end:=node.end;
        node2.startequal:=node.startequal;
        node2.endequal:=node.endequal;
        COPY(node.string,node2.string);
        node2.type:=node.type;
      END;
    END;
  ELSIF node IS FuncTerm THEN
    WITH node: FuncTerm DO
      WITH node2: FuncTerm DO
        IF node2.term=NIL THEN
          NEW(node2.term(Term));
          node2.term(Term).depend:=l.Create();
          node2.term(Term).define:=l.Create();
        END;
        CopyNode(node.term,node2.term);
      END;
    END;
  ELSIF node IS Coord THEN
    WITH node: Coord DO
      WITH node2: Coord DO
        node2.picx:=node.picx;
        node2.picy:=node.picy;
        node2.weltx:=node.weltx;
        node2.welty:=node.welty;
        COPY(node.xkstr,node2.xkstr);
        COPY(node.ykstr,node2.ykstr);
        node2.welt:=node.welt;
      END;
    END;
    IF node IS GraphObject THEN
      WITH node: GraphObject DO
        WITH node2: GraphObject DO
          node2.colf:=node.colf;
          node2.colb:=node.colb;
          node2.trans:=node.trans;
          node2.style:=node.style;
          CopyTextAttr(s.ADR(node.attr),s.ADR(node2.attr));
        END;
      END;
      IF node IS Text THEN
        WITH node: Text DO
          WITH node2: Text DO
            COPY(node.string,node2.string);
            node.snap:=node2.snap;
          END;
        END;
      ELSIF node IS Point THEN
        WITH node: Point DO
          WITH node2: Point DO
            COPY(node.string,node2.string);
            node2.label:=node.label;
            node2.point:=node.point;
            node2.fill:=node.fill;
            node2.snap:=node.snap;
            node2.exp:=node.exp;
            node2.nach:=node.nach;
          END;
        END;
      ELSIF node IS Mark THEN
        WITH node: Mark DO
          WITH node2: Mark DO
            COPY(node.string,node2.string);
            node2.label:=node.label;
            node2.line:=node.line;
            node2.width:=node.width;
            node2.textdir:=node.textdir;
            node2.textside:=node.textside;
            node2.snap:=node.snap;
            node2.exp:=node.exp;
            node2.nach:=node.nach;
          END;
        END;
      END;
    END;
  ELSIF node IS Area THEN
    WITH node: Area DO
      WITH node2: Area DO
        COPY(node.name,node2.name);
        CopyList(node.dims,node2.dims);
        node2.pattern:=node.pattern;
        node2.colf:=node.colf;
        node2.colb:=node.colb;
        node2.clearb:=node.clearb;
        node2.areab:=node.areab;
      END;
    END;
  ELSIF node IS AreaDim THEN
    WITH node: AreaDim DO
      WITH node2: AreaDim DO
        node2.type:=node.type;
        COPY(node.name,node2.name);
        node2.object:=node.object;
        COPY(node.string,node2.string);
        node2.root:=node.root;
        node2.xcoord:=node.xcoord;
        node2.ycoord:=node.ycoord;
        COPY(node.xcoords,node2.xcoords);
        COPY(node.ycoords,node2.ycoords);
        node2.up:=node.up;
        node2.down:=node.down;
        node2.left:=node.left;
        node2.right:=node.right;
        node2.include:=node.include;
      END;
    END;
  ELSIF node IS Legend THEN
    WITH node: Legend DO
      WITH node2: Legend DO
        COPY(node.name,node2.name);
        CopyList(node.elements,node2.elements);
        node2.outsame:=node.outsame;
        node2.insame:=node.insame;
        node2.fontsame:=node.fontsame;
        node2.einruck:=node.einruck;
        node2.vorbild:=node.vorbild;
        node2.default:=node.default;
        node2.xpos:=node.xpos;
        node2.ypos:=node.ypos;
        node2.width:=node.width;
        node2.height:=node.height;
        CopyTextAttr(s.ADR(node.attr),s.ADR(node2.attr));
      END;
    END;
  ELSIF node IS Table THEN
    WITH node: Table DO
      WITH node2: Table DO
        COPY(node.name,node2.name);
        CopyList(node.zeilen,node2.zeilen);
        node2.samewi:=node.samewi;
        node2.samecol:=node.samecol;
        node2.center:=node.center;
        node2.dectab:=node.dectab;
        node2.firstsep:=node.firstsep;
        CopyDesign(s.ADR(node.design),s.ADR(node2.design));
        CopyTextAttr(s.ADR(node.attr),s.ADR(node2.attr));
        node2.colf:=node.colf;
        node2.colb:=node.colb;
        node2.xpos:=node.xpos;
        node2.ypos:=node.ypos;
        node2.width:=node.width;
        node2.height:=node.height;
        node2.lwidth:=node.lwidth;
        node2.lheight:=node.lheight;
        node2.pwidth:=node.pwidth;
        node2.pheight:=node.pheight;
      END;
    END;
  ELSIF node IS List THEN
    WITH node: List DO
      WITH node2: List DO
        COPY(node.name,node2.name);
        CopyList(node.spalten,node2.spalten);
        node2.samewi:=node.samewi;
        node2.samecol:=node.samecol;
        node2.center:=node.center;
        node2.dectab:=node.dectab;
        node2.topsep:=node.topsep;
        node2.samefield:=node.samefield;
        CopyDesign(s.ADR(node.design),s.ADR(node2.design));
        node2.colf:=node.colf;
        node2.colb:=node.colb;
        node2.xpos:=node.xpos;
        node2.ypos:=node.ypos;
        node2.width:=node.width;
        node2.height:=node.height;
        node2.lwidth:=node.lwidth;
        node2.lheight:=node.lheight;
        node2.pwidth:=node.pheight;
        node2.pheight:=node.pheight;
      END;
    END;
  ELSIF node IS LegendElement THEN
    WITH node: LegendElement DO
      WITH node2: LegendElement DO
        COPY(node.term,node2.term);
        node2.col:=node.col;
        node2.line:=node.line;
        node2.width:=node.width;
        node2.point:=node.point;
        node2.sub:=node.sub;
      END;
    END;
  ELSIF node IS TableSpalt THEN
    WITH node: TableSpalt DO
      WITH node2: TableSpalt DO
        COPY(node.string,node2.string);
        node2.color:=node.color;
        node2.style:=node.style;
        node2.width:=node.width;
        node2.integwidth:=node.integwidth;
        node2.floatwidth:=node.floatwidth;
        node2.pointwidth:=node.pointwidth;
        node2.pwidth:=node.pwidth;
        node2.pintegwidth:=node.pintegwidth;
        node2.pfloatwidth:=node.pfloatwidth;
        node2.ppointwidth:=node.ppointwidth;
      END;
    END;
  ELSIF node IS TableZeil THEN
    WITH node: TableZeil DO
      WITH node2: TableZeil DO
        CopyList(node.spalten,node2.spalten);
        node2.samecol:=node.samecol;
        node2.samefont:=node.samefont;
        node2.height:=node.height;
        node2.pheight:=node.pheight;
      END;
    END;
  ELSIF node IS ListZeil THEN
    WITH node: ListZeil DO
      WITH node2: ListZeil DO
        COPY(node.string,node2.string);
        node2.color:=node.color;
        node2.style:=node.style;
      END;
    END;
  ELSIF node IS ListSpalt THEN
    WITH node: ListSpalt DO
      WITH node2: ListSpalt DO
        CopyList(node.zeilen,node2.zeilen);
        node2.samecol:=node.samecol;
        node2.samefont:=node.samefont;
        node2.width:=node.width;
        node2.integwidth:=node.integwidth;
        node2.floatwidth:=node.floatwidth;
        node2.pointwidth:=node.pointwidth;
        node2.pwidth:=node.pwidth;
        node2.pintegwidth:=node.pintegwidth;
        node2.pfloatwidth:=node.pfloatwidth;
        node2.ppointwidth:=node.ppointwidth;
      END;
    END;
  END;
END CopyNode;

PROCEDURE CopyList*(list:l.List;VAR list2:l.List);

VAR node,node2 : l.Node;

BEGIN
  IF list#NIL THEN
    node:=list.head;
    node2:=list2.head;
    WHILE node#NIL DO
      IF node2=NIL THEN
        IF node IS Term THEN
          NEW(node2(Term));
        ELSIF node IS Depend THEN
          NEW(node2(Depend));
        ELSIF node IS Define THEN
          NEW(node2(Define));
        ELSIF node IS FuncTerm THEN
          NEW(node2(FuncTerm));
        ELSIF node IS LegendElement THEN
          NEW(node2(LegendElement));
        ELSIF node IS TableZeil THEN
          NEW(node2(TableZeil));
        ELSIF node IS TableSpalt THEN
          NEW(node2(TableSpalt));
        ELSIF node IS ListZeil THEN
          NEW(node2(ListZeil));
        ELSIF node IS ListSpalt THEN
          NEW(node2(ListSpalt));
        END;
        list2.AddTail(node2);
      END;
      CopyNode(node,node2);
      node:=node.next;
      node2:=node2.next;
    END;
  END;
END CopyList;

(*PROCEDURE CopyNodeNew*(node:l.Node):l.Node;

VAR node2 : l.Node;

PROCEDURE CopyList(node:l.List):l.List;

VAR list  : l.List;
    node2 : l.Node;

BEGIN
  IF node#NIL THEN
    list:=l.Create();
    node2:=node.head;
    WHILE node2#NIL DO
      list.AddTail(CopyNodeNew(node2));
      node2:=node2.next;
    END;
  END;
  RETURN list;
END CopyList;

BEGIN
(*  node2:=NIL;
  IF node IS Term THEN
    WITH node: Term DO
      NEW(node2(Term));
      node2(Term).depend:=l.Create();
      node2(Term).define:=l.Create();
      CopyNode(node,node2);
    END;
  ELSIF node IS Depend THEN
    WITH node: Depend DO
      NEW(node2(Depend));
      CopyNode(node,node2);
    END;
  ELSIF node IS Define THEN
    WITH node: Define DO
      NEW(node2(Define));
      CopyNode(node,node2);
    END;
  ELSIF node IS FuncTerm THEN
    WITH node: FuncTerm DO
      NEW(node2(FuncTerm));
      WITH node2: FuncTerm DO
        node2.term:=CopyNodeNew(node.term);
      END;
    END;
  ELSE
(*    IF node IS Text THEN
      NEW(node2(Text));
    ELSIF node IS Point THEN
      NEW(node2(Point));
    ELSIF node IS Mark THEN
      NEW(node2(Mark));
(*    ELSIF node IS Legend THEN
      NEW(node2(Legend));
    ELSIF node IS Table THEN
      NEW(node2(Table));
    ELSIF node IS List THEN
      NEW(node2(List));*)
    END;
    InitNode(node2);
    CopyNode(node,node2);*)
  END;
  RETURN node2;*)
END CopyNodeNew;

PROCEDURE CopyListNew*(node:l.List):l.List;

VAR list  : l.List;
    node2 : l.Node;

BEGIN
  IF node#NIL THEN
    list:=l.Create();
    node2:=node.head;
    WHILE node2#NIL DO
      list.AddTail(CopyNodeNew(node2));
      node2:=node2.next;
    END;
  END;
  RETURN list;
END CopyListNew;*)

PROCEDURE SendNewObject*(node:l.Node);

VAR node2 : l.Node;

BEGIN
  NewNodeShare(node);
  node(LockAble).mathpri:=TRUE;
  NEW(node2(PreviewNode));
  node2(PreviewNode).node:=node;
  node2(PreviewNode).prevgotobj:=FALSE;
  node2(PreviewNode).changed:=FALSE;
  prevlist.AddTail(node2);
  e.Signal(prevtask,LONGSET{prevnewobj});
END SendNewObject;

PROCEDURE SendChangedObject*(node:l.Node);

VAR node2 : l.Node;

BEGIN
  node(LockAble).mathpri:=TRUE;
  NEW(node2(PreviewNode));
  node2(PreviewNode).node:=node;
  node2(PreviewNode).prevgotobj:=FALSE;
  node2(PreviewNode).changed:=TRUE;
  prevlist.AddTail(node2);
  e.Signal(prevtask,LONGSET{prevnewobj});
END SendChangedObject;

PROCEDURE ChangeNode*(node:l.Node);

BEGIN
  IF node IS Fenster THEN
    node(Fenster).refresh:=TRUE;
  ELSIF node IS Legend THEN
    node(Legend).refresh:=TRUE;
  ELSIF node IS Table THEN
    node(Table).refresh:=TRUE;
  ELSIF node IS List THEN
    node(List).refresh:=TRUE;
  END;
  IF node IS LockAble THEN
    SendChangedObject(node);
  END;
END ChangeNode;

PROCEDURE MemoryManager*;

VAR node,node2 : l.Node;

BEGIN
  node:=garbage.head;
  WHILE node#NIL DO
    node2:=node.next;
    WITH node: ChangeAble DO
      IF node.numtasks=0 THEN
        FreeNode(node);
        node.Remove;
      END;
    END;
    node:=node2;
  END;
END MemoryManager;

PROCEDURE SetReqsToSleep*(p:l.Node);

VAR node : l.Node;

BEGIN
  IF p#NIL THEN
    WITH p: ChangeAble DO
      node:=p.reqtasklist.head;
      WHILE node#NIL DO
        WITH node: ReqNode DO
          IF (node.task#NIL) AND (node.sigtosleep#-1) THEN
            e.Signal(node.task,LONGSET{node.sigtosleep});
          END;
        END;
        node:=node.next;
      END;
    END;
  END;
END SetReqsToSleep;

PROCEDURE SetReqsToOpen*(p:l.Node);

VAR node : l.Node;

BEGIN
  IF p#NIL THEN
    WITH p: ChangeAble DO
      node:=p.reqtasklist.head;
      WHILE node#NIL DO
        WITH node: ReqNode DO
          IF (node.task#NIL) AND (node.sigtofront#-1) THEN
            e.Signal(node.task,LONGSET{node.sigtofront});
          END;
        END;
        node:=node.next;
      END;
    END;
  END;
END SetReqsToOpen;

PROCEDURE CheckPrevList*;

VAR node,node2 : l.Node;

BEGIN
  node:=prevlist.head;
  WHILE node#NIL DO
    node2:=node.next;
    IF node(PreviewNode).prevgotobj THEN
      node.Remove;
    END;
    node:=node2;
  END;
END CheckPrevList;

PROCEDURE SetToRecalc*(p:l.Node);

VAR node : l.Node;

BEGIN
  IF p#NIL THEN
    IF p IS Fenster THEN
      WITH p: Fenster DO
        node:=p.funcs.head;
        WHILE node#NIL DO
          node(FensterFunc).changed:=TRUE;
          node:=node.next;
        END;
        p.refresh:=TRUE;
        NEW(node(ChangeListEl));
        node(ChangeListEl).node:=p;
      END;
    END;
  END;
END SetToRecalc;

PROCEDURE GetPicCoords*(p,node:l.Node;VAR x,y:INTEGER);

BEGIN
  WITH node: Coord DO
    IF node.welt THEN
      WorldToPic(node.weltx,node.welty,node.picx,node.picy,p);
    END;
    x:=node.picx;
    y:=node.picy;
  END;
END GetPicCoords;

PROCEDURE GetWorldCoords*(p,node:l.Node;VAR x,y:LONGREAL);

BEGIN
  WITH node: Coord DO
    IF NOT(node.welt) THEN
      PicToWorld(node.weltx,node.welty,node.picx,node.picy,p);
    END;
    x:=node.weltx;
    y:=node.welty;
  END;
END GetWorldCoords;

PROCEDURE RefreshOtherCoord*(p,node:l.Node);

BEGIN
  WITH node: Coord DO
    IF node.welt THEN
      WorldToPic(node.weltx,node.welty,node.picx,node.picy,p);
    ELSE
      PicToWorld(node.weltx,node.welty,node.picx,node.picy,p);
    END;
  END;
END RefreshOtherCoord;

PROCEDURE GetNodeNumber*(list:l.List;node:l.Node):INTEGER;

VAR i     : INTEGER;
    node2 : l.Node;

BEGIN
  node2:=list.head;
  i:=0;
  WHILE (node2#NIL) AND (node2#node) DO
    INC(i);
    node2:=node2.next;
  END;
  IF node2=NIL THEN
    i:=-1;
  END;
  RETURN i;
END GetNodeNumber;

PROCEDURE GetNode*(list:l.List;num:INTEGER):l.Node;

VAR node : l.Node;

BEGIN
  node:=list.head;
  i:=-1;
  LOOP
    INC(i);
    IF (i=num) OR (node=NIL) THEN
      EXIT;
    END;
    node:=node.next;
  END;
  RETURN node;
END GetNode;

PROCEDURE GetFuncNode*(list:l.List;num:INTEGER):l.Node;

VAR node : l.Node;
    i    : INTEGER;

BEGIN
  node:=list.head;
  i:=-1;
  LOOP
    IF node=NIL THEN
      EXIT;
    END;
    IF NOT(node(Function).isbase) THEN
      INC(i);
    END;
    IF i=num THEN
      EXIT;
    END;
    node:=node.next;
  END;
  RETURN node;
END GetFuncNode;

PROCEDURE NumberNotBaseFuncs*():INTEGER;

VAR node : l.Node;
    i    : INTEGER;

BEGIN
  node:=functions.head;
  i:=0;
  WHILE node#NIL DO
    IF NOT(node(Function).isbase) THEN
      INC(i);
    END;
    node:=node.next;
  END;
  RETURN i;
END NumberNotBaseFuncs;

PROCEDURE GetFuncNodeNumber*(list:l.List;node:l.Node):INTEGER;

VAR node2 : l.Node;
    i     : INTEGER;

BEGIN
  node2:=list.head;
  i:=0;
  WHILE (node2#NIL) AND (node2#node) DO
    IF NOT(node2(Function).isbase) THEN
      INC(i);
    END;
    node2:=node2.next;
  END;
  RETURN i;
END GetFuncNodeNumber;

PROCEDURE GetTermNodeNumber*(list:l.List;node:l.Node):INTEGER;

VAR node2 : l.Node;
    i     : INTEGER;

BEGIN
  node2:=list.head;
  i:=0;
  LOOP
    IF node2=NIL THEN
      EXIT;
    END;
    IF node2(FuncTerm).term=node THEN
      EXIT;
    END;
    INC(i);
    node2:=node2.next;
  END;
  RETURN i;
END GetTermNodeNumber;

PROCEDURE GetTermNode*(list:l.List;num:INTEGER):l.Node;

VAR node : l.Node;

BEGIN
  node:=GetNode(list,num);
  node:=node(FuncTerm).term;
  RETURN node;
END GetTermNode;

PROCEDURE ClearGraph*(node:l.Node);

BEGIN
  WITH node: FunctionGraph DO
    FOR i:=0 TO SHORT(LEN(node.table^)-1) DO
      node.table[i].real:=0;
      node.table[i].error:=0;
      node.table[i].updown:=0;
    END;
    node.col:=2;
    node.line:=0;
    node.width:=1;
    node.calced:=FALSE;
  END;
END ClearGraph;

PROCEDURE SoftClearGraph*(node:l.Node);

BEGIN
  WITH node: FunctionGraph DO
    FOR i:=0 TO SHORT(LEN(node.table^)-1) DO
      node.table[i].real:=0;
      node.table[i].error:=0;
      node.table[i].updown:=0;
    END;
    node.calced:=FALSE;
  END;
END SoftClearGraph;

PROCEDURE LockNode*(node:l.Node);

VAR exit : BOOLEAN;

BEGIN
  exit:=FALSE;
  WITH node: LockAble DO
    REPEAT
      WHILE node.locked DO
        d.Delay(10);
      END;
      e.Forbid();
      IF NOT(node.locked) THEN
        node.locked:=TRUE;
        node.mathpri:=FALSE;
        exit:=TRUE;
      END;
      e.Permit();
    UNTIL exit;
  END;
END LockNode;

PROCEDURE UnLockNode*(node:l.Node);

BEGIN
  node(LockAble).locked:=FALSE;
  node(LockAble).mathpri:=FALSE;
END UnLockNode;

PROCEDURE WaitMathPri*(node:l.Node);

BEGIN
  WHILE node(LockAble).mathpri DO
    d.Delay(10);
  END;
END WaitMathPri;

(*PROCEDURE DrawArrow*(rast:g.RastPortPtr;x,y,arrow,dir,col:INTEGER);

VAR xa,ya : INTEGER;
    bool  : BOOLEAN;

BEGIN
  g.SetAPen(rast,col);
  FOR ya:=0 TO 8 DO
    FOR xa:=0 TO 15 DO
      IF arrows[arrow].matrix[ya,xa]="1" THEN
        IF dir=0 THEN
          bool:=g.WritePixel(rast,x+ya-arrows[arrow].hoty,y-xa+arrows[arrow].hotx);
        ELSIF dir=1 THEN
          bool:=g.WritePixel(rast,x+xa-arrows[arrow].hotx,y+ya-arrows[arrow].hoty);
        END;
      END;
    END;
  END;
END DrawArrow;*)

PROCEDURE InitStandards*;

VAR node : l.Node;

BEGIN
  NEW(std.wind(Fenster));
  InitNode(std.wind);
  node:=std.wind;
  WITH node: Fenster DO
    node.funcs:=l.Create();
    node.texts:=l.Create();
    node.points:=l.Create();
    node.marks:=l.Create();
    node.areas:=l.Create();
    node.lines:=l.Create();
  END;

  NEW(std.legend(Legend));
  InitNode(std.legend);
  node:=std.legend;
  WITH node: Legend DO
    COPY(ac.GetString(ac.Legend)^,node.name);
    node.elements:=l.Create();
    node.insame:=TRUE;
    node.outsame:=TRUE;
    node.einruck:=TRUE;
    node.vorbild:=FALSE;
    node.default:=NIL;
    node.xpos:=100;
    node.ypos:=50;
    node.width:=-1;
    node.height:=-1;
  END;

  NEW(std.table(Table));
  InitNode(std.table);
  node:=std.table;
  WITH node: Table DO
    COPY(ac.GetString(ac.Table)^,node.name);
    node.xpos:=20;
    node.ypos:=20;
    node.width:=-1;
    node.height:=-1;
    node.colf:=1;
    node.colb:=0;
    node.dectab:=TRUE;
    node.firstsep:=TRUE;
    node.design.hindex:=1;
    node.design.vindex:=1;
    node.design.width:=8;
    node.design.height:=3;
    node.design.left:=4;
    node.design.top:=2;
    node.design.col:=2;
    node.zeilen:=l.Create();
  END;

  NEW(std.list(List));
  InitNode(std.list);
  node:=std.list;
  WITH node: List DO
    COPY(ac.GetString(ac.List)^,node.name);
    node.xpos:=20;
    node.ypos:=20;
    node.width:=-1;
    node.height:=-1;
    node.colf:=1;
    node.colb:=0;
    node.dectab:=TRUE;
    node.topsep:=TRUE;
    node.design.hindex:=1;
    node.design.vindex:=1;
    node.design.width:=8;
    node.design.height:=3;
    node.design.left:=4;
    node.design.top:=2;
    node.design.col:=2;
    node.spalten:=l.Create();
  END;

  NEW(std.text(Text));
  InitNode(std.text);
  node:=std.text;
  WITH node: Text DO
    node.xkstr:="0";
    node.ykstr:="0";
    node.welt:=TRUE;
    node.colf:=2;
    node.colb:=0;
    node.style:=SHORTSET{};
    node.trans:=FALSE;
  END;

  NEW(std.point(Point));
  InitNode(std.point);
  node:=std.point;
  WITH node: Point DO
    node.string:="A";
    node.label:=labels.head;
    node.xkstr:="0";
    node.ykstr:="0";
    node.welt:=TRUE;
    node.colf:=2;
    node.colb:=0;
    node.style:=SHORTSET{};
    node.trans:=TRUE;
    node.nach:=2;
    node.exp:=FALSE;
  END;

  NEW(std.mark(Mark));
  InitNode(std.mark);
  node:=std.mark;
  WITH node: Mark DO
    node.string:="A";
    node.label:=labels.head;
    node.xkstr:="0";
    node.ykstr:="0";
    node.welt:=TRUE;
    node.colf:=2;
    node.colb:=0;
    node.width:=1;
    node.line:=0;
    node.textdir:=0;
    node.textside:=1;
    node.style:=SHORTSET{};
    node.trans:=TRUE;
    node.nach:=2;
    node.exp:=FALSE;
  END;
  NEW(std.area(Area));
  InitNode(std.area);
  node:=std.area;
  WITH node: Area DO
    node.name:="Standard-Bereich";
    node.dims:=l.Create();
    node.pattern:=0;
    node.colf:=3;
    node.colb:=0;
    node.clearb:=FALSE;
    node.areab:=TRUE;
  END;
END InitStandards;

PROCEDURE FreeStandards*;

BEGIN
  FreeNode(std.wind);
  FreeNode(std.legend);
  FreeNode(std.table);
  FreeNode(std.list);
  FreeNode(std.text);
  FreeNode(std.point);
  FreeNode(std.mark);
  FreeNode(std.area);
END FreeStandards;

BEGIN
  NEW(auto,29);
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
(*  auto[23]:=20000;
  auto[24]:=50000;
  auto[25]:=100000;
  auto[26]:=200000;
  auto[27]:=500000;
  auto[28]:=1000000;*)

(*  movedraw:=l.Create();*)
  garbage:=l.Create();
  NEW(lines,20);
  NEW(arrows,10);
  NEW(points,15);
  NEW(areas,15);
  FOR i:=0 TO 19 DO
    NEW(lines[i](gt.Line));
  END;
  FOR i:=0 TO 9 DO
    arrows[i]:=vt.NewVectorObject();
  END;
  FOR i:=0 TO 14 DO
    NEW(points[i]);
    points[i].data:=vt.NewVectorObject();
  END;

  NEW(scr);
  NEW(reqs);
  NEW(std);

  os:=I.int.libNode.version;
  IF os>=36 THEN
    os2:=TRUE;
  ELSIF os>=39 THEN
    os3:=TRUE;
  END;

(*  NEW(infotext,5,80);
  infotext[0]:="SuperCalc V0.9";
  infotext[1]:="© 1994 Marc Necker";
  infotext[2]:="";
  infotext[3]:="Dies ist eine Vorversion, die";
  infotext[4]:="nicht frei kopiert werden darf!";*)
END SuperCalcTools1.





























































