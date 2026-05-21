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


MODULE TextTools;

IMPORT I   : Intuition,
       g   : Graphics,
       e   : Exec,
       s   : SYSTEM,
       c   : Conversions,
       it  : IntuitionTools,
       st  : Strings,
       lrc : LongRealConversions;

(* $TypeChk- $NilChk- $OvflChk- $RangeChk- *)

PROCEDURE Clear*(VAR string:ARRAY OF CHAR);

VAR ci    : INTEGER;
    float : BOOLEAN;

BEGIN
  float:=FALSE;
  ci:=SHORT(st.Length(string));
  WHILE ci>0 DO
    DEC(ci);
    IF string[ci]="." THEN
      float:=TRUE;
    END;
  END;
  IF float THEN
    ci:=SHORT(st.Length(string));
    LOOP
      ci:=ci-1;
      IF string[ci]="0" THEN
        st.Delete(string,ci,1);
      ELSIF string[ci]="." THEN
        st.Delete(string,ci,1);
        EXIT;
      ELSE
        EXIT;
      END;
      IF ci=0 THEN EXIT;END;
    END;
  END;
  ci:=0;
  REPEAT
    IF string[ci]=" " THEN
      st.Delete(string,ci,1);
      ci:=ci-1;
    END;
    ci:=ci+1;
  UNTIL ci=st.Length(string);
END Clear;

PROCEDURE MoveDiffSign*(VAR str:ARRAY OF CHAR);

VAR i : INTEGER;

BEGIN
  i:=0;
  WHILE i<st.Length(str)-1 DO
    IF (str[i]="-") & (str[i+1]=" ") THEN
      str[i+1]:="-";
      str[i]:=" ";
    END;
    INC(i);
  END;
END MoveDiffSign;

PROCEDURE RealToString*(f:LONGREAL;VAR ub:ARRAY OF CHAR;exp:BOOLEAN):BOOLEAN;

VAR j,v,n : LONGINT;
    ok    : BOOLEAN;

BEGIN
  v:=1;
  j:=10;
  WHILE j<100000 DO
    IF ABS(f)>=j THEN
      v:=v+1;
    END;
    j:=j*10;
  END;
  IF SHORT(SHORT(f))=f THEN
    n:=0;
  ELSE
    n:=4;
  END;
  ok:=lrc.RealToString(f,ub,SHORT(v),SHORT(n),exp);
  Clear(ub);
  RETURN ok;
END RealToString;

PROCEDURE Print*(x,y:INTEGER;string:e.STRPTR;r:g.RastPortPtr);

BEGIN
  g.Move(r,x,y);
  g.Text(r,string^,st.Length(string^));
END Print;

PROCEDURE PrintInt*(x,y:INTEGER;int:LONGINT;v:INTEGER;r:g.RastPortPtr);

VAR string : ARRAY 20 OF CHAR;
    bool   : BOOLEAN;

BEGIN
  bool:=c.IntToString(int,string,v);
  g.Move(r,x,y);
  g.Text(r,string,st.Length(string));
END PrintInt;

PROCEDURE PrintMid*(x,y:INTEGER;f:LONGREAL;r:g.RastPortPtr);

VAR ub    : ARRAY 20 OF CHAR;
    j,v,n : LONGINT;
    ok    : BOOLEAN;

BEGIN
  v:=1;
  j:=10;
  WHILE j<100000 DO
    IF ABS(f)>=j THEN
      v:=v+1;
    END;
    j:=j*10;
  END;
  IF SHORT(SHORT(f))=f THEN
    n:=0;
  ELSE
    n:=4;
  END;
(*  v:=7;
  n:=7;*)
  ok:=lrc.RealToString(f,ub,SHORT(v),SHORT(n),FALSE);
  Clear(ub);
  Print(x-g.TextLength(r,ub,st.Length(ub)) DIV 2,y,s.ADR(ub),r);
END PrintMid;

PROCEDURE PrintRight*(x,y:INTEGER;f:LONGREAL;r:g.RastPortPtr);

VAR ub    : ARRAY 80 OF CHAR;
    j,v,n : LONGINT;
    ok    : BOOLEAN;

BEGIN
  v:=1;
  j:=10;
  WHILE j<100000 DO
    IF ABS(f)>=j THEN
      v:=v+1;
    END;
    j:=j*10;
  END;
  IF SHORT(SHORT(f))=f THEN
    n:=0;
  ELSE
    n:=4;
  END;
(*  v:=7;
  n:=7;*)
  ok:=lrc.RealToString(f,ub,SHORT(v),SHORT(n),FALSE);
  Clear(ub);
  Print(x-g.TextLength(r,ub,st.Length(ub)),y,s.ADR(ub),r);
