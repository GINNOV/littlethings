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


MODULE MathGUI;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       u  : Utility,
       s  : SYSTEM,
       gd : GadTools,
       r  : Requests,
       bt : BasicTools,
       it : IntuitionTools,
       mb : MathBasics,
       gb : GeneralBasics,
       gg : GeneralGUI,
       wm : WindowManager,
       mm : MenuManager,
       pt : Pointers,
       ac : AnalayCatalog,
       dc : DisplayConversion,
       vs : VersionStrings,
       io,
       NoGuruRq;



VAR screen      * : I.ScreenPtr; (* Math mode default screen *)
    window      * : I.WindowPtr; (* Main window (Backdrop or on Workbench) *)
    view        * : g.ViewPortPtr;
    colormap    * : g.ColorMapPtr;
    vinfo       * : gd.VisualInfo;
    menu        * : I.MenuPtr;
    mainwind    * : wm.Window;
    mainsub     * : wm.SubWindow;
    plast       * : ARRAY 1 OF INTEGER;
    screenmode  * : gg.ScreenMode;
    mathconv    * : dc.ConversionTable; (* Conversion table used by Math Mode *)



PROCEDURE Init*;

VAR new             : I.ExtNewScreen;
    long            : LONGINT;
    rgb             : ARRAY 3 OF LONGINT;
    set             : SET;
    i,width,height,
    col             : INTEGER;
    usewbscreenitem,
    quickselectitem,
    autoactiveitem  : I.MenuItemPtr;
    bool            : BOOLEAN;

BEGIN
  plast[0]:=-1;
  IF screenmode.usewbscreen THEN
    screen:=I.LockPubScreen("Workbench");
  ELSE
    INCL(new.ns.type,I.nsExtended);
    IF screenmode.clonewb THEN
      screen:=I.LockPubScreen("Workbench");
      screenmode.width:=screen.width;
      screenmode.height:=screen.height;
      screenmode.depth:=screen.rastPort.bitMap.depth;
      screenmode.displayId:=g.GetVPModeID(s.ADR(screen.viewPort));
      I.UnlockPubScreen("Workbench",screen);
    END;
    screen:=I.OpenScreenTags(new,I.saLeft,0,
                                 I.saTop,0,
                                 I.saWidth,screenmode.width,
                                 I.saHeight,screenmode.height,
                                 I.saDepth,screenmode.depth,
                                 I.saTitle,vs.mainscreentitle,
                                 I.saPens,s.ADR(plast),
                                 I.saDetailPen,0,
                                 I.saBlockPen,1,
                                 I.saDisplayID,screenmode.displayId,
                                 I.saOverscan,screenmode.oscan,
                                 I.saFont,0,
                                 I.saSysFont,0,
                                 I.saBitMap,0,
                                 I.saAutoScroll,screenmode.autoscroll,
                                 I.saSharePens,I.LTRUE,
                                 I.saFullPalette,I.LTRUE,
                                 u.done);
    IF screen=NIL THEN
      io.WriteString("Opening of screen failed. Using Workbench screen.\n");
      screenmode.usewbscreen:=TRUE;
      screen:=I.LockPubScreen("Workbench");
      IF screen=NIL THEN
        bool:=r.Request("Could not open","display!","",ac.GetString(ac.OK)^);
      END;
    END;
  END;
  IF screenmode.usewbscreen THEN
    mainsub.SetScreen(screen);
    mainsub.SetScreenBack(FALSE);
    window:=mainsub.Open(NIL);
    I.UnlockPubScreen("Workbench",screen);
  ELSE
    mainsub.SetScreen(screen);
    mainsub.SetScreenBack(TRUE);
    window:=mainsub.Open(NIL);
  END;

  screenmode.reqwindow:=mainsub.GetWindow();

  view:=s.ADR(screen.viewPort);

(* ColorSharing *)

  colormap:=view.colorMap;
  IF bt.os>=39 THEN

(* Reserving colors for Math-Mode *)

    i:=3;
    WHILE i<screenmode.reserved-1 DO
      INC(i);
      g.GetRGB32(colormap,i,1,rgb);
      long:=g.ObtainPen(colormap,i,rgb[0],rgb[1],rgb[2],0);
    END;
  END;

  IF screenmode.colormap[0,0]=-1 THEN

