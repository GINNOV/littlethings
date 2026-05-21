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


MODULE Area;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       u  : Utility,
       r  : Requests,
       gd : GadTools,
       ml : MATHLIB,
       l  : LinkedLists,
       tt : TextTools,
       vt : VectorTools,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       m  : Multitasking,
       mem: MemoryManager,
       tid: TaskIDs,
       dc : DisplayConversion,
       gb : GeneralBasics,
       go : GraphicObjects,
       fb : FunctionBasics,
       ft : FunctionTrees,
       mb : MathBasics,
       mg : MathGUI,
       t  : Terms,
       co : Coords,
       w  : Window,
       wf : WindowFunction,
       gob: GraphObject,
       pmo: PointMarkObject,
       ac : AnalayCatalog,
       bt : BasicTypes,
       io,
       NoGuruRq;

(* $TypeChk- $NilChk- *)

(* Area itself is a ChangeAble. That means tasks to change the
   area object are started as tasks of the Area-Object, not as
   tasks of the related GraphWindow-Object! *)

TYPE AreaDim * = POINTER TO AreaDimDesc;
     AreaDimDesc * = RECORD(m.ShareAbleDesc)
       window  * : w.Window;
       type    * : INTEGER;            (* Type of areadim *)
       name    * : ARRAY 80 OF CHAR;   (* Name of AreaDim *)
       object  * : l.Node;             (* Related object (e.g. point, marker, function) *)
       string  * : ARRAY 256 OF CHAR;  (* Name of related object or for example a functionterm which is not present in the current functionlist. *)
       root    * : fb.Node;
       xcoord  * ,
       ycoord  * : LONGREAL;
       xcoords * ,
       ycoords * : ARRAY 256 OF CHAR;
       up      * ,
       down    * ,
       left    * ,
       right   * ,
       include * : BOOLEAN;
       changed   : BOOLEAN; (* Internal used by Area.Change *)
     END;

PROCEDURE (areadim:AreaDim) Init*;

BEGIN
  areadim.type:=0;
  COPY(ac.GetString(ac.XAxis)^,areadim.name);
  areadim.object:=NIL;
  COPY(ac.GetString(ac.XAxis)^,areadim.string);
  areadim.xcoord:=0;
  areadim.ycoord:=0;
  areadim.xcoords:="0";
  areadim.ycoords:="0";
  areadim.up:=TRUE;
  areadim.down:=FALSE;
  areadim.left:=TRUE;
  areadim.right:=FALSE;
  areadim.include:=FALSE;
END Init;

PROCEDURE (areadim:AreaDim) Destruct*;

BEGIN
  IF areadim.object#NIL THEN areadim.object(m.ShareAble).FreeUser(areadim.window); END;
  areadim.Destruct;
END Destruct;

PROCEDURE * PrintAreaDim*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=datalist.GetNode(num);
  IF node#NIL THEN
    WITH node: AreaDim DO
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintAreaDim;

PROCEDURE (areadim:AreaDim) SetObject(object:l.Node);
(* Sets areadim.object to the new pointer. Refreshes also all other
   necessary fields of areadim. Also calls object.NewUser and
   oldobject.FreeUser. *)

