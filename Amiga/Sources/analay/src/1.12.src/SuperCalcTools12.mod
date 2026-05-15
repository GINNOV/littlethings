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


MODULE SuperCalcTools12;

IMPORT I  : Intuition,
       g  : Graphics,
       d  : Dos,
       e  : Exec,
       s  : SYSTEM,
       f  : Function,
       l  : LinkedLists,
       f1 : Function1,
       c  : Conversions,
       as : ASL,
       wm : WindowManager,
       gm : GadgetManager,
       it : IntuitionTools,
       tt : TextTools,
       at : AslTools,
       vt : VectorTools,
       gt : GraphicsTools,
       ag : AmigaGuideTools,
       ac : AnalayCatalog,
       lrc: LongRealConversions,
       st : Strings,
       r  : Requests,
       s1 : SuperCalcTools1,
       s2 : SuperCalcTools2,
       s3 : SuperCalcTools3,
       s4 : SuperCalcTools4,
       s5 : SuperCalcTools5,
       s6 : SuperCalcTools6,
       s7 : SuperCalcTools7,
       s8 : SuperCalcTools8,
       s9 : SuperCalcTools9,
       s10: SuperCalcTools10,
       s11: SuperCalcTools11,
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- $StackChk- $ReturnChk- *)

VAR ok,bool     : BOOLEAN;
    code        : INTEGER;
    class       : LONGSET;
    address     : s.ADDRESS;
    a,j,i       : INTEGER;
    textId    * ,
    pointId   * ,
    markId    * ,
    pointdesId* ,
    markdesId * : INTEGER;


PROCEDURE ChangeText*(p,text:l.Node):BOOLEAN;

VAR wind    : I.WindowPtr;
    rast    : g.RastPortPtr;
    ok,ca,
    help,
    textgad,
    font,
    bold,
    italic,
    under,
    trans,
    xpos,
    ypos,
    klebe,
    bound,
    maus    : I.GadgetPtr;
    palf,
    palb    : l.Node;
    cols    : INTEGER;
    ret     : BOOLEAN;
    table   : ARRAY 2 OF ARRAY 28 OF CHAR;
    boundpos: INTEGER;
    textstr : ARRAY 256 OF CHAR;
    xposstr,
    yposstr : ARRAY 80 OF CHAR;
    actcolf,
    actcolb : INTEGER;
    style   : SHORTSET;
    transb,
    snap    : BOOLEAN;
    x,y     : INTEGER;
    realx,
    realy   : REAL;
    longx,
    longy   : LONGREAL;
    auto    : ARRAY 5 OF CHAR;
    node,
    savetext: l.Node;
    fontrequest : as.FontRequesterPtr;

PROCEDURE RefreshCoords;

BEGIN
  WITH text: s1.Text DO
    gm.PutGadgetText(xpos,text.xkstr);
    IF NOT(text.snap) THEN
      gm.PutGadgetText(ypos,text.ykstr);
    ELSE
      gm.PutGadgetText(ypos,text.ykstr);
      I.OffGadget(ypos^,wind,NIL);
    END;
    I.RefreshGList(xpos,wind,NIL,2);
  END;
END RefreshCoords;

PROCEDURE GetXCoord;

BEGIN
  WITH text: s1.Text DO
    gm.GetGadgetText(xpos,text.xkstr);
    longx:=f.ExpressionToReal(text.xkstr);
    IF boundpos=0 THEN
      text.weltx:=longx;
      IF text.snap THEN
        s2.SnapToFunktion(node,text.weltx,text.welty);
        s1.WorldToPic(text.weltx,text.welty,text.picx,text.picy,p);
        bool:=lrc.RealToString(text.welty,text.ykstr,7,7,FALSE);
        tt.Clear(text.ykstr);
      ELSE
        s1.WorldToPic(text.weltx,text.welty,text.picx,text.picy,p);
      END;
    ELSIF boundpos=1 THEN
      text.picx:=SHORT(SHORT(SHORT(longx)));
      s1.PicToWorld(text.weltx,text.welty,text.picx,text.picy,p);
      IF text.snap THEN
        s2.SnapToFunktion(node,text.weltx,text.welty);
        s1.WorldToPic(text.weltx,text.welty,text.picx,text.picy,p);
        bool:=c.IntToString(text.picy,text.ykstr,7);
        tt.Clear(text.ykstr);
      END;
    END;
  END;
END GetXCoord;

PROCEDURE GetYCoord;

BEGIN
  WITH text: s1.Text DO
    gm.GetGadgetText(ypos,text.ykstr);
    longy:=f.ExpressionToReal(text.ykstr);
    IF boundpos=0 THEN
      text.welty:=longy;
    ELSE
      text.picy:=SHORT(SHORT(SHORT(longy)));
    END;
    s1.RefreshOtherCoord(p,text);
  END;
END GetYCoord;

PROCEDURE GetText;

BEGIN
  WITH text: s1.Text DO
    gm.GetGadgetText(textgad,text.string);
  END;
END GetText;

BEGIN
  ret:=FALSE;
  IF textId=-1 THEN
    textId:=wm.InitWindow(80,20,464,193,ac.GetString(ac.ChangeText),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.mouseMove},s1.screen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,172,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(350,172,100,14,ac.GetString(ac.Cancel));
  help:=gm.SetBooleanGadget(120,172,100,14,ac.GetString(ac.Help));
  font:=gm.SetBooleanGadget(252,56,186,14,ac.GetString(ac.Font));
  maus:=gm.SetBooleanGadget(26,149,208,14,ac.GetString(ac.Mouse));
  IF p=s1.std.wind THEN
    INCL(maus.flags,I.gadgDisabled);
  END;
  IF g.bold IN text(s1.Text).style THEN
    bool:=TRUE;
  ELSE
    bool:=FALSE;
  END;
  bold:=gm.SetCheckBoxGadget(412,72,26,9,bool);
  IF g.italic IN text(s1.Text).style THEN
    bool:=TRUE;
  ELSE
    bool:=FALSE;
  END;
  italic:=gm.SetCheckBoxGadget(412,83,26,9,bool);
  IF g.underlined IN text(s1.Text).style THEN
    bool:=TRUE;
  ELSE
    bool:=FALSE;
  END;
  under:=gm.SetCheckBoxGadget(412,94,26,9,bool);
  trans:=gm.SetCheckBoxGadget(412,105,26,9,text(s1.Text).trans);
  klebe:=gm.SetCheckBoxGadget(412,134,26,9,text(s1.Text).snap);
  textgad:=gm.SetStringGadget(26,40,400,14,255);
  xpos:=gm.SetStringGadget(86,133,40,14,79);
  ypos:=gm.SetStringGadget(206,133,40,14,79);
  COPY(ac.GetString(ac.AxesCoordinates)^,table[0]);
  COPY(ac.GetString(ac.ScreenCoordinates)^,table[1]);
  boundpos:=0;
  bound:=gm.SetCycleGadget(238,149,200,14,table[0]);
  palf:=gm.SetPaletteGadget(26,65,200,20,s1.screen.rastPort.bitMap.depth,text(s1.Text).colf);
  palb:=gm.SetPaletteGadget(26,96,200,20,s1.screen.rastPort.bitMap.depth,text(s1.Text).colb);
  gm.EndGadgets;
  wm.SetGadgets(textId,ok);
  wm.ChangeScreen(textId,s1.screen);
  wind:=wm.OpenWindow(textId);
  IF wind#NIL THEN
    node:=p;
    WITH p: s1.Fenster DO
      WITH text: s1.Text DO
        rast:=wind.rPort;
