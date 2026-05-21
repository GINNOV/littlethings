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


MODULE OldGadgets;

IMPORT I : Intuition,
       g : Graphics,
       e : Exec,
       s : SYSTEM,
       st: Strings;

(* $TypeChk- $NilChk- $RangeChk- $OvflChk- *)

CONST stdFlags      = SET{I.gadgHImage};
      stdActivation = SET{I.relVerify,I.gadgImmediate};

VAR topaz        : g.TextAttrPtr;
    checkbord,
    checkselbord,
    upbord,
    upselbord,
    downbord,
    downselbord,
    upwidebord,
    upwideselbord,
    downwidebord,
    downwideselbord,
    leftwidebord,
    leftwideselbord,
    rightwidebord,
    rightwideselbord,
    radiobord,
    radioselbord : s.ADDRESS;
    farben       : UNTRACED POINTER TO ARRAY 160 OF LONGSET;
    a,b          : INTEGER;

PROCEDURE AllocBooleanBorder(bitwidth:INTEGER):e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 48 OF INTEGER;

BEGIN
     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*48,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=2;      dat3^[1]:=1;
     dat3^[2]:=bitwidth-3;dat3^[3]:=1;
     dat3^[4]:=bitwidth-3;dat3^[5]:=2;
     dat3^[6]:=2;      dat3^[7]:=2;
     dat3^[8]:=2;      dat3^[9]:=3;
     dat3^[10]:=bitwidth-3;dat3^[11]:=3;
     dat3^[12]:=bitwidth-3;dat3^[13]:=4;
     dat3^[14]:=2;      dat3^[15]:=4;
     dat3^[16]:=2;      dat3^[17]:=5;
     dat3^[18]:=bitwidth-3;dat3^[19]:=5;
     dat3^[20]:=bitwidth-3;dat3^[21]:=6;
     dat3^[22]:=2;      dat3^[23]:=6;
     dat3^[24]:=2;      dat3^[25]:=7;
     dat3^[26]:=bitwidth-3;dat3^[27]:=7;
     dat3^[28]:=bitwidth-3;dat3^[29]:=8;
     dat3^[30]:=2;      dat3^[31]:=8;
     dat3^[32]:=2;      dat3^[33]:=9;
     dat3^[34]:=bitwidth-3;dat3^[35]:=9;
     dat3^[36]:=bitwidth-3;dat3^[37]:=10;
     dat3^[38]:=2;      dat3^[39]:=10;
     dat3^[40]:=2;      dat3^[41]:=11;
     dat3^[42]:=bitwidth-3;dat3^[43]:=11;
     dat3^[44]:=bitwidth-3;dat3^[45]:=12;
     dat3^[46]:=2;      dat3^[47]:=12;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 0;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 24;
         bord3.xy       := dat3;

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=0;
     dat2^[2]:=0;      dat2^[3]:=14-1;
     dat2^[4]:=1;      dat2^[5]:=14-2;
     dat2^[6]:=1;      dat2^[7]:=0;
     dat2^[8]:=bitwidth-2;      dat2^[9]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 5;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=bitwidth-1;      dat^[1]:=14-1;
     dat^[2]:=bitwidth-1;dat^[3]:=0;
     dat^[4]:=bitwidth-2;dat^[5]:=1;
     dat^[6]:=bitwidth-2;dat^[7]:=14-1;
     dat^[8]:=1;      dat^[9]:=14-1;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 5;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocBooleanBorder;

PROCEDURE AllocInBooleanBorder(bitwidth:INTEGER):e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 48 OF INTEGER;

BEGIN
  bord:=AllocBooleanBorder(bitwidth);
  bord.frontPen:=2;
  bord.nextBorder.frontPen:=1;
  bord.nextBorder.nextBorder.frontPen:=3;
(*     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*48,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=2;      dat3^[1]:=1;
     dat3^[2]:=bitwidth-3;dat3^[3]:=1;
     dat3^[4]:=bitwidth-3;dat3^[5]:=2;
     dat3^[6]:=2;      dat3^[7]:=2;
     dat3^[8]:=2;      dat3^[9]:=3;
     dat3^[10]:=bitwidth-3;dat3^[11]:=3;
     dat3^[12]:=bitwidth-3;dat3^[13]:=4;
     dat3^[14]:=2;      dat3^[15]:=4;
     dat3^[16]:=2;      dat3^[17]:=5;
     dat3^[18]:=bitwidth-3;dat3^[19]:=5;
     dat3^[20]:=bitwidth-3;dat3^[21]:=6;
     dat3^[22]:=2;      dat3^[23]:=6;
     dat3^[24]:=2;      dat3^[25]:=7;
     dat3^[26]:=bitwidth-3;dat3^[27]:=7;
     dat3^[28]:=bitwidth-3;dat3^[29]:=8;
     dat3^[30]:=2;      dat3^[31]:=8;
     dat3^[32]:=2;      dat3^[33]:=9;
     dat3^[34]:=bitwidth-3;dat3^[35]:=9;
     dat3^[36]:=bitwidth-3;dat3^[37]:=10;
     dat3^[38]:=2;      dat3^[39]:=10;
     dat3^[40]:=2;      dat3^[41]:=11;
     dat3^[42]:=bitwidth-3;dat3^[43]:=11;
     dat3^[44]:=bitwidth-3;dat3^[45]:=12;
     dat3^[46]:=2;      dat3^[47]:=12;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 3;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 24;
         bord3.xy       := dat3;

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=0;
     dat2^[2]:=0;      dat2^[3]:=14-1;
     dat2^[4]:=1;      dat2^[5]:=14-2;
     dat2^[6]:=1;      dat2^[7]:=0;
     dat2^[8]:=bitwidth-2;      dat2^[9]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 1;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 5;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=bitwidth-1;      dat^[1]:=14-1;
     dat^[2]:=bitwidth-1;dat^[3]:=0;
     dat^[4]:=bitwidth-2;dat^[5]:=1;
     dat^[6]:=bitwidth-2;dat^[7]:=14-1;
     dat^[8]:=0;      dat^[9]:=14-1;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 2;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 5;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);*)


    RETURN bord;
END AllocInBooleanBorder;

PROCEDURE AllocStringBorder(bitwidth,he:INTEGER):e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 22 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 22 OF INTEGER;

BEGIN
     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*22,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=-5;      dat2^[1]:=-2;
     dat2^[2]:=-5;      dat2^[3]:=he+3;
     dat2^[4]:=-4;      dat2^[5]:=he+2;
     dat2^[6]:=-4;      dat2^[7]:=-2;
     dat2^[8]:=bitwidth+5;      dat2^[9]:=-2;
     dat2^[10]:=bitwidth+4;      dat2^[11]:=-2;
     dat2^[12]:=bitwidth+4;      dat2^[13]:=he+2;
     dat2^[14]:=bitwidth+3;      dat2^[15]:=he+2;
     dat2^[16]:=bitwidth+3;      dat2^[17]:=0;
     dat2^[18]:=bitwidth+3;      dat2^[19]:=he+2;
     dat2^[20]:=-2;      dat2^[21]:=he+2;

         bord2.leftEdge :=-1;
         bord2.topEdge  :=-1;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 11;
         bord2.xy       := dat2;


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*22,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=bitwidth+6;      dat^[1]:=he+3;
     dat^[2]:=bitwidth+6;dat^[3]:=-2;
     dat^[4]:=bitwidth+5;dat^[5]:=-1;
     dat^[6]:=bitwidth+5;dat^[7]:=he+3;
     dat^[8]:=-4;      dat^[9]:=he+3;
     dat^[10]:=-3;      dat^[11]:=he+3;
     dat^[12]:=-3;      dat^[13]:=-1;
     dat^[14]:=-2;      dat^[15]:=-1;
     dat^[16]:=-2;      dat^[17]:=he+1;
     dat^[18]:=-2;      dat^[19]:=-1;
     dat^[20]:=bitwidth+3;      dat^[21]:=-1;

         bord.leftEdge :=-1;
         bord.topEdge  :=-1;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 11;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocStringBorder;

PROCEDURE AllocPropBorder(bitwidth,height:INTEGER):e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 10 OF INTEGER;

BEGIN
  INC(bitwidth,8);
  INC(height,4);
     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=0;
     dat2^[2]:=0;      dat2^[3]:=height-1;
     dat2^[4]:=1;      dat2^[5]:=height-2;
     dat2^[6]:=1;      dat2^[7]:=0;
     dat2^[8]:=bitwidth-2;      dat2^[9]:=0;

         bord2.leftEdge :=-4;
         bord2.topEdge  :=-2;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 5;
         bord2.xy       := dat2;
         bord2.nextBorder:=NIL;


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=bitwidth-1;      dat^[1]:=height-1;
     dat^[2]:=bitwidth-1;dat^[3]:=0;
     dat^[4]:=bitwidth-2;dat^[5]:=1;
     dat^[6]:=bitwidth-2;dat^[7]:=height-1;
     dat^[8]:=1;      dat^[9]:=height-1;

         bord.leftEdge :=-4;
         bord.topEdge  :=-2;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 5;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocPropBorder;

PROCEDURE AllocCheckBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 42 OF INTEGER;