(* Don't forget to lock areadim before calling this function! *)

VAR bool : BOOLEAN;

BEGIN
  IF object#NIL THEN object(m.ShareAble).NewUser(areadim.window); END;
  IF areadim.object#NIL THEN areadim.object(m.ShareAble).FreeUser(areadim.window); END;
  areadim.object:=object;
  IF object#NIL THEN
    IF areadim.type=4 THEN
      COPY(object(t.Function).name,areadim.string);
    ELSIF areadim.type=5 THEN
      IF object IS pmo.PointObject THEN
        WITH object: pmo.PointObject DO
          COPY(object.string,areadim.string);
          object.GetCoordsWorld(areadim.window.rect,areadim.xcoord,areadim.ycoord);
          IF object.GetWorld() THEN
            object.GetCoordStrings(areadim.xcoords,areadim.ycoords);
          ELSE
            bool:=tt.RealToString(areadim.xcoord,areadim.xcoords,FALSE);
            bool:=tt.RealToString(areadim.ycoord,areadim.ycoords,FALSE);
          END;
        END;
      END;
    ELSIF areadim.type=6 THEN
      IF object IS pmo.MarkObject THEN
        WITH object: pmo.MarkObject DO
          COPY(object.string,areadim.string);
          object.GetCoordsWorld(areadim.window.rect,areadim.xcoord,areadim.ycoord);
          IF object.GetWorld() THEN
            object.GetCoordStrings(areadim.xcoords,areadim.ycoords);
          ELSE
            bool:=tt.RealToString(areadim.xcoord,areadim.xcoords,FALSE);
            bool:=tt.RealToString(areadim.ycoord,areadim.ycoords,FALSE);
          END;
          areadim.ycoords:="";
          areadim.ycoord:=0;
        END;
      END;
    END;
  END;
END SetObject;



TYPE Area * = POINTER TO AreaDesc;
     AreaDesc * = RECORD(m.ChangeAbleDesc)
       window  - : w.Window;
       coords  - : co.CoordSystem;
       graphobjects - : gob.GraphObjectList; (* Same as window.graphobjects. *)
       name    * : ARRAY 80 OF CHAR;
       dims    * : m.MTList;    (* List of AreaDims *)
       pattern * ,
       colorf  * ,
       colorb  * : INTEGER;
       clearb  * ,            (* Cleare background (or transparent) *)
       areab   * : BOOLEAN;   (* Move area behind function graphs *)
       newobject*: BOOLEAN;
     END;

PROCEDURE (area:Area) Init*;

BEGIN
  area.Init^;
  area.name:="Area";
  area.dims:=m.Create();
  area.pattern:=0;
  area.colorf:=3;
  area.colorb:=0;
  area.clearb:=TRUE;
  area.areab:=TRUE;
  area.newobject:=TRUE;
END Init;

PROCEDURE (area:Area) InitArea*(window:w.Window;coords:co.CoordSystem;graphobjects:gob.GraphObjectList);

BEGIN
  area.window:=window;
  area.coords:=coords;
  area.graphobjects:=graphobjects;
END InitArea;

PROCEDURE (area:Area) Destruct*;

BEGIN
  IF area.dims#NIL THEN area.dims.Destruct; END;
  area.Destruct^;
END Destruct;

PROCEDURE * PrintArea*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=datalist.GetNode(num);
  IF node#NIL THEN
    WITH node: Area DO
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintArea;

PROCEDURE (area:Area) GraphObjectChanged*(object:m.ShareAble);
(* Call this procedure whenever a graphobject was changed. [graphobject]
   must contain a pointer to the changed graphobject. *)

VAR dim  : l.Node;
    task : m.Task;

BEGIN
  area.dims.Lock(TRUE);
  dim:=area.dims.head;
  WHILE dim#NIL DO
    IF dim(AreaDim).object=object THEN
      dim(AreaDim).SetObject(object);

(* Don't use this or the related GraphWindow will always get a
   Refreshmessage *)
(*      area.SendNewMsgToAllTasks(m.msgNodeChanged,object);*)
      task:=area.FindTask(tid.changeTaskID);
      IF task#NIL THEN
        task.SendNewMsg(m.msgNodeChanged,object);
      END;

      dim:=NIL;
    END;
    IF dim#NIL THEN dim:=dim.next; END;
  END;
  area.dims.UnLock;
END GraphObjectChanged;

PROCEDURE (area:Area) Plot*(rast:g.RastPortPtr;coord:co.CoordSystem;rect:co.Rectangle;conv:dc.ConversionTable;setwide:BOOLEAN);
(* Settings if called by GraphWindow:                                                                         FALSE          *)
(* setwide: Set to TRUE to make the area pattern larger. Use this for
            high resolutions. *)

VAR raster     : s.ADDRESS;
    temp       : g.TmpRas;
    areainfo   : g.AreaInfo;
    data       : s.ADDRESS;
    xpos,ypos  : INTEGER;
    minx,maxx,
    miny,maxy,
    step,x,y   : LONGREAL;
    node,node2 : l.Node;
    xyarray    : POINTER TO ARRAY OF ARRAY OF INTEGER;
    picx,picy,
    picxmin,
    picxmax,
    picymin,
    picymax,
    pos        : INTEGER;
    bool       : BOOLEAN;
    incup,
    inclow     : BOOLEAN;
    layoutplot : BOOLEAN;

PROCEDURE GetMinMaxX(max:BOOLEAN):LONGREAL;

VAR val,real : LONGREAL;

BEGIN
  IF NOT(max) THEN
    val:=MIN(LONGREAL);
  ELSE
    val:=MAX(LONGREAL);
  END;
  node:=area.dims.head;
  WHILE node#NIL DO
    WITH node: AreaDim DO
      IF (node.type=1) OR (node.type=2) OR (node.type=5) OR (node.type=6) THEN
        IF ((node.right) AND NOT(max)) OR ((node.left) AND (max)) THEN
          real:=0;
          IF node.type=1 THEN
            real:=0;
          ELSE
            real:=node.xcoord;
          END;
          IF (real>val) AND NOT(max) THEN
            val:=real;
          ELSIF (real<val) AND max THEN
            val:=real;
          END;
        END;
      END;
    END;
    node:=node.next;
  END;
  RETURN val;
END GetMinMaxX;

PROCEDURE GetYBorder(x:LONGREAL;VAR lower,upper:LONGREAL;VAR inclower,incupper:BOOLEAN);

VAR up,low,func : LONGREAL;
    pos         : INTEGER;

BEGIN
  upper:=MAX(LONGREAL);
  lower:=MIN(LONGREAL);
  incupper:=FALSE;
  inclower:=FALSE;
  node:=area.dims.head;
  WHILE node#NIL DO
    WITH node: AreaDim DO
      IF (node.type=0) OR (node.type=3) OR (node.type=4) OR (node.type=5) THEN
        up:=MAX(LONGREAL);
        low:=MIN(LONGREAL);
        IF node.type=0 THEN
          IF node.up THEN
            low:=0;
          ELSIF node.down THEN
            up:=0;
          END;
        ELSIF node.type=3 THEN
          IF node.up THEN
            low:=node.ycoord;
          ELSIF node.down THEN
            up:=node.ycoord;
          END;
        ELSIF node.type=4 THEN
          func:=ft.CalcLong(node.root,x,0,pos);
          IF node.up THEN
            low:=func;
          ELSIF node.down THEN
            up:=func;
          END;
        ELSIF node.type=5 THEN
          IF node.up THEN
            low:=node.ycoord;
          ELSIF node.down THEN
            up:=node.ycoord;
          END;
        END;
        IF up<upper THEN
          upper:=up;
          incupper:=node.include;
        END;
        IF low>lower THEN
          lower:=low;
          inclower:=node.include;
        END;
      END;
    END;
    node:=node.next;
  END;
END GetYBorder;

BEGIN
  WITH coord: co.CartesianSystem DO
    area.Lock(FALSE);
(* Note: Areas are never plotted in the dragbar. *)
    IF rast#area.window.rast THEN layoutplot:=TRUE;
                             ELSE layoutplot:=FALSE; END;

    node:=area.dims.head;
    WHILE node#NIL DO
      pos:=0;
      node(AreaDim).root:=ft.Parse(node(AreaDim).string);
      node:=node.next;
    END;

    minx:=GetMinMaxX(FALSE);
    maxx:=GetMinMaxX(TRUE);
    IF minx<coord.xmin THEN
      minx:=coord.xmin;
    END;
    IF maxx>coord.xmax THEN
      maxx:=coord.xmax;
    END;
    step:=coord.xmax-coord.xmin;
(*      step:=step/p.stutz;*)
(* New: Always step one pixel! *)
    step:=step/rect.width;

    IF setwide THEN
      g.SetAfPt(rast,s.ADR(go.areas[area.pattern].widepat),4);
    ELSE
      g.SetAfPt(rast,s.ADR(go.areas[area.pattern].pattern),4);
    END;
    g.SetAPen(rast,conv.GetColor(area.colorf,dc.graphType));
    g.SetBPen(rast,conv.GetColor(area.window.backcol,dc.standardType));
    IF area.clearb THEN
      g.SetDrMd(rast,g.jam2);
    ELSE
      g.SetDrMd(rast,g.jam1);
    END;

    x:=minx-step;
    pos:=-1;
    coord.WorldToPic(rect,minx,miny,picxmin,picymin);
    coord.WorldToPic(rect,maxx,miny,picxmax,picymin);
    xpos:=picxmin-1;
    WHILE xpos<picxmax DO
      INC(xpos);
      x:=x+step;
      coord.PicToWorld(rect,xpos,ypos,x,y);
      GetYBorder(x,miny,maxy,inclow,incup);
      IF miny<coord.ymin THEN
        miny:=coord.ymin;
      END;
      IF maxy>coord.ymax THEN
        maxy:=coord.ymax;
      END;
      IF miny<maxy THEN
        coord.WorldToPic(rect,x,miny,picx,picymin);
        coord.WorldToPic(rect,x,maxy,picx,picymax);
        IF picymax<picymin THEN
          g.RectFill(rast,xpos,picymax+1,xpos,picymin);
        END;
      END;
    END;

    g.SetAfPt(rast,NIL,0);

    area.UnLock;
  END;
END Plot;



VAR areawind * : wm.Window;

(* Spaceobject *)

TYPE AreaGadget * = POINTER TO AreaGadgetDesc;
     AreaGadgetDesc * = RECORD(gmb.GadgetDesc)
       actdim   : l.Node;
       sinarray : POINTER TO ARRAY OF LONGREAL;
     END;

PROCEDURE (gad:AreaGadget) Destruct*;

BEGIN
  IF gad.sinarray#NIL THEN DISPOSE(gad.sinarray); gad.sinarray:=NIL; END;
  gad.Destruct^;
END Destruct;

PROCEDURE (text:AreaGadget) Init*;

BEGIN
  text.width:=text.minwi;
  text.height:=text.minhe;
  IF text.autoout THEN
    text.topout:=SHORT(SHORT(text.font.ySize/8+0.5));
    text.leftout:=SHORT(SHORT(text.font.ySize/2+0.5));
  END;
  text.Init^;
END Init;

PROCEDURE (text:AreaGadget) Resize*;

BEGIN
END Resize;

PROCEDURE (gad:AreaGadget) RefreshSide*;

VAR rast    : g.RastPortPtr;
    i       : LONGINT;
    actdim  : AreaDim;
    xm,ym   : INTEGER; (* Pixel coordinate of origin of coordinate system *)
    xv,yv   : INTEGER; (* Pixel coordinate where e.g. a point is displayed. *)
    x,y     : INTEGER;
    real    : LONGREAL;
    calc    : BOOLEAN;

BEGIN
  IF gad.root.iwind#NIL THEN
    gad.iwind:=gad.root.iwind;
    rast:=gad.iwind.rPort;

    IF gad.actdim#NIL THEN
      actdim:=gad.actdim(AreaDim);
      xm:=gad.xpos+(gad.width DIV 2);
      ym:=gad.ypos+(gad.height DIV 2);
      xv:=xm+gad.width DIV 5;
      yv:=ym-gad.height DIV 5;

      g.SetDrMd(rast,SHORTSET{g.complement});
      IF actdim.type=0 THEN
        IF actdim.up THEN g.RectFill(rast,gad.xpos+2,gad.ypos+1,gad.xpos+gad.width-5,ym-1);
        ELSIF actdim.down THEN g.RectFill(rast,gad.xpos+2,ym+1,gad.xpos+gad.width-5,gad.ypos+gad.height-3); END;
      ELSIF actdim.type=1 THEN
        IF actdim.left THEN g.RectFill(rast,gad.xpos+2,gad.ypos+1,xm-1,gad.ypos+gad.height-3);
        ELSIF actdim.right THEN g.RectFill(rast,xm+1,gad.ypos+1,gad.xpos+gad.width-5,gad.ypos+gad.height-3); END;
      ELSIF actdim.type=2 THEN
        IF actdim.left THEN g.RectFill(rast,gad.xpos+2,gad.ypos+1,xv-1,gad.ypos+gad.height-3);
        ELSIF actdim.right THEN g.RectFill(rast,xv+1,gad.ypos+1,gad.xpos+gad.width-5,gad.ypos+gad.height-3); END;
      ELSIF actdim.type=3 THEN
        IF actdim.up THEN g.RectFill(rast,gad.xpos+2,gad.ypos+1,gad.xpos+gad.width-5,yv-1);
        ELSIF actdim.down THEN g.RectFill(rast,gad.xpos+2,yv+1,gad.xpos+gad.width-5,gad.ypos+gad.height-3); END;
      ELSIF actdim.type=4 THEN
        IF (gad.sinarray=NIL) OR (LEN(gad.sinarray^)#gad.xpos+gad.width-5-gad.xpos-3+1) THEN
          NEW(gad.sinarray,gad.xpos+gad.width-5-gad.xpos-3+1);
          calc:=TRUE;
        ELSE
          calc:=FALSE;
        END;
        x:=gad.xpos+3;
        i:=0;
        WHILE x<=gad.xpos+gad.width-5 DO
          IF calc THEN
            real:=ml.SIN((x-gad.xpos)/gad.width*12.56);
            gad.sinarray[i]:=real;
          ELSE
            real:=gad.sinarray[i];
          END;
          y:=SHORT(SHORT(SHORT(real*(gad.height DIV 3))));
          IF actdim.up THEN
            g.Move(rast,x,gad.ypos+1);
            g.Draw(rast,x,ym+y-1);
          ELSE
            g.Move(rast,x,ym+y+1);
            g.Draw(rast,x,gad.ypos+gad.height-3);
          END;
          INC(x);
          INC(i);
        END;
      ELSIF actdim.type=5 THEN
        IF actdim.up THEN
          IF actdim.right THEN g.RectFill(rast,xv+1,gad.ypos+1,gad.xpos+gad.width-5,yv-1);
          ELSIF actdim.left THEN g.RectFill(rast,gad.xpos+3,gad.ypos+1,xv-1,yv-1); END;
        ELSIF actdim.down THEN
          IF actdim.right THEN g.RectFill(rast,xv+1,yv+1,gad.xpos+gad.width-5,gad.ypos+gad.height-3);
          ELSIF actdim.left THEN g.RectFill(rast,gad.xpos+3,yv+1,xv-1,gad.ypos+gad.height-3); END;
        END;
      ELSIF actdim.type=6 THEN
        IF actdim.left THEN g.RectFill(rast,gad.xpos+2,gad.ypos+1,xv-1,gad.ypos+gad.height-3);
        ELSIF actdim.right THEN g.RectFill(rast,xv+1,gad.ypos+1,gad.xpos+gad.width-5,gad.ypos+gad.height-3); END;
      END;
      g.SetDrMd(rast,g.jam2);
    END;
  END;
END RefreshSide;

PROCEDURE (gad:AreaGadget) Refresh*;

VAR rast    : g.RastPortPtr;
    str     : UNTRACED POINTER TO ARRAY OF CHAR;
    i       : LONGINT;
    pattern : ARRAY 4 OF INTEGER;
    actdim  : AreaDim;
    xm,ym   : INTEGER; (* Pixel coordinate of origin of coordinate system *)
    xv,yv   : INTEGER; (* Pixel coordinate where e.g. a point is displayed. *)
    x,y     : INTEGER;
    real    : LONGREAL;
    calc    : BOOLEAN;

  PROCEDURE PlotAxis(markx,marky:BOOLEAN);

  BEGIN
    IF markx THEN
      g.SetAPen(rast,2);
    ELSE
      g.SetAPen(rast,1);
    END;
    g.Move(rast,gad.xpos+2,ym);
    g.Draw(rast,gad.xpos+gad.width-5,ym);
    vt.DrawVectorObject(rast,go.arrows[0],gad.xpos+gad.width-5,ym,mg.mathconv.GetStdPicX(),mg.mathconv.GetStdPicY(),0,1,1);

    IF marky THEN
      g.SetAPen(rast,2);
    ELSE
      g.SetAPen(rast,1);
    END;
    g.Move(rast,xm,gad.ypos+1);
    g.Draw(rast,xm,gad.ypos+gad.height-3);
    vt.DrawVectorObject(rast,go.arrows[0],xm,gad.ypos+1,mg.mathconv.GetStdPicX(),mg.mathconv.GetStdPicY(),90,1,1);
  END PlotAxis;

BEGIN
  IF gad.root.iwind#NIL THEN
    gad.iwind:=gad.root.iwind;
    rast:=gad.iwind.rPort;

    g.SetAPen(rast,0);
    g.RectFill(rast,gad.xpos+2,gad.ypos+1,gad.xpos+gad.width-5,gad.ypos+gad.height-3);

    gd.DrawBevelBox(rast,gad.xpos,gad.ypos,gad.width,gad.height,
                                           gd.bbFrameType,gd.bbftButton,
                                           gd.visualInfo,gad.root.vinfo,
                                           u.done);

    IF gad.actdim=NIL THEN
      pattern[0]:=0AAAAU;
      pattern[2]:=0AAAAU;
      pattern[1]:=05555U;
      pattern[3]:=05555U;
      g.SetAfPt(rast,s.ADR(pattern),1);
      g.SetAPen(rast,3);
      g.RectFill(rast,gad.xpos+2,gad.ypos+1,gad.xpos+gad.width-5,gad.ypos+gad.height-3);
      g.SetAfPt(rast,NIL,0);
    ELSE
      actdim:=gad.actdim(AreaDim);
      xm:=gad.xpos+(gad.width DIV 2);
      ym:=gad.ypos+(gad.height DIV 2);
      xv:=xm+gad.width DIV 5;
      yv:=ym-gad.height DIV 5;
      IF actdim.type=0 THEN
        PlotAxis(TRUE,FALSE);
      ELSIF actdim.type=1 THEN
        PlotAxis(FALSE,TRUE);
      ELSIF actdim.type=2 THEN
        PlotAxis(FALSE,FALSE);
        g.SetAPen(rast,2);
        g.Move(rast,xv,gad.ypos+1);
        g.Draw(rast,xv,gad.ypos+gad.height-3);
      ELSIF actdim.type=3 THEN
        PlotAxis(FALSE,FALSE);
        g.SetAPen(rast,2);
        g.Move(rast,gad.xpos+3,yv);
        g.Draw(rast,gad.xpos+gad.width-5,yv);
      ELSIF actdim.type=4 THEN
        PlotAxis(FALSE,FALSE);
        IF (gad.sinarray=NIL) OR (LEN(gad.sinarray^)#gad.xpos+gad.width-5-gad.xpos-3+1) THEN
          IF gad.sinarray#NIL THEN DISPOSE(gad.sinarray); END;
          NEW(gad.sinarray,gad.width-5-3+1);
          calc:=TRUE;
        ELSE
          calc:=FALSE;
        END;
        g.SetAPen(rast,2);
        x:=gad.xpos+3;
        i:=0;
        WHILE x<=gad.xpos+gad.width-5 DO
          IF calc THEN
            real:=ml.SIN((x-gad.xpos)/gad.width*12.56);
            gad.sinarray[i]:=real;
          ELSE
            real:=gad.sinarray[i];
          END;
          y:=SHORT(SHORT(SHORT(real*(gad.height DIV 3))));
          IF x=gad.xpos+3 THEN
            g.Move(rast,x,ym+y);
          ELSE
            g.Draw(rast,x,ym+y);
          END;
          INC(x);
          INC(i);
        END;
      ELSIF actdim.type=5 THEN
        PlotAxis(FALSE,FALSE);
        g.SetAPen(rast,2);
        g.Move(rast,xv,gad.ypos+1);
        g.Draw(rast,xv,gad.ypos+gad.height-3);
        g.Move(rast,gad.xpos+3,yv);
        g.Draw(rast,gad.xpos+gad.width-5,yv);
        tt.Print(xv+2,yv-2-rast.txHeight+rast.txBaseline,s.ADR("P(x|y)"),rast);
        g.SetAPen(rast,1);
        y:=rast.txHeight DIV 3;
        g.Move(rast,xv,yv-y);
        g.Draw(rast,xv,yv+y);
        g.Move(rast,xv-y,yv);
        g.Draw(rast,xv+y,yv);
      ELSIF actdim.type=6 THEN
        PlotAxis(FALSE,FALSE);
        g.SetAPen(rast,2);
        g.Move(rast,xv,gad.ypos+1);
        g.Draw(rast,xv,gad.ypos+gad.height-3);
        tt.Print(xv+2,yv,s.ADR("M x=a"),rast);
      END;
      gad.RefreshSide;
    END;
  END;
END Refresh;

PROCEDURE (area:AreaGadget) SetAreaDim*(actdim:l.Node);

BEGIN
  area.actdim:=actdim;
  area.Refresh;
END SetAreaDim;

PROCEDURE SetAreaGadget*(actdim:l.Node):AreaGadget;

VAR gad       : I.GadgetPtr;
    node      : l.Node;
    maxx,maxy : BOOLEAN;

BEGIN
  node:=NIL;
  NEW(node(AreaGadget));
  IF node#NIL THEN
    gmb.AddObject(node);
    WITH node: AreaGadget DO
      node.text:=NIL;
      node.font:=gmb.font;
      node.disabled:=FALSE;
      node.sizex:=1;
      node.sizey:=1;
      node.minwi:=20;
      node.minhe:=20;
      node.userminwi:=0;
      node.userminhe:=0;
      node.autoout:=TRUE;
      node.root:=gmb.actroot;
      node.subwind:=node.root.subwind;
    END;
  END;
  RETURN node(AreaGadget);
END SetAreaGadget;

PROCEDURE (gad:AreaGadget) InputEvent*(mes:I.IntuiMessagePtr);

VAR actdim  : AreaDim;
    x,y     : INTEGER;
    xm,ym   : INTEGER; (* Pixel coordinate of origin of coordinate system *)
    xv,yv   : INTEGER; (* Pixel coordinate where e.g. a point is displayed. *)

BEGIN
  IF (~gad.disabled) & (gad.actdim#NIL) THEN
    IF I.mouseButtons IN mes.class THEN
      IF mes.code=I.selectDown THEN
        x:=mes.mouseX; y:=mes.mouseY;
        IF (x>=gad.xpos) & (x<gad.xpos+gad.width) & (y>=gad.ypos) & (y<gad.ypos+gad.height) THEN
          actdim:=gad.actdim(AreaDim);
          xm:=gad.xpos+(gad.width DIV 2);
          ym:=gad.ypos+(gad.height DIV 2);
          xv:=xm+gad.width DIV 5;
          yv:=ym-gad.height DIV 5;
          gad.RefreshSide;
          IF actdim.type=0 THEN
            IF y<ym THEN actdim.up:=TRUE;
                         actdim.down:=FALSE; END;
            IF y>ym THEN actdim.up:=FALSE;
                         actdim.down:=TRUE; END;
          ELSIF actdim.type=1 THEN
            IF x<xm THEN actdim.left:=TRUE;
                         actdim.right:=FALSE; END;
            IF x>xm THEN actdim.left:=FALSE;
                         actdim.right:=TRUE; END;
          ELSIF actdim.type=2 THEN
            IF x<xv THEN actdim.left:=TRUE;
                         actdim.right:=FALSE; END;
            IF x>xv THEN actdim.left:=FALSE;
                         actdim.right:=TRUE; END;
          ELSIF actdim.type=3 THEN
            IF y<yv THEN actdim.up:=TRUE;
                         actdim.down:=FALSE; END;
            IF y>yv THEN actdim.up:=FALSE;
                         actdim.down:=TRUE; END;
          ELSIF actdim.type=4 THEN
            xv:=x-gad.xpos-3;
            IF xv<0 THEN xv:=0;
            ELSIF xv>=LEN(gad.sinarray^) THEN xv:=SHORT(LEN(gad.sinarray^)-1); END;
            yv:=ym+SHORT(SHORT(SHORT(gad.sinarray[xv]*(gad.height DIV 3))));
            IF y<yv THEN actdim.up:=TRUE;
                         actdim.down:=FALSE; END;
            IF y>yv THEN actdim.up:=FALSE;
                         actdim.down:=TRUE; END;
          ELSIF actdim.type=5 THEN
            IF x<xv THEN actdim.left:=TRUE;
                         actdim.right:=FALSE; END;
            IF x>xv THEN actdim.left:=FALSE;
                         actdim.right:=TRUE; END;
            IF y<yv THEN actdim.up:=TRUE;
                         actdim.down:=FALSE; END;
            IF y>yv THEN actdim.up:=FALSE;
                         actdim.down:=TRUE; END;
          ELSIF actdim.type=6 THEN
            IF x<xv THEN actdim.left:=TRUE;
                         actdim.right:=FALSE; END;
            IF x>xv THEN actdim.left:=FALSE;
                         actdim.right:=TRUE; END;
          END;
          mes.iAddress:=gad;
          mes.class:=LONGSET{I.gadgetUp};
          gad.RefreshSide;
        END;
      END;
    END;
  END;
END InputEvent;



PROCEDURE (area:Area) Change(changetask:m.Task):BOOLEAN;

VAR subwind   : wm.SubWindow;
    wind      : I.WindowPtr;
    rast      : g.RastPortPtr;
    root      : gmb.Root;
    dimslv    : gmo.ListView;
    newdim,
    deldim    : gmo.BooleanGadget;
    dimtype   : gmo.RadioButtons;
    areagad   : AreaGadget;
    dimdir    : gmo.CycleGadget;
    selobject : gmo.BooleanGadget;
    objecttext: gmo.Text;
    areaname,
    objectname,
    xgad,ygad : gmo.StringGadget;
    palette   : gmo.PaletteGadget;
    pattern   : gmo.SelectBox;
    clearback,
    areaback  : gmo.CheckboxGadget;
    gadobj    : gmb.Object;
    glist     : I.GadgetPtr;
    mes       : I.IntuiMessagePtr;
    class     : LONGSET;
    msg       : m.Message;
    dimtypearray : ARRAY 8 OF e.STRPTR;
    dimdirarray  : ARRAY 5 OF e.STRPTR;

    actdim,
    node      : l.Node;
    bool,ret,
    didchange,
    sendchange: BOOLEAN; (* Set to TRUE by some local procedures if the
                            window (to which this area belongs) must be
                            informed of some changes. *)

PROCEDURE RefreshDims;

BEGIN
  IF actdim#NIL THEN
    dimslv.SetString(actdim(AreaDim).name);
    dimslv.SetValue(area.dims.GetNodeNumber(actdim));
  ELSE
    dimslv.Refresh;
  END;
END RefreshDims;

PROCEDURE RefreshInputGadgets;
(* Refreshes the gadgets with which you can select a function, enter
   x- resp. y-values *)

BEGIN
  IF actdim#NIL THEN
    WITH actdim: AreaDim DO
      IF (actdim.type=0) OR (actdim.type=1) THEN
        objectname.SetText(s.ADR(" "));
        objectname.Disable(TRUE);
        xgad.Disable(TRUE);
        ygad.Disable(TRUE);
      ELSIF (actdim.type=2) THEN
        objectname.SetText(s.ADR(" "));
        objectname.Disable(TRUE);
        xgad.Disable(FALSE);
        ygad.Disable(TRUE);
      ELSIF (actdim.type=3) THEN
        objectname.SetText(s.ADR(" "));
        objectname.Disable(TRUE);
        xgad.Disable(TRUE);
        ygad.Disable(FALSE);
      ELSIF (actdim.type=4) THEN (* Function *)
        objecttext.SetText(ac.GetString(ac.Function));
        objectname.Disable(FALSE);
        xgad.Disable(TRUE);
        ygad.Disable(TRUE);
        objectname.SetString(actdim.string);
      ELSIF (actdim.type=5) THEN (* Point *)
        objecttext.SetText(ac.GetString(ac.Point));
        objectname.Disable(FALSE);
        xgad.Disable(FALSE);
        ygad.Disable(FALSE);
        IF actdim.object#NIL THEN
          objectname.SetString(actdim.object(gob.GraphObject).string);
        ELSE
          objectname.SetString("");
        END;
      ELSIF (actdim.type=6) THEN (* Marking *)
        objecttext.SetText(ac.GetString(ac.Marker));
        objectname.Disable(FALSE);
        xgad.Disable(FALSE);
        ygad.Disable(TRUE);
        IF actdim.object#NIL THEN
          objectname.SetString(actdim.object(gob.GraphObject).string);
        ELSE
          objectname.SetString("");
        END;
      END;
      objecttext.Refresh;
      xgad.SetString(actdim.xcoords);
      ygad.SetString(actdim.ycoords);
    END;
  END;
END RefreshInputGadgets;

PROCEDURE SetData;

BEGIN
  areagad.SetAreaDim(actdim);
  IF actdim#NIL THEN
    WITH actdim: AreaDim DO
      dimtype.SetValue(actdim.type);
      RefreshInputGadgets;
    END;
  END;
END SetData;

PROCEDURE GetInput;

VAR oldstr  : ARRAY 256 OF CHAR;
    oldreal : LONGREAL;
    list    : l.List;
    node    : l.Node;

BEGIN
  IF actdim#NIL THEN
    WITH actdim: AreaDim DO
      dimslv.GetString(actdim.name);
      actdim.type:=SHORT(dimtype.GetValue());

      COPY(actdim.string,oldstr);
      objectname.GetString(actdim.string);
      IF ~tt.Compare(actdim.string,oldstr) THEN

(* Getting pointer to new object *)

        IF actdim.type=4 THEN
          (* New function, needs no pointer *)
          actdim.SetObject(NIL);
          sendchange:=TRUE;
        ELSIF actdim.type=5 THEN
          node:=area.graphobjects.head;
          WHILE node#NIL DO
            IF node IS pmo.PointObject THEN
              IF tt.Compare(node(pmo.PointObject).string,actdim.string) THEN
                actdim.SetObject(node);
                RefreshInputGadgets;
                node:=NIL;
                sendchange:=TRUE;
              END;
            END;
            IF node#NIL THEN node:=node.next; END;
          END;
        ELSIF actdim.type=6 THEN
          node:=area.graphobjects.head;
          WHILE node#NIL DO
            IF node IS pmo.MarkObject THEN
              IF tt.Compare(node(pmo.MarkObject).string,actdim.string) THEN
                actdim.SetObject(node);
                RefreshInputGadgets;
                node:=NIL;
                sendchange:=TRUE;
              END;
            END;
            IF node#NIL THEN node:=node.next; END;
          END;
        END;
      END;

      oldreal:=actdim.xcoord;
      xgad.GetString(actdim.xcoords); actdim.xcoord:=xgad.real;
      IF oldreal#actdim.xcoord THEN sendchange:=TRUE; END;

      oldreal:=actdim.ycoord;
      ygad.GetString(actdim.ycoords); actdim.ycoord:=ygad.real;
      IF oldreal#actdim.ycoord THEN sendchange:=TRUE; END;

      area.colorf:=SHORT(palette.GetValue());
      area.pattern:=SHORT(pattern.GetValue());
      area.clearb:=clearback.Checked();
      area.areab:=areaback.Checked();
    END;
  END;
END GetInput;

PROCEDURE RefreshDimDir;
(* Updates dimdir-gadget to changed actdim *)

BEGIN
  IF actdim#NIL THEN
    WITH actdim: AreaDim DO
      IF actdim.type=0 THEN
        dimdirarray[0]:=ac.GetString(ac.AboveXAxis);
        dimdirarray[1]:=ac.GetString(ac.BelowXAxis);
        dimdirarray[2]:=NIL;
        dimdir.Change(s.ADR(dimdirarray),0);
        IF actdim.up THEN dimdir.SetValue(0);
                     ELSE dimdir.SetValue(1); END;
      ELSIF actdim.type=1 THEN
        dimdirarray[0]:=ac.GetString(ac.RightOfYAxis);
        dimdirarray[1]:=ac.GetString(ac.LeftOfYAxis);
        dimdirarray[2]:=NIL;
        dimdir.Change(s.ADR(dimdirarray),0);
        IF actdim.right THEN dimdir.SetValue(0);
                        ELSE dimdir.SetValue(1); END;
      ELSIF actdim.type=2 THEN
        dimdirarray[0]:=ac.GetString(ac.RightOfXValue);
        dimdirarray[1]:=ac.GetString(ac.LeftOfXValue);
        dimdirarray[2]:=NIL;
        dimdir.Change(s.ADR(dimdirarray),0);
        IF actdim.right THEN dimdir.SetValue(0);
                        ELSE dimdir.SetValue(1); END;
      ELSIF actdim.type=3 THEN
        dimdirarray[0]:=ac.GetString(ac.AboveYValue);
        dimdirarray[1]:=ac.GetString(ac.BelowYValue);
        dimdirarray[2]:=NIL;
        dimdir.Change(s.ADR(dimdirarray),0);
        IF actdim.up THEN dimdir.SetValue(0);
                     ELSE dimdir.SetValue(1); END;
      ELSIF actdim.type=4 THEN
        dimdirarray[0]:=ac.GetString(ac.AboveFunction);
        dimdirarray[1]:=ac.GetString(ac.BelowFunction);
        dimdirarray[2]:=NIL;
        dimdir.Change(s.ADR(dimdirarray),0);
        IF actdim.up THEN dimdir.SetValue(0);
                     ELSE dimdir.SetValue(1); END;
      ELSIF actdim.type=5 THEN
        dimdirarray[0]:=ac.GetString(ac.RightAboveP);
        dimdirarray[1]:=ac.GetString(ac.LeftAboveP);
        dimdirarray[2]:=ac.GetString(ac.RightBelowP);
        dimdirarray[3]:=ac.GetString(ac.LeftBelowP);
        dimdirarray[4]:=NIL;
        dimdir.Change(s.ADR(dimdirarray),0);
        IF actdim.up THEN
          IF actdim.right THEN dimdir.SetValue(0);
                          ELSE dimdir.SetValue(1); END;
        ELSIF actdim.down THEN
          IF actdim.right THEN dimdir.SetValue(2);
                          ELSE dimdir.SetValue(3); END;
        END;
      ELSIF actdim.type=6 THEN
        dimdirarray[0]:=ac.GetString(ac.RightOfMarker);
        dimdirarray[1]:=ac.GetString(ac.LeftOfMarker);
        dimdirarray[2]:=NIL;
        dimdir.Change(s.ADR(dimdirarray),0);
        IF actdim.right THEN dimdir.SetValue(0);
                        ELSE dimdir.SetValue(1); END;
      END;
    END;
  END;
END RefreshDimDir;

PROCEDURE AdaptDimName;
(* Changes actdim.name if the user selects another dim-type. *)

BEGIN
  IF actdim#NIL THEN
    WITH actdim: AreaDim DO
      CASE actdim.type OF
      | 0 : COPY(ac.GetString(ac.XAxis)^,actdim.name);
      | 1 : COPY(ac.GetString(ac.YAxis)^,actdim.name);
      | 2 : COPY(ac.GetString(ac.XValue)^,actdim.name);
      | 3 : COPY(ac.GetString(ac.YValue)^,actdim.name);
      | 4 : COPY(ac.GetString(ac.Function)^,actdim.name);
      | 5 : COPY(ac.GetString(ac.Point)^,actdim.name);
      | 6 : COPY(ac.GetString(ac.Marker)^,actdim.name);
      ELSE
      END;
    END;
  END;
END AdaptDimName;

BEGIN
  t.functions.NewUser(changetask,TRUE);
  area.graphobjects.NewUser(changetask,TRUE);
  NEW(mes);
  ret:=FALSE;
  IF areawind=NIL THEN
    areawind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.ChangeHatching),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=areawind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmb.NewBox(gmb.horizBox,gd.bbftButton,FALSE,ac.GetString(ac.HatchingBounds));
      gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
        dimslv:=gmo.SetListView(ac.GetString(ac.BoundaryElements),area.dims,PrintAreaDim,0,TRUE,79);
        newdim:=gmo.SetBooleanGadget(ac.GetString(ac.NewElement),FALSE);
        deldim:=gmo.SetBooleanGadget(ac.GetString(ac.DelElement),FALSE);

        dimtypearray[0]:=ac.GetString(ac.XAxis);
        dimtypearray[1]:=ac.GetString(ac.YAxis);
        dimtypearray[2]:=ac.GetString(ac.XValue);
        dimtypearray[3]:=ac.GetString(ac.YValue);
        dimtypearray[4]:=ac.GetString(ac.Function);
        dimtypearray[5]:=ac.GetString(ac.Point);
        dimtypearray[6]:=ac.GetString(ac.Marker);
        dimtypearray[7]:=NIL;
        dimtype:=gmo.SetRadioButtons(s.ADR(dimtypearray),0);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
        areaname:=gmo.SetStringGadget(ac.GetString(ac.HatchingName),79,gmo.stringType);

        areagad:=SetAreaGadget(area.dims.head);
        dimdirarray[0]:=ac.GetString(ac.NoElementSelected);
        dimdirarray[1]:=NIL;
        dimdir:=gmo.SetCycleGadget(NIL,s.ADR(dimdirarray),0);

        gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
          objecttext:=gmo.SetText(ac.GetString(ac.Marker),-1);
          objecttext.SetSizeY(0);
          objectname:=gmo.SetStringGadget(NIL,255,gmo.stringType);
          objectname.SetMinVisible(10);
          objectname.SetSizeY(-1);
          selobject:=gmo.SetBooleanGadget(s.ADR("A"),FALSE);
          selobject.SetSizeY(-1);
          selobject.SetOutValues(0,0);
        gmb.EndBox;
        gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
          xgad:=gmo.SetStringGadget(s.ADR("x"),255,gmo.realType);
          xgad.SetMinVisible(5);
          ygad:=gmo.SetStringGadget(s.ADR("y"),255,gmo.realType);
          ygad.SetMinVisible(5);
        gmb.EndBox;
      gmb.EndBox;
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.horizBox,gd.bbftButton,FALSE,ac.GetString(ac.HatchingDesign));
      gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
        palette:=gmo.SetPaletteGadget(ac.GetString(ac.Color),mg.screenmode.depth,s.LSH(1,mg.screenmode.depth),area.colorf);
        clearback:=gmo.SetCheckboxGadget(ac.GetString(ac.ClearBackground),area.clearb);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
        pattern:=gmo.SetSelectBox(ac.GetString(ac.Pattern),7,area.pattern,7,1,30,20,-1,gmo.horizOrient,go.PlotAreaPattern);
        areaback:=gmo.SetCheckboxGadget(ac.GetString(ac.HatchingToTheBack),area.areab);
      gmb.EndBox;
    gmb.EndBox;
  glist:=root.EndRoot();

  root.Init;

  areaname.SetString(area.name);

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    areaname.Activate;

    actdim:=area.dims.head;
    areagad.SetAreaDim(actdim);
    RefreshDimDir;

    didchange:=FALSE;
    sendchange:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF changetask.msgsig IN class THEN
        REPEAT
          msg:=changetask.ReceiveMsg();
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
                areaname.Activate;
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
      END;
      area.Lock(FALSE);
      REPEAT
        root.GetIMes(mes);
        IF I.gadgetUp IN mes.class THEN
          GetInput;
          IF mes.iAddress=root.ok THEN
            GetInput;
            area.window.SendNewMsg(m.msgNodeChanged,NIL);
            ret:=TRUE;
            area.UnLock;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            IF didchange THEN
              area.window.SendNewMsg(m.msgNodeChanged,NIL);
            END;

            ret:=FALSE;
            area.UnLock;
            EXIT;
          ELSIF mes.iAddress=newdim.gadget THEN
            node:=NIL;
            NEW(node(AreaDim)); node.Init;
            node(AreaDim).window:=area.window;
            area.dims.AddTail(node);
            actdim:=node;
            RefreshDims;
            RefreshDimDir;
            SetData;
            sendchange:=TRUE;
          ELSIF mes.iAddress=deldim.gadget THEN
            IF actdim#NIL THEN
              node:=actdim.next;
              IF node=NIL THEN node:=actdim.prev; END;
              actdim.Remove;
              actdim.Destruct;
              actdim:=node;
              RefreshDims;
              RefreshDimDir;
              SetData;
              sendchange:=TRUE;
            END;
          ELSIF mes.iAddress=dimslv.scrollgad THEN
            IF mes.code=gmo.newActEntry THEN
              actdim:=area.dims.GetNode(dimslv.GetValue());
              RefreshDims;
              RefreshDimDir;
              SetData;
            END;
          ELSIF mes.iAddress=dimdir.gadget THEN
            IF actdim#NIL THEN
              WITH actdim: AreaDim DO
                areagad.RefreshSide;
                IF (actdim.type=0) OR (actdim.type=3) OR (actdim.type=4) THEN
                  IF dimdir.GetValue()=0 THEN actdim.up:=TRUE; actdim.down:=FALSE;
                                         ELSE actdim.up:=FALSE; actdim.down:=TRUE; END;
                ELSIF (actdim.type=1) OR (actdim.type=2) OR (actdim.type=6) THEN
                  IF dimdir.GetValue()=0 THEN actdim.right:=TRUE; actdim.left:=FALSE;
                                         ELSE actdim.right:=FALSE; actdim.left:=TRUE; END;
                ELSIF actdim.type=5 THEN
                  IF dimdir.GetValue()=0 THEN actdim.up:=TRUE; actdim.down:=FALSE; actdim.right:=TRUE; actdim.left:=FALSE;
                  ELSIF dimdir.GetValue()=1 THEN actdim.up:=TRUE; actdim.down:=FALSE; actdim.right:=FALSE; actdim.left:=TRUE;
                  ELSIF dimdir.GetValue()=2 THEN actdim.up:=FALSE; actdim.down:=TRUE; actdim.right:=TRUE; actdim.left:=FALSE;
                  ELSIF dimdir.GetValue()=3 THEN actdim.up:=FALSE; actdim.down:=TRUE; actdim.right:=FALSE; actdim.left:=TRUE; END;
                END;
                areagad.RefreshSide;
                sendchange:=TRUE;
              END;
            END;
          ELSIF mes.iAddress=areagad THEN
            RefreshDimDir;
            sendchange:=TRUE;
          ELSIF mes.iAddress=selobject.gadget THEN
            IF actdim#NIL THEN
              WITH actdim: AreaDim DO
                IF actdim.type=4 THEN

(* IMPORTANT: You HAVE to unlock the area before you call any
              Select-Method, since they might try to lock the
              area's window. However the area's window may try
              to lock the area at the same time which will end in
              a deadlock! *)

                  area.UnLock;
                  node:=gb.SelectNode(t.functions,ac.GetString(ac.SelectFunction),ac.GetString(ac.Function),s.ADR("No functions are entered at the moment!"),mb.mathoptions.quickselect,t.PrintFunction,NIL,subwind.GetWindow());
                  area.Lock(FALSE);
                  IF node#actdim.object THEN sendchange:=TRUE; END;
                  actdim.SetObject(node);
                ELSIF actdim.type=5 THEN
                  area.window.subwindow.Activate;
                  area.window.subwindow.ToFront;
                  area.UnLock;
                  node:=area.graphobjects.Select();
                  area.Lock(FALSE);
                  IF node#NIL THEN
                    IF node IS pmo.PointObject THEN
                      IF node#actdim.object THEN sendchange:=TRUE; END;
                      actdim.SetObject(node);
                    ELSE
                      bool:=r.Request("Object is of","wrong type.","","   OK   ");
                    END;
                  END;
                ELSIF actdim.type=6 THEN
                  area.window.subwindow.Activate;
                  area.window.subwindow.ToFront;
                  area.UnLock;
                  node:=area.graphobjects.Select();
                  area.Lock(FALSE);
                  IF node#NIL THEN
                    IF node IS pmo.MarkObject THEN
                      IF node#actdim.object THEN sendchange:=TRUE; END;
                      actdim.SetObject(node);
                    ELSE
                      bool:=r.Request("Object is of","wrong type.","","   OK   ");
                    END;
                  END;
                END;
                RefreshInputGadgets;
              END;
            END;
          ELSIF NOT(mes.iAddress=root.help) THEN
            sendchange:=TRUE;
          END;
        ELSIF I.gadgetDown IN mes.class THEN
          GetInput;
          IF mes.iAddress=dimtype.gadget THEN
            IF actdim#NIL THEN
              actdim(AreaDim).SetObject(NIL);
              RefreshDimDir;
              AdaptDimName;
              RefreshDims;
              RefreshInputGadgets;
              areagad.Refresh;
              sendchange:=TRUE;
            END;
          END;
        END;
  (*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"texts",wind);
        END;*)
      UNTIL mes.class=LONGSET{};
      IF sendchange THEN
        didchange:=TRUE; area.window.SendNewMsg(m.msgNodeChanged,NIL);
        sendchange:=FALSE;
      END;
      area.UnLock;
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  area.graphobjects.FreeUser(changetask);
  t.functions.FreeUser(changetask);
  RETURN ret;
END Change;

PROCEDURE ChangeAreaTask*(changetask:bt.ANY):bt.ANY;

VAR data : Area;
    bool : BOOLEAN;

BEGIN
  WITH changetask: m.Task DO
    changetask.InitCommunication;
    data:=changetask.data(Area);
    bool:=data.Change(changetask);
  
    data.RemTask(changetask);
    changetask.ReplyAllMessages;
    changetask.DestructCommunication;
    data.FreeUser(changetask);
    mem.NodeToGarbage(changetask);
    IF (~bool) & (data.newobject) THEN
      IF data.list#NIL THEN
        data.Remove;
      END;
      data.SendNewMsgToAllTasks(m.msgQuit,NIL);
      data.ReplyAllMessages;
      data.DestructCommunication;
      mem.NodeToGarbage(data);
    ELSE
      data.newobject:=FALSE;
    END;
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END ChangeAreaTask;

PROCEDURE (area:Area) StartChangeTask*;

VAR task : m.Task;
    bool : BOOLEAN;

BEGIN
  task:=area.FindTask(tid.changeTaskID);
  IF task=NIL THEN
    NEW(task); task.Init;
    task.InitTask(ChangeAreaTask,area,10000,m.taskdata.requesterpri);
    task.SetID(tid.changeTaskID);
    area.AddTask(task);
    area.NewUser(task);
    bool:=task.Start();
  ELSE
    task.SendNewMsg(m.msgActivate,NIL);
  END;
END StartChangeTask;

END Area.