(*        ig.SetPlastHighGadget(ok,wind,s.ADR("OK"),12,171,100,
                          SET{I.gadgImmediate,I.relVerify});
        ig.SetPlastHighGadget(ca,wind,s.ADR("Abbrechen"),348,171,100,
                          SET{I.gadgImmediate,I.relVerify});
  
        ig.SetPlastHighGadget(font,wind,s.ADR("Schriftart"),250,55,186,
                          SET{I.gadgImmediate,I.relVerify});
        ig.SetPlastHighGadget(maus,wind,s.ADR("Maus"),24,148,208,
                          SET{I.gadgImmediate,I.relVerify});
        ig.SetCheckBoxGadget(bold,wind,412,72,
                          SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
        ig.SetCheckBoxGadget(italic,wind,412,83,
                          SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
        ig.SetCheckBoxGadget(under,wind,412,94,
                          SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
        ig.SetCheckBoxGadget(trans,wind,412,105,
                          SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
        ig.SetCheckBoxGadget(klebe,wind,412,135,
                          SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
        ig.SetPlastStringGadget(textgad,wind,400,255,26,40,FALSE);
        ig.SetPlastStringGadget(xpos,wind,40,79,86,133,FALSE);
        ig.SetPlastStringGadget(ypos,wind,40,79,206,133,FALSE);

        ig.SetPlastCycleGadget(bound,wind,s.ADR(table[0]),236,148,200,
                          SET{I.gadgImmediate,I.relVerify});*)

        NEW(savetext(s1.Text));
        s1.InitNode(savetext);
        s1.CopyNode(text,savetext);

        g.SetAPen(rast,1);
        tt.Print(20,25,ac.GetString(ac.Text),rast);
        tt.Print(20,127,ac.GetString(ac.Coordinates),rast);
        g.SetAPen(rast,2);
        tt.Print(26,37,ac.GetString(ac.Input),rast);
        tt.Print(26,62,ac.GetString(ac.ForegroundColor),rast);
        tt.Print(26,93,ac.GetString(ac.BackgroundColor),rast);
        tt.Print(252,80,ac.GetString(ac.Bold),rast);
        tt.Print(252,91,ac.GetString(ac.Italic),rast);
        tt.Print(252,102,ac.GetString(ac.Underlined),rast);
        tt.Print(252,113,ac.GetString(ac.Transparent),rast);
        tt.Print(26,142,ac.GetString(ac.XCoord),rast);
        tt.Print(146,142,ac.GetString(ac.YCoord),rast);
        tt.Print(270,142,ac.GetString(ac.SnapToGraph),rast);

        it.DrawBorder(rast,14,16,436,153);
        it.DrawBorder(rast,20,28,424,91);
        it.DrawBorder(rast,20,130,424,36);

(*        cols:=SHORT(ig.Hoch(2,s1.screen.bitMap.depth));
        s1.SetPalette(colf,cols,wind,78,66);
        bordcol:=ig.SetPlastInBorder(16,38);
        I.DrawBorder(rast,bordcol,28,66);
  
        s1.SetPalette(colb,cols,wind,78,97);
        I.DrawBorder(rast,bordcol,28,97);
  
        bord1:=ig.SetPlastBorder(149,432);
        I.DrawBorder(rast,bord1,16,17);
  
        bord2:=ig.SetPlastBorder(87,420);
        I.DrawBorder(rast,bord2,22,29);

        bord3:=ig.SetPlastBorder(32,420);
        I.DrawBorder(rast,bord3,22,131);*)

        auto:="Auto";

        COPY(text.string,textstr);
        COPY(text.xkstr,xposstr);
        COPY(text.ykstr,yposstr);
        actcolf:=text.colf;
        actcolb:=text.colb;
        IF NOT(text.welt) THEN
          gm.CyclePressed(bound,wind,table,boundpos);
        END;
        style:=text.style;
        transb:=text.trans;
        snap:=text.snap;
(*        IF g.bold IN style THEN
          gm.ActivateBool(bold,wind);
        END;
        IF g.italic IN style THEN
          gm.ActivateBool(italic,wind);
        END;
        IF g.underlined IN style THEN
          gm.ActivateBool(under,wind);
        END;
        IF transb THEN
          gm.ActivateBool(trans,wind);
        END;
        IF snap THEN
          gm.ActivateBool(klebe,wind);
        END;*)
        gm.PutGadgetText(textgad,text.string);
        gm.PutGadgetText(xpos,text.xkstr);
        IF NOT(text.snap) THEN
          gm.PutGadgetText(ypos,text.ykstr);
        ELSE
          gm.PutGadgetText(ypos,text.ykstr);
(*          ig.PutGadgetText(s.ADR(ypos),s.ADR(auto));*)
          I.OffGadget(ypos^,wind,NIL);
        END;
        I.RefreshGList(textgad,wind,NIL,3);
        fontrequest:=NIL;

(*        g.SetAPen(rast,actcolf);
        g.RectFill(rast,30,67,63,82);
        g.SetAPen(rast,actcolb);
        g.RectFill(rast,30,98,63,113);*)

        gm.SetCorrectWindow(palf,wind);
        gm.RefreshPaletteGadget(palf);
        gm.SetCorrectWindow(palb,wind);
        gm.RefreshPaletteGadget(palb);

        bool:=I.ActivateGadget(textgad^,wind,NIL);

        LOOP
          e.WaitPort(wind.userPort);
          it.GetIMes(wind,class,code,address);
          bool:=gm.CheckPaletteGadget(palf,class,code,address);
          bool:=gm.CheckPaletteGadget(palb,class,code,address);
          text.colf:=gm.ActCol(palf);
          text.colb:=gm.ActCol(palb);
          GetText;
          IF I.gadgetUp IN class THEN
            IF address=ok THEN
              GetXCoord;
              GetYCoord;
              ret:=TRUE;
              EXIT;
            ELSIF address=ca THEN
              EXIT;
            ELSIF address=maus THEN
              REPEAT
                it.GetIMes(p.wind,class,code,address);
              UNTIL class=LONGSET{};
              I.WindowToFront(p.wind);
              I.ActivateWindow(p.wind);
              it.GetMousePos(p.wind,x,y);
              s1.PicToWorld(longx,longy,x,y,p);
              IF text.snap THEN
                s2.SnapToFunktion(node,longx,longy);
                s1.WorldToPic(longx,longy,x,y,p);
              END;
              text.picx:=x;
              text.picy:=y;
              text.weltx:=longx;
              text.welty:=longy;
              g.SetDrMd(p.rast,SHORTSET{g.complement});
              REPEAT
                s4.PlotObject(p,text,FALSE);
                e.WaitPort(p.wind.userPort);
                it.GetMousePos(p.wind,x,y);
                s4.PlotObject(p,text,FALSE);
                s1.PicToWorld(longx,longy,x,y,p);
                IF text.snap THEN
                  s2.SnapToFunktion(node,longx,longy);
                  s1.WorldToPic(longx,longy,x,y,p);
                END;
                text.picx:=x;
                text.picy:=y;
                text.weltx:=longx;
                text.welty:=longy;
                it.GetIMes(p.wind,class,code,address);
                IF NOT(I.mouseButtons IN class) THEN
                  REPEAT
                    it.GetIMes(p.wind,class,code,address);
                  UNTIL NOT(I.mouseMove IN class);
                END;
              UNTIL (I.mouseButtons IN class) AND (code=I.selectUp);
              IF boundpos=0 THEN
                bool:=lrc.RealToString(text.weltx,text.xkstr,7,7,FALSE);
                bool:=lrc.RealToString(text.welty,text.ykstr,7,7,FALSE);
                tt.Clear(text.xkstr);
                tt.Clear(text.ykstr);
                RefreshCoords;
(*                I.RefreshGList(xpos,wind,NIL,2);*)
              ELSE
                bool:=c.IntToString(text.picx,text.xkstr,7);
                bool:=c.IntToString(text.picy,text.ykstr,7);
                tt.Clear(text.xkstr);
                tt.Clear(text.ykstr);
                RefreshCoords;
(*                I.RefreshGList(xpos,wind,NIL,2);*)
              END;
              I.WindowToFront(wind);
              I.ActivateWindow(wind);
            ELSIF address=bold THEN
              IF g.bold IN text.attr.style THEN
                EXCL(text.attr.style,g.bold);
              ELSE
                INCL(text.attr.style,g.bold);
              END;
            ELSIF address=italic THEN
              IF g.italic IN text.attr.style THEN
                EXCL(text.attr.style,g.italic);
              ELSE
                INCL(text.attr.style,g.italic);
              END;
            ELSIF address=under THEN
              IF g.underlined IN text.attr.style THEN
                EXCL(text.attr.style,g.underlined);
              ELSE
                INCL(text.attr.style,g.underlined);
              END;
            ELSIF address=trans THEN
              text.trans:=NOT(text.trans);
            ELSIF address=font THEN
(*              at.SetFontRequestMinMax(1,100);*)
              bool:=at.FontRequest(fontrequest,ac.GetString(ac.SelectFontForText),wind,s.ADR(text.attr),at.nocols,at.nocols);
            ELSIF address=klebe THEN
              text.snap:=NOT(text.snap);
              IF NOT(text.snap) THEN
(*                ig.PutGadgetText(s.ADR(ypos),s.ADR(text.ykstr));*)
                I.OnGadget(ypos^,wind,NIL);
              ELSE
(*                ig.PutGadgetText(s.ADR(ypos),s.ADR(auto));*)
                IF boundpos=0 THEN
                  s2.SnapToFunktion(node,text.weltx,text.welty);
                  s1.WorldToPic(text.weltx,text.welty,text.picx,text.picy,p);
                  bool:=lrc.RealToString(text.welty,text.ykstr,7,7,FALSE);
                  tt.Clear(text.ykstr);
                  RefreshCoords;
(*                  I.RefreshGList(xpos,wind,NIL,2);*)
                ELSIF boundpos=1 THEN
                  s2.SnapToFunktion(node,text.weltx,text.welty);
                  s1.WeltToPic(SHORT(text.weltx),SHORT(text.welty),x,y,p.xmin,p.xmax,p.ymin,p.ymax,p.width,p.height);
                  s1.WorldToPic(text.weltx,text.welty,text.picx,text.picy,p);
                  bool:=c.IntToString(text.picy,text.ykstr,7);
                  tt.Clear(text.ykstr);
                  RefreshCoords;
(*                  I.RefreshGList(xpos,wind,NIL,2);*)
                END;
                I.OffGadget(ypos^,wind,NIL);
              END;
            ELSIF address=bound THEN
              gm.CyclePressed(bound,wind,table,boundpos);
              text.welt:=NOT(text.welt);
              IF boundpos=0 THEN
                s1.PicToWorld(text.weltx,text.welty,text.picx,text.picy,p);
                bool:=lrc.RealToString(text.weltx,text.xkstr,7,7,FALSE);
                bool:=lrc.RealToString(text.welty,text.ykstr,7,7,FALSE);
                tt.Clear(text.xkstr);
                tt.Clear(text.ykstr);
                RefreshCoords;
(*                I.RefreshGList(xpos,wind,NIL,2);*)
              ELSE
                s1.WorldToPic(text.weltx,text.welty,text.picx,text.picy,p);
                bool:=c.IntToString(text.picx,text.xkstr,7);
                bool:=c.IntToString(text.picy,text.ykstr,7);
                tt.Clear(text.xkstr);
                tt.Clear(text.ykstr);
                RefreshCoords;
(*                I.RefreshGList(xpos,wind,NIL,2);*)
              END;
            ELSIF address=textgad THEN
              bool:=I.ActivateGadget(xpos^,wind,NIL);
            ELSIF address=xpos THEN
(*              pos:=0;
              root:=f.Parse(text.xkstr,pos);
              pos:=0;
              longx:=f.RechenLong(root,0,0,pos);
              IF boundpos=0 THEN
                text.weltx:=longx;
                IF text.snap THEN
                  s1.SnapToFunktion(node,text.weltx,text.welty);
                  s1.WorldToPic(text.weltx,text.welty,text.picx,text.picy,p);
                  bool:=lrc.RealToString(text.welty,text.ykstr,7,7,FALSE);
                  tt.Clear(text.ykstr);
                  RefreshCoords;
(*                  I.RefreshGList(xpos,wind,NIL,2);*)
                ELSE
                  s1.WorldToPic(text.weltx,text.welty,text.picx,text.picy,p);
                END;
              ELSIF boundpos=1 THEN
                text.picx:=SHORT(SHORT(SHORT(longx)));
                s1.PicToWorld(text.weltx,text.welty,text.picx,text.picy,p);
                IF text.snap THEN
                  s1.SnapToFunktion(node,text.weltx,text.welty);
                  s1.WorldToPic(text.weltx,text.welty,text.picx,text.picy,p);
                  bool:=c.IntToString(text.picy,text.ykstr,7);
                  tt.Clear(text.ykstr);
                  RefreshCoords;
(*                  I.RefreshGList(xpos,wind,NIL,2);*)
                END;
              END;*)

              GetXCoord;
              RefreshCoords;
              IF NOT(text.snap) THEN
                bool:=I.ActivateGadget(ypos^,wind,NIL);
              ELSE
                bool:=I.ActivateGadget(textgad^,wind,NIL);
              END;
            ELSIF address=ypos THEN
(*              pos:=0;
              root:=f.Parse(text.ykstr,pos);
              pos:=0;
              text.welty:=f.RechenLong(root,0,0,pos);
              s1.WorldToPic(text.weltx,text.welty,text.picx,text.picy,p);*)
              GetYCoord;
              bool:=I.ActivateGadget(textgad^,wind,NIL);
(*            ELSE
              i:=-1;
              WHILE i<cols-1 DO
                INC(i);
                IF address=s.ADR(colf[i]) THEN
                  g.SetAPen(rast,i);
                  g.RectFill(rast,30,67,63,82);
                  text.colf:=i;
                ELSIF address=s.ADR(colb[i]) THEN
                  g.SetAPen(rast,i);
                  g.RectFill(rast,30,98,63,113);
                  text.colb:=i;
                END;
              END;*)
            END;
          END;
          IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
            ag.ShowFile(s1.analaydoc,"texts",wind);
          END;
        END;

        IF fontrequest#NIL THEN
          as.FreeAslRequest(fontrequest);
        END;
(*        ig.FreePlastStringGadget(ypos,wind);
        ig.FreePlastStringGadget(xpos,wind);
        ig.FreePlastStringGadget(textgad,wind);
        ig.FreePlastCheckBoxGadget(klebe,wind);
        ig.FreePlastCheckBoxGadget(trans,wind);
        ig.FreePlastCheckBoxGadget(under,wind);
        ig.FreePlastCheckBoxGadget(italic,wind);
        ig.FreePlastCheckBoxGadget(bold,wind);
        ig.FreePlastHighBooleanGadget(maus,wind);
        ig.FreePlastHighBooleanGadget(font,wind);
        ig.FreePlastHighBooleanGadget(ca,wind);
        ig.FreePlastHighBooleanGadget(ok,wind);
        ig.FreePlastBorder(bord1);
        ig.FreePlastBorder(bord2);
        ig.FreePlastBorder(bord3);
        ig.FreePlastBorder(bordcol);*)
        wm.CloseWindow(textId);
        s1.FreeNode(savetext);
      END;
    END;
  END;
  wm.FreeGadgets(textId);
  IF NOT(ret) THEN
    s1.CopyNode(savetext,text);
  END;
  RETURN ret;
END ChangeText;

PROCEDURE * PrintLabel(rast:g.RastPortPtr;x,y,width,num:INTEGER;datalist:l.List);

VAR node : l.Node;
    str  : e.STRPTR;

BEGIN
  node:=s1.GetNode(s1.labels,num);
  IF node#NIL THEN
    WITH node: s1.Label DO
      NEW(str);
      COPY(node.string,str^);
      tt.CutStringToLength(rast,str^,width);
      tt.Print(x,y,str,rast);
      DISPOSE(str);
    END;
  END;
END PrintLabel;

PROCEDURE ChangePoint*(p,point:l.Node):BOOLEAN;

VAR wind : I.WindowPtr;
    rast : g.RastPortPtr;
    ok,ca,
    help,
    name,add,
    del,font,
    changedes,
    trans,
    format,
    string,
    label,maus,
    klebe,xpos,
    ypos,bound: I.GadgetPtr;
    list,
    palf,palb : l.Node;
    ret       : BOOLEAN;
    node,
    savepoint : l.Node;
    cols      : INTEGER;
    boundpos  : INTEGER;
    table     : ARRAY 2 OF ARRAY 28 OF CHAR;
    x,y       : INTEGER;
    longx,
    longy     : LONGREAL;
    objname   : ARRAY 20 OF CHAR;
    str       : ARRAY 80 OF CHAR;
    fontrequest : as.FontRequesterPtr;


(*PROCEDURE RefreshPoints;

VAR i : INTEGER;

BEGIN
  g.SetAPen(rast,1);
  FOR i:=0 TO 9 DO
    vt.DrawVectorObject(rast,s1.points[i],231+i*21+8,104+8,16,16,0,1,1);
(*    s3.PlotPointMatrix(rast,231+i*21,104,i);*)
  END;
END RefreshPoints;

PROCEDURE RefreshPointBorders;

VAR i : INTEGER;

BEGIN
  FOR i:=0 TO 9 DO
    IF i=point(s1.Point).point THEN
      it.DrawBorderIn(rast,228+i*21,102,21,20);
    ELSE
      it.DrawBorder(rast,228+i*21,102,21,20);
    END;
  END;
END RefreshPointBorders;*)

PROCEDURE NewLabelList;

BEGIN
  gm.SetListViewParams(list,26,56,196,54,SHORT(s1.labels.nbElements()),s1.GetNodeNumber(s1.labels,point(s1.GraphObject).label),PrintLabel);
  gm.SetCorrectPosition(list);
  gm.RefreshListView(list);
END NewLabelList;

PROCEDURE RefreshLabel;

BEGIN
  IF point(s1.GraphObject).label#NIL THEN
    gm.PutGadgetText(label,point(s1.GraphObject).label(s1.Label).string);
    I.RefreshGList(label,wind,NIL,1);
    bool:=I.ActivateGadget(label^,wind,NIL);
  END;
END RefreshLabel;

PROCEDURE RefreshCoords;

BEGIN
  WITH point: s1.GraphObject DO
    gm.PutGadgetText(xpos,point.xkstr);
    IF NOT(point.snap) THEN
      gm.PutGadgetText(ypos,point.ykstr);
    ELSE
      gm.PutGadgetText(ypos,point.ykstr);
      I.OffGadget(ypos^,wind,NIL);
    END;
    I.RefreshGList(xpos,wind,NIL,2);
  END;
END RefreshCoords;

PROCEDURE GetXCoord;

BEGIN
  WITH point: s1.GraphObject DO
    gm.GetGadgetText(xpos,point.xkstr);
    longx:=f.ExpressionToReal(point.xkstr);
    IF boundpos=0 THEN
      point.weltx:=longx;
      IF point.snap THEN
        s2.SnapToFunktion(node,point.weltx,point.welty);
        s1.WorldToPic(point.weltx,point.welty,point.picx,point.picy,p);
        bool:=lrc.RealToString(point.welty,point.ykstr,7,7,FALSE);
        tt.Clear(point.ykstr);
      ELSE
        s1.WorldToPic(point.weltx,point.welty,point.picx,point.picy,p);
      END;
    ELSIF boundpos=1 THEN
      point.picx:=SHORT(SHORT(SHORT(longx)));
      s1.PicToWorld(point.weltx,point.welty,point.picx,point.picy,p);
      IF point.snap THEN
        s2.SnapToFunktion(node,point.weltx,point.welty);
        s1.WorldToPic(point.weltx,point.welty,point.picx,point.picy,p);
        bool:=c.IntToString(point.picy,point.ykstr,7);
        tt.Clear(point.ykstr);
      END;
    END;
  END;
END GetXCoord;

PROCEDURE GetYCoord;

BEGIN
  WITH point: s1.GraphObject DO
    gm.GetGadgetText(ypos,point.ykstr);
    longy:=f.ExpressionToReal(point.ykstr);
    IF boundpos=0 THEN
      point.welty:=longy;
    ELSE
      point.picy:=SHORT(SHORT(SHORT(longy)));
    END;
    s1.RefreshOtherCoord(p,point);
  END;
END GetYCoord;

PROCEDURE GetTexts;

BEGIN
  WITH point: s1.GraphObject DO
    gm.GetGadgetText(name,point.string);
    IF point.label#NIL THEN
      gm.GetGadgetText(label,point.label(s1.Label).string);
    END;
  END;
END GetTexts;

PROCEDURE ChangePointDes(point:l.Node):BOOLEAN;

VAR wind     : I.WindowPtr;
    rast     : g.RastPortPtr;
    ok,ca,
    help,
    fill     : I.GadgetPtr;
    x,y,i,
    oldpoint : INTEGER;
    ret      : BOOLEAN;

PROCEDURE RefreshPoints;

VAR savepoint : INTEGER;

BEGIN
  savepoint:=point(s1.Point).point;
  g.SetAPen(rast,2);
  FOR i:=0 TO 9 DO
    point(s1.Point).point:=i;
    s4.RawPlotPoint(rast,point,29+i*(s1.stdpicx+10)+(s1.stdpicx DIV 2),41+(s1.stdpicy DIV 2),s1.stdpicx,s1.stdpicy,1,1,1,0);
(*    IF i<=5 THEN
      vt.DrawVectorObject(rast,s1.points[i].data,29+i*(s1.stdpicx+10)+(s1.stdpicx DIV 2),41+(s1.stdpicy DIV 2),s1.stdpicx,s1.stdpicy,0,1,1);
    ELSIF i=6 THEN
      g.DrawEllipse(rast,29+i*(s1.stdpicx+10)+(s1.stdpicx DIV 2),41+(s1.stdpicy DIV 2),SHORT(SHORT(0.4*s1.stdpicx)),SHORT(SHORT(0.4*s1.stdpicy)));
    ELSIF i=7 THEN
      g.DrawEllipse(rast,29+i*(s1.stdpicx+10)+(s1.stdpicx DIV 2),41+(s1.stdpicy DIV 2),SHORT(SHORT(0.2*s1.stdpicx)),SHORT(SHORT(0.2*s1.stdpicy)));
    END;*)
  END;
  point(s1.Point).point:=savepoint;
END RefreshPoints;

PROCEDURE RefreshPointBorders;

BEGIN
  FOR i:=0 TO 9 DO
    IF i=point(s1.Point).point THEN
      it.DrawBorderIn(rast,26+i*(s1.stdpicx+10),40,s1.stdpicx+8,s1.stdpicy+3);
    ELSE
      it.DrawBorder(rast,26+i*(s1.stdpicx+10),40,s1.stdpicx+8,s1.stdpicy+3);
    END;
  END;
END RefreshPointBorders;

BEGIN
  ret:=FALSE;
  IF pointdesId=-1 THEN
    pointdesId:=wm.InitWindow(20,20,40+10*(s1.stdpicx+10)-2+12,71+15+s1.stdpicy,ac.GetString(ac.PointDesign),LONGSET{I.activate,I.windowDrag,I.windowDepth},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.intuiTicks},s1.screen,FALSE);
  ELSE
    wm.SetDimensions(pointdesId,-1,-1,40+10*(s1.stdpicx+10)-2+12,71+15+s1.stdpicy);
  END;
  wm.ChangeScreen(pointdesId,s1.screen);
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,-20,100,14,ac.GetString(ac.OK));
  INCL(ok.flags,I.gRelBottom);
  ca:=gm.SetBooleanGadget(-113,-20,100,14,ac.GetString(ac.Cancel));
  INCL(ca.flags,I.gRelRight);
  INCL(ca.flags,I.gRelBottom);
  fill:=gm.SetCheckBoxGadget(-51,-40,26,9,point(s1.Point).fill);
  INCL(fill.flags,I.gRelRight);
  INCL(fill.flags,I.gRelBottom);
  gm.EndGadgets;
  wm.SetGadgets(pointdesId,ok);
  wind:=wm.OpenWindow(pointdesId);
  IF wind#NIL THEN
    WITH point: s1.Point DO
      rast:=wind.rPort;
  
      it.DrawBorder(rast,14,16,wind.width-28,31+s1.stdpicy+15);
      it.DrawBorder(rast,20,28,wind.width-28-12,31+s1.stdpicy);
  
      g.SetAPen(rast,1);
      tt.Print(20,25,ac.GetString(ac.PointDesign),rast);
      g.SetAPen(rast,2);
      tt.Print(26,37,ac.GetString(ac.Point),rast);
      tt.Print(26,wind.height-33,ac.GetString(ac.FillPoint),rast);

      oldpoint:=point.point;

      RefreshPoints;
      RefreshPointBorders;
      IF (point.point=6) OR (point.point=7) THEN
        I.OnGadget(fill^,wind,NIL);
        IF point.fill THEN
          gm.ActivateBool(fill,wind);
        ELSE
          gm.DeActivateBool(fill,wind);
        END;
      ELSE
        I.OffGadget(fill^,wind,NIL);
      END;

      LOOP
        e.WaitPort(wind.userPort);
        it.GetIMes(wind,class,code,address);
        IF I.gadgetUp IN class THEN
          IF address=ok THEN
            ret:=TRUE;
            EXIT;
          ELSIF address=ca THEN
            point.point:=oldpoint;
            EXIT;
          ELSIF address=fill THEN
            point.fill:=NOT(point.fill);
          END;
        ELSIF (I.mouseButtons IN class) AND (code=I.selectDown) THEN
          it.GetMousePos(wind,x,y);
          IF (y>=40) AND (y<40+s1.stdpicy+4) THEN
            DEC(x,26);
            x:=x DIV (s1.stdpicx+10);
            IF (x>=0) AND (x<=9) THEN
              point.point:=x;
              RefreshPointBorders;
              IF (point.point>=4) AND (point.point<=7) THEN
                I.OnGadget(fill^,wind,NIL);
                g.SetAPen(rast,0);
                g.RectFill(rast,wind.width-51,wind.height-40,wind.width-51+26,wind.height-40+9);
                IF point.fill THEN
                  gm.ActivateBool(fill,wind);
                ELSE
                  gm.DeActivateBool(fill,wind);
                END;
              ELSE
                I.OffGadget(fill^,wind,NIL);
              END;
            END;
          END;
        END;
        IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"pointdesreq",wind);
        END;
      END;
    END;
    wm.CloseWindow(pointdesId);
  END;
  wm.FreeGadgets(pointdesId);
  RETURN ret;
END ChangePointDes;

PROCEDURE ChangeMarkDes(mark:l.Node):BOOLEAN;

VAR wind        : I.WindowPtr;
    rast        : g.RastPortPtr;
    ok,ca,help  : I.GadgetPtr;
    x,y,i,pos,
    oldline,
    oldwidth,
    oldtextdir,
    oldtextside : INTEGER;
    ret         : BOOLEAN;

PROCEDURE RefreshTextDirs;

BEGIN
  g.SetAPen(rast,1);
  FOR i:=0 TO 3 DO
    gt.DrawLine(rast,40+i*52,124,40+i*52,159,1,1,s1.lines[0],pos);
    IF i=0 THEN
      tt.Print(42+i*52,132,s.ADR("x=1"),rast);
    ELSIF i=1 THEN
      tt.PrintDown(42+i*52,132,s.ADR("x=1"),rast);
    ELSIF i=2 THEN
      tt.PrintRotated(42+i*52,132-rast.txBaseline,"x=1",rast,-90);
    ELSIF i=3 THEN
      tt.PrintRotated(42+i*52,132-rast.txBaseline,"x=1",rast,90);
    END;
  END;
END RefreshTextDirs;

PROCEDURE RefreshTextDirBorders;

BEGIN
  FOR i:=0 TO 3 DO
    IF mark(s1.Mark).textdir=i THEN
      it.DrawBorderIn(rast,26+i*52,122,50,40);
    ELSE
      it.DrawBorder(rast,26+i*52,122,50,40);
    END;
  END;
END RefreshTextDirBorders;

PROCEDURE RefreshTextSides;

BEGIN
  g.SetAPen(rast,1);
  FOR i:=0 TO 1 DO
    gt.DrawLine(rast,74+i*106,175,74+i*106,190,1,1,s1.lines[0],pos);
    IF i=0 THEN
      tt.Print(48+i*102,185,s.ADR("x=0"),rast);
    ELSIF i=1 THEN
      tt.Print(80+i*102,185,s.ADR("x=0"),rast);
    END;
  END;
END RefreshTextSides;

PROCEDURE RefreshTextSideBorders;

BEGIN
  FOR i:=0 TO 1 DO
    IF ((i=0) AND (mark(s1.Mark).textside=-1)) OR ((i=1) AND (mark(s1.Mark).textside=1)) THEN
      it.DrawBorderIn(rast,26+i*106,173,104,20);
    ELSE
      it.DrawBorder(rast,26+i*106,173,104,20);
    END;
  END;
END RefreshTextSideBorders;

BEGIN
  ret:=FALSE;
  IF markdesId=-1 THEN
    markdesId:=wm.InitWindow(80,20,262,223,ac.GetString(ac.MarkerDesign),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.mouseMove},s1.screen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,202,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(148,202,100,14,ac.GetString(ac.Cancel));
  gm.EndGadgets;
  wm.SetGadgets(markdesId,ok);
  wm.ChangeScreen(markdesId,s1.screen);
  wind:=wm.OpenWindow(markdesId);
  IF wind#NIL THEN
    WITH mark: s1.Mark DO
      rast:=wind.rPort;

      g.SetAPen(rast,1);
      tt.Print(20,25,ac.GetString(ac.MarkerDesign),rast);
      tt.Print(20,107,ac.GetString(ac.MarkerLegend),rast);
      g.SetAPen(rast,2);
      tt.Print(26,37,ac.GetString(ac.MarkerPattern),rast);
      tt.Print(26,64,ac.GetString(ac.MarkerWidth),rast);
      tt.Print(26,119,ac.GetString(ac.TextOrientation),rast);
      tt.Print(26,170,ac.GetString(ac.TextSide),rast);

      it.DrawBorder(rast,14,16,234,183);
      it.DrawBorder(rast,20,28,222,71);
      it.DrawBorder(rast,20,110,222,86);

      oldline:=mark.line;
      oldwidth:=mark.width;
      oldtextdir:=mark.textdir;
      oldtextside:=mark.textside;

      s7.RefreshLines(rast,26,40);
      s7.RefreshLineBorders(rast,26,40,mark.line);
      s7.RefreshWidthLines(rast,26,67);
      s7.RefreshWidthBorders(rast,26,67,mark.width);
      RefreshTextDirs;
      RefreshTextDirBorders;
      RefreshTextSides;
      RefreshTextSideBorders;

      LOOP
        e.WaitPort(wind.userPort);
        it.GetIMes(wind,class,code,address);
        IF I.gadgetUp IN class THEN
          IF address=ok THEN
            ret:=TRUE;
            EXIT;
          ELSIF address=ca THEN
            mark.line:=oldline;
            mark.width:=oldwidth;
            mark.textdir:=oldtextdir;
            mark.textside:=oldtextside;
            EXIT;
          END;
        ELSIF I.mouseButtons IN class THEN
          bool:=s7.CheckLines(wind,26,40,mark.line);
          bool:=s7.CheckWidths(wind,26,67,mark.width);
          it.GetMousePos(wind,x,y);
          IF (y>=122) AND (y<162) THEN
            DEC(x,26);
            x:=x DIV 52;
            IF (x>=0) AND (x<=3) THEN
              mark.textdir:=x;
              RefreshTextDirBorders;
            END;
          ELSIF (y>=173) AND (y<193) THEN
            DEC(x,26);
            x:=x DIV 106;
            IF (x>=0) AND (x<=1) THEN
              IF x=0 THEN
                mark.textside:=-1;
              ELSIF x=1 THEN
                mark.textside:=1;
              END;
              RefreshTextSideBorders;
            END;
          END;
        END;
        IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"markdesreq",wind);
        END;
      END;

      wm.CloseWindow(markdesId);
    END;
  END;
  wm.FreeGadgets(markdesId);
  RETURN ret;
END ChangeMarkDes;

BEGIN
  IF point IS s1.Point THEN
    COPY(ac.GetString(ac.Point)^,objname);
    COPY(ac.GetString(ac.ChangePoint)^,str);
  ELSIF point IS s1.Mark THEN
    COPY(ac.GetString(ac.Marker)^,objname);
    COPY(ac.GetString(ac.ChangeMarker)^,str);
  END;
(*  COPY(objname,str);*)
(*  st.Append(str," verändern");*)
  ret:=FALSE;
  IF pointId=-1 THEN
    pointId:=wm.InitWindow(80,20,464,232,s.ADR(str),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.mouseMove},s1.screen,FALSE);
  END;
  wm.ChangeTitle(pointId,s.ADR(str));
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,211,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(350,211,100,14,ac.GetString(ac.Cancel));
  help:=gm.SetBooleanGadget(120,211,100,14,ac.GetString(ac.Help));
  add:=gm.SetBooleanGadget(26,126,196,14,ac.GetString(ac.NewPattern));
  del:=gm.SetBooleanGadget(26,141,196,14,ac.GetString(ac.DelPattern));
  trans:=gm.SetCheckBoxGadget(412,92,26,9,point(s1.GraphObject).trans);