END PrintRight;

PROCEDURE PrintLeft*(x,y:INTEGER;f:LONGREAL;r:g.RastPortPtr);

VAR ub    : ARRAY 80 OF CHAR;
    j,v,n : LONGINT;
    ok    : BOOLEAN;

BEGIN
  v:=1;
  j:=10;
  WHILE j<100000 DO
    IF ABS(f)>=j THEN
      v:=v+1;
    END;
    j:=j*10;
  END;
  IF SHORT(SHORT(f))=f THEN
    n:=0;
  ELSE
    n:=4;
  END;
(*  v:=7;
  n:=7;*)
  ok:=lrc.RealToString(f,ub,SHORT(v),SHORT(n),FALSE);
  Clear(ub);
  Print(x,y,s.ADR(ub),r);
END PrintLeft;

PROCEDURE PrintDown*(x,y:INTEGER;string:e.STRPTR;r:g.RastPortPtr);

VAR i   : INTEGER;
    str : ARRAY 2 OF CHAR;

BEGIN
  str[1]:=0X;
  FOR i:=0 TO SHORT(st.Length(string^)-1) DO
    str[0]:=string^[i];
    g.Move(r,x,y);
    g.Text(r,str,1);
    INC(y,r.txHeight);
  END;
END PrintDown;

PROCEDURE PrintText*(x,y:INTEGER;text:e.STRPTR;rast:g.RastPortPtr;xv,yv,zv:LONGREAL;nach:INTEGER;exp:BOOLEAN);

VAR str  : ARRAY 2 OF CHAR;
    str2 : ARRAY 80 OF CHAR;
    i    : INTEGER;
    bool : BOOLEAN;

BEGIN
  IF st.Length(text^)>0 THEN
    FOR i:=0 TO SHORT(st.Length(text^)-1) DO
      IF text^[i]#"$" THEN
        str[0]:=text^[i];
        str[1]:=0X;
        Print(x,y,s.ADR(str),rast);
        INC(x,g.TextLength(rast,str,1));
      ELSE
        INC(i);
        IF CAP(text^[i])="X" THEN
          bool:=lrc.RealToString(xv,str2,7,nach,exp);
          Clear(str2);
          Print(x,y,s.ADR(str2),rast);
          INC(x,g.TextLength(rast,str2,st.Length(str2)));
        ELSIF CAP(text^[i])="Y" THEN
          bool:=lrc.RealToString(yv,str2,7,nach,exp);
          Clear(str2);
          Print(x,y,s.ADR(str2),rast);
          INC(x,g.TextLength(rast,str2,st.Length(str2)));
        ELSIF CAP(text^[i])="Z" THEN
          bool:=lrc.RealToString(zv,str2,7,nach,exp);
          Clear(str2);
          Print(x,y,s.ADR(str2),rast);
          INC(x,g.TextLength(rast,str2,st.Length(str2)));
        ELSIF CAP(text^[i])="$" THEN
          str[0]:="$";
          str[1]:=0X;
          Print(x,y,s.ADR(str),rast);
          INC(x,g.TextLength(rast,str,1));
        END;
      END;
    END;
  END;
END PrintText;

PROCEDURE TextLength*(text:e.STRPTR;rast:g.RastPortPtr;xv,yv,zv:LONGREAL;nach:INTEGER;exp:BOOLEAN):INTEGER;

VAR str  : ARRAY 2 OF CHAR;
    str2 : ARRAY 80 OF CHAR;
    i,l  : INTEGER;
    length : INTEGER;
    bool   : BOOLEAN;

BEGIN
  length:=0;
  IF st.Length(text^)>0 THEN
    FOR i:=0 TO SHORT(st.Length(text^)-1) DO
      IF text^[i]#"$" THEN
        str[0]:=text^[i];
        str[1]:=0X;
        l:=g.TextLength(rast,str,1);
        INC(length,l);
      ELSE
        INC(i);
        IF CAP(text^[i])="X" THEN
          bool:=lrc.RealToString(xv,str2,7,nach,exp);
          Clear(str2);
          l:=g.TextLength(rast,str2,st.Length(str2));
          INC(length,l);
        ELSIF CAP(text^[i])="Y" THEN
          bool:=lrc.RealToString(yv,str2,7,nach,exp);
          Clear(str2);
          l:=g.TextLength(rast,str2,st.Length(str2));
          INC(length,l);
        ELSIF CAP(text^[i])="Z" THEN
          bool:=lrc.RealToString(zv,str2,7,nach,exp);
          Clear(str2);
          l:=g.TextLength(rast,str2,st.Length(str2));
          INC(length,l);
        ELSIF CAP(text^[i])="$" THEN
          str[0]:="$";
          str[1]:=0X;
          l:=g.TextLength(rast,str,1);
          INC(length,l);
        END;
      END;
    END;
  END;
  RETURN length;
