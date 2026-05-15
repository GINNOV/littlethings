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


MODULE Constants;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       gd : GadTools,
       c  : Conversions,
       tt : TextTools,
       ag : AmigaGuideTools,
       ag : AmigaGuideTools,
       wm : WindowManager,
       gmb: GuiManagerBasics,
       gmo: GuiManagerObjects,
       m  : Multitasking,
       mem: MemoryManager,
       gb : GeneralBasics,
       mg : MathGUI,
       bt : BasicTypes,
       ac : AnalayCatalog,
       NoGuruRq;

VAR changeconstantswind * : wm.Window;

PROCEDURE ChangeConstants*(changetask:m.Task):BOOLEAN;

VAR subwind   : wm.Window;
    wind      : I.WindowPtr;
    rast      : g.RastPortPtr;
    root      : gmb.Root;
    consttype : gmo.CycleGadget;
    constlv   : gmo.ListView;
    addconst,
    delconst,
    copyconst : gmo.BooleanGadget;
    gadobj    : gmb.Object;
    glist     : I.GadgetPtr;
    typearray : ARRAY 3 OF e.STRPTR;
    bool,ret  : BOOLEAN;

BEGIN
    NEW(mes);
    ret:=FALSE;
    IF changeconstantswind=NIL THEN
      changeconstantswind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.ChangeConstantsReq),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
    END;
    subwind:=changeconstantswind.InitSub(mg.screen);

    root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
      typearray[0]:=ac.GetString(ac.InternalConstants);
      typearray[1]:=ac.GetString(ac.TemporalConstants);
      typearray[2]:=NIL;
      consttype:=gmo.SetCycleGadget(NIL,s.ADR(typearray),0);
      gadobj:=gmb.NewBox(gmb.horizBox,gd.bbftButton,FALSE,NIL);
        gadobj:=gmo.SetText(ac.GetString(ac.Symbol),-1);
        gadobj.SetMinVisible(7);
        gadobj.SetSizeX(1);
        gadobj:=gmo.SetText(ac.GetString(ac.Value),-1);
        gadobj.SetMinVisible(15);
        gadobj.SetSizeX(1);
        gadobj:=gmo.SetText(ac.GetString(ac.Comment),-1);
        gadobj.SetMinVisible(20);
        gadobj.SetSizeX(4);
      gmb.EndBox;
      constlv:=gmo.SetListView(NIL,fb.objects,PrintConstant,0,FALSE,255);
      constlv.SetOutValues(0,0);
      addconst:=gmo.SetBooleanGadget(ac.NewConstant),FALSE);
      delconst:=gmo.SetBooleanGadget(ac.DelConstant),FALSE);
      copyconst:=gmo.SetBooleanGadget(ac.CopyConstant),TRUE);
    glist:=root.EndRoot();
  
    root.Init;

    wind:=subwind.Open(glist);
    IF wind#NIL THEN
      rast:=wind.rPort;
      root.Resize;

      GetResults;

      LOOP
        class:=e.Wait(LONGSET{0..31});
        IF changetaskobj.msgsig IN class THEN
          REPEAT
            msg:=changeobj.ReceiveMsg();
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
              ELSIF msg.type=m.msgNodeChanged THEN
              ELSIF msg.type=m.msgActivate THEN
                subwind.ToFront;
              END;
              msg.Reply;
            END;
          UNTIL msg=NIL;
        END;
        REPEAT
          root.GetIMes(mes);
          IF I.gadgetUp IN mes.class THEN
            IF mes.iAddress=root.ok THEN
              GetInput;
              ret:=TRUE;
              EXIT;
            ELSIF mes.iAddress=root.ca THEN
              ret:=FALSE;
              EXIT;
            ELSIF NOT(mes.iAddress=root.help) THEN
              GetInput;(* didchange:=TRUE;*)
            END;
          END;
          IF ((I.gadgetUp IN mes.class) AND (mes.iAddress=root.help)) THEN
            ag.ShowFile(ag.guidename,"changeconstants",wind);
          END;
        UNTIL mes.class=LONGSET{};
      END;
  
      subwind.Destruct;
    END;
    root.Destruct;
    DISPOSE(mes);
  ELSE END;
END ChangeConstants;

BEGIN
  changeconstantswind:=NIL;
END Constants.