(*  COPY(objname,str);
  st.Append(str,"aussehen");*)
  IF point IS s1.Point THEN
    changedes:=gm.SetBooleanGadget(234,107,198,14,ac.GetString(ac.PointDesign));
  ELSIF point IS s1.Mark THEN
    changedes:=gm.SetBooleanGadget(234,107,198,14,ac.GetString(ac.MarkerDesign));
  END;
  font:=gm.SetBooleanGadget(228,126,210,14,ac.GetString(ac.Font));
  format:=gm.SetBooleanGadget(228,141,210,14,ac.GetString(ac.NumberFormat));
  maus:=gm.SetBooleanGadget(26,188,208,14,ac.GetString(ac.Mouse));
  IF p=s1.std.wind THEN
    INCL(maus.flags,I.gadgDisabled);
  END;
  klebe:=gm.SetCheckBoxGadget(412,174,26,9,point(s1.GraphObject).snap);
  name:=gm.SetStringGadget(66,31,144,14,80);
  label:=gm.SetStringGadget(26,110,184,14,80);
  xpos:=gm.SetStringGadget(86,172,40,14,79);
  ypos:=gm.SetStringGadget(206,172,40,14,79);
  COPY(ac.GetString(ac.AxesCoordinates)^,table[0]);
  COPY(ac.GetString(ac.ScreenCoordinates)^,table[1]);
  boundpos:=0;
  bound:=gm.SetCycleGadget(238,188,200,14,table[0]);
  list:=gm.SetListView(26,56,196,54,0,0,PrintLabel);
  palf:=gm.SetPaletteGadget(228,40,200,20,s1.screen.rastPort.bitMap.depth,point(s1.GraphObject).colf);
  palb:=gm.SetPaletteGadget(228,71,200,20,s1.screen.rastPort.bitMap.depth,point(s1.GraphObject).colb);
  gm.EndGadgets;
  wm.SetGadgets(pointId,ok);
  wm.ChangeScreen(pointId,s1.screen);
  wind:=wm.OpenWindow(pointId);
  IF wind#NIL THEN
    node:=p;
    WITH p: s1.Fenster DO
      WITH point: s1.GraphObject DO
        rast:=wind.rPort;

        IF point IS s1.Point THEN
          NEW(savepoint(s1.Point));
        ELSIF point IS s1.Mark THEN
          NEW(savepoint(s1.Mark));
        END;
        s1.InitNode(savepoint);
        s1.CopyNode(point,savepoint);

        g.SetDrMd(rast,g.jam1);
        g.SetAPen(rast,1);
        tt.Print(20,25,s.ADR(objname),rast);
        tt.Print(20,166,ac.GetString(ac.Coordinates),rast);
        g.SetAPen(rast,2);
        tt.Print(26,40,ac.GetString(ac.Name),rast);
        tt.Print(26,53,ac.GetString(ac.Pattern),rast);
        tt.Print(228,37,ac.GetString(ac.ForegroundColor),rast);
        tt.Print(228,68,ac.GetString(ac.BackgroundColor),rast);
        tt.Print(228,100,ac.GetString(ac.TextTransparent),rast);
