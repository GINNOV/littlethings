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


MODULE GeneralBasics;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       l  : LinkedLists,
       r  : Requests,
       st : Strings,
       gd : GadTools,
       tt : TextTools,
       ag : AmigaGuideTools,
       ac : AnalayCatalog,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       ml : MATHLIB,
       NoGuruRq;



TYPE String * = POINTER TO StringDesc;
     StringDesc * = RECORD(l.NodeDesc)
       string * : UNTRACED POINTER TO ARRAY OF CHAR;
       style  * : SHORTSET;
     END;

PROCEDURE (string:String) Destruct*;

BEGIN
  IF string.string#NIL THEN
    DISPOSE(string.string);
  END;
END Destruct;

PROCEDURE * PrintString*(rast:g.RastPortPtr;x,y,width:INTEGER;num:LONGINT;datalist:l.List;user:e.APTR);

VAR node       : l.Node;
    str        : UNTRACED POINTER TO ARRAY OF CHAR;
    mask,style : SHORTSET;

BEGIN
  node:=datalist.GetNode(num);
  IF node#NIL THEN
    WITH node: String DO
      NEW(str,st.Length(node.string^)+1);
      COPY(node.string^,str^);
      tt.CutStringToLength(rast,str^,width);
      mask:=g.AskSoftStyle(rast);
      style:=g.SetSoftStyle(rast,node.style,mask);
      tt.Print(x,y,s.ADR(str^),rast);
      mask:=g.AskSoftStyle(rast);
      style:=g.SetSoftStyle(rast,SHORTSET{},mask);
      DISPOSE(str);
    END;
  END;
END PrintString;

PROCEDURE AddString*(list:l.List;string:ARRAY OF CHAR;style:SHORTSET);

VAR result : String;

BEGIN
  NEW(result);
  NEW(result.string,st.Length(string)+1);
  COPY(string,result.string^);
  result.style:=style;
  list.AddTail(result);
END AddString;



VAR stringreqwind * ,
    valuereqwind  * ,
    pointreqwind  * ,
    listwind      * : wm.Window;

    analaydoc     * : ARRAY 80 OF CHAR;
    monitorsize   * : INTEGER; (* In Inch *)
    aspect        * : LONGREAL; (* Fraction of aspect ratio of monitor, default is 4:3 *)



PROCEDURE EnterString*(screen:I.ScreenPtr;title,subtitle:e.STRPTR;VAR string:ARRAY OF CHAR):BOOLEAN;

VAR subwind  : wm.SubWindow;
    wind     : I.WindowPtr;
    rast     : g.RastPortPtr;
    root     : gmb.Root;
    strgad   : gmo.StringGadget;
    gadobj   : gmb.Object;
    glist    : I.GadgetPtr;
    mes      : I.IntuiMessagePtr;
    ret,bool : BOOLEAN;