BEGIN
     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*42,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=7;      dat3^[1]:=5;
     dat3^[2]:=9;      dat3^[3]:=5;
     dat3^[4]:=8;      dat3^[5]:=6;
     dat3^[6]:=10;      dat3^[7]:=6;
     dat3^[8]:=9;      dat3^[9]:=7;
     dat3^[10]:=12;      dat3^[11]:=7;
     dat3^[12]:=10;      dat3^[13]:=7;
     dat3^[14]:=10;      dat3^[15]:=8;
     dat3^[16]:=12;      dat3^[17]:=8;
     dat3^[18]:=12;      dat3^[19]:=7;
     dat3^[20]:=13;      dat3^[21]:=7;
     dat3^[22]:=13;      dat3^[23]:=6;
     dat3^[24]:=14;      dat3^[25]:=6;
     dat3^[26]:=14;      dat3^[27]:=5;
     dat3^[28]:=15;      dat3^[29]:=5;
     dat3^[30]:=15;      dat3^[31]:=4;
     dat3^[32]:=16;      dat3^[33]:=4;
     dat3^[34]:=16;      dat3^[35]:=3;
     dat3^[36]:=17;      dat3^[37]:=3;
     dat3^[38]:=17;      dat3^[39]:=2;
     dat3^[40]:=19;      dat3^[41]:=2;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 0;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 21;
         bord3.xy       := dat3;

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=0;
     dat2^[2]:=0;      dat2^[3]:=7+3;
     dat2^[4]:=1;      dat2^[5]:=7+2;
     dat2^[6]:=1;      dat2^[7]:=0;
     dat2^[8]:=22+2;      dat2^[9]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 5;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=22+3;      dat^[1]:=7+3;
     dat^[2]:=22+3;dat^[3]:=0;
     dat^[4]:=22+2;dat^[5]:=1;
     dat^[6]:=22+2;dat^[7]:=7+3;
     dat^[8]:=1;      dat^[9]:=7+3;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 5;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocCheckBorder;

PROCEDURE AllocCheckSelBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 42 OF INTEGER;

BEGIN
  bord:=AllocCheckBorder();
  bord.frontPen:=1;
  bord.nextBorder.frontPen:=2;
  bord.nextBorder.nextBorder.frontPen:=1;
(*     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*42,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=7;      dat3^[1]:=5;
     dat3^[2]:=9;      dat3^[3]:=5;
     dat3^[4]:=8;      dat3^[5]:=6;
     dat3^[6]:=10;      dat3^[7]:=6;
     dat3^[8]:=9;      dat3^[9]:=7;
     dat3^[10]:=12;      dat3^[11]:=7;
     dat3^[12]:=10;      dat3^[13]:=7;
     dat3^[14]:=10;      dat3^[15]:=8;
     dat3^[16]:=12;      dat3^[17]:=8;
     dat3^[18]:=12;      dat3^[19]:=7;
     dat3^[20]:=13;      dat3^[21]:=7;
     dat3^[22]:=13;      dat3^[23]:=6;
     dat3^[24]:=14;      dat3^[25]:=6;
     dat3^[26]:=14;      dat3^[27]:=5;
     dat3^[28]:=15;      dat3^[29]:=5;
     dat3^[30]:=15;      dat3^[31]:=4;
     dat3^[32]:=16;      dat3^[33]:=4;
     dat3^[34]:=16;      dat3^[35]:=3;
     dat3^[36]:=17;      dat3^[37]:=3;
     dat3^[38]:=17;      dat3^[39]:=2;
     dat3^[40]:=19;      dat3^[41]:=2;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 1;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 21;
         bord3.xy       := dat3;

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=0;
     dat2^[2]:=0;      dat2^[3]:=7+3;
     dat2^[4]:=1;      dat2^[5]:=7+2;
     dat2^[6]:=1;      dat2^[7]:=0;
     dat2^[8]:=22+2;      dat2^[9]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 5;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=22+3;      dat^[1]:=7+3;
     dat^[2]:=22+3;dat^[3]:=0;
     dat^[4]:=22+2;dat^[5]:=1;
     dat^[6]:=22+2;dat^[7]:=7+3;
     dat^[8]:=1;      dat^[9]:=7+3;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 5;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);*)

    RETURN bord;
END AllocCheckSelBorder;

PROCEDURE AllocArrowUpBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 28 OF INTEGER;
bord4: UNTRACED POINTER TO I.Border;
dat4 : UNTRACED POINTER TO ARRAY 36 OF INTEGER;

BEGIN

     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*28,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=4;      dat3^[1]:=7;
     dat3^[2]:=5;      dat3^[3]:=7;
     dat3^[4]:=5;      dat3^[5]:=5;
     dat3^[6]:=6;      dat3^[7]:=6;
     dat3^[8]:=6;      dat3^[9]:=3;
     dat3^[10]:=7;      dat3^[11]:=4;
     dat3^[12]:=7;      dat3^[13]:=2;
     dat3^[14]:=8;      dat3^[15]:=2;
     dat3^[16]:=8;      dat3^[17]:=4;
     dat3^[18]:=9;      dat3^[19]:=3;
     dat3^[20]:=9;      dat3^[21]:=6;
     dat3^[22]:=10;      dat3^[23]:=5;
     dat3^[24]:=10;      dat3^[25]:=7;
     dat3^[26]:=11;      dat3^[27]:=7;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 1;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 14;
         bord3.xy       := dat3;

     bord4:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat4:=e.AllocMem(s.SIZE(INTEGER)*36,LONGSET{e.memClear});
(*     NEW(bord4);
     NEW(dat4);*)
     dat4^[0]:=2;      dat4^[1]:=1;
     dat4^[2]:=13;      dat4^[3]:=1;
     dat4^[4]:=13;      dat4^[5]:=2;
     dat4^[6]:=2;      dat4^[7]:=2;
     dat4^[8]:=2;      dat4^[9]:=3;
     dat4^[10]:=13;      dat4^[11]:=3;
     dat4^[12]:=13;      dat4^[13]:=4;
     dat4^[14]:=2;      dat4^[15]:=4;
     dat4^[16]:=2;      dat4^[17]:=5;
     dat4^[18]:=13;      dat4^[19]:=5;
     dat4^[20]:=13;      dat4^[21]:=6;
     dat4^[22]:=2;      dat4^[23]:=6;
     dat4^[24]:=2;      dat4^[25]:=7;
     dat4^[26]:=13;      dat4^[27]:=7;
     dat4^[28]:=13;      dat4^[29]:=8;
     dat4^[30]:=2;      dat4^[31]:=8;

         bord4.leftEdge :=0;
         bord4.topEdge  :=0;
         bord4.frontPen := 0;
         bord4.backPen  := 0;
         bord4.drawMode := g.jam1;
         bord4.count    := 16;
         bord4.xy       := dat4;
         bord4.nextBorder:=s.VAL(e.APTR,bord3);

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=0;
     dat2^[2]:=0;      dat2^[3]:=6+3;
     dat2^[4]:=1;      dat2^[5]:=6+2;
     dat2^[6]:=1;      dat2^[7]:=0;
     dat2^[8]:=12+2;      dat2^[9]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 5;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord4);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=12+3;      dat^[1]:=6+3;
     dat^[2]:=12+3;dat^[3]:=0;
     dat^[4]:=12+2;dat^[5]:=1;
     dat^[6]:=12+2;dat^[7]:=6+3;
     dat^[8]:=1;      dat^[9]:=6+3;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 5;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocArrowUpBorder;

PROCEDURE AllocArrowUpSelBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 28 OF INTEGER;
bord4: UNTRACED POINTER TO I.Border;
dat4 : UNTRACED POINTER TO ARRAY 36 OF INTEGER;

BEGIN
  bord:=AllocArrowUpBorder();
  bord.frontPen:=2;
  bord.nextBorder.frontPen:=1;
  bord.nextBorder.nextBorder.frontPen:=3;
  bord.nextBorder.nextBorder.nextBorder.frontPen:=1;

(*     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*28,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=4;      dat3^[1]:=7;
     dat3^[2]:=5;      dat3^[3]:=7;
     dat3^[4]:=5;      dat3^[5]:=5;
     dat3^[6]:=6;      dat3^[7]:=6;
     dat3^[8]:=6;      dat3^[9]:=3;
     dat3^[10]:=7;      dat3^[11]:=4;
     dat3^[12]:=7;      dat3^[13]:=2;
     dat3^[14]:=8;      dat3^[15]:=2;
     dat3^[16]:=8;      dat3^[17]:=4;
     dat3^[18]:=9;      dat3^[19]:=3;
     dat3^[20]:=9;      dat3^[21]:=6;
     dat3^[22]:=10;      dat3^[23]:=5;
     dat3^[24]:=10;      dat3^[25]:=7;
     dat3^[26]:=11;      dat3^[27]:=7;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 1;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 14;
         bord3.xy       := dat3;

     bord4:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat4:=e.AllocMem(s.SIZE(INTEGER)*36,LONGSET{e.memClear});
(*     NEW(bord4);
     NEW(dat4);*)
     dat4^[0]:=2;      dat4^[1]:=1;
     dat4^[2]:=13;      dat4^[3]:=1;
     dat4^[4]:=13;      dat4^[5]:=2;
     dat4^[6]:=2;      dat4^[7]:=2;
     dat4^[8]:=2;      dat4^[9]:=3;
     dat4^[10]:=13;      dat4^[11]:=3;
     dat4^[12]:=13;      dat4^[13]:=4;
     dat4^[14]:=2;      dat4^[15]:=4;
     dat4^[16]:=2;      dat4^[17]:=5;
     dat4^[18]:=13;      dat4^[19]:=5;
     dat4^[20]:=13;      dat4^[21]:=6;
     dat4^[22]:=2;      dat4^[23]:=6;
     dat4^[24]:=2;      dat4^[25]:=7;
     dat4^[26]:=13;      dat4^[27]:=7;
     dat4^[28]:=13;      dat4^[29]:=8;
     dat4^[30]:=2;      dat4^[31]:=8;

         bord4.leftEdge :=0;
         bord4.topEdge  :=0;
         bord4.frontPen := 3;
         bord4.backPen  := 0;
         bord4.drawMode := g.jam1;
         bord4.count    := 16;
         bord4.xy       := dat4;
         bord4.nextBorder:=s.VAL(e.APTR,bord3);

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=0;
     dat2^[2]:=0;      dat2^[3]:=6+3;
     dat2^[4]:=1;      dat2^[5]:=6+2;
     dat2^[6]:=1;      dat2^[7]:=0;
     dat2^[8]:=12+2;      dat2^[9]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 1;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 5;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord4);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=12+3;      dat^[1]:=6+3;
     dat^[2]:=12+3;dat^[3]:=0;
     dat^[4]:=12+2;dat^[5]:=1;
     dat^[6]:=12+2;dat^[7]:=6+3;
     dat^[8]:=1;      dat^[9]:=6+3;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 2;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 5;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);*)

    RETURN bord;
