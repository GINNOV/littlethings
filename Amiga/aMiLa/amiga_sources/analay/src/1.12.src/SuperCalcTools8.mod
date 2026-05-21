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


MODULE SuperCalcTools8;

IMPORT I  : Intuition,
       g  : Graphics,
       d  : Dos,
       e  : Exec,
       s  : SYSTEM,
       f  : Function,
       f1 : Function1,
       c  : Conversions,
       l  : LinkedLists,
       it : IntuitionTools,
       tt : TextTools,
       ag : AmigaGuideTools,
       rt : RequesterTools,
       gm : GadgetManager,
       wm : WindowManager,
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
       NoGuruRq;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- *)

VAR ok,bool     : BOOLEAN;
    code        : INTEGER;
    class       : LONGSET;
    address     : s.ADDRESS;
    a,j,i       : INTEGER;
    aussehenId* ,
    formatId  * ,
    einstellungenId*,
    rangeId   * ,
    priorId   * : INTEGER;
    nach      * : INTEGER;
    exp       * : BOOLEAN;
    start*,enu* ,
    step      * : LONGREAL;
    names2      : POINTER TO ARRAY OF ARRAY OF CHAR;

PROCEDUREP* PrintSub(rast<g.RastPortPtr;x,y,wiutq,num:IJPEØ‘)ïsïQÓW3‘Q‚•ÓW3Rp`àÞŸfÒÓ)íÑ‚šÃ)í`×3Öí‚Ù7ØßßØ`à˜Ÿ#bà‹›~ÒïTíÕV‰"›aÙ›šà›~ÒóT‘•šƒÒïTíÕVÛoÙ›šàšÝS×3Ö‚p`™#'ÚSÒïTíÕVÕóTÜ×3ÖÚ‚p`óó‚™3sÝsÖÓRï7Ó!íÒï3ÓƒÖïW3×3ÖÚóióÓ‚p`Žóó‚ßÖÓRóƒëêQ×3ÖÖïW3‚P`™›g'›'=ƒ×3×`š™xš™`š™ßÖÕRóÙ3h`àßØ›9=™ÝØŸsW-ÓíÒ€ƒ×Ñ‚šÓ)í‚p˜›#!Ÿb`àwind)|
      3 : gm.ActivateBool(s.ADR(c8),wind)|
      4 : gm.ActivateBool(s.ADR(c16),wind)|
    ELSE
      gm.ActivateBool(s.ADR(c4),wind);
    END;
    IF over THEN
      gm.ActivateBool(s.ADR(overscan),wind);
    END;
    IF ntsc THEN
      gm.ActivateBool(s.ADR(ntscscreen),wind);
    END;
    IF a4 THEN
      gm.ActivateBool(s.ADR(dina4),wind);
    END;

    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      IF I.gadgetUp IN class THEN
        IF address=s.ADR(ok) THEN
          EXIT;
        ELSIF address=s.ADR(c2) THEN
          DeActivateColor;
          gm.ActivateBool(s.ADR(c2),wind);
          de:=1;
        ELSIF address=s.ADR(c4) THEN
          DeActivateColor;
          gm.ActivateBool(s.ADR(c4),wind);
          de:=2;
        ELSIF address=s.ADR(c8) THEN
          DeActivateColor;
          gm.ActivateBool(s.ADR(c8),wind);
          de:=3;
        ELSIF address=s.ADR(c16) THEN
          DeActivateColor;
          gm.ActivateBool(s.ADR(c16),wind);
          de:=4;
        ELSIF address=s.ADR(low) THEN
          DeActivateMode;
          gm.ActivateBool(s.ADR(low),wind);
          IF ntsc THEN
            he:=200;
          ELSE
            he:=256;
          END;
        ELSIF address=s.ADR(high) THEN
          DeActivateMode;
          gm.ActivateBool(s.ADR(high),wind);
          IF ntsc THEN
            he:=400;
          ELSE
            he:=512;
          END;
        ELSIF address=s.ADR(overscan) THEN
          over:=NOT(over);
        ELSIF address=s.ADR(ntscscreen) THEN
          ntsc:=NOT(ntsc);
          IF he>350 THEN
            IF ntsc THEN
              he:=400;
            ELSE
              he:=512;
            END;
          ELSE
            IF ntsc THEN
              he:=200;
            ELSE
              he:=256;
            END;
          END;
        ELSIF address=s.ADR(dina4) THEN
          a4:=NOT(a4);
        END;
      END;
    END;

    ig.FreePlastBooleanGadget(c16,wind);
    ig.FreePlastBooleanGadget(c8,wind);
    ig.FreePlastBooleanGadget(c4,wind);
    ig.FreePlastBooleanGadget(c2,wind);
    ig.FreePlastCheckBoxGadget(dina4,wind);
    ig.FreePlastCheckBoxGadget(ntscscreen,wind);
    ig.FreePlastCheckBoxGadget(overscan,wind);
    ig.FreePlastBooleanGadget(high,wind);
    ig.FreePlastBooleanGadget(low,wind);
    ig.FreePlastBooleanGadget(ca,wind);
    ig.FreePlastBooleanGadget(ok,wind);
    ig.FreePlastBorder(bord1);
    ig.FreePlastBorder(bord2);
    I.CloseWindow(wind);
  END;*)
END Auflosung;*)

BEGIN
  skalaId:=-1;
  gitterId:=-1;
  bereichId:=-1;
  resId:=-1;
  res2Id:=-1;
END SuperCalcTools7.
#act THEN
      RefreshWidthBorders(wind.rPort,x,y,act);
      ret:=TRUE;
    END;
  END;
  RETURN ret;
END CheckWidths;

PROCEDURE ChangeGitter*(p:l.Node):BOOLEAN;

VAR wind : I.WindowPtr;
    rast : g.RastPortPtr;
    ok,ca,
    help,
    on1g,
    on2g,
    stepx1,
    stepy1,
    startx1,
    starty1,
    stepx2,
    stepy2,
    startx2,
    starty2: I.GadgetPtr;
    pal1,pal2 : l.Node;
    col1g,
    col2g   : ARRAY 16 OF I.Gadget;
    bord1,
    bord2,
    bord3,
    bordcol,
    widthbord,
    widthbordsel : I.BorderPtr;
    cols : INTEGER;
    ret  : BOOLEAN;
    linebord,
    linebordsel : ARRAY 20 OF I.BorderPtr;
    act1,
    act2 : INTEGER;
    xspace1,
    yspace1,
    xstart1,
    ystart1 : LONGREAL;
    col1,
    muster1,
    actwi1,
    actwi2  : INTEGER;
    xspace2,
    yspace2,
    xstart2,
    ystart2 : LONGREAL;
    col2,
    muster2 : INTEGER;
    on1,
    on2 : BOOLEAN;
