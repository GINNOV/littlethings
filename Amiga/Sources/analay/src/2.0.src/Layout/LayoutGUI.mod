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


MODULE LayoutGUI;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       u  : Utility,
       gd : GadTools,
       bt : BasicTools,
       wm : WindowManager,
       mm : MenuManager,
       gg : GeneralGUI,
       lb : LayoutBasics,
       mg : MathGUI,
       vs : VersionStrings,
       ac : AnalayCatalog,
       lc : LayoutConversion,
       pi : PlotInfo,
       io,
       NoGuruRq;


TYPE Menu * = POINTER TO MenuDesc;
     MenuDesc * = RECORD
       bold*,italic  * ,
       underline     * ,
       left*,right   * ,
       center*,block * ,
       tool          * ,
       showinactmenu * ,
       ownscreenmenu * : I.MenuItemPtr;
     END;



VAR screen     * : I.ScreenPtr;    (* Layout default screen, can be Workbench, Math or Private *)
    window     * : I.WindowPtr;    (* Backdrop on private screen. *)
    mainwind   * : wm.Window;
    mainsub    * : wm.SubWindow;
    maindisp   * : pi.Display;
    menu       * ,
    dragbarmenu* : I.MenuPtr;
    plast      * : ARRAY 1 OF INTEGER;
    screenmode * : gg.ScreenMode;
    menuitems  * ,
    dragitems  * : Menu;
    layoutconv * : lc.LayoutConversionTable; (* Standard Layout conversion table *)



PROCEDURE Init*; (* Layout screen, etc. *)

VAR new           : I.ExtNewScreen;
    long          : LONGINT;
    rgb           : ARRAY 3 OF LONGINT;
    col,i         : INTEGER;
    set           : SET;
    bool          : BOOLEAN;

BEGIN
  IF lb.layoutoptions.ownscreen THEN
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
                                 I.saTitle,vs.layoutscreentitle,
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
    mainsub.SetScreen(screen);
    mainsub.SetScreenBack(TRUE);
    window:=mainsub.Open(NIL);

(* Updating display for PlotInfo *)

    maindisp.screen:=screen;
    maindisp.Init;
    maindisp.InitGreyScale;

    i:=3;
    WHILE i<screenmode.reserved-1 DO
      INC(i);
      g.GetRGB32(maindisp.colormap,i,1,rgb);
      long:=g.ObtainPen(maindisp.colormap,i,rgb[0],rgb[1],rgb[2],0);
    END;

    IF screenmode.colormap[0,0]=-1 THEN
      IF bt.os>=39 THEN
        FOR i:=0 TO 15 DO
          g.GetRGB32(maindisp.colormap,i,1,rgb);
          screenmode.colormap[i,0]:=bt.RGBToInt(rgb[0]);
          screenmode.colormap[i,1]:=bt.RGBToInt(rgb[1]);
          screenmode.colormap[i,2]:=bt.RGBToInt(rgb[2]);
        END;
      ELSE
        FOR i:=0 TO 15 DO
          col:=g.GetRGB4(maindisp.colormap,i);
          set:=s.VAL(SET,col);
          screenmode.colormap[i,0]:=s.VAL(INTEGER,s.LSH(s.LSH(set,4),-12))*255 DIV 15;
          screenmode.colormap[i,1]:=s.VAL(INTEGER,s.LSH(s.LSH(set,8),-12))*255 DIV 15;
          screenmode.colormap[i,2]:=s.VAL(INTEGER,s.LSH(s.LSH(set,12),-12))*255 DIV 15;
        END;
      END;
    ELSE
      FOR i:=0 TO 15 DO
        IF bt.os<39 THEN
          g.SetRGB4(maindisp.view,i,screenmode.colormap[i,0]*15 DIV 255,screenmode.colormap[i,1]*15 DIV 255,screenmode.colormap[i,2]*15 DIV 255);
        ELSE
          g.SetRGB32(maindisp.view,i,bt.IntToRGB(screenmode.colormap[i,0]),bt.IntToRGB(screenmode.colormap[i,1]),bt.IntToRGB(screenmode.colormap[i,2]));
        END;
      END;
    END;
  ELSE
    screen:=mg.screen;
    screenmode.displayId:=mg.screenmode.displayId;
    screenmode.oscan:=mg.screenmode.oscan;

    io.WriteString("IL1\n");
    maindisp.screen:=screen;
    io.WriteString("IL2\n");
    maindisp.Init;
    io.WriteString("IL3\n");
    maindisp.InitGreyScale;
    io.WriteString("IL4\n");

    window:=NIL;
  END;
  lb.screen:=screen;
  io.WriteString("IL5\n");