END AllocArrowUpSelBorder;

PROCEDURE AllocArrowDownBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 28 OF INTEGER;
bord4: UNTRACED POINTER TO I.Border;
dat4 : UNTRACED POINTER TO ARRAY 36 OF INTEGER;

BEGIN

     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*28,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=4;      dat3^[1]:=2;
     dat3^[2]:=5;      dat3^[3]:=2;
     dat3^[4]:=5;      dat3^[5]:=4;
     dat3^[6]:=6;      dat3^[7]:=3;
     dat3^[8]:=6;      dat3^[9]:=6;
     dat3^[10]:=7;      dat3^[11]:=5;
     dat3^[12]:=7;      dat3^[13]:=7;
     dat3^[14]:=8;      dat3^[15]:=7;
     dat3^[16]:=8;      dat3^[17]:=5;
     dat3^[18]:=9;      dat3^[19]:=6;
     dat3^[20]:=9;      dat3^[21]:=3;
     dat3^[22]:=10;      dat3^[23]:=4;
     dat3^[24]:=10;      dat3^[25]:=2;
     dat3^[26]:=11;      dat3^[27]:=2;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 1;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 14;
         bord3.xy       := dat3;

     bord4:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat4:=e.AllocMem(s.SIZE(INTEGER)*36,LONGSET{e.memClear});
(*     NEW(bord4);
     NEW(dat4);*)
     dat4^[0]:=2;      dat4^[1]:=1;
     dat4^[2]:=13;      dat4^[3]:=1;
     dat4^[4]:=13;      dat4^[5]:=2;
     dat4^[6]:=2;      dat4^[7]:=2;
     dat4^[8]:=2;      dat4^[9]:=3;
     dat4^[10]:=13;      dat4^[11]:=3;
     dat4^[12]:=13;      dat4^[13]:=4;
     dat4^[14]:=2;      dat4^[15]:=4;
     dat4^[16]:=2;      dat4^[17]:=5;
     dat4^[18]:=13;      dat4^[19]:=5;
     dat4^[20]:=13;      dat4^[21]:=6;
     dat4^[22]:=2;      dat4^[23]:=6;
     dat4^[24]:=2;      dat4^[25]:=7;
     dat4^[26]:=13;      dat4^[27]:=7;
     dat4^[28]:=13;      dat4^[29]:=8;
     dat4^[30]:=2;      dat4^[31]:=8;

         bord4.leftEdge :=0;
         bord4.topEdge  :=0;
         bord4.frontPen := 0;
         bord4.backPen  := 0;
         bord4.drawMode := g.jam1;
         bord4.count    := 16;
         bord4.xy       := dat4;
         bord4.nextBorder:=s.VAL(e.APTR,bord3);

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=0;
     dat2^[2]:=0;      dat2^[3]:=6+3;
     dat2^[4]:=1;      dat2^[5]:=6+2;
     dat2^[6]:=1;      dat2^[7]:=0;
     dat2^[8]:=12+2;      dat2^[9]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 5;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord4);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=12+3;      dat^[1]:=6+3;
     dat^[2]:=12+3;dat^[3]:=0;
     dat^[4]:=12+2;dat^[5]:=1;
     dat^[6]:=12+2;dat^[7]:=6+3;
     dat^[8]:=1;      dat^[9]:=6+3;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 5;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocArrowDownBorder;

PROCEDURE AllocArrowDownSelBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 28 OF INTEGER;
bord4: UNTRACED POINTER TO I.Border;
dat4 : UNTRACED POINTER TO ARRAY 36 OF INTEGER;

BEGIN
  bord:=AllocArrowDownBorder();
  bord.frontPen:=2;
  bord.nextBorder.frontPen:=1;
  bord.nextBorder.nextBorder.frontPen:=3;
  bord.nextBorder.nextBorder.nextBorder.frontPen:=1;

(*     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*28,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=4;      dat3^[1]:=2;
     dat3^[2]:=5;      dat3^[3]:=2;
     dat3^[4]:=5;      dat3^[5]:=4;
     dat3^[6]:=6;      dat3^[7]:=3;
     dat3^[8]:=6;      dat3^[9]:=6;
     dat3^[10]:=7;      dat3^[11]:=5;
     dat3^[12]:=7;      dat3^[13]:=7;
     dat3^[14]:=8;      dat3^[15]:=7;
     dat3^[16]:=8;      dat3^[17]:=5;
     dat3^[18]:=9;      dat3^[19]:=6;
     dat3^[20]:=9;      dat3^[21]:=3;
     dat3^[22]:=10;      dat3^[23]:=4;
     dat3^[24]:=10;      dat3^[25]:=2;
     dat3^[26]:=11;      dat3^[27]:=2;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 1;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 14;
         bord3.xy       := dat3;

     bord4:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat4:=e.AllocMem(s.SIZE(INTEGER)*36,LONGSET{e.memClear});
(*     NEW(bord4);
     NEW(dat4);*)
     dat4^[0]:=2;      dat4^[1]:=1;
     dat4^[2]:=13;      dat4^[3]:=1;
     dat4^[4]:=13;      dat4^[5]:=2;
     dat4^[6]:=2;      dat4^[7]:=2;
     dat4^[8]:=2;      dat4^[9]:=3;
     dat4^[10]:=13;      dat4^[11]:=3;
     dat4^[12]:=13;      dat4^[13]:=4;
     dat4^[14]:=2;      dat4^[15]:=4;
     dat4^[16]:=2;      dat4^[17]:=5;
     dat4^[18]:=13;      dat4^[19]:=5;
     dat4^[20]:=13;      dat4^[21]:=6;
     dat4^[22]:=2;      dat4^[23]:=6;
     dat4^[24]:=2;      dat4^[25]:=7;
     dat4^[26]:=13;      dat4^[27]:=7;
     dat4^[28]:=13;      dat4^[29]:=8;
     dat4^[30]:=2;      dat4^[31]:=8;

         bord4.leftEdge :=0;
         bord4.topEdge  :=0;
         bord4.frontPen := 3;
         bord4.backPen  := 0;
         bord4.drawMode := g.jam1;
         bord4.count    := 16;
         bord4.xy       := dat4;
         bord4.nextBorder:=s.VAL(e.APTR,bord3);

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=0;
     dat2^[2]:=0;      dat2^[3]:=6+3;
     dat2^[4]:=1;      dat2^[5]:=6+2;
     dat2^[6]:=1;      dat2^[7]:=0;
     dat2^[8]:=12+2;      dat2^[9]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 1;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 5;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord4);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=12+3;      dat^[1]:=6+3;
     dat^[2]:=12+3;dat^[3]:=0;
     dat^[4]:=12+2;dat^[5]:=1;
     dat^[6]:=12+2;dat^[7]:=6+3;
     dat^[8]:=1;      dat^[9]:=6+3;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 2;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 5;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);*)

    RETURN bord;
END AllocArrowDownSelBorder;

PROCEDURE AllocArrowUpWideBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 6 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 6 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 26 OF INTEGER;

BEGIN

     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*26,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=4;      dat3^[1]:=7;
     dat3^[2]:=8;      dat3^[3]:=3;
     dat3^[4]:=9;      dat3^[5]:=3;
     dat3^[6]:=13;      dat3^[7]:=7;
     dat3^[8]:=12;      dat3^[9]:=7;
     dat3^[10]:=9;      dat3^[11]:=4;
     dat3^[12]:=8;      dat3^[13]:=4;
     dat3^[14]:=5;      dat3^[15]:=7;
     dat3^[16]:=6;      dat3^[17]:=6;
     dat3^[18]:=7;      dat3^[19]:=6;
     dat3^[20]:=8;      dat3^[21]:=5;
     dat3^[22]:=9;      dat3^[23]:=5;
     dat3^[24]:=10;      dat3^[25]:=6;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 1;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 13;
         bord3.xy       := dat3;

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*6,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=10;
     dat2^[2]:=0;      dat2^[3]:=0;
     dat2^[4]:=16;      dat2^[5]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 3;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*6,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=1;      dat^[1]:=10;
     dat^[2]:=17;     dat^[3]:=10;
     dat^[4]:=17;     dat^[5]:=0;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 3;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocArrowUpWideBorder;

PROCEDURE AllocArrowUpWideSelBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 6 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 6 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 26 OF INTEGER;

BEGIN

     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*26,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=4;      dat3^[1]:=7;
     dat3^[2]:=8;      dat3^[3]:=3;
     dat3^[4]:=9;      dat3^[5]:=3;
     dat3^[6]:=13;      dat3^[7]:=7;
     dat3^[8]:=12;      dat3^[9]:=7;
     dat3^[10]:=9;      dat3^[11]:=4;
     dat3^[12]:=8;      dat3^[13]:=4;
     dat3^[14]:=5;      dat3^[15]:=7;
     dat3^[16]:=6;      dat3^[17]:=6;
     dat3^[18]:=7;      dat3^[19]:=6;
     dat3^[20]:=8;      dat3^[21]:=5;
     dat3^[22]:=9;      dat3^[23]:=5;
     dat3^[24]:=10;      dat3^[25]:=6;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 1;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 13;
         bord3.xy       := dat3;

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*6,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=9;
     dat2^[2]:=0;      dat2^[3]:=0;
     dat2^[4]:=17;      dat2^[5]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 1;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 3;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*6,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=0;      dat^[1]:=10;
     dat^[2]:=17;     dat^[3]:=10;
     dat^[4]:=17;     dat^[5]:=1;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 2;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 3;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocArrowUpWideSelBorder;

PROCEDURE AllocArrowDownWideBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 6 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 6 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 26 OF INTEGER;

BEGIN

     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*26,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=4;      dat3^[1]:=3;
     dat3^[2]:=8;      dat3^[3]:=7;
     dat3^[4]:=9;      dat3^[5]:=7;
     dat3^[6]:=13;      dat3^[7]:=3;
     dat3^[8]:=12;      dat3^[9]:=3;
     dat3^[10]:=9;      dat3^[11]:=6;
     dat3^[12]:=8;      dat3^[13]:=6;
     dat3^[14]:=5;      dat3^[15]:=3;
     dat3^[16]:=6;      dat3^[17]:=4;
     dat3^[18]:=7;      dat3^[19]:=4;
     dat3^[20]:=8;      dat3^[21]:=5;
     dat3^[22]:=9;      dat3^[23]:=5;
     dat3^[24]:=10;      dat3^[25]:=4;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 1;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 13;
         bord3.xy       := dat3;

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*6,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=10;
     dat2^[2]:=0;      dat2^[3]:=0;
     dat2^[4]:=16;      dat2^[5]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 3;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*6,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=1;      dat^[1]:=10;
     dat^[2]:=17;     dat^[3]:=10;
     dat^[4]:=17;     dat^[5]:=0;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 3;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocArrowDownWideBorder;

PROCEDURE AllocArrowDownWideSelBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 6 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 6 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 26 OF INTEGER;

BEGIN

     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*26,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=4;      dat3^[1]:=3;
     dat3^[2]:=8;      dat3^[3]:=7;
     dat3^[4]:=9;      dat3^[5]:=7;
     dat3^[6]:=13;      dat3^[7]:=3;
     dat3^[8]:=12;      dat3^[9]:=3;
     dat3^[10]:=9;      dat3^[11]:=6;
     dat3^[12]:=8;      dat3^[13]:=6;
     dat3^[14]:=5;      dat3^[15]:=3;
     dat3^[16]:=6;      dat3^[17]:=4;
     dat3^[18]:=7;      dat3^[19]:=4;
     dat3^[20]:=8;      dat3^[21]:=5;
     dat3^[22]:=9;      dat3^[23]:=5;
     dat3^[24]:=10;      dat3^[25]:=4;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 1;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 13;
         bord3.xy       := dat3;

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*6,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=9;
     dat2^[2]:=0;      dat2^[3]:=0;
     dat2^[4]:=17;      dat2^[5]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 1;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 3;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*6,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=0;      dat^[1]:=10;
     dat^[2]:=17;     dat^[3]:=10;
     dat^[4]:=17;     dat^[5]:=1;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 2;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 3;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocArrowDownWideSelBorder;

PROCEDURE AllocArrowLeftWideBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 6 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 6 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 12 OF INTEGER;

BEGIN

     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*12,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=10;      dat3^[1]:=6;
     dat3^[2]:=5;      dat3^[3]:=4;
     dat3^[4]:=10;      dat3^[5]:=2;
     dat3^[6]:=8;      dat3^[7]:=4;
     dat3^[8]:=10;      dat3^[9]:=6;
     dat3^[10]:=7;      dat3^[11]:=4;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 1;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 6;
         bord3.xy       := dat3;

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*6,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=8;
     dat2^[2]:=0;      dat2^[3]:=0;
     dat2^[4]:=15;      dat2^[5]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 3;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*6,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=0;      dat^[1]:=9;
     dat^[2]:=15;     dat^[3]:=9;
     dat^[4]:=15;     dat^[5]:=1;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 3;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocArrowLeftWideBorder;

PROCEDURE AllocArrowLeftWideSelBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 6 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 6 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 12 OF INTEGER;

BEGIN

     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*12,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=10;      dat3^[1]:=6;
     dat3^[2]:=5;      dat3^[3]:=4;
     dat3^[4]:=10;      dat3^[5]:=2;
     dat3^[6]:=8;      dat3^[7]:=4;
     dat3^[8]:=10;      dat3^[9]:=6;
     dat3^[10]:=7;      dat3^[11]:=4;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 1;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 6;
         bord3.xy       := dat3;

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*6,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=8;
     dat2^[2]:=0;      dat2^[3]:=0;
     dat2^[4]:=15;      dat2^[5]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 1;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 3;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*6,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=0;      dat^[1]:=9;
     dat^[2]:=15;     dat^[3]:=9;
     dat^[4]:=15;     dat^[5]:=1;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 2;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 3;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocArrowLeftWideSelBorder;

PROCEDURE AllocArrowRightWideBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 6 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 6 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 12 OF INTEGER;

BEGIN

     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*12,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=5;      dat3^[1]:=6;
     dat3^[2]:=10;      dat3^[3]:=4;
     dat3^[4]:=5;      dat3^[5]:=2;
     dat3^[6]:=7;      dat3^[7]:=4;
     dat3^[8]:=5;      dat3^[9]:=6;
     dat3^[10]:=8;      dat3^[11]:=4;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 1;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 6;
         bord3.xy       := dat3;

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*6,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=8;
     dat2^[2]:=0;      dat2^[3]:=0;
     dat2^[4]:=15;      dat2^[5]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 3;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*6,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=0;      dat^[1]:=9;
     dat^[2]:=15;     dat^[3]:=9;
     dat^[4]:=15;     dat^[5]:=1;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 3;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocArrowRightWideBorder;

PROCEDURE AllocArrowRightWideSelBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 6 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 6 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 12 OF INTEGER;

BEGIN

     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*12,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=5;      dat3^[1]:=6;
     dat3^[2]:=10;      dat3^[3]:=4;
     dat3^[4]:=5;      dat3^[5]:=2;
     dat3^[6]:=7;      dat3^[7]:=4;
     dat3^[8]:=5;      dat3^[9]:=6;
     dat3^[10]:=8;      dat3^[11]:=4;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 1;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 6;
         bord3.xy       := dat3;

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*6,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=8;
     dat2^[2]:=0;      dat2^[3]:=0;
     dat2^[4]:=15;      dat2^[5]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 1;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 3;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*6,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=0;      dat^[1]:=9;
     dat^[2]:=15;     dat^[3]:=9;
     dat^[4]:=15;     dat^[5]:=1;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 2;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 3;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocArrowRightWideSelBorder;

PROCEDURE AllocCycleBorder(bitwidth:INTEGER):e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 48 OF INTEGER;
bord4: UNTRACED POINTER TO I.Border;
dat4 : UNTRACED POINTER TO ARRAY 40 OF INTEGER;
bord5: UNTRACED POINTER TO I.Border;
dat5 : UNTRACED POINTER TO ARRAY 4 OF INTEGER;
bord6: UNTRACED POINTER TO I.Border;
dat6 : UNTRACED POINTER TO ARRAY 4 OF INTEGER;