BEGIN
  NEW(mes);
  ret:=FALSE;
  IF stringreqwind=NIL THEN
    stringreqwind:=wm.InitWindow(wm.centered,wm.centered,10,10,TRUE,title,LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=stringreqwind.InitSub(screen);
  subwind.SetTitle(title);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmo.SetText(subtitle,-1);
    strgad:=gmo.SetStringGadget(NIL,255,gmo.stringType);
  glist:=root.EndRoot();

  strgad.SetString(string);

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;
    strgad.Activate;

    LOOP
      subwind.WaitPort;
      root.GetIMes(mes);
      IF I.gadgetUp IN mes.class THEN
        IF mes.iAddress=root.ok THEN
          strgad.GetString(string);
          IF (string[0]#0X) AND NOT((st.Length(string)=1) AND (string[0]=" ")) THEN
            ret:=TRUE;
          END;
          EXIT;
        ELSIF mes.iAddress=root.ca THEN
          EXIT;
        ELSIF mes.iAddress=strgad.gadget THEN
          strgad.GetString(string);
          IF (string[0]#0X) AND NOT((st.Length(string)=1) AND (string[0]=" ")) THEN
            ret:=TRUE;
          END;
          EXIT;
        END;
      END;
      IF ((I.gadgetUp IN mes.class) AND (mes.iAddress=root.help)) THEN
        ag.ShowFile(ag.guidename,"getstring",wind);
      END;
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  RETURN ret;
END EnterString;

PROCEDURE EnterPoint*(screen:I.ScreenPtr;VAR x,y:ARRAY OF CHAR;autopy:BOOLEAN):BOOLEAN;

VAR subwind   : wm.SubWindow;
    wind      : I.WindowPtr;
    rast      : g.RastPortPtr;
    root      : gmb.Root;
    xstr,ystr : gmo.StringGadget;
    gadobj    : gmb.Object;
    glist     : I.GadgetPtr;
    mes       : I.IntuiMessagePtr;
    ret       : BOOLEAN;

BEGIN
  NEW(mes);
  ret:=FALSE;
  IF pointreqwind=NIL THEN
    pointreqwind:=wm.InitWindow(wm.centered,wm.centered,10,10,TRUE,ac.GetString(ac.EnterPoint),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=pointreqwind.InitSub(screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmo.SetText(ac.GetString(ac.PointCoordinates),-1);
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      xstr:=gmo.SetStringGadget(ac.GetString(ac.XCoord),79,gmo.realType);
      xstr.SetMinVisible(5);
      ystr:=gmo.SetStringGadget(ac.GetString(ac.YCoord),79,gmo.realType);
      ystr.SetMinVisible(5);
    gmb.EndBox;
  glist:=root.EndRoot();

  xstr.SetString(x);
  ystr.SetString(y);
  IF autopy THEN
    ystr.Disable(TRUE);
  END;

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;
    xstr.Activate;

    LOOP
      subwind.WaitPort;
      root.GetIMes(mes);
      IF I.gadgetUp IN mes.class THEN
        IF mes.iAddress=root.ok THEN
          xstr.GetString(x);
          ystr.GetString(y);
          ret:=TRUE;
          EXIT;
        ELSIF mes.iAddress=root.ca THEN
          EXIT;
        ELSIF (mes.iAddress=ystr.gadget) OR ((mes.iAddress=xstr.gadget) AND (autopy)) THEN
          xstr.GetString(x);
          ystr.GetString(y);
          ret:=TRUE;
          EXIT;
        END;
      END;
      IF ((I.gadgetUp IN mes.class) AND (mes.iAddress=root.help)) THEN
        ag.ShowFile(ag.guidename,"enterpoint",wind);
      END;
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  RETURN ret;
END EnterPoint;

PROCEDURE EnterInteger*(screen:I.ScreenPtr;title,subtitle:e.STRPTR;min,max:LONGINT;VAR value:LONGINT;helpnode:ARRAY OF CHAR):BOOLEAN;

VAR subwind  : wm.SubWindow;
    wind     : I.WindowPtr;
    rast     : g.RastPortPtr;
    root     : gmb.Root;
    strgad   : gmo.StringGadget;
    slider   : gmo.SliderGadget;
    gadobj   : gmb.Object;
    glist    : I.GadgetPtr;
    mes      : I.IntuiMessagePtr;
    savevalue: LONGINT;
    ret,bool : BOOLEAN;

  PROCEDURE SetData;
  
  BEGIN
    strgad.SetInteger(value);
    slider.SetValue(value);
  END SetData;
  
  PROCEDURE GetStringInput;
  
  BEGIN
    value:=strgad.GetInteger();
    slider.SetValue(value);
  END GetStringInput;
  
BEGIN
  NEW(mes);
  ret:=FALSE;
  IF valuereqwind=NIL THEN
    valuereqwind:=wm.InitWindow(wm.centered,wm.centered,10,10,TRUE,title,LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=valuereqwind.InitSub(screen);
  subwind.SetTitle(title);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmo.SetText(subtitle,-1);
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      strgad:=gmo.SetStringGadget(NIL,255,gmo.integerType);
      strgad.SetMinVisible(4);
      strgad.SetSizeX(0);
      strgad.SetMinMaxInt(min,max);
      slider:=gmo.SetSliderGadget(min,max,value,0,NIL);
    gmb.EndBox;
    gmb.FillSpace;
  glist:=root.EndRoot();

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;
    SetData;
    strgad.Activate;

    savevalue:=value;

    LOOP
      subwind.WaitPort;
      root.GetIMes(mes);
      IF I.gadgetUp IN mes.class THEN
        IF mes.iAddress=root.ok THEN
          GetStringInput;
          ret:=TRUE;
          EXIT;
        ELSIF mes.iAddress=root.ca THEN
          value:=savevalue;
          EXIT;
        ELSIF mes.iAddress=slider.gadget THEN
          value:=slider.GetValue();
          SetData;
        ELSIF ~(mes.iAddress=root.help) THEN
          GetStringInput;
        END;
      END;
      IF ((I.gadgetUp IN mes.class) AND (mes.iAddress=root.help)) THEN
        ag.ShowFile(ag.guidename,helpnode,wind);
      END;
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  RETURN ret;
END EnterInteger;

PROCEDURE SelectNode*(list:l.List;windtitle,listtitle,noelements:e.STRPTR;quickselect:BOOLEAN;proc:gmo.PrintProc;user:e.APTR;window:I.WindowPtr):l.Node;
(* $CopyArrays- *)
(* Sorry for this parameter bunch *)

VAR subwind     : wm.SubWindow;
    wind        : I.WindowPtr;
    rast        : g.RastPortPtr;
    root        : gmb.Root;
    listview    : gmo.ListView;
    mes         : I.IntuiMessagePtr;
    glist       : I.GadgetPtr;
    minwi,minhe : INTEGER;
    node,actel,
    oldel       : l.Node;
    str1,str2   : POINTER TO ARRAY OF CHAR;
    i           : INTEGER;
    bool        : BOOLEAN;

BEGIN
  IF window#NIL THEN
    NEW(mes);
    actel:=NIL;
    IF (list.nbElements()=1) AND (quickselect) THEN
      actel:=list.head;
    ELSIF NOT(list.isEmpty()) THEN
      actel:=list.head;
    
      IF listwind=NIL THEN
        listwind:=wm.InitWindow(10,10,minwi,minhe,TRUE,windtitle,LONGSET{I.activate,I.windowDrag,I.windowDepth,I.windowSizing,I.reportMouse},gmb.stdIDCMP);
      END;
      listwind.SetTitle(windtitle);
      subwind:=listwind.InitSub(window.wScreen);
  
      root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
        listview:=gmo.SetListView(listtitle,list,proc,0,FALSE,79);
        listview.SetUser(user);
      glist:=root.EndRoot();
      root.Init;
  
      wind:=subwind.Open(glist);
      IF wind#NIL THEN
        rast:=wind.rPort;
        root.Resize;
  
        LOOP
          e.WaitPort(wind.userPort);
          root.GetIMes(mes);
          IF I.gadgetUp IN mes.class THEN
            IF mes.iAddress=root.ok THEN
              EXIT;
            ELSIF mes.iAddress=root.ca THEN
              actel:=NIL;
              EXIT;
            ELSIF mes.iAddress=listview.scrollgad THEN
              IF mes.code=gmo.newActEntry THEN
                actel:=list.GetNode(listview.actentry);
              ELSIF mes.code=gmo.doubleClicked THEN
                EXIT;
              END;
            END;
          END;
        END;
    
        subwind.Destruct;
      END;
      root.Destruct;
    ELSE
      i:=SHORT(st.Length(noelements^)+1);
      NEW(str1,i);
      NEW(str2,i);
      COPY(noelements^,str2^);
      str1^:="";
      i:=0;
      WHILE (i<st.Length(str2^)) AND (str2[i]#" ") DO
        str1[i]:=str2[i];
        INC(i);
      END;
      st.Delete(str2^,0,i+1);
      bool:=r.RequestWin(str1^,str2^,"",ac.GetString(ac.OK)^,window);
      DISPOSE(str2);
      DISPOSE(str1);
    END;
    DISPOSE(mes);
    RETURN actel;
  ELSE
    RETURN NIL;
  END;
END SelectNode;

PROCEDURE GetStdPicX*(maxwi:LONGINT):INTEGER;
(* maxwi is the screen width *)
(* Returns 0,5cm in pixels *)

VAR width : LONGREAL; (* Diagonale *)

BEGIN
  width:=ml.SIN(ml.ATAN(aspect))*monitorsize;
  width:=width*2.54;

(* width now contains the screen width in cm *)

  RETURN SHORT(SHORT(SHORT(maxwi/width*0.5)));
END GetStdPicX;

PROCEDURE GetStdPicY*(maxhe:LONGINT):INTEGER;
(* maxhe is the screen height *)
(* Returns 0,5cm in pixels *)

VAR height : LONGREAL; (* Diagonale *)

BEGIN
  height:=ml.COS(ml.ATAN(aspect))*monitorsize;
  height:=height*2.54;

(* height now contains the screen height in cm *)

  RETURN SHORT(SHORT(SHORT(maxhe/height*0.5)));
END GetStdPicY;

BEGIN
  stringreqwind:=NIL;
  pointreqwind:=NIL;
  listwind:=NIL;

  monitorsize:=15;
  aspect:=4/3;
END GeneralBasics.