(* Menu stuff *)

  IF menu=NIL THEN
    mm.StartMenu(mg.window);

    mm.NewMenu(ac.GetString(ac.Program));
    mm.NewItem(ac.GetString(ac.Load),"O");
    mm.NewItem(ac.GetString(ac.Save),"S");
    mm.NewItem(ac.GetString(ac.SaveAs),"A");
    mm.Separator;
    mm.NewItem(s.ADR("Hide this document"),"H");
    mm.NewItem(s.ADR("Reveal any document"),"R");
    mm.Separator;
    mm.NewItem(ac.GetString(ac.Print),"P");
    mm.Separator;
    mm.NewItem(ac.GetString(ac.About),0X);
    mm.NewItem(ac.GetString(ac.QuitLayout),"Q");
  
    mm.NewMenu(ac.GetString(ac.Create));
    mm.NewItem(ac.GetString(ac.SetTextbox),"T");
    mm.NewItem2(ac.GetString(ac.SetTextline),s.ADR("Ctrl+T"));
    mm.NewItem(ac.GetString(ac.DrawLine),"L");
    mm.NewItem(ac.GetString(ac.SetRectangle),"R");
    mm.NewItem(ac.GetString(ac.SetEllipse),"E");
  
    mm.NewMenu(ac.GetString(ac.Work));
    mm.NewItem(ac.GetString(ac.DeleteActiveBox),"X");
    mm.Separator;
    mm.NewItem(ac.GetString(ac.ChangeActiveBox),"C");
    mm.NewItem(ac.GetString(ac.AdaptBoxSize),"M");
    mm.NewItem(ac.GetString(ac.ChangeBoxContents),"B");
    mm.Separator;
    mm.NewItem(ac.GetString(ac.GlobalPageSettings),"G");
  
    mm.NewMenu(ac.GetString(ac.Text));
    mm.NewItem(ac.GetString(ac.Script),"S");
    mm.NewItem2(ac.GetString(ac.Style),s.ADR("»"));
    mm.NewSubCheckItem(ac.GetString(ac.Bold),0X,FALSE);
    mm.NewSubCheckItem(ac.GetString(ac.Italic),0X,FALSE);
    mm.NewSubCheckItem(ac.GetString(ac.Underlined),0X,FALSE);
    mm.NewItem2(ac.GetString(ac.Alignment),s.ADR("»"));
    mm.NewSubCheckItem(ac.GetString(ac.Left),0X,FALSE);
    mm.NewSubCheckItem(ac.GetString(ac.Right),0X,FALSE);
    mm.NewSubCheckItem(ac.GetString(ac.Center),0X,FALSE);
    mm.NewSubCheckItem(ac.GetString(ac.Justify),0X,FALSE);
    mm.NewItem(ac.GetString(ac.Color),0X);
    mm.NewItem(ac.GetString(ac.ImportASCII),"I");
    mm.Separator;
    mm.NewItem(ac.GetString(ac.InsertFormula),"F");
    mm.NewItem2(ac.GetString(ac.ChangeFormula),s.ADR("Ctrl+F"));
    mm.Separator;
    mm.NewItem(ac.GetString(ac.ChangeTextLine),0X);
  
  (*  mm.NewMenu("Grafik");
    mm.NewItem("Verändern","C");*)
  