(* Saving colormap of screen for further use (e.g. writing it to disk). *)

    IF bt.os>=39 THEN
      FOR i:=0 TO 15 DO
        g.GetRGB32(colormap,i,1,rgb);
        screenmode.colormap[i,0]:=bt.RGBToInt(rgb[0]);
        screenmode.colormap[i,1]:=bt.RGBToInt(rgb[1]);
        screenmode.colormap[i,2]:=bt.RGBToInt(rgb[2]);
      END;
    ELSE
      FOR i:=0 TO 15 DO
        col:=g.GetRGB4(colormap,i);
        set:=s.VAL(SET,col);
        screenmode.colormap[i,0]:=s.VAL(INTEGER,s.LSH(s.LSH(set,4),-12))*255 DIV 15;
        screenmode.colormap[i,1]:=s.VAL(INTEGER,s.LSH(s.LSH(set,8),-12))*255 DIV 15;
        screenmode.colormap[i,2]:=s.VAL(INTEGER,s.LSH(s.LSH(set,12),-12))*255 DIV 15;
      END;
    END;
  ELSIF ~screenmode.usewbscreen THEN
    FOR i:=0 TO 15 DO
      IF bt.os<39 THEN
        g.SetRGB4(view,i,screenmode.colormap[i,0]*15 DIV 255,screenmode.colormap[i,1]*15 DIV 255,screenmode.colormap[i,2]*15 DIV 255);
      ELSE
        g.SetRGB32(view,i,bt.IntToRGB(screenmode.colormap[i,0]),bt.IntToRGB(screenmode.colormap[i,1]),bt.IntToRGB(screenmode.colormap[i,2]));
      END;
    END;
  END;

  IF vinfo#NIL THEN
    gd.FreeVisualInfo(vinfo);
    vinfo:=NIL;
  END;
  vinfo:=gd.GetVisualInfo(screen,NIL);
  IF menu=NIL THEN
    mainsub.SetBusyPointer;

    mm.StartMenu(window);
  
    mm.NewMenu(ac.GetString(ac.Program));
    mm.NewItem(ac.GetString(ac.Load),"O");
    mm.NewItem(ac.GetString(ac.Save),"S");
    mm.NewItem(ac.GetString(ac.SaveAs),"A");
    mm.Separator;
    mm.NewItem(ac.GetString(ac.Layout),"Y");
    mm.Separator;
    mm.NewItem(ac.GetString(ac.About),0X);
    mm.NewItem(ac.GetString(ac.Quit),"Q");
  
    mm.NewMenu(ac.GetString(ac.Function));
    mm.NewItem(ac.GetString(ac.Input),"I");
    mm.NewItem(ac.GetString(ac.DefinitionDomain),"D");
    mm.NewItem(ac.GetString(ac.Connect),"C");
    mm.NewItem(ac.GetString(ac.Process),"P");
    mm.NewItem(ac.GetString(ac.ChangeConstants),"O");
    mm.Separator;
    mm.NewItem2(ac.GetString(ac.QuickEnter),s.ADR("Ctrl+I"));
  
    mm.NewMenu(ac.GetString(ac.Windows));
    mm.NewItem(ac.GetString(ac.Create),"W");
    mm.NewItem(ac.GetString(ac.Settings),"N");
    mm.Separator;
    mm.NewItem(ac.GetString(ac.AxisLimits),"B");
    mm.NewItem(ac.GetString(ac.AxisDesign),"A");
    mm.NewItem(ac.GetString(ac.Grid),"G");
    mm.NewItem(ac.GetString(ac.GraphDesign),"F");
    mm.Separator;
    mm.NewItem2(ac.GetString(ac.Text),s.ADR("»"));
    mm.NewSubItem2(ac.GetString(ac.Place),s.ADR("Ctrl+T"));
    mm.NewSubItem2(ac.GetString(ac.Change),s.ADR("Alt+T"));
    mm.NewSubItem(ac.GetString(ac.Delete),0X);
    mm.SubSeparator;
    mm.NewSubItem2(ac.GetString(ac.Default),s.ADR("Ctrl+Alt+T"));
    mm.NewItem2(ac.GetString(ac.Point),s.ADR("»"));
    mm.NewSubItem2(ac.GetString(ac.Place),s.ADR("Ctrl+P"));
    mm.NewSubItem2(ac.GetString(ac.Change),s.ADR("Alt+P"));
    mm.NewSubItem(ac.GetString(ac.Delete),0X);
    mm.SubSeparator;
    mm.NewSubItem2(ac.GetString(ac.Default),s.ADR("Ctrl+Alt+P"));
    mm.NewItem2(ac.GetString(ac.Marker),s.ADR("»"));
    mm.NewSubItem2(ac.GetString(ac.Place),s.ADR("Ctrl+M"));
    mm.NewSubItem2(ac.GetString(ac.Change),s.ADR("Alt+M"));
    mm.NewSubItem(ac.GetString(ac.Delete),0X);
    mm.SubSeparator;
    mm.NewSubItem2(ac.GetString(ac.Default),s.ADR("Ctrl+Alt+M"));
    mm.NewItem2(ac.GetString(ac.Hatching),s.ADR("»"));
    mm.NewSubItem2(ac.GetString(ac.Place),s.ADR("Ctrl+S"));
    mm.NewSubItem2(ac.GetString(ac.Change),s.ADR("Alt+S"));
    mm.NewSubItem(ac.GetString(ac.Delete),0X);
    mm.SubSeparator;
    mm.NewSubItem2(ac.GetString(ac.Default),s.ADR("Ctrl+Alt+S"));
  
  (*  mm.NewItem2("Text setzen","Ctrl+T");
    mm.NewItem2("Punkt setzen","Ctrl+P");
    mm.NewItem2("Markierung setzen","Ctrl+M");
    mm.NewItem2("Bereich schraffieren","Ctrl+B");
    mm.Separator;
    mm.NewItem2("Text verändern","Ctrl+Shift+T");
    mm.NewItem2("Punkt verändern","Ctrl+Shift+P");
    mm.NewItem2("Markierung verändern","Ctrl+Shift+M");
    mm.NewItem2("Bereich verändern","Ctrl+Shift+B");
    mm.Separator;
    mm.NewItem("Text löschen",0X);
    mm.NewItem("Punkt löschen",0X);
    mm.NewItem("Markierung löschen",0X);
    mm.NewItem("Bereich löschen",0X);*)
  
    mm.NewMenu(ac.GetString(ac.Analysis));
    mm.NewItem(ac.GetString(ac.FindZeros),"1");
    mm.NewItem(ac.GetString(ac.FindExtremes),"2");
    mm.NewItem(ac.GetString(ac.FindGaps),"3");
    mm.NewItem(ac.GetString(ac.FindInflections),"4");
    mm.NewItem(ac.GetString(ac.FindIntersections),"5");
    mm.Separator;
    mm.NewItem(ac.GetString(ac.CompleteAnalysis),"6");
    mm.NewItem(ac.GetString(ac.CompleteSettings),"7");
    mm.Separator;
    mm.NewItem(ac.GetString(ac.CalcArea),"S");
  
    mm.NewMenu(ac.GetString(ac.Special));
    mm.NewItem2(ac.GetString(ac.Legend),s.ADR("»"));
    mm.NewSubItem(ac.GetString(ac.Create),"N");
    mm.NewSubItem2(ac.GetString(ac.Change),s.ADR("Alt+N"));
    mm.NewSubItem(ac.GetString(ac.Delete),0X);
    mm.SubSeparator;
    mm.NewSubItem2(ac.GetString(ac.Default),s.ADR("Ctrl+Alt+N"));
    mm.NewItem2(ac.GetString(ac.Table),s.ADR("»"));
    mm.NewSubItem(ac.GetString(ac.Create),"T");
    mm.NewSubItem2(ac.GetString(ac.Change),s.ADR("Alt+T"));
    mm.NewSubItem(ac.GetString(ac.Delete),0X);
    mm.SubSeparator;
    mm.NewSubItem2(ac.GetString(ac.Default),s.ADR("Ctrl+Alt+T"));
    mm.NewItem2(ac.GetString(ac.List),s.ADR("»"));
    mm.NewSubItem(ac.GetString(ac.Create),"L");
    mm.NewSubItem2(ac.GetString(ac.Change),s.ADR("Alt+L"));
    mm.NewSubItem(ac.GetString(ac.Delete),0X);
    mm.SubSeparator;
    mm.NewSubItem2(ac.GetString(ac.Default),s.ADR("Ctrl+Alt+L"));