END TextLength;

PROCEDURE PrintTextDown*(x,y:INTEGER;text:e.STRPTR;rast:g.RastPortPtr;xv,yv,zv:LONGREAL;nach:INTEGER;exp:BOOLEAN);

VAR str  : ARRAY 2 OF CHAR;
    str2 : ARRAY 80 OF CHAR;
    i    : INTEGER;
    bool : BOOLEAN;

BEGIN
  IF st.Length(text^)>0 THEN
    FOR i:=0 TO SHORT(st.Length(text^)-1) DO
      IF text^[i]#"$" THEN
        str[0]:=text^[i];
        str[1]:=0X;
        Print(x,y,s.ADR(str),rast);
        INC(y,rast.txHeight);
      ELSE
        INC(i);
        IF CAP(text^[i])="X" THEN
          bool:=lrc.RealToString(xv,str2,7,nach,exp);
          Clear(str2);
          PrintDown(x,y,s.ADR(str2),rast);
          INC(y,rast.txHeight*SHORT(st.Length(str2)));
        ELSIF CAP(text^[i])="Y" THEN
          bool:=lrc.RealToString(yv,str2,7,nach,exp);
          Clear(str2);
          PrintDown(x,y,s.ADR(str2),rast);
          INC(y,rast.txHeight*SHORT(st.Length(str2)));
        ELSIF CAP(text^[i])="Z" THEN
          bool:=lrc.RealToString(zv,str2,7,nach,exp);
          Clear(str2);
          PrintDown(x,y,s.ADR(str2),rast);
          INC(y,rast.txHeight*SHORT(st.Length(str2)));
        ELSIF CAP(text^[i])="$" THEN
          str[0]:="$";
          str[1]:=0X;
          Print(x,y,s.ADR(str),rast);
          INC(y,rast.txHeight);
        END;
      END;
    END;
  END;
END PrintTextDown;

PROCEDURE CutStringToLength*(rast:g.RastPortPtr;VAR string:ARRAY OF CHAR;width:INTEGER);

VAR i        : INTEGER;
    strwidth : LONGINT;
    str      : ARRAY 2 OF CHAR;

BEGIN
  i:=SHORT(st.Length(string));
  strwidth:=g.TextLength(rast,string,i);
  str[1]:=0X;
  WHILE (strwidth>width) AND (i>0) DO
    DEC(i);
    str[0]:=string[i];
    string[i]:=0X;
    strwidth:=strwidth-g.TextLength(rast,str,1);
  END;
END CutStringToLength;

PROCEDURE Compare*(str1,str2:ARRAY OF CHAR):BOOLEAN;
(* $CopyArrays- *)

VAR ret : BOOLEAN;
    i   : INTEGER;

BEGIN
  ret:=TRUE;
  IF st.Length(str1)#st.Length(str2) THEN
    ret:=FALSE;
  ELSIF st.Length(str1)>0 THEN
    FOR i:=0 TO SHORT(st.Length(str1)-1) DO
      IF CAP(str1[i])#CAP(str2[i]) THEN
        ret:=FALSE;
      END;
    END;
  END;
  RETURN ret;
END Compare;

PROCEDURE PrintRotatedChar*(xpos,ypos:INTEGER;ch:CHAR;rast:g.RastPortPtr;angle:INTEGER);

VAR buffer : g.RastPortPtr;
    wi,he,
    x,y,
    nx,ny  : INTEGER;
    str    : ARRAY 2 OF CHAR;
    bool   : BOOLEAN;

BEGIN
  str[0]:=ch;
  str[1]:=0X;
  wi:=g.TextLength(rast,str,1);
  he:=rast.txHeight;
  buffer:=it.AllocRastPort(wi,he,1);
  g.SetFont(buffer,rast.font);
  g.SetAPen(buffer,0);
  g.RectFill(buffer,0,0,wi-1,he-1);
  g.SetAPen(buffer,1);
  Print(0,rast.txBaseline,s.ADR(str),buffer);
  IF angle=90 THEN
    DEC(ypos,wi);
  END;
  x:=-1;
  WHILE x<wi-1 DO
    INC(x);
    y:=-1;
    WHILE y<he-1 DO
      INC(y);
      IF g.ReadPixel(buffer,x,y)>0 THEN
        IF angle=0 THEN
          nx:=x;
          ny:=y;
        ELSIF angle=90 THEN
          nx:=y;
          ny:=wi-1-x;
        ELSIF angle=-90 THEN
          nx:=he-1-y;
          ny:=x;
        END;
        INC(nx,xpos);
        INC(ny,ypos);
        bool:=g.WritePixel(rast,nx,ny);
      END;
    END;
  END;
  it.FreeRastPort(buffer);
