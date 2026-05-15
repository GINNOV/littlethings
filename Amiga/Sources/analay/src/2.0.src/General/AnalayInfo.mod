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


MODULE AnalayInfo;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       gd : GadTools,
       im : Images,
       st : Strings,
       m  : Multitasking,
       mem: MemoryManager,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       gme: GuiManagerExtendedObjects,
       vs : VersionStrings,
       mg : MathGUI,
       ac : AnalayCatalog,
       kf : KeyFiles,
       bt : BasicTypes,
       io,
       NoGuruRq;

VAR analayinfowind * ,
    buhwind        * : wm.Window;

PROCEDURE Buh*;

VAR subwind     : wm.SubWindow;
    wind        : I.WindowPtr;
    rast        : g.RastPortPtr;
    root        : gmb.Root;
    okgad       : gmo.BooleanGadget;
    gadobj      : gmb.Object;
    glist       : I.GadgetPtr;
    mes         : I.IntuiMessagePtr;
    class       : LONGSET;
    bool        : BOOLEAN;

BEGIN
  NEW(mes);
  IF buhwind=NIL THEN
    buhwind:=wm.InitWindow(wm.centered,wm.centered,10,10,TRUE,s.ADR("Buh!"),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=buhwind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{},subwind);
    gadobj:=gmb.NewBox(gmb.horizBox,gd.bbftButton,FALSE,NIL);
      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      gmb.EndBox;
      gadobj.SetSizeX(1);

      gadobj:=gmo.SetText(s.ADR("Buh!"),gmo.shadowText);
      gadobj.SetSizeXY(0,1);

      gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      gmb.EndBox;
      gadobj.SetSizeX(1);
    gmb.EndBox;
    okgad:=gmo.SetBooleanGadget(ac.GetString(ac.OK),FALSE);
  glist:=root.EndRoot();

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    LOOP
      subwind.WaitPort;
      REPEAT
        root.GetIMes(mes);
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=okgad.gadget THEN
            EXIT;
          END;
        END;
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
END Buh;

PROCEDURE AnalayInfo*(infotask:m.Task);

VAR subwind     : wm.SubWindow;
    wind        : I.WindowPtr;
    rast        : g.RastPortPtr;
    root        : gmb.Root;
    analaygad,
    analysisgad : gmo.ImageGadget;
    spacegad    : gme.Space;
    okgad       : gmo.BooleanGadget;
    gadobj      : gmb.Object;
    glist       : I.GadgetPtr;
    mes         : I.IntuiMessagePtr;
    msg         : m.Message;
    class       : LONGSET;
    name        : ARRAY 5 OF ARRAY 80 OF CHAR;
    i,pos,kfpos : INTEGER;
    bool        : BOOLEAN;

