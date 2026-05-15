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


MODULE PageCoords;

(* It's not save to call methods of this module if lg.screen=NIL! *)

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       gb : GeneralBasics,
       co : Coords,
       lb : LayoutBasics,
       NoGuruRq;


CONST inch  * = 2.54;
      point * = 1/72*inch;
      pt    * = point;

PROCEDURE InchToCM*(inch:LONGREAL):LONGREAL;

BEGIN
  RETURN inch*2.54;
END InchToCM;

PROCEDURE CMToInch*(cm:LONGREAL):LONGREAL;

BEGIN
  RETURN cm/2.54;
END CMToInch;

PROCEDURE CMToPt*(cm:LONGREAL):LONGREAL;

BEGIN
  RETURN cm/pt;
END CMToPt;

PROCEDURE PtToCM*(ptval:LONGREAL):LONGREAL;

BEGIN
  RETURN ptval*pt;
END PtToCM;

PROCEDURE InchToPt*(inchval:LONGREAL):LONGREAL;

BEGIN
  RETURN inchval*72;
END InchToPt;

PROCEDURE PtToInch*(ptval:LONGREAL):LONGREAL;

BEGIN
  RETURN ptval/72;
END PtToInch;



(* Standard unit: cm *)

TYPE PageCoords * = POINTER TO PageCoordsDesc;
     PageCoordsDesc * = RECORD(l.NodeDesc)
       editwidth  * ,           (* Maximum dims of edit area on screen *)
       editheight * ,
       picwidth   - ,           (* Whole width of nominal pagedims in pixels. Calculated by this object. Do not set this. *)
       picheight  - : LONGINT;
       pagewidth  * ,           (* Nominal pagedims: Width will fit in editwidth for zoom=100% *)
       pageheight * : LONGREAL;

       cmx,cmy      : LONGREAL; (* One cm in pixels *)
       zoom       - : LONGREAL;
       rect       - : co.Rectangle; (* Should contain ptr to pagerect. *)
       offx-,offy - : LONGINT;  (* Scrolling offset *)
     END;

PROCEDURE (coordobj:PageCoords) Refresh*;

BEGIN
  coordobj.cmx:=2*gb.GetStdPicX(lb.screen.width)*coordobj.zoom/100;
  coordobj.cmy:=2*gb.GetStdPicY(lb.screen.height)*coordobj.zoom/100;
  coordobj.picwidth:=SHORT(SHORT(coordobj.pagewidth*coordobj.cmx));
  coordobj.picheight:=SHORT(SHORT(coordobj.pageheight*coordobj.cmy));
END Refresh;

PROCEDURE (coordobj:PageCoords) Init*;

BEGIN
  coordobj.Init^;
  coordobj.zoom:=100;
  coordobj.Refresh;
END Init;

PROCEDURE (coordobj:PageCoords) Destruct*;

BEGIN
  coordobj.Destruct^;
END Destruct;

(*PROCEDURE (coordobj:PageCoords) SetEditDims*(editwidth,editheight:LONGINT);

BEGIN
  coordobj.editwidth:=editwidth;
  coordobj.editheight:=editheight;
END SetEditDims;*)

PROCEDURE (coordobj:PageCoords) SetPageDims*(pagewidth,pageheight:LONGREAL);

BEGIN
  coordobj.pagewidth:=pagewidth;
  coordobj.pageheight:=pageheight;
  coordobj.Refresh;
END SetPageDims;

PROCEDURE (coordobj:PageCoords) SetZoom*(zoom:LONGREAL);

BEGIN
  coordobj.zoom:=zoom;
  coordobj.Refresh;
END SetZoom;

PROCEDURE (coordobj:PageCoords) SetRect*(rect:co.Rectangle);

BEGIN
  coordobj.rect:=rect;
END SetRect;

PROCEDURE (coordobj:PageCoords) SetOffset*(offx,offy:LONGINT);

BEGIN
  coordobj.offx:=offx;
  coordobj.offy:=offy;
END SetOffset;

PROCEDURE (coordobj:PageCoords) CheckOffset*;
(* Corrects offset values when zoom was changed so that no plain area
   is displayed right to or below the page. *)

BEGIN
  IF coordobj.rect.width+coordobj.offx>coordobj.picwidth THEN
    coordobj.offx:=coordobj.picwidth-coordobj.rect.width;
    IF coordobj.offx<0 THEN coordobj.offx:=0; END;
  END;
  IF coordobj.rect.height+coordobj.offy>coordobj.picheight THEN
    coordobj.offy:=coordobj.picheight-coordobj.rect.height;
    IF coordobj.offy<0 THEN coordobj.offy:=0; END;
  END;
END CheckOffset;

PROCEDURE (coordobj:PageCoords) PicToCM*(picx,picy:LONGINT;VAR cmx,cmy:LONGREAL);

BEGIN
  cmx:=picx/coordobj.cmx;
  cmy:=picy/coordobj.cmy;
END PicToCM;

PROCEDURE (coordobj:PageCoords) CMToPic*(cmx,cmy:LONGREAL;VAR picx,picy:LONGINT);

BEGIN
  picx:=SHORT(SHORT(cmx*coordobj.cmx));
  picy:=SHORT(SHORT(cmy*coordobj.cmy));
(*  IF picx=0 THEN picx:=1; END;
  IF picy=0 THEN picy:=1; END;*)
END CMToPic;

PROCEDURE (coordobj:PageCoords) PicToCMRect*(picx,picy:LONGINT;VAR cmx,cmy:LONGREAL;rect:co.Rectangle);

BEGIN
  IF rect=NIL THEN
    rect:=coordobj.rect;
    picx:=picx+coordobj.offx;
    picy:=picy+coordobj.offy;
  END;
  picx:=picx-rect.xoff;
  picy:=picy-rect.yoff;
  coordobj.PicToCM(picx,picy,cmx,cmy);
END PicToCMRect;

PROCEDURE (coordobj:PageCoords) CMToPicRect*(cmx,cmy:LONGREAL;VAR picx,picy:LONGINT;rect:co.Rectangle);

BEGIN
  coordobj.CMToPic(cmx,cmy,picx,picy);
  IF rect=NIL THEN
    rect:=coordobj.rect;
    picx:=picx-coordobj.offx;
    picy:=picy-coordobj.offy;
  END;
  picx:=picx+rect.xoff;
  picy:=picy+rect.yoff;
END CMToPicRect;

PROCEDURE (coordobj:PageCoords) BoxZoom*(x,y,width,height:LONGREAL);

VAR picx,picy : LONGINT;

BEGIN
  coordobj.CMToPic(x,y,picx,picy);
  coordobj.offx:=picx; coordobj.offy:=picy;
  coordobj.zoom:=100*coordobj.pagewidth/width;
  coordobj.Refresh;
END BoxZoom;



END PageCoords.