(*    mm.Separator;
    mm.NewItem("Verändere Legende",0X);
    mm.NewItem("Verändere Wertetabelle",0X);
    mm.NewItem("Verändere Liste",0X);*)
  (*  mm.Separator;
    mm.NewItem("Setze Punkt","6");
    mm.NewItem("Lösche Punkt","7");
    mm.NewItem("Setze Markierung","8");
    mm.NewItem("Lösche Markierung","9");
    mm.NewItem("Markiere Bereich","0");*)
  
    mm.NewMenu(ac.GetString(ac.SettingsMenu));
    mm.NewItem(ac.GetString(ac.ScreenMode),0X);
    mm.NewItem(ac.GetString(ac.ScreenColors),0X);
    mm.NewItem(ac.GetString(ac.Priorities),0X);
    mm.NewItem(ac.GetString(ac.Fonts),0X);
    mm.NewCheckItem(ac.GetString(ac.UseWBScreen),0X,screenmode.usewbscreen);
    mm.NewCheckItem(ac.GetString(ac.QuickSelect),0X,mb.mathoptions.quickselect);
    mm.NewCheckItem(ac.GetString(ac.AutoActiveWindow),0X,mb.mathoptions.autoactive);
    mm.NewCheckItem(ac.GetString(ac.CloneWB),0X,screenmode.clonewb);
    mm.Separator;
    mm.NewItem(ac.GetString(ac.Save),0X);
    mm.Separator;
    mm.NewItem(ac.GetString(ac.Load),0X);
    mm.NewItem(ac.GetString(ac.SaveAs),0X);
