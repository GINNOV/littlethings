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


MODULE Colors;

(* This module provides you with some functions for easy color
   handling. Starting with AmigaOS 3.0 (glib>=39) You will have
   a full color support. This module automatically switches to
   gray scaling when used with earlier AmigaOS releases.

   You have one global list containing all colors spezified. You
   can add or remove colors from this list. Each color can be used
   on several screens. Therefore you always have to provide a
   PlotInfo.PlotInfo record when calling any method of this module.
   Thus the methods know on which display (and even rastPort) you want
   to use the color. Each color may get different colorpens on different
   screens. The colorpens are stored in the pens-list of the
   color-object. The nodes in this list are of type PenNode, where
   the pennumber and the related viewport are to be found.

   Moreover this module can be used by several tasks at the same time!
   For each task requesting a color a new PenNode is allocated.
   This guaratees that no color pen is freed until no task is using
   it anymore! *)

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       u  : Utility,
       gd : GadTools,
       st : Strings,
       l  : LinkedLists,
       bt : BasicTools,
       tt : TextTools,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       m  : Multitasking,
       mem: MemoryManager,
       lb : LayoutBasics,
       pi : PlotInfo,
       ac : AnalayCatalog,
       bas: BasicTypes,
       NoGuruRq;

TYPE PenNode * = POINTER TO PenNodeDesc;
     PenNodeDesc * = RECORD(l.NodeDesc);
       view      * : g.ViewPortPtr;
       task      * : e.TaskPtr;      (* Task owning this pen *)
       pen       * : LONGINT;        (* Pen number on screen *)
       selectpen * : LONGINT;        (* Pen when displayed for selection *)
     END;



TYPE Color * = POINTER TO ColorDesc;
     ColorDesc * = RECORD(m.ShareAbleDesc)
       name      * : ARRAY 80 OF CHAR;
       red*,green* ,            (* Each value 0..255 -> 256^3=16.7E6 colors *)
       blue      * : LONGINT;
       pens      * : l.List;    (* List of PenNode *)
       used      * : BOOLEAN;
     END;