(*        tt.Print(228,99,"Punktauswahl",rast);*)
        tt.Print(26,181,ac.GetString(ac.XCoord),rast);
        tt.Print(146,181,ac.GetString(ac.YCoord),rast);
        tt.Print(270,181,ac.GetString(ac.SnapToGraph),rast);

        it.DrawBorder(rast,14,16,436,192);
        it.DrawBorder(rast,20,28,424,130);
        it.DrawBorder(rast,20,169,424,36);
        it.DrawBorderIn(rast,228,104,210,20);

        IF NOT(point.welt) THEN
          gm.CyclePressed(bound,wind,table,boundpos);
        END;
(*        RefreshPoints;
        RefreshPointBorders;*)

        gm.PutGadgetText(name,point.string);
        bool:=I.ActivateGadget(name^,wind,NIL);
        IF point.label#NIL THEN
          gm.PutGadgetText(label,point.label(s1.Label).string);
        END;
        gm.PutGadgetText(xpos,point.xkstr);
        gm.PutGadgetText(ypos,point.ykstr);
        IF point.snap THEN
          I.OffGadget(ypos^,wind,NIL);
        END;
        I.RefreshGList(name,wind,NIL,4);
        fontrequest:=NIL;

        gm.SetCorrectWindow(palf,wind);
        gm.RefreshPaletteGadget(palf);
        gm.SetCorrectWindow(palb,wind);
        gm.RefreshPaletteGadget(palb);
        gm.SetCorrectWindow(list,wind);
        gm.SetNoEntryText(list,ac.GetString(ac.None),ac.GetString(ac.PatternsEx));

        NewLabelList;

        LOOP
          e.WaitPort(wind.userPort);
          it.GetIMes(wind,class,code,address);
          bool:=gm.CheckListView(list,class,code,address);
          IF bool THEN
            point.label:=s1.GetNode(s1.labels,gm.ActEl(list));
            RefreshLabel;
          END;
          bool:=gm.CheckPaletteGadget(palf,class,code,address);
          bool:=gm.CheckPaletteGadget(palb,class,code,address);
          point.colf:=gm.ActCol(palf);
          point.colb:=gm.ActCol(palb);
          GetTexts;
          IF I.gadgetUp IN class THEN
            IF address=ok THEN
              GetXCoord;
              GetYCoord;
              ret:=TRUE;
              EXIT;
            ELSIF address=ca THEN
              EXIT;
            ELSIF address=add THEN
              node:=NIL;
              NEW(node(s1.Label));
              node(s1.Label).string:="";
              s1.labels.AddTail(node);
              point.label:=node;
              NewLabelList;
              RefreshLabel;
            ELSIF address=del THEN
              IF point.label#NIL THEN
                node:=NIL;
                node:=point.label.next;
                IF node=NIL THEN
                  node:=point.label.prev;
                END;
                point.label.Remove;
                point.label:=node;
                NewLabelList;
                RefreshLabel;
              END;
            ELSIF address=changedes THEN
              IF point IS s1.Point THEN
                bool:=ChangePointDes(point);
              ELSIF point IS s1.Mark THEN
                bool:=ChangeMarkDes(point);
              END;
            ELSIF address=format THEN
              bool:=s8.NumberFormat(point.nach,point.exp);
            ELSIF address=font THEN