(*    mm.NewItem("Linien editieren",0X);
    mm.NewItem("Punkte editieren",0X);
    mm.NewItem("Markierungen editieren",0X);
    mm.NewItem("Füllmuster editieren",0X);*)
  
    menu:=mm.EndMenu();
  END;
  bool:=gd.LayoutMenus(menu,vinfo,gd.mnNewLookMenus,I.LTRUE,
                                  u.done);
  usewbscreenitem:=menu.nextMenu.nextMenu.nextMenu.nextMenu.nextMenu.firstItem.nextItem.nextItem.nextItem;
  quickselectitem:=usewbscreenitem.nextItem;
  autoactiveitem:=quickselectitem.nextItem;

  IF screenmode.usewbscreen THEN
    INCL(usewbscreenitem.flags,I.checked);
  ELSE
    EXCL(usewbscreenitem.flags,I.checked);
  END;
  IF mb.mathoptions.quickselect THEN
    INCL(quickselectitem.flags,I.checked);
  ELSE
    EXCL(quickselectitem.flags,I.checked);
  END;
  IF mb.mathoptions.autoactive THEN
    INCL(autoactiveitem.flags,I.checked);
  ELSE
    EXCL(autoactiveitem.flags,I.checked);
  END;
  IF screenmode.clonewb THEN
    INCL(autoactiveitem.nextItem.flags,I.checked);
  ELSE
    EXCL(autoactiveitem.nextItem.flags,I.checked);
  END;

  bool:=I.SetMenuStrip(window,menu^);

(* Updating values to new resolution *)

  mathconv.stdpicx:=gb.GetStdPicX(screen.width);
  mathconv.stdpicy:=gb.GetStdPicY(screen.height);
END Init;

PROCEDURE Close*;

VAR wbscreen : I.ScreenPtr;
    i        : INTEGER;
    bool     : BOOLEAN;