BEGIN
  NEW(mes);
  IF analayinfowind=NIL THEN
    analayinfowind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,vs.progversion,LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=analayinfowind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gmb.noBorder,FALSE,NIL,LONGSET{},subwind);
    gadobj:=gmb.NewBox(gmb.horizBox,gd.bbftButton,FALSE,NIL);
      gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,FALSE,NIL);
        gadobj:=gmb.NewBox(gmb.horizBox,gd.bbftButton,FALSE,NIL);
          analaygad:=gmo.SetImageGadget(160,31,2,im.analayimg,im.analayimg,FALSE);
          gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
            spacegad:=gme.SetSpace(gmb.noBorder,FALSE,10,5,FALSE);
            spacegad.SetSizeY(0);
            gadobj:=gmo.SetText(vs.version,gmo.shadowText);
            gadobj.SetSizeXY(1,-1);
          gmb.EndBox;
        gmb.EndBox;
        gadobj:=gmo.SetText(vs.copyright,-1);
        gadobj:=gmo.SetText(ac.GetString(ac.AllRightsReserved),-1);
        gadobj:=gmo.SetText(s.ADR("UUCP: Marc@buster.apl.s.shuttle.de"),-1);
        gadobj:=gmo.SetText(s.ADR("Fido: 2:246/1115.15"),-1);
        gadobj:=gmo.SetText(s.ADR(" "),-1);

        IF ~kf.demo THEN
          gadobj:=gmo.SetText(ac.GetString(ac.ThisVersionIsRegisteredTo),-1);
          gadobj:=gmo.SetText(s.ADR(" "),-1);
          io.WriteString(kf.name); io.WriteLn;
          kfpos:=0;
          i:=0;
          WHILE i<5 DO
            pos:=0;
            WHILE (kfpos<st.Length(kf.name)) & (kf.name[kfpos]#",") & (kf.name[kfpos]#0X) & (pos<79) DO
              name[i,pos]:=kf.name[kfpos];
              INC(kfpos); INC(pos);
            END;
            name[i,pos]:=0X;
            io.WriteString(name[i]); io.WriteLn;

            gadobj:=gmo.SetText(s.ADR(name[i]),-1);

            INC(kfpos);
            INC(i);
            IF kfpos>=st.Length(kf.name) THEN
              i:=5;
            ELSE
              IF kf.name[kfpos]=" " THEN INC(kfpos); END;
            END;
          END;
        ELSE
          gadobj:=gmo.SetText(ac.GetString(ac.ThisIsADemo1),-1);
          gadobj:=gmo.SetText(ac.GetString(ac.ThisIsADemo2),-1);
        END;


(*        gadobj:=gmo.SetText(s.ADR("Diese Batatestversion ist nur für die"),-1);
        gadobj:=gmo.SetText(s.ADR("Proxity.Beta bestimmt und darf nicht"),-1);
        gadobj:=gmo.SetText(s.ADR("frei kopiert werden!"),-1);*)

        gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
        gmb.EndBox;
        gadobj.SetSizeY(1);
      gmb.EndBox;
      gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
        gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
        gmb.EndBox;
        gadobj.SetSizeY(1);
        gadobj:=gmb.NewBox(gmb.vertBox,gd.bbftButton,TRUE,NIL);
          analysisgad:=gmo.SetImageGadget(144,100,2,im.analysisimg,im.analysisimg,FALSE);
        gmb.EndBox;
        gadobj:=gmb.NewBox(gmb.vertBox,gmb.noBorder,FALSE,NIL);
        gmb.EndBox;
        gadobj.SetSizeY(1);
      gmb.EndBox;
    gmb.EndBox;
    okgad:=gmo.SetBooleanGadget(ac.GetString(ac.OK),FALSE);
  glist:=root.EndRoot();

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    LOOP
      class:=e.Wait(LONGSET{0..31});
      IF infotask#NIL THEN
        IF infotask.msgsig IN class THEN
          REPEAT
            msg:=infotask.ReceiveMsg();
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
                ELSE
                  msg.Reply;
                  EXIT;
                END;
              ELSIF msg.type=m.msgActivate THEN
                subwind.ToFront;
              END;
              msg.Reply;
            END;
          UNTIL msg=NIL;
        END;
      END;
  
      REPEAT
        root.GetIMes(mes);
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=okgad.gadget THEN
            EXIT;
          ELSE
            Buh;
          END;
        END;
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
END AnalayInfo;

PROCEDURE AnalayInfoTask*(infotask:bt.ANY):bt.ANY;

VAR bool : BOOLEAN;

BEGIN
  WITH infotask: m.Task DO
    infotask.InitCommunication;
    AnalayInfo(infotask);

    m.taskdata.maintask.RemTask(infotask);
    infotask.ReplyAllMessages;
    infotask.DestructCommunication;
    mem.NodeToGarbage(infotask);
    m.taskdata.maintask.FreeUser(infotask);
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END AnalayInfoTask;

BEGIN
  analayinfowind:=NIL;
  buhwind:=NIL;
END AnalayInfo.