(*              at.SetFontRequestMinMax(1,100);*)
              bool:=at.FontRequest(fontrequest,ac.GetString(ac.SelectFontForPoint),wind,s.ADR(point.attr),at.nocols,at.nocols);
            ELSIF address=trans THEN
              point.trans:=NOT(point.trans);
            ELSIF address=maus THEN
              REPEAT
                it.GetIMes(p.wind,class,code,address);
              UNTIL class=LONGSET{};
              I.WindowToFront(p.wind);
              I.ActivateWindow(p.wind);
              it.GetMousePos(p.wind,x,y);
(*              DEC(x,s1.pointmust[point.point].hotx);
              DEC(y,s1.pointmust[point.point].hoty);*)
              s1.PicToWorld(longx,longy,x,y,p);
              IF point.snap THEN
                s2.SnapToFunktion(p,longx,longy);
                s1.WorldToPic(longx,longy,x,y,p);
              END;
              point.picx:=x;
              point.picy:=y;
              point.weltx:=longx;
              point.welty:=longy;
              g.SetDrMd(p.rast,SHORTSET{g.complement});
              REPEAT
                s4.PlotObject(p,point,FALSE);
                e.WaitPort(p.wind.userPort);
                it.GetIMes(p.wind,class,code,address);
                IF NOT(I.mouseButtons IN class) THEN
                  REPEAT
                    it.GetIMes(p.wind,class,code,address);
                  UNTIL NOT(I.mouseMove IN class);
                END;
                it.GetMousePos(p.wind,x,y);