BEGIN
  wbscreen:=I.LockPubScreen("Workbench");
  IF bt.os>=39 THEN
    i:=3;
    WHILE i<screenmode.reserved-1 DO
      INC(i);
      g.ReleasePen(colormap,i);
    END;
  END;
  IF vinfo#NIL THEN
    gd.FreeVisualInfo(vinfo);
    vinfo:=NIL;
  END;
  IF window#NIL THEN
    I.ClearMenuStrip(window);
    mainsub.Close;
    window:=NIL;
  END;
  IF (screen#NIL) & (screen#wbscreen) THEN
    bool:=I.CloseScreen(screen);
  END;
  screen:=NIL;
  I.UnlockPubScreen("Workbench",wbscreen);
END Close;

PROCEDURE Destruct*;

VAR wbscreen : I.ScreenPtr;
    bool     : BOOLEAN;

BEGIN
  wbscreen:=I.LockPubScreen("Workbench");
  IF window#NIL THEN
    I.ClearMenuStrip(window);
    mainwind.Destruct;
    window:=NIL;
  END;
  wm.CloseAllWindows;
  IF (screen#NIL) & (screen#wbscreen) THEN
    bool:=I.CloseScreen(screen);
  END;
  screen:=NIL;
  IF menu#NIL THEN
    gd.FreeMenus(menu); menu:=NIL;
  END;
  I.UnlockPubScreen("Workbench",wbscreen);
END Destruct;

PROCEDURE ImitateMenu*(VAR code:INTEGER);

BEGIN
  IF code=9 THEN (* Schnelleingabe *)
    code:=I.FullMenuNum(1,6,0);
  ELSIF code=20 THEN (* Text erstellen *)
    code:=I.FullMenuNum(2,8,0);
  ELSIF code=254 THEN (* Text verändern *)
    code:=I.FullMenuNum(2,8,1);
  ELSIF code=148 THEN (* Text-Standard *)
    code:=I.FullMenuNum(2,8,4);
  ELSIF code=16 THEN (* Punkt erstellen *)
    code:=I.FullMenuNum(2,9,0);
  ELSIF code=182 THEN (* Punkt verändern *)
    code:=I.FullMenuNum(2,9,1);
  ELSIF code=144 THEN (* Punkt-Standard *)
    code:=I.FullMenuNum(2,9,4);
  ELSIF code=13 THEN (* Markierung erstellen *)
    code:=I.FullMenuNum(2,10,0);
  ELSIF code=184 THEN (* Markierung verändern *)
    code:=I.FullMenuNum(2,10,1);
  ELSIF code=141 THEN (* Markierung-Standard *)
    code:=I.FullMenuNum(2,10,4);
  ELSIF code=19 THEN (* Schraffur erstellen *)
    code:=I.FullMenuNum(2,11,0);
  ELSIF code=223 THEN (* Schraffur verändern *)
    code:=I.FullMenuNum(2,11,1);
  ELSIF code=147 THEN (* Schraffur-Standard *)
    code:=I.FullMenuNum(2,11,4);
  ELSIF code=173 THEN (* Legende verändern *)
    code:=I.FullMenuNum(4,0,1);
  ELSIF code=142 THEN (* Legende-Standard *)
    code:=I.FullMenuNum(4,0,4);
  ELSIF code=176 THEN (* Wertetabelle verändern *)
    code:=I.FullMenuNum(4,1,1);
  ELSIF code=151 THEN (* Wertetabelle-Standard *)
    code:=I.FullMenuNum(4,1,4);
  ELSIF code=163 THEN (* Liste verändern *)
    code:=I.FullMenuNum(4,2,1);
  ELSIF code=140 THEN (* Liste-Standard *)
    code:=I.FullMenuNum(4,2,4);
  ELSE
    code:=-1;
  END;
END ImitateMenu;

BEGIN
  menu:=NIL;
  screenmode:=NIL;
  NEW(screenmode);

  mainwind:=NIL; mainsub:=NIL;
  mainwind:=wm.InitWindow(50,100,200,100,FALSE,vs.mainwindtitle,LONGSET{I.windowDrag,I.windowSizing,I.windowClose,I.windowDepth,I.activate,I.simpleRefresh,I.noCareRefresh},LONGSET{I.menuPick,I.closeWindow,I.rawKey,I.vanillaKey,I.activeWindow,I.inactiveWindow});
  mainsub:=mainwind.InitSub(NIL);

(* Setting screen mode for first start *)

  screenmode.width:=I.stdScreenWidth;
  screenmode.height:=I.stdScreenHeight;
  screenmode.depth:=2;
  screenmode.displayId:=g.ntscMonitorID+g.hiresKey;
  screenmode.oscan:=I.oScanText;
  screenmode.autoscroll:=I.LTRUE;
  screenmode.colormap[0,0]:=-1;
  screenmode.reserved:=4;
  screenmode.usewbscreen:=FALSE;
  screenmode.clonewb:=TRUE;

(* Initializing Math Mode's standard conversion table *)

  NEW(mathconv);
  mathconv.stdpicx:=20;
  mathconv.stdpicy:=10;
CLOSE
(*  Destruct;*)
  IF screenmode#NIL  THEN DISPOSE(screenmode); END;
END MathGUI.

