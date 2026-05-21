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


MODULE SettingsRequesters;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       gd : GadTools,
       c  : Conversions,
       tt : TextTools,
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

VAR prioritieswind * : wm.Window;

PROCEDURE ChangePriorities*(changetask:m.Task):BOOLEAN;

VAR subwind   : wm.SubWindow;
    wind      : I.WindowPtr;
    rast      : g.RastPortPtr;
    root      : gmb.Root;
    mainstr,
    layoutstr,
    windowstr,
    reqstr    : gmo.StringGadget;
    mainslide,
    layoutslide,
    windowslide,
    reqslide  : gmo.SliderGadget;
    gadobj    : gmb.Object;
    glist     : I.GadgetPtr;
    mes       : I.IntuiMessagePtr;
    msg       : m.Message;
    class     : LONGSET;
    long      : LONGINT;
    oldmainpri,
    oldwindowpri,
    oldlayoutpri,
    oldreqpri : SHORTINT;
    ret,bool,
    didchange : BOOLEAN;

PROCEDURE SetData;

VAR str : ARRAY 10 OF CHAR;

BEGIN
  bool:=c.IntToString(m.taskdata.mainpri,str,5); tt.Clear(str);
  mainstr.SetString(str);
  mainslide.SetValue(m.taskdata.mainpri);

  bool:=c.IntToString(m.taskdata.windowpri,str,5); tt.Clear(str);
  windowstr.SetString(str);
  windowslide.SetValue(m.taskdata.windowpri);

  bool:=c.IntToString(m.taskdata.layoutpri,str,5); tt.Clear(str);
  layoutstr.SetString(str);
  layoutslide.SetValue(m.taskdata.layoutpri);

  bool:=c.IntToString(m.taskdata.requesterpri,str,5); tt.Clear(str);
  reqstr.SetString(str);
  reqslide.SetValue(m.taskdata.requesterpri);
END SetData;

PROCEDURE GetStringInput;

VAR str  : ARRAY 10 OF CHAR;

BEGIN
  mainstr.GetString(str);
  bool:=c.StringToInt(str,long);
  mainslide.SetValue(long);
  m.taskdata.mainpri:=SHORT(SHORT(long));

  windowstr.GetString(str);
  bool:=c.StringToInt(str,long);
  windowslide.SetValue(long);
  m.taskdata.windowpri:=SHORT(SHORT(long));

  layoutstr.GetString(str);
  bool:=c.StringToInt(str,long);
  layoutslide.SetValue(long);
  m.taskdata.layoutpri:=SHORT(SHORT(long));

  reqstr.GetString(str);
  bool:=c.StringToInt(str,long);
  reqslide.SetValue(long);
  m.taskdata.requesterpri:=SHORT(SHORT(long));
END GetStringInput;

(*PROCEDURE GetSliderInput;

BEGIN
  long:=mainslide.GetValue();
  m.taskdata.mainpri:=SHORT(SHORT(long));

  long:=windowslide.GetValue();
  m.taskdata.windowpri:=SHORT(SHORT(long));

  long:=layoutslide.GetValue();
  m.taskdata.layoutpri:=SHORT(SHORT(long));

  long:=reqslide.GetValue();
  m.taskdata.requesterpri:=SHORT(SHORT(long));

  SetData;
END GetSliderInput;*)

PROCEDURE Backup;

BEGIN
  oldmainpri:=m.taskdata.mainpri;
  oldwindowpri:=m.taskdata.windowpri;
  oldlayoutpri:=m.taskdata.layoutpri;
  oldreqpri:=m.taskdata.requesterpri;
END Backup;

PROCEDURE Restore;

BEGIN
  m.taskdata.mainpri:=oldmainpri;
  m.taskdata.windowpri:=oldwindowpri;
  m.taskdata.layoutpri:=oldlayoutpri;
  m.taskdata.requesterpri:=oldreqpri;
END Restore;