BEGIN
     bord6:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat6:=e.AllocMem(s.SIZE(INTEGER)*4,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat6^[0]:=21;      dat6^[1]:=2;
     dat6^[2]:=21;      dat6^[3]:=11;

         bord6.leftEdge :=0;
         bord6.topEdge  :=0;
         bord6.frontPen := 2;
         bord6.backPen  := 0;
         bord6.drawMode := g.jam1;
         bord6.count    := 2;
         bord6.xy       := dat6;

     bord5:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat5:=e.AllocMem(s.SIZE(INTEGER)*4,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat5^[0]:=20;      dat5^[1]:=2;
     dat5^[2]:=20;      dat5^[3]:=11;

         bord5.leftEdge :=0;
         bord5.topEdge  :=0;
         bord5.frontPen := 1;
         bord5.backPen  := 0;
         bord5.drawMode := g.jam1;
         bord5.count    := 2;
         bord5.xy       := dat5;
         bord5.nextBorder:=s.VAL(e.APTR,bord6);

     bord4:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat4:=e.AllocMem(s.SIZE(INTEGER)*40,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat4^[0]:=14;      dat4^[1]:=9;
     dat4^[2]:=13;      dat4^[3]:=9;
     dat4^[4]:=13;      dat4^[5]:=10;
     dat4^[6]:=7;      dat4^[7]:=10;
     dat4^[8]:=7;      dat4^[9]:=3;
     dat4^[10]:=6;       dat4^[11]:=3;
     dat4^[12]:=6;       dat4^[13]:=9;
     dat4^[14]:=7;      dat4^[15]:=9;
     dat4^[16]:=7;      dat4^[17]:=2;
     dat4^[18]:=13;      dat4^[19]:=2;
     dat4^[20]:=13;      dat4^[21]:=5;
     dat4^[22]:=16;      dat4^[23]:=5;
     dat4^[24]:=11;      dat4^[25]:=5;
     dat4^[26]:=12;      dat4^[27]:=5;
     dat4^[28]:=12;      dat4^[29]:=6;
     dat4^[30]:=15;      dat4^[31]:=6;
     dat4^[32]:=13;      dat4^[33]:=6;
     dat4^[34]:=13;      dat4^[35]:=7;
     dat4^[36]:=14;      dat4^[37]:=7;
     dat4^[38]:=14;      dat4^[39]:=3;

         bord4.leftEdge :=0;
         bord4.topEdge  :=0;
         bord4.frontPen := 1;
         bord4.backPen  := 0;
         bord4.drawMode := g.jam1;
         bord4.count    := 20;
         bord4.xy       := dat4;
         bord4.nextBorder:=s.VAL(e.APTR,bord5);

     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*48,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=2;      dat3^[1]:=1;
     dat3^[2]:=bitwidth-3;dat3^[3]:=1;
     dat3^[4]:=bitwidth-3;dat3^[5]:=2;
     dat3^[6]:=2;      dat3^[7]:=2;
     dat3^[8]:=2;      dat3^[9]:=3;
     dat3^[10]:=bitwidth-3;dat3^[11]:=3;
     dat3^[12]:=bitwidth-3;dat3^[13]:=4;
     dat3^[14]:=2;      dat3^[15]:=4;
     dat3^[16]:=2;      dat3^[17]:=5;
     dat3^[18]:=bitwidth-3;dat3^[19]:=5;
     dat3^[20]:=bitwidth-3;dat3^[21]:=6;
     dat3^[22]:=2;      dat3^[23]:=6;
     dat3^[24]:=2;      dat3^[25]:=7;
     dat3^[26]:=bitwidth-3;dat3^[27]:=7;
     dat3^[28]:=bitwidth-3;dat3^[29]:=8;
     dat3^[30]:=2;      dat3^[31]:=8;
     dat3^[32]:=2;      dat3^[33]:=9;
     dat3^[34]:=bitwidth-3;dat3^[35]:=9;
     dat3^[36]:=bitwidth-3;dat3^[37]:=10;
     dat3^[38]:=2;      dat3^[39]:=10;
     dat3^[40]:=2;      dat3^[41]:=11;
     dat3^[42]:=bitwidth-3;dat3^[43]:=11;
     dat3^[44]:=bitwidth-3;dat3^[45]:=12;
     dat3^[46]:=2;      dat3^[47]:=12;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 0;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 24;
         bord3.xy       := dat3;
         bord3.nextBorder:=s.VAL(e.APTR,bord4);

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=0;
     dat2^[2]:=0;      dat2^[3]:=14-1;
     dat2^[4]:=1;      dat2^[5]:=14-2;
     dat2^[6]:=1;      dat2^[7]:=0;
     dat2^[8]:=bitwidth-2;      dat2^[9]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 5;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=bitwidth-1;      dat^[1]:=14-1;
     dat^[2]:=bitwidth-1;dat^[3]:=0;
     dat^[4]:=bitwidth-2;dat^[5]:=1;
     dat^[6]:=bitwidth-2;dat^[7]:=14-1;
     dat^[8]:=0;      dat^[9]:=14-1;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 5;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocCycleBorder;

PROCEDURE AllocCycleInBorder(bitwidth:INTEGER):e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 48 OF INTEGER;
bord4: UNTRACED POINTER TO I.Border;
dat4 : UNTRACED POINTER TO ARRAY 40 OF INTEGER;
bord5: UNTRACED POINTER TO I.Border;
dat5 : UNTRACED POINTER TO ARRAY 4 OF INTEGER;
bord6: UNTRACED POINTER TO I.Border;
dat6 : UNTRACED POINTER TO ARRAY 4 OF INTEGER;

BEGIN
  bord:=AllocCycleBorder(bitwidth);
  bord.frontPen:=2;
  bord.nextBorder.frontPen:=1;
  bord.nextBorder.nextBorder.frontPen:=3;
  bord.nextBorder.nextBorder.nextBorder.frontPen:=1;
  bord.nextBorder.nextBorder.nextBorder.nextBorder.frontPen:=2;
  bord.nextBorder.nextBorder.nextBorder.nextBorder.nextBorder.frontPen:=1;

(*     bord6:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat6:=e.AllocMem(s.SIZE(INTEGER)*4,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat6^[0]:=21;      dat6^[1]:=2;
     dat6^[2]:=21;      dat6^[3]:=11;

         bord6.leftEdge :=0;
         bord6.topEdge  :=0;
         bord6.frontPen := 1;
         bord6.backPen  := 0;
         bord6.drawMode := g.jam1;
         bord6.count    := 2;
         bord6.xy       := dat6;

     bord5:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat5:=e.AllocMem(s.SIZE(INTEGER)*4,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat5^[0]:=20;      dat5^[1]:=2;
     dat5^[2]:=20;      dat5^[3]:=11;

         bord5.leftEdge :=0;
         bord5.topEdge  :=0;
         bord5.frontPen := 2;
         bord5.backPen  := 0;
         bord5.drawMode := g.jam1;
         bord5.count    := 2;
         bord5.xy       := dat5;
         bord5.nextBorder:=s.VAL(e.APTR,bord6);

     bord4:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat4:=e.AllocMem(s.SIZE(INTEGER)*40,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat4^[0]:=14;      dat4^[1]:=9;
     dat4^[2]:=13;      dat4^[3]:=9;
     dat4^[4]:=13;      dat4^[5]:=10;
     dat4^[6]:=7;      dat4^[7]:=10;
     dat4^[8]:=7;      dat4^[9]:=3;
     dat4^[10]:=6;       dat4^[11]:=3;
     dat4^[12]:=6;       dat4^[13]:=9;
     dat4^[14]:=7;      dat4^[15]:=9;
     dat4^[16]:=7;      dat4^[17]:=2;
     dat4^[18]:=13;      dat4^[19]:=2;
     dat4^[20]:=13;      dat4^[21]:=5;
     dat4^[22]:=16;      dat4^[23]:=5;
     dat4^[24]:=11;      dat4^[25]:=5;
     dat4^[26]:=12;      dat4^[27]:=5;
     dat4^[28]:=12;      dat4^[29]:=6;
     dat4^[30]:=15;      dat4^[31]:=6;
     dat4^[32]:=13;      dat4^[33]:=6;
     dat4^[34]:=13;      dat4^[35]:=7;
     dat4^[36]:=14;      dat4^[37]:=7;
     dat4^[38]:=14;      dat4^[39]:=3;

         bord4.leftEdge :=0;
         bord4.topEdge  :=0;
         bord4.frontPen := 1;
         bord4.backPen  := 0;
         bord4.drawMode := g.jam1;
         bord4.count    := 20;
         bord4.xy       := dat4;
         bord4.nextBorder:=s.VAL(e.APTR,bord5);

     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*48,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=2;      dat3^[1]:=1;
     dat3^[2]:=bitwidth-3;dat3^[3]:=1;
     dat3^[4]:=bitwidth-3;dat3^[5]:=2;
     dat3^[6]:=2;      dat3^[7]:=2;
     dat3^[8]:=2;      dat3^[9]:=3;
     dat3^[10]:=bitwidth-3;dat3^[11]:=3;
     dat3^[12]:=bitwidth-3;dat3^[13]:=4;
     dat3^[14]:=2;      dat3^[15]:=4;
     dat3^[16]:=2;      dat3^[17]:=5;
     dat3^[18]:=bitwidth-3;dat3^[19]:=5;
     dat3^[20]:=bitwidth-3;dat3^[21]:=6;
     dat3^[22]:=2;      dat3^[23]:=6;
     dat3^[24]:=2;      dat3^[25]:=7;
     dat3^[26]:=bitwidth-3;dat3^[27]:=7;
     dat3^[28]:=bitwidth-3;dat3^[29]:=8;
     dat3^[30]:=2;      dat3^[31]:=8;
     dat3^[32]:=2;      dat3^[33]:=9;
     dat3^[34]:=bitwidth-3;dat3^[35]:=9;
     dat3^[36]:=bitwidth-3;dat3^[37]:=10;
     dat3^[38]:=2;      dat3^[39]:=10;
     dat3^[40]:=2;      dat3^[41]:=11;
     dat3^[42]:=bitwidth-3;dat3^[43]:=11;
     dat3^[44]:=bitwidth-3;dat3^[45]:=12;
     dat3^[46]:=2;      dat3^[47]:=12;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 3;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 24;
         bord3.xy       := dat3;
         bord3.nextBorder:=s.VAL(e.APTR,bord4);

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=0;
     dat2^[2]:=0;      dat2^[3]:=14-1;
     dat2^[4]:=1;      dat2^[5]:=14-2;
     dat2^[6]:=1;      dat2^[7]:=0;
     dat2^[8]:=bitwidth-2;      dat2^[9]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 1;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 5;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=bitwidth-1;      dat^[1]:=14-1;
     dat^[2]:=bitwidth-1;dat^[3]:=0;
     dat^[4]:=bitwidth-2;dat^[5]:=1;
     dat^[6]:=bitwidth-2;dat^[7]:=14-1;
     dat^[8]:=0;      dat^[9]:=14-1;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 2;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 5;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);*)

    RETURN bord;
END AllocCycleInBorder;

PROCEDURE AllocRadioBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 22 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 22 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 24 OF INTEGER;

BEGIN
     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*24,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=5;      dat3^[1]:=2;
     dat3^[2]:=11;     dat3^[3]:=2;
     dat3^[4]:=11;     dat3^[5]:=3;
     dat3^[6]:=12;     dat3^[7]:=3;
     dat3^[8]:=4;      dat3^[9]:=3;
     dat3^[10]:=4;      dat3^[11]:=4;
     dat3^[12]:=12;     dat3^[13]:=4;
     dat3^[14]:=12;     dat3^[15]:=5;
     dat3^[16]:=4;      dat3^[17]:=5;
     dat3^[18]:=5;      dat3^[19]:=5;
     dat3^[20]:=5;      dat3^[21]:=6;
     dat3^[22]:=11;     dat3^[23]:=6;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 0;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 12;
         bord3.xy       := dat3;

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*22,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=2;      dat2^[1]:=8;
     dat2^[2]:=2;      dat2^[3]:=7;
     dat2^[4]:=1;      dat2^[5]:=7;
     dat2^[6]:=1;      dat2^[7]:=6;
     dat2^[8]:=0;      dat2^[9]:=2;
     dat2^[10]:=0;      dat2^[11]:=6;
     dat2^[12]:=1;      dat2^[13]:=6;
     dat2^[14]:=1;      dat2^[15]:=1;
     dat2^[16]:=2;      dat2^[17]:=1;
     dat2^[18]:=2;      dat2^[19]:=0;
     dat2^[20]:=13;      dat2^[21]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 11;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*22,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=14;      dat^[1]:=0;
     dat^[2]:=14;      dat^[3]:=1;
     dat^[4]:=15;      dat^[5]:=1;
     dat^[6]:=15;      dat^[7]:=2;
     dat^[8]:=16;      dat^[9]:=6;
     dat^[10]:=16;      dat^[11]:=2;
     dat^[12]:=15;      dat^[13]:=2;
     dat^[14]:=15;      dat^[15]:=7;
     dat^[16]:=14;      dat^[17]:=7;
     dat^[18]:=14;      dat^[19]:=8;
     dat^[20]:=3;      dat^[21]:=8;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 11;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocRadioBorder;

PROCEDURE AllocRadioSelBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 22 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 22 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 24 OF INTEGER;

BEGIN
  bord:=AllocRadioBorder();
  bord.frontPen:=2;
  bord.nextBorder.frontPen:=1;
  bord.nextBorder.nextBorder.frontPen:=3;
(*     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*24,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=5;      dat3^[1]:=2;
     dat3^[2]:=11;     dat3^[3]:=2;
     dat3^[4]:=11;     dat3^[5]:=3;
     dat3^[6]:=12;     dat3^[7]:=3;
     dat3^[8]:=4;      dat3^[9]:=3;
     dat3^[10]:=4;      dat3^[11]:=4;
     dat3^[12]:=12;     dat3^[13]:=4;
     dat3^[14]:=12;     dat3^[15]:=5;
     dat3^[16]:=4;      dat3^[17]:=5;
     dat3^[18]:=5;      dat3^[19]:=5;
     dat3^[20]:=5;      dat3^[21]:=6;
     dat3^[22]:=11;     dat3^[23]:=6;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 3;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 12;
         bord3.xy       := dat3;

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*22,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=2;      dat2^[1]:=8;
     dat2^[2]:=2;      dat2^[3]:=7;
     dat2^[4]:=1;      dat2^[5]:=7;
     dat2^[6]:=1;      dat2^[7]:=6;
     dat2^[8]:=0;      dat2^[9]:=2;
     dat2^[10]:=0;      dat2^[11]:=6;
     dat2^[12]:=1;      dat2^[13]:=6;
     dat2^[14]:=1;      dat2^[15]:=1;
     dat2^[16]:=2;      dat2^[17]:=1;
     dat2^[18]:=2;      dat2^[19]:=0;
     dat2^[20]:=13;      dat2^[21]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 1;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 11;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*22,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=14;      dat^[1]:=0;
     dat^[2]:=14;      dat^[3]:=1;
     dat^[4]:=15;      dat^[5]:=1;
     dat^[6]:=15;      dat^[7]:=2;
     dat^[8]:=16;      dat^[9]:=6;
     dat^[10]:=16;      dat^[11]:=2;
     dat^[12]:=15;      dat^[13]:=2;
     dat^[14]:=15;      dat^[15]:=7;
     dat^[16]:=14;      dat^[17]:=7;
     dat^[18]:=14;      dat^[19]:=8;
     dat^[20]:=3;      dat^[21]:=8;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 2;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 11;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);*)

    RETURN bord;
END AllocRadioSelBorder;

PROCEDURE SetBooleanGadget*(xpos,ypos,width:INTEGER;text:e.STRPTR;prev:I.GadgetPtr;fontwind:I.WindowPtr):I.GadgetPtr;

VAR gadget : I.GadgetPtr;

PROCEDURE AllocBooleanIntuiText():s.ADDRESS;

VAR intui : I.IntuiTextPtr;
    len   : INTEGER;

BEGIN
  intui:=e.AllocMem(s.SIZE(I.IntuiText),LONGSET{e.memClear});
  intui.frontPen:=1;
  intui.backPen:=0;
  intui.drawMode:=g.jam1;
  len:=g.TextLength(fontwind.rPort,text^,st.Length(text^));
  IF (len<width-8) AND (fontwind.rPort.txHeight<=12) THEN
    intui.iTextFont:=NIL;
    intui.leftEdge:=(width DIV 2)-(len DIV 2);
  ELSE
    intui.iTextFont:=topaz;
    intui.leftEdge:=SHORT((width DIV 2)-((st.Length(text^)*8) DIV 2));
  END;
  intui.topEdge:=7-(fontwind.rPort.txHeight DIV 2);
  intui.iText:=text;
  intui.nextText:=NIL;
  RETURN intui;
END AllocBooleanIntuiText;

BEGIN
  gadget:=e.AllocMem(s.SIZE(I.Gadget),LONGSET{e.memClear});
  gadget.nextGadget:=NIL;
  gadget.leftEdge:=xpos;
  gadget.topEdge:=ypos;
  gadget.width:=width;
  gadget.height:=14;
  gadget.flags:=SET{I.gadgHImage};
  gadget.activation:=stdActivation;
  gadget.gadgetType:=I.boolGadget;
  gadget.gadgetRender:=AllocBooleanBorder(width);
  gadget.selectRender:=AllocInBooleanBorder(width);
  gadget.gadgetText:=AllocBooleanIntuiText();
  gadget.mutualExclude:=LONGSET{};
  gadget.specialInfo:=NIL;
  gadget.gadgetID:=-1;
  gadget.userData:=NIL;
  IF prev#NIL THEN
    prev.nextGadget:=gadget;
  END;
  RETURN gadget;
END SetBooleanGadget;

PROCEDURE SetStringGadget*(xpos,ypos,width,height,chars:INTEGER;prev:I.GadgetPtr;fontwind:I.WindowPtr):I.GadgetPtr;

VAR gadget : I.GadgetPtr;

PROCEDURE SetStringInfo():s.ADDRESS;

VAR info : I.StringInfoPtr;

BEGIN
  info:=e.AllocMem(s.SIZE(I.StringInfo),LONGSET{e.memClear});
  info.buffer:=e.AllocMem(s.SIZE(CHAR)*(chars+1),LONGSET{e.memClear});
  info.undoBuffer:=e.AllocMem(s.SIZE(CHAR)*(chars+1),LONGSET{e.memClear});
  info.bufferPos:=0;
  info.maxChars:=chars;
  info.dispPos:=0;
  info.longInt:=0;
  info.altKeyMap:=NIL;
  RETURN info;
END SetStringInfo;

BEGIN
  gadget:=e.AllocMem(s.SIZE(I.Gadget),LONGSET{e.memClear});
  gadget.leftEdge:=xpos+6;
  gadget.topEdge:=ypos+3;
  gadget.width:=width;
  gadget.height:=height-6;
  gadget.flags:=SET{};
  gadget.activation:=SET{I.relVerify,I.gadgImmediate,I.toggleSelect};
  gadget.gadgetType:=I.strGadget;
  gadget.gadgetRender:=AllocStringBorder(width,height-6);
  gadget.selectRender:=NIL;
  gadget.gadgetText:=NIL;
  gadget.mutualExclude:=LONGSET{};
  gadget.specialInfo:=SetStringInfo();
  gadget.gadgetID:=-1;
  gadget.userData:=NIL;
  IF prev#NIL THEN
    prev.nextGadget:=gadget;
  END;
  RETURN gadget;
END SetStringGadget;

PROCEDURE PutGadgetText*(gadget:I.GadgetPtr;text:ARRAY OF CHAR);

VAR info : I.StringInfoPtr;

BEGIN
  info:=s.VAL(I.StringInfoPtr,gadget.specialInfo);
  COPY(info.buffer^,info.undoBuffer^);
  COPY(text,info.buffer^);
END PutGadgetText;

PROCEDURE GetGadgetText*(gadget:I.GadgetPtr;VAR text:ARRAY OF CHAR);

VAR info : I.StringInfoPtr;

BEGIN
  info:=s.VAL1I.StringInfoPtr,gadget.specialInfo);
  COPY(info.buffer^,text);
END GetGadgetText;

PROEEDURE SetPropGadget*(xpos,ypos,width,heqght:INTEGER;hPos,vPos,hBod}lwRody:LOVGINT;prev:I.GadgetPtr;fontwind:I.WindowPtr):I.GadgetPtr;

VA≤ gadget : I/WadgetPtr;

PROEEDURE AllocPropInfo():I.PropInfoPtr;

VAR qnfo : I.PropInfoPtr;

BEGIN
  info:=e.AllocMem(s.SOZE(I.PropInfo),LONGSET{e.memEl}ar});
  info.flags:=SET{I.autoKnob,I.propBorderless};
  IF hBody>0 THEN
    INCL(info.flags4-1;
     dat2^[4]:=1;      dat2^[5]:=14-2;
     dat2^[6]:=1;      dat2^[7]:=0;
     dat2^[8]:=bitwidth-2;      dat2^[9]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 5;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=bitwidth-1;      dat^[1]:=14-1;
     dat^[2]:=bitwidth-1;dat^[3]:=0;
     dat^[4]:=bitwidth-2;dat^[5]:=1;
     dat^[6]:=bitwidth-2;dat^[7]:=14-1;
     dat^[8]:=1;      dat^[9]:=14-1;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 5;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocBooleanBorder;

PROCEDURE AllocInBooleanBorder(bitwidth:INTEGER):e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 48 OF INTEGER;

BEGIN
  bord:=AllocBooleanBorder(bitwidth);
  bord.frontPen:=2;
  bord.nextBorder.frontPen:=1;
  bord.nextBorder.nextBorder.frontPen:=3;
(*     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*48,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=2;      dat3^[1]:=1;
     dat3^[2]:=bitwidth-3;dat3^[3]:=1;
     dat3^[4]:=bitwidth-3;dat3^[5]:=2;
     dat3^[6]:=2;      dat3^[7]:=2;
     dat3^[8]:=2;      dat3^[9]:=3;
     dat3^[10]:=bitwidth-3;dat3^[11]:=3;
     dat3^[12]:=bitwidth-3;dat3^[13]:=4;
     dat3^[14]:=2;      dat3^[15]:=4;
     dat3^[16]:=2;      dat3^[17]:=5;
     dat3^[18]:=bitwidth-3;dat3^[19]:=5;
     dat3^[20]:=bitwidth-3;dat3^[21]:=6;
     dat3^[22]:=2;      dat3^[23]:=6;
     dat3^[24]:=2;      dat3^[25]:=7;
     dat3^[26]:=bitwidth-3;dat3^[27]:=7;
     dat3^[28]:=bitwidth-3;dat3^[29]:=8;
     dat3^[30]:=2;      dat3^[31]:=8;
     dat3^[32]:=2;      dat3^[33]:=9;
     dat3^[34]:=bitwidth-3;dat3^[35]:=9;
     dat3^[36]:=bitwidth-3;dat3^[37]:=10;
     dat3^[38]:=2;      dat3^[39]:=10;
     dat3^[40]:=2;      dat3^[41]:=11;
     dat3^[42]:=bitwidth-3;dat3^[43]:=11;
     dat3^[44]:=bitwidth-3;dat3^[45]:=12;
     dat3^[46]:=2;      dat3^[47]:=12;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 3;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 24;
         bord3.xy       := dat3;

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=0;
     dat2^[2]:=0;      dat2^[3]:=14-1;
     dat2^[4]:=1;      dat2^[5]:=14-2;
     dat2^[6]:=1;      dat2^[7]:=0;
     dat2^[8]:=bitwidth-2;      dat2^[9]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 1;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 5;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=bitwidth-1;      dat^[1]:=14-1;
     dat^[2]:=bitwidth-1;dat^[3]:=0;
     dat^[4]:=bitwidth-2;dat^[5]:=1;
     dat^[6]:=bitwidth-2;dat^[7]:=14-1;
     dat^[8]:=0;      dat^[9]:=14-1;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 2;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 5;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);*)


    RETURN bord;
END AllocInBooleanBorder;

PROCEDURE AllocStringBorder(bitwidth,he:INTEGER):e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 22 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 22 OF INTEGER;

BEGIN
     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*22,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=-5;      dat2^[1]:=-2;
     dat2^[2]:=-5;      dat2^[3]:=he+3;
     dat2^[4]:=-4;      dat2^[5]:=he+2;
     dat2^[6]:=-4;      dat2^[7]:=-2;
     dat2^[8]:=bitwidth+5;      dat2^[9]:=-2;
     dat2^[10]:=bitwidth+4;      dat2^[11]:=-2;
     dat2^[12]:=bitwidth+4;      dat2^[13]:=he+2;
     dat2^[14]:=bitwidth+3;      dat2^[15]:=he+2;
     dat2^[16]:=bitwidth+3;      dat2^[17]:=0;
     dat2^[18]:=bitwidth+3;      dat2^[19]:=he+2;
     dat2^[20]:=-2;      dat2^[21]:=he+2;

         bord2.leftEdge :=-1;
         bord2.topEdge  :=-1;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 11;
         bord2.xy       := dat2;


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*22,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=bitwidth+6;      dat^[1]:=he+3;
     dat^[2]:=bitwidth+6;dat^[3]:=-2;
     dat^[4]:=bitwidth+5;dat^[5]:=-1;
     dat^[6]:=bitwidth+5;dat^[7]:=he+3;
     dat^[8]:=-4;      dat^[9]:=he+3;
     dat^[10]:=-3;      dat^[11]:=he+3;
     daInBordeshwydth);
  gadget.gadgetText:=AllocCycleIntuiText();
  gadget.mutualExclude:=LONGSET{};
  gadget.specialInfo:=NIL;
  gadget.adgetID:=-1;
  gadget.userData:=NIL;
  IF prev#NIL THEN
    prev.nextGadget:=gadg}t;
  END;
  RETURN gadget;
