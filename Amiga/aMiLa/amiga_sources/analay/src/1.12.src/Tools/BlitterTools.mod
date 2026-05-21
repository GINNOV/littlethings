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


MODULE BlitterTools;

IMPORT I   : Intuition,
       g   : Graphics,
       e   : Exec,
       s   : SYSTEM,
       h   : Hardware,
       ol  : OberonLib;

(* $TypeChk- $NilChk- $RangeChk- $StackChk- $OvflChk- $ReturnChk- *)

(* Dieses Modul enthält folgende Prozeduren:
   (Falls nicht anders angegeben sind alle Parameter in x-Richtung
   an Wortgrenzen gebunden!)
   Alle Routinen sind bei der Breite an Wortgrenzen gebunden und
   überprüfen nicht, ob sich Quell- und Zielbreich überlappen!

   ACHTUNG: Nach Beendigung einer Prozedur kopiert der Blitter immer noch
            die letzten Daten. Wenn man mit den Prozeduren dieses Moduls
            arbeitet, macht das nichts, da jede Prozedur am Anfang
            wartet, bis der Blitter seinen vorherigen Kopiervorgang beendet
            hat. Bei eigenen Routinen müssen Sie aber auf jeden Fall
            sicherstellen, daß der Blitter bereits fertig ist, bevor Sie
            die Register erneut beschreiben. Die Prozedur WaitBlit erledigt
            genau dies. Sie sollten Sie vor Graphics.DisownBlitter aus
   ACHTUNG: Sicherheitsgründen aufrufen!

   BlitFast  : Optimierte Routine zum schnellen Kopieren.
   Blit      : Routine zum schnellen Kopieren, Ziel-x pixelweise, jedoch
               16 Pixel breiter schwarzer Balken links neben der Grafik, der
               bei einer Kopie in einen schwarzen Bildschirm oder bei einer
               Ziel-x-Koordinate von 0 nicht stört. Langsamer als
               BlitFast.
   BlitA     : Routine zum schnellen Kopieren, Ziel-x pixelweise. Langsamer
               als Blit, aber ohne schwarzen Balken.
   BlitTrans : Routine zum transparenten Kopieren, Quell-x pixelweise.
               Langsamer als nicht-transparente Routinen.
   BlitterPri: Steuert die Blitterpriorität.


   Parameterübergabe der Prozeduren:

   source : Quell-BitMap
   xs,ys  : x-, y-Koordinate des Quellausschnittes
   dest   : Ziel-BitMap
   xd,yd  : x-, y-Koordinate des Zielausschnittes
   wi,he  : Breite, Höhe des zu kopierenden Ausschnittes
   mask   : BitMap mit der Maske für das transparente Kopieren. Sie muß
            die gleichen Dimensionen wie die Quell-BitMap und eine
            Tiefe von 1 haben.


   Keine der Prozeduren überprüft die Parameter auf eventuelle
   Fehlangaben! *)


VAR blitamask : UNTRACED POINTER TO ARRAY OF LONGINT;
    blitalen  : INTEGER;

PROCEDURE CheckOneBlock(map:g.BitMapPtr;de:INTEGER):BOOLEAN;

VAR ret    : BOOLEAN;
    i,size : INTEGER;

BEGIN
  ret:=TRUE;
  DEC(de);
  IF de>=0 THEN
    size:=map.bytesPerRow*map.rows;
    FOR i:=0 TO de DO
      IF s.VAL(LONGINT,map.planes[i])+size#s.VAL(LONGINT,map.planes[i+1]) THEN
        ret:=FALSE;
      END;
    END;
  END;
  RETURN ret;
END CheckOneBlock;

PROCEDURE BlitFast*(source:g.BitMapPtr;xs,ys:INTEGER;dest:g.BitMapPtr;xd,yd:INTEGER;wi,he,de:INTEGER);
(* xs,xd und wi sind wortgebunden! *)

VAR starta,startd: s.ADDRESS;
    bltsize      : INTEGER;
    offseta,
    offsetd      : LONGINT;
    moda,modd,a  : INTEGER;

