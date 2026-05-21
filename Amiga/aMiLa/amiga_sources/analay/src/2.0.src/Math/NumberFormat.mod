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


MODULE NumberFormat;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       st : Strings,
       lrc: LongRealConversions,
       ft : FunctionTrees,
       tt :TextTools,
       NoGuruRq;

TYPE NumberFormat * = POINTER TO NumberFormatDesc;
     NumberFormatDesc * = RECORD
       digitsafterpoint * : INTEGER;
       decimalpoint     * : CHAR;
       exponent         * : BOOLEAN;
     END;

VAR stdformat * : NumberFormat;

PROCEDURE (numberformat:NumberFormat) Init*;

BEGIN
  numberformat.digitsafterpoint:=stdformat.digitsafterpoint;
  numberformat.decimalpoint:=stdformat.decimalpoint;
  numberformat.exponent:=stdformat.exponent;
END Init;

PROCEDURE (numberformat:NumberFormat) Destruct*;

BEGIN
  DISPOSE(numberformat);
END Destruct;

PROCEDURE (numberformat:NumberFormat) RealToString*(real:LONGREAL;VAR str:ARRAY OF CHAR):BOOLEAN;

VAR i    : INTEGER;
    bool : BOOLEAN;

BEGIN
  bool:=lrc.RealToString(real,str,10,numberformat.digitsafterpoint,numberformat.exponent);
  IF bool THEN
    tt.Clear(str);
    i:=0;
    WHILE i<st.Length(str) DO
      IF str[i]="." THEN
        str[i]:=numberformat.decimalpoint;
      END;
      INC(i);
    END;
  END;
  RETURN bool;
END RealToString;

PROCEDURE (numberformat:NumberFormat) StringToReal*(str:ARRAY OF CHAR):LONGREAL;

VAR real : LONGREAL;
    i    : INTEGER;

BEGIN
  i:=0;
  WHILE i<st.Length(str) DO
    IF str[i]="." THEN
      str[i]:=numberformat.decimalpoint;
    END;
    INC(i);
  END;
  real:=ft.ExpressionToReal(str);
  RETURN real;
END StringToReal;

PROCEDURE (numberformat:NumberFormat) ParseString*(VAR str:ARRAY OF CHAR;xcoord,ycoord,zcoord:LONGREAL);

VAR realstr,
    xstr,ystr,zstr : ARRAY 80 OF CHAR;
    pos            : LONGINT;
    bool           : BOOLEAN;

BEGIN
  bool:=numberformat.RealToString(xcoord,xstr);
  bool:=numberformat.RealToString(ycoord,ystr);
  bool:=numberformat.RealToString(zcoord,zstr);
  pos:=0;
  WHILE pos<st.Length(str) DO
    IF (str[pos]="\\") OR ((str[pos]="$") & ((CAP(str[pos+1])="X") OR (CAP(str[pos+1])="Y") OR (CAP(str[pos+1])="Z") OR (str[pos+1]="$"))) THEN
      CASE CAP(str[pos+1]) OF
      | "X" : st.Delete(str,pos,2);
              st.Insert(str,pos,xstr);
              INC(pos,st.Length(xstr)-1);
      | "Y" : st.Delete(str,pos,2);
              st.Insert(str,pos,ystr);
              INC(pos,st.Length(ystr)-1);
      | "Z" : st.Delete(str,pos,2);
              st.Insert(str,pos,zstr);
              INC(pos,st.Length(zstr)-1);
      | "$", "\\": st.Delete(str,pos,1);
      ELSE
      END;
    END;
    INC(pos);
  END;
END ParseString;