VAR colors   - : m.MTList;
    black    - ,           (* These three colors will always contain *)
    white    - ,           (* valid pointers. So you don't have to NewUser() them. *)
    stdcolor - : Color;    (* However you should to be consistent. *)

PROCEDURE (color:Color) Init*;

BEGIN
  color.Init^;
  color.pens:=l.Create();
END Init;

PROCEDURE (color:Color) Destruct*;

BEGIN
  IF color.pens#NIL THEN color.pens.Destruct; END;
  color.Destruct^;
END Destruct;

PROCEDURE AddNewColor*(name:ARRAY OF CHAR;red,green,blue:INTEGER);

VAR node : Color;

BEGIN
  NEW(node); node.Init;
  COPY(name,node.name);
  node.red:=red;
  node.green:=green;
  node.blue:=blue;
  colors.AddTail(node);
END AddNewColor;

PROCEDURE (color:Color) GetPenNode(plotinfo:pi.Display):PenNode;

VAR node : l.Node;

BEGIN
  node:=color.pens.head;
  WHILE node#NIL DO
    IF (node(PenNode).view=plotinfo.view) & (node(PenNode).task=e.SysBase.thisTask) THEN
      RETURN node(PenNode);
    END;
    node:=node.next;
  END;
  IF node=NIL THEN
    NEW(node(PenNode)); node.Init;
    node(PenNode).view:=plotinfo.view;
    node(PenNode).task:=e.SysBase.thisTask;
    node(PenNode).pen:=-1;
    node(PenNode).selectpen:=-1;
    color.pens.AddTail(node);
  END;
  IF node#NIL THEN
    RETURN node(PenNode);
  ELSE
    RETURN NIL;
  END;
END GetPenNode;

CONST setNoPen    * = 0;
      setFrontPen * = 1;
      setBackPen  * = 2;

PROCEDURE (color:Color) SetColor*(plotinfo:pi.PlotInfo;type:INTEGER):INTEGER;
(* Make color the current foreground or background color. Use this
   method instead of Graphics.SetAPen() and Graphics.SetBPen(). *)

VAR pennode : PenNode;

BEGIN
  color.used:=TRUE;
  IF ~plotinfo.display.usegreyscale THEN
    pennode:=color.GetPenNode(plotinfo.display);
    IF pennode.pen=-1 THEN
      pennode.pen:=g.ObtainBestPen(plotinfo.colormap,bt.IntToRGB(color.red),bt.IntToRGB(color.green),bt.IntToRGB(color.blue),u.done);
    END;
  ELSE
  END;
  IF type=setFrontPen THEN
    g.SetAPen(plotinfo.rast,SHORT(pennode.pen));
  ELSIF type=setBackPen THEN
    g.SetBPen(plotinfo.rast,SHORT(pennode.pen));
  END;
  RETURN SHORT(pennode.pen);
END SetColor;

PROCEDURE (color:Color) FreePen*(disp:pi.Display);
(* Call this method if no pixel on the display is of the given color.
   If you still have some pixels of this color on your screen they
   may be changed in color by Graphics. *)

VAR pennode : PenNode;

BEGIN
  pennode:=color.GetPenNode(disp);
  IF pennode#NIL THEN
    IF pennode.pen#-1 THEN
      g.ReleasePen(disp.colormap,pennode.pen);
      pennode.pen:=-1;
    END;
  END;
END FreePen;

PROCEDURE FreePens*(disp:pi.Display);
(* Same as FreePen, but frees pens of all used colors. Therefore your
   image on the screen might change in color. *)

VAR color : l.Node;

BEGIN
  color:=colors.head;
  WHILE color#NIL DO
    color(Color).FreePen(disp);
    color:=color.next;
  END;
END FreePens;

PROCEDURE (color:Color) SetColorSelect*(plotinfo:pi.PlotInfo;type:INTEGER):INTEGER;
(* Make color the current foreground or background color. Use this
   method instead of Graphics.SetAPen() and Graphics.SetBPen(). *)

VAR pennode : PenNode;

BEGIN
  color.used:=TRUE;
  IF ~plotinfo.display.usegreyscale THEN
    pennode:=color.GetPenNode(plotinfo.display);
    IF pennode.selectpen=-1 THEN
      pennode.selectpen:=g.ObtainBestPen(plotinfo.colormap,bt.IntToRGB(color.red),bt.IntToRGB(color.green),bt.IntToRGB(color.blue),u.done);
    END;
  ELSE
  END;
  IF type=setFrontPen THEN
    g.SetAPen(plotinfo.rast,SHORT(pennode.selectpen));
  ELSIF type=setBackPen THEN
    g.SetBPen(plotinfo.rast,SHORT(pennode.selectpen));
  END;
  RETURN SHORT(pennode.selectpen);
END SetColorSelect;

PROCEDURE (color:Color) FreePenSelect*(disp:pi.Display);
(* Call this method if no pixel on the display is of the given color.
   If you still have some pixels of this color on your screen they
   may be changed in color by Graphics. *)

VAR pennode : PenNode;

BEGIN
  pennode:=color.GetPenNode(disp);
  IF pennode#NIL THEN
    IF pennode.selectpen#-1 THEN
      g.ReleasePen(disp.colormap,pennode.selectpen);
      pennode.selectpen:=-1;
    END;
  END;
END FreePenSelect;

PROCEDURE FreePensSelect*(disp:pi.Display);
(* Same as FreePen, but frees pens of all used colors. Therefore your
   image on the screen might change in color. *)

VAR color : l.Node;

BEGIN
  color:=colors.head;
  WHILE color#NIL DO
    color(Color).FreePenSelect(disp);
    color:=color.next;
  END;
END FreePensSelect;

PROCEDURE * PrintColor*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node        : l.Node;
    str         : e.STRPTR;
    plotinfo    : pi.PlotInfo;
    spotwidth,i : INTEGER;

BEGIN
  plotinfo:=s.VAL(pi.PlotInfo,user);
  spotwidth:=SHORT(SHORT(rast.txHeight*1.3));
  node:=colors.GetNode(num);
  IF node#NIL THEN
    WITH node: Color DO
      NEW(str);
      COPY(node.name,str^);
      tt.CutStringToLength(rast,str^,width-spotwidth-4);
      tt.Print(x+spotwidth+4,y,str,rast);

      g.SetAPen(rast,1);
      g.RectFill(rast,x,y-rast.txBaseline,x+spotwidth-1,y+rast.txHeight-rast.txBaseline-1);
      i:=node.SetColorSelect(plotinfo,setFrontPen);
      g.SetAPen(rast,i);
      g.RectFill(rast,x+2,y+1-rast.txBaseline,x+16,y+rast.txHeight-rast.txBaseline-2);
      DISPOSE(str);
    END;
  END;
END PrintColor;



(* Main color requester *)

VAR changecolorswind * : wm.Window;

PROCEDURE ChangeColors*(colortask:m.Task):BOOLEAN;

VAR subwind    : wm.SubWindow;
    wind       : I.WindowPtr;
    rast       : g.RastPortPtr;
    root       : gmb.Root;
    wheel      : gmo.ColorWheel;
    gradient   : gmo.GradientSlider;
    redtext,
    greentext,
    bluetext   : gmo.Text;
    redgad,
    greengad,
    bluegad    : gmo.SliderGadget;
    colorlv    : gmo.ListView;
    newcol,
    delcol     : gmo.BooleanGadget;
    gadobj     : gmb.Object;
    glist      : I.GadgetPtr;
    mes        : I.IntuiMessagePtr;
    msg        : m.Message;
    class      : LONGSET;
    redstr,
    greenstr,
    bluestr    : ARRAY 80 OF CHAR;
    actcol,
    color      : l.Node;
    plotinfo   : pi.PlotInfo;
    oldred,
    oldgreen,
    oldblue    : LONGINT;
    ret,bool,
    didchange,
    getwheel   : BOOLEAN;

PROCEDURE RefreshColor;

BEGIN
  IF actcol#NIL THEN
    colorlv.SetString(actcol(Color).name);
    colorlv.SetValue(colors.GetNodeNumber(actcol));
  ELSE
    colorlv.Refresh;
  END;
END RefreshColor;

PROCEDURE RefreshWheel;
(* Adapts wheel to new RGB-Values in actcol. Also modifies
   gradient slider, but does not touch RGB-sliders. *)

BEGIN
  IF actcol#NIL THEN
    WITH actcol: Color DO
      wheel.RefreshWheel(actcol.red,actcol.green,actcol.blue,s.ADR(lb.screen.viewPort));
      wheel.RefreshPens(s.ADR(lb.screen.viewPort));
    END;
  END;
END RefreshWheel;

PROCEDURE RefreshSliders;
(* Modifies sliders, but does not change wheel and gradient slider. *)

BEGIN
  IF actcol#NIL THEN
    WITH actcol: Color DO
      redgad.SetValue(actcol.red);
      greengad.SetValue(actcol.green);
      bluegad.SetValue(actcol.blue);
    END;
  END;
END RefreshSliders;

BEGIN
  NEW(plotinfo); plotinfo.Init;
  plotinfo.view:=s.ADR(lb.screen.viewPort);
  plotinfo.colormap:=plotinfo.view.colorMap;
  plotinfo.vinfo:=gd.GetVisualInfo(lb.screen,u.done);
  plotinfo.display:=lb.maindisp(pi.Display);
  NEW(mes);
  ret:=FALSE;
  IF changecolorswind=NIL THEN
    changecolorswind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.ChangeColors),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP+LONGSET{I.intuiTicks});
  END;
  subwind:=changecolorswind.InitSub(lb.screen);

  root:=gmb.SetRootBox(gmb.horizBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad},subwind);
    gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,ac.GetString(ac.CurrentColor));
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        gradient:=gmo.SetGradientSlider(4,-1);
        wheel:=gmo.SetColorWheel(gradient);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        redtext:=gmo.SetText(ac.GetString(ac.RedDP),-1);
        redgad:=gmo.SetSliderGadget(0,255,0,3,NIL);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        greentext:=gmo.SetText(ac.GetString(ac.GreenDP),-1);
        greengad:=gmo.SetSliderGadget(0,255,0,3,NIL);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        bluetext:=gmo.SetText(ac.GetString(ac.BlueDP),-1);
        bluegad:=gmo.SetSliderGadget(0,255,0,3,NIL);
      gmb.EndBox;
      root.NewSameTextWidth;
        root.AddSameTextWidth(redtext);
        root.AddSameTextWidth(greentext);
        root.AddSameTextWidth(bluetext);
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
      colorlv:=gmo.SetListView(ac.GetString(ac.SelectColor),colors,PrintColor,0,TRUE,79);
      colorlv.SetUser(plotinfo);
      newcol:=gmo.SetBooleanGadget(ac.GetString(ac.NewColor),FALSE);
      delcol:=gmo.SetBooleanGadget(ac.GetString(ac.DelColor),FALSE);
    gmb.EndBox;
  glist:=root.EndRoot();

  root.Init;

  wheel.PreparePens(s.ADR(lb.screen.viewPort));

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    plotinfo.rast:=rast;
    root.Resize;

    actcol:=colors.head;
    RefreshColor;
    RefreshWheel;
    RefreshSliders;

    didchange:=FALSE;
    getwheel:=FALSE;
    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF colortask.msgsig IN class THEN
        REPEAT
          msg:=colortask.ReceiveMsg();
          IF msg#NIL THEN
            IF msg.type=m.msgQuit THEN
              msg.Reply;
              EXIT;
            ELSIF msg.type=m.msgClose THEN
              subwind.Close;
              root.Resize;
            ELSIF msg.type=m.msgOpen THEN
              subwind.SetScreen(lb .screen);
              wind:=subwind.Open(NIL);
              IF wind#NIL THEN
                rast:=wind.rPort;
                root.Resize;
                colorlv.Activate;
              ELSE
                msg.Reply;
                EXIT;
              END;