BEGIN
  (* Ganz zu Anfang wird gewartet, bis der Blitter nichts mehr arbeitet. *)
  REPEAT
  UNTIL NOT(h.bltdone IN h.custom.dmaconr);

  (* offset enthält die Anzahl an Bytes, die zur Startaddresse einer Bitplane
     dazuaddiert werden müssen, damit man die Startaddresse des Bereichs
     erhält. Sie wird für den Quell- und den Zielbereich getrennt berechnet,
     da diese ja unterschiedliche Dimensionen haben können. *)
  offseta:=(source.bytesPerRow*ys);
  offseta:=offseta+(xs DIV 8);
  offsetd:=(dest.bytesPerRow*yd);
  offsetd:=offsetd+(xd DIV 8);

  (* mod enthält den Modulowert für einen Datenbereich. *)
  moda:=source.bytesPerRow-(wi DIV 8);
  modd:=dest.bytesPerRow-(wi DIV 8);

  (* Hier wird der Wert für das bltsize-Register berechnet. Da der
     Kopiervorgang gestartet wird, wenn wir das Register beschreiben,
     wird er zunächst in einer Variablen zwischengespeichert. *)
  bltsize:=he*64+(wi DIV 16);

  (* Hier wird die Blitter-DMA eingeschaltet. *)
  INCL(h.custom.dmaconr,h.blitter);

  (* bltcon1 wird ganz gelöscht. Damit ist gewährleistet, daß der Blitter
     im Kopiermodus ist. *)
  h.custom.bltcon1:=SET{};
  h.custom.bltamod:=moda;
  h.custom.bltdmod:=modd;

  (* Setzen der Minterme und Einschalten von Quelle A und des Zielbereichs. *)
  h.custom.bltcon0:=SET{h.anbnc,h.anbc,h.abnc,h.abc,h.dest,h.srcA};

  (* Die Maske für das erste und das letzte Wort muß vollständig
     gesetzt sein, damit der Blitter die ersten und letzten Wörter jeder
     Zeile mitkopiert. *)
  h.custom.bltafwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
  h.custom.bltalwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};

  a:=-1;
  WHILE a<de-1 DO
    INC(a);

    (* Die Addressen für bltapt und bltdpt werden zuerst in Variablen
       gespeichert, da der Blitter immer noch die Daten der vorherigen
       Bitplane kopiert und wir die Register erst beschreiben können,
       wenn der Blitter fertig ist. *)
    starta:=source.planes[a];
    starta:=s.VAL(s.ADDRESS,s.VAL(LONGINT,starta)+offseta);
    startd:=dest.planes[a];
    startd:=s.VAL(s.ADDRESS,s.VAL(LONGINT,startd)+offsetd);

    (* Warten, bis der Blitter die letzte Bitplane kopiert hat. *)
    REPEAT
    UNTIL NOT(h.bltdone IN h.custom.dmaconr);
    h.custom.bltapt:=starta;
    h.custom.bltdpt:=startd;

    (* Mit dem Setzen von bltsize wird der Kopiervorgang gestartet. *)
    h.custom.bltsize:=bltsize;
  END;
END BlitFast;

PROCEDURE Blit*(source:g.BitMapPtr;xs,ys:INTEGER;dest:g.BitMapPtr;xd,yd:INTEGER;wi,he,de:INTEGER);
(* xd und wi sind wortgebunden. xs pixelweise.
   Außerdem gibt es bei einem nicht auf einer Wortgrenze liegendem xs einen
   schwarzen Balken im Zielbereich links neben der Grafik. Dies stört bei
   einer Kopie in eine schwarzen Bildschirm oder bei xd=0 nicht.
   Die einfachste und schnellste Möglichkeit den schwarzen Balken zu
   beseitigen, besteht darin, mit BlitFast noch einen 16 Pixel breiten
   Streifen links neben die Grafik zu kopieren. *)

VAR starta,startd: s.ADDRESS;
    bltsize      : INTEGER;
    offseta,
    offsetd      : LONGINT;
    moda,modd    : INTEGER;
    a,j,
    wordoffset   : INTEGER;
    vset,fm,lm,vs: SET;
    blt0,fwm,lwm : SET;

BEGIN
  REPEAT
  UNTIL NOT(h.bltdone IN h.custom.dmaconr);

  (* Zunächst wird wird ausgerechnet, um wieviel Pixel sich xs vom nächsten
     linken Wort unterscheidet. *)
  wordoffset:=xs MOD 16;

  IF wordoffset>0 THEN
    (* Bei einem nicht auf Wortgrenzen liegenden xs wird xs auf eine Wortgrenze
       gesetzt. Um den Quellbereich nach rechts auf die nächste Wortgrenze
       schieben zu können, müssen wir die Breite um 1 Wort vergrößern, damit
       noch alles mitkopiert wird. Außerdem müssen wir xd um 1 Wort
       verkleinern, da wir durch das Verschieben nach rechts ja auf der
       linken Seite 1 Wort Daten haben, die nicht zur Grafik gehören. *)
    wi:=wi+16;
    xs:=xs-wordoffset;
    xd:=xd-16;

    (* Hier wird wordoffset gleich in die Anzahl der zu verschiebenden Pixel
       umgerechnet. *)
    wordoffset:=16-wordoffset;
  END;

  offseta:=(source.bytesPerRow*ys);
  offseta:=offseta+(xs DIV 8);
  offsetd:=(dest.bytesPerRow*yd);
  offsetd:=offsetd+(xd DIV 8);
  moda:=source.bytesPerRow-(wi DIV 8);
  modd:=dest.bytesPerRow-(wi DIV 8);
  bltsize:=he*64+(wi DIV 16);

  INCL(h.custom.dmaconr,h.blitter);
  blt0:=SET{h.anbnc,h.anbc,h.abnc,h.abc,h.dest,h.srcA};
  h.custom.bltcon1:=SET{};
  h.custom.bltamod:=moda;
  h.custom.bltdmod:=modd;
  fwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
  lwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};

  IF wordoffset>0 THEN
    (* Um die Bits 12-15 des bltcon0-Registers einfach mit dem 4-Bit Wert zum
       Verschieben von Quelle A beschreiben können, wird blt0, das zunächst
       in eine INTEGER-Zahl umgewandelt. Danach Rotieren wir diese um 4 Bits
       nach links, was dazu führt, daß die Bits 12-15 nun die unteren 4 Bits
       darstellen. Wir können nun einfach durch addieren die gewünschte
       Verschiebung in das register schreiben. Aufpassen müssen wir hierbei
       nur, daß die Verschiebung zwischen 0 und 15 liegen muß, da sonst
       andere Bits des Registers überschrieben werden. Danach wird der Wert
       wieder um 4 Bits nach rechts rotiert und blt0 in einen SET-Typ
       umgewandelt. *)
    j:=s.VAL(INTEGER,blt0);
    j:=s.ROT(j,4);
    j:=j+wordoffset;
    j:=s.ROT(j,-4);
    blt0:=s.VAL(SET,j);

    (* Die Maske für das erste und das letzte Wort muß noch korrekt gesetzt
       werden. Dies geschieht durch Verschieben der Werte, da alle neu
       hereingeschobenen Bits auf null gesetzt werden. Aus dem teilweise
       maskierten Bereich des ersten Wortes resultiert der schwarze Balken
       links neben der Grafik. *)
    fwm:=s.LSH(fwm,-(16-wordoffset));
    lwm:=s.LSH(lwm,wordoffset);
  END;
  h.custom.bltcon0:=blt0;
  h.custom.bltafwm:=fwm;
  h.custom.bltalwm:=lwm;

