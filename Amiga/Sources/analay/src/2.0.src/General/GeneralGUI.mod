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


MODULE GeneralGUI;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       a  : ASL,
       at : AslTools,
       m  : Multitasking,
       mm : MemoryManager,
       ac : AnalayCatalog,
       bt : BasicTypes,
       io,
       NoGuruRq;

TYPE ScreenMode * = POINTER TO ScreenModeDesc;
     ScreenModeDesc * = RECORD(bt.ANYDesc)
       displayId * ,
       width     * ,
       height    * : LONGINT;
       depth     * : INTEGER;
       oscan     * : INTEGER;
       autoscroll* : I.LONGBOOL;
       colormap  * : ARRAY 16 OF ARRAY 3 OF INTEGER;
       reserved  * : INTEGER;
       usewbscreen*,
       clonewb   * : BOOLEAN;
       reqwindow * : I.WindowPtr; (* The change requester will open on this window's screen. *)
     END;

PROCEDURE (scrmode:ScreenMode) Change37*(scrmodetask:m.Task):BOOLEAN;

BEGIN

END Change37;

PROCEDURE (scrmode:ScreenMode) Change*(scrmodetask:m.Task):BOOLEAN;

VAR moderequest : a.ScreenModeRequesterPtr;
    bool,ret    : BOOLEAN;

BEGIN
  moderequest:=NIL;
  ret:=at.ScreenModeRequest(moderequest,ac.GetString(ac.ScreenResolution),scrmode.reqwindow,scrmode.displayId,scrmode.width,scrmode.height,scrmode.depth,scrmode.oscan,bool);
  IF ret THEN
    IF bool THEN scrmode.autoscroll:=I.LTRUE
            ELSE scrmode.autoscroll:=I.LFALSE; END;
    scrmode.clonewb:=FALSE;
    io.WriteString("GGWidth: "); io.WriteInt(scrmode.width,7); io.WriteLn;
    io.WriteString("GGHeight: "); io.WriteInt(scrmode.height,7); io.WriteLn;
    io.WriteString("GGDepth: "); io.WriteInt(scrmode.depth,7); io.WriteLn;

    m.taskdata.maintask.SendNewMsg(m.msgNewScreenMode,NIL);
  END;
  RETURN ret;
END Change;

PROCEDURE ChangeScreenModeTask*(scrmodetask:bt.ANY):bt.ANY;

VAR data : ScreenMode;
    bool : BOOLEAN;

BEGIN
  WITH scrmodetask: m.Task DO
    scrmodetask.InitCommunication;
    data:=scrmodetask.data(ScreenMode);
    bool:=data.Change(scrmodetask);

    m.taskdata.maintask.RemTask(scrmodetask);
    scrmodetask.ReplyAllMessages;
    scrmodetask.DestructCommunication;
    mm.NodeToGarbage(scrmodetask);
    m.taskdata.maintask.FreeUser(scrmodetask);
  END;
  IF bool THEN
    RETURN s.VAL(bt.ANY,I.LTRUE);
  ELSE
    RETURN NIL;
  END;
END ChangeScreenModeTask;

END GeneralGUI.