(*                DEC(x,s1.pointmust[point.point].hotx);
                DEC(y,s1.pointmust[point.point].hoty);*)
                s4.PlotObject(p,point,FALSE);
                s1.PicToWorld(longx,longy,x,y,p);
                IF point.snap THEN
                  s2.SnapToFunktion(p,longx,longy);
                  s1.WorldToPic(longx,longy,x,y,p);
                END;
                point.picx:=x;
                point.picy:=y;
                point.weltx:=longx;
                point.welty:=longy;
              UNTIL (I.mouseButtons IN class) AND (code=I.selectUp);
              IF boundpos=0 THEN
                bool:=lrc.RealToString(point.weltx,point.xkstr,7,7,FALSE);
                bool:=lrc.RealToString(point.welty,point.ykstr,7,7,FALSE);
                tt.Clear(point.xkstr);
                tt.Clear(point.ykstr);
                RefreshCoords;
              ELSE
                bool:=c.IntToString(point.picx,point.xkstr,7);
                bool:=c.IntToString(point.picy,point.ykstr,7);
                tt.Clear(point.xkstr);
                tt.Clear(point.ykstr);
                RefreshCoords;
              END;
              I.WindowToFront(wind);
              I.ActivateWindow(wind);
            ELSIF address=name THEN
              IF point.label#NIL THEN
                bool:=I.ActivateGadget(label^,wind,NIL);
              ELSE
                bool:=I.ActivateGadget(xpos^,wind,NIL);
              END;
            ELSIF address=label THEN
              NewLabelList;
              bool:=I.ActivateGadget(xpos^,wind,NIL);
            ELSIF address=klebe THEN
              point.snap:=NOT(point.snap);
              IF NOT(point.snap) THEN
                I.OnGadget(ypos^,wind,NIL);
              ELSE
                IF boundpos=0 THEN
                  s2.SnapToFunktion(p,point.weltx,point.welty);
                  s1.WorldToPic(point.weltx,point.welty,point.picx,point.picy,p);
                  bool:=lrc.RealToString(point.welty,point.ykstr,7,7,FALSE);
                  tt.Clear(point.ykstr);
                  RefreshCoords;
                ELSIF boundpos=1 THEN
                  s2.SnapToFunktion(p,point.weltx,point.welty);
                  s1.WeltToPic(SHORT(point.weltx),SHORT(point.welty),x,y,p.xmin,p.xmax,p.ymin,p.ymax,p.width,p.height);
                  s1.WorldToPic(point.weltx,point.welty,point.picx,point.picy,p);
                  bool:=c.IntToString(point.picy,point.ykstr,7);
                  tt.Clear(point.ykstr);
                  RefreshCoords;
                END;
                I.OffGadget(ypos^,wind,NIL);
              END;
            ELSIF address=bound THEN
              gm.CyclePressed(bound,wind,table,boundpos);
              point.welt:=NOT(point.welt);
              IF boundpos=0 THEN
                s1.PicToWorld(point.weltx,point.welty,point.picx,point.picy,p);
                bool:=lrc.RealToString(point.weltx,point.xkstr,7,7,FALSE);
                bool:=lrc.RealToString(point.welty,point.ykstr,7,7,FALSE);
                tt.Clear(point.xkstr);
                tt.Clear(point.ykstr);
                RefreshCoords;
              ELSE
                s1.WorldToPic(point.weltx,point.welty,point.picx,point.picy,p);
                bool:=c.IntToString(point.picx,point.xkstr,7);
                bool:=c.IntToString(point.picy,point.ykstr,7);
                tt.Clear(point.xkstr);
                tt.Clear(point.ykstr);
                RefreshCoords;
              END;
            ELSIF address=xpos THEN
              GetXCoord;
              RefreshCoords;
              IF NOT(point.snap) THEN
                bool:=I.ActivateGadget(ypos^,wind,NIL);
              ELSE
                bool:=I.ActivateGadget(name^,wind,NIL);
              END;
            ELSIF address=ypos THEN
              point.welty:=f.ExpressionToReal(point.ykstr);
              s1.WorldToPic(point.weltx,point.welty,point.picx,point.picy,p);
              GetYCoord;
              bool:=I.ActivateGadget(name^,wind,NIL);
            END;
(*          ELSIF (I.mouseButtons IN class) AND (code=I.selectDown) THEN
            it.GetMousePos(wind,x,y);
            IF (x>228) AND (x<438) AND (y>101) AND (y<122) THEN
              x:=x-228;
              x:=x DIV 21;
              point.point:=x;
              RefreshPointBorders;
            END;*)
          END;
          IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
            ag.ShowFile(s1.analaydoc,"points",wind);
          END;
        END;

        IF fontrequest#NIL THEN
          as.FreeAslRequest(fontrequest);
        END;