(*  IF NOT(CheckOneBlock(source,5)) OR NOT(CheckOneBlock(dest,5)) OR NOT(source.rows=he) OR NOT(dest.rows=he) THEN*)
    a:=-1;
    WHILE a<de-1 DO
      INC(a);
      starta:=source.planes[a];
      starta:=s.VAL(s.ADDRESS,s.VAL(LONGINT,starta)+offseta);
      startd:=dest.planes[a];
      startd:=s.VAL(s.ADDRESS,s.VAL(LONGINT,startd)+offsetd);
      REPEAT
      UNTIL NOT(h.bltdone IN h.custom.dmaconr);
      h.custom.bltapt:=starta;
      h.custom.bltdpt:=startd;
      h.custom.bltsize:=bltsize;
    END;
(*  ELSE
    bltsize:=he*64*de+(wi DIV 16);
    starta:=source.planes[0];
    starta:=s.VAL(s.ADDRESS,s.VAL(LONGINT,starta)+offseta);
    startd:=dest.planes[0];
    startd:=s.VAL(s.ADDRESS,s.VAL(LONGINT,startd)+offsetd);
    h.custom.bltapt:=starta;
    h.custom.bltdpt:=startd;
    h.custom.bltsize:=bltsize;
  END;*)
END Blit;

PROCEDURE FreeBlitAB*;

BEGIN
  IF blitamask#NIL THEN
    DISPOSE(blitamask);
  END;
END FreeBlitAB;

PROCEDURE PrepareBlitAB*(wi,he:INTEGER);

VAR ptri,ptri2 : LONGINT;

BEGIN
  FreeBlitAB;
  blitalen:=((wi+7+16) DIV 8)*he;
  blitalen:=(blitalen+3) DIV 4;
  INCL(ol.MemReqs,e.chip);
  NEW(blitamask,blitalen);
  EXCL(ol.MemReqs,e.chip);
  FOR ptri:=0 TO blitalen-1 DO
    blitamask[ptri]:=s.VAL(LONGINT,LONGSET{0..31});
  END;
END PrepareBlitAB;

PROCEDURE BlitA*(source:g.BitMapPtr;xs,ys:INTEGER;dest:g.BitMapPtr;xd,yd:INTEGER;wi,he,de:INTEGER);
(* Wie Blit, aber ohne den schwarzen Balken am linken Rand. *)

VAR starta,startd: s.ADDRESS;
    bltsize      : INTEGER;
    offseta,
    offsetd      : LONGINT;
    moda,modd    : INTEGER;
    a,j,
    wordoffset   : INTEGER;
    vset,fm,lm,vs: SET;
    blt0,fwm,lwm,blt1 : SET;

BEGIN
  REPEAT
  UNTIL NOT(h.bltdone IN h.custom.dmaconr);

  wordoffset:=xs MOD 16;
  IF wordoffset>0 THEN
    wi:=wi+16;
    xs:=xs-wordoffset;
    xd:=xd-16;
    wordoffset:=16-wordoffset;
  END;

  offseta:=(source.bytesPerRow*ys);
  offseta:=offseta+(xs DIV 8);
  offsetd:=(dest.bytesPerRow*yd);
  offsetd:=offsetd+(xd DIV 8);
  moda:=source.bytesPerRow-(wi DIV 8);
  modd:=dest.bytesPerRow-(wi DIV 8);
  bltsize:=he*64+(wi DIV 16);

  INCL(h.custom.dmaconr,h.blitter);
  blt0:=SET{h.nanbc,h.nabc,h.abnc,h.abc,h.dest,h.srcA,h.srcB,h.srcC};
  blt1:=SET{};
  h.custom.bltamod:=0;
  h.custom.bltbmod:=moda;
  h.custom.bltcmod:=modd;
  h.custom.bltdmod:=modd;
  fwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
  lwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};

  IF wordoffset>0 THEN
    j:=s.VAL(INTEGER,blt1);
    j:=s.ROT(j,4);
    j:=j+wordoffset;
    j:=s.ROT(j,-4);
    blt1:=s.VAL(SET,j);
    fwm:=SET{};
  END;
  h.custom.bltcon0:=blt0;
  h.custom.bltcon1:=blt1;
  h.custom.bltafwm:=fwm;
  h.custom.bltalwm:=lwm;

  a:=-1;
  WHILE a<de-1 DO
    INC(a);
    starta:=source.planes[a];
    starta:=s.VAL(s.ADDRESS,s.VAL(LONGINT,starta)+offseta);
    startd:=dest.planes[a];
    startd:=s.VAL(s.ADDRESS,s.VAL(LONGINT,startd)+offsetd);
    REPEAT
    UNTIL NOT(h.bltdone IN h.custom.dmaconr);
    h.custom.bltapt:=s.ADR(blitamask^);
    h.custom.bltbpt:=starta;
    h.custom.bltcpt:=startd;
    h.custom.bltdpt:=startd;
    h.custom.bltsize:=bltsize;
  END;