(*            ELSIF msg.type=m.msgNodeChanged THEN
              SetData;*)
            ELSIF msg.type=m.msgActivate THEN
              subwind.ToFront;
            END;
            msg.Reply;
          END;
        UNTIL msg=NIL;
      END;
      REPEAT
        root.GetIMes(mes);
        IF actcol#NIL THEN
          WITH actcol: Color DO
            colorlv.GetString(actcol.name);
            oldred:=actcol.red;
            oldgreen:=actcol.green;
            oldblue:=actcol.blue;
            IF getwheel THEN
              wheel.GetColor(actcol(Color).red,actcol(Color).green,actcol(Color).blue);
            ELSE
              actcol(Color).red:=redgad.GetValue();
              actcol(Color).green:=greengad.GetValue();
              actcol(Color).blue:=bluegad.GetValue();
            END;
            IF (actcol.red#oldred) OR (actcol.green#oldgreen) OR (actcol.blue#oldblue) THEN
              actcol.FreePenSelect(plotinfo.display);
              IF getwheel THEN RefreshSliders;
                          ELSE RefreshWheel; END;
              colorlv.Refresh;
            END;
          END;
        END;
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
(*            GetInput;
            ret:=TRUE;
            grid1.window.changed:=TRUE;
            grid1.window.SendNewMsg(m.msgNodeChanged,NIL);*)
            EXIT;
(*          ELSIF mes.iAddress=root.ca THEN
(*            IF didchange THEN
              grid1.window.changed:=TRUE;
              grid1.window.SendNewMsg(m.msgNodeChanged,NIL);
            END;*)
            ret:=FALSE;
            EXIT;*)
          ELSIF mes.iAddress=newcol.gadget THEN
            AddNewColor(ac.GetString(ac.White)^,255,255,255);
            actcol:=colors.tail;
            RefreshColor;
            RefreshWheel; RefreshSliders;
          ELSIF mes.iAddress=delcol.gadget THEN
            IF (actcol#NIL) & (actcol#black) & (actcol#white) THEN
              color:=actcol.next;
              IF color=NIL THEN color:=actcol.prev; END;
              actcol.Remove;
              mem.NodeToGarbage(actcol(Color));
              actcol:=color;
              RefreshColor;
              RefreshWheel; RefreshSliders;
            END;
          ELSIF (mes.iAddress=wheel.gadget) OR (mes.iAddress=gradient.gadget) THEN
            getwheel:=FALSE;
          ELSIF mes.iAddress=colorlv.stringgad THEN
            colorlv.Refresh;
          ELSIF mes.iAddress=colorlv.gadget THEN
            IF mes.code=gmo.newActEntry THEN
              actcol:=colors.GetNode(colorlv.GetValue());
              RefreshWheel;
              RefreshSliders;
              RefreshColor;
            END;
          ELSIF NOT(mes.iAddress=root.help) THEN
          END;
        ELSIF I.gadgetDown IN mes.class THEN
          IF (mes.iAddress=wheel.gadget) OR (mes.iAddress=gradient.gadget) THEN
            getwheel:=TRUE;
          END;
        END;
  (*      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"changegrid",wind);
        END;*)
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
  END;
  wheel.ReleasePens(s.ADR(lb.screen.viewPort));
  root.Destruct;
  DISPOSE(mes);
  FreePensSelect(plotinfo.display);
  IF plotinfo.vinfo#NIL THEN gd.FreeVisualInfo(plotinfo.vinfo); END;
  plotinfo.Destruct;
  RETURN ret;
END ChangeColors;

PROCEDURE ChangeColorsTask*(colortask:bas.ANY):bas.ANY;

VAR bool : BOOLEAN;

BEGIN
  WITH colortask: m.Task DO
    colortask.InitCommunication;
    bool:=ChangeColors(colortask);

    m.taskdata.layouttask.RemTask(colortask);
    colortask.ReplyAllMessages;
    colortask.DestructCommunication;
    mem.NodeToGarbage(colortask);
    m.taskdata.layouttask.FreeUser(colortask);
  END;
  IF bool THEN
    RETURN s.VAL(bas.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END ChangeColorsTask;



(* Some alien stuff :) *)

PROCEDURE AllocMinPlotInfo*():pi.PlotInfo;

VAR plotinfo : pi.PlotInfo;

BEGIN
  NEW(plotinfo); plotinfo.Init;
  plotinfo.view:=s.ADR(lb.screen.viewPort);
  plotinfo.colormap:=plotinfo.view.colorMap;
  plotinfo.vinfo:=gd.GetVisualInfo(lb.screen,u.done);
  plotinfo.display:=lb.maindisp(pi.Display);
  RETURN plotinfo;
END AllocMinPlotInfo;

PROCEDURE DestructMinPlotInfo*(plotinfo:pi.PlotInfo);

(* You no longer have to free the pens before calling this! *)
                      (* || *)
BEGIN                 (* \/ *)
  FreePensSelect(plotinfo.display);
  IF plotinfo.vinfo#NIL THEN gd.FreeVisualInfo(plotinfo.vinfo); END;
  plotinfo.Destruct;
END DestructMinPlotInfo;



VAR str : ARRAY 80 OF CHAR;

BEGIN
  colors:=m.Create();
  IF colors=NIL THEN HALT(20); END;

  AddNewColor(ac.GetString(ac.Cyan)^,0,255,255);
  AddNewColor(ac.GetString(ac.Magenta)^,255,0,255);
  AddNewColor(ac.GetString(ac.Yellow)^,255,255,0);
  AddNewColor(ac.GetString(ac.Red)^,255,0,0);
  AddNewColor(ac.GetString(ac.Green)^,0,255,0);
  AddNewColor(ac.GetString(ac.Blue)^,0,0,255);
  AddNewColor(ac.GetString(ac.Black)^,0,0,0);
  black:=colors.tail(Color);
  COPY(ac.GetString(ac.Gray)^,str);
  st.Append(str," 80%");
  AddNewColor(str,51,51,51);
  COPY(ac.GetString(ac.Gray)^,str);
  st.Append(str," 60%");
  AddNewColor(str,102,102,102);
  COPY(ac.GetString(ac.Gray)^,str);
  st.Append(str," 40%");
  AddNewColor(str,153,153,153);
  COPY(ac.GetString(ac.Gray)^,str);
  st.Append(str," 20%");
  AddNewColor(str,204,204,204);
  AddNewColor(ac.GetString(ac.White)^,255,255,255);
  white:=colors.tail(Color);
  stdcolor:=black;

CLOSE
  IF colors#NIL THEN colors.Destruct; END;
END Colors.