(*    mm.NewMenu(ac.GetString(ac.Conversion));
    mm.NewItem(ac.GetString(ac.Font),0X);
    mm.NewItem(ac.GetString(ac.Color),0X);
    mm.NewItem(ac.GetString(ac.LineThickness),0X);
    mm.Separator;
    mm.NewItem(ac.GetString(ac.AxisSystem),0X);
    mm.NewItem(ac.GetString(ac.BackgroundGrid),0X);*)
  
    mm.NewMenu(ac.GetString(ac.Preferences));
    mm.NewItem(ac.GetString(ac.Zoom),0X);
    mm.NewItem(ac.GetString(ac.RasterGrid),0X);
    mm.NewItem(ac.GetString(ac.DocumentColors),0X);
    mm.NewItem(ac.GetString(ac.Fonts),0X);
    mm.NewItem(ac.GetString(ac.ScreenPresentation),0X);
    mm.NewCheckItem(ac.GetString(ac.ShowInactive),0X,FALSE);
    mm.NewCheckItem(ac.GetString(ac.ToolBox),0X,TRUE);
    mm.NewCheckItem(ac.GetString(ac.CustomScreen),0X,FALSE);
    mm.NewCheckItem(ac.GetString(ac.CloneWB),0X,FALSE);
    mm.Separator;
    mm.NewItem(ac.GetString(ac.ScreenMode),0X);
    mm.NewItem(ac.GetString(ac.ScreenColors),0X);
    mm.Separator;
    mm.NewItem(ac.GetString(ac.Save),0X);
    mm.Separator;
    mm.NewItem(ac.GetString(ac.Load),0X);
    mm.NewItem(ac.GetString(ac.SaveAs),0X);
  
    menu:=mm.EndMenu();
  END;
  bool:=gd.LayoutMenus(menu,maindisp.vinfo,gd.mnNewLookMenus,I.LTRUE,
                                           u.done);

(* Creating dragbar menus *)

  IF dragbarmenu=NIL THEN
    mm.StartMenu(mg.window);

    mm.NewMenu(ac.GetString(ac.Program));
    mm.NewItem(ac.GetString(ac.Load),"O");
    mm.NewItem(ac.GetString(ac.Save),"S");
    mm.NewItem(ac.GetString(ac.SaveAs),"A");
    mm.Separator;
    mm.NewItem(s.ADR("New document"),"D");
    mm.NewItem(s.ADR("Hide document"),"H");
    mm.NewItem(s.ADR("Reveal document"),"R");
    mm.Separator;
    mm.NewItem(ac.GetString(ac.About),0X);
    mm.NewItem(ac.GetString(ac.QuitLayout),"Q");
  
    mm.NewMenu(ac.GetString(ac.Conversion));
    mm.NewItem(ac.GetString(ac.Font),0X);
    mm.NewItem(ac.GetString(ac.Color),0X);
    mm.NewItem(ac.GetString(ac.LineThickness),0X);
    mm.Separator;
    mm.NewItem(ac.GetString(ac.AxisSystem),0X);
    mm.NewItem(ac.GetString(ac.BackgroundGrid),0X);
  
    mm.NewMenu(ac.GetString(ac.Preferences));
    mm.NewItem(ac.GetString(ac.Zoom),0X);
    mm.NewItem(ac.GetString(ac.RasterGrid),0X);
    mm.NewItem(ac.GetString(ac.DocumentColors),0X);
    mm.NewItem(ac.GetString(ac.Fonts),0X);
    mm.NewItem(ac.GetString(ac.ScreenPresentation),0X);
    mm.NewCheckItem(ac.GetString(ac.ShowInactive),0X,FALSE);
    mm.NewCheckItem(ac.GetString(ac.ToolBox),0X,TRUE);
    mm.NewCheckItem(ac.GetString(ac.CustomScreen),0X,FALSE);
    mm.NewCheckItem(ac.GetString(ac.CloneWB),0X,FALSE);
    mm.Separator;
    mm.NewItem(ac.GetString(ac.ScreenMode),0X);
    mm.NewItem(ac.GetString(ac.ScreenColors),0X);
    mm.Separator;
    mm.NewItem(ac.GetString(ac.Save),0X);
    mm.Separator;
    mm.NewItem(ac.GetString(ac.Load),0X);
    mm.NewItem(ac.GetString(ac.SaveAs),0X);
  
    dragbarmenu:=mm.EndMenu();
  END;
  bool:=gd.LayoutMenus(dragbarmenu,maindisp.vinfo,gd.mnNewLookMenus,I.LTRUE,
                                                  u.done);