END BlitA;

PROCEDURE BlitB*(source:g.BitMapPtr;xs,ys:INTEGER;dest:g.BitMapPtr;xd,yd:INTEGER;wi,he,de:INTEGER);
(* Wie Blit, aber ohne den schwarzen Balken am linken Rand. *)

VAR starta,startd: s.ADDRESS;
    bltsize      : INTEGER;
    offseta,
    offsetd      : LONGINT;
    moda,modd    : INTEGER;
    a,j,
    wordoffset,
    maskoffset   : INTEGER;
    vset,fm,lm,vs: SET;
    blt0,fwm,lwm,blt1 : SET;

BEGIN
  REPEAT
  UNTIL NOT(h.bltdone IN h.custom.dmaconr);

  maskoffset:=xs MOD 16;
  xs:=xs-maskoffset;
  wordoffset:=maskoffset-(xd MOD 16);
  IF (wordoffset>0) OR (maskoffset>0) THEN
    wi:=wi+16;
    IF wordoffset>0 THEN
      xd:=xd-16;
      wordoffset:=16-wordoffset;
    ELSIF wordoffset<0 THEN
(*      wordoffset:=ABS(wordoffset);*)
    END;
  END;
(*  maskoffset:=maskoffset+(xd MOD 16);*)

  offseta:=(source.bytesPerRow*ys);
  offseta:=offseta+(xs DIV 8);
  offsetd:=(dest.bytesPerRow*yd);
  offsetd:=offsetd+(xd DIV 8);
  moda:=source.bytesPerRow-(wi DIV 8);
  modd:=dest.bytesPerRow-(wi DIV 8);
  bltsize:=he*64+(wi DIV 16);

  INCL(h.custom.dmaconr,h.blitter);
  blt0:=SET{h.nanbc,h.nabc,h.abnc,h.abc,h.dest,h.srcA,h.srcB,h.srcC};
  blt1:=SET{};
  h.custom.bltamod:=0;
  h.custom.bltbmod:=moda;
  h.custom.bltcmod:=modd;
  h.custom.bltdmod:=modd;
  fwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
  lwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};

  IF (wordoffset>0) OR (maskoffset>0) THEN
    j:=s.VAL(INTEGER,blt1);
    j:=s.ROT(j,4);
    j:=j+ABS(wordoffset);
    j:=s.ROT(j,-4);
    blt1:=s.VAL(SET,j);
(*    j:=s.VAL(INTEGER,blt0);
    j:=s.ROT(j,4);
    j:=j+wordoffset;
    j:=s.ROT(j,-4);
    blt0:=s.VAL(SET,j);*)

    IF wordoffset>-1 THEN
      fwm:=s.LSH(fwm,-maskoffset);
      lwm:=s.LSH(lwm,16-maskoffset);
    ELSE
      lwm:=SET{};
    END;
  END;
  h.custom.bltcon0:=blt0;
  h.custom.bltcon1:=blt1;
  h.custom.bltafwm:=fwm;
  h.custom.bltalwm:=lwm;

  a:=-1;
  WHILE a<de-1 DO
    INC(a);
    starta:=source.planes[a];
    starta:=s.VAL(s.ADDRESS,s.VAL(LONGINT,starta)+offseta);
    startd:=dest.planes[a];
    startd:=s.VAL(s.ADDRESS,s.VAL(LONGINT,startd)+offsetd);
    REPEAT
    UNTIL NOT(h.bltdone IN h.custom.dmaconr);
    h.custom.bltapt:=s.ADR(blitamask^);
    h.custom.bltbpt:=starta;
    h.custom.bltcpt:=startd;
    h.custom.bltdpt:=startd;
    h.custom.bltsize:=bltsize;
  END;
END BlitB;

PROCEDURE BlitASlow*(source:g.BitMapPtr;xs,ys:INTEGER;dest:g.BitMapPtr;xd,yd:INTEGER;wi,he,de:INTEGER);
(* Wie BlitA, nur langsamer. Benötigt aber keinen zusätzlichen Speicherblock. *)

VAR starta,startd: s.ADDRESS;
    bltsize      : INTEGER;
    offseta,
    offsetd      : LONGINT;
    moda,modd    : INTEGER;
    a,j,
    wordoffset   : INTEGER;
    vset,fm,lm,vs: SET;
    blt0,fwm,lwm,blt1 : SET;