(*        ig.FreePlastPropGadget(scroll,wind);
        ig.FreePlastArrowGadget(down,wind);
        ig.FreePlastArrowGadget(up,wind);
        ig.FreePlastStringGadget(ypos,wind);
        ig.FreePlastStringGadget(xpos,wind);
        ig.FreePlastCheckBoxGadget(klebe,wind);
        ig.FreePlastHighBooleanGadget(maus,wind);
        ig.FreePlastStringGadget(label,wind);
        ig.FreePlastStringGadget(name,wind);
        ig.FreePlastHighBooleanGadget(format,wind);
        ig.FreePlastHighBooleanGadget(font,wind);
        ig.FreePlastHighBooleanGadget(del,wind);
        ig.FreePlastHighBooleanGadget(add,wind);
        ig.FreePlastHighBooleanGadget(ca,wind);
        ig.FreePlastHighBooleanGadget(ok,wind);
        ig.FreePlastBorder(bord1);
        ig.FreePlastBorder(bord2);
        ig.FreePlastBorder(bord3);
        ig.FreePlastBorder(bord4);
        ig.FreePlastBorder(bordpoint);
        ig.FreePlastBorder(bordpointin);*)
        wm.CloseWindow(pointId);
        s1.FreeNode(savepoint);
      END;
    END;
  END;
  wm.FreeGadgets(pointId);
  IF NOT(ret) THEN
    s1.CopyNode(savepoint,point);
  END;
  RETURN ret;
END ChangePoint;

PROCEDURE ChangeMark*(p,point:l.Node):BOOLEAN;
(*
VAR wind : I.WindowPtr;
    rast : g.RastPortPtr;
    ok,ca,
    name,add,
    del,font,
    format,
    string,
    label,maus,
    klebe,xpos,
    ypos,bound,
    changedes : I.GadgetPtr;
    list,
    palf,palb : l.Node;
    ret       : BOOLEAN;
    node,
    savemark  : l.Node;
    cols      : INTEGER;
    boundpos  : INTEGER;
    table     : ARRAY 2 OF ARRAY 28 OF CHAR;
    x,y       : INTEGER;
    longx,
    longy     : LONGREAL;


PROCEDURE NewLabelList;

BEGIN
  gm.SetListViewParams(list,26,56,196,54,SHORT(s1.labels.nbElements()),s1.GetNodeNumber(s1.labels,point(s1.Mark).label),PrintLabel);
  gm.SetCorrectPosition(list);
  gm.RefreshListView(list);
END NewLabelList;

PROCEDURE RefreshLabel;

BEGIN
  IF point(s1.Mark).label#NIL THEN
    gm.PutGadgetText(label,point(s1.Mark).label(s1.Label).string);
    I.RefreshGList(label,wind,NIL,1);
    bool:=I.ActivateGadget(label^,wind,NIL);
  END;
END RefreshLabel;

PROCEDURE RefreshCoords;

BEGIN
  WITH point: s1.Mark DO
    gm.PutGadgetText(xpos,point.xkstr);
    IF NOT(point.snap) THEN
      gm.PutGadgetText(ypos,point.ykstr);
    ELSE
      gm.PutGadgetText(ypos,point.ykstr);
      I.OffGadget(ypos^,wind,NIL);
    END;
    I.RefreshGList(xpos,wind,NIL,2);
  END;
END RefreshCoords;

PROCEDURE GetXCoord;

BEGIN
  WITH point: s1.Mark DO
    gm.GetGadgetText(xpos,point.xkstr);
    longx:=f.ExpressionToReal(point.xkstr);
    IF boundpos=0 THEN
      point.weltx:=longx;
      IF point.snap THEN
        s2.SnapToFunktion(node,point.weltx,point.welty);
        s1.WorldToPic(point.weltx,point.welty,point.picx,point.picy,p);
        bool:=lrc.RealToString(point.welty,point.ykstr,7,7,FALSE);
        tt.Clear(point.ykstr);
      ELSE
        s1.WorldToPic(point.weltx,point.welty,point.picx,point.picy,p);
      END;
    ELSIF boundpos=1 THEN
      point.picx:=SHORT(SHORT(SHORT(longx)));
      s1.PicToWorld(point.weltx,point.welty,point.picx,point.picy,p);
      IF point.snap THEN
        s2.SnapToFunktion(node,point.weltx,point.welty);
        s1.WorldToPic(point.weltx,point.welty,point.picx,point.picy,p);
        bool:=c.IntToString(point.picy,point.ykstr,7);
        tt.Clear(point.ykstr);
      END;
    END;
  END;
END GetXCoord;

PROCEDURE GetYCoord;

BEGIN
  WITH point: s1.Mark DO
    gm.GetGadgetText(ypos,point.ykstr);
    longy:=f.ExpressionToReal(point.ykstr);
    IF boundpos=0 THEN
      point.welty:=longy;
    ELSE
      point.picy:=SHORT(SHORT(SHORT(longy)));
    END;
    s1.RefreshOtherCoord(p,point);
  END;
END GetYCoord;

PROCEDURE GetTexts;

BEGIN
  WITH point: s1.Mark DO
    gm.GetGadgetText(name,point.string);
    IF point.label#NIL THEN
      gm.GetGadgetText(label,point.label(s1.Label).string);
    END;
  END;
END GetTexts;

BEGIN
  ret:=FALSE;
  IF pointId=-1 THEN
    pointId:=wm.InitWindow(80,20,464,232,"Markierung verändern",LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.mouseMove},s1.screen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,211,100,14,s.ADR("OK"));
  ca:=gm.SetBooleanGadget(350,211,100,14,s.ADR("Abbrechen"));
  add:=gm.SetBooleanGadget(26,126,196,14,s.ADR("Neuer Eintrag"));
  del:=gm.SetBooleanGadget(26,141,196,14,s.ADR("Eintrag löschen"));
  changedes:=gm.SetBooleanGadget(234,101,199,14,s.ADR("Markierungsaussehen"));
  font:=gm.SetBooleanGadget(228,126,210,14,s.ADR("Schriftart"));
  format:=gm.SetBooleanGadget(228,141,210,14,s.ADR("Zahlenformat"));
  maus:=gm.SetBooleanGadget(26,188,208,14,s.ADR("Maus"));
  IF p=s1.std.wind THEN
    INCL(maus.flags,I.gadgDisabled);
  END;
  klebe:=gm.SetCheckBoxGadget(412,174,26,9,point(s1.Mark).snap);
  name:=gm.SetStringGadget(66,31,144,14,80);
  label:=gm.SetStringGadget(26,110,184,14,80);
  xpos:=gm.SetStringGadget(86,172,40,14,79);
  ypos:=gm.SetStringGadget(206,172,40,14,79);
  table[0]:="Achsenkoordinaten";
  table[1]:="Bildschirmkoordinaten";
  boundpos:=0;
  bound:=gm.SetCycleGadget(238,188,200,14,s.ADR(table[0]));
  list:=gm.SetListView(26,56,196,54,0,0,PrintLabel);
  palf:=gm.SetPaletteGadget(228,40,200,20,s1.screen.bitMap.depth,point(s1.Mark).colf);
  palb:=gm.SetPaletteGadget(228,71,200,20,s1.screen.bitMap.depth,point(s1.Mark).colb);
  gm.EndGadgets;
  wm.SetGadgets(pointId,ok);
  wm.ChangeScreen(pointId,s1.screen);
  wind:=wm.OpenWindow(pointId);
  IF wind#NIL THEN
    node:=p;
    WITH p: s1.Fenster DO
      WITH point: s1.Mark DO
        rast:=wind.rPort;

        NEW(savemark);
        s1.InitNode(savemark);
        s1.CopyNode(point,savemark);

        g.SetDrMd(rast,g.jam1);
        g.SetAPen(rast,1);
        tt.Print(20,25,"Markierung",rast);
        tt.Print(20,166,"Koordinaten",rast);
        g.SetAPen(rast,2);
        tt.Print(26,40,"Name",rast);
        tt.Print(26,53,"Bezeichnung",rast);
        tt.Print(228,37,"Vordergrundfarbe",rast);
        tt.Print(228,68,"Hintergrundfarbe",rast);
        tt.Print(26,181,"x-Koord",rast);
        tt.Print(146,181,"y-Koord",rast);
        tt.Print(270,181,"Klebe an Funktion",rast);

        it.DrawBorder(rast,14,16,436,192);
        it.DrawBorder(rast,20,28,424,130);
        it.DrawBorder(rast,20,169,424,36);
        it.DrawBorderIn(rast,228,98,210,20);

        IF NOT(point.welt) THEN
          gm.CyclePressed(bound,wind,table,boundpos);
        END;

        gm.PutGadgetText(name,point.string);
        bool:=I.ActivateGadget(name^,wind,NIL);
        IF point.label#NIL THEN
          gm.PutGadgetText(label,point.label(s1.Label).string);
        END;
        gm.PutGadgetText(xpos,point.xkstr);
        gm.PutGadgetText(ypos,point.ykstr);
        I.RefreshGList(name,wind,NIL,4);

        gm.SetCorrectWindow(palf,wind);
        gm.RefreshPaletteGadget(palf);
        gm.SetCorrectWindow(palb,wind);
        gm.RefreshPaletteGadget(palb);
        gm.SetCorrectWindow(list,wind);
        gm.SetNoEntryText(list,"Keine","Masken!");

        NewLabelList;

        LOOP
          e.WaitPort(wind.userPort);
          it.GetIMes(wind,class,code,address);
          bool:=gm.CheckListView(list,class,code,address);
          IF bool THEN
            point.label:=s1.GetNode(s1.labels,gm.ActEl(list));
            RefreshLabel;
          END;
          bool:=gm.CheckPaletteGadget(palf,class,code,address);
          bool:=gm.CheckPaletteGadget(palb,class,code,address);
          point.colf:=gm.ActCol(palf);
          point.colb:=gm.ActCol(palb);
          GetTexts;
          IF I.gadgetUp IN class THEN
            IF address=ok THEN
              GetXCoord;
              GetYCoord;
              ret:=TRUE;
              EXIT;
            ELSIF address=ca THEN
              EXIT;
            ELSIF address=add THEN
              node:=NIL;
              NEW(node(s1.Label));
              node(s1.Label).string:="";
              s1.labels.AddTail(node);
              point.label:=node;
              NewLabelList;
              RefreshLabel;
            ELSIF address=del THEN
              IF point.label#NIL THEN
                node:=NIL;
                node:=point.label.next;
                IF node=NIL THEN
                  node:=point.label.prev;
                END;
                point.label.Remove;
                point.label:=node;
                NewLabelList;
                RefreshLabel;
              END;
            ELSIF address=format THEN
              bool:=s8.NumberFormat(point.nach,point.exp);
            ELSIF address=maus THEN
              REPEAT
                it.GetIMes(p.wind,class,code,address);
              UNTIL class=LONGSET{};
              I.WindowToFront(p.wind);
              I.ActivateWindow(p.wind);
              it.GetMousePos(p.wind,x,y);