END SetCycleGadget;

PS_CEDURE SetImageGadget*(xros,ypos,width,height,depth:INTEGER;data,davasel:s.ADDRESS;pr}vZ.GadgetPtr;fontwind:I.WindowPtr):I.GadgetPtr;

VAR gadget   : I>GadgetPtr;
    image,
    imagesel : I.ImagePtr;

BEGIN
  image:=e.AllocMem(s.SIZE(I.Image),LpBorder(bitwidth,height:INTEGER):e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 10 OF INTEGER;

BEGIN
  INC(bitwidth,8);
  INC(height,4);
     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=0;
     dat2^[2]:=0;      dat2^[3]:=height-1;
     dat2^[4]:=1;      dat2^[5]:=height-2;
     dat2^[6]:=1;      dat2^[7]:=0;
     dat2^[8]:=bitwidth-2;      dat2^[9]:=0;

         bord2.leftEdge :=-4;
         bord2.topEdge  :=-2;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 5;
         bord2.xy       := dat2;
         bord2.nextBorder:=NIL;


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=bitwidth-1;      dat^[1]:=height-1;
     dat^[2]:=bitwidth-1;dat^[3]:=0;
     dat^[4]:=bitwidth-2;dat^[5]:=1;
     dat^[6]:=bitwidth-2;dat^[7]:=height-1;
     dat^[8]:=1;      dat^[9]:=height-1;

         bord.leftEdge :=-4;
         bord.topEdge  :=-2;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 5;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocPropBorder;

PROCEDURE AllocCheckBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 42 OF INTEGER;

BEGIN
     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*42,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=7;      dat3^[1]:=5;
     dat3^[2]:=9;      dat3^[3]:=5;
     dat3^[4]:=8;      dat3^[5]:=6;
     dat3^[6]:=10;      dat3^[7]:=6;
     dat3^[8]:=9;      dat3^[9]:=7;
     dat3^[10]:=12;      dat3^[11]:=7;
     dat3^[12]:=10;      dat3^[13]:=7;
     dat3^[14]:=10;      dat3^[15]:=8;
     dat3^[16]:=12;      dat3^[17]:=8;
     dat3^[18]:=12;      dat3^[19]:=7;
     dat3^[20]:=13;      dat3^[21]:=7;
     dat3^[22]:=13;      dat3^[23]:=6;
     dat3^[24]:=14;      dat3^[25]:=6;
     dat3^[26]:=14;      dat3^[27]:=5;
     dat3^[28]:=15;      dat3^[29]:=5;
     dat3^[30]:=15;      dat3^[31]:=4;
     dat3^[32]:=16;      dat3^[33]:=4;
     dat3^[34]:=16;      dat3^[35]:=3;
     dat3^[36]:=17;      dat3^[37]:=3;
     dat3^[38]:=17;      dat3^[39]:=2;
     dat3^[40]:=19;      dat3^[41]:=2;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 0;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 21;
         bord3.xy       := dat3;

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=0;
     dat2^[2]:=0;      dat2^[3]:=7+3;
     dat2^[4]:=1;      dat2^[5]:=7+2;
     dat2^[6]:=1;      dat2^[7]:=0;
     dat2^[8]:=22+2;      dat2^[9]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 5;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=22+3;      dat^[1]:=7+3;
     dat^[2]:=22+3;dat^[3]:=0;
     dat^[4]:=22+2;dat^[5]:=1;
     dat^[6]:=22+2;dat^[7]:=7+3;
     dat^[8]:=1;      dat^[9]:=7+3;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 5;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocCheckBorder;

PROCEDURE AllocCheckSelBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 42 OF INTEGER;

BEGIN
  bord:=AllocCheckBorder();
  bord.frontPen:=1;
  bord.nextBorder.frontPen:=2;
  bord.nextBorder.nextBorder.frontPen:=1;
(*     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*42,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=7;      dat3^[1]:=5;
     dat3^[2]:=9;      dat3^[3]:=5;
     dat3^[4]:=8;      dat3^[5]:=6;
     dat3^[6]:=10;      dat3^[7]:=6;
     dat3^[8]:=9;      dat3^[9]:=7;
     dat3^[10]:=12;      dat3^[11]:=7;
     dat3^[12]:=10;      dat3^[13]:=7;
     dat3^[14]:=10;      dat3^[15]:=8;
     dat3^[16]:=12;      dat3^[17]:=8;
     dat3^[18]:=12;      dat3^[19]:=7;
     dat3^[20]:=13;      dat3^[21]:=7;
     dat3^[22]:=13;      dat3^[23]:=6;
     dat3^[24]:=14;      dat3^[25]:=6;
     dat3^[26]:=14;      dat3^[27]:=5;
     dat3^[28]:=15;      dat3^[29]:=5;
     dat3^[30]:=15;      dat3^[31]:=4;
     dat3^[32]:=16;      dat3^[33]:=4;
     dat3^[34]:=16;      dat3^[35]:=3;
     dat3^[36]:=17;      dat3^[37]:=3;
     dat3^[38]:=17;      dat3^[39]:=2;
     dat3^[40]:=19;      dat3^[41]:=2;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 1;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 21;
         bord3.xy       := dat3;

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=0;
     dat2^[2]:=0;      dat2^[3]:=7+3;
     dat2^[4]:=1;      dat2^[5]:=7+2;
     dat2^[6]:=1;      dat2^[7]:=0;
     dat2^[8]:=22+2;      dat2^[9]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 5;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord3);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=22+3;      dat^[1]:=7+3;
     dat^[2]:=22+3;dat^[3]:=0;
     dat^[4]:=22+2;dat^[5]:=1;
     dat^[6]:=22+2;dat^[7]:=7+3;
     dat^[8]:=1;      dat^[9]:=7+3;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 5;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);*)

    RETURN bord;