BEGIN
  REPEAT
  UNTIL NOT(h.bltdone IN h.custom.dmaconr);

  wordoffset:=xs MOD 16;
  IF wordoffset>0 THEN
    wi:=wi+16;
    xs:=xs-wordoffset;
    xd:=xd-16;
    wordoffset:=16-wordoffset;
  END;

  offseta:=(source.bytesPerRow*ys);
  offseta:=offseta+(xs DIV 8);
  offsetd:=(dest.bytesPerRow*yd);
  offsetd:=offsetd+(xd DIV 8);
  moda:=source.bytesPerRow-(wi DIV 8);
  modd:=dest.bytesPerRow-(wi DIV 8);
  bltsize:=he*64+(wi DIV 16);

  INCL(h.custom.dmaconr,h.blitter);
  blt0:=SET{h.dest,h.srcA};
  blt1:=SET{};
  fwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
  lwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};

  h.custom.bltcon0:=blt0;
  h.custom.bltcon1:=blt1;
  h.custom.bltafwm:=fwm;
  h.custom.bltalwm:=lwm;

  IF wordoffset>0 THEN
    j:=2;
  ELSE
    j:=0;
  END;

  h.custom.bltamod:=modd+j;
  h.custom.bltdmod:=modd+j;

  a:=-1;
  WHILE a<de-1 DO
    INC(a);
    startd:=dest.planes[a];
    startd:=s.VAL(s.ADDRESS,s.VAL(LONGINT,startd)+offsetd+j);
    REPEAT
    UNTIL NOT(h.bltdone IN h.custom.dmaconr);
    h.custom.bltapt:=startd;
    h.custom.bltdpt:=startd;
    h.custom.bltsize:=bltsize-(j DIV 2);
  END;

  REPEAT
  UNTIL NOT(h.bltdone IN h.custom.dmaconr);
  blt0:=SET{h.nabnc,h.nabc,h.anbnc,h.anbc,h.dest,h.srcA,h.srcB};
  blt1:=SET{};
  h.custom.bltamod:=moda;
  h.custom.bltbmod:=modd;
  h.custom.bltdmod:=modd;
  fwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
  lwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};

  IF wordoffset>0 THEN
    j:=s.VAL(INTEGER,blt0);
    j:=s.ROT(j,4);
    j:=j+wordoffset;
    j:=s.ROT(j,-4);
    blt0:=s.VAL(SET,j);
    fwm:=s.LSH(fwm,-(16-wordoffset));
    lwm:=s.LSH(lwm,wordoffset);
  END;
  h.custom.bltcon0:=blt0;
  h.custom.bltcon1:=blt1;
  h.custom.bltafwm:=fwm;
  h.custom.bltalwm:=lwm;

  a:=-1;
  WHILE a<de-1 DO
    INC(a);
    starta:=source.planes[a];
    starta:=s.VAL(s.ADDRESS,s.VAL(LONGINT,starta)+offseta);
    startd:=dest.planes[a];
    startd:=s.VAL(s.ADDRESS,s.VAL(LONGINT,startd)+offsetd);
    REPEAT
    UNTIL NOT(h.bltdone IN h.custom.dmaconr);
    h.custom.bltapt:=starta;
    h.custom.bltbpt:=startd;
    h.custom.bltdpt:=startd;
    h.custom.bltsize:=bltsize;
  END;
END BlitASlow;

PROCEDURE BlitTrans*(source:g.BitMapPtr;xs,ys:INTEGER;dest:g.BitMapPtr;xd,yd:INTEGER;wi,he,de:INTEGER;mask:g.BitMapPtr);
(* Prozedur zum Kopieren mit Maske.
   xd pixelweise. Das Zielpixel wird von der Quelle übernommen, wenn das
   entsprechende Pixel in der Maske gesetzt ist. Andernfalls wird das
   Pixel in der Zielbitmap unverändert gelassen.
   mask muß die gleichen Ausmaße wie source und eine Tiefe von 1 haben. *)

VAR starta,startd,
    startb       : s.ADDRESS;
    bltsize      : INTEGER;
    offseta,
    offsetd      : LONGINT;
    moda,modd    : INTEGER;
    a,j,
    wordoffset   : INTEGER;
    vset,fm,lm,vs: SET;
    blt0,blt1    : SET;

BEGIN
  REPEAT
  UNTIL NOT(h.bltdone IN h.custom.dmaconr);
  wordoffset:=xd MOD 16;
  IF (wordoffset>0) AND (wordoffset<16) THEN
    xd:=xd-wordoffset;
    wi:=wi+16;
  END;
  offseta:=(source.bytesPerRow*ys);
  offseta:=offseta+(xs DIV 8);
  offsetd:=(dest.bytesPerRow*yd);
  offsetd:=offsetd+(xd DIV 8);
  moda:=source.bytesPerRow-(wi DIV 8);
  modd:=dest.bytesPerRow-(wi DIV 8);
  bltsize:=he*64+(wi DIV 16);

  INCL(h.custom.dmaconr,h.blitter);
  blt0:=SET{h.nanbc,h.nabc,h.abnc,h.abc,h.dest,h.srcA,h.srcB,h.srcC};
  blt1:=SET{};
  h.custom.bltamod:=moda;
  h.custom.bltbmod:=moda;
  h.custom.bltcmod:=modd;
  h.custom.bltdmod:=modd;

  h.custom.bltafwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
  h.custom.bltalwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
  IF wordoffset>0 THEN
    j:=s.VAL(INTEGER,blt0);
    j:=s.ROT(j,4);
    j:=j+wordoffset;
    j:=s.ROT(j,-4);
    blt0:=s.VAL(SET,j);
    j:=s.VAL(INTEGER,blt1);
    j:=s.ROT(j,4);
    j:=j+wordoffset;
    j:=s.ROT(j,-4);
    blt1:=s.VAL(SET,j);
    h.custom.bltalwm:=SET{};
  END;
  h.custom.bltcon0:=blt0;
  h.custom.bltcon1:=blt1;

  a:=-1;
  WHILE a<de-1 DO
    INC(a);
    starta:=mask.planes[0];
    starta:=s.VAL(s.ADDRESS,s.VAL(LONGINT,starta)+offseta);
    startb:=source.planes[a];
    startb:=s.VAL(s.ADDRESS,s.VAL(LONGINT,startb)+offseta);
    startd:=dest.planes[a];
    startd:=s.VAL(s.ADDRESS,s.VAL(LONGINT,startd)+offsetd);
    REPEAT
    UNTIL NOT(h.bltdone IN h.custom.dmaconr);
    h.custom.bltapt:=starta;
    h.custom.bltbpt:=startb;
    h.custom.bltcpt:=startd;
    h.custom.bltdpt:=startd;
    h.custom.bltsize:=bltsize;
  END;