(*    ub1,
    ub2,
    ub3,
    ub4,
    ub5,
    ub6,
    ub7,
    ub8  : ARRAY 80 OF CHAR;
    p1,
    p2,
    p3,
    p4,
    p5,
    p6,
    p7,
    p8   : e.STRPTR(*POINTER TO ARRAY 17 OF CHAR*);*)
    x,y  : INTEGER;
    root : f1.NodePtr;

BEGIN
  ret:=FALSE;
  IF gitterId=-1 THEN
    gitterId:=wm.InitWindow(80,20,490,233,ac.GetString(ac.Grid),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.mouseMove},s1.screen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,212,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(376,212,100,14,ac.GetString(ac.Cancel));
  help:=gm.SetBooleanGadget(120,212,100,14,ac.GetString(ac.Help));
  on1g:=gm.SetCheckBoxGadget(132,18,26,9,p(s1.Fenster).grid1.on);
  on2g:=gm.SetCheckBoxGadget(362,18,26,9,p(s1.Fenster).grid2.on);
  stepx1:=gm.SetStringGadget(40,51,32,14,79);
  stepy1:=gm.SetStringGadget(102,51,32,14,79);
  startx1:=gm.SetStringGadget(40,76,32,14,79);
  starty1:=gm.SetStringGadget(102,76,32,14,79);
  stepx2:=gm.SetStringGadget(268,51,32,14,79);
  stepy2:=gm.SetStringGadget(330,51,32,14,79);
  startx2:=gm.SetStringGadget(268,76,32,14,79);
  starty2:=gm.SetStringGadget(330,76,32,14,79);
  pal1:=gm.SetPaletteGadget(26,116,200,20,s1.screen.rastPort.bitMap.depth,p(s1.Fenster).grid1.col);
  pal2:=gm.SetPaletteGadget(254,116,200,20,s1.screen.rastPort.bitMap.depth,p(s1.Fenster).grid2.col);
  gm.EndGadgets;
  wm.SetGadgets(gitterId,ok);
  wm.ChangeScreen(gitterId,s1.screen);
  wind:=wm.OpenWindow(gitterId);
  IF wind#NIL THEN
    WITH p: s1.Fenster DO
      rast:=wind.rPort;