END AllocCheckSelBorder;

PROCEDURE AllocArrowUpBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 28 OF INTEGER;
bord4: UNTRACED POINTER TO I.Border;
dat4 : UNTRACED POINTER TO ARRAY 36 OF INTEGER;

BEGIN

     bord3:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat3:=e.AllocMem(s.SIZE(INTEGER)*28,LONGSET{e.memClear});
(*     NEW(bord3);
     NEW(dat3);*)
     dat3^[0]:=4;      dat3^[1]:=7;
     dat3^[2]:=5;      dat3^[3]:=7;
     dat3^[4]:=5;      dat3^[5]:=5;
     dat3^[6]:=6;      dat3^[7]:=6;
     dat3^[8]:=6;      dat3^[9]:=3;
     dat3^[10]:=7;      dat3^[11]:=4;
     dat3^[12]:=7;      dat3^[13]:=2;
     dat3^[14]:=8;      dat3^[15]:=2;
     dat3^[16]:=8;      dat3^[17]:=4;
     dat3^[18]:=9;      dat3^[19]:=3;
     dat3^[20]:=9;      dat3^[21]:=6;
     dat3^[22]:=10;      dat3^[23]:=5;
     dat3^[24]:=10;      dat3^[25]:=7;
     dat3^[26]:=11;      dat3^[27]:=7;

         bord3.leftEdge :=0;
         bord3.topEdge  :=0;
         bord3.frontPen := 1;
         bord3.backPen  := 0;
         bord3.drawMode := g.jam1;
         bord3.count    := 14;
         bord3.xy       := dat3;

     bord4:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat4:=e.AllocMem(s.SIZE(INTEGER)*36,LONGSET{e.memClear});