END BlitTrans;

PROCEDURE BlitTransOld*(source:g.BitMapPtr;xs,ys:INTEGER;dest:g.BitMapPtr;xd,yd:INTEGER;wi,he,de:INTEGER;mask:g.BitMapPtr);

VAR mapa,mapd,map3: g.BitMapPtr;
    starta,startd,
    startsh,startb : s.ADDRESS;
    bltsize      : INTEGER;
    offseta,
    offsetd,
    offsetb      : LONGINT;
    moda,modd,modb : INTEGER;
    a,j,
    wordoffset   : INTEGER;
    vset,fm,lm,vs: SET;
    blt0,fwm,lwm : SET;

BEGIN
  REPEAT
  UNTIL NOT(14 IN h.custom.dmaconr);
  wordoffset:=xd MOD 16;
  IF (wordoffset>0) AND (wordoffset<16) THEN
    xd:=xd-wordoffset;
    wi:=wi+16;
  END;
  mapa:=source;
  mapd:=dest;
  offseta:=(mapa.bytesPerRow*ys);
  offseta:=offseta+(xs DIV 8);
  offsetd:=(mapd.bytesPerRow*yd);
  offsetd:=offsetd+(xd DIV 8);
  moda:=mapa.bytesPerRow-(wi DIV 8);
  modd:=mapd.bytesPerRow-(wi DIV 8);
  bltsize:=he*64+(wi DIV 16);

  INCL(h.custom.dmaconr,h.blitter);
  blt0:=SET{2,3,8,10,11};
  h.custom.bltcon1:=SET{};
  h.custom.bltamod:=moda;
  h.custom.bltbmod:=modd;
  h.custom.bltdmod:=modd;

  h.custom.bltafwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
  h.custom.bltalwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
  IF wordoffset>0 THEN
    j:=s.VAL(INTEGER,blt0);
    j:=s.ROT(j,4);
    j:=j+wordoffset;
    j:=s.ROT(j,-4);
    blt0:=s.VAL(SET,j);
    h.custom.bltalwm:=SET{};
  END;
  h.custom.bltcon0:=blt0;

  REPEAT
  UNTIL NOT(14 IN h.custom.dmaconr);
  a:=-1;
  WHILE a<de-1 DO
    INC(a);
    starta:=mask.planes[0];
    starta:=s.VAL(s.ADDRESS,s.VAL(LONGINT,starta)+offseta);
    startd:=dest.planes[a];
    startd:=s.VAL(s.ADDRESS,s.VAL(LONGINT,startd)+offsetd);
    REPEAT
    UNTIL NOT(14 IN h.custom.dmaconr);
    h.custom.bltapt:=starta;
    h.custom.bltbpt:=startd;
    h.custom.bltdpt:=startd;
    h.custom.bltsize:=bltsize;
  END;
  REPEAT
  UNTIL NOT(14 IN h.custom.dmaconr);

  blt0:=SET{2,3,4,5,6,7,8,10,11};
  IF wordoffset>0 THEN
    j:=s.VAL(INTEGER,blt0);
    j:=s.ROT(j,4);
    j:=j+wordoffset;
    j:=s.ROT(j,-4);
    blt0:=s.VAL(SET,j);
  END;
  h.custom.bltcon0:=blt0;

  a:=-1;
  WHILE a<de-1 DO
    INC(a);
    starta:=source.planes[a];
    starta:=s.VAL(s.ADDRESS,s.VAL(LONGINT,starta)+offseta);
    startd:=dest.planes[a];
    startd:=s.VAL(s.ADDRESS,s.VAL(LONGINT,startd)+offsetd);
    REPEAT
    UNTIL NOT(14 IN h.custom.dmaconr);
    h.custom.bltapt:=starta;
    h.custom.bltbpt:=startd;
    h.custom.bltdpt:=startd;
    h.custom.bltsize:=bltsize;
  END;
END BlitTransOld;

PROCEDURE BlitterPri*(blitterpri:BOOLEAN);

BEGIN
  IF blitterpri THEN
    INCL(h.custom.dmaconr,h.blithog);
  ELSE
    EXCL(h.custom.dmaconr,h.blithog);
  END;
END BlitterPri;

PROCEDURE WaitBlitter*;