(*      ig.SetPlastHighGadget(ok,wind,s.ADR("OK"),12,212,100,
                        SET{I.gadgImmediate,I.relVerify});
      ig.SetPlastHighGadget(ca,wind,s.ADR("Abbrechen"),374,212,100,
                        SET{I.gadgImmediate,I.relVerify});

      ig.SetCheckBoxGadget(on1g,wind,130,18,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
      ig.SetCheckBoxGadget(on2g,wind,360,18,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
      ig.SetPlastStringGadget(stepx1,wind,32,79,38,51,FALSE);
      ig.SetPlastStringGadget(stepy1,wind,32,79,100,51,FALSE);
      ig.SetPlastStringGadget(startx1,wind,32,79,38,76,FALSE);
      ig.SetPlastStringGadget(starty1,wind,32,79,100,76,FALSE);
  
      ig.SetPlastStringGadget(stepx2,wind,32,79,266,51,FALSE);
      ig.SetPlastStringGadget(stepy2,wind,32,79,328,51,FALSE);
      ig.SetPlastStringGadget(startx2,wind,32,79,266,76,FALSE);
      ig.SetPlastStringGadget(starty2,wind,32,79,328,76,FALSE);*)
  
      g.SetAPen(rast,1);
      tt.Print(20,25,ac.GetString(ac.Grid1On),rast);
      tt.Print(248,25,ac.GetString(ac.Grid2On),rast);
      tt.Print(20,36,ac.GetString(ac.Settings),rast);
      tt.Print(248,36,ac.GetString(ac.Settings),rast);
      tt.Print(20,101,ac.GetString(ac.GridDesign),rast);
      tt.Print(248,101,ac.GetString(ac.GridDesign),rast);
      g.SetAPen(rast,2);
      tt.Print(26,48,ac.GetString(ac.GridSize),rast);
      tt.Print(26,73,ac.GetString(ac.StartCoordinates),rast);
      tt.Print(26,60,s.ADR("x"),rast);
      tt.Print(88,60,s.ADR("y"),rast);
      tt.Print(26,85,s.ADR("x"),rast);
      tt.Print(88,85,s.ADR("y"),rast);
      tt.Print(26,113,ac.GetString(ac.Color),rast);
      tt.Print(26,144,ac.GetString(ac.LinePattern),rast);
      tt.Print(26,171,ac.GetString(ac.LineThickness),rast);
      tt.Print(254,48,ac.GetString(ac.GridSize),rast);
      tt.Print(254,73,ac.GetString(ac.StartCoordinates),rast);
      tt.Print(254,60,s.ADR("x"),rast);
      tt.Print(316,60,s.ADR("y"),rast);
      tt.Print(254,85,s.ADR("x"),rast);
      tt.Print(316,85,s.ADR("y"),rast);
      tt.Print(254,113,ac.GetString(ac.Color),rast);
      tt.Print(254,144,ac.GetString(ac.LinePattern),rast);
      tt.Print(254,171,ac.GetString(ac.LineThickness),rast);
  
      it.DrawBorder(rast,14,16,462,193);
      it.DrawBorder(rast,20,39,222,54);
      it.DrawBorder(rast,248,39,222,54);
      it.DrawBorder(rast,20,104,222,102);
      it.DrawBorder(rast,248,104,222,102);
  
(*      cols:=SHORT(ig.Hoch(2,s1.screen.bitMap.depth));
      s1.SetPalette(col1g,cols,wind,78,117);
      bordcol:=ig.SetPlastInBorder(16,38);
      I.DrawBorder(rast,bordcol,28,117);
  
      s1.SetPalette(col2g,cols,wind,306,117);
      I.DrawBorder(rast,bordcol,256,117);

      bord1:=ig.SetPlastBorder(190,458);
      I.DrawBorder(rast,bord1,16,17);

      bord2:=ig.SetPlastBorder(50,218);
      I.DrawBorder(rast,bord2,22,40);
      I.DrawBorder(rast,bord2,250,40);
  
      bord3:=ig.SetPlastBorder(99,218);
      I.DrawBorder(rast,bord3,22,105);
      I.DrawBorder(rast,bord3,250,105);*)
  
(*      i:=-1;
      WHILE i<4 DO
        INC(i);
        linebord[i]:=ig.SetPlastBorder(3,24);
        linebordsel[i]:=ig.SetPlastInBorder(3,24);
        I.DrawBorder(rast,linebord[i],28+i*30,148);
      END;
      i:=4;
      WHILE i<9 DO
        INC(i);
        linebord[i]:=ig.SetPlastBorder(3,24);
        linebordsel[i]:=ig.SetPlastInBorder(3,24);
        I.DrawBorder(rast,linebord[i],28+(i-5)*30,158);
      END;
      act1:=-1;
      WHILE act1<9 DO
        INC(act1);
        RefreshLine1;
      END;*)

(*      i:=-1;
      WHILE i<4 DO
        INC(i);
        I.DrawBorder(rast,linebord[i],256+i*30,148);
      END;
      i:=4;
      WHILE i<9 DO
        INC(i);
        I.DrawBorder(rast,linebord[i],256+(i-5)*30,158);
      END;
      act2:=-1;
      WHILE act2<9 DO
        INC(act2);
        RefreshLine2;
      END;*)
      act1:=p.grid1.muster;
      act2:=p.grid2.muster;
(*      RefreshBorders1;
      RefreshBorders2;*)
      actwi1:=p.grid1.width;
      actwi2:=p.grid2.width;
(*      widthbord:=ig.SetPlastBorder(5,98);
      widthbordsel:=ig.SetPlastInBorder(5,98);
      RefreshWidthLines1;
      RefreshWidthBorders1;
      RefreshWidthLines2;
      RefreshWidthBorders2;*)
  
      xspace1:=p.grid1.xspace;
      yspace1:=p.grid1.yspace;
      xstart1:=p.grid1.xstart;
      ystart1:=p.grid1.ystart;
      col1:=p.grid1.col;
      muster1:=p.grid1.muster;
      on1:=p.grid1.on;
  
      xspace2:=p.grid2.xspace;
      yspace2:=p.grid2.yspace;
      xstart2:=p.grid2.xstart;
      ystart2:=p.grid2.ystart;
      col2:=p.grid2.col;
      muster2:=p.grid2.muster;
      on2:=p.grid2.on;
  
(*      IF on1 THEN
        gm.ActivateBool(on1g,wind);
      END;
      IF on2 THEN
        gm.ActivateBool(on2g,wind);
      END;*)
  
(*      g.SetAPen(rast,col1);
      g.RectFill(rast,30,118,63,133);
      g.SetAPen(rast,col2);
      g.RectFill(rast,258,118,291,133);*)

(*      RefreshBorders1;
      RefreshLines1;
      RefreshBorders2;
      RefreshLines2;
      RefreshWidthBorders1;
      RefreshWidthLines1;
      RefreshWidthBorders2;
      RefreshWidthLines2;*)

      RefreshLines(rast,26,147);
      RefreshLineBorders(rast,26,147,muster1);
      RefreshLines(rast,254,147);
      RefreshLineBorders(rast,254,147,muster2);
      RefreshWidthLines(rast,26,174);
      RefreshWidthBorders(rast,26,174,actwi1);
      RefreshWidthLines(rast,254,174);
      RefreshWidthBorders(rast,254,174,actwi2);

      gm.PutGadgetText(startx1,p.grid1.xstarts);
      gm.PutGadgetText(starty1,p.grid1.ystarts);
      gm.PutGadgetText(stepx1,p.grid1.xspaces);
      gm.PutGadgetText(stepy1,p.grid1.yspaces);
      gm.PutGadgetText(startx2,p.grid2.xstarts);
      gm.PutGadgetText(starty2,p.grid2.ystarts);
      gm.PutGadgetText(stepx2,p.grid2.xspaces);
      gm.PutGadgetText(stepy2,p.grid2.yspaces);
  
(*      bool:=nrc.RealToString(xstart1,ub1,7,6,FALSE);
      bool:=nrc.RealToString(ystart1,ub2,7,6,FALSE);
      bool:=nrc.RealToString(xspace1,ub3,7,6,FALSE);
      bool:=nrc.RealToString(yspace1,ub4,7,6,FALSE);*)

(*      COPY(p.grid1.xstarts,ub1);
      COPY(p.grid1.ystarts,ub2);
      COPY(p.grid1.xspaces,ub3);
      COPY(p.grid1.yspaces,ub4);*)
(*      s1.Clear(ub1);
      s1.Clear(ub2);
      s1.Clear(ub3);
      s1.Clear(ub4);*)
(*      ig.PutGadgetText(s.ADR(startx1),s.ADR(ub1));
      ig.PutGadgetText(s.ADR(starty1),s.ADR(ub2));
      ig.PutGadgetText(s.ADR(stepx1),s.ADR(ub3));
      ig.PutGadgetText(s.ADR(stepy1),s.ADR(ub4));*)
  
(*      bool:=nrc.RealToString(xstart2,ub5,7,6,FALSE);
      bool:=nrc.RealToString(ystart2,ub6,7,6,FALSE);
      bool:=nrc.RealToString(xspace2,ub7,7,6,FALSE);
      bool:=nrc.RealToString(yspace2,ub8,7,6,FALSE);*)
(*      COPY(p.grid2.xstarts,ub5);
      COPY(p.grid2.ystarts,ub6);
      COPY(p.grid2.xspaces,ub7);
      COPY(p.grid2.yspaces,ub8);*)
(*      s1.Clear(ub5);
      s1.Clear(ub6);
      s1.Clear(ub7);
      s1.Clear(ub8);*)
(*      ig.PutGadgetText(s.ADR(startx2),s.ADR(ub5));
      ig.PutGadgetText(s.ADR(starty2),s.ADR(ub6));
      ig.PutGadgetText(s.ADR(stepx2),s.ADR(ub7));
      ig.PutGadgetText(s.ADR(stepy2),s.ADR(ub8));*)

      gm.SetCorrectWindow(pal1,wind);
      gm.RefreshPaletteGadget(pal1);
      gm.SetCorrectWindow(pal2,wind);
      gm.RefreshPaletteGadget(pal2);
  
      I.RefreshGadgets(stepx1,wind,NIL);
      bool:=I.ActivateGadget(stepx1^,wind,NIL);
  
      LOOP
        e.WaitPort(wind.userPort);
        it.GetIMes(wind,class,code,address);
        bool:=gm.CheckPaletteGadget(pal1,class,code,address);
        bool:=gm.CheckPaletteGadget(pal2,class,code,address);
        IF I.gadgetUp IN class THEN
          IF address=ok THEN
  (*          p.grid1.xspace:=xspace1;
            p.grid1.yspace:=yspace1;
            p.grid1.xstart:=xstart1;
            p.grid1.ystart:=ystart1;
            p.grid1.col:=col1;
            p.grid1.muster:=muster1;
            p.grid1.on:=won1;
  
            p.grid2.xspace:=xspace2;
            p.grid2.yspace:=yspace2;
            p.grid2.xstart:=xstart2;
            p.grid2.ystart:=ystart2;
            p.grid2.col:=col2;
            p.grid2.muster:=muster2;
            p.grid2.on:=won2;*)
  
            p.grid1.col:=gm.ActCol(pal1);
            p.grid2.col:=gm.ActCol(pal2);
            p.grid1.muster:=muster1;
            p.grid2.muster:=muster2;
            p.grid1.width:=actwi1;
            p.grid2.width:=actwi2;
            p.grid1.on:=on1;
            p.grid2.on:=on2;
            p.autogridscale:=FALSE;
  
            gm.GetGadgetText(startx1,p.grid1.xstarts);
            gm.GetGadgetText(starty1,p.grid1.ystarts);
            gm.GetGadgetText(stepx1,p.grid1.xspaces);
            gm.GetGadgetText(stepy1,p.grid1.yspaces);
            gm.GetGadgetText(startx2,p.grid2.xstarts);
            gm.GetGadgetText(starty2,p.grid2.ystarts);
            gm.GetGadgetText(stepx2,p.grid2.xspaces);
            gm.GetGadgetText(stepy2,p.grid2.yspaces);

            p.grid1.xstart:=f.ExpressionToReal(p.grid1.xstarts);
            p.grid1.ystart:=f.ExpressionToReal(p.grid1.ystarts);
            p.grid1.xspace:=f.ExpressionToReal(p.grid1.xspaces);
            p.grid1.yspace:=f.ExpressionToReal(p.grid1.yspaces);
            p.grid2.xstart:=f.ExpressionToReal(p.grid2.xstarts);
            p.grid2.ystart:=f.ExpressionToReal(p.grid2.ystarts);
            p.grid2.xspace:=f.ExpressionToReal(p.grid2.xspaces);
            p.grid2.yspace:=f.ExpressionToReal(p.grid2.yspaces);

(*            ig.GetGadgetText(s.ADR(startx1),p1);
            ig.GetGadgetText(s.ADR(starty1),p2);
            ig.GetGadgetText(s.ADR(stepx1),p3);
            ig.GetGadgetText(s.ADR(stepy1),p4);
            COPY(p1^,p.grid1.xstarts);
            COPY(p2^,p.grid1.ystarts);
            COPY(p3^,p.grid1.xspaces);
            COPY(p4^,p.grid1.yspaces);
            i:=0;
            root:=f.Parse(p.grid1.xstarts,i);
            p.grid1.xstart:=f.Rechen(root,0,0,i);
            i:=0;
            root:=f.Parse(p.grid1.ystarts,i);
            p.grid1.ystart:=f.Rechen(root,0,0,i);
            i:=0;
            root:=f.Parse(p.grid1.xspaces,i);
            p.grid1.xspace:=f.Rechen(root,0,0,i);
            i:=0;
            root:=f.Parse(p.grid1.yspaces,i);
            p.grid1.yspace:=f.Rechen(root,0,0,i);

            ig.GetGadgetText(s.ADR(startx2),p1);
            ig.GetGadgetText(s.ADR(starty2),p2);
            ig.GetGadgetText(s.ADR(stepx2),p3);
            ig.GetGadgetText(s.ADR(stepy2),p4);
            COPY(p1^,p.grid2.xstarts);
            COPY(p2^,p.grid2.ystarts);
            COPY(p3^,p.grid2.xspaces);
            COPY(p4^,p.grid2.yspaces);
            i:=0;
            root:=f.Parse(p.grid2.xstarts,i);
            p.grid2.xstart:=f.Rechen(root,0,0,i);
            i:=0;
            root:=f.Parse(p.grid2.ystarts,i);
            p.grid2.ystart:=f.Rechen(root,0,0,i);
            i:=0;
            root:=f.Parse(p.grid2.xspaces,i);
            p.grid2.xspace:=f.Rechen(root,0,0,i);
            i:=0;
            root:=f.Parse(p.grid2.yspaces,i);
            p.grid2.yspace:=f.Rechen(root,0,0,i);*)

(*            bool:=rc.StringToReal(p1^,p.grid1.xstart);
            bool:=rc.StringToReal(p2^,p.grid1.ystart);
            bool:=rc.StringToReal(p3^,p.grid1.xspace);
            bool:=rc.StringToReal(p4^,p.grid1.yspace);*)
  
(*            ig.GetGadgetText(s.ADR(startx2),p5);
            ig.GetGadgetText(s.ADR(starty2),p6);
            ig.GetGadgetText(s.ADR(stepx2),p7);
            ig.GetGadgetText(s.ADR(stepy2),p8);
            bool:=rc.StringToReal(p5^,p.grid2.xstart);
            bool:=rc.StringToReal(p6^,p.grid2.ystart);
            bool:=rc.StringToReal(p7^,p.grid2.xspace);
            bool:=rc.StringToReal(p8^,p.grid2.yspace);*)
  
            ret:=TRUE;
            EXIT;
          ELSIF address=ca THEN
            ret:=FALSE;
            EXIT;
          ELSIF address=on1g THEN
            on1:=NOT(on1);
          ELSIF address=on2g THEN
            on2:=NOT(on2);
          ELSIF address=stepx1 THEN
            bool:=I.ActivateGadget(stepy1^,wind,NIL);
          ELSIF address=stepy1 THEN
            bool:=I.ActivateGadget(startx1^,wind,NIL);
          ELSIF address=startx1 THEN
            bool:=I.ActivateGadget(starty1^,wind,NIL);
          ELSIF address=starty1 THEN
            bool:=I.ActivateGadget(stepx2^,wind,NIL);
          ELSIF address=stepx2 THEN
            bool:=I.ActivateGadget(stepy2^,wind,NIL);
          ELSIF address=stepy2 THEN
            bool:=I.ActivateGadget(startx2^,wind,NIL);
          ELSIF address=startx2 THEN
            bool:=I.ActivateGadget(starty2^,wind,NIL);
          ELSIF address=starty2 THEN
            bool:=I.ActivateGadget(stepx1^,wind,NIL);
(*          ELSE
            i:=-1;
            WHILE i<cols-1 DO
              INC(i);
              IF address=s.ADR(col1g[i]) THEN
                g.SetAPen(rast,i);
                g.RectFill(rast,30,118,63,133);
                col1:=i;
              ELSIF address=s.ADR(col2g[i]) THEN
                g.SetAPen(rast,i);
                g.RectFill(rast,258,118,291,133);
                col2:=i;
              END;
            END;*)
          END;
        ELSIF I.mouseButtons IN class THEN
          bool:=CheckLines(wind,26,147,muster1);
          bool:=CheckLines(wind,254,147,muster2);
          bool:=CheckWidths(wind,26,174,actwi1);
          bool:=CheckWidths(wind,254,174,actwi2);
(*          it.GetMousePos(wind,x,y);
          IF (x>28) AND (x<215) AND (y>146) AND (y<163) THEN
            x:=x-28;
            x:=x DIV 30;
            IF (y>146) AND (y<154) THEN
              act1:=x;
            ELSIF (y>155) AND (y<163) THEN
              act1:=x+5;
            END;
            muster1:=act1;
            RefreshBorders1;
(*            RefreshLine1;*)
          ELSIF (x>256) AND (x<443) AND (y>146) AND (y<163) THEN
            x:=x-256;
            x:=x DIV 30;
            IF (y>146) AND (y<154) THEN
              act2:=x;
            ELSIF (y>155) AND (y<163) THEN
              act2:=x+5;
            END;
            muster2:=act2;
            RefreshBorders2;
(*            RefreshLine2;*)
          ELSIF (x>28) AND (x<234) AND (y>173) AND (y<204) THEN
            y:=y-174;
            y:=y DIV 10;
            IF x>130 THEN
              y:=y+3;
            END;
            INC(y);
            actwi1:=y;
            IF actwi1>5 THEN
              actwi1:=5;
            END;
            RefreshWidthBorders1;
          ELSIF (x>256) AND (x<462) AND (y>173) AND (y<204) THEN
            y:=y-174;
            y:=y DIV 10;
            IF x>358 THEN
              y:=y+3;
            END;
            INC(y);
            actwi2:=y;
            IF actwi2>5 THEN
              actwi2:=5;
            END;
            RefreshWidthBorders2;
          END;*)
        END;
        IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"changegrid",wind);
        END;
      END;

(*      ig.FreePlastStringGadget(starty2,wind);
      ig.FreePlastStringGadget(startx2,wind);
      ig.FreePlastStringGadget(stepy2,wind);
      ig.FreePlastStringGadget(stepx2,wind);
      ig.FreePlastStringGadget(starty1,wind);
      ig.FreePlastStringGadget(startx1,wind);
      ig.FreePlastStringGadget(stepy1,wind);
      ig.FreePlastStringGadget(stepx1,wind);
      ig.FreePlastCheckBoxGadget(on2g,wind);
      ig.FreePlastCheckBoxGadget(on1g,wind);
      ig.FreePlastHighBooleanGadget(ca,wind);
      ig.FreePlastHighBooleanGadget(ok,wind);
      ig.FreePlastBorder(bord1);
      ig.FreePlastBorder(bord2);
      ig.FreePlastBorder(bord3);
      ig.FreePlastBorder(bordcol);
      i:=-1;
      WHILE i<9 DO
        INC(i);
        ig.FreePlastBorder(linebord[i]);
        ig.FreePlastBorder(linebordsel[i]);
      END;*)
      wm.CloseWindow(gitterId);
    END;
  END;
  wm.FreeGadgets(gitterId);
  RETURN ret;
END ChangeGitter;

PROCEDURE ChangeSkala*(p:l.Node):BOOLEAN;

VAR wind         : I.WindowPtr;
    rast         : g.RastPortPtr;
    ok,ca,
    help,
    on,
    numson,
    markon,
    hervon,
    numsx,
    numsy,
    markx,
    marky,
    hervx,
    hervy,
    bezx,
    bezy,
    onx,
    ony,
    font         : I.GadgetPtr;
(*    col          : ARRAY 16 OF I.Gadget;
    cols         : INTEGER;*)
    pal          : l.Node;
    numsonv,
    markonv,
    hervonv,
    onv,
    bezxonv,
    bezyonv      : BOOLEAN;
    coln         : INTEGER;
    bord1,
    bord2,
    bord3,
    bordcol      : I.BorderPtr;
    ret          : BOOLEAN;
    act,actwi,
    actarr       : INTEGER;
    linebord,
    linebordsel,
    widthbord,
    widthbordsel,
    arrowbord,
    arrowbordsel : I.BorderPtr;
(*    ub1,
    ub2,
    ub3,
    ub4,
    ub5,
    ub6,
    ub7,
    ub8          : ARRAY 17 OF CHAR;
    p1,
    p2,
    p3,
    p4,
    p5,
    p6,
    p7,
    p8           : e.STRPTR(*POINTER TO ARRAY 17 OF CHAR*);*)
    x,y          : INTEGER;
    attr         : g.TextAttr;
    fontrequest  : as.FontRequesterPtr;

PROCEDURE RefreshArrowBorders;

VAR i : INTEGER;

BEGIN
  FOR i:=0 TO 9 DO
    IF i<5 THEN
      IF actarr=i THEN
        it.DrawBorderIn(rast,220+i*26,138,24,13);
(*        I.DrawBorder(rast,arrowbordsel,222+i*26,140);*)
      ELSE
        it.DrawBorder(rast,220+i*26,138,24,13);
(*        I.DrawBorder(rast,arrowbord,222+i*26,140);*)
      END;
    ELSE
      IF actarr=i THEN
        it.DrawBorderIn(rast,220+(i-5)*26,153,24,13);
(*        I.DrawBorder(rast,arrowbordsel,222+(i-5)*26,155);*)
      ELSE
        it.DrawBorder(rast,220+(i-5)*26,153,24,13);
(*        I.DrawBorder(rast,arrowbord,222+(i-5)*26,155);*)
      END;
    END;
  END;
END RefreshArrowBorders;

PROCEDURE RefreshArrows;

VAR i : INTEGER;

BEGIN
  FOR i:=0 TO 9 DO
    IF i<5 THEN
      vt.DrawVectorObject(rast,s1.arrows[i],230+i*26+12,138+6,20,11,0,1,1);
(*      s1.DrawArrow(rast,224+i*26+s1.arrows[i].hotx,140+s1.arrows[i].hoty,i,1,1);*)
    ELSE
      vt.DrawVectorObject(rast,s1.arrows[i],230+(i-5)*26+12,153+6,20,11,0,1,1);
(*      s1.DrawArrow(rast,224+(i-5)*26+s1.arrows[i].hotx,155+s1.arrows[i].hoty,i,1,1);*)
    END;
  END;
END RefreshArrows;

BEGIN
  ret:=FALSE;
  IF skalaId=-1 THEN
    skalaId:=wm.InitWindow(80,20,456,196,ac.GetString(ac.AxisDesign),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.mouseMove},s1.screen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,175,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(342,175,100,14,ac.GetString(ac.Cancel));
  help:=gm.SetBooleanGadget(120,175,100,14,ac.GetString(ac.Help));
  font:=gm.SetBooleanGadget(26,153,176,14,ac.GetString(ac.Font));
  on:=gm.SetCheckBoxGadget(152,18,26,9,p(s1.Fenster).scale.on);
  numson:=gm.SetCheckBoxGadget(148,41,26,9,p(s1.Fenster).scale.numson);
  markon:=gm.SetCheckBoxGadget(148,67,26,9,p(s1.Fenster).scale.mark1on);
  hervon:=gm.SetCheckBoxGadget(148,94,26,9,p(s1.Fenster).scale.mark2on);
  onx:=gm.SetCheckBoxGadget(178,123,26,9,p(s1.Fenster).scale.xbezon);
  ony:=gm.SetCheckBoxGadget(178,139,26,9,p(s1.Fenster).scale.ybezon);
  numsx:=gm.SetStringGadget(40,52,32,14,79);
  numsy:=gm.SetStringGadget(102,52,32,14,79);
  markx:=gm.SetStringGadget(40,79,32,14,79);
  marky:=gm.SetStringGadget(102,79,32,14,79);
  hervx:=gm.SetStringGadget(40,106,32,14,79);
  hervy:=gm.SetStringGadget(102,106,32,14,79);
  bezx:=gm.SetStringGadget(132,122,32,14,79);
  bezy:=gm.SetStringGadget(132,138,32,14,79);
  pal:=gm.SetPaletteGadget(220,40,200,20,s1.screen.rastPort.bitMap.depth,p(s1.Fenster).scale.col);
  gm.EndGadgets;
  wm.SetGadgets(skalaId,ok);
  wm.ChangeScreen(skalaId,s1.screen);
  wind:=wm.OpenWindow(skalaId);
  IF wind#NIL THEN
    WITH p: s1.Fenster DO
      rast:=wind.rPort;
(*      ig.SetPlastHighGadget(ok,wind,s.ADR("OK"),12,175,100,
                        SET{I.gadgImmediate,I.relVerify});
      ig.SetPlastHighGadget(ca,wind,s.ADR("Abbrechen"),340,175,100,
                        SET{I.gadgImmediate,I.relVerify});

      ig.SetCheckBoxGadget(on,wind,150,18,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
      ig.SetCheckBoxGadget(numson,wind,146,41,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
      ig.SetCheckBoxGadget(markon,wind,146,68,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
      ig.SetCheckBoxGadget(hervon,wind,146,95,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
      ig.SetCheckBoxGadget(onx,wind,176,123,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
      ig.SetCheckBoxGadget(ony,wind,176,139,
                        SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
  
      ig.SetPlastStringGadget(numsx,wind,32,15,38,52,FALSE);
      ig.SetPlastStringGadget(numsy,wind,32,15,100,52,FALSE);
      ig.SetPlastStringGadget(markx,wind,32,15,38,79,FALSE);
      ig.SetPlastStringGadget(marky,wind,32,15,100,79,FALSE);
      ig.SetPlastStringGadget(hervx,wind,32,15,38,106,FALSE);
      ig.SetPlastStringGadget(hervy,wind,32,15,100,106,FALSE);
      ig.SetPlastStringGadget(bezx,wind,32,15,130,122,FALSE);
      ig.SetPlastStringGadget(bezy,wind,32,15,130,138,FALSE);*)
  
      g.SetAPen(rast,1);
      tt.Print(20,25,ac.GetString(ac.AxisSystemOn),rast);
      tt.Print(20,36,ac.GetString(ac.Scale),rast);
      tt.Print(214,25,ac.GetString(ac.AxisRealDesign),rast);
      g.SetAPen(rast,2);
      tt.Print(26,48,ac.GetString(ac.Values),rast);
      tt.Print(26,61,s.ADR("x"),rast);
      tt.Print(88,61,s.ADR("y"),rast);
      tt.Print(26,76,ac.GetString(ac.Ticks1),rast);
      tt.Print(26,88,s.ADR("x"),rast);
      tt.Print(88,88,s.ADR("y"),rast);
      tt.Print(26,103,ac.GetString(ac.Ticks2),rast);
      tt.Print(26,115,s.ADR("x"),rast);
      tt.Print(88,115,s.ADR("y"),rast);
      tt.Print(26,131,ac.GetString(ac.XAxisLabel),rast);
      tt.Print(26,147,ac.GetString(ac.YAxisLabel),rast);
      tt.Print(220,37,ac.GetString(ac.Color),rast);
      tt.Print(220,68,ac.GetString(ac.LinePattern),rast);
      tt.Print(220,95,ac.GetString(ac.LineThickness),rast);
      tt.Print(220,135,ac.GetString(ac.Arrow),rast);
  
(*      cols:=SHORT(ig.Hoch(2,s1.screen.bitMap.depth));
      s1.SetPalette(col,cols,wind,272,41);
      bordcol:=ig.SetPlastInBorder(16,38);
      I.DrawBorder(rast,bordcol,222,41);*)

      it.DrawBorder(rast,14,16,428,156);
      it.DrawBorder(rast,20,39,188,130);
      it.DrawBorder(rast,214,28,222,141);
  
(*      bord1:=ig.SetPlastBorder(153,424);
      I.DrawBorder(rast,bord1,16,17);

      bord2:=ig.SetPlastBorder(127,184);
      I.DrawBorder(rast,bord2,22,40);

      bord3:=ig.SetPlastBorder(138,218);
      I.DrawBorder(rast,bord3,216,29);

      linebord:=ig.SetPlastBorder(3,24);
      linebordsel:=ig.SetPlastInBorder(3,24);

      widthbord:=ig.SetPlastBorder(5,98);
      widthbordsel:=ig.SetPlastInBorder(5,98);

      arrowbord:=ig.SetPlastBorder(9,20);
      arrowbordsel:=ig.SetPlastInBorder(9,20);

      act:=-1;
      WHILE act<9 DO
        INC(act);
        RefreshLine;
      END;*)
      act:=p.scale.muster;
      actwi:=p.scale.width;
      actarr:=p.scale.arrow;
(*      RefreshBorders;
      RefreshLines;
      RefreshWidthLines;
      RefreshWidthBorders;*)
      RefreshArrows;
      RefreshArrowBorders;

      RefreshLines(rast,220,71);
      RefreshLineBorders(rast,220,71,act);
      RefreshWidthLines(rast,220,98);
      RefreshWidthBorders(rast,220,98,actwi);
  
      coln:=p.scale.col;
(*      g.SetAPen(rast,coln);
      g.RectFill(rast,224,42,257,57);*)

      gm.PutGadgetText(numsx,p.scale.numsxs);
      gm.PutGadgetText(numsy,p.scale.numsys);
      gm.PutGadgetText(markx,p.scale.mark1xs);
      gm.PutGadgetText(marky,p.scale.mark1ys);
      gm.PutGadgetText(hervx,p.scale.mark2xs);
      gm.PutGadgetText(hervy,p.scale.mark2ys);
      gm.PutGadgetText(bezx,p.scale.xname);
      gm.PutGadgetText(bezy,p.scale.yname);
  
(*      bool:=lrc.RealToString(p.scale.numsx,ub1,7,6,FALSE);
      bool:=lrc.RealToString(p.scale.numsy,ub2,7,6,FALSE);
      bool:=lrc.RealToString(p.scale.mark1x,ub3,7,6,FALSE);
      bool:=lrc.RealToString(p.scale.mark1y,ub4,7,6,FALSE);
      bool:=lrc.RealToString(p.scale.mark2x,ub5,7,6,FALSE);
      bool:=lrc.RealToString(p.scale.mark2y,ub6,7,6,FALSE);
      tt.Clear(ub1);
      tt.Clear(ub2);
      tt.Clear(ub3);
      tt.Clear(ub4);
      tt.Clear(ub5);
      tt.Clear(ub6);
      ig.PutGadgetText(s.ADR(numsx),s.ADR(ub1));
      ig.PutGadgetText(s.ADR(numsy),s.ADR(ub2));
      ig.PutGadgetText(s.ADR(markx),s.ADR(ub3));
      ig.PutGadgetText(s.ADR(marky),s.ADR(ub4));
      ig.PutGadgetText(s.ADR(hervx),s.ADR(ub5));
      ig.PutGadgetText(s.ADR(hervy),s.ADR(ub6));

      COPY(p.scale.xname,ub7);
      COPY(p.scale.yname,ub8);
      ig.PutGadgetText(s.ADR(bezx),s.ADR(ub7));
      ig.PutGadgetText(s.ADR(bezy),s.ADR(ub8));*)

      gm.SetCorrectWindow(pal,wind);
      gm.RefreshPaletteGadget(pal);

      I.RefreshGadgets(numsx,wind,NIL);
      bool:=I.ActivateGadget(numsx^,wind,NIL);
  
(*      IF p.scale.numson THEN
        gm.ActivateBool(numson,wind);
      END;
      IF p.scale.mark1on THEN
        gm.ActivateBool(markon,wind);
      END;
      IF p.scale.mark2on THEN
        gm.ActivateBool(hervon,wind);
      END;
      IF p.scale.on THEN
        gm.ActivateBool(on,wind);
      END;
      IF p.scale.xbezon THEN
        gm.ActivateBool(onx,wind);
      END;
      IF p.scale.ybezon THEN
        gm.ActivateBool(ony,wind);
      END;*)
      numsonv:=p.scale.numson;
      markonv:=p.scale.mark1on;
      hervonv:=p.scale.mark2on;
      onv:=p.scale.on;
      bezxonv:=p.scale.xbezon;
      bezyonv:=p.scale.ybezon;
      attr.name:=e.AllocMem(s.SIZE(CHAR)*256,LONGSET{e.memClear});
      COPY(p.scale.attr.name^,attr.name^);
      attr.ySize:=p.scale.attr.ySize;
      attr.style:=p.scale.attr.style;
      fontrequest:=NIL;
  
      LOOP
        e.WaitPort(wind.userPort);
        it.GetIMes(wind,class,code,address);
        bool:=gm.CheckPaletteGadget(pal,class,code,address);
        IF I.gadgetUp IN class THEN
          IF address=ok THEN
            gm.GetGadgetText(numsx,p.scale.numsxs);
            gm.GetGadgetText(numsy,p.scale.numsys);
            gm.GetGadgetText(markx,p.scale.mark1xs);
            gm.GetGadgetText(marky,p.scale.mark1ys);
            gm.GetGadgetText(hervx,p.scale.mark2xs);
            gm.GetGadgetText(hervy,p.scale.mark2ys);
            gm.GetGadgetText(bezx,p.scale.xname);
            gm.GetGadgetText(bezy,p.scale.yname);

            p.scale.numsx:=f.ExpressionToReal(p.scale.numsxs);
            p.scale.numsy:=f.ExpressionToReal(p.scale.numsxs);
            p.scale.mark1x:=f.ExpressionToReal(p.scale.mark1xs);
            p.scale.mark1y:=f.ExpressionToReal(p.scale.mark1ys);
            p.scale.mark2x:=f.ExpressionToReal(p.scale.mark2xs);
            p.scale.mark2y:=f.ExpressionToReal(p.scale.mark2ys);
(*            ig.GetGadgetText(s.ADR(numsx),p1);
            ig.GetGadgetText(s.ADR(numsy),p2);
            ig.GetGadgetText(s.ADR(markx),p3);
            ig.GetGadgetText(s.ADR(marky),p4);
            ig.GetGadgetText(s.ADR(hervx),p5);
            ig.GetGadgetText(s.ADR(hervy),p6);
            bool:=lrc.StringToReal(p1^,p.scale.numsx);
            bool:=lrc.StringToReal(p2^,p.scale.numsy);
            bool:=lrc.StringToReal(p3^,p.scale.mark1x);
            bool:=lrc.StringToReal(p4^,p.scale.mark1y);
            bool:=lrc.StringToReal(p5^,p.scale.mark2x);
            bool:=lrc.StringToReal(p6^,p.scale.mark2y);

            ig.GetGadgetText(s.ADR(bezx),p7);
            ig.GetGadgetText(s.ADR(bezy),p8);
            COPY(p7^,p.scale.xname);
            COPY(p8^,p.scale.yname);*)

            p.scale.numson:=numsonv;
            p.scale.mark1on:=markonv;
            p.scale.mark2on:=hervonv;
            p.scale.on:=onv;
            p.scale.xbezon:=bezxonv;
            p.scale.ybezon:=bezyonv;
            p.scale.muster:=act;
            p.scale.col:=gm.ActCol(pal);
            p.scale.width:=actwi;
            p.scale.arrow:=actarr;
            p.autoskalascale:=FALSE;
            COPY(attr.name^,p.scale.attr.name^);
            p.scale.attr.ySize:=attr.ySize;
            p.scale.attr.style:=attr.style;
            ret:=TRUE;
            EXIT;
          ELSIF address=ca THEN
            ret:=FALSE;
            EXIT;
          ELSIF address=font THEN
            bool:=at.FontRequest(fontrequest,ac.GetString(ac.SelectAxisLabelsFont),wind,s.ADR(attr),at.nocols,at.nocols);
          ELSIF address=numson THEN
            numsonv:=NOT(numsonv);
          ELSIF address=hervon THEN
            hervonv:=NOT(hervonv);
          ELSIF address=markon THEN
            markonv:=NOT(markonv);
          ELSIF address=on THEN
            onv:=NOT(onv);
          ELSIF address=onx THEN
            bezxonv:=NOT(bezxonv);
          ELSIF address=ony THEN
            bezyonv:=NOT(bezyonv);
          ELSIF address=numsx THEN
            bool:=I.ActivateGadget(numsy^,wind,NIL);
          ELSIF address=numsy THEN
            bool:=I.ActivateGadget(markx^,wind,NIL);
          ELSIF address=markx THEN
            bool:=I.ActivateGadget(marky^,wind,NIL);
          ELSIF address=marky THEN
            bool:=I.ActivateGadget(hervx^,wind,NIL);
          ELSIF address=hervx THEN
            bool:=I.ActivateGadget(hervy^,wind,NIL);
          ELSIF address=hervy THEN
            bool:=I.ActivateGadget(bezx^,wind,NIL);
          ELSIF address=bezx THEN
            bool:=I.ActivateGadget(bezy^,wind,NIL);
          ELSIF address=bezy THEN
            bool:=I.ActivateGadget(numsx^,wind,NIL);
(*          ELSE
            i:=-1;
            WHILE i<cols-1 DO
              INC(i);
              IF address=s.ADR(col[i]) THEN
                g.SetAPen(rast,i);
                g.RectFill(rast,224,42,257,57);
                coln:=i;
              END;
            END;*)
          END;
        ELSIF I.mouseButtons IN class THEN
          bool:=CheckLines(wind,220,71,act);
          bool:=CheckWidths(wind,220,98,actwi);
          it.GetMousePos(winIN
  bool:=c.IntToString(reqpri,string,3);
  tt.Clear(string);
  gm.PutGadgetText(reqstr,string);
  I.RefreshGList(reqstr,wind,NIL,1);
  gm.SetSlider(reqslide,wind,-128,13w,reqpri);
END RefreshMathReq;

PROEDURE CheckPris;

BEGIN
  oldmath:=lathpri;
  IF lathpri<-12> THEN
    mathpri:=-128;
  ELSIF mathpri>127 THEN
    mathpri;}127;
  END;
  IF oldmath%mathpri THEN
  & RefreshMath;
  END;
  oldprev:=prevpri;
  IF prevpri<-128 THEN
    prevpri:=-128;
  ELSIF prevpri>12W THEN
    prevpri:=127;
 PEND;
  IF ol    RefreshWidthBorders;*)
          IF (x>219) AND (x<350) AND (y>137) AND (y<166) THEN
            x:=x-220;
            x:=x DIV 26;
            IF y>152 THEN
              INC(x,5);
            END;
            actarr:=x;
            RefreshArrowBorders;
          END;
        END;
        IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
          ag.ShowFile(s1.analaydoc,"changeaxes",wind);
        END;
      END;
  
      IF fontrequest#NIL THEN
        as.FreeAslRequest(fontrequest);
      END;
(*      ig.FreePlastStringGadget(bezy,wind);
      ig.FreePlastStringGadget(bezx,wind);
      ig.FreePlastStringGadget(hervy,wind);
      ig.FreePlastStringGadget(hervx,wind);
      ig.FreePlastCheckBoxGadget(ony,wind);
      ig.FreePlastCheckBoxGadget(onx,wind);
      ig.FreePlastCheckBoxGadget(hervon,wind);
      ig.FreePlastStringGadget(marky,wind);
      ig.FreePlastStringGadget(markx,wind);
      ig.FreePlastCheckBoxGadget(markon,wind);
      ig.FreePlastStringGadget(numsy,wind);
      ig.FreePlastStringGadget(numsx,wind);
      ig.FreePlastCheckBoxGadget(numson,wind);
      ig.FreePlastCheckBoxGadget(on,wind);
      ig.FreePlastHighBooleanGadget(ca,wind);
      ig.FreePlastHighBooleanGadget(ok,wind);
      ig.FreePlastBorder(bord1);
      ig.FreePlastBorder(bord2);
      ig.FreePlastBorder(bord3);
      ig.FreePlastBorder(bordcol);
      ig.FreePlastBorder(linebord);
      ig.FreePlastBorder(linebordsel);*)
      e.FreeMem(attr.name,s.SIZE(CHAR)*256);
      wm.CloseWindow(skalaId);
    END;
  END;
  wm.FreeGadgets(skalaId);
  RETURN ret;
END ChangeSkala;

PROCEDURE CheckAxesLimits*(p:l.Node);

VAR dx,dy : LONGREAL;
    str   : ARRAY 256 OF CHAR;

BEGIN
  WITH p: s1.Fenster DO
    IF p.xmin>p.xmax THEN
      dx:=p.xmax;
      p.xmax:=p.xmin;
      p.xmin:=SHORT(dx);
      COPY(p.xmaxs,str);
      COPY(p.xmins,p.xmaxs);
      COPY(str,p.xmins);
(*      gm.PutGadgetText(xmin,p.xmins);
      gm.PutGadgetText(xmax,p.xmaxs);
      I.RefreshGList(xmin,wind,NIL,2);*)
    END;
    IF p.ymin>p.ymax THEN
      dy:=p.ymax;
      p.ymax:=p.ymin;
      p.ymin:=SHORT(dy);
      COPY(p.ymaxs,str);
      COPY(p.ymins,p.ymaxs);
      COPY(str,p.ymins);
(*      gm.PutGadgetText(ymin,p.ymins);
      gm.PutGadgetText(ymax,p.ymaxs);
      I.RefreshGList(ymin,wind,NIL,2);*)
    END;
    dx:=p.xmax-p.xmin;
    IF dx<0.001 THEN
      dx:=0.001;
      p.xmax:=p.xmin+SHORT(dx);
      bool:=lrc.RealToString(p.xmax,p.xmaxs,7,7,FALSE);
      tt.Clear(p.xmaxs);
(*      gm.PutGadgetText(xmax,p.xmaxs);
      I.RefreshGList(xmax,wind,NIL,1);*)
    END;
    dy:=p.ymax-p.ymin;
    IF dy<0.001 THEN
      dy:=0.001;
      p.ymax:=p.ymin+SHORT(dy);
      bool:=lrc.RealToString(p.ymax,p.ymaxs,7,7,FALSE);
      tt.Clear(p.ymaxs);
(*      gm.PutGadgetText(ymax,p.ymaxs);
      I.RefreshGList(ymax,wind,NIL,1);*)
    END;
  END;
END CheckAxesLimits;

PROCEDURE ChangeBereich*(data:bt.ANY):bt.ANY;

VAR wind      : I.WindowPtr;
    rast      : g.RastPortPtr;
    ok,ca,
    help,
    xmin,xmax,
    ymin,ymax,
    undo      : I.GadgetPtr;
    p,node    : l.Node;
    sigtoend,
    sigtofront,
    sigtosleep,
    sigtonewvals : SHORTINT;
    string,
    savexmin,
    savexmax,
    saveymin,
    saveymax  : ARRAY 256 OF CHAR;
    ret       : BOOLEAN;

PROCEDURE CheckChanged;

VAR changed : BOOLEAN;

BEGIN
  WITH p: s1.Fenster DO
    changed:=FALSE;
    gm.GetGadgetText(xmin,string);
    IF NOT(tt.Compare(string,p.xmins)) THEN
      changed:=TRUE;
      COPY(string,p.xmins);
      p.xmin:=SHORT(f.ExpressionToReal(p.xmins));
    END;
    gm.GetGadgetText(xmax,string);
    IF NOT(tt.Compare(string,p.xmaxs)) THEN
      changed:=TRUE;
      COPY(string,p.xmaxs);
      p.xmax:=SHORT(f.ExpressionToReal(p.xmaxs));
    END;
    gm.GetGadgetText(ymin,string);
    IF NOT(tt.Compare(string,p.ymins)) THEN
      changed:=TRUE;
      COPY(string,p.ymins);
      p.ymin:=SHORT(f.ExpressionToReal(p.ymins));
    END;
    gm.GetGadgetText(ymax,string);
    IF NOT(tt.Compare(string,p.ymaxs)) THEN
      changed:=TRUE;
      COPY(string,p.ymaxs);
     
  exp:=FALSE;
  start:=0;
  end:=10;
  step:=1;
END SuperCalcTools8.
