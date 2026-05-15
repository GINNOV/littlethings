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


MODULE Pointers;

IMPORT I : Intuition,
       g : Graphics,
       e : Exec,
       u : Utility,
       s : SYSTEM;

VAR wait : UNTRACED POINTER TO ARRAY 34 OF INTEGER;

PROCEDURE SetBusyPointer*(wind:I.WindowPtr);

BEGIN
  IF wind#NIL THEN
    IF I.int.libNode.version>=39 THEN
      I.SetWindowPointer(wind,I.waBusyPointer,I.LTRUE,
                              u.done);
    ELSE
      I.SetPointer(wind,wait^,16,17,-6,0);
    END;
  END;
END SetBusyPointer;

PROCEDURE ClearPointer*(wind:I.WindowPtr);

BEGIN
  IF wind#NIL THEN
    IF I.int.libNode.version>=39 THEN
      I.SetWindowPointer(wind,u.done);
    ELSE
      I.ClearPointer(wind);
    END;
  END;
END ClearPointer;

BEGIN
  wait:=e.AllocMem(34*s.SIZE(INTEGER),LONGSET{e.memClear,e.chip});

  wait[0]:=0000H;
  wait[2]:=0400H;
  wait[4]:=0000H;
  wait[6]:=0100H;
  wait[8]:=0000H;
  wait[10]:=07C0H;
  wait[12]:=1FF0H;
  wait[14]:=3FF8H;
  wait[16]:=3FF8H;
  wait[18]:=7FFCH;
  wait[20]:=7EFCH;
  wait[22]:=7FFCH;
  wait[24]:=3FF8H;
  wait[26]:=3FF8H;
  wait[28]:=1FF0H;
  wait[30]:=07C0H;
  wait[32]:=0000H;

  wait[1]:=0000H;
  wait[3]:=07C0H;
  wait[5]:=07C0H;
  wait[7]:=0380H;
  wait[9]:=07E0H;
  wait[11]:=1FF8H;
  wait[13]:=3FECH;
  wait[15]:=7FDEH;
  wait[17]:=7FBEH;
  wait[19]:=s.VAL(INTEGER,0FF7FH);
  wait[21]:=s.VAL(INTEGER,0FFFFH);
  wait[23]:=s.VAL(INTEGER,0FFFFH);
  wait[25]:=7FFEH;
  wait[27]:=7FFEH;
  wait[29]:=3FFCH;
  wait[31]:=1FF8H;
  wait[33]:=07E0H;
CLOSE
  e.FreeMem(wait,34*s.SIZE(INTEGER));
END Pointers.