END PrintRotatedChar;

PROCEDURE PrintRotated*(xpos,ypos:INTEGER;string:ARRAY OF CHAR;rast:g.RastPortPtr;angle:INTEGER);

VAR i,wi : INTEGER;
    str  : ARRAY 2 OF CHAR;

BEGIN
  str[1]:=0X;
  IF angle=90 THEN
    INC(ypos,g.TextLength(rast,string,st.Length(string)));
  END;
  FOR i:=0 TO SHORT(st.Length(string)-1) DO
    PrintRotatedChar(xpos,ypos,string[i],rast,angle);
    str[0]:=string[i];
    wi:=g.TextLength(rast,str,1);
    IF angle=0 THEN
      INC(xpos,wi);
    ELSIF angle=90 THEN
      DEC(ypos,wi);
    ELSIF angle=-90 THEN
      INC(ypos,wi);
    END;
  END;
END PrintRotated;

PROCEDURE PrintRotatedText*(x,y:INTEGER;text:e.STRPTR;rast:g.RastPortPtr;angle:INTEGER;xv,yv,zv:LONGREAL;nach:INTEGER;exp:BOOLEAN);

VAR str  : ARRAY 2 OF CHAR;
    str2 : ARRAY 80 OF CHAR;
    i,wi,
    wi2  : INTEGER;
    bool : BOOLEAN;

BEGIN
  IF angle=90 THEN
    INC(y,TextLength(text,rast,xv,yv,zv,nach,exp));
  END;
  IF st.Length(text^)>0 THEN
    FOR i:=0 TO SHORT(st.Length(text^)-1) DO
      wi:=0;
      IF text^[i]#"$" THEN
        str[0]:=text^[i];
        str[1]:=0X;
        PrintRotatedChar(x,y,text^[i],rast,angle);
        wi:=g.TextLength(rast,str,1);
      ELSE
        INC(i);
        IF CAP(text^[i])="X" THEN
          bool:=lrc.RealToString(xv,str2,7,nach,exp);
          Clear(str2);
          wi:=g.TextLength(rast,str2,st.Length(str2));
          IF angle=90 THEN
            wi2:=wi;
          ELSE
            wi2:=0;
          END;
          PrintRotated(x,y-wi2,str2,rast,angle);
        ELSIF CAP(text^[i])="Y" THEN
          bool:=lrc.RealToString(yv,str2,7,nach,exp);
          Clear(str2);
          wi:=g.TextLength(rast,str2,st.Length(str2));
          IF angle=90 THEN
            wi2:=wi;
          ELSE
            wi2:=0;
          END;
          PrintRotated(x,y-wi2,str2,rast,angle);
        ELSIF CAP(text^[i])="Z" THEN
          bool:=lrc.RealToString(zv,str2,7,nach,exp);
          Clear(str2);
          wi:=g.TextLength(rast,str2,st.Length(str2));
          IF angle=90 THEN
            wi2:=wi;
          ELSE
            wi2:=0;
          END;
          PrintRotated(x,y-wi2,str2,rast,angle);
        ELSIF CAP(text^[i])="$" THEN
          str[0]:="$";
          str[1]:=0X;
          PrintRotatedChar(x,y,"$",rast,angle);
          wi:=g.TextLength(rast,str,1);
        END;
      END;
      IF angle=90 THEN
        DEC(y,wi);
      ELSIF angle=-90 THEN
        INC(y,wi);
      END;
    END;
  END;
END PrintRotatedText;

PROCEDURE Append*(VAR str:ARRAY OF CHAR;str2:ARRAY OF CHAR);
(* $CopyArrays- *)

BEGIN
  IF st.Length(str)+st.Length(str2)<LEN(str) THEN
    st.Append(str,str2);
  END;
END Append;

PROCEDURE AppendChar*(VAR str:ARRAY OF CHAR;char:CHAR);
(* $CopyArrays- *)

BEGIN
  IF st.Length(str)+1<LEN(str) THEN
    st.AppendChar(str,char);
  END;
END AppendChar;

END TextTools.