(*              DEC(x,s1.pointmust[point.point].hotx);
              DEC(y,s1.pointmust[point.point].hoty);*)
              s1.PicToWorld(longx,longy,x,y,p);
              IF point.snap THEN
                s2.SnapToFunktion(p,longx,longy);
                s1.WorldToPic(longx,longy,x,y,p);
              END;
              point.picx:=x;
              point.picy:=y;
              point.weltx:=longx;
              point.welty:=longy;
              g.SetDrMd(p.rast,SHORTSET{g.complement});
              REPEAT
                s3.PlotObject(p,point,FALSE);
                e.WaitPort(p.wind.userPort);
                it.GetMousePos(p.wind,x,y);
(*                DEC(x,s1.pointmust[point.point].hotx);
                DEC(y,s1.pointmust[point.point].hoty);*)
                s3.PlotObject(p,point,FALSE);
                s1.PicToWorld(longx,longy,x,y,p);
                IF point.snap THEN
                  s2.SnapToFunktion(p,longx,longy);
                  s1.WorldToPic(longx,longy,x,y,p);
                END;
                point.picx:=x;
                point.picy:=y;
                point.weltx:=longx;
                point.welty:=longy;
                it.GetIMes(p.wind,class,code,address);
                IF NOT(I.mouseButtons IN class) THEN
                  REPEAT
                    it.GetIMes(p.wind,class,code,address);
                  UNTIL NOT(I.mouseMove IN class);
                END;
              UNTIL (I.mouseButtons IN class) AND (code=I.selectUp);
              IF boundpos=0 THEN
                bool:=lrc.RealToString(point.weltx,point.xkstr,7,7,FALSE);
                bool:=lrc.RealToString(point.welty,point.ykstr,7,7,FALSE);
                tt.Clear(point.xkstr);
                tt.Clear(point.ykstr);
                RefreshCoords;
              ELSE
                bool:=c.IntToString(point.picx,point.xkstr,7);
                bool:=c.IntToString(point.picy,point.ykstr,7);
                tt.Clear(point.xkstr);
                tt.Clear(point.ykstr);
                RefreshCoords;
              END;
              I.WindowToFront(wind);
              I.ActivateWindow(wind);
            ELSIF address=name THEN
              IF point.label#NIL THEN
                bool:=I.ActivateGadget(label^,wind,NIL);
              ELSE
                bool:=I.ActivateGadget(xpos^,wind,NIL);
              END;
            ELSIF address=label THEN
              NewLabelList;
              bool:=I.ActivateGadget(xpos^,wind,NIL);
            ELSIF address=klebe THEN
              point.snap:=NOT(point.snap);
              IF NOT(point.snap) THEN
                I.OnGadget(ypos^,wind,NIL);
              ELSE
                IF boundpos=0 THEN
                  s2.SnapToFunktion(p,point.weltx,point.welty);
                  s1.WorldToPic(point.weltx,point.welty,point.picx,point.picy,p);
                  bool:=lrc.RealToString(point.welty,point.ykstr,7,7,FALSE);
                  tt.Clear(point.ykstr);
                  RefreshCoords;
                ELSIF boundpos=1 THEN
                  s2.SnapToFunktion(p,point.weltx,point.welty);
                  s1.WeltToPic(SHORT(point.weltx),SHORT(point.welty),x,y,p.xmin,p.xmax,p.ymin,p.ymax,p.width,p.height);
                  s1.WorldToPic(point.weltx,point.welty,point.picx,point.picy,p);
                  bool:=c.IntToString(point.picy,point.ykstr,7);
                  tt.Clear(point.ykstr);
                  RefreshCoords;
                END;
                I.OffGadget(ypos^,wind,NIL);
              END;
            ELSIF address=bound THEN
              gm.CyclePressed(bound,wind,table,boundpos);
              point.welt:=NOT(point.welt);
              IF boundpos=0 THEN
                s1.PicToWorld(point.weltx,point.welty,point.picx,point.picy,p);
                bool:=lrc.RealToString(point.weltx,point.xkstr,7,7,FALSE);
                bool:=lrc.RealToString(point.welty,point.ykstr,7,7,FALSE);
                tt.Clear(point.xkstr);
                tt.Clear(point.ykstr);
                RefreshCoords;
              ELSE
                s1.WorldToPic(point.weltx,point.welty,point.picx,point.picy,p);
                bool:=c.IntToString(point.picx,point.xkstr,7);
                bool:=c.IntToString(point.picy,point.ykstr,7);
                tt.Clear(point.xkstr);
                tt.Clear(point.ykstr);
                RefreshCoords;
              END;
            ELSIF address=xpos THEN
              GetXCoord;
              RefreshCoords;
              IF NOT(point.snap) THEN
                bool:=I.ActivateGadget(ypos^,wind,NIL);
              ELSE
                bool:=I.ActivateGadget(name^,wind,NIL);
              END;
            ELSIF address=ypos THEN
              point.welty:=f.ExpressionToReal(point.ykstr);
              s1.WorldToPic(point.weltx,point.welty,point.picx,point.picy,p);
              GetYCoord;
              bool:=I.ActivateGadget(name^,wind,NIL);
            ELSIF address=font THEN
(*              at.SetFontRequestMinMax(1,100);*)
              bool:=at.FontRequest(s.ADR("Zeichensatz für Punkt auswählen"),wind,s.ADR(point.attr),at.nocols,at.nocols);
            END;
          END;
        END;

(*        ig.FreePlastPropGadget(scroll,wind);
        ig.FreePlastArrowGadget(down,wind);
        ig.FreePlastArrowGadget(up,wind);
        ig.FreePlastStringGadget(ypos,wind);
        ig.FreePlastStringGadget(xpos,wind);
        ig.FreePlastCheckBoxGadget(klebe,wind);
        ig.FreePlastHighBooleanGadget(maus,wind);
        ig.FreePlastStringGadget(label,wind);
        ig.FreePlastStringGadget(name,wind);
        ig.FreePlastHighBooleanGadget(format,wind);
        ig.FreePlastHighBooleanGadget(font,wind);
        ig.FreePlastHighBooleanGadget(del,wind);
        ig.FreePlastHighBooleanGadget(add,wind);
        ig.FreePlastHighBooleanGadget(ca,wind);
        ig.FreePlastHighBooleanGadget(ok,wind);
        ig.FreePlastBorder(bord1);
        ig.FreePlastBorder(bord2);
        ig.FreePlastBorder(bord3);
        ig.FreePlastBorder(bord4);
        ig.FreePlastBorder(bordpoint);
        ig.FreePlastBorder(bordpointin);*)
        wm.CloseWindow(pointId);
        s1.FreeNode(savemark);
      END;
    END;
  END;
  wm.FreeGadgets(pointId);
  IF NOT(ret) THEN
    s1.CopyNode(savemark,point);
  END;
  RETURN ret;*)
END ChangeMark;

BEGIN
  textId:=-1;
  pointId:=-1;
  markId:=-1;
  pointdesId:=-1;
  markdesId:=-1;
END SuperCalcTools12.

















