BEGIN
  NEW(mes);
  ret:=FALSE;
  IF prioritieswind=NIL THEN
    prioritieswind:=wm.InitWindow(wm.centered,wm.centered,100,100,TRUE,ac.GetString(ac.SetPriorities),LONGSET{I.activate,I.windowDrag,I.windowDepth,I.reportMouse,I.windowSizing},gmb.stdIDCMP);
  END;
  subwind:=prioritieswind.InitSub(mg.screen);

  root:=gmb.SetRootBox(gmb.vertBox,gd.bbftButton,FALSE,NIL,LONGSET{gmb.okGad,gmb.helpGad,gmb.cancelGad},subwind);
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      mainstr:=gmo.SetStringGadget(s.ADR("Maintask"),5,gmo.integerType);
      mainstr.SetMinVisible(4);
      mainstr.SetSizeX(0);
      mainstr.SetMinMaxInt(-128,127);
      mainslide:=gmo.SetSliderGadget(-128,127,m.taskdata.mainpri,0,NIL);
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      windowstr:=gmo.SetStringGadget(s.ADR("Mathmode windows"),5,gmo.integerType);
      windowstr.SetMinVisible(4);
      windowstr.SetSizeX(0);
      windowstr.SetMinMaxInt(-128,127);
      windowslide:=gmo.SetSliderGadget(-128,127,m.taskdata.windowpri,0,NIL);
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      layoutstr:=gmo.SetStringGadget(ac.GetString(ac.LayoutMode),5,gmo.integerType);
      layoutstr.SetMinVisible(4);
      layoutstr.SetSizeX(0);
      layoutstr.SetMinMaxInt(-128,127);
      layoutslide:=gmo.SetSliderGadget(-128,127,m.taskdata.layoutpri,0,NIL);
    gmb.EndBox;
    gadobj:=gmb.NewBox(gmb.horizBox,gmb.noBorder,FALSE,NIL);
      reqstr:=gmo.SetStringGadget(s.ADR("Requesters"),5,gmo.integerType);
      reqstr.SetMinVisible(4);
      reqstr.SetSizeX(0);
      reqstr.SetMinMaxInt(-128,127);
      reqslide:=gmo.SetSliderGadget(-128,127,m.taskdata.requesterpri,0,NIL);
    gmb.EndBox;
    gmb.FillSpace;
    root.NewSameTextWidth;
      root.AddSameTextWidth(mainstr);
      root.AddSameTextWidth(windowstr);
      root.AddSameTextWidth(layoutstr);
      root.AddSameTextWidth(reqstr);
  glist:=root.EndRoot();

  root.Init;

  wind:=subwind.Open(glist);
  IF wind#NIL THEN
    rast:=wind.rPort;
    root.Resize;

    SetData;
    mainstr.Activate;
    Backup;

    didchange:=FALSE;
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
                mainstr.Activate;
              ELSE
                msg.Reply;
                EXIT;
              END;
            ELSIF msg.type=m.msgNodeChanged THEN
              SetData;
            ELSIF msg.type=m.msgActivate THEN
              subwind.ToFront;
            ELSIF msg.type=m.msgNewPriority THEN
              changetask.SetPriority(m.taskdata.requesterpri);
            END;
            msg.Reply;
          END;
        UNTIL msg=NIL;
      END;
      REPEAT
        root.GetIMes(mes);
        IF I.gadgetUp IN mes.class THEN
          IF mes.iAddress=root.ok THEN
            GetStringInput;
            m.taskdata.maintask.SendNewMsg(m.msgNewPriority,NIL);
            ret:=TRUE;
            EXIT;
          ELSIF mes.iAddress=root.ca THEN
            Restore;

            IF didchange THEN
              m.taskdata.maintask.SendNewMsg(m.msgNewPriority,NIL);
            END;
            ret:=FALSE;
            EXIT;
          ELSIF mes.iAddress=mainslide.gadget THEN
            long:=mainslide.GetValue();
            m.taskdata.mainpri:=SHORT(SHORT(long));
            SetData;
          ELSIF mes.iAddress=windowslide.gadget THEN
            long:=windowslide.GetValue();
            m.taskdata.windowpri:=SHORT(SHORT(long));
            SetData;
          ELSIF mes.iAddress=layoutslide.gadget THEN
            long:=layoutslide.GetValue();
            m.taskdata.layoutpri:=SHORT(SHORT(long));
            SetData;
          ELSIF mes.iAddress=reqslide.gadget THEN
            long:=reqslide.GetValue();
            m.taskdata.requesterpri:=SHORT(SHORT(long));
            SetData;
          ELSIF NOT(mes.iAddress=root.help) THEN
            GetStringInput; didchange:=TRUE;
            m.taskdata.maintask.SendNewMsg(m.msgNewPriority,NIL);
          END;
        END;
        IF ((I.gadgetUp IN mes.class) AND (mes.iAddress=root.help)) THEN
          ag.ShowFile(ag.guidename,"changepriorities",wind);
        END;
      UNTIL mes.class=LONGSET{};
    END;

    subwind.Destruct;
  END;
  root.Destruct;
  DISPOSE(mes);
  RETURN ret;
END ChangePriorities;

PROCEDURE ChangePrioritiesTask*(changetask:bt.ANY):bt.ANY;

VAR bool : BOOLEAN;

BEGIN
  WITH changetask: m.Task DO
    changetask.InitCommunication;
    bool:=ChangePriorities(changetask);

    m.taskdata.maintask.RemTask(changetask);
    changetask.ReplyAllMessages;
    changetask.DestructCommunication;
    mem.NodeToGarbage(changetask);
    m.taskdata.maintask.FreeUser(changetask);
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END ChangePrioritiesTask;



BEGIN
  prioritieswind:=NIL;
END SettingsRequesters.