(*     NEW(bord4);
     NEW(dat4);*)
     dat4^[0]:=2;      dat4^[1]:=1;
     dat4^[2]:=13;      dat4^[3]:=1;
     dat4^[4]:=13;      dat4^[5]:=2;
     dat4^[6]:=2;      dat4^[7]:=2;
     dat4^[8]:=2;      dat4^[9]:=3;
     dat4^[10]:=13;      dat4^[11]:=3;
     dat4^[12]:=13;      dat4^[13]:=4;
     dat4^[14]:=2;      dat4^[15]:=4;
     dat4^[16]:=2;      dat4^[17]:=5;
     dat4^[18]:=13;      dat4^[19]:=5;
     dat4^[20]:=13;      dat4^[21]:=6;
     dat4^[22]:=2;      dat4^[23]:=6;
     dat4^[24]:=2;      dat4^[25]:=7;
     dat4^[26]:=13;      dat4^[27]:=7;
     dat4^[28]:=13;      dat4^[29]:=8;
     dat4^[30]:=2;      dat4^[31]:=8;

         bord4.leftEdge :=0;
         bord4.topEdge  :=0;
         bord4.frontPen := 0;
         bord4.backPen  := 0;
         bord4.drawMode := g.jam1;
         bord4.count    := 16;
         bord4.xy       := dat4;
         bord4.nextBorder:=s.VAL(e.APTR,bord3);

     bord2:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat2:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord2);
     NEW(dat2);*)
     dat2^[0]:=0;      dat2^[1]:=0;
     dat2^[2]:=0;      dat2^[3]:=6+3;
     dat2^[4]:=1;      dat2^[5]:=6+2;
     dat2^[6]:=1;      dat2^[7]:=0;
     dat2^[8]:=12+2;      dat2^[9]:=0;

         bord2.leftEdge :=0;
         bord2.topEdge  :=0;
         bord2.frontPen := 2;
         bord2.backPen  := 0;
         bord2.drawMode := g.jam1;
         bord2.count    := 5;
         bord2.xy       := dat2;
         bord2.nextBorder:=s.VAL(e.APTR,bord4);


     bord:=e.AllocMem(s.SIZE(I.Border),LONGSET{e.memClear});
     dat:=e.AllocMem(s.SIZE(INTEGER)*10,LONGSET{e.memClear});
(*     NEW(bord);
     NEW(dat);*)
     dat^[0]:=12+3;      dat^[1]:=6+3;
     dat^[2]:=12+3;dat^[3]:=0;
     dat^[4]:=12+2;dat^[5]:=1;
     dat^[6]:=12+2;dat^[7]:=6+3;
     dat^[8]:=1;      dat^[9]:=6+3;

         bord.leftEdge :=0;
         bord.topEdge  :=0;
         bord.frontPen := 1;
         bord.backPen  := 0;
         bord.drawMode := g.jam1;
         bord.count    := 5;
         bord.xy       := dat;
         bord.nextBorder:=s.VAL(e.APTR,bord2);

    RETURN bord;
END AllocArrowUpBorder;

PROCEDURE AllocArrowUpSelBorder():e.ADDRESS;
VAR
bord : UNTRACED POINTER TO I.Border;
dat  : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord2: UNTRACED POINTER TO I.Border;
dat2 : UNTRACED POINTER TO ARRAY 10 OF INTEGER;
bord3: UNTRACED POINTER TO I.Border;
dat3 : UNTRACED POINTER TO ARRAY 28 OF INTEGER;
bord4: UNTRACED POINTER TO I.Border;
dat4 : UNTRACED POINTER TO ARRAY 36 OF INTEGER;

BEGIN
  bord:=AllocArrowUpBorder();
  bord.frontPen:=2;
  bord.nextBorder.frontPen:=1;
  bord.nextBorder.nextBorder.frontPen:=3;
  bord.nextBorder.nextBord    Õh   H     Õi±Ì¨ Õ∞ ÕØ ÕÆ Õ≠ Õ¨ Õ´ Õ™ Õ© Õ® Õß Õ¶ Õ• Õ§ Õ£ Õ¢ Õ° Õ† Õü Õû Õù Õú Õõ Õö Õô Õò Õó Õñ Õï Õî Õì Õí Õë Õê Õè Õé Õç Õå Õã Õä Õâ Õà Õá ÕÜ ÕÖ ÕÑ ÕÉ ÕÇ ÕÅ ÕÄ Õ Õ~ Õ} Õ| Õ{ Õz Õy Õx Õw Õv Õu Õt Õs Õr Õq Õp Õo Õn Õm Õl Õk Õj Õi                                                                    