BEGIN
  REPEAT
  UNTIL NOT(h.bltdone IN h.custom.dmaconr);
END WaitBlitter;

PROCEDURE Blit2*(source:g.BitMapPtr;xs,ys:INTEGER;dest:g.BitMapPtr;xd,yd:INTEGER;wi,he,de:INTEGER;sync:BOOLEAN);

VAR mapa,mapd    : g.BitMapPtr;
    starta,startd: s.ADDRESS;
    bltsize      : INTEGER;
    offseta,
    offsetd      : LONGINT;
    moda,modd    : INTEGER;
    a,j,
    wordoffset,
    wordoffset2  : INTEGER;
    vset,fm,lm,vs: SET;
    blt0,fwm,lwm : SET;

BEGIN
  wordoffset:=xs MOD 16;
  wordoffset2:=xd MOD 16;
  IF (wordoffset>0) OR (wordoffset2>0) THEN
    wi:=wi+16;
  END;

  mapa:=source;
  mapd:=dest;
  offseta:=(mapa.bytesPerRow*ys);
  offseta:=offseta+(xs DIV 8);
  offsetd:=(mapd.bytesPerRow*yd);
  offsetd:=offsetd+(xd DIV 8);
  moda:=mapa.bytesPerRow-(wi DIV 8);
  modd:=mapd.bytesPerRow-(wi DIV 8);
  bltsize:=he*64+(wi DIV 16);

  h.custom.dmaconr:=SET{h.blitter,h.blithog};
  blt0:=SET{4,5,6,7,8,11};
  h.custom.bltcon1:=SET{};
  h.custom.bltamod:=moda;
  h.custom.bltdmod:=modd;
  fwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
  lwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};

  IF (wordoffset>0) OR (wordoffset2>0) THEN
    j:=s.VAL(INTEGER,blt0);
    j:=s.ROT(j,4);
    j:=j+wordoffset2;
    j:=s.ROT(j,-4);
    blt0:=s.VAL(SET,j);
    IF (wordoffset>0) OR (wordoffset2>0) THEN
      wordoffset:=wordoffset-wordoffset2;
      fwm:=s.LSH(fwm,-wordoffset);
      lwm:=s.LSH(lwm,16-wordoffset);
    END;
  END;
  h.custom.bltcon0:=blt0;
  h.custom.bltafwm:=fwm;
  h.custom.bltalwm:=lwm;

  REPEAT
  UNTIL NOT(14 IN h.custom.dmaconr);
  a:=-1;
  IF sync THEN
    g.WaitTOF;
  END;
  WHILE a<de-1 DO
    INC(a);
    starta:=source.planes[a];
    starta:=s.VAL(s.ADDRESS,s.VAL(LONGINT,starta)+offseta);
    startd:=dest.planes[a];
    startd:=s.VAL(s.ADDRESS,s.VAL(LONGINT,startd)+offsetd);
    REPEAT
    UNTIL NOT(14 IN h.custom.dmaconr);
    h.custom.bltapt:=starta;
    h.custom.bltdpt:=startd;
    h.custom.bltsize:=bltsize;
  END;
  REPEAT
  UNTIL NOT(14 IN h.custom.dmaconr);
END Blit2;

PROCEDURE BlitTrans2*(source:g.BitMapPtr;xs,ys:INTEGER;dest:g.BitMapPtr;xd,yd:INTEGER;wi,he,de:INTEGER;mask:g.BitMapPtr;sync:BOOLEAN);

VAR mapa,mapd,map3: g.BitMapPtr;
    starta,startd,
    startsh,startb : s.ADDRESS;
    bltsize      : INTEGER;
    offseta,
    offsetd,
    offsetb      : LONGINT;
    moda,modd,modb : INTEGER;
    a,j,
    wordoffset   : INTEGER;
    vset,fm,lm,vs: SET;
    blt0,fwm,lwm : SET;

