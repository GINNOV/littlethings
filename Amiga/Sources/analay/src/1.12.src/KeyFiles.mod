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


MODULE KeyFiles;

IMPORT I  : Intuition,
       d  : Dos,
       s  : SYSTEM,
       r  : Random,
       c  : Conversions,
       st : Strings,
       rq : Requests,
(*       io,*)
       NoGuruRq;

(* TypeChk+ NilChk+ OvflChk- RangeChk+ *)

TYPE string16 = ARRAY 2 OF CHAR;

VAR name   * ,
    filename : ARRAY 80 OF CHAR;
    keystr * : ARRAY 1024 OF CHAR;
    file     : d.FileHandlePtr;
    len,
    userId * : INTEGER;
    long     : LONGINT;
    bool,
    demo   * ,
    error  * : BOOLEAN;
    refpos * : ARRAY 10 OF INTEGER;

PROCEDURE NotInDemo*(window:I.WindowPtr);

VAR bool : BOOLEAN;

BEGIN
  bool:=rq.RequestWin("Diese Funktion ist in der unregistrierten","Demoversion nicht verfügbar!","","   OK   ",window);
END NotInDemo;

PROCEDURE Int*(str:ARRAY OF CHAR;pos:INTEGER):INTEGER;

VAR str16 : string16;

BEGIN
  str16[0]:=str[pos];
  str16[1]:=str[pos+1];
  RETURN s.VAL(INTEGER,str16);
END Int;

PROCEDURE WriteShort*(VAR str:ARRAY OF CHAR;VAR pos:INTEGER;int:SHORTINT);

VAR char : CHAR;

BEGIN
  char:=s.VAL(CHAR,int);
  str[pos]:=char;
  INC(pos);
END WriteShort;

PROCEDURE WriteInt*(VAR str:ARRAY OF CHAR;VAR pos:INTEGER;int:INTEGER);

VAR str16 : string16;

BEGIN
  int:=s.ROT(int,pos MOD 16);
  str16:=s.VAL(string16,int);
  str[pos]:=str16[0];
  str[pos+1]:=str16[1];
  INC(pos,2);
END WriteInt;

PROCEDURE ReadShort*(str:ARRAY OF CHAR;VAR pos:INTEGER;VAR int:SHORTINT);

VAR char : CHAR;

BEGIN
  int:=s.VAL(SHORTINT,str[pos]);
  INC(pos);
END ReadShort;

PROCEDURE ReadInt*(str:ARRAY OF CHAR;VAR pos:INTEGER;VAR int:INTEGER);

VAR str16 : string16;

BEGIN
  str16[0]:=str[pos];
  str16[1]:=str[pos+1];
  int:=s.VAL(INTEGER,str16);
  int:=s.ROT(int,-(pos MOD 16));
  INC(pos,2);
END ReadInt;

PROCEDURE Combine*(int1,int2,mode:INTEGER):INTEGER;

VAR i   : INTEGER;
    set1,
    set2,
    ret : SET;