(* Maybe you need this?!? *)

(*  p1.scr.displayId:=g.GetVPModeID(p1.previewview);
  gt.GetModeDims(p1.scr.displayId,p1.scr.oscan,width,height,i);
  p1.scr.width:=width;
  p1.scr.height:=height;*)


  menuitems.bold:=menu.nextMenu.nextMenu.nextMenu.firstItem.nextItem.subItem;
  menuitems.italic:=menuitems.bold.nextItem;
  menuitems.underline:=menuitems.italic.nextItem;
  menuitems.left:=menu.nextMenu.nextMenu.nextMenu.firstItem.nextItem.nextItem.subItem;
  menuitems.right:=menuitems.left.nextItem;
  menuitems.center:=menuitems.right.nextItem;
  menuitems.block:=menuitems.center.nextItem;
  menuitems.showinactmenu:=menu.nextMenu.nextMenu.nextMenu.nextMenu.firstItem.nextItem.nextItem.nextItem.nextItem.nextItem;
  menuitems.tool:=menuitems.showinactmenu.nextItem;
  menuitems.ownscreenmenu:=menuitems.tool.nextItem;

  IF lb.layoutoptions.toolbox THEN
    INCL(menuitems.tool.flags,I.checked);
  ELSE
    EXCL(menuitems.tool.flags,I.checked);
  END;
  IF lb.layoutoptions.showinact THEN
    INCL(menuitems.showinactmenu.flags,I.checked);
  ELSE
    EXCL(menuitems.showinactmenu.flags,I.checked);
  END;
  IF lb.layoutoptions.ownscreen THEN
    INCL(menuitems.ownscreenmenu.flags,I.checked);
  ELSE
    EXCL(menuitems.ownscreenmenu.flags,I.checked);
  END;
  IF screenmode.clonewb THEN
    INCL(menuitems.ownscreenmenu.nextItem.flags,I.checked);
  ELSE
    EXCL(menuitems.ownscreenmenu.nextItem.flags,I.checked);
  END;
END Init;

PROCEDURE Close*;

VAR wbscreen : I.ScreenPtr;
    bool     : BOOLEAN;

BEGIN
  wbscreen:=I.LockPubScreen("Workbench");
  IF window#NIL THEN
    I.ClearMenuStrip(window);
    mainsub.Close;
    window:=NIL;
  END;
  IF lb.layoutoptions.ownscreen & (screen#NIL) & (screen#wbscreen) THEN
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
  END;
  IF mainwind#NIL THEN
    mainwind.Destruct;
    window:=NIL;
  END;
  IF lb.layoutoptions.ownscreen & (screen#NIL) & (screen#wbscreen) THEN
    bool:=I.CloseScreen(screen);
  END;
  screen:=NIL;
  IF menu#NIL THEN
    gd.FreeMenus(menu); menu:=NIL;
  END;
  I.UnlockPubScreen("Workbench",wbscreen);
END Destruct;



BEGIN
  NEW(maindisp);
  IF maindisp=NIL THEN HALT(20); END;
  lb.maindisp:=maindisp;
  NEW(menuitems);
  IF menuitems=NIL THEN HALT(20); END;

  menu:=NIL;
  dragbarmenu:=NIL;
  screenmode:=NIL;
  NEW(screenmode);

  mainwind:=NIL; mainsub:=NIL;
  mainwind:=wm.InitWindow(50,100,200,100,FALSE,NIL,LONGSET{I.windowDrag,I.windowSizing,I.windowClose,I.windowDepth,I.activate,I.simpleRefresh,I.noCareRefresh},LONGSET{I.menuPick,I.closeWindow,I.rawKey,I.vanillaKey,I.activeWindow,I.inactiveWindow});
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

(*  NEW(layoutconv); layoutconv.Init(m.taskdata.layouttask);*) (* Now to be found in modul "Layout", because m.taskdata.layouttask is not yet properly set up here! *)
CLOSE
(*  Destruct;*)
  IF screenmode#NIL  THEN DISPOSE(screenmode); END;
  IF maindisp#NIL THEN maindisp.Destruct; END;
END LayoutGUI.