BEGIN
  wordoffset:=xd MOD 16;
  IF wordoffset>0 THEN
    xd:=xd-wordoffset;
    wi:=wi+16;
  END;
  mapa:=source;
  mapd:=dest;
  offseta:=(mapa.bytesPerRow*ys);
  offseta:=offseta+(xs DIV 8);
  offsetd:=(mapd.bytesPerRow*yd);
  offsetd:=offsetd+(xd DIV 8);
  moda:=mapa.bytesPerRow-(wi DIV 8);
  modd:=mapd.bytesPerRow-(wi DIV 8);
  bltsize:=he*64+(wi DIV 16);

  h.custom.dmaconr:=SET{h.blitter,h.blithog};
  blt0:=SET{2,3,8,10,11};
  h.custom.bltcon1:=SET{};
  h.custom.bltamod:=moda;
  h.custom.bltbmod:=modd;
  h.custom.bltdmod:=modd;

  h.custom.bltafwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
  h.custom.bltalwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
  IF wordoffset>0 THEN
    j:=s.VAL(INTEGER,blt0);
    j:=s.ROT(j,4);
    j:=j+wordoffset;
    j:=s.ROT(j,-4);
    blt0:=s.VAL(SET,j);
    h.custom.bltalwm:=SET{};
  END;
  h.custom.bltcon0:=blt0;

  REPEAT
  UNTIL NOT(14 IN h.custom.dmaconr);
  a:=-1;
  IF sync THEN
    g.WaitTOF;
  END;
  WHILE a<de-1 DO
    INC(a);
    starta:=mask.planes[0];
    starta:=s.VAL(s.ADDRESS,s.VAL(LONGINT,starta)+offseta);
    startd:=dest.planes[a];
    startd:=s.VAL(s.ADDRESS,s.VAL(LONGINT,startd)+offsetd);
    REPEAT
    UNTIL NOT(14 IN h.custom.dmaconr);
    h.custom.bltapt:=starta;
    h.custom.bltbpt:=startd;
    h.custom.bltdpt:=startd;
    h.custom.bltsize:=bltsize;
  END;
  REPEAT
  UNTIL NOT(14 IN h.custom.dmaconr);

  blt0:=SET{2,3,4,5,6,7,8,10,11};
  IF wordoffset>0 THEN
    j:=s.VAL(INTEGER,blt0);
    j:=s.ROT(j,4);
    j:=j+wordoffset;
    j:=s.ROT(j,-4);
    blt0:=s.VAL(SET,j);
  END;
  h.custom.bltcon0:=blt0;

  a:=-1;
  WHILE a<de-1 DO
    INC(a);
    starta:=source.planes[a];
    starta:=s.VAL(s.ADDRESS,s.VAL(LONGINT,starta)+offseta);
    startd:=dest.planes[a];
    startd:=s.VAL(s.ADDRESS,s.VAL(LONGINT,startd)+offsetd);
    REPEAT
    UNTIL NOT(14 IN h.custom.dmaconr);
    h.custom.bltapt:=starta;
    h.custom.bltbpt:=startd;
    h.custom.bltdpt:=startd;
    h.custom.bltsize:=bltsize;
  END;
  REPEAT
  UNTIL NOT(14 IN h.custom.dmaconr);
END BlitTrans2;

(*PROCEDURE Blit2*(source:g.BitMapPtr;xs,ys:INTEGER;dest:g.BitMapPtr;xd,yd:INTEGER;wi,he,de:INTEGER;sync:BOOLEAN);

VAR mapa,mapd    : g.BitMapPtr;
    starta,startd: s.ADDRESS;
    bltsize      : INTEGER;
    offseta,
    offsetd      : LONGINT;
    moda,modd    : INTEGER;
    a,j,
    wordoffset,
    wordoffset2  : INTEGER;
    vset,fm,lm,vs: SET;
    blt0,fwm,lwm : SET;

BEGIN
  wordoffset:=xs MOD 16;
  wordoffset2:=xd MOD 16;
  IF (wordoffset>0) OR (wordoffset2>0) THEN
    wi:=wi+16;
    xs:=xs-wordoffset;
    IF wordoffset>0 THEN
      xd:=xd-16;
    END;
(*    wordoffset:=16-wordoffset;*)
  END;
(*  IF (wordoffset2>0) AND (wordoffset2<16) THEN
    wordoffset2:=16-wordoffset2;
  END;*)
  mapa:=source;
  mapd:=dest;
  offseta:=(mapa.bytesPerRow*ys);
  offseta:=offseta+(xs DIV 8);
  offsetd:=(mapd.bytesPerRow*yd);
  offsetd:=offsetd+(xd DIV 8);
  moda:=mapa.bytesPerRow-(wi DIV 8);
  modd:=mapd.bytesPerRow-(wi DIV 8);
  bltsize:=he*64+(wi DIV 16);

  h.custom.dmaconr:=SET{h.blitter,h.blithog};
  blt0:=SET{4,5,6,7,8,11};
  h.custom.bltcon1:=SET{};
  h.custom.bltamod:=moda;
  h.custom.bltdmod:=modd;
  fwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
  lwm:=SET{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};

  IF (wordoffset>0) OR (wordoffset2>0) THEN
    j:=s.VAL(INTEGER,blt0);
    j:=s.ROT(j,4);
    j:=j+wordoffset2+wordoffset;
    j:=s.ROT(j,-4);
    blt0:=s.VAL(SET,j);
    fwm:=s.LSH(fwm,-wordoffset);
    IF wordoffset>0 THEN
      lwm:=s.LSH(lwm,16-wordoffset);
    END;
    IF wordoffset2>0 THEN
      lwm:=SET{};
    END;
  END;
  h.custom.bltcon0:=blt0;
  h.custom.bltafwm:=fwm;
  h.custom.bltalwm:=lwm;

  REPEAT
  UNTIL NOT(14 IN h.custom.dmaconr);
  a:=-1;
  IF sync THEN
    g.WaitTOF;
  END;
  WHILE a<de-1 DO
    INC(a);
    starta:=source.planes[a];
    starta:=s.VAL(s.ADDRESS,s.VAL(LONGINT,starta)+offseta);
    startd:=dest.planes[a];
    startd:=s.VAL(s.ADDRESS,s.VAL(LONGINT,startd)+offsetd);
    REPEAT
    UNTIL NOT(14 IN h.custom.dmaconr);
    h.custom.bltapt:=starta;
    h.custom.bltdpt:=startd;
    h.custom.bltsize:=bltsize;
  END;
  REPEAT
  UNTIL NOT(14 IN h.custom.dmaconr);
END Blit2;*)

BEGIN
  blitamask:=NIL;
CLOSE
  IF blitamask#NIL THEN
    DISPOSE(blitamask);
  END;
END BlitterTools.