BEGIN
  ret:=SET{};
  set1:=s.VAL(SET,int1);
  set2:=s.VAL(SET,int2);
  FOR i:=0 TO 15 DO
    IF mode=0 THEN (* AND *)
      IF (i IN set1) AND (i IN set2) THEN
        INCL(ret,i);
      END;
    ELSIF mode=1 THEN (* OR *)
      IF (i IN set1) OR (i IN set2) THEN
        INCL(ret,i);
      END;
    ELSIF mode=2 THEN (* XOR *)
      IF (i IN set1) OR NOT(i IN set2) THEN
        INCL(ret,i);
      END;
    ELSIF mode=3 THEN (* Special *)
      IF ((i IN set1) AND (i IN set2) AND (i MOD 2=0)) OR (((i IN set1) OR (i IN set2)) AND (i MOD 2#0)) THEN
        INCL(ret,i);
      END;
    END;
  END;
  RETURN s.VAL(INTEGER,ret);
END Combine;

PROCEDURE CombineChar*(int1,int2:CHAR;mode:INTEGER):CHAR;

VAR i   : INTEGER;
    set1,
    set2,
    ret : SHORTSET;

BEGIN
  ret:=SHORTSET{};
  set1:=s.VAL(SHORTSET,int1);
  set2:=s.VAL(SHORTSET,int2);
  FOR i:=0 TO 7 DO
    IF mode=0 THEN (* AND *)
      IF (i IN set1) AND (i IN set2) THEN
        INCL(ret,i);
      END;
    ELSIF mode=1 THEN (* OR *)
      IF (i IN set1) OR (i IN set2) THEN
        INCL(ret,i);
      END;
    ELSIF mode=2 THEN (* XOR *)
      IF (i IN set1) OR NOT(i IN set2) THEN
        INCL(ret,i);
      END;
    ELSIF mode=3 THEN (* Special *)
      IF ((i IN set1) AND (i IN set2) AND (i MOD 2=0)) OR (((i IN set1) OR (i IN set2)) AND (i MOD 2#0)) THEN
        INCL(ret,i);
      END;
    END;
  END;
  RETURN s.VAL(CHAR,ret);
END CombineChar;

PROCEDURE CreateKeyFile*(VAR keystring:ARRAY OF CHAR;name:ARRAY OF CHAR;userId:INTEGER):INTEGER;

VAR i,a,len,
    keypos    : INTEGER;
    str16,
    userIdStr : string16;
    str       : ARRAY 80 OF CHAR;

BEGIN
  len:=SHORT(st.Length(name));
  keystring:="";
  keypos:=0;
  userIdStr:=s.VAL(string16,userId);
  WriteInt(keystring,keypos,len);
  i:=0;
  WHILE i<len DO
    str16[0]:=name[i];
    str16[1]:=name[i+1];
    str16:=s.VAL(string16,s.ROT(s.VAL(SET,str16),(i MOD 15)+1));
    keystring[keypos]:=str16[0];
    keystring[keypos+1]:=str16[1];
    INC(keypos,2);
    INC(i,2);
    IF i>20 THEN
      INC(i,2);
    END;
  END;
  FOR i:=0 TO len-1 DO
    keystring[keypos]:=name[i];
    INC(keypos);
  END;
  WriteInt(keystring,keypos,r.RND(MAX(INTEGER)));
  WriteInt(keystring,keypos,r.RND(MAX(INTEGER)));
  WriteInt(keystring,keypos,s.VAL(SHORTINT,name[0])+s.VAL(SHORTINT,name[len-1]));
  WriteInt(keystring,keypos,s.VAL(SHORTINT,name[0])+s.VAL(SHORTINT,name[0]));
  FOR i:=0 TO len-1 BY 2 DO
    IF (i MOD 7#0) AND (i#10) AND (len MOD i#0) THEN
      WriteInt(keystring,keypos,s.VAL(SHORTINT,name[i])+s.VAL(SHORTINT,name[len-i-1]));
    ELSE
      WriteInt(keystring,keypos,r.RND(MAX(INTEGER)));
    END;
  END;
  keystring[keypos]:=userIdStr[0];
  INC(keypos);
  IF len>10 THEN
    WriteInt(keystring,keypos,Combine(Int(name,1),Int(name,2),0));
    WriteInt(keystring,keypos,r.RND(MAX(INTEGER)));
    WriteInt(keystring,keypos,Combine(Int(name,5),Int(name,9),3));
    WriteInt(keystring,keypos,Combine(Int(name,0),Int(name,0),2));
    WriteInt(keystring,keypos,Combine(Int(name,6),Int(name,3),0));
    WriteInt(keystring,keypos,Combine(Int(name,1),Int(name,2),1));
    WriteInt(keystring,keypos,r.RND(MAX(INTEGER)));
  END;
  keystring[keypos]:=CombineChar(userIdStr[0],userIdStr[1],3);
  INC(keypos);
  IF len>20 THEN
    WriteInt(keystring,keypos,Combine(Int(name,1),Int(name,17),0));
    WriteInt(keystring,keypos,Combine(Int(name,2),Int(name,15),1));
    WriteInt(keystring,keypos,Combine(Int(name,19),Int(name,5),0));
    WriteInt(keystring,keypos,r.RND(MAX(INTEGER)));
    WriteInt(keystring,keypos,Combine(Int(name,10),Int(name,9),3));
    WriteInt(keystring,keypos,Combine(Int(name,14),Int(name,0),2));
    WriteInt(keystring,keypos,r.RND(MAX(INTEGER)));
  END;
  keystring[keypos]:=userIdStr[1];
  INC(keypos);
  a:=len DIV 4;
  FOR i:=1 TO len-1 BY 2 DO
    keystring[keypos]:=CombineChar(name[i],name[a],i MOD 4);
    INC(keypos);
    INC(a,2);
    IF a>len-1 THEN
      a:=0;
    ELSIF (a>2) AND (a<10) AND (a MOD 2=0) THEN
      WriteShort(keystring,keypos,SHORT(r.RND(MAX(SHORTINT))));
    END;
  END;
  WriteInt(keystring,keypos,r.RND(MAX(INTEGER)));
  keystring[keypos]:=CombineChar(userIdStr[0],name[0],0);
  INC(keypos);
  IF len>30 THEN
    WriteInt(keystring,keypos,r.RND(MAX(INTEGER)));
    WriteInt(keystring,keypos,Combine(Int(name,15),Int(name,29),3));
    WriteInt(keystring,keypos,Combine(Int(name,1),Int(name,27),2));
    WriteInt(keystring,keypos,Combine(Int(name,21),Int(name,8),1));
    WriteInt(keystring,keypos,Combine(Int(name,8),Int(name,11),0));
    WriteInt(keystring,keypos,r.RND(MAX(INTEGER)));
    WriteInt(keystring,keypos,Combine(Int(name,0),Int(name,20),2));
  END;
  RETURN keypos;
END CreateKeyFile;

PROCEDURE CheckKeyFile*(VAR isOk:BOOLEAN;keystring:ARRAY OF CHAR;VAR name:ARRAY OF CHAR;VAR userId:INTEGER):BOOLEAN;

VAR i,a,len,
    keypos,
    int       : INTEGER;
    str16,
    userIdStr : string16;
    str       : ARRAY 80 OF CHAR;
    ret       : BOOLEAN;
    short     : SHORTINT;
    saveIdChar: CHAR;

BEGIN
  keypos:=0;
  ReadInt(keystring,keypos,len);
  i:=0;
  WHILE i<len DO
    str16[0]:=keystring[keypos];
    str16[1]:=keystring[keypos+1];
    str16:=s.VAL(string16,s.ROT(s.VAL(SET,str16),-(i MOD 15+1)));
    name[i]:=str16[0];
    name[i+1]:=str16[1];
    INC(keypos,2);
    INC(i,2);
    IF i>20 THEN
      name[i]:=" ";
      name[i+1]:=" ";
      INC(i,2);
    END;
  END;
  ret:=TRUE;
  error:=TRUE;
  FOR i:=0 TO len-1 DO
    IF (keystring[keypos]=name[i]) OR ((i>20) AND (name[i]=" ")) THEN
      name[i]:=keystring[keypos];
    ELSE
      ret:=FALSE;
      error:=FALSE;
    END;
    INC(keypos);
  END;
  ReadInt(keystring,keypos,i);
  ReadInt(keystring,keypos,i);
  ReadInt(keystring,keypos,i);
  IF s.VAL(SHORTINT,name[0])+s.VAL(SHORTINT,name[len-1])#i THEN
    ret:=FALSE;
    error:=FALSE;
    keystring[len]:=" ";
  ELSE
    keystring[len]:="#";
  END;
  isOk:=ret;
  ReadInt(keystring,keypos,i);
  IF s.VAL(SHORTINT,name[0])+s.VAL(SHORTINT,name[0])#i THEN
    ret:=FALSE;
    isOk:=FALSE;
    error:=FALSE;
    keystring[len]:=" ";
  ELSE
    keystring[len DIV 2]:="*";
  END;
  FOR i:=0 TO len-1 BY 2 DO
    IF (i MOD 7#0) AND (i#10) AND (len MOD i#0) THEN
      ReadInt(keystring,keypos,int);
      IF s.VAL(SHORTINT,name[i])+s.VAL(SHORTINT,name[len-i-1])#int THEN
        ret:=FALSE;
        isOk:=FALSE;
        error:=FALSE;
      END;
    ELSE
      ReadInt(keystring,keypos,int);
      IF int=0 THEN
        keystring[0]:=" ";
      END;
    END;
  END;
  userIdStr[0]:=keystring[keypos];
  INC(keypos);
  IF len>10 THEN
    refpos[0]:=keypos;
    ReadInt(keystring,keypos,i);
    IF Combine(Int(name,1),Int(name,2),0)#i THEN;
      ret:=FALSE;
      error:=FALSE;
    END;
    ReadInt(keystring,keypos,i);
    ReadInt(keystring,keypos,i);
    IF Combine(Int(name,5),Int(name,9),3)#i THEN;
(*      ret:=FALSE;*)
      error:=FALSE;
    END;
    ReadInt(keystring,keypos,i);
    IF i#Combine(Int(name,0),Int(name,0),2) THEN
(*      ret:=FALSE;*)
      error:=FALSE;
    END;
    refpos[1]:=keypos;
    ReadInt(keystring,keypos,i);
    IF Combine(Int(name,6),Int(name,3),0)#i THEN
      isOk:=FALSE;
      error:=FALSE;
    END;
    ReadInt(keystring,keypos,i);
    IF i#Combine(Int(name,1),Int(name,2),1) THEN
      ret:=FALSE;
      isOk:=FALSE;
      error:=FALSE;
    END;
    ReadInt(keystring,keypos,i);
    IF i#r.RND(MAX(INTEGER)) THEN
      keystring[1]:=" ";
    END;
  ELSE
    refpos[0]:=-1;
    refpos[1]:=-1;
  END;
  saveIdChar:=keystring[keypos];
  INC(keypos);
  IF len>20 THEN
    refpos[2]:=keypos;
    ReadInt(keystring,keypos,i);
    IF i#Combine(Int(name,1),Int(name,17),0) THEN
      ret:=FALSE;
      isOk:=FALSE;
      error:=FALSE;
    END;
    ReadInt(keystring,keypos,i);
    IF Combine(Int(name,2),Int(name,15),1)#i THEN
(*      ret:=FALSE;*)
      error:=FALSE;
    END;
    ReadInt(keystring,keypos,i);
    IF Combine(Int(name,19),Int(name,5),0)#i THEN
      isOk:=FALSE;
      ret:=FALSE;
      error:=FALSE;
    END;
    ReadInt(keystring,keypos,i);
    ReadInt(keystring,keypos,i);
    IF i#Combine(Int(name,10),Int(name,9),3) THEN
      ret:=FALSE;
      isOk:=FALSE;
      error:=FALSE;
    END;
    ReadInt(keystring,keypos,i);
    IF Combine(Int(name,14),Int(name,0),2)#i THEN
(*      ret:=FALSE;*)
      error:=FALSE;
    END;
    ReadInt(keystring,keypos,i);
  ELSE
    refpos[2]:=-1;
  END;
  userIdStr[1]:=keystring[keypos];
  INC(keypos);
  IF saveIdChar#CombineChar(userIdStr[0],userIdStr[1],3) THEN
    ret:=FALSE;
    isOk:=FALSE;
    error:=FALSE;
  END;
  a:=len DIV 4;
  FOR i:=1 TO len-1 BY 2 DO
    IF keystring[keypos]#CombineChar(name[i],name[a],i MOD 4) THEN
      isOk:=FALSE;
      ret:=FALSE;
      error:=FALSE;
    END;
    INC(keypos);
    INC(a,2);
    IF a>len-1 THEN
      a:=0;
    ELSIF (a>2) AND (a<10) AND (a MOD 2=0) THEN
      ReadShort(keystring,keypos,short);
    END;
  END;
  userId:=s.VAL(INTEGER,userIdStr);
  ReadInt(keystring,keypos,i);
  IF keystring[keypos]#CombineChar(userIdStr[0],name[0],0) THEN
    isOk:=FALSE;
    error:=FALSE;
  END;
  INC(keypos);
  IF len>30 THEN
    ReadInt(keystring,keypos,i);
    ReadInt(keystring,keypos,i);
    IF i#Combine(Int(name,15),Int(name,29),3) THEN
      isOk:=FALSE;
      error:=FALSE;
    END;
    ReadInt(keystring,keypos,i);
    IF Combine(Int(name,1),Int(name,27),2)#i THEN
(*      ret:=FALSE;*)
      error:=FALSE;
    END;
    ReadInt(keystring,keypos,i);
    IF Combine(Int(name,21),Int(name,8),1)#i THEN
      ret:=FALSE;
      error:=FALSE;
    END;
    ReadInt(keystring,keypos,i);
    IF i#Combine(Int(name,8),Int(name,11),0) THEN
(*      ret:=FALSE;*)
      error:=FALSE;
    END;
    ReadInt(keystring,keypos,i);
    refpos[3]:=keypos;
    ReadInt(keystring,keypos,i);
    IF i#Combine(Int(name,0),Int(name,20),2) THEN
      ret:=FALSE;
      isOk:=FALSE;
      error:=FALSE;
    END;
  ELSE
    refpos[3]:=-1;
  END;
  IF (keystring[len]#"#") OR (keystring[len DIV 2]#"*") THEN
    RETURN FALSE;
  ELSE
    RETURN ret;
  END;
END CheckKeyFile;

BEGIN
(*  io.WriteString("KeyFileCreator V0.9  © 1994 Marc Necker\n");
  io.WriteString("Adresse: ");
  io.ReadString(name);
  io.WriteString("Schreibe nach: ");
  io.ReadString(filename);
  st.Append(filename,"Analay.keyfile");
  IF name[0]#0X THEN
    len:=CreateKeyFile(keystr,name);
    file:=d.Open(filename,d.newFile);
    long:=d.Write(file,keystr,len);
    bool:=CheckKeyFile(keystr,name);
    bool:=d.Close(file);
  ELSE
    file:=d.Open(filename,d.oldFile);
    long:=d.Read(file,keystr,1024);
    bool:=CheckKeyFile(keystr,name);
    IF bool THEN
      io.WriteString("KeyFile OK!\n");
      io.WriteString("Adresse: ");
      io.WriteString(name);
      io.WriteLn;
    ELSE
      io.WriteString("KeyFile ungültig!\n");
    END;
    bool:=d.Close(file);
  END;*)
END KeyFiles.