(*PROCEDURE (format:NumberFormat) Change*():BOOLEAN;

VAR subwind   : wm.SubWindow;
    wind      : I.WindowPtr;
    rast      : g.RastPortPtr;
    root      : gmb.Root;
    gadobj    : gmb.Object;
    glist     : I.GadgetPtr;
    expgad,
    nachgad,
    nachstr : I.GadgetPtr;
    string  : ARRAY 10 OF CHAR;
    class   : LONGSET;
    code    : INTEGER;
    address : s.ADDRESS;
    old     : INTEGER;
    long    : LONGINT;
    ret     : BOOLEAN;
    oldnach : INTEGER;
    oldexp  : BOOLEAN;

BEGIN
  ret:=FALSE;
  IF formatId=-1 THEN
    formatId:=wm.InitWindow(20,20,232,80,ac.GetString(ac.NumberFormat),LONGSET{I.activate,I.windowDrag,I.windowDepth},LONGSET{I.menuPick,I.rawKey,I.gadgetDown,I.gadgetUp,I.mouseButtons,I.intuiTicks},s1.screen,FALSE);
  END;
  gm.StartGadgets(s1.window);
  ok:=gm.SetBooleanGadget(14,59,100,14,ac.GetString(ac.OK));
  ca:=gm.SetBooleanGadget(118,59,100,14,ac.GetString(ac.Cancel));
  expgad:=gm.SetCheckBoxGadget(186,18,26,9,exp);
  nachstr:=gm.SetStringGadget(20,40,16,14,2);
  nachgad:=gm.SetPropGadget(52,41,160,12,0,0,32767,0);
  gm.EndGadgets;
  wm.SetGadgets(formatId,ok);
  wm.ChangeScreen(formatId,s1.screen);
  wind:=wm.OpenWindow(formatId);
  IF wind#NIL THEN
    rast:=wind.rPort;
(*    ig.SetPlastHighGadget(ok,wind,s.ADR("OK"),12,58,100,
                      SET{I.gadgImmediate,I.relVerify});
    ig.SetPlastHighGadget(ca,wind,s.ADR("Abbrechen"),116,58,100,
                      SET{I.gadgImmediate,I.relVerify});*)

    gm.DrawPropBorders(wind);

    it.DrawBorder(rast,14,16,204,40);

    g.SetAPen(rast,2);
    tt.Print(20,26,ac.GetString(ac.Exponent),rast);
(*    ig.SetCheckBoxGadget(expgad,wind,186,18,
                      SET{I.gadgImmediate,I.relVerify,I.toggleSelect});
    ig.SetPlastStringGadget(nachstr,wind,16,2,20,40,FALSE);
    ig.SetPlastProp(nachgad,SET{I.autoKnob,I.freeHoriz,I.knobHit},54,42,156,8,
                    0,4096,wind);*)
    tt.Print(20,37,ac.GetString(ac.DecimalPlaces),rast);
    tt.PrintInt(288,49,nach,2,rast);

    bool:=c.IntToString(nach,string,1);
    tt.Clear(string);
    gm.PutGadgetText(nachstr,string);
    I.RefreshGList(nachstr,wind,NIL,1);
    bool:=I.ActivateGadget(nachstr^,wind,NIL);
    gm.SetSlider(nachgad,wind,0,8,nach);
(*    IF exp THEN
      gm.ActivateBool(expgad,wind);
    END;*)
    oldnach:=nach;
    oldexp:=exp;

    LOOP
      e.WaitPort(wind.userPort);
      it.GetIMes(wind,class,code,address);
      old:=nach;
      nach:=gm.GetSlider(nachgad,0,8);
      IF old#nach THEN
        bool:=c.IntToString(nach,string,1);
        tt.Clear(string);
        gm.PutGadgetText(nachstr,string);
        I.RefreshGList(nachstr,wind,NIL,1);
        bool:=I.ActivateGadget(nachstr^,wind,NIL);
      END;
      IF I.gadgetUp IN class THEN
        IF address=ok THEN
          gm.GetGadgetText(nachstr,string);
          bool:=c.StringToInt(string,long);
          nach:=SHORT(long);
          ret:=TRUE;
          EXIT;
        ELSIF address=ca THEN
          nach:=oldnach;
          exp:=oldexp;
          EXIT;
        ELSIF address=nachstr THEN
          gm.GetGadgetText(nachstr,string);
          bool:=c.StringToInt(string,long);
          nach:=SHORT(long);
          IF nach<0 THEN
            nach:=0;
            bool:=c.IntToString(nach,string,1);
            tt.Clear(string);
            gm.PutGadgetText(nachstr,string);
            I.RefreshGList(nachstr,wind,NIL,1);
          ELSIF nach>8 THEN
            nach:=8;
            bool:=c.IntToString(nach,string,1);
            tt.Clear(string);
            gm.PutGadgetText(nachstr,string);
            I.RefreshGList(nachstr,wind,NIL,1);
          END;
          gm.SetSlider(nachgad,wind,0,8,nach);
          bool:=I.ActivateGadget(nachstr^,wind,NIL);
        ELSIF address=expgad THEN
          exp:=NOT(exp);
        END;
      END;
      IF ((I.gadgetUp IN class) AND (address=help)) OR ((I.rawKey IN class) AND (code=95)) THEN
        ag.ShowFile(s1.analaydoc,"numberformatreq",wind);
      END;
    END;

(*    ig.FreePlastPropGadget(nachgad,wind);
    ig.FreeStringGadget(nachstr,wind);
    ig.FreePlastCheckBoxGadget(expgad,wind);
    ig.FreePlastHighBooleanGadget(ca,wind);
    ig.FreePlastHighBooleanGadget(ok,wind);*)
    wm.CloseWindow(formatId);
  END;
  wm.FreeGadgets(formatId);
  RETURN ret;
END NumberFormat;*)

BEGIN
  NEW(stdformat);
  IF stdformat=NIL THEN HALT(20); END;
  stdformat.digitsafterpoint:=7;
  stdformat.decimalpoint:=".";
  stdformat.exponent:=FALSE;
CLOSE
  IF stdformat#NIL THEN stdformat.Destruct; END;
END NumberFormat.